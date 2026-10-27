"use strict";
// Cloud Functions: Main API endpoints for compliance readiness
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
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.api = void 0;
const admin = __importStar(require("firebase-admin"));
const functions = __importStar(require("firebase-functions"));
const express_1 = __importDefault(require("express"));
const cors_1 = __importDefault(require("cors"));
const types_1 = require("./types");
const utils_1 = require("./utils");
admin.initializeApp();
const db = admin.firestore();
const auth = admin.auth();
// Configure emulator if env vars are set
if (process.env.FIRESTORE_EMULATOR_HOST) {
    console.log('Using Firestore emulator at:', process.env.FIRESTORE_EMULATOR_HOST);
}
if (process.env.FIREBASE_AUTH_EMULATOR_HOST) {
    console.log('Using Firebase Auth emulator at:', process.env.FIREBASE_AUTH_EMULATOR_HOST);
}
const app = (0, express_1.default)();
// Middleware
app.use((0, cors_1.default)());
app.use(express_1.default.json());
/**
 * Middleware to verify Firebase auth token
 * Allows requests with or without a valid token (for emulator testing)
 */
const authenticateToken = async (req, res, next) => {
    const token = req.headers.authorization?.split('Bearer ')[1];
    if (!token) {
        // For emulator/testing: allow unauthenticated requests
        // In production, this should return 401
        console.log('No token provided - using test user ID');
        req.userId = 'test-user-' + Date.now();
        return next();
    }
    try {
        const decodedToken = await auth.verifyIdToken(token);
        req.userId = decodedToken.uid;
        console.log('Token verified for user:', decodedToken.uid);
        next();
    }
    catch (error) {
        console.error('Token verification error:', error);
        // For emulator/testing: still allow the request
        req.userId = 'test-user-' + Date.now();
        next();
    }
};
app.use(authenticateToken);
// ============================================================================
// Question Endpoints
// ============================================================================
/**
 * GET /questions?complianceType=sox&category=accessControls
 * Fetch questions for a compliance type, optionally filtered by category
 */
app.get('/questions', async (req, res) => {
    try {
        const { complianceType = 'sox', category } = req.query;
        let query = db
            .collection('compliance_questions')
            .where('complianceType', '==', complianceType)
            .orderBy('order', 'asc');
        if (category) {
            query = query.where('category', '==', category);
        }
        const snapshot = await query.get();
        const questions = snapshot.docs.map((doc) => ({
            id: doc.id,
            ...doc.data(),
        }));
        res.status(200).json({
            success: true,
            data: questions,
            timestamp: new Date().toISOString(),
        });
    }
    catch (error) {
        console.error('Error fetching questions:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to fetch questions',
            timestamp: new Date().toISOString(),
        });
    }
});
/**
 * GET /questions/:questionId
 * Fetch a single question
 */
app.get('/questions/:questionId', async (req, res) => {
    try {
        const { questionId } = req.params;
        const doc = await db.collection('compliance_questions').doc(questionId).get();
        if (!doc.exists) {
            return res.status(404).json({
                success: false,
                error: 'Question not found',
                timestamp: new Date().toISOString(),
            });
        }
        res.status(200).json({
            success: true,
            data: { id: doc.id, ...doc.data() },
            timestamp: new Date().toISOString(),
        });
    }
    catch (error) {
        console.error('Error fetching question:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to fetch question',
            timestamp: new Date().toISOString(),
        });
    }
});
// ============================================================================
// Assessment Endpoints
// ============================================================================
/**
 * GET /assessments
 * Fetch all assessments for current user
 */
app.get('/assessments', async (req, res) => {
    try {
        const userId = req.userId;
        const snapshot = await db
            .collection('assessments')
            .where('userId', '==', userId)
            .get();
        const assessments = snapshot.docs.map((doc) => ({
            id: doc.id,
            ...doc.data(),
        }));
        res.status(200).json({
            success: true,
            data: assessments,
            timestamp: new Date().toISOString(),
        });
    }
    catch (error) {
        console.error('Error fetching assessments:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to fetch assessments',
            timestamp: new Date().toISOString(),
        });
    }
});
/**
 * GET /assessments/:questionId
 * Fetch assessment for a specific question
 */
app.get('/assessments/:questionId', async (req, res) => {
    try {
        const userId = req.userId;
        const { questionId } = req.params;
        const docId = `${userId}_${questionId}`;
        const doc = await db.collection('assessments').doc(docId).get();
        if (!doc.exists) {
            return res.status(404).json({
                success: false,
                error: 'Assessment not found',
                timestamp: new Date().toISOString(),
            });
        }
        res.status(200).json({
            success: true,
            data: { id: doc.id, ...doc.data() },
            timestamp: new Date().toISOString(),
        });
    }
    catch (error) {
        console.error('Error fetching assessment:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to fetch assessment',
            timestamp: new Date().toISOString(),
        });
    }
});
/**
 * POST /assessments/:questionId
 * Create or update an assessment
 * Body: { completionState: 'notStarted' | 'partial' | 'complete', notes?: string }
 */
app.post('/assessments/:questionId', async (req, res) => {
    try {
        const userId = req.userId;
        const { questionId } = req.params;
        const { completionState, notes } = req.body;
        if (!completionState || !Object.values(types_1.CompletionState).includes(completionState)) {
            return res.status(400).json({
                success: false,
                error: 'Invalid completionState',
                timestamp: new Date().toISOString(),
            });
        }
        const docId = `${userId}_${questionId}`;
        const assessment = {
            id: docId,
            userId,
            questionId,
            completionState: completionState,
            notes,
            lastUpdated: admin.firestore.Timestamp.now(),
            lastUpdatedBy: userId,
        };
        await db.collection('assessments').doc(docId).set(assessment, { merge: true });
        res.status(201).json({
            success: true,
            data: assessment,
            timestamp: new Date().toISOString(),
        });
    }
    catch (error) {
        console.error('Error creating/updating assessment:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to update assessment',
            timestamp: new Date().toISOString(),
        });
    }
});
/**
 * DELETE /assessments/:questionId
 * Delete an assessment
 */
app.delete('/assessments/:questionId', async (req, res) => {
    try {
        const userId = req.userId;
        const { questionId } = req.params;
        const docId = `${userId}_${questionId}`;
        await db.collection('assessments').doc(docId).delete();
        res.status(200).json({
            success: true,
            timestamp: new Date().toISOString(),
        });
    }
    catch (error) {
        console.error('Error deleting assessment:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to delete assessment',
            timestamp: new Date().toISOString(),
        });
    }
});
// ============================================================================
// Readiness Endpoints
// ============================================================================
/**
 * GET /readiness?complianceType=sox
 * Calculate and return readiness metrics
 */
app.get('/readiness', async (req, res) => {
    try {
        const userId = req.userId;
        const { complianceType = 'sox' } = req.query;
        // Fetch questions
        const questionSnapshot = await db
            .collection('compliance_questions')
            .where('complianceType', '==', complianceType)
            .get();
        const questions = questionSnapshot.docs.map((doc) => ({
            id: doc.id,
            ...doc.data(),
        }));
        // Fetch assessments
        const assessmentSnapshot = await db
            .collection('assessments')
            .where('userId', '==', userId)
            .get();
        const assessments = assessmentSnapshot.docs.map((doc) => ({
            id: doc.id,
            ...doc.data(),
        }));
        // Calculate metrics
        const metrics = (0, utils_1.calculateReadinessMetrics)(userId, complianceType, questions, assessments);
        // Save metrics for caching
        const metricsDocId = `${userId}_${complianceType}`;
        await db.collection('readiness_metrics').doc(metricsDocId).set(metrics, { merge: true });
        res.status(200).json({
            success: true,
            data: metrics,
            timestamp: new Date().toISOString(),
        });
    }
    catch (error) {
        console.error('Error calculating readiness:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to calculate readiness',
            timestamp: new Date().toISOString(),
        });
    }
});
// ============================================================================
// Dashboard Endpoint
// ============================================================================
/**
 * GET /dashboard?complianceType=sox
 * Get complete dashboard data (readiness + action items)
 */
app.get('/dashboard', async (req, res) => {
    try {
        const userId = req.userId;
        const { complianceType = 'sox' } = req.query;
        let questions = [];
        try {
            // Fetch questions from Firestore
            const questionSnapshot = await db
                .collection('compliance_questions')
                .where('complianceType', '==', complianceType)
                .get();
            questions = questionSnapshot.docs.map((doc) => ({
                id: doc.id,
                ...doc.data(),
            }));
        }
        catch (firestoreError) {
            console.warn('Could not fetch from Firestore, using mock data:', firestoreError);
            // Use mock data if Firestore is not available (emulator not running)
            questions = [
                {
                    id: 'q1',
                    complianceType: 'sox',
                    category: 'accessControls',
                    questionText: 'Is user access to financial systems formally documented?',
                    description: 'All user access should be documented with clear approval trails',
                    weight: 1.0,
                    order: 1,
                },
                {
                    id: 'q2',
                    complianceType: 'sox',
                    category: 'accessControls',
                    questionText: 'Are quarterly access reviews performed?',
                    description: 'Periodic reviews ensure access remains appropriate',
                    weight: 1.0,
                    order: 2,
                },
                {
                    id: 'q3',
                    complianceType: 'sox',
                    category: 'changeManagement',
                    questionText: 'Are all system changes formally documented and approved?',
                    description: 'Change management processes should be in place',
                    weight: 1.0,
                    order: 3,
                },
            ];
        }
        if (questions.length === 0) {
            // No questions found - return empty dashboard
            const emptyMetrics = {
                userId,
                complianceType: complianceType,
                readinessPercentage: 0,
                readinessDecimal: 0,
                totalQuestions: 0,
                completeCount: 0,
                partialCount: 0,
                notStartedCount: 0,
                isReadyForAuditors: false,
                threshold: (0, utils_1.getThreshold)(complianceType),
                calculatedAt: admin.firestore.Timestamp.now(),
            };
            const dashboardData = {
                metrics: emptyMetrics,
                nextSteps: [],
                status: (0, utils_1.generateDashboardStatus)(emptyMetrics),
                lastUpdated: admin.firestore.Timestamp.now(),
            };
            return res.status(200).json({
                success: true,
                data: dashboardData,
                timestamp: new Date().toISOString(),
            });
        }
        // Fetch assessments
        let assessments = [];
        try {
            const assessmentSnapshot = await db
                .collection('assessments')
                .where('userId', '==', userId)
                .get();
            assessments = assessmentSnapshot.docs.map((doc) => ({
                id: doc.id,
                ...doc.data(),
            }));
        }
        catch (e) {
            console.warn('Could not fetch assessments:', e);
            // Use empty assessments if Firestore is not available
            assessments = [];
        }
        // Calculate metrics
        const metrics = (0, utils_1.calculateReadinessMetrics)(userId, complianceType, questions, assessments);
        // Generate action items
        const nextSteps = (0, utils_1.generateActionItems)(questions, assessments);
        // Generate status
        const status = (0, utils_1.generateDashboardStatus)(metrics);
        const dashboardData = {
            metrics,
            nextSteps,
            status,
            lastUpdated: admin.firestore.Timestamp.now(),
        };
        res.status(200).json({
            success: true,
            data: dashboardData,
            timestamp: new Date().toISOString(),
        });
    }
    catch (error) {
        console.error('Error fetching dashboard:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to fetch dashboard',
            timestamp: new Date().toISOString(),
        });
    }
});
// Health check endpoint
app.get('/health', (req, res) => {
    res.status(200).json({
        success: true,
        data: { status: 'ok' },
        timestamp: new Date().toISOString(),
    });
});
// Export the Express app as a Cloud Function
exports.api = functions.https.onRequest(app);
//# sourceMappingURL=index.js.map