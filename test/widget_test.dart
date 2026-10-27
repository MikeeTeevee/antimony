// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accedr/main.dart';
import 'package:accedr/data/regulatory_text.dart';
import 'package:accedr/data/sox_questions.dart';

void main() {
  testWidgets('Landing screen displays Antimony branding', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Antimony'), findsOneWidget);
    expect(find.text('Compliance Tools'), findsOneWidget);
    final logo = tester.widget<Image>(
      find.image(const AssetImage('assets/antimony_logo.png')),
    );
    expect(logo.width, 72);
    expect(logo.height, 72);
    expect(logo.filterQuality, FilterQuality.high);
  });

  test('Question 15 keeps Rule 13a-15(e) in linked regulatory text', () {
    final question = soxComplianceQuestions.singleWhere(
      (question) => question.id == 'q15',
    );
    final regulatoryText = getRegulatoryText(question.legalReference);

    expect(question.description, isNot(contains('SEC Rule 13a-15(e)')));
    expect(
      regulatoryText,
      contains(
        '[SEC Rule 13a-15(e) - Definition of Disclosure Controls and Procedures]'
        '(https://www.law.cornell.edu/cfr/text/17/240.13a-15)',
      ),
    );
    expect(
      regulatoryText,
      contains(
        'as appropriate to allow timely decisions regarding required disclosure.',
      ),
    );
  });
}
