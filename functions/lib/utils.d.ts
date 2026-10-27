import { CompletionState, ComplianceType, QuestionCategory, ActionItem, ReadinessMetrics, ComplianceQuestion, QuestionAssessment } from './types';
/**
 * Get the readiness threshold for a compliance type
 */
export declare function getThreshold(type: ComplianceType): number;
/**
 * Get numeric score for completion state
 */
export declare function getCompletionScore(state: CompletionState): number;
/**
 * Generate suggested action text based on question and state
 */
export declare function generateSuggestedAction(question: ComplianceQuestion, state: CompletionState): string;
/**
 * Format enum name to readable text
 * e.g., "accessControls" -> "Access Controls"
 */
export declare function formatCategoryName(category: QuestionCategory): string;
/**
 * Calculate readiness metrics from questions and assessments
 */
export declare function calculateReadinessMetrics(userId: string, complianceType: ComplianceType, questions: ComplianceQuestion[], assessments: QuestionAssessment[]): ReadinessMetrics;
/**
 * Generate action items from incomplete questions
 */
export declare function generateActionItems(questions: ComplianceQuestion[], assessments: QuestionAssessment[]): ActionItem[];
/**
 * Generate dashboard status based on readiness
 */
export declare function generateDashboardStatus(metrics: ReadinessMetrics): string;
//# sourceMappingURL=utils.d.ts.map