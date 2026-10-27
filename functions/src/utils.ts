// Utility functions for readiness calculation

import {
  CompletionState,
  ComplianceType,
  QuestionCategory,
  ActionItem,
  ReadinessMetrics,
  ComplianceQuestion,
  QuestionAssessment,
} from './types';

const SOX_THRESHOLD = 0.8;

/**
 * Get the readiness threshold for a compliance type
 */
export function getThreshold(type: ComplianceType): number {
  switch (type) {
    case ComplianceType.SOX:
      return SOX_THRESHOLD;
    default:
      return 0.8;
  }
}

/**
 * Get numeric score for completion state
 */
export function getCompletionScore(state: CompletionState): number {
  switch (state) {
    case CompletionState.NotStarted:
      return 0.0;
    case CompletionState.Partial:
      return 0.5;
    case CompletionState.Complete:
      return 1.0;
  }
}

/**
 * Generate suggested action text based on question and state
 */
export function generateSuggestedAction(
  question: ComplianceQuestion,
  state: CompletionState,
): string {
  switch (state) {
    case CompletionState.NotStarted:
      const category = formatCategoryName(question.category);
      return `Start assessment of ${category} control`;
    case CompletionState.Partial:
      return 'Complete remaining assessment work for this control';
    case CompletionState.Complete:
      return '';
  }
}

/**
 * Format enum name to readable text
 * e.g., "accessControls" -> "Access Controls"
 */
export function formatCategoryName(category: QuestionCategory): string {
  return category
    .replace(/([a-z])([A-Z])/g, '$1 $2')
    .replace(/^./, (str) => str.toUpperCase());
}

/**
 * Calculate readiness metrics from questions and assessments
 */
export function calculateReadinessMetrics(
  userId: string,
  complianceType: ComplianceType,
  questions: ComplianceQuestion[],
  assessments: QuestionAssessment[],
): ReadinessMetrics {
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
      calculatedAt: new Date() as any,
    };
  }

  const assessmentMap = new Map<string, QuestionAssessment>();
  for (const assessment of assessments) {
    assessmentMap.set(assessment.questionId, assessment);
  }

  let totalScore = 0.0;
  let completeCount = 0;
  let partialCount = 0;
  let notStartedCount = 0;

  for (const question of questions) {
    const assessment = assessmentMap.get(question.id);
    const state = assessment?.completionState ?? CompletionState.NotStarted;
    const score = getCompletionScore(state);

    // Apply question weight if specified, otherwise equal weighting
    const weight = question.weight ?? 1.0 / totalQuestions;
    totalScore += score * weight;

    // Track completion states
    switch (state) {
      case CompletionState.Complete:
        completeCount++;
        break;
      case CompletionState.Partial:
        partialCount++;
        break;
      case CompletionState.NotStarted:
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
    calculatedAt: new Date() as any,
  };
}

/**
 * Generate action items from incomplete questions
 */
export function generateActionItems(
  questions: ComplianceQuestion[],
  assessments: QuestionAssessment[],
): ActionItem[] {
  const assessmentMap = new Map<string, QuestionAssessment>();
  for (const assessment of assessments) {
    assessmentMap.set(assessment.questionId, assessment);
  }

  const actionItems: ActionItem[] = [];

  for (const question of questions) {
    const assessment = assessmentMap.get(question.id);
    const state = assessment?.completionState ?? CompletionState.NotStarted;

    // Only include incomplete items
    if (state !== CompletionState.Complete) {
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
    if (categoryCompare !== 0) return categoryCompare;

    const stateOrder: Record<CompletionState, number> = {
      [CompletionState.NotStarted]: 0,
      [CompletionState.Partial]: 1,
      [CompletionState.Complete]: 2,
    };

    return (stateOrder[a.currentState] ?? 0) - (stateOrder[b.currentState] ?? 0);
  });

  return actionItems;
}

/**
 * Generate dashboard status based on readiness
 */
export function generateDashboardStatus(metrics: ReadinessMetrics): string {
  if (metrics.isReadyForAuditors) {
    return 'Ready to engage auditors';
  } else {
    const percentageNeeded = (metrics.threshold * 100 - metrics.readinessPercentage).toFixed(1);
    return `Not ready (${percentageNeeded}% more work needed)`;
  }
}
