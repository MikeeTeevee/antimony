"use strict";
// Seed data for SOX compliance questions
// Run this via Firebase Admin SDK or manually create in Firestore Console
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.seedSOXQuestions = seedSOXQuestions;
exports.createSOXFramework = createSOXFramework;
exports.initializeComplianceData = initializeComplianceData;
const admin = __importStar(require("firebase-admin"));
const types_1 = require("./types");
const db = admin.firestore();
/**
 * SOX questions covering key internal control areas
 * These are representative questions for SOX 404 readiness assessment
 */
const SOX_QUESTIONS = [
    // Access Controls (5 questions)
    {
        complianceType: types_1.ComplianceType.SOX,
        category: types_1.QuestionCategory.AccessControls,
        questionText: 'Is user access to financial systems formally documented?',
        description: 'All user access to ERP, accounting, and financial reporting systems should be documented with clear approval trails',
        weight: 1.0,
        order: 1,
    },
    {
        complianceType: types_1.ComplianceType.SOX,
        category: types_1.QuestionCategory.AccessControls,
        questionText: 'Are quarterly access reviews performed for all financial system users?',
        description: 'Periodic reviews ensure access remains appropriate and obsolete accounts are removed',
        weight: 1.0,
        order: 2,
    },
    {
        complianceType: types_1.ComplianceType.SOX,
        category: types_1.QuestionCategory.AccessControls,
        questionText: 'Are segregation of duties conflicts identified and mitigated?',
        description: 'Critical incompatible duties (e.g., request/approve/record) must be assigned to different individuals',
        weight: 1.5,
        order: 3,
    },
    {
        complianceType: types_1.ComplianceType.SOX,
        category: types_1.QuestionCategory.AccessControls,
        questionText: 'Is physical access to financial data centers restricted and monitored?',
        description: 'Physical controls prevent unauthorized access to servers, backup media, and documentation',
        weight: 1.0,
        order: 4,
    },
    {
        complianceType: types_1.ComplianceType.SOX,
        category: types_1.QuestionCategory.AccessControls,
        questionText: 'Are user ID and password policies enforced consistently?',
        description: 'Password complexity, expiration, and re-use requirements must be enforced across all systems',
        weight: 1.0,
        order: 5,
    },
    // Change Management (4 questions)
    {
        complianceType: types_1.ComplianceType.SOX,
        category: types_1.QuestionCategory.ChangeManagement,
        questionText: 'Is there a formal change control process for financial systems?',
        description: 'All changes must be requested, approved, tested, and documented before implementation',
        weight: 1.5,
        order: 6,
    },
    {
        complianceType: types_1.ComplianceType.SOX,
        category: types_1.QuestionCategory.ChangeManagement,
        questionText: 'Are changes to financial processes documented and authorized?',
        description: 'Process changes require business owner and IT approval with documented justification',
        weight: 1.0,
        order: 7,
    },
    {
        complianceType: types_1.ComplianceType.SOX,
        category: types_1.QuestionCategory.ChangeManagement,
        questionText: 'Is separation between development, test, and production environments enforced?',
        description: 'Development and test environments must be isolated from production systems',
        weight: 1.5,
        order: 8,
    },
    {
        complianceType: types_1.ComplianceType.SOX,
        category: types_1.QuestionCategory.ChangeManagement,
        questionText: 'Are system backups tested regularly and documented?',
        description: 'Backup restoration must be tested at least quarterly to ensure recoverability',
        weight: 1.0,
        order: 9,
    },
    // Financial Reporting (6 questions)
    {
        complianceType: types_1.ComplianceType.SOX,
        category: types_1.QuestionCategory.FinancialReporting,
        questionText: 'Is the general ledger reconciled to subsidiary ledgers regularly?',
        description: 'Monthly reconciliation ensures consistency and identifies discrepancies promptly',
        weight: 1.5,
        order: 10,
    },
    {
        complianceType: types_1.ComplianceType.SOX,
        category: types_1.QuestionCategory.FinancialReporting,
        questionText: 'Are journal entry controls documented and enforced?',
        description: 'Manual journal entries must be approved, referenced, and traceable to supporting documentation',
        weight: 1.5,
        order: 11,
    },
    {
        complianceType: types_1.ComplianceType.SOX,
        category: types_1.QuestionCategory.FinancialReporting,
        questionText: 'Is period-end close process documented with assigned responsibilities?',
        description: 'Close procedures must include specific steps, owners, deadlines, and sign-off',
        weight: 1.5,
        order: 12,
    },
    {
        complianceType: types_1.ComplianceType.SOX,
        category: types_1.QuestionCategory.FinancialReporting,
        questionText: 'Are account reconciliations performed and reviewed monthly?',
        description: 'Balance sheet accounts must be reconciled to supporting documentation with management review',
        weight: 1.5,
        order: 13,
    },
    {
        complianceType: types_1.ComplianceType.SOX,
        category: types_1.QuestionCategory.FinancialReporting,
        questionText: 'Is the financial reporting process documented and communicated?',
        description: 'Documentation includes data sources, calculations, assumptions, and roles responsible',
        weight: 1.0,
        order: 14,
    },
    {
        complianceType: types_1.ComplianceType.SOX,
        category: types_1.QuestionCategory.FinancialReporting,
        questionText: 'Are adjustments to financial statements authorized before release?',
        description: 'All adjustments require business justification and appropriate approval levels',
        weight: 1.0,
        order: 15,
    },
    // IT Controls (5 questions)
    {
        complianceType: types_1.ComplianceType.SOX,
        category: types_1.QuestionCategory.ItControls,
        questionText: 'Is an IT governance structure defined and documented?',
        description: 'Governance defines roles, responsibilities, and decision-making authority for IT',
        weight: 1.0,
        order: 16,
    },
    {
        complianceType: types_1.ComplianceType.SOX,
        category: types_1.QuestionCategory.ItControls,
        questionText: 'Are system access logs reviewed regularly for unauthorized activity?',
        description: 'Access logs must be retained and reviewed at least quarterly',
        weight: 1.5,
        order: 17,
    },
    {
        complianceType: types_1.ComplianceType.SOX,
        category: types_1.QuestionCategory.ItControls,
        questionText: 'Is a disaster recovery plan in place and tested?',
        description: 'Plans must address RTO/RPO requirements and be tested at least annually',
        weight: 1.5,
        order: 18,
    },
    {
        complianceType: types_1.ComplianceType.SOX,
        category: types_1.QuestionCategory.ItControls,
        questionText: 'Are system security patches and updates applied timely?',
        description: 'Critical patches must be applied within defined windows with documented approval',
        weight: 1.0,
        order: 19,
    },
    {
        complianceType: types_1.ComplianceType.SOX,
        category: types_1.QuestionCategory.ItControls,
        questionText: 'Is anti-malware protection installed and maintained on all systems?',
        description: 'Malware definitions must be updated and real-time scanning enabled',
        weight: 1.0,
        order: 20,
    },
    // Documentation (4 questions)
    {
        complianceType: types_1.ComplianceType.SOX,
        category: types_1.QuestionCategory.Documentation,
        questionText: 'Are control activities documented with sufficient detail?',
        description: 'Documentation must include control objective, owner, frequency, and evidence collection method',
        weight: 1.0,
        order: 21,
    },
    {
        complianceType: types_1.ComplianceType.SOX,
        category: types_1.QuestionCategory.Documentation,
        questionText: 'Is testing evidence retained for audit review?',
        description: 'Evidence must demonstrate control execution and effectiveness; retention period: 7 years',
        weight: 1.5,
        order: 22,
    },
    {
        complianceType: types_1.ComplianceType.SOX,
        category: types_1.QuestionCategory.Documentation,
        questionText: 'Are policies and procedures current and communicated to relevant staff?',
        description: 'Documentation must be approved, dated, and accessible to all personnel performing the activities',
        weight: 1.0,
        order: 23,
    },
    {
        complianceType: types_1.ComplianceType.SOX,
        category: types_1.QuestionCategory.Documentation,
        questionText: 'Is control testing plan documented and scheduled?',
        description: 'Plan must assign responsibility, define testing scope, and establish timelines',
        weight: 1.0,
        order: 24,
    },
    // Testing (3 questions)
    {
        complianceType: types_1.ComplianceType.SOX,
        category: types_1.QuestionCategory.Testing,
        questionText: 'Are controls tested by independent personnel?',
        description: 'Control testing should be performed by someone other than the control operator',
        weight: 1.5,
        order: 25,
    },
    {
        complianceType: types_1.ComplianceType.SOX,
        category: types_1.QuestionCategory.Testing,
        questionText: 'Is test sample size justified and documented?',
        description: 'Sampling method must be documented with rationale for sample size',
        weight: 1.0,
        order: 26,
    },
    {
        complianceType: types_1.ComplianceType.SOX,
        category: types_1.QuestionCategory.Testing,
        questionText: 'Are control deviations analyzed and remediated?',
        description: 'Any deviations found during testing must be analyzed, root caused, and action plans implemented',
        weight: 1.5,
        order: 27,
    },
    {
        complianceType: types_1.ComplianceType.SOX,
        category: types_1.QuestionCategory.Documentation,
        questionText: 'Are changes in equity ownership filed electronically within two business days?',
        description: 'Any officer, director, or 10% shareholder changes in company equity ownership must be filed with the SEC electronically (Form 4) within 2 business days of the transaction. Implement process to track trading activity, calculate Form 4 filing deadlines, and ensure timely electronic filing.',
        weight: 1.0,
        order: 28,
    },
    {
        complianceType: types_1.ComplianceType.SOX,
        category: types_1.QuestionCategory.Documentation,
        questionText: 'Is the company capable of disclosing material changes to the public on a rapid and current basis?',
        description: 'Company must have capability to disclose material changes in financial condition or operations to the public on a rapid and current basis. Establish procedures for identifying material events, approving disclosures, and timely communication to SEC and public.',
        weight: 1.0,
        order: 29,
    },
    {
        complianceType: types_1.ComplianceType.SOX,
        category: types_1.QuestionCategory.Documentation,
        questionText: 'Is there a prohibition against corruptly tampering with objects or records to impair their integrity?',
        description: 'Establish policy prohibiting corrupt alteration, destruction, or concealment of records, documents, or objects with intent to impair integrity or availability for official proceedings. Include examples, consequences, and training. This protects against obstruction of justice.',
        weight: 1.0,
        order: 30,
    },
    {
        complianceType: types_1.ComplianceType.SOX,
        category: types_1.QuestionCategory.Testing,
        questionText: 'Does the company disclose whether the audit committee has at least one "financial expert"?',
        description: 'Company must disclose whether at least one audit committee member is a financial expert, as defined by SEC rules. Financial expert must have relevant experience in financial reporting, internal controls, or audit functions. If no financial expert exists, explain why.',
        weight: 1.0,
        order: 31,
    },
    {
        complianceType: types_1.ComplianceType.SOX,
        category: types_1.QuestionCategory.Testing,
        questionText: 'Is there a mechanism to ensure the lead audit partner rotates every 5 years?',
        description: 'Establish mechanism requiring the lead (or coordinating) audit partner to rotate every 5 years. This prevents undue familiarity and ensures audit independence. Document audit partner rotation history and partner assignments to ensure compliance.',
        weight: 1.0,
        order: 32,
    },
    {
        complianceType: types_1.ComplianceType.SOX,
        category: types_1.QuestionCategory.Testing,
        questionText: 'Do executive contracts acknowledge that bonuses must be repaid (clawed back) if financial reports are restated due to misconduct?',
        description: 'CEO and CFO must forfeit and repay bonuses and incentive-based compensation received during 12-month period following materially misleading financial statements later restated. Include clawback provisions in employment contracts. Establish procedures to enforce clawback obligations.',
        weight: 1.0,
        order: 33,
    },
    {
        complianceType: types_1.ComplianceType.SOX,
        category: types_1.QuestionCategory.Testing,
        questionText: 'Do attorneys have a mandatory channel to report material violations to the chief legal counsel or audit committee?',
        description: 'Establish procedures requiring attorneys to report evidence of material violations of securities law to chief legal counsel or CEO. If they do not respond appropriately, attorneys must report to the audit committee. Document these procedures and training to all attorneys.',
        weight: 1.0,
        order: 34,
    },
    {
        complianceType: types_1.ComplianceType.SOX,
        category: types_1.QuestionCategory.Testing,
        questionText: 'Are all non-audit services provided by the auditor preapproved by the audit committee?',
        description: 'Audit committee must preapprove all non-audit services provided by external auditors. Establish audit committee procedures for reviewing and approving non-audit services before engagement. Maintain documentation of preapprovals and all approved services.',
        weight: 1.0,
        order: 35,
    },
    {
        complianceType: types_1.ComplianceType.SOX,
        category: types_1.QuestionCategory.Testing,
        questionText: 'Does the company verify that no CEO/CFO/Controller was employed by the auditor in the past year?',
        description: 'Auditors cannot perform audit services if CEO, CFO, or Controller was employed by the accounting firm in the prior year and participated in any audit capacity. Obtain signed confirmations from current executives regarding prior audit firm employment and verify auditor compliance.',
        weight: 1.0,
        order: 36,
    },
    {
        complianceType: types_1.ComplianceType.SOX,
        category: types_1.QuestionCategory.Testing,
        questionText: 'Is there a process to immediately disclose any waiver of the Code of Ethics for senior financial officers?',
        description: 'Establish process to immediately disclose any waiver of Code of Ethics provisions applicable to senior financial officers. Monitor code compliance and maintain records of all waivers granted, reasons for waivers, and approvals.',
        weight: 1.0,
        order: 37,
    },
    {
        complianceType: types_1.ComplianceType.SOX,
        category: types_1.QuestionCategory.Testing,
        questionText: 'Is there a strict policy ensuring financial reports reflect all material correcting adjustments identified by the auditor?',
        description: 'Establish policy requiring all material correcting adjustments identified by auditors to be recorded in financial statements. Implement process to track auditor-identified adjustments and ensure none are omitted from final reported results. Document review and approval of all adjustments.',
        weight: 1.0,
        order: 38,
    },
];
/**
 * Seed the compliance questions to Firestore
 */
async function seedSOXQuestions() {
    console.log('Starting SOX questions seed...');
    try {
        const batch = db.batch();
        let count = 0;
        for (const question of SOX_QUESTIONS) {
            const docRef = db.collection('compliance_questions').doc();
            batch.set(docRef, {
                ...question,
                createdAt: admin.firestore.Timestamp.now(),
            });
            count++;
        }
        await batch.commit();
        console.log(`Successfully seeded ${count} SOX questions`);
    }
    catch (error) {
        console.error('Error seeding questions:', error);
        throw error;
    }
}
/**
 * Create the SOX compliance framework document
 */
async function createSOXFramework() {
    console.log('Creating SOX compliance framework...');
    try {
        await db.collection('compliance_frameworks').doc('sox').set({
            name: 'Sarbanes-Oxley (SOX)',
            description: 'SOX 404 Section 404 compliance readiness assessment framework',
            readinessThreshold: 0.8,
            questionCount: SOX_QUESTIONS.length,
            createdAt: admin.firestore.Timestamp.now(),
        });
        console.log('Successfully created SOX compliance framework');
    }
    catch (error) {
        console.error('Error creating SOX framework:', error);
        throw error;
    }
}
/**
 * Main seed function - run this to initialize all data
 */
async function initializeComplianceData() {
    await createSOXFramework();
    await seedSOXQuestions();
    console.log('Compliance data initialization complete!');
}
//# sourceMappingURL=seed.js.map