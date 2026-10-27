/// Data model for a "how might you build this process" implementation guide.
/// These are illustrative, non-authoritative walkthroughs that help a
/// customer imagine the operational steps behind a compliance control.
library;

class ProcessGuideStep {
  final int number;
  final String title;
  final String description;

  const ProcessGuideStep({
    required this.number,
    required this.title,
    required this.description,
  });
}

class ProcessGuide {
  /// Matches the `ComplianceQuestion.id` this guide supports (e.g. 'q10').
  final String id;
  final String title;
  final String disclaimer;
  final List<ProcessGuideStep> steps;

  const ProcessGuide({
    required this.id,
    required this.title,
    required this.disclaimer,
    required this.steps,
  });
}
