// Standalone seeding script for SOX questions
// Usage: node seed-standalone.js

const admin = require('firebase-admin');
const serviceAccount = require('./lib/service-account.json');

// Initialize Firebase Admin SDK
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

// Connect to emulator if FIRESTORE_EMULATOR_HOST is set
if (process.env.FIRESTORE_EMULATOR_HOST) {
  console.log('Using Firestore emulator at:', process.env.FIRESTORE_EMULATOR_HOST);
}

const SOX_QUESTIONS = [
  {
    complianceType: 'sox',
    category: 'accessControls',
    questionText: 'Is user access to financial systems formally documented?',
    description: 'All user access to ERP, accounting, and financial reporting systems should be documented with clear approval trails',
    weight: 1.0,
    order: 1,
  },
  {
    complianceType: 'sox',
    category: 'accessControls',
    questionText: 'Are quarterly access reviews performed for all financial system users?',
    description: 'Periodic reviews ensure access remains appropriate and obsolete accounts are removed',
    weight: 1.0,
    order: 2,
  },
  {
    complianceType: 'sox',
    category: 'accessControls',
    questionText: 'Are segregation of duties conflicts identified and mitigated?',
    description: 'Critical incompatible duties (e.g., request/approve/record) must be assigned to different individuals',
    weight: 1.5,
    order: 3,
  },
  {
    complianceType: 'sox',
    category: 'accessControls',
    questionText: 'Is physical access to financial data centers restricted and monitored?',
    description: 'Physical controls prevent unauthorized access to servers, backup media, and documentation',
    weight: 1.0,
    order: 4,
  },
  {
    complianceType: 'sox',
    category: 'accessControls',
    questionText: 'Are password policies enforced (complexity, expiration, history)?',
    description: 'Strong password controls reduce risk of unauthorized access',
    weight: 1.0,
    order: 5,
  },
  {
    complianceType: 'sox',
    category: 'changeManagement',
    questionText: 'Is there a formal change control process for all financial system changes?',
    description: 'Changes must be authorized, tested, and documented before production deployment',
    weight: 1.5,
    order: 6,
  },
  {
    complianceType: 'sox',
    category: 'changeManagement',
    questionText: 'Are business process changes assessed for control impact?',
    description: 'Process changes may create new control gaps that need to be addressed',
    weight: 1.5,
    order: 7,
  },
  {
    complianceType: 'sox',
    category: 'changeManagement',
    questionText: 'Are development, test, and production environments segregated?',
    description: 'Separation prevents inadvertent or malicious production data exposure',
    weight: 1.5,
    order: 8,
  },
  {
    complianceType: 'sox',
    category: 'changeManagement',
    questionText: 'Are backup and disaster recovery procedures regularly tested?',
    description: 'Regular testing ensures backups are usable and recovery time objectives are met',
    weight: 1.0,
    order: 9,
  },
  {
    complianceType: 'sox',
    category: 'financialReporting',
    questionText: 'Are general ledger reconciliations performed and reviewed monthly?',
    description: 'GL reconciliations ensure all transactions are accurately recorded',
    weight: 1.5,
    order: 10,
  },
  {
    complianceType: 'sox',
    category: 'financialReporting',
    questionText: 'Are manual journal entries authorized and documented?',
    description: 'Manual entries bypass system controls and require explicit authorization',
    weight: 1.5,
    order: 11,
  },
  {
    complianceType: 'sox',
    category: 'financialReporting',
    questionText: 'Is the month-end close process fully documented and controlled?',
    description: 'Close procedures ensure complete and accurate financial statement preparation',
    weight: 1.5,
    order: 12,
  },
  {
    complianceType: 'sox',
    category: 'financialReporting',
    questionText: 'Are account reconciliations completed for all material accounts?',
    description: 'Account-level reconciliations identify and resolve discrepancies',
    weight: 1.0,
    order: 13,
  },
  {
    complianceType: 'sox',
    category: 'financialReporting',
    questionText: 'Is the financial reporting process controlled and documented?',
    description: 'Controls ensure reports are accurate, complete, and timely',
    weight: 1.5,
    order: 14,
  },
  {
    complianceType: 'sox',
    category: 'financialReporting',
    questionText: 'Are journal entry adjustments reviewed and approved before posting?',
    description: 'Pre-posting review prevents errors in the general ledger',
    weight: 1.0,
    order: 15,
  },
  {
    complianceType: 'sox',
    category: 'itControls',
    questionText: 'Is IT governance aligned with overall business governance?',
    description: 'IT strategy and decisions should support business objectives',
    weight: 1.0,
    order: 16,
  },
  {
    complianceType: 'sox',
    category: 'itControls',
    questionText: 'Are system access logs reviewed and monitored for anomalies?',
    description: 'Log review detects unauthorized access attempts and unusual activity',
    weight: 1.5,
    order: 17,
  },
  {
    complianceType: 'sox',
    category: 'itControls',
    questionText: 'Are disaster recovery plans documented and tested annually?',
    description: 'DR planning ensures business continuity in case of major incidents',
    weight: 1.5,
    order: 18,
  },
  {
    complianceType: 'sox',
    category: 'itControls',
    questionText: 'Are security patches applied timely to all financial systems?',
    description: 'Timely patching reduces vulnerability to known security exploits',
    weight: 1.5,
    order: 19,
  },
  {
    complianceType: 'sox',
    category: 'itControls',
    questionText: 'Is anti-malware protection installed and kept current?',
    description: 'Anti-malware protection prevents infection of financial systems',
    weight: 1.0,
    order: 20,
  },
  {
    complianceType: 'sox',
    category: 'documentation',
    questionText: 'Are all control procedures documented in detail?',
    description: 'Documentation enables consistent execution and training of new staff',
    weight: 1.5,
    order: 21,
  },
  {
    complianceType: 'sox',
    category: 'documentation',
    questionText: 'Is control testing evidence retained and organized?',
    description: 'Evidence demonstrates that controls operated effectively',
    weight: 1.5,
    order: 22,
  },
  {
    complianceType: 'sox',
    category: 'documentation',
    questionText: 'Are policies and procedures communicated to relevant personnel?',
    description: 'Communication ensures staff understands expectations',
    weight: 1.0,
    order: 23,
  },
  {
    complianceType: 'sox',
    category: 'documentation',
    questionText: 'Is there a documented plan for testing all key controls?',
    description: 'Test plans ensure comprehensive and timely control evaluation',
    weight: 1.5,
    order: 24,
  },
  {
    complianceType: 'sox',
    category: 'testing',
    questionText: 'Is control testing performed by individuals independent of control execution?',
    description: 'Independence ensures objectivity of testing results',
    weight: 1.5,
    order: 25,
  },
  {
    complianceType: 'sox',
    category: 'testing',
    questionText: 'Are control test sample sizes justified and documented?',
    description: 'Proper sampling provides reasonable assurance of control effectiveness',
    weight: 1.0,
    order: 26,
  },
  {
    complianceType: 'sox',
    category: 'testing',
    questionText: 'Are control deviations analyzed and documented?',
    description: 'Deviation analysis determines if exceptions indicate control failures',
    weight: 1.5,
    order: 27,
  },
];

async function seedSOXQuestions() {
  try {
    console.log('Starting to seed SOX questions...');
    
    const batch = db.batch();
    const questionsRef = db.collection('compliance_questions');
    
    for (const question of SOX_QUESTIONS) {
      const docRef = questionsRef.doc(`sox_q${question.order}`);
      batch.set(docRef, {
        ...question,
        createdAt: admin.firestore.Timestamp.now(),
      });
    }
    
    await batch.commit();
    console.log(`✓ Successfully seeded ${SOX_QUESTIONS.length} SOX questions`);
    
  } catch (error) {
    console.error('Error seeding questions:', error);
    throw error;
  }
}

async function initializeComplianceData() {
  try {
    await seedSOXQuestions();
    console.log('✓ Compliance data initialization complete');
    process.exit(0);
  } catch (error) {
    console.error('Failed to initialize compliance data:', error);
    process.exit(1);
  }
}

// Run
initializeComplianceData();
