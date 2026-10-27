/// Firebase service for managing compliance questions.
/// Provides queries and operations for compliance framework questions.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/compliance_models.dart';

class ComplianceQuestionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get all questions for a compliance type
  Future<List<ComplianceQuestion>> getQuestionsByType(
    ComplianceType type,
  ) async {
    final snapshot = await _firestore
        .collection('compliance_questions')
        .where('complianceType', isEqualTo: type.toString().split('.').last)
        .orderBy('order', descending: false)
        .get();

    return snapshot.docs
        .map((doc) => ComplianceQuestion.fromFirestore(doc))
        .toList();
  }

  /// Get questions by category
  Future<List<ComplianceQuestion>> getQuestionsByCategory(
    ComplianceType type,
    QuestionCategory category,
  ) async {
    final snapshot = await _firestore
        .collection('compliance_questions')
        .where('complianceType', isEqualTo: type.toString().split('.').last)
        .where('category', isEqualTo: category.toString().split('.').last)
        .orderBy('order', descending: false)
        .get();

    return snapshot.docs
        .map((doc) => ComplianceQuestion.fromFirestore(doc))
        .toList();
  }

  /// Get a single question by ID
  Future<ComplianceQuestion?> getQuestion(String questionId) async {
    final doc =
        await _firestore.collection('compliance_questions').doc(questionId).get();

    if (!doc.exists) return null;
    return ComplianceQuestion.fromFirestore(doc);
  }

  /// Create a new question (admin operation)
  Future<String> createQuestion(ComplianceQuestion question) async {
    final doc = await _firestore
        .collection('compliance_questions')
        .add(question.toFirestore());
    return doc.id;
  }

  /// Update a question (admin operation)
  Future<void> updateQuestion(String questionId, ComplianceQuestion question) async {
    await _firestore
        .collection('compliance_questions')
        .doc(questionId)
        .update(question.toFirestore());
  }

  /// Delete a question (admin operation)
  Future<void> deleteQuestion(String questionId) async {
    await _firestore.collection('compliance_questions').doc(questionId).delete();
  }

  /// Get count of questions by type
  Future<int> getQuestionCount(ComplianceType type) async {
    final snapshot = await _firestore
        .collection('compliance_questions')
        .where('complianceType', isEqualTo: type.toString().split('.').last)
        .count()
        .get();

    return snapshot.count ?? 0;
  }
}

/// Firebase service for managing user assessments.
/// Handles storing and retrieving question completion states.

class AssessmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get assessment for a specific question by user
  Future<QuestionAssessment?> getAssessment(
    String userId,
    String questionId,
  ) async {
    final doc = await _firestore
        .collection('assessments')
        .doc(_assessmentDocId(userId, questionId))
        .get();

    if (!doc.exists) return null;
    return QuestionAssessment.fromFirestore(doc);
  }

  /// Get all assessments for a user
  Future<List<QuestionAssessment>> getUserAssessments(String userId) async {
    final snapshot = await _firestore
        .collection('assessments')
        .where('userId', isEqualTo: userId)
        .get();

    return snapshot.docs
        .map((doc) => QuestionAssessment.fromFirestore(doc))
        .toList();
  }

  /// Get assessments for a user by compliance type
  Future<List<QuestionAssessment>> getUserAssessmentsByType(
    String userId,
    ComplianceType type,
  ) async {
    // Note: In real implementation, you'd want a denormalized field
    // on assessments collection to enable this query more efficiently
    final snapshot = await _firestore
        .collection('assessments')
        .where('userId', isEqualTo: userId)
        .get();

    final assessments = snapshot.docs
        .map((doc) => QuestionAssessment.fromFirestore(doc))
        .toList();

    return assessments; // Further filter by compliance type in service layer
  }

  /// Create or update an assessment
  Future<void> updateAssessment(
    String userId,
    String questionId,
    CompletionState state, {
    String? notes,
    String? updatedBy,
  }) async {
    final assessment = QuestionAssessment(
      id: _assessmentDocId(userId, questionId),
      userId: userId,
      questionId: questionId,
      completionState: state,
      notes: notes,
      lastUpdated: DateTime.now(),
      lastUpdatedBy: updatedBy,
    );

    await _firestore
        .collection('assessments')
        .doc(_assessmentDocId(userId, questionId))
        .set(assessment.toFirestore(), SetOptions(merge: true));
  }

  /// Bulk update assessments
  Future<void> bulkUpdateAssessments(
    String userId,
    List<(String questionId, CompletionState state)> updates,
  ) async {
    final batch = _firestore.batch();

    for (final (questionId, state) in updates) {
      final assessment = QuestionAssessment(
        id: _assessmentDocId(userId, questionId),
        userId: userId,
        questionId: questionId,
        completionState: state,
        lastUpdated: DateTime.now(),
        lastUpdatedBy: null,
      );

      batch.set(
        _firestore
            .collection('assessments')
            .doc(_assessmentDocId(userId, questionId)),
        assessment.toFirestore(),
        SetOptions(merge: true),
      );
    }

    await batch.commit();
  }

  /// Delete an assessment
  Future<void> deleteAssessment(String userId, String questionId) async {
    await _firestore
        .collection('assessments')
        .doc(_assessmentDocId(userId, questionId))
        .delete();
  }

  /// Get assessments grouped by completion state
  Future<Map<CompletionState, int>> getAssessmentStats(String userId) async {
    final assessments = await getUserAssessments(userId);

    final stats = <CompletionState, int>{};
    for (final state in CompletionState.values) {
      stats[state] = 0;
    }

    for (final assessment in assessments) {
      stats[assessment.completionState] = (stats[assessment.completionState] ?? 0) + 1;
    }

    return stats;
  }

  /// Generate document ID for assessment (deterministic)
  String _assessmentDocId(String userId, String questionId) {
    return '${userId}_$questionId';
  }
}
