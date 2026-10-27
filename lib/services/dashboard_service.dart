/// Dashboard service that aggregates readiness data and action items.
/// Provides a high-level view of SOX compliance readiness status.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/compliance_models.dart';
import 'firebase_services.dart';
import 'readiness_calculator.dart';

class DashboardService {
  final ReadinessCalculator _readinessCalculator;
  final ComplianceQuestionService _questionService;
  final AssessmentService _assessmentService;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DashboardService({
    ReadinessCalculator? readinessCalculator,
    ComplianceQuestionService? questionService,
    AssessmentService? assessmentService,
  })  : _readinessCalculator = readinessCalculator ?? ReadinessCalculator(),
        _questionService = questionService ?? ComplianceQuestionService(),
        _assessmentService = assessmentService ?? AssessmentService();

  /// Get complete dashboard data for a user
  /// This is the main endpoint for the dashboard view
  Future<DashboardData> getDashboardData(
    String userId,
    ComplianceType complianceType,
  ) async {
    try {
      // Calculate readiness metrics
      final metrics = await _readinessCalculator.calculateReadiness(userId, complianceType);

      // Generate action items from incomplete questions
      final actionItems =
          await _readinessCalculator.generateActionItems(userId, complianceType);

      // Determine status based on readiness
      final status = _generateStatus(metrics);

      // Create dashboard data
      final dashboardData = DashboardData(
        metrics: metrics,
        nextSteps: actionItems,
        status: status,
        lastUpdated: DateTime.now(),
      );

      // Cache the dashboard data
      await _cacheDashboardData(userId, complianceType, dashboardData);

      return dashboardData;
    } catch (e) {
      rethrow;
    }
  }

  /// Stream dashboard data for real-time updates
  Stream<DashboardData> streamDashboardData(
    String userId,
    ComplianceType complianceType,
  ) {
    return _firestore
        .collection('assessments')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .asyncMap((_) => getDashboardData(userId, complianceType));
  }

  /// Get summary statistics for the dashboard
  Future<Map<String, dynamic>> getDashboardSummary(
    String userId,
    ComplianceType complianceType,
  ) async {
    final metrics = await _readinessCalculator.calculateReadiness(userId, complianceType);

    return {
      'readinessPercentage': metrics.readinessPercentage,
      'readinessDecimal': metrics.readinessDecimal,
      'isReadyForAuditors': metrics.isReadyForAuditors,
      'completionRate':
          '${metrics.completeCount}/${metrics.totalQuestions}', // e.g., "12/27"
      'partialCount': metrics.partialCount,
      'notStartedCount': metrics.notStartedCount,
      'nextStepsCount': metrics.notStartedCount + metrics.partialCount,
      'percentageToTarget': _calculatePercentageToTarget(metrics),
      'estimatedItemsToComplete': _estimateItemsToComplete(metrics),
    };
  }

  /// Get breakdown of completion by category
  Future<Map<QuestionCategory, Map<String, int>>> getCategoryBreakdown(
    String userId,
    ComplianceType complianceType,
  ) async {
    // Fetch all questions grouped by category
    final breakdown = <QuestionCategory, Map<String, int>>{};

    for (final category in QuestionCategory.values) {
      final questions =
          await _questionService.getQuestionsByCategory(complianceType, category);
      final questionIds = questions.map((q) => q.id).toSet();

      // Fetch assessments
      final assessments = await _assessmentService.getUserAssessments(userId);

      int completeCount = 0;
      int partialCount = 0;
      int notStartedCount = 0;

      for (final assessment in assessments) {
        if (questionIds.contains(assessment.questionId)) {
          switch (assessment.completionState) {
            case CompletionState.complete:
              completeCount++;
            case CompletionState.partial:
              partialCount++;
            case CompletionState.notStarted:
              notStartedCount++;
          }
        }
      }

      // Include questions without assessments as not started
      final uncountedQuestions = questions.length - (completeCount + partialCount + notStartedCount);
      notStartedCount += uncountedQuestions;

      breakdown[category] = {
        'complete': completeCount,
        'partial': partialCount,
        'notStarted': notStartedCount,
        'total': questions.length,
      };
    }

    return breakdown;
  }

  /// Get priority action items (most urgent next steps)
  /// Prioritizes items based on: not_started > partial, then by category
  Future<List<ActionItem>> getPriorityActionItems(
    String userId,
    ComplianceType complianceType, {
    int limit = 10,
  }) async {
    final allItems =
        await _readinessCalculator.generateActionItems(userId, complianceType);

    // Return top N items (already sorted by priority)
    return allItems.take(limit).toList();
  }

  /// Check if user is ready to engage auditors
  Future<bool> isReadyForAuditors(
    String userId,
    ComplianceType complianceType,
  ) async {
    final metrics = await _readinessCalculator.calculateReadiness(userId, complianceType);
    return metrics.isReadyForAuditors;
  }

  /// Cache dashboard data in Firestore
  Future<void> _cacheDashboardData(
    String userId,
    ComplianceType complianceType,
    DashboardData data,
  ) async {
    try {
      await _firestore
          .collection('dashboard_cache')
          .doc('${userId}_$complianceType')
          .set({
        'userId': userId,
        'complianceType': complianceType.toString().split('.').last,
        'readinessPercentage': data.metrics.readinessPercentage,
        'isReadyForAuditors': data.metrics.isReadyForAuditors,
        'status': data.status,
        'nextStepsCount': data.nextSteps.length,
        'lastUpdated': Timestamp.fromDate(data.lastUpdated),
      }, SetOptions(merge: true));
    } catch (e) {
      // Silently fail cache writes - don't block dashboard
      print('Dashboard cache write failed: $e');
    }
  }

  /// Get cached dashboard data (may be stale)
  Future<Map<String, dynamic>?> getCachedDashboardData(
    String userId,
    ComplianceType complianceType,
  ) async {
    try {
      final doc = await _firestore
          .collection('dashboard_cache')
          .doc('${userId}_$complianceType')
          .get();

      if (!doc.exists) return null;
      return doc.data();
    } catch (e) {
      return null;
    }
  }

  /// Generate status string based on metrics
  String _generateStatus(ReadinessMetrics metrics) {
    if (metrics.isReadyForAuditors) {
      return 'Ready to engage auditors';
    } else {
      final percentageNeeded = (metrics.threshold * 100 - metrics.readinessPercentage).toStringAsFixed(1);
      return 'Not ready ($percentageNeeded% more work needed)';
    }
  }

  /// Calculate percentage progress toward 80% target
  double _calculatePercentageToTarget(ReadinessMetrics metrics) {
    if (metrics.threshold == 0) return 0;
    final progressToTarget = (metrics.readinessDecimal / metrics.threshold) * 100;
    return double.parse(progressToTarget.toStringAsFixed(1));
  }

  /// Estimate how many items need to be marked complete to reach 80%
  int _estimateItemsToComplete(ReadinessMetrics metrics) {
    if (metrics.isReadyForAuditors) return 0;

    // Rough estimate: items at partial or not started that need to go to complete
    // This assumes equal weighting and complete = 1.0, partial = 0.5
    final itemsAtPartial = metrics.partialCount;
    final itemsAtNotStarted = metrics.notStartedCount;

    // Simple heuristic: prioritize moving partials to complete first
    int needed = 0;
    double currentScore = metrics.readinessDecimal;
    double targetScore = metrics.threshold;

    // Move partials to complete (gains 0.5 per item)
    for (int i = 0; i < itemsAtPartial && currentScore < targetScore; i++) {
      currentScore += 0.5 / metrics.totalQuestions;
      needed++;
    }

    // Move not started to complete (gains 1.0 per item)
    for (int i = 0; i < itemsAtNotStarted && currentScore < targetScore; i++) {
      currentScore += 1.0 / metrics.totalQuestions;
      needed++;
    }

    return needed;
  }
}
