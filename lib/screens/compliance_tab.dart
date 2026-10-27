import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/compliance_api_client.dart';
import '../models/compliance_models.dart';
import '../models/activity_models.dart';
import '../data/sox_questions.dart';
import '../data/regulatory_text.dart';
import '../data/process_guides.dart';
import 'process_guide_screen.dart';
import 'sox_activity_view.dart';

enum ViewMode { education, activity }

class ComplianceTab extends StatefulWidget {
  const ComplianceTab({super.key});

  @override
  State<ComplianceTab> createState() => _ComplianceTabState();
}

class _ComplianceTabState extends State<ComplianceTab> {
  late ComplianceApiClient _apiClient;
  bool _isAuthenticated = false;
  final bool _useRealApi = false; // Toggle to use real API when ready
  late DashboardData _mockDashboard;
  late Map<String, String?> _answers; // Track user responses
  late Map<String, ControlRowData>
  _controlRows; // Activity view execution state
  ViewMode _viewMode = ViewMode.education;

  @override
  void initState() {
    super.initState();
    _apiClient = ComplianceApiClient(
      baseUrl: 'http://127.0.0.1:5001/accedr/us-central1/api',
    );
    _answers = {};
    _initializeAuth();
    _createMockDashboard();
  }

  void _createMockDashboard() {
    _mockDashboard = DashboardData(
      metrics: DashboardMetrics(
        totalQuestions: soxComplianceQuestions.length,
        answeredQuestions: 0,
        readinessPercentage: 0.0,
        criticityScore: 0.0,
      ),
      nextSteps: [],
      status: 'In Progress',
      lastUpdated: DateTime.now(),
      questions: soxComplianceQuestions,
    );
    // Initialise activity-view control rows for every question
    _controlRows = {
      for (final q in soxComplianceQuestions)
        q.id: ControlRowData(questionId: q.id),
    };
  }

  /// Mark a control as initialised (Unscoped → Not Started).
  void _initializeControl(ComplianceQuestion question) {
    setState(() {
      final current =
          _controlRows[question.id] ?? ControlRowData(questionId: question.id);
      if (current.status == ControlStatus.unscoped) {
        _controlRows[question.id] = current.copyWith(
          status: ControlStatus.notStarted,
        );
      }
    });
  }

  Widget _buildViewToggle() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: SegmentedButton<ViewMode>(
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: const Color(0xFF1F4788),
          selectedForegroundColor: Colors.white,
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        segments: const [
          ButtonSegment(
            value: ViewMode.education,
            icon: Icon(Icons.school_outlined, size: 16),
            label: Text('Education View'),
          ),
          ButtonSegment(
            value: ViewMode.activity,
            icon: Icon(Icons.grid_on_outlined, size: 16),
            label: Text('Activity View'),
          ),
        ],
        selected: {_viewMode},
        onSelectionChanged: (s) => setState(() => _viewMode = s.first),
      ),
    );
  }

  Future<void> _initializeAuth() async {
    try {
      print('Starting authentication...');

      // Ensure user is signed in
      if (FirebaseAuth.instance.currentUser == null) {
        print('No user found, signing in anonymously...');
        await FirebaseAuth.instance.signInAnonymously();
        print('Anonymous sign-in successful');
      }

      // Get ID token to verify auth works
      final token = await FirebaseAuth.instance.currentUser?.getIdToken();
      print('Got ID token: ${token != null}');

      if (mounted) {
        setState(() {
          _isAuthenticated = true;
        });
      }
    } catch (e) {
      print('Auth error: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Authentication failed: $e')));
      }
      // Don't rethrow - continue with mock data
    }
  }

  void _refreshDashboard() {
    setState(() {});
  }

  void _resetAllAnswers() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset All Answers'),
        content: const Text(
          'Are you sure you want to reset all answers? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _answers.clear();
              });
              Navigator.pop(context);
            },
            child: const Text(
              'Reset',
              style: TextStyle(color: Color(0xFFDC2626)),
            ),
          ),
        ],
      ),
    );
  }

  DashboardData _getUpdatedDashboard() {
    // Calculate updated metrics based on answers
    final totalQuestions = _mockDashboard.questions.length;
    int answeredCount = 0;
    int yesCount = 0;

    for (final question in _mockDashboard.questions) {
      // Only count user's explicit answers, not original mock data
      final answer = _answers[question.id];
      if (answer != null) {
        answeredCount++;
        if (answer == 'Yes') {
          yesCount++;
        }
      }
    }

    final readinessPercentage = totalQuestions > 0
        ? (answeredCount / totalQuestions * 100.0)
        : 0.0;

    final updatedMetrics = DashboardMetrics(
      totalQuestions: totalQuestions,
      answeredQuestions: answeredCount,
      readinessPercentage: readinessPercentage,
      criticityScore: 65.0,
    );

    // Update questions with current answers
    final updatedQuestions = _mockDashboard.questions.map((q) {
      final currentAnswer = _answers[q.id];
      if (currentAnswer != null) {
        return ComplianceQuestion(
          id: q.id,
          complianceType: q.complianceType,
          category: q.category,
          questionText: q.questionText,
          order: q.order,
          createdAt: q.createdAt,
          categoryName: q.categoryName,
          criticality: q.criticality,
          answered: true,
          response: currentAnswer,
        );
      }
      return q;
    }).toList();

    // Status is green only if all are answered AND all are "Yes"
    final allAnsweredAndYes =
        answeredCount == totalQuestions && yesCount == totalQuestions;

    return DashboardData(
      metrics: updatedMetrics,
      nextSteps: [],
      status: allAnsweredAndYes
          ? 'All Questions Answered'
          : answeredCount == totalQuestions
          ? 'All Questions Answered: Review these areas for improvement'
          : 'In Progress',
      lastUpdated: DateTime.now(),
      questions: updatedQuestions,
    );
  }

  void _showAnswerDialog(ComplianceQuestion question, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(question.questionText),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Category: ${question.categoryName}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Chip(
                      label: Text(question.criticality),
                      backgroundColor: question.criticality == 'High'
                          ? Colors.red[100]
                          : Colors.orange[100],
                    ),
                  ],
                ),
              ),
              const Text(
                'Your Response:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ..._buildAnswerOptions(question),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(ComplianceQuestion question) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        actionsAlignment: MainAxisAlignment.spaceBetween,
        title: Row(
          children: [
            const Icon(Icons.info, color: Color(0xFF1F4788)),
            const SizedBox(width: 8),
            Expanded(child: Text(question.questionText)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFBFDBFE), width: 1),
              ),
              child: Text(
                'Q${question.order}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E40AF),
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Legal Reference Section
              if (question.legalReference != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F4788),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Legal Reference',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        question.legalReference!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              if (question.legalReference != null) const SizedBox(height: 16),
              // Category & Criticality Section
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F4788).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF1F4788).withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Category: ${question.categoryName}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Color(0xFF1F4788),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text(
                          'Criticality: ',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: question.criticality == 'High'
                                ? Colors.red[100]
                                : Colors.orange[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            question.criticality,
                            style: TextStyle(
                              color: question.criticality == 'High'
                                  ? Colors.red[700]
                                  : Colors.orange[700],
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Guidance:',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 8),
              MarkdownBody(
                data:
                    question.description ??
                    'No additional guidance available for this question.',
                styleSheet: MarkdownStyleSheet(
                  p: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                  strong: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[800],
                    fontWeight: FontWeight.w700,
                  ),
                  listBullet: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  a: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF1F4788),
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
                onTapLink: (text, href, title) {
                  if (href == null) return;
                  if (href.startsWith('http://') ||
                      href.startsWith('https://')) {
                    launchUrl(
                      Uri.parse(href),
                      mode: LaunchMode.externalApplication,
                    );
                    return;
                  }
                  final matches = _mockDashboard.questions.where(
                    (q) => q.id == href,
                  );
                  if (matches.isNotEmpty) {
                    Navigator.pop(context);
                    _showInfoDialog(matches.first);
                  }
                },
              ),
              const SizedBox(height: 16),
              // Related Question Link
              if (question.id == 'q4')
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!, width: 1),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(
                                text:
                                    'This code of ethics needs to be immediately disclosed where possible - ',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                              TextSpan(
                                text: 'Jump to Question 37',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF1F4788),
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.pop(context);
                                    final q37 = _mockDashboard.questions
                                        .firstWhere((q) => q.id == 'q37');
                                    _showInfoDialog(q37);
                                  },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              // Expandable Regulatory Text Section
              if (question.legalReference != null &&
                  question.legalReference!.isNotEmpty)
                _buildRegulatoryTextExpansion(question.legalReference!),
            ],
          ),
        ),
        actions: [
          if (processGuides.containsKey(question.id))
            TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        ProcessGuideScreen(guide: processGuides[question.id]!),
                  ),
                );
              },
              icon: const Icon(Icons.menu_book_outlined, size: 16),
              label: const Text('View Process Guide'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF1F4788),
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
            )
          else
            const SizedBox.shrink(),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () {
                  _initializeControl(question);
                  Navigator.pop(context);
                  setState(() => _viewMode = ViewMode.activity);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Q${question.order} initialized — tracking in Activity View.',
                      ),
                      backgroundColor: const Color(0xFF059669),
                      duration: const Duration(seconds: 3),
                    ),
                  );
                },
                icon: const Icon(Icons.play_circle_outline, size: 16),
                label: const Text('Got it, initialize control'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF059669),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  textStyle: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Extract SEC number from legal reference and build a colored badge
  Widget _buildSecBadge(String? legalReference) {
    if (legalReference == null || legalReference.isEmpty) {
      return const SizedBox.shrink();
    }

    // Extract SEC number from "SEC. XXX [..."
    final secMatch = RegExp(r'SEC\.\s*(\d+)').firstMatch(legalReference);
    if (secMatch == null) {
      return const SizedBox.shrink();
    }

    final secNumber = secMatch.group(1) ?? '';

    // Map SEC numbers to colors
    final colorMap = {
      '201': (Colors.blue[100]!, Colors.blue[900]!),
      '203': (Colors.purple[100]!, Colors.purple[900]!),
      '204': (Colors.teal[100]!, Colors.teal[900]!),
      '206': (Colors.orange[100]!, Colors.orange[900]!),
      '301': (Colors.green[100]!, Colors.green[900]!),
      '302': (Colors.red[100]!, Colors.red[900]!),
      '304': (Colors.pink[100]!, Colors.pink[900]!),
      '401': (Colors.yellow[100]!, Colors.yellow[900]!),
      '404': (Colors.indigo[100]!, Colors.indigo[900]!),
      '408': (Colors.lime[100]!, Colors.lime[900]!),
      '802': (Colors.cyan[100]!, Colors.cyan[900]!),
      '906': (Colors.grey[300]!, Colors.grey[900]!),
    };

    final colors =
        colorMap[secNumber] ?? (Colors.grey[100]!, Colors.grey[900]!);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.$1,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: colors.$2, width: 0.5),
      ),
      child: Text(
        'SEC. $secNumber',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: colors.$2,
        ),
      ),
    );
  }

  /// Build an expandable section showing the full regulatory text
  Widget _buildRegulatoryTextExpansion(String legalReference) {
    final regulatoryText = getRegulatoryText(legalReference);

    return StatefulBuilder(
      builder: (context, setStateLocal) {
        bool isExpanded = false;

        return StatefulBuilder(
          builder: (context, setStateInner) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.amber[50],
                border: Border.all(color: Colors.amber[300]!, width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      setStateInner(() {
                        isExpanded = !isExpanded;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(
                            isExpanded ? Icons.expand_less : Icons.expand_more,
                            color: Colors.amber[800],
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'View Full Regulatory Text',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Colors.amber[900],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (isExpanded)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          top: BorderSide(color: Colors.amber[300]!, width: 1),
                        ),
                      ),
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: MarkdownBody(
                            data: regulatoryText,
                            styleSheet: MarkdownStyleSheet(
                              p: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[800],
                                height: 1.6,
                                fontFamily: 'Courier',
                              ),
                              a: const TextStyle(
                                color: Color(0xFF1F4788),
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            onTapLink: (text, href, title) {
                              if (href != null && href.startsWith('https://')) {
                                launchUrl(
                                  Uri.parse(href),
                                  mode: LaunchMode.externalApplication,
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  List<Widget> _buildAnswerOptions(ComplianceQuestion question) {
    final currentAnswer = _answers[question.id];
    return [
      RadioListTile<String>(
        title: const Text('Yes'),
        value: 'Yes',
        groupValue: currentAnswer,
        onChanged: (value) {
          setState(() {
            _answers[question.id] = value!;
          });
          Navigator.pop(context);
        },
      ),
      RadioListTile<String>(
        title: const Text('No'),
        value: 'No',
        groupValue: currentAnswer,
        onChanged: (value) {
          setState(() {
            _answers[question.id] = value!;
          });
          Navigator.pop(context);
        },
      ),
      RadioListTile<String>(
        title: const Text('Partially'),
        value: 'Partially',
        groupValue: currentAnswer,
        onChanged: (value) {
          setState(() {
            _answers[question.id] = value!;
          });
          Navigator.pop(context);
        },
      ),
      RadioListTile<String>(
        title: const Text('Not Sure'),
        value: 'Not Sure',
        groupValue: currentAnswer,
        onChanged: (value) {
          setState(() {
            _answers[question.id] = value!;
          });
          Navigator.pop(context);
        },
      ),
    ];
  }

  Widget _buildGroupedQuestions(List<ComplianceQuestion> questions) {
    // Group questions by categoryName
    final Map<String, List<ComplianceQuestion>> grouped = {};
    for (final question in questions) {
      final category = question.categoryName;
      grouped.putIfAbsent(category, () => []).add(question);
    }

    // Define the order of categories
    final categoryOrder = [
      'Governance & Ownership',
      'Risk & Fraud Awareness',
      'Control Activities',
      'Monitoring & Testing',
      'Documentation & Evidence',
      'Gap Questions (Robustness)',
      'Process Questions (Vulnerabilities)',
    ];

    final widgets = <Widget>[];

    for (final category in categoryOrder) {
      if (grouped.containsKey(category)) {
        // Add category header
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 24.0, bottom: 16.0),
            child: Text(
              category,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2937),
              ),
            ),
          ),
        );

        // Add questions for this category
        for (final question in grouped[category]!) {
          widgets.add(_buildQuestionCard(question));
        }
      }
    }

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(children: widgets),
    );
  }

  Widget _buildQuestionCard(ComplianceQuestion question) {
    final currentAnswer = _answers[question.id];

    return GestureDetector(
      onTap: () => _showAnswerDialog(question, 0),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey[100]!, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: const Color(0xFFBFDBFE),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'Q${question.order}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E40AF),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      question.questionText,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.info_outline),
                    iconSize: 20,
                    color: Colors.grey[500],
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => _showInfoDialog(question),
                  ),
                  const SizedBox(width: 8),
                  _buildSecBadge(question.legalReference),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: question.criticality == 'High'
                          ? const Color(0xFFFEE2E2)
                          : const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: question.criticality == 'High'
                            ? const Color(0xFFFCA5A5)
                            : const Color(0xFFFCD34D),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      question.criticality,
                      style: TextStyle(
                        color: question.criticality == 'High'
                            ? const Color(0xFFDC2626)
                            : const Color(0xFFD97706),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: currentAnswer != null
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: currentAnswer == 'Yes'
                                  ? const Color(0xFFD1FAE5)
                                  : currentAnswer == 'No'
                                  ? const Color(0xFFFEE2E2)
                                  : const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: currentAnswer == 'Yes'
                                    ? const Color(0xFF6EE7B7)
                                    : currentAnswer == 'No'
                                    ? const Color(0xFFFCA5A5)
                                    : const Color(0xFFFCD34D),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              'Response: $currentAnswer',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: currentAnswer == 'Yes'
                                    ? const Color(0xFF059669)
                                    : currentAnswer == 'No'
                                    ? const Color(0xFFDC2626)
                                    : const Color(0xFFD97706),
                              ),
                            ),
                          )
                        : Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: Colors.grey[300]!,
                                width: 1,
                              ),
                            ),
                            child: const Text(
                              'Not answered',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.edit_outlined, size: 18, color: Colors.grey[400]),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dashboard = _getUpdatedDashboard();
    return Column(
      children: [
        _buildViewToggle(),
        Expanded(
          child: _viewMode == ViewMode.activity
              ? SoxActivityView(
                  questions: dashboard.questions,
                  answers: _answers,
                  controlRows: _controlRows,
                  onAnswerChanged: (id, ans) =>
                      setState(() => _answers[id] = ans),
                  onRowChanged: (id, row) =>
                      setState(() => _controlRows[id] = row),
                )
              : _buildEducationView(dashboard),
        ),
      ],
    );
  }

  Widget _buildEducationView(DashboardData dashboard) {
    // Use updated dashboard with current answers
    final metrics = dashboard.metrics;

    return RefreshIndicator(
      onRefresh: () async {
        _refreshDashboard();
      },
      color: const Color(0xFF1F4788),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Readiness Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey[100]!, width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'SOX Readiness Status',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Progress Ring
                      Center(
                        child: Column(
                          children: [
                            SizedBox(
                              height: 180,
                              width: 180,
                              child: CustomPaint(
                                painter: SegmentedRingPainter(
                                  segments: dashboard.questions.length,
                                  answers: [
                                    for (final q in dashboard.questions)
                                      _answers[q.id],
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              dashboard.status.contains(
                                    'All Questions Answered',
                                  )
                                  ? 'Readiness Complete'
                                  : '${metrics.readinessPercentage.toStringAsFixed(0)}% Complete',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Status
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: dashboard.status.contains('Review these areas')
                              ? const Color(0xFFFEF3C7)
                              : dashboard.status.contains(
                                  'All Questions Answered',
                                )
                              ? const Color(0xFFD1FAE5)
                              : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                dashboard.status.contains('Review these areas')
                                ? const Color(0xFFF59E0B)
                                : dashboard.status.contains(
                                    'All Questions Answered',
                                  )
                                ? const Color(0xFF10B981)
                                : Colors.grey[300]!,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              dashboard.status.contains(
                                    'All Questions Answered',
                                  )
                                  ? Icons.check_circle
                                  : Icons.info_outline,
                              color:
                                  dashboard.status.contains(
                                    'Review these areas',
                                  )
                                  ? const Color(0xFFD97706)
                                  : dashboard.status.contains(
                                      'All Questions Answered',
                                    )
                                  ? const Color(0xFF059669)
                                  : const Color(0xFF6B7280),
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                dashboard.status,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      dashboard.status.contains(
                                        'Review these areas',
                                      )
                                      ? const Color(0xFFD97706)
                                      : dashboard.status.contains(
                                          'All Questions Answered',
                                        )
                                      ? const Color(0xFF059669)
                                      : const Color(0xFF6B7280),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Stats
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _StatItem(
                            label: 'Total',
                            value: '${metrics.totalQuestions}',
                            color: const Color(0xFF3B82F6),
                          ),
                          _StatItem(
                            label: 'Answered',
                            value: '${metrics.answeredQuestions}',
                            color: const Color(0xFF10B981),
                          ),
                          _StatItem(
                            label: 'Pending',
                            value:
                                '${metrics.totalQuestions - metrics.answeredQuestions}',
                            color: const Color(0xFFF59E0B),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Questions Section - Grouped by Category
              _buildGroupedQuestions(dashboard.questions),
              const SizedBox(height: 32),
              // Reset All Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _resetAllAnswers,
                  icon: const Icon(Icons.restore),
                  label: const Text('Reset All Answers'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B7280),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class SegmentedRingPainter extends CustomPainter {
  final int segments;
  final List<String?> answers;

  SegmentedRingPainter({required this.segments, required this.answers});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 28;

    // Draw background circle
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.grey[300]!
        ..style = PaintingStyle.stroke
        ..strokeWidth = 28,
    );

    // Draw segments
    for (int i = 0; i < segments; i++) {
      final startAngle = (i / segments * 2 * 3.14159) - 3.14159 / 2;
      final sweepAngle =
          (1 / segments * 2 * 3.14159) - 0.05; // Small gap between segments

      Color segmentColor;
      final answer = answers[i];

      // Check if all answers are "Yes"
      final allYes = answers.every((a) => a == 'Yes');

      if (allYes) {
        // All blue when complete
        segmentColor = const Color(0xFF1F4788);
      } else if (answer == null) {
        segmentColor = Colors.grey[400]!;
      } else if (answer == 'Yes') {
        segmentColor = Colors.green;
      } else if (answer == 'No') {
        segmentColor = Colors.red;
      } else {
        segmentColor = Colors.orange;
      }

      paint.color = segmentColor;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(SegmentedRingPainter oldDelegate) {
    return oldDelegate.answers != answers;
  }
}
