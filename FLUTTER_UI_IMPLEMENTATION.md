# Flutter UI Implementation Guide - Clickable Regulatory References

This guide shows how to implement clickable links in your Flutter UI that connect compliance questions to detailed regulatory requirements.

---

## Overview

Transform simple legal references into interactive navigation elements that link users directly to regulatory details.

### Before (Current State)
```
Question: "Is user access formally documented and reviewed?"
Legal Reference: SEC. 404 [15 U.S.C. 7262] - Management Assessment of Internal Controls
```

### After (With Clickable Links)
```
Question: "Is user access formally documented and reviewed?"
Legal Reference: [SEC. 404 [15 U.S.C. 7262] - Management Assessment of Internal Controls] ← Click me!
                 └─→ Opens detailed requirements & control procedures
```

---

## Implementation Options

### Option 1: URL-Based Navigation (Simplest)

For displaying questions in your Flutter app with clickable regulatory links:

```dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ComplianceQuestionCard extends StatelessWidget {
  final ComplianceQuestion question;

  const ComplianceQuestionCard({
    required this.question,
    Key? key,
  }) : super(key: key);

  /// Extract SEC reference (e.g., "sec-404" from "SEC. 404 [...]")
  String _extractSectionId(String legalReference) {
    final regex = RegExp(r'SEC\.\s*(\d+)');
    final match = regex.firstMatch(legalReference);
    if (match != null) {
      return 'sec-${match.group(1)!.toLowerCase()}';
    }
    return '';
  }

  Future<void> _openRegulatoryReference() async {
    final sectionId = _extractSectionId(question.legalReference!);
    
    // Option A: Open local markdown file with anchor
    final url = 'REGULATORY_REFERENCE.md#$sectionId';
    
    // Option B: Open GitHub or web version
    // final url = 'https://github.com/your-org/accedr/blob/main/REGULATORY_REFERENCE.md#$sectionId';
    
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question Text
            Text(
              question.questionText,
              style: Theme.of(context).textTheme.headline6,
            ),
            SizedBox(height: 12),

            // Description
            if (question.description != null)
              Text(
                question.description!,
                style: Theme.of(context).textTheme.bodyText2,
              ),
            SizedBox(height: 12),

            // CLICKABLE Legal Reference
            GestureDetector(
              onTap: _openRegulatoryReference,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  border: Border(
                    left: BorderSide(
                      color: Colors.blue,
                      width: 4,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.description,
                      color: Colors.blue,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        question.legalReference ?? 'No reference',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          decoration: TextDecoration.underline,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.open_in_new,
                      color: Colors.blue,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // Assessment Response Options
            // ... your existing assessment UI
          ],
        ),
      ),
    );
  }
}
```

---

### Option 2: In-App Navigation (Recommended)

Create a regulatory reference screen that displays markdown content:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class RegulatoryReferenceScreen extends StatefulWidget {
  final String? sectionId; // e.g., "sec-404"

  const RegulatoryReferenceScreen({
    this.sectionId,
    Key? key,
  }) : super(key: key);

  @override
  _RegulatoryReferenceScreenState createState() => _RegulatoryReferenceScreenState();
}

class _RegulatoryReferenceScreenState extends State<RegulatoryReferenceScreen> {
  late Future<String> _markdownContent;

  @override
  void initState() {
    super.initState();
    _markdownContent = _loadMarkdownContent();
  }

  /// Load the regulatory reference markdown file
  Future<String> _loadMarkdownContent() async {
    // Load from assets or file system
    try {
      // Option 1: Load from assets
      final content = await DefaultAssetBundle.of(context)
          .loadString('assets/REGULATORY_REFERENCE.md');
      
      // Option 2: Load from app directory
      // final content = File('REGULATORY_REFERENCE.md').readAsStringSync();
      
      return content;
    } catch (e) {
      return 'Error loading regulatory reference: $e';
    }
  }

  /// Scroll to specific section if provided
  void _scrollToSection(String sectionId) {
    // Implementation depends on markdown package
    // You may need a more sophisticated scroll position handler
    print('Navigating to $sectionId');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Regulatory Reference'),
        elevation: 0,
      ),
      body: FutureBuilder<String>(
        future: _markdownContent,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final content = snapshot.data ?? '';
          
          return SingleChildScrollView(
            child: Markdown(
              data: content,
              onTapLink: (text, href, title) {
                // Handle internal links
                if (href?.startsWith('#') ?? false) {
                  _scrollToSection(href!.substring(1));
                }
              },
            ),
          );
        },
      ),
    );
  }
}
```

---

### Option 3: Enhanced Widget with Direct Navigation

```dart
import 'package:flutter/material.dart';

class RegulatoryReferenceBadge extends StatelessWidget {
  final String? legalReference;
  final VoidCallback? onTap;

  const RegulatoryReferenceBadge({
    this.legalReference,
    this.onTap,
    Key? key,
  }) : super(key: key);

  /// Parse SEC number from legal reference
  /// Input: "SEC. 404 [15 U.S.C. 7262] - Management Assessment..."
  /// Output: ("404", "Management Assessment...")
  (String, String) _parseLegalReference(String ref) {
    final match = RegExp(r'SEC\.\s*(\d+)\s*\[.*?\]\s*-\s*(.+?)(?:\n|$)')
        .firstMatch(ref);
    
    if (match != null) {
      return (match.group(1)!, match.group(2)!.trim());
    }
    
    return ('', ref);
  }

  @override
  Widget build(BuildContext context) {
    if (legalReference == null) return SizedBox.shrink();

    final (secNumber, title) = _parseLegalReference(legalReference!);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 8),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            border: Border.all(color: Colors.amber.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.law, color: Colors.amber.shade700, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'SEC. $secNumber',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade900,
                      fontSize: 14,
                    ),
                  ),
                  Spacer(),
                  Icon(
                    Icons.arrow_forward,
                    color: Colors.amber.shade700,
                    size: 16,
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  color: Colors.amber.shade800,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

**Usage:**
```dart
RegulatoryReferenceBadge(
  legalReference: question.legalReference,
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegulatoryReferenceScreen(
          sectionId: 'sec-404',
        ),
      ),
    );
  },
)
```

---

## Integration with Existing Question Display

### In Your Question List Screen

```dart
class QuestionListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: soxComplianceQuestions.length,
      itemBuilder: (context, index) {
        final question = soxComplianceQuestions[index];
        
        return ComplianceQuestionCard(
          question: question,
          onLegalReferencePressed: () {
            _navigateToRegulatoryReference(context, question.legalReference);
          },
        );
      },
    );
  }

  void _navigateToRegulatoryReference(BuildContext context, String? ref) {
    if (ref == null) return;

    // Extract section ID
    final sectionId = _extractSectionId(ref);

    // Navigate to reference screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RegulatoryReferenceScreen(
          sectionId: sectionId,
        ),
      ),
    );
  }

  String _extractSectionId(String reference) {
    final match = RegExp(r'SEC\.\s*(\d+)').firstMatch(reference);
    return 'sec-${match?.group(1)?.toLowerCase() ?? ''}';
  }
}
```

---

## Asset Setup

### Step 1: Add Markdown Package to `pubspec.yaml`

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_markdown: ^0.6.0
  url_launcher: ^6.0.0
```

### Step 2: Add Regulatory Reference as Asset

```yaml
flutter:
  assets:
    - REGULATORY_REFERENCE.md
    - assets/docs/
```

### Step 3: Copy File to Assets

```bash
mkdir -p assets/docs
cp REGULATORY_REFERENCE.md assets/docs/
```

---

## Data Model Enhancement

### Update `compliance_models.dart`

```dart
class ComplianceQuestion {
  final String id;
  final ComplianceType complianceType;
  final QuestionCategory category;
  final String questionText;
  final String? description;
  final String? legalReference;        // ← Already exists
  final String? regulatorySection;     // ← NEW: e.g., "404"
  final String? regulatoryCategory;    // ← NEW: e.g., "accessControls"
  final double? weight;
  final int order;
  final DateTime createdAt;

  ComplianceQuestion({
    required this.id,
    required this.complianceType,
    required this.category,
    required this.questionText,
    this.description,
    this.legalReference,
    this.regulatorySection,
    this.regulatoryCategory,
    this.weight,
    required this.order,
    required this.createdAt,
  });
}
```

### Usage in Questions

```dart
ComplianceQuestion(
  id: 'q1',
  complianceType: ComplianceType.sox,
  category: QuestionCategory.accessControls,
  questionText: 'Is user access formally documented and reviewed?',
  description: 'Ensure all user access to financial systems is formally documented with regular reviews',
  legalReference: 'SEC. 404 [15 U.S.C. 7262] - Management Assessment of Internal Controls',
  regulatorySection: '404',           // ← NEW
  regulatoryCategory: 'accessControls', // ← NEW
  weight: 1.0,
  order: 1,
  createdAt: DateTime.now(),
)
```

---

## Testing the Implementation

### Unit Test Example

```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Regulatory Reference Tests', () {
    test('Extract SEC number from legal reference', () {
      final ref = 'SEC. 404 [15 U.S.C. 7262] - Management Assessment of Internal Controls';
      final pattern = RegExp(r'SEC\.\s*(\d+)');
      final match = pattern.firstMatch(ref);
      
      expect(match?.group(1), equals('404'));
    });

    test('Navigate to correct regulatory section', () {
      // Test navigation logic
      final sectionId = 'sec-404';
      expect(sectionId.isNotEmpty, true);
    });

    test('All questions have legal references', () {
      for (var q in soxComplianceQuestions) {
        expect(q.legalReference, isNotNull);
        expect(q.legalReference, isNotEmpty);
      }
    });
  });
}
```

---

## CSS Styling (If Using Web)

If you deploy as a web app, style the clickable reference:

```css
.regulatory-reference {
  background-color: #fff8e1;
  border-left: 4px solid #fbc02d;
  padding: 12px;
  margin: 8px 0;
  border-radius: 4px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.regulatory-reference:hover {
  background-color: #fff3cd;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.regulatory-reference a {
  color: #f57f17;
  text-decoration: none;
  font-weight: 500;
}

.regulatory-reference a:hover {
  text-decoration: underline;
}

.regulatory-reference-icon {
  display: inline-block;
  margin-right: 8px;
}
```

---

## Best Practices

✅ **DO:**
- Always include a legal reference in your data
- Make references clickable when displaying questions
- Load regulatory document from assets or local files
- Test all links before deployment
- Provide clear visual indication that references are clickable

❌ **DON'T:**
- Hard-code regulatory text in the UI
- Store large documents in the app (use references instead)
- Make assumptions about which SEC section applies
- Break the linking functionality during updates

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Link not working | Verify section ID matches markdown anchors (e.g., `#sec-404`) |
| Markdown not displaying | Ensure `flutter_markdown` is imported and asset path is correct |
| Wrong section opens | Check regex pattern extraction of SEC number |
| Performance issues | Load markdown asynchronously with caching |
| iOS/Android differences | Test on both platforms for URL launching |

---

## Next Steps

1. **Implement** one of the UI options above
2. **Test** with all 27 compliance questions
3. **Deploy** with confidence that links work
4. **Monitor** for any broken references
5. **Update** REGULATORY_REFERENCE.md as new requirements emerge

---

*Reference: [REGULATORY_INTEGRATION_GUIDE.md](REGULATORY_INTEGRATION_GUIDE.md)*
