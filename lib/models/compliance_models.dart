/// Core data models for compliance readiness system.
/// Supports multiple compliance types with extensible architecture.
library;

import 'package:cloud_firestore/cloud_firestore.dart';

// ============================================================================
// Enums
// ============================================================================

enum ComplianceType { sox }

enum QuestionCategory {
  accessControls,
  changeManagement,
  financialReporting,
  itControls,
  documentation,
  testing,
}

enum CompletionState { notStarted, partial, complete }

// ============================================================================
// Compliance Type
// ============================================================================

/// Represents a compliance framework (e.g., SOX)
class ComplianceFramework {
  final String id;
  final String name;
  final String description;
  final double readinessThreshold; // 0.0 - 1.0
  final int questionCount;
  final DateTime createdAt;

  ComplianceFramework({
    required this.id,
    required this.name,
    required this.description,
    required this.readinessThreshold,
    required this.questionCount,
    required this.createdAt,
  });

  factory ComplianceFramework.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ComplianceFramework(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      readinessThreshold: (data['readinessThreshold'] ?? 0.8).toDouble(),
      questionCount: data['questionCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'readinessThreshold': readinessThreshold,
      'questionCount': questionCount,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

// ============================================================================
// Compliance Question
// ============================================================================

/// Represents a compliance question/control
class ComplianceQuestion {
  final String id;
  final ComplianceType complianceType;
  final QuestionCategory category;
  final String questionText;
  final String? description;
  final String? legalReference; // e.g., "SEC. 404 [15 U.S.C. 7262]"
  final double? weight; // Optional weight, defaults to equal weighting
  final int order; // For display ordering
  final DateTime createdAt;
  final String categoryName;
  final String criticality;
  final bool answered;
  final String? response;

  ComplianceQuestion({
    required this.id,
    required this.complianceType,
    required this.category,
    required this.questionText,
    this.description,
    this.legalReference,
    this.weight,
    required this.order,
    required this.createdAt,
    String? categoryName,
    String? criticality,
    bool? answered,
    String? response,
  })
      : categoryName = categoryName ?? 'General',
        criticality = criticality ?? 'Medium',
        answered = answered ?? false,
        response = response;

  factory ComplianceQuestion.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ComplianceQuestion(
      id: doc.id,
      complianceType: _parseComplianceType(data['complianceType']),
      category: _parseCategory(data['category']),
      questionText: data['questionText'] ?? '',
      description: data['description'],
      weight: (data['weight'] as num?)?.toDouble(),
      order: data['order'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'complianceType': complianceType.toString().split('.').last,
      'category': category.toString().split('.').last,
      'questionText': questionText,
      'description': description,
      'weight': weight,
      'order': order,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

// ============================================================================
// Assessment / User Response
// ============================================================================

/// Represents a user's response to a compliance question
class QuestionAssessment {
  final String id;
  final String userId;
  final String questionId;
  final CompletionState completionState;
  final String? notes;
  final DateTime lastUpdated;
  final String? lastUpdatedBy; // User or system

  QuestionAssessment({
    required this.id,
    required this.userId,
    required this.questionId,
    required this.completionState,
    this.notes,
    required this.lastUpdated,
    this.lastUpdatedBy,
  });

  factory QuestionAssessment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return QuestionAssessment(
      id: doc.id,
      userId: data['userId'] ?? '',
      questionId: data['questionId'] ?? '',
      completionState: _parseCompletionState(data['completionState']),
      notes: data['notes'],
      lastUpdated: (data['lastUpdated'] as Timestamp).toDate(),
      lastUpdatedBy: data['lastUpdatedBy'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'questionId': questionId,
      'completionState': completionState.toString().split('.').last,
      'notes': notes,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'lastUpdatedBy': lastUpdatedBy,
    };
  }

  /// Get score for this assessment (0 to 1)
  double getScore() {
    switch (completionState) {
      case CompletionState.notStarted:
        return 0.0;
      case CompletionState.partial:
        return 0.5;
      case CompletionState.complete:
        return 1.0;
    }
  }
}

// ============================================================================
// Readiness Metrics
// ============================================================================

/// Simple metrics for dashboard display
class DashboardMetrics {
  final int totalQuestions;
  final int answeredQuestions;
  final double readinessPercentage;
  final double criticityScore;

  DashboardMetrics({
    required this.totalQuestions,
    required this.answeredQuestions,
    required this.readinessPercentage,
    required this.criticityScore,
  });
}

/// Calculated readiness metrics for a user
class ReadinessMetrics {
  final String userId;
  final ComplianceType complianceType;
  final double readinessPercentage; // 0 to 100
  final double readinessDecimal; // 0 to 1
  final int totalQuestions;
  final int completeCount;
  final int partialCount;
  final int notStartedCount;
  final bool isReadyForAuditors; // >= threshold
  final double threshold;
  final DateTime calculatedAt;
  // Convenience fields for simple display
  final int answeredQuestions;
  final double criticityScore;

  ReadinessMetrics({
    required this.userId,
    required this.complianceType,
    required this.readinessPercentage,
    required this.readinessDecimal,
    required this.totalQuestions,
    required this.completeCount,
    required this.partialCount,
    required this.notStartedCount,
    required this.isReadyForAuditors,
    required this.threshold,
    required this.calculatedAt,
    int? answeredQuestions,
    double? criticityScore,
  })
      : answeredQuestions = answeredQuestions ?? completeCount,
        criticityScore = criticityScore ?? 65.0;

  factory ReadinessMetrics.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReadinessMetrics(
      userId: data['userId'] ?? '',
      complianceType: _parseComplianceType(data['complianceType']),
      readinessPercentage: (data['readinessPercentage'] ?? 0).toDouble(),
      readinessDecimal: (data['readinessDecimal'] ?? 0).toDouble(),
      totalQuestions: data['totalQuestions'] ?? 0,
      completeCount: data['completeCount'] ?? 0,
      partialCount: data['partialCount'] ?? 0,
      notStartedCount: data['notStartedCount'] ?? 0,
      isReadyForAuditors: data['isReadyForAuditors'] ?? false,
      threshold: (data['threshold'] ?? 0.8).toDouble(),
      calculatedAt: (data['calculatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'complianceType': complianceType.toString().split('.').last,
      'readinessPercentage': readinessPercentage,
      'readinessDecimal': readinessDecimal,
      'totalQuestions': totalQuestions,
      'completeCount': completeCount,
      'partialCount': partialCount,
      'notStartedCount': notStartedCount,
      'isReadyForAuditors': isReadyForAuditors,
      'threshold': threshold,
      'calculatedAt': Timestamp.fromDate(calculatedAt),
    };
  }
}

// ============================================================================
// Dashboard Data
// ============================================================================

/// Next steps / action items derived from incomplete questions
class ActionItem {
  final String questionId;
  final String questionText;
  final QuestionCategory category;
  final CompletionState currentState;
  final String? suggestedAction;

  ActionItem({
    required this.questionId,
    required this.questionText,
    required this.category,
    required this.currentState,
    this.suggestedAction,
  });

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'questionText': questionText,
      'category': category.toString().split('.').last,
      'currentState': currentState.toString().split('.').last,
      'suggestedAction': suggestedAction,
    };
  }
}

/// Complete dashboard view for a user
class DashboardData {
  final dynamic metrics; // Can be ReadinessMetrics or DashboardMetrics for UI flexibility
  final List<ActionItem> nextSteps; // Incomplete items
  final String status; // "Ready to engage auditors" or "Not ready"
  final DateTime lastUpdated;
  final List<ComplianceQuestion> questions; // For simple UI display

  DashboardData({
    required this.metrics,
    required this.nextSteps,
    required this.status,
    required this.lastUpdated,
    List<ComplianceQuestion>? questions,
  }) : questions = questions ?? [];

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    final metrics = ReadinessMetrics(
      userId: json['metrics']['userId'] ?? '',
      complianceType: _parseComplianceType(json['metrics']['complianceType']),
      readinessPercentage: (json['metrics']['readinessPercentage'] ?? 0).toDouble(),
      readinessDecimal: (json['metrics']['readinessDecimal'] ?? 0).toDouble(),
      totalQuestions: json['metrics']['totalQuestions'] ?? 0,
      completeCount: json['metrics']['completeCount'] ?? 0,
      partialCount: json['metrics']['partialCount'] ?? 0,
      notStartedCount: json['metrics']['notStartedCount'] ?? 0,
      isReadyForAuditors: json['metrics']['isReadyForAuditors'] ?? false,
      threshold: (json['metrics']['threshold'] ?? 0.8).toDouble(),
      calculatedAt: DateTime.parse(json['metrics']['calculatedAt']),
    );

    final nextSteps = (json['nextSteps'] as List? ?? [])
        .map((item) => ActionItem(
              questionId: item['questionId'] ?? '',
              questionText: item['questionText'] ?? '',
              category: _parseCategory(item['category']),
              currentState: _parseCompletionState(item['currentState']),
              suggestedAction: item['suggestedAction'],
            ))
        .toList();

    return DashboardData(
      metrics: metrics,
      nextSteps: nextSteps,
      status: json['status'] ?? '',
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'metrics': {
        'userId': metrics.userId,
        'complianceType': metrics.complianceType.toString().split('.').last,
        'readinessPercentage': metrics.readinessPercentage,
        'readinessDecimal': metrics.readinessDecimal,
        'totalQuestions': metrics.totalQuestions,
        'completeCount': metrics.completeCount,
        'partialCount': metrics.partialCount,
        'notStartedCount': metrics.notStartedCount,
        'isReadyForAuditors': metrics.isReadyForAuditors,
        'threshold': metrics.threshold,
        'calculatedAt': metrics.calculatedAt.toIso8601String(),
      },
      'nextSteps': nextSteps.map((item) => item.toJson()).toList(),
      'status': status,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}

// ============================================================================
// Helper functions
// ============================================================================

ComplianceType _parseComplianceType(String? value) {
  return value == 'sox' ? ComplianceType.sox : ComplianceType.sox;
}

QuestionCategory _parseCategory(String? value) {
  switch (value) {
    case 'accessControls':
      return QuestionCategory.accessControls;
    case 'changeManagement':
      return QuestionCategory.changeManagement;
    case 'financialReporting':
      return QuestionCategory.financialReporting;
    case 'itControls':
      return QuestionCategory.itControls;
    case 'documentation':
      return QuestionCategory.documentation;
    case 'testing':
      return QuestionCategory.testing;
    default:
      return QuestionCategory.accessControls;
  }
}

CompletionState _parseCompletionState(String? value) {
  switch (value) {
    case 'partial':
      return CompletionState.partial;
    case 'complete':
      return CompletionState.complete;
    case 'notStarted':
    default:
      return CompletionState.notStarted;
  }
}
