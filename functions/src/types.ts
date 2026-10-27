// Data models mirroring Dart models for TypeScript

export enum ComplianceType {
  SOX = 'sox',
}

export enum QuestionCategory {
  AccessControls = 'accessControls',
  ChangeManagement = 'changeManagement',
  FinancialReporting = 'financialReporting',
  ItControls = 'itControls',
  Documentation = 'documentation',
  Testing = 'testing',
}

export enum CompletionState {
  NotStarted = 'notStarted',
  Partial = 'partial',
  Complete = 'complete',
}

export interface ComplianceQuestion {
  id: string;
  complianceType: ComplianceType;
  category: QuestionCategory;
  questionText: string;
  description?: string;
  weight?: number;
  order: number;
  createdAt: FirebaseFirestore.Timestamp;
}

export interface QuestionAssessment {
  id: string;
  userId: string;
  questionId: string;
  completionState: CompletionState;
  notes?: string;
  lastUpdated: FirebaseFirestore.Timestamp;
  lastUpdatedBy?: string;
}

export interface ReadinessMetrics {
  userId: string;
  complianceType: ComplianceType;
  readinessPercentage: number; // 0 to 100
  readinessDecimal: number; // 0 to 1
  totalQuestions: number;
  completeCount: number;
  partialCount: number;
  notStartedCount: number;
  isReadyForAuditors: boolean;
  threshold: number;
  calculatedAt: FirebaseFirestore.Timestamp;
}

export interface ActionItem {
  questionId: string;
  questionText: string;
  category: QuestionCategory;
  currentState: CompletionState;
  suggestedAction?: string;
}

export interface DashboardData {
  metrics: ReadinessMetrics;
  nextSteps: ActionItem[];
  status: string;
  lastUpdated: FirebaseFirestore.Timestamp;
}

export interface ApiResponse<T> {
  success: boolean;
  data?: T;
  error?: string;
  timestamp: string;
}
