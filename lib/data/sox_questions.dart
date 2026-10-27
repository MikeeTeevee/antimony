/// SOX Compliance Questions Database
/// 38 comprehensive SOX compliance assessment questions
/// Organized across 7 regulatory compliance areas
library;

import 'package:accedr/models/compliance_models.dart';

final List<ComplianceQuestion> soxComplianceQuestions = [
  // ========== 1. GOVERNANCE & OWNERSHIP (6 Questions) ==========

  // Q1 - SEC. 302
  ComplianceQuestion(
    id: 'q1',
    complianceType: ComplianceType.sox,
    category: QuestionCategory.documentation,
    questionText:
        'Have the principal officers explicitly accepted responsibility for establishing and maintaining internal controls?',
    description:
        'Principal officers (CEO, CFO, Controller) must formally acknowledge in writing their responsibility for establishing, maintaining, and assessing the effectiveness of internal controls over financial reporting. This should be documented through board minutes, policy statements, and signed acknowledgments. Officers must understand they are accountable for control design and operation.\n\nYour business should find a way to review this statement annually to keep it up to date and ensure it is being regularly refreshed when stakeholders either leave or join the business. You can make this an automated process with your compliance team, or embed it into your HR onboarding methods for board members.',
    legalReference:
        'SEC. 302 [15 U.S.C. 7241] - Corporate Responsibility for Financial Reports',
    weight: 1.0,
    order: 1,
    createdAt: DateTime.now(),
    categoryName: 'Governance & Ownership',
    criticality: 'High',
    answered: false,
    response: null,
  ),

  // Q2 - SEC. 302
  ComplianceQuestion(
    id: 'q2',
    complianceType: ComplianceType.sox,
    category: QuestionCategory.documentation,
    questionText:
        'Can the signing officers confirm they have reviewed the annual or quarterly reports prior to filing?',
    description:
        'Signing officers must certify they have personally reviewed the financial reports before submission. Document the review process including what was reviewed, by whom, when, and their sign-off. Officers must attest they have reviewed management discussion & analysis, financial statements, and disclosures.\n\nSpecifically, the statutory language requires the signatures of:\n\n- The **Principal Executive Officer** (typically the **CEO**)\n- The **Principal Financial Officer** (typically the **CFO**)\n\n[SEC Reference: Certification of Disclosure in Companies\' Quarterly and Annual Reports](https://www.sec.gov/rules-regulations/2002/08/certification-disclosure-companies-quarterly-annual-reports#:~:text=25%20Section%20302%20of%20the,financial%20officer%20or%20officers%2C%20or)',
    legalReference:
        'SEC. 302 [15 U.S.C. 7241] - Corporate Responsibility for Financial Reports',
    weight: 1.0,
    order: 2,
    createdAt: DateTime.now(),
    categoryName: 'Governance & Ownership',
    criticality: 'High',
    answered: false,
    response: null,
  ),

  // Q3 - SEC. 301
  ComplianceQuestion(
    id: 'q3',
    complianceType: ComplianceType.sox,
    category: QuestionCategory.documentation,
    questionText:
        'Is the audit committee composed entirely of independent members of the board of directors?',
    description:
        'All audit committee members must be independent, meaning they have no material relationships with the company beyond their board duties. Maintain documentation of audit committee composition, independence certifications, and any related-party transactions that might affect independence. Document board-approved audit committee charter.\n\nThe operational work your business needs to do involves **proving that this structure exists and functions**.\n\nYour team (not the board) will be the ones doing the work to:\n\n- Document the board\'s charters and committee structures.\n- Gather signed independence statements from the directors annually.\n- Set up, test, and maintain the whistleblower hotline/mechanism.\n- Organize and archive the minutes of the audit committee meetings to prove they are actively overseeing the external auditors.\n\nThe directors attend, ask challenging questions, review the evidence your team provides, and sign off on the final decisions. You should work with your auditors to establish and understand role objectives in your business.\n\nWhen people talk about the audit committee, they often lump this question — Section 301 (which mandates that everyone must be independent) and [Section 407](q31) (which mandates the financial expert disclosure) — into the same bucket because they both dictate who sits on that committee.',
    legalReference:
        'SEC. 301 [15 U.S.C. 78j(m)] - Audit Committee Requirements',
    weight: 1.0,
    order: 3,
    createdAt: DateTime.now(),
    categoryName: 'Governance & Ownership',
    criticality: 'High',
    answered: false,
    response: null,
  ),

  // Q4 - SEC. 406
  ComplianceQuestion(
    id: 'q4',
    complianceType: ComplianceType.sox,
    category: QuestionCategory.documentation,
    questionText:
        'Has the company adopted a code of ethics for senior financial officers?',
    description:
        'Senior financial officers (CFO, Controller, Chief Accounting Officer, and finance leaders) must be covered by a formal code of ethics addressing conflicts of interest, confidentiality, and regulatory compliance. Publish the code, confirm all senior financial officers acknowledge it, and maintain records of violations and remediation.\n\nThis part is very transparent about what must happen. Here is a real world example of what that looks like.\n\n[ex: Cornell Law School public published Code of ethics](https://www.law.cornell.edu/cfr/text/17/229.406)',
    legalReference:
        'SEC. 406 [15 U.S.C. 7264] - Code of Ethics for Senior Financial Officers',
    weight: 1.0,
    order: 4,
    createdAt: DateTime.now(),
    categoryName: 'Governance & Ownership',
    criticality: 'Medium',
    answered: false,
    response: null,
  ),

  // Q5 - SEC. 906
  ComplianceQuestion(
    id: 'q5',
    complianceType: ComplianceType.sox,
    category: QuestionCategory.documentation,
    questionText:
        'Do the CEO and CFO provide a written statement certifying the report fairly presents the financial condition?',
    description:
        'CEO and CFO must provide signed written certifications with each quarterly and annual filing attesting the report fairly presents financial condition in all material respects. Maintain records of all certifications, who signed and when, and the certification process used to ensure accuracy.\n\nIt is incredibly important to note the punishments for this detailed in the regulatory text - you should read the examples of [Arthur Andersen 2002 case](https://www.latimes.com/archives/la-xpm-2001-jun-20-fi-12500-story.html) where they were fined 7 million after failing to declare waste management, and as an extension of this [Zornoza v. Terraform Global Inc. whistleblower case](https://masslawyersweekly.com/files/2025/04/Domenech-complaint.pdf) where a whistleblower recieved 34.5 million in a retalation case. These are examples of where companies can be punished and punished again in their approach to whistleblowing, which we\'ll cover further in [Question 10](q10).\n\nDon\'t glaze over this question - a \'yes\' answer needs to come with evidence of entirely how these processes are being managed.',
    legalReference:
        'SEC. 906 [18 U.S.C. 1350] - Criminal Penalties for Certification',
    weight: 1.0,
    order: 5,
    createdAt: DateTime.now(),
    categoryName: 'Governance & Ownership',
    criticality: 'High',
    answered: false,
    response: null,
  ),

  // Q6 - SEC. 1105
  ComplianceQuestion(
    id: 'q6',
    complianceType: ComplianceType.sox,
    category: QuestionCategory.documentation,
    questionText:
        'Has the company verified that no current officer or director is subject to an SEC bar?',
    description:
        'Verify that no officer or director has been subject to SEC (U.S. Securities and Exchange Commission) enforcement action prohibiting them from serving. Maintain documentation of verification performed, including SEC database searches and officer confirmations. Update verification annually or when new officers/directors are appointed.\n\nAfter the creation of SOX, the SEC leverage the ability to bar corporate executives or director from serving in a leadership role at a public company if they\'ve violated section 10(b) of the Securitiies Exchange Act of 1934 and if the SEC bars you, you are legally forbidden from being a director or executive at any company that is registered under Section 12.\n\nNaturally, you\'re being asked to track and show your efforts to investigate and ensure no one who is barred is operating within your business as an office or director.',
    legalReference: 'SEC. 1105 - SEC Authority to Ban Officer/Directors',
    weight: 1.0,
    order: 6,
    createdAt: DateTime.now(),
    categoryName: 'Governance & Ownership',
    criticality: 'High',
    answered: false,
    response: null,
  ),

  // ========== 2. RISK & FRAUD AWARENESS (6 Questions) ==========

  // Q7 - SEC. 404
  ComplianceQuestion(
    id: 'q7',
    complianceType: ComplianceType.sox,
    category: QuestionCategory.documentation,
    questionText:
        'Does management perform an annual assessment of the effectiveness of the internal control structure?',
    description:
        'Management must assess internal control effectiveness at least annually. Document assessment methodology, scope, controls evaluated, testing performed, deficiencies identified, and conclusions. Assessment should cover all significant account balances and transaction flows affecting financial reporting.\n\nThe expectation is that a [SOX 404 Top-Down Risk Assessment](https://en.wikipedia.org/wiki/SOX_404_top%E2%80%93down_risk_assessment) would be conducted.\n\nA Top-Down Risk Assessment (TDRA) is not just a best practice; it is the definitive, explicit regulatory expectation for SOX 404 compliance. This expectation is codified by both governing bodies that regulate SOX:\n\n**For Management (SOX 404a):** The SEC\'s 2007 Interpretive Guidance (Release No. 33-8810) explicitly directs management to use a top-down, risk-based approach to structure their evaluation. [SEC Guidance on top-down risk-based evaluation of ICFR](https://www.bakertilly.com/insights/improve-sox-404-compliance-strategies#:~:text=The%20SEC%20provides%20guidance%20on,risk%2Dbased%20evaluation%20of%20ICFR)\n\n**For External Auditors (SOX 404b):** The PCAOB\'s Auditing Standard 2201 (AS 2201) explicitly mandates that auditors must use a top-down approach to audit Internal Control over Financial Reporting (ICFR). [PCAOB AS 2201 top-down, risk-based methodology](https://www.finrep.ai/blog/sox-section-404-compliance-guide-the-practitioners-playbook#:~:text=The%20original%20PCAOB%20Auditing%20Standard,down%2C%20risk%2Dbased%20methodology)\n\nThe regulations mandate this specifically to prevent companies from wasting millions of dollars treating SOX like an exhausting "checkbox" exercise where every single control in the building gets documented and tested.\n\nIf this is a no on your list, you\'ll want to consider that you\'ll need to start in this arena and get compliance guidance. Expect to:\n\n1. Create and maintain an internal Risk Control Matrix (RCM) alongside the latest Top-Down Risk Assessment (TDRA). Ensure every key control actively maps to a high-risk financial assertion — if it doesn\'t, scope it out immediately to save time.\n\n2. Identify all Information Produced by Entity (IPE) and third-party SaaS platforms supporting those controls. You must request SOC 1 Type II reports now and document the corresponding User Entity Controls (UECs) before year-end.\n\n3. Prioritize Management Review Controls (MRCs). Guide the team to document the explicit precision of their reviews — defining exact variance thresholds and investigation steps — rather than relying on passive approvals.\n\nThis arena isn\'t exhaustive in a single one-shot message. Start to explore the questions outlined to get you a head start and have a compliance team review the process to make sure it is efficient.',
    legalReference:
        'SEC. 404 [15 U.S.C. 7262] - Management Assessment of Internal Controls',
    weight: 1.0,
    order: 7,
    createdAt: DateTime.now(),
    categoryName: 'Risk & Fraud Awareness',
    criticality: 'High',
    answered: false,
    response: null,
  ),

  // Q8 - SEC. 302
  ComplianceQuestion(
    id: 'q8',
    complianceType: ComplianceType.sox,
    category: QuestionCategory.documentation,
    questionText:
        'Have officers disclosed to auditors any fraud involving management or employees with roles in internal controls?',
    description:
        'Officers must communicate to auditors any fraud, whether material or immaterial, involving management or employees responsible for controls. Maintain documentation of fraud investigations, communications to auditors, and remediation actions.\n\n**What does that mean for you?**\n\nThis zero-tolerance disclosure rule does not apply to every single employee in the company. It specifically targets:\n\n- **Management:** Anyone in a leadership or supervisory role.\n- **Key Control Personnel:** Any employee, regardless of their rank, who has a significant role in the company\'s **internal controls over financial reporting (ICFR)** (e.g., IT administrators with access to financial systems, internal auditors, or accounting staff). [A2Q2: SOX 302 Certifications – Who Must Disclose Fraud](https://a2q2.com/blog/sox-302-certifications-disclosure-committee/#:~:text=any%20fraud%2C%20whether%20or%20not,the%20issuer\'s%20internal%20controls%3B%20and)\n\n*Contextual example*\n\nIf a regular cashier at a retail store steals \$20 from the register, that is a local HR issue (and is immaterial). But if the *Accounting Manager* alters an invoice by \$20 to cover up a mistake, that is a SOX 302 disclosure event that **must** be reported directly to the external auditors and the Board of Directors.',
    legalReference:
        'SEC. 302 [15 U.S.C. 7241] - Corporate Responsibility for Financial Reports',
    weight: 1.0,
    order: 8,
    createdAt: DateTime.now(),
    categoryName: 'Risk & Fraud Awareness',
    criticality: 'High',
    answered: false,
    response: null,
  ),

  // Q9 - SEC. 303
  ComplianceQuestion(
    id: 'q9',
    complianceType: ComplianceType.sox,
    category: QuestionCategory.documentation,
    questionText:
        'Is there a policy prohibiting the fraudulent influence or misleading of independent accountants?',
    description:
        'Establish written policy prohibiting any action to fraudulently influence, coerce, or mislead auditors in the performance of audits. Include specific examples and consequences for violations. Ensure all employees understand this policy and know how to report concerns.\n\nThe compliance question is really asking: does your organization have an explicit written policy telling employees they must never pressure, threaten, or deceive the external/independent auditors during an audit, since doing so is a federal violation.\n\nYou should create the policy, cascade the information appropriately, know where the policy is embedded in your business practices and check it is being maintained.',
    legalReference:
        'SEC. 303 [15 U.S.C. 7242] - Improper Influence on Conduct of Audits',
    weight: 1.0,
    order: 9,
    createdAt: DateTime.now(),
    categoryName: 'Risk & Fraud Awareness',
    criticality: 'Medium',
    answered: false,
    response: null,
  ),

  // Q10 - SEC. 806
  ComplianceQuestion(
    id: 'q10',
    complianceType: ComplianceType.sox,
    category: QuestionCategory.documentation,
    questionText:
        'Are whistleblower protections in place to prevent discrimination against employees reporting fraud?',
    description:
        'Establish and publicize whistleblower protection policy prohibiting discharge, demotion, suspension, harassment, or retaliation against employees who report suspected fraud. Implement confidential and anonymous reporting mechanisms. Maintain records of all reports and ensure no retaliation occurs.\n\nFollowing the [Dodd-Frank Act](https://en.wikipedia.org/wiki/Dodd%E2%80%93Frank_Act), [the National Defense Authorization Act (NDAA) for Fiscal Year 2022](https://www.congress.gov/bill/117th-congress/house-bill/4350/text) further amended SOX Section 806 by extending the window for employees to file an initial retaliation complaint with OSHA from 180 days to 180 days after the date on which the violation occurs. There is [civil action](https://www.whistleblowers.gov/statutes/sox_amended) that can be taken to protect against retaliation.\n\nThere is a typified example of what such an action would look like, below.',
    legalReference:
        'SEC. 806 [18 U.S.C. 1513] - Whistleblower Protection Against Retaliation',
    weight: 1.0,
    order: 10,
    createdAt: DateTime.now(),
    categoryName: 'Risk & Fraud Awareness',
    criticality: 'High',
    answered: false,
    response: null,
  ),

  // Q11 - SEC. 1107
  ComplianceQuestion(
    id: 'q11',
    complianceType: ComplianceType.sox,
    category: QuestionCategory.documentation,
    questionText:
        'Is the organization aware of the criminal penalties for retaliating against informants?',
    description:
        'Ensure senior management and board understand that retaliation against informants is a federal crime with penalties including fines and imprisonment. Include this in training and ethical conduct communications to reinforce the seriousness of whistleblower protection requirements.',
    legalReference:
        'SEC. 1107 [18 U.S.C. 1512] - Criminal Penalties for Retaliation',
    weight: 1.0,
    order: 11,
    createdAt: DateTime.now(),
    categoryName: 'Risk & Fraud Awareness',
    criticality: 'Medium',
    answered: false,
    response: null,
  ),

  // Q12 - SEC. 807
  ComplianceQuestion(
    id: 'q12',
    complianceType: ComplianceType.sox,
    category: QuestionCategory.documentation,
    questionText:
        'Is the company aware that executing a scheme to defraud shareholders is a specific criminal offense?',
    description:
        'Ensure management and board understand that schemes to defraud shareholders in connection with securities are federal crimes with penalties up to 25 years imprisonment. Include this understanding in fraud prevention and ethical conduct training.',
    legalReference:
        'SEC. 807 [18 U.S.C. 1348] - Criminal Penalties for Securities Fraud',
    weight: 1.0,
    order: 12,
    createdAt: DateTime.now(),
    categoryName: 'Risk & Fraud Awareness',
    criticality: 'Medium',
    answered: false,
    response: null,
  ),

  // ========== 3. CONTROL ACTIVITIES (6 Questions) ==========

  // Q13 - SEC. 404
  ComplianceQuestion(
    id: 'q13',
    complianceType: ComplianceType.sox,
    category: QuestionCategory.documentation,
    questionText:
        'Has management established an adequate internal control structure for financial reporting?',
    description:
        'Management must establish adequate controls over financial reporting including process controls (authorization, segregation of duties, reconciliations) and IT controls (access, change management, monitoring). Document control structure through policies, procedures, and control descriptions.',
    legalReference:
        'SEC. 404 [15 U.S.C. 7262] - Management Assessment of Internal Controls',
    weight: 1.0,
    order: 13,
    createdAt: DateTime.now(),
    categoryName: 'Control Activities',
    criticality: 'High',
    answered: false,
    response: null,
  ),

  // Q14 - SEC. 402
  ComplianceQuestion(
    id: 'q14',
    complianceType: ComplianceType.sox,
    category: QuestionCategory.documentation,
    questionText:
        'Does the company prohibit extending personal loans to directors or executive officers?',
    description:
        '**1. Policy & Governance**\n\n'
        '- Adopt a formal **Insider Lending Policy** (or integrate it into the Code of Business Conduct & Ethics) explicitly banning personal loans, loan guarantees, or indirect credit arrangements for [Section 16 officers](https://www.goodwinlaw.com/en/resource/off-the-shelf/section-16) and board members.\n'
        '- Define strict boundaries for routine business advances: clarify that standard travel/expense advances must be substantiated and reconciled within the standard billing cycle (typically 30–60 days) to prevent them from being deemed constructive loans.\n\n'
        '**2. Preventative Controls (Disbursements & Payroll)**\n\n'
        '- **Treasury & AP Screening:** Flag any off-cycle, non-standard wire transfers or disbursements payable to directors or officers for legal/CFO review before release.\n'
        '- **Equity Compensation Guardrails:** Configure equity administration systems to prohibit company-funded loans for option exercises (ensure cashless exercise programs rely on independent broker-assisted models without company financing or repayment guarantees).\n\n'
        '**3. Detective Controls & Audit Evidence**\n\n'
        '- **Quarterly Related-Party Review:** Corporate accounting reconciles notes receivable and employee receivable ledger accounts each quarter to confirm zero balances for covered executives.\n'
        '- **Annual D&O Questionnaires:** Require all directors and named executive officers to disclose and certify any direct or indirect personal financial arrangements with the issuer or its affiliates.',
    legalReference:
        'SEC. 402 [15 U.S.C. 78m] - Personal Loans to Officers/Directors Prohibited',
    weight: 1.0,
    order: 14,
    createdAt: DateTime.now(),
    categoryName: 'Control Activities',
    criticality: 'High',
    answered: false,
    response: null,
  ),

  // Q15 - SEC. 302
  ComplianceQuestion(
    id: 'q15',
    complianceType: ComplianceType.sox,
    category: QuestionCategory.documentation,
    questionText:
        'Are controls designed to ensure material information is made known to signing officers?',
    description:
        '**1. Governance & Committee Architecture**\n\n'
        '- **Charter a Disclosure Committee:** Establish a committee composed of key stakeholders (Controller, General Counsel, Head of Investor Relations, Head of Internal Audit, and key operational leads) reporting directly to the CEO and CFO.\n'
        '- **Pre-Filing Review Meetings:** Require the Disclosure Committee to convene before every 10-Q and 10-K filing to review draft disclosures, accounting estimates, litigation reserves, and unrecorded adjustments.\n\n'
        '**2. Escalation & Sub-Certification Workflow**\n\n'
        '- **Cascading Sub-Certifications:** Implement a formal quarterly sign-off process where divisional leaders, plant managers, and regional controllers certify that all material transactions, contracts, and contingencies within their scope have been reported.\n'
        '- **Defined Materiality Thresholds:** Define clear quantitative (e.g., balance sheet percentage variance) and qualitative (e.g., regulatory inquiries, whistleblower reports, major vendor disputes) criteria that mandate immediate escalation to the General Counsel and CFO outside the standard reporting cycle.\n\n'
        '**3. Evidentiary Audit Trail**\n\n'
        '- **Meeting Documentation:** Retain agendas, attendee sign-in logs, and detailed minutes of Disclosure Committee deliberations as primary audit evidence for external auditors.\n'
        '- **Sign-off Repository:** Maintain an auditable repository of executed sub-certification forms, including documented exceptions, follow-up actions, and resolution notes.',
    legalReference:
        'SEC. 302 [15 U.S.C. 7241] - Corporate Responsibility for Financial Reports',
    weight: 1.0,
    order: 15,
    createdAt: DateTime.now(),
    categoryName: 'Control Activities',
    criticality: 'High',
    answered: false,
    response: null,
  ),

  // Q16 - SEC. 401
  ComplianceQuestion(
    id: 'q16',
    complianceType: ComplianceType.sox,
    category: QuestionCategory.documentation,
    questionText:
        'Do financial reports disclose all material off-balance sheet transactions?',
    description:
        'Implement controls ensuring all off-balance sheet transactions, arrangements, and relationships with unconsolidated entities are identified, analyzed, and disclosed. Document the review process and disclosure rationale for each significant off-balance sheet item.',
    legalReference: 'SEC. 401 [15 U.S.C. 78m] - Periodic Report Disclosures',
    weight: 1.0,
    order: 16,
    createdAt: DateTime.now(),
    categoryName: 'Control Activities',
    criticality: 'High',
    answered: false,
    response: null,
  ),

  // Q17 - SEC. 306
  ComplianceQuestion(
    id: 'q17',
    complianceType: ComplianceType.sox,
    category: QuestionCategory.documentation,
    questionText:
        'Are executives prohibited from trading during pension fund blackout periods?',
    description:
        'Establish and enforce policy prohibiting directors and officers from purchasing, selling, or transferring equity securities during blackout periods (periods when employee pension fund transaction capability is suspended). Document policy, blackout periods in effect, and monitoring for violations.',
    legalReference:
        'SEC. 306 [15 U.S.C. 7244] - Insider Trades During Pension Blackout Periods',
    weight: 1.0,
    order: 17,
    createdAt: DateTime.now(),
    categoryName: 'Control Activities',
    criticality: 'Medium',
    answered: false,
    response: null,
  ),

  // Q18 - SEC. 201
  ComplianceQuestion(
    id: 'q18',
    complianceType: ComplianceType.sox,
    category: QuestionCategory.documentation,
    questionText:
        'Are controls in place to prevent the external auditor from performing prohibited non-audit services?',
    description:
        'Implement controls and audit committee procedures to ensure external auditors do not perform prohibited services including bookkeeping, financial system design/implementation, appraisals, internal audit, or other independence-impairing services. Document audit committee approval process for any permitted non-audit services.',
    legalReference:
        'SEC. 201 [15 U.S.C. 7211] - Services Outside Scope of Auditors',
    weight: 1.0,
    order: 18,
    createdAt: DateTime.now(),
    categoryName: 'Control Activities',
    criticality: 'High',
    answered: false,
    response: null,
  ),

  // ========== 4. MONITORING & TESTING (6 Questions) ==========

  // Q19 - SEC. 302
  ComplianceQuestion(
    id: 'q19',
    complianceType: ComplianceType.sox,
    category: QuestionCategory.testing,
    questionText:
        'Have officers evaluated the effectiveness of internal controls within 90 days prior to the report?',
    description:
        'Signing officers must evaluate control effectiveness within 90 days before filing reports. Document evaluation methodology, controls tested, testing dates, evidence of effectiveness, and any deficiencies identified and remediated before certification.',
    legalReference:
        'SEC. 302 [15 U.S.C. 7241] - Corporate Responsibility for Financial Reports',
    weight: 1.0,
    order: 19,
    createdAt: DateTime.now(),
    categoryName: 'Monitoring & Testing',
    criticality: 'High',
    answered: false,
    response: null,
  ),

  // Q20 - SEC. 302
  ComplianceQuestion(
    id: 'q20',
    complianceType: ComplianceType.sox,
    category: QuestionCategory.testing,
    questionText:
        'Have officers disclosed all significant deficiencies and material weaknesses to the auditors?',
    description:
        'Officers must disclose to auditors all significant deficiencies and material weaknesses in control design or operation identified during their assessment. Maintain documentation of deficiencies, management evaluation of severity, and remediation actions taken.',
    legalReference:
        'SEC. 302 [15 U.S.C. 7241] - Corporate Responsibility for Financial Reports',
    weight: 1.0,
    order: 20,
    createdAt: DateTime.now(),
    categoryName: 'Monitoring & Testing',
    criticality: 'High',
    answered: false,
    response: null,
  ),

  // Q21 - SEC. 302
  ComplianceQuestion(
    id: 'q21',
    complianceType: ComplianceType.sox,
    category: QuestionCategory.testing,
    questionText:
        'Does the report indicate if there were significant changes in internal controls subsequent to the evaluation?',
    description:
        'Disclosure must include any significant changes to internal controls or other factors that could affect control effectiveness that occurred after the evaluation date. Document all changes made during the period and assess impact on control effectiveness.',
    legalReference:
        'SEC. 302 [15 U.S.C. 7241] - Corporate Responsibility for Financial Reports',
    weight: 1.0,
    order: 21,
    createdAt: DateTime.now(),
    categoryName: 'Monitoring & Testing',
    criticality: 'Medium',
    answered: false,
    response: null,
  ),

  // Q22 - SEC. 404
  ComplianceQuestion(
    id: 'q22',
    complianceType: ComplianceType.sox,
    category: QuestionCategory.testing,
    questionText:
        'Has the external auditor attested to management\'s assessment of internal controls?',
    description:
        'External auditors must provide an attestation report on management\'s internal control assessment. Obtain and review the auditor\'s attestation opinion, noting any adverse findings or limitations. Address any deficiencies identified by the auditor.',
    legalReference:
        'SEC. 404 [15 U.S.C. 7262] - Management Assessment of Internal Controls',
    weight: 1.0,
    order: 22,
    createdAt: DateTime.now(),
    categoryName: 'Monitoring & Testing',
    criticality: 'High',
    answered: false,
    response: null,
  ),

  // Q23 - SEC. 204
  ComplianceQuestion(
    id: 'q23',
    complianceType: ComplianceType.sox,
    category: QuestionCategory.testing,
    questionText:
        'Does the auditor report critical accounting policies and alternative treatments to the audit committee?',
    description:
        'Auditors must report to the audit committee all critical accounting policies and alternative treatment methods being considered. Review auditor reports confirming this requirement is being met and that audit committee has appropriate understanding of financial reporting alternatives.',
    legalReference:
        'SEC. 204 [15 U.S.C. 7214] - Auditor Reports to Audit Committees',
    weight: 1.0,
    order: 23,
    createdAt: DateTime.now(),
    categoryName: 'Monitoring & Testing',
    criticality: 'Medium',
    answered: false,
    response: null,
  ),

  // Q24 - SEC. 301
  ComplianceQuestion(
    id: 'q24',
    complianceType: ComplianceType.sox,
    category: QuestionCategory.testing,
    questionText:
        'Has the audit committee established procedures for the receipt and treatment of complaints?',
    description:
        'Audit committee must establish and publish procedures for receiving, retaining, and treating complaints regarding accounting, internal controls, and auditing matters. Procedures must address confidential and anonymous complaints. Document all complaints received and how they were addressed.',
    legalReference:
        'SEC. 301 [15 U.S.C. 78j(m)] - Audit Committee Requirements',
    weight: 1.0,
    order: 24,
    createdAt: DateTime.now(),
    categoryName: 'Monitoring & Testing',
    criticality: 'High',
    answered: false,
    response: null,
  ),

  // ========== 5. DOCUMENTATION & EVIDENCE (5 Questions) ==========

  // Q25 - SEC. 802
  ComplianceQuestion(
    id: 'q25',
    complianceType: ComplianceType.sox,
    category: QuestionCategory.documentation,
    questionText:
        'Are procedures in place to prevent the destruction or alteration of records to impede investigations?',
    description:
        'Implement written procedures prohibiting destruction, alteration, or concealment of records with intent to impede investigations. Include document retention policies, consequences for violations, and training on these requirements. Monitor for compliance.',
    legalReference:
        'SEC. 802 [18 U.S.C. 1519] - Document Destruction/Alteration Criminal Penalties',
    weight: 1.0,
    order: 25,
    createdAt: DateTime.now(),
    categoryName: 'Documentation & Evidence',
    criticality: 'High',
    answered: false,
    response: null,
  ),

  // Q26 - SEC. 103
  ComplianceQuestion(
    id: 'q26',
    complianceType: ComplianceType.sox,
    category: QuestionCategory.documentation,
    questionText:
        'Are audit work papers and related information maintained for at least 7 years?',
    description:
        'Audit firms must prepare and maintain audit work papers and all audit-related information for at least 7 years. If you manage the audit relationship, confirm your auditor has appropriate record retention. If internally conducting SOX work, maintain all audit evidence for 7 years.',
    legalReference:
        'SEC. 103 [15 U.S.C. 7213] - Audit Work Paper Retention Requirements',
    weight: 1.0,
    order: 26,
    createdAt: DateTime.now(),
    categoryName: 'Documentation & Evidence',
    criticality: 'Medium',
    answered: false,
    response: null,
  ),

  // Q27 - SEC. 802
  ComplianceQuestion(
    id: 'q27',
    complianceType: ComplianceType.sox,
    category: QuestionCategory.documentation,
    questionText:
        'Are audit or review workpapers maintained for 5 years from the end of the fiscal period?',
    description:
        'Company internal audit and review workpapers must be maintained for 5 years from the end of the fiscal period in which audit/review was completed. Establish retention schedule and storage procedures for audit evidence.',
    legalReference: 'SEC. 802 [18 U.S.C. 1520] - Audit Work Paper Retention',
    weight: 1.0,
    order: 27,
    createdAt: DateTime.now(),
    categoryName: 'Documentation & Evidence',
    criticality: 'Medium',
    answered: false,
    response: null,
  ),

  // Q28 - SEC. 403
  ComplianceQuestion(
    id: 'q28',
    complianceType: ComplianceType.sox,
    category: QuestionCategory.documentation,
    questionText:
        'Are changes in equity ownership filed electronically within two business days?',
    description:
        'Any officer, director, or 10% shareholder changes in company equity ownership must be filed with the SEC electronically (Form 4) within 2 business days of the transaction. Implement process to track trading activity, calculate Form 4 filing deadlines, and ensure timely electronic filing.',
    legalReference:
        'SEC. 403 [15 U.S.C. 78m] - Insider Trading Disclosure Requirements',
    weight: 1.0,
    order: 28,
    createdAt: DateTime.now(),
    categoryName: 'Documentation & Evidence',
    criticality: 'High',
    answered: false,
    response: null,
  ),

  // Q29 - SEC. 409
  ComplianceQuestion(
    id: 'q29',
    complianceType: ComplianceType.sox,
    category: QuestionCategory.documentation,
    questionText:
        'Is the company capable of disclosing material changes to the public on a rapid and current basis?',
    description:
        'Company must have capability to disclose material changes in financial condition or operations to the public on a rapid and current basis. Establish procedures for identifying material events, approving disclosures, and timely communication to SEC and public.',
    legalReference:
        'SEC. 409 [15 U.S.C. 78m] - Real-Time Disclosure of Material Changes',
    weight: 1.0,
    order: 29,
    createdAt: DateTime.now(),
    categoryName: 'Documentation & Evidence',
    criticality: 'Medium',
    answered: false,
    response: null,
  ),

  // Q30 - SEC. 1102
  ComplianceQuestion(
    id: 'q30',
    complianceType: ComplianceType.sox,
    category: QuestionCategory.documentation,
    questionText:
        'Is there a prohibition against corruptly tampering with objects or records to impair their integrity?',
    description:
        'Establish policy prohibiting corrupt alteration, destruction, or concealment of records, documents, or objects with intent to impair integrity or availability for official proceedings. Include examples, consequences, and training. This protects against obstruction of justice.',
    legalReference:
        'SEC. 1102 [18 U.S.C. 1512] - Corruption of Records Criminal Penalties',
    weight: 1.0,
    order: 30,
    createdAt: DateTime.now(),
    categoryName: 'Documentation & Evidence',
    criticality: 'Medium',
    answered: false,
    response: null,
  ),

  // ========== 6. GAP QUESTIONS - ROBUSTNESS (6 Questions) ==========

  // Q31 - SEC. 407
  ComplianceQuestion(
    id: 'q31',
    complianceType: ComplianceType.sox,
    category: QuestionCategory.testing,
    questionText:
        'Does the company disclose whether the audit committee has at least one "financial expert"?',
    description:
        'Company must disclose whether at least one audit committee member is a financial expert, as defined by SEC rules. Financial expert must have relevant experience in financial reporting, internal controls, or audit functions. If no financial expert exists, explain why.',
    legalReference:
        'SEC. 407 [15 U.S.C. 7265] - Disclosure of Audit Committee Financial Expert',
    weight: 1.0,
    order: 31,
    createdAt: DateTime.now(),
    categoryName: 'Gap Questions (Robustness)',
    criticality: 'High',
    answered: false,
    response: null,
  ),

  // Q32 - SEC. 203
  ComplianceQuestion(
    id: 'q32',
    complianceType: ComplianceType.sox,
    category: QuestionCategory.testing,
    questionText:
        'Is there a mechanism to ensure the lead audit partner rotates every 5 years?',
    description:
        'Establish mechanism requiring the lead (or coordinating) audit partner to rotate every 5 years. This prevents undue familiarity and ensures audit independence. Document audit partner rotation history and partner assignments to ensure compliance.',
    legalReference: 'SEC. 203 [15 U.S.C. 7212] - Lead Audit Partner Rotation',
    weight: 1.0,
    order: 32,
    createdAt: DateTime.now(),
    categoryName: 'Gap Questions (Robustness)',
    criticality: 'High',
    answered: false,
    response: null,
  ),

  // Q33 - SEC. 304
  ComplianceQuestion(
    id: 'q33',
    complianceType: ComplianceType.sox,
    category: QuestionCategory.testing,
    questionText:
        'Do executive contracts acknowledge that bonuses must be repaid (clawed back) if financial reports are restated due to misconduct?',
    description:
        'CEO and CFO must forfeit and repay bonuses and incentive-based compensation received during 12-month period following materially misleading financial statements later restated. Include clawback provisions in employment contracts. Establish procedures to enforce clawback obligations.',
    legalReference:
        'SEC. 304 [15 U.S.C. 7243] - Bonus Clawback for Restatements',
    weight: 1.0,
    order: 33,
    createdAt: DateTime.now(),
    categoryName: 'Gap Questions (Robustness)',
    criticality: 'Medium',
    answered: false,
    response: null,
  ),

  // Q34 - SEC. 307
  ComplianceQuestion(
    id: 'q34',
    complianceType: ComplianceType.sox,
    category: QuestionCategory.testing,
    questionText:
        'Do attorneys have a mandatory channel to report material violations to the chief legal counsel or audit committee?',
    description:
        'Establish procedures requiring attorneys to report evidence of material violations of securities law to chief legal counsel or CEO. If they do not respond appropriately, attorneys must report to the audit committee. Document these procedures and training to all attorneys.',
    legalReference:
        'SEC. 307 [15 U.S.C. 7245] - Attorney Reporting Requirements',
    weight: 1.0,
    order: 34,
    createdAt: DateTime.now(),
    categoryName: 'Gap Questions (Robustness)',
    criticality: 'High',
    answered: false,
    response: null,
  ),

  // Q35 - SEC. 202
  ComplianceQuestion(
    id: 'q35',
    complianceType: ComplianceType.sox,
    category: QuestionCategory.testing,
    questionText:
        'Are all non-audit services provided by the auditor preapproved by the audit committee?',
    description:
        'Audit committee must preapprove all non-audit services provided by external auditors. Establish audit committee procedures for reviewing and approving non-audit services before engagement. Maintain documentation of preapprovalsand all approved services.',
    legalReference: 'SEC. 202 [15 U.S.C. 7212] - Non-Audit Service Preapproval',
    weight: 1.0,
    order: 35,
    createdAt: DateTime.now(),
    categoryName: 'Gap Questions (Robustness)',
    criticality: 'High',
    answered: false,
    response: null,
  ),

  // Q36 - SEC. 206
  ComplianceQuestion(
    id: 'q36',
    complianceType: ComplianceType.sox,
    category: QuestionCategory.testing,
    questionText:
        'Does the company verify that no CEO/CFO/Controller was employed by the auditor in the past year?',
    description:
        'Auditors cannot perform audit services if CEO, CFO, or Controller was employed by the accounting firm in the prior year and participated in any audit capacity. Obtain signed confirmations from current executives regarding prior audit firm employment and verify auditor compliance.',
    legalReference:
        'SEC. 206 [15 U.S.C. 7214] - Auditor Independence - Prior Employment',
    weight: 1.0,
    order: 36,
    createdAt: DateTime.now(),
    categoryName: 'Gap Questions (Robustness)',
    criticality: 'High',
    answered: false,
    response: null,
  ),

  // ========== 7. PROCESS QUESTIONS - VULNERABILITIES (2 Questions) ==========

  // Q37 - SEC. 406
  ComplianceQuestion(
    id: 'q37',
    complianceType: ComplianceType.sox,
    category: QuestionCategory.testing,
    questionText:
        'Is there a process to immediately disclose any waiver of the Code of Ethics for senior financial officers?',
    description:
        'Establish process to immediately disclose any waiver of Code of Ethics provisions applicable to senior financial officers. Monitor code compliance and maintain records of all waivers granted, reasons for waivers, and approvals.',
    legalReference:
        'SEC. 406 [15 U.S.C. 7264] - Code of Ethics Waiver Disclosure',
    weight: 1.0,
    order: 37,
    createdAt: DateTime.now(),
    categoryName: 'Process Questions (Vulnerabilities)',
    criticality: 'Medium',
    answered: false,
    response: null,
  ),

  // Q38 - SEC. 401
  ComplianceQuestion(
    id: 'q38',
    complianceType: ComplianceType.sox,
    category: QuestionCategory.testing,
    questionText:
        'Is there a strict policy ensuring financial reports reflect all material correcting adjustments identified by the auditor?',
    description:
        'Establish policy requiring all material correcting adjustments identified by auditors to be recorded in financial statements. Implement process to track auditor-identified adjustments and ensure none are omitted from final reported results. Document review and approval of all adjustments.',
    legalReference:
        'SEC. 401 [15 U.S.C. 78m] - Complete and Accurate Financial Reporting',
    weight: 1.0,
    order: 38,
    createdAt: DateTime.now(),
    categoryName: 'Process Questions (Vulnerabilities)',
    criticality: 'High',
    answered: false,
    response: null,
  ),
];
