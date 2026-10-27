/// Readiness scoring logic for compliance frameworks.
/// Calculates overall readiness percentage and generates action items.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/compliance_models.dart';
import 'firebase_services.dart';

class ReadinessCalculator {
  final AssessmentService _assessmentService;
  final ComplianceQuestionService _questionService;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // SOX readiness threshold: 80%
  static const double SOX_THRESHOLD = 0.80;

  ReadinessCalculator({
    AssessmentService? assessmentService,
    ComplianceQuestionService? questionService,
  })  : _assessmentService = assessmentService ?? AssessmentService(),
        _questionService = questionService ?? ComplianceQuestionService();

  /// Calculate readiness metrics for a user
  Future<ReadinessMetrics> calculateReadiness(
    String userId,
    ComplianceType complianceType,
  ) async {
    // Fetch all questions for the compliance type
    final questions = await _questionService.getQuestionsByType(complianceType);
    final totalQuestions = questions.length;

    if (totalQuestions == 0) {
      return ReadinessMetrics(
        userId: userId,
        complianceType: complianceType,
        readinessPercentage: 0.0,
        readinessDecimal: 0.0,
        totalQuestions: 0,
        completeCount: 0,
        partialCount: 0,
        notStartedCount: 0,
        isReadyForAuditors: false,
        threshold: _getThreshold(complianceType),
        calculatedAt: DateTime.now(),
      );
    }

    // Fetch all assessments for the user
    final assessments = await _assessmentService.getUserAssessments(userId);
    final assessmentMap = {
      for (final assessment in assessments) assessment.questionId: assessment
    };

    // Calculate scores
    double totalScore = 0.0;
    int completeCount = 0;
    int partialCount = 0;
    int notStartedCount = 0;

    for (final question in questions) {
      final assessment = assessmentMap[question.id];
      final score = assessment?.getScore() ?? 0.0;

      // Apply question weight if specified
      final weight = question.weight ?? (1.0 / totalQuestions);
      totalScore += score * weight;

      // Track completion states
      switch (assessment?.completionState ?? CompletionState.notStarted) {
        case CompletionState.complete:
          completeCount++;
        case CompletionState.partial:
          partialCount++;
        case CompletionState.notStarted:
          notStartedCount++;
      }
    }

    // Normalize by total questions (if weights don't sum to 1.0)
    final threshold = _getThreshold(complianceType);
    final readinessDecimal = totalScore / totalQuestions;
    final readinessPercentage = readinessDecimal * 100.0;

    return ReadinessMetrics(
      userId: userId,
      complianceType: complianceType,
      readinessPercentage: double.parse(readinessPercentage.toStringAsFixed(2)),
      readinessDecimal: double.parse(readinessDecimal.toStringAsFixed(4)),
      totalQuestions: totalQuestions,
      completeCount: completeCount,
      partialCount: partialCount,
      notStartedCount: notStartedCount,
      isReadyForAuditors: readinessDecimal >= threshold,
      threshold: threshold,
      calculatedAt: DateTime.now(),
    );
  }

  /// Generate action items from incomplete questions
  Future<List<ActionItem>> generateActionItems(
    String userId,
    ComplianceType complianceType,
  ) async {
    // Fetch all questions
    final questions = await _questionService.getQuestionsByType(complianceType);

    // Fetch all assessments
    final assessments = await _assessmentService.getUserAssessments(userId);
    final assessmentMap = {
      for (final assessment in assessments) assessment.questionId: assessment
    };

    final actionItems = <ActionItem>[];

    for (final question in questions) {
      final assessment = assessmentMap[question.id];
      final state = assessment?.completionState ?? CompletionState.notStarted;

      // Only include incomplete items
      if (state != CompletionState.complete) {
        actionItems.add(
          ActionItem(
            questionId: question.id,
            questionText: question.questionText,
            category: question.category,
            currentState: state,
            suggestedAction: _generateSuggestedAction(question, state),
          ),
        );
      }
    }

    // Sort by category then by state (notStarted first)
    actionItems.sort((a, b) {
      final categoryCompare =
          a.category.toString().compareTo(b.category.toString());
      if (categoryCompare != 0) return categoryCompare;

      // not_started (0) < partial (1) < complete (2)
      final stateOrder = {
        CompletionState.notStarted: 0,
        CompletionState.partial: 1,
        CompletionState.complete: 2,
      };
      return (stateOrder[a.currentState] ?? 0)
          .compareTo(stateOrder[b.currentState] ?? 0);
    });

    return actionItems;
  }

  /// Save calculated metrics to Firestore for caching
  Future<void> saveMetrics(ReadinessMetrics metrics) async {
    await _firestore
        .collection('readiness_metrics')
        .doc('${metrics.userId}_${metrics.complianceType}')
        .set(metrics.toFirestore(), SetOptions(merge: true));
  }

  /// Get cached metrics (may be stale)
  Future<ReadinessMetrics?> getCachedMetrics(
    String userId,
    ComplianceType complianceType,
  ) async {
    final doc = await _firestore
        .collection('readiness_metrics')
        .doc('${userId}_$complianceType')
        .get();

    if (!doc.exists) return null;
    return ReadinessMetrics.fromFirestore(doc);
  }

  /// Get threshold for a compliance type
  double _getThreshold(ComplianceType type) {
    switch (type) {
      case ComplianceType.sox:
        return SOX_THRESHOLD;
    }
  }

  /// Generate a suggested action based on question and completion state
  String _generateSuggestedAction(
    ComplianceQuestion question,
    CompletionState state,
  ) {
    switch (state) {
      case CompletionState.notStarted:
        return 'Start assessment of ${question.category.toString().split('.').last.replaceAllMapped(
          RegExp(r'([a-z])([A-Z])'),
          (match) => '${match.group(1)} ${match.group(2)}',
        )} control';
      case CompletionState.partial:
        return 'Complete remaining assessment work for this control';
      case CompletionState.complete:
        return ''; // Should not appear
    }
  }
}
