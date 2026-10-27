/// Central library of illustrative process/implementation guides.
///
/// Keyed by the `ComplianceQuestion.id` they support (e.g. 'q10'). Add new
/// guides here as they are written so they are automatically organised in
/// one place and available to any screen that wants to surface a
/// "View Process Guide" link for a given question.
library;

import '../models/process_guide.dart';

final Map<String, ProcessGuide> processGuides = {
  'q10': ProcessGuide(
    id: 'q10',
    title: 'Whistleblower Protection Process',
    disclaimer:
        'There is no finite or correct way this process is to be completed. '
        'The following is to help imagine what actions would need to be '
        'taken to build a process for whistleblower protection.',
    steps: [
      ProcessGuideStep(
        number: 1,
        title: 'Designate Independent Intake Channels',
        description:
            'Establish multiple ways for staff to report concerns so they '
            'do not have to go through direct managers. Provide a dedicated '
            'confidential email inbox (e.g., compliance@company.com), a '
            'physical lockbox, or an anonymous web portal/hotline managed '
            'by a third party.',
      ),
      ProcessGuideStep(
        number: 2,
        title: 'Draft & Publish the Policy',
        description:
            'Write a concise, transparent policy document. Outline exactly '
            'what happens after a report is submitted, expected timeframes '
            'for acknowledgment, and how investigations are handled. Keep '
            'it accessible in your staff handbook or company intranet.',
      ),
      ProcessGuideStep(
        number: 3,
        title: 'Appoint a Whistleblower Officer / Committee',
        description:
            'Designate an impartial individual or small internal team '
            '(e.g., Compliance Lead, HR Manager, or Legal Counsel) '
            'responsible for receiving, triaging, and managing disclosures '
            'to avoid conflicts of interest.',
      ),
      ProcessGuideStep(
        number: 4,
        title: 'Train Managers & Educate Staff',
        description:
            'Train team leads and managers on how to recognize disclosures, '
            'maintain confidentiality, and prevent subtle retaliation. '
            'Conduct brief onboarding for all staff so they know their '
            'rights and how to use the reporting channels.',
      ),
      ProcessGuideStep(
        number: 5,
        title: 'Establish an Investigation & Resolution Protocol',
        description:
            'Define clear rules for evaluating reports: record intake, '
            'assess severity, conduct impartial investigations, take '
            'corrective action when necessary, and provide appropriate '
            'updates to the whistleblower without violating privacy rules.',
      ),
    ],
  ),
  'q13': ProcessGuide(
    id: 'q13',
    title: 'Internal Control Structure for Financial Reporting',
    disclaimer:
        'There is no finite or correct way this process is to be completed. '
        'The following is to help imagine what actions would need to be '
        'taken to build a process for internal control structure.',
    steps: [
      // Phase 1: Scoping & Top-Down Risk Assessment (TDRA)
      ProcessGuideStep(
        number: 1,
        title: 'Map Financial Statements',
        description:
            'Identify material financial accounts, financial disclosures, and line items '
            'based on quantitative thresholds and qualitative risk factors. Document all '
            'accounts that could be materially misstated and impact the financial statements.',
      ),
      ProcessGuideStep(
        number: 2,
        title: 'Identify Significant Processes',
        description:
            'Map material accounts to key business cycles such as Revenue/Order-to-Cash, '
            'Procurement/Procure-to-Pay, Payroll, and Financial Close & Reporting. '
            'Determine which processes have the greatest impact on material accounts.',
      ),
      ProcessGuideStep(
        number: 3,
        title: 'Define Key Assertions',
        description:
            'Pinpoint relevant financial assertions for each process: Completeness, Accuracy, '
            'Valuation, Existence/Occurrence, Rights & Obligations, and Presentation. '
            'These assertions form the basis for control design.',
      ),
      ProcessGuideStep(
        number: 4,
        title: 'Scope IT Systems (ITGC Scope)',
        description:
            'Identify all ERPs, sub-ledgers, databases, and third-party SaaS tools that '
            'generate, process, or store financial data. Document the flow of data through '
            'these systems to understand the IT control environment.',
      ),
      // Phase 2: Process Mapping & Control Design
      ProcessGuideStep(
        number: 5,
        title: 'Draft Process Flowcharts & Narratives',
        description:
            'Detail end-to-end transaction flows from origin to entry in the general ledger. '
            'Create visual flowcharts and accompanying narratives that document how each '
            'business process operates.',
      ),
      ProcessGuideStep(
        number: 6,
        title: 'Build a Risk & Control Matrix (RCM)',
        description:
            'Create a central repository mapping "What Could Go Wrong" (WCGW) risks to specific '
            'key controls. This matrix serves as the foundation for your control environment.',
      ),
      ProcessGuideStep(
        number: 7,
        title: 'Define Control Types',
        description:
            'Categorize controls as Preventive vs. Detective and Manual vs. Automated/Application-based. '
            'Ensure a balanced mix of control types covers all significant risks.',
      ),
      ProcessGuideStep(
        number: 8,
        title: 'Establish IT General Controls (ITGCs)',
        description:
            'Design controls around User Access (RBAC, provisioning, termination), Change Management '
            '(code deployments, approvals), and Computer Operations (backups, batch jobs). '
            'ITGCs provide the foundation for application controls.',
      ),
      ProcessGuideStep(
        number: 9,
        title: 'Enforce Segregation of Duties (SoD)',
        description:
            'Identify conflict matrices to ensure no single individual can initiate, approve, and '
            'execute critical financial transactions. Document SoD requirements for all significant processes.',
      ),
      // Phase 3: Operational Implementation & Walkthroughs
      ProcessGuideStep(
        number: 10,
        title: 'Assign Control Owners',
        description:
            'Explicitly designate individual owners for every control in the RCM. Define the required '
            'evidence of performance and communication channels for each control owner.',
      ),
      ProcessGuideStep(
        number: 11,
        title: 'Standardize Evidence Capture',
        description:
            'Create standardized templates for reviews, reconciliations, and approvals so that audit '
            'trails are repeatable and re-performable. Ensure all control evidence is documented consistently.',
      ),
      ProcessGuideStep(
        number: 12,
        title: 'Conduct Process Walkthroughs',
        description:
            'Perform dry runs with process owners, internal auditors, and external auditors to confirm '
            'the control design operates as documented. Address any gaps or misalignments identified.',
      ),
      // Phase 4: Testing, Deficiencies & Remediation
      ProcessGuideStep(
        number: 13,
        title: 'Execute Test Plans',
        description:
            'Perform interim operating effectiveness testing on selected sample sizes (e.g., daily, '
            'monthly, quarterly controls). Document test methodology, results, and any exceptions.',
      ),
      ProcessGuideStep(
        number: 14,
        title: 'Evaluate Key Reports (IPE)',
        description:
            'Test Information Produced by Entity (IPE) to verify the source data, logic, and parameters '
            'of custom reports supporting SOX controls are accurate and complete.',
      ),
      ProcessGuideStep(
        number: 15,
        title: 'Classify Deficiencies',
        description:
            'Evaluate identified control failures into three categories: Control Deficiency (minor '
            'operational flaw), Significant Deficiency (warrants attention by those charged with governance), '
            'and Material Weakness (reasonable possibility that a material misstatement will not be prevented or detected).',
      ),
      ProcessGuideStep(
        number: 16,
        title: 'Remediate & Re-test',
        description:
            'Implement corrective actions for failed controls and allow a sufficient re-testing window '
            'prior to fiscal year-end. Document remediation evidence and re-test results.',
      ),
      // Phase 5: Year-End Evaluation & Reporting
      ProcessGuideStep(
        number: 17,
        title: 'Perform Roll-Forward Testing',
        description:
            're-verify that key controls remained effective through the final quarter of the fiscal year. '
            'This ensures continuous control effectiveness through year-end.',
      ),
      ProcessGuideStep(
        number: 18,
        title: 'Draft Management\'s Section 404(a) Report',
        description:
            'Prepare the internal control report to be included in the annual Form 10-K filing. This report '
            'must contain management\'s assessment of the effectiveness of internal controls over financial reporting.',
      ),
      ProcessGuideStep(
        number: 19,
        title: 'Coordinate Auditor Attestation (404b filers)',
        description:
            'Align with external auditors to review findings and issue their formal opinion on internal control '
            'over financial reporting (ICFR) effectiveness for 404(b) filers (large accelerated filers).',
      ),
    ],
  ),
};
