"use strict";
// Utility functions for readiness calculation
Object.defineProperty(exports, "__esModule", { value: true });
exports.getThreshold = getThreshold;
exports.getCompletionScore = getCompletionScore;
exports.generateSuggestedAction = generateSuggestedAction;
exports.formatCategoryName = formatCategoryName;
exports.calculateReadinessMetrics = calculateReadinessMetrics;
exports.generateActionItems = generateActionItems;
exports.generateDashboardStatus = generateDashboardStatus;
const types_1 = require("./types");
const SOX_THRESHOLD = 0.8;
/**
 * Get the readiness threshold for a compliance type
 */
function getThreshold(type) {
    switch (type) {
        case types_1.ComplianceType.SOX:
            return SOX_THRESHOLD;
        default:
            return 0.8;
    }
}
/**
 * Get numeric score for completion state
 */
function getCompletionScore(state) {
    switch (state) {
        case types_1.CompletionState.NotStarted:
            return 0.0;
        case types_1.CompletionState.Partial:
            return 0.5;
        case types_1.CompletionState.Complete:
            return 1.0;
    }
}
/**
 * Generate suggested action text based on question and state
 */
function generateSuggestedAction(question, state) {
    switch (state) {
        case types_1.CompletionState.NotStarted:
            const category = formatCategoryName(question.category);
            return `Start assessment of ${category} control`;
        case types_1.CompletionState.Partial:
            return 'Complete remaining assessment work for this control';
        case types_1.CompletionState.Complete:
            return '';
    }
}
/**
 * Format enum name to readable text
 * e.g., "accessControls" -> "Access Controls"
 */
function formatCategoryName(category) {
    return category
        .replace(/([a-z])([A-Z])/g, '$1 $2')
        .replace(/^./, (str) => str.toUpperCase());
}
/**
 * Calculate readiness metrics from questions and assessments
 */
function calculateReadinessMetrics(userId, complianceType, questions, assessments) {
    const totalQuestions = questions.length;
    if (totalQuestions === 0) {
        return {
            userId,
            complianceType,
            readinessPercentage: 0.0,
            readinessDecimal: 0.0,
            totalQuestions: 0,
            completeCount: 0,
            partialCount: 0,
            notStartedCount: 0,
            isReadyForAuditors: false,
            threshold: getThreshold(complianceType),
            calculatedAt: new Date(),
        };
    }
    const assessmentMap = new Map();
    for (const assessment of assessments) {
        assessmentMap.set(assessment.questionId, assessment);
    }
    let totalScore = 0.0;
    let completeCount = 0;
    let partialCount = 0;
    let notStartedCount = 0;
    for (const question of questions) {
        const assessment = assessmentMap.get(question.id);
        const state = assessment?.completionState ?? types_1.CompletionState.NotStarted;
        const score = getCompletionScore(state);
        // Apply question weight if specified, otherwise equal weighting
        const weight = question.weight ?? 1.0 / totalQuestions;
        totalScore += score * weight;
        // Track completion states
        switch (state) {
            case types_1.CompletionState.Complete:
                completeCount++;
                break;
            case types_1.CompletionState.Partial:
                partialCount++;
                break;
            case types_1.CompletionState.NotStarted:
                notStartedCount++;
                break;
        }
    }
    // Normalize score
    const threshold = getThreshold(complianceType);
    const readinessDecimal = totalScore / totalQuestions;
    const readinessPercentage = readinessDecimal * 100;
    return {
        userId,
        complianceType,
        readinessPercentage: parseFloat(readinessPercentage.toFixed(2)),
        readinessDecimal: parseFloat(readinessDecimal.toFixed(4)),
        totalQuestions,
        completeCount,
        partialCount,
        notStartedCount,
        isReadyForAuditors: readinessDecimal >= threshold,
        threshold,
        calculatedAt: new Date(),
    };
}
/**
 * Generate action items from incomplete questions
 */
function generateActionItems(questions, assessments) {
    const assessmentMap = new Map();
    for (const assessment of assessments) {
        assessmentMap.set(assessment.questionId, assessment);
    }
    const actionItems = [];
    for (const question of questions) {
        const assessment = assessmentMap.get(question.id);
        const state = assessment?.completionState ?? types_1.CompletionState.NotStarted;
        // Only include incomplete items
        if (state !== types_1.CompletionState.Complete) {
            actionItems.push({
                questionId: question.id,
                questionText: question.questionText,
                category: question.category,
                currentState: state,
                suggestedAction: generateSuggestedAction(question, state),
            });
        }
    }
    // Sort by category, then by state (notStarted first)
    actionItems.sort((a, b) => {
        const categoryCompare = a.category.localeCompare(b.category);
        if (categoryCompare !== 0)
            return categoryCompare;
        const stateOrder = {
            [types_1.CompletionState.NotStarted]: 0,
            [types_1.CompletionState.Partial]: 1,
            [types_1.CompletionState.Complete]: 2,
        };
        return (stateOrder[a.currentState] ?? 0) - (stateOrder[b.currentState] ?? 0);
    });
    return actionItems;
}
/**
 * Generate dashboard status based on readiness
 */
function generateDashboardStatus(metrics) {
    if (metrics.isReadyForAuditors) {
        return 'Ready to engage auditors';
    }
    else {
        const percentageNeeded = (metrics.threshold * 100 - metrics.readinessPercentage).toFixed(1);
        return `Not ready (${percentageNeeded}% more work needed)`;
    }
}
//# sourceMappingURL=utils.js.map