// API Client Service for Cloud Functions
// Provides Dart interface to the backend API

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/compliance_models.dart';

class ComplianceApiClient {
  final String baseUrl;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  ComplianceApiClient({
    this.baseUrl = 'https://us-central1-your-project-id.cloudfunctions.net/api',
  });

  /// Get authorization header with Firebase auth token
  /// For emulator/development: requests without auth tokens are allowed
  Future<Map<String, String>> _getHeaders() async {
    final user = _auth.currentUser;
    print('_getHeaders: currentUser = $user');
    
    String? token;
    if (user != null) {
      token = await user.getIdToken();
      print('_getHeaders: Token obtained: ${token != null}');
    } else {
      print('_getHeaders: No user logged in, proceeding without token (emulator mode)');
    }
    
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Fetch questions for a compliance type
  Future<List<ComplianceQuestion>> getQuestions({
    ComplianceType type = ComplianceType.sox,
    QuestionCategory? category,
  }) async {
    try {
      final headers = await _getHeaders();
      String url = '$baseUrl/questions?complianceType=${type.toString().split('.').last}';

      if (category != null) {
        url += '&category=${category.toString().split('.').last}';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch questions: ${response.body}');
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final data = json['data'] as List;

      return data.map((q) {
        // Convert API response to ComplianceQuestion
        return ComplianceQuestion(
          id: q['id'],
          complianceType: ComplianceType.sox,
          category: _parseCategory(q['category']),
          questionText: q['questionText'],
          description: q['description'],
          weight: (q['weight'] as num?)?.toDouble(),
          order: q['order'] ?? 0,
          createdAt: DateTime.parse(q['createdAt']),
        );
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Fetch a single question
  Future<ComplianceQuestion> getQuestion(String questionId) async {
    try {
      final headers = await _getHeaders();

      final response = await http.get(
        Uri.parse('$baseUrl/questions/$questionId'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch question: ${response.body}');
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final q = json['data'];

      return ComplianceQuestion(
        id: q['id'],
        complianceType: ComplianceType.sox,
        category: _parseCategory(q['category']),
        questionText: q['questionText'],
        description: q['description'],
        weight: (q['weight'] as num?)?.toDouble(),
        order: q['order'] ?? 0,
        createdAt: DateTime.parse(q['createdAt']),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Fetch all assessments for current user
  Future<List<QuestionAssessment>> getAssessments() async {
    try {
      final headers = await _getHeaders();

      final response = await http.get(
        Uri.parse('$baseUrl/assessments'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch assessments: ${response.body}');
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final data = json['data'] as List;

      return data.map((a) {
        return QuestionAssessment(
          id: a['id'],
          userId: a['userId'],
          questionId: a['questionId'],
          completionState: _parseCompletionState(a['completionState']),
          notes: a['notes'],
          lastUpdated: DateTime.parse(a['lastUpdated']),
          lastUpdatedBy: a['lastUpdatedBy'],
        );
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Fetch assessment for a specific question
  Future<QuestionAssessment?> getAssessment(String questionId) async {
    try {
      final headers = await _getHeaders();

      final response = await http.get(
        Uri.parse('$baseUrl/assessments/$questionId'),
        headers: headers,
      );

      if (response.statusCode == 404) {
        return null;
      }

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch assessment: ${response.body}');
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final a = json['data'];

      return QuestionAssessment(
        id: a['id'],
        userId: a['userId'],
        questionId: a['questionId'],
        completionState: _parseCompletionState(a['completionState']),
        notes: a['notes'],
        lastUpdated: DateTime.parse(a['lastUpdated']),
        lastUpdatedBy: a['lastUpdatedBy'],
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Create or update an assessment
  Future<void> updateAssessment(
    String questionId,
    CompletionState state, {
    String? notes,
  }) async {
    try {
      final headers = await _getHeaders();

      final body = {
        'completionState': state.toString().split('.').last,
        'notes': ?notes,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/assessments/$questionId'),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to update assessment: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Delete an assessment
  Future<void> deleteAssessment(String questionId) async {
    try {
      final headers = await _getHeaders();

      final response = await http.delete(
        Uri.parse('$baseUrl/assessments/$questionId'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete assessment: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Calculate readiness for a compliance type
  Future<ReadinessMetrics> getReadiness({
    ComplianceType type = ComplianceType.sox,
  }) async {
    try {
      final headers = await _getHeaders();

      final response = await http.get(
        Uri.parse('$baseUrl/readiness?complianceType=${type.toString().split('.').last}'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch readiness: ${response.body}');
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final m = json['data'];

      return ReadinessMetrics(
        userId: m['userId'],
        complianceType: ComplianceType.sox,
        readinessPercentage: (m['readinessPercentage'] as num).toDouble(),
        readinessDecimal: (m['readinessDecimal'] as num).toDouble(),
        totalQuestions: m['totalQuestions'],
        completeCount: m['completeCount'],
        partialCount: m['partialCount'],
        notStartedCount: m['notStartedCount'],
        isReadyForAuditors: m['isReadyForAuditors'],
        threshold: (m['threshold'] as num).toDouble(),
        calculatedAt: DateTime.parse(m['calculatedAt']),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get complete dashboard data
  Future<DashboardData> getDashboard({
    ComplianceType type = ComplianceType.sox,
  }) async {
    try {
      print('getDashboard: Getting headers...');
      final headers = await _getHeaders();
      print('getDashboard: Headers obtained, calling API...');

      final url = '$baseUrl/dashboard?complianceType=${type.toString().split('.').last}';
      print('getDashboard: URL = $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      print('getDashboard: Response status = ${response.statusCode}');

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch dashboard: ${response.statusCode} - ${response.body}');
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return DashboardData.fromJson(json['data']);
    } catch (e) {
      print('getDashboard error: $e');
      rethrow;
    }
  }

  // Helper functions

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
}
