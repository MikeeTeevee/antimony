# SOX Compliance Readiness Backend

## Overview

This is a comprehensive backend system for assessing SOX (Sarbanes-Oxley) compliance readiness. The system allows organizations to evaluate their internal control maturity across multiple dimensions and determine their readiness to engage external auditors.

**Key Features:**
- 📋 27 comprehensive SOX questions across 6 control categories
- 📊 Intelligent readiness scoring (0-100%)
- 🎯 80% threshold for "Ready to engage auditors"
- 🚀 Extensible architecture for future compliance frameworks
- ☁️ Firebase backend with Cloud Functions
- 🔒 Secure authentication and authorization
- ⚡ Real-time dashboard and metrics

## Architecture

### Technology Stack
- **Database**: Firebase Firestore
- **Backend**: Firebase Cloud Functions (Node.js/TypeScript)
- **Frontend**: Flutter (Dart)
- **Authentication**: Firebase Auth
- **API**: RESTful HTTP (Express.js)

### Project Structure

```
accedr/
├── lib/
│   ├── models/
│   │   └── compliance_models.dart          # Data models
│   ├── services/
│   │   ├── firebase_services.dart          # Firestore operations
│   │   ├── readiness_calculator.dart       # Scoring logic
│   │   ├── dashboard_service.dart          # Dashboard aggregation
│   │   └── compliance_api_client.dart      # API client for Cloud Functions
│   └── main.dart
├── functions/
│   ├── src/
│   │   ├── index.ts                        # Main API endpoints
│   │   ├── types.ts                        # TypeScript interfaces
│   │   ├── utils.ts                        # Scoring utilities
│   │   └── seed.ts                         # Database seeding
│   ├── package.json
│   └── tsconfig.json
└── pubspec.yaml
```

## Data Models

### Core Entities

#### ComplianceQuestion
Represents a specific control or testing requirement.

```dart
class ComplianceQuestion {
  final String id;
  final ComplianceType complianceType;  // 'sox'
  final QuestionCategory category;      // e.g., accessControls
  final String questionText;            // "Is user access documented?"
  final String? description;            // Guidance text
  final double? weight;                 // Optional question weight
  final int order;                      // Display order
  final DateTime createdAt;
}
```

**Categories:**
- Access Controls
- Change Management
- Financial Reporting
- IT Controls
- Documentation
- Testing

#### QuestionAssessment
User's response to a question (completion state).

```dart
class QuestionAssessment {
  final String userId;
  final String questionId;
  final CompletionState completionState;  // notStarted | partial | complete
  final String? notes;
  final DateTime lastUpdated;
  final String? lastUpdatedBy;
}
```

#### ReadinessMetrics
Calculated readiness percentage and statistics.

```dart
class ReadinessMetrics {
  final String userId;
  final ComplianceType complianceType;
  final double readinessPercentage;     // 0-100
  final double readinessDecimal;        // 0-1
  final int totalQuestions;
  final int completeCount;
  final int partialCount;
  final int notStartedCount;
  final bool isReadyForAuditors;        // >= 80%
  final double threshold;               // 0.80 for SOX
  final DateTime calculatedAt;
}
```

#### DashboardData
Complete dashboard view (metrics + action items).

```dart
class DashboardData {
  final ReadinessMetrics metrics;
  final List<ActionItem> nextSteps;     // Incomplete items
  final String status;                  // "Ready to engage auditors" or status
  final DateTime lastUpdated;
}
```

## Scoring Logic

### Completion State Scores
```
not_started  = 0.0
partial      = 0.5
complete     = 1.0
```

### Readiness Calculation
```
Readiness = (Sum of all question scores) / Total questions
```

### Weighting (Optional)
Questions can have optional weights. If specified, the calculation becomes:
```
Readiness = (Sum of (score × weight)) / Total questions
```

### Readiness Thresholds
```
SOX: 80% (0.80)
```

When `Readiness >= Threshold`:
- Status: "Ready to engage auditors"
- isReadyForAuditors: true

## API Endpoints

All endpoints require Firebase authentication token in `Authorization: Bearer <token>` header.

### Questions

#### GET /questions
Fetch questions for a compliance type.

**Query Parameters:**
- `complianceType` (optional): 'sox' (default: 'sox')
- `category` (optional): Filter by category (e.g., 'accessControls')

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "q1",
      "complianceType": "sox",
      "category": "accessControls",
      "questionText": "Is user access formally documented?",
      "description": "...",
      "weight": 1.0,
      "order": 1,
      "createdAt": "2024-01-20T10:00:00Z"
    }
  ],
  "timestamp": "2024-01-20T10:30:00Z"
}
```

#### GET /questions/:questionId
Fetch a single question by ID.

### Assessments

#### GET /assessments
Fetch all assessments for current user.

**Response:** Array of QuestionAssessment objects

#### GET /assessments/:questionId
Fetch assessment for a specific question.

#### POST /assessments/:questionId
Create or update an assessment.

**Request Body:**
```json
{
  "completionState": "partial",
  "notes": "Started work on this control..."
}
```

#### DELETE /assessments/:questionId
Delete an assessment.

### Readiness

#### GET /readiness
Calculate readiness for current user.

**Query Parameters:**
- `complianceType` (optional): 'sox' (default: 'sox')

**Response:**
```json
{
  "success": true,
  "data": {
    "userId": "user123",
    "complianceType": "sox",
    "readinessPercentage": 65.5,
    "readinessDecimal": 0.655,
    "totalQuestions": 38,
    "partialCount": 6,
    "notStartedCount": 9,
    "isReadyForAuditors": false,
    "threshold": 0.8,
    "calculatedAt": "2024-01-20T10:30:00Z"
  },
  "timestamp": "2024-01-20T10:30:00Z"
}
```

### Dashboard

#### GET /dashboard
Get complete dashboard data (readiness + action items).

**Query Parameters:**
- `complianceType` (optional): 'sox'

**Response:**
```json
{
  "success": true,
  "data": {
    "metrics": { ... },
    "nextSteps": [
      {
        "questionId": "q7",
        "questionText": "Are changes to financial systems formally controlled?",
        "category": "changeManagement",
        "currentState": "notStarted",
        "suggestedAction": "Start assessment of Change Management control"
      }
    ],
    "status": "Not ready (14.5% more work needed)",
    "lastUpdated": "2024-01-20T10:30:00Z"
  },
  "timestamp": "2024-01-20T10:30:00Z"
}
```

## Flutter Service Usage

### Getting Started

1. **Initialize API Client:**
```dart
final apiClient = ComplianceApiClient(
  baseUrl: 'https://us-central1-your-project-id.cloudfunctions.net/api',
);
```

2. **Fetch Questions:**
```dart
final questions = await apiClient.getQuestions();
final byCategory = await apiClient.getQuestions(
  category: QuestionCategory.accessControls,
);
```

3. **Update Assessment:**
```dart
await apiClient.updateAssessment(
  'question-id',
  CompletionState.partial,
  notes: 'Work in progress',
);
```

4. **Get Readiness:**
```dart
final metrics = await apiClient.getReadiness();
print('Readiness: ${metrics.readinessPercentage}%');
print('Ready for auditors: ${metrics.isReadyForAuditors}');
```

5. **Get Dashboard:**
```dart
final dashboard = await apiClient.getDashboard();
print('Status: ${dashboard.status}');
print('Action items: ${dashboard.nextSteps.length}');
```

### Dashboard Service (Local)

For offline-first or cached access, use the DashboardService:

```dart
final dashboardService = DashboardService();

// Get complete dashboard data
final dashboard = await dashboardService.getDashboardData(
  userId,
  ComplianceType.sox,
);

// Stream real-time updates
dashboardService.streamDashboardData(userId, ComplianceType.sox)
  .listen((dashboard) {
    setState(() {
      readiness = dashboard.metrics.readinessPercentage;
      nextSteps = dashboard.nextSteps;
    });
  });

// Get category breakdown
final breakdown = await dashboardService.getCategoryBreakdown(
  userId,
  ComplianceType.sox,
);

// Get priority action items (top 10)
final priorities = await dashboardService.getPriorityActionItems(
  userId,
  ComplianceType.sox,
  limit: 10,
);
```

## Cloud Functions Setup

### Prerequisites
- Node.js 20+
- Firebase CLI
- Firebase project with Firestore enabled

### Installation

1. **Install dependencies:**
```bash
cd functions
npm install
```

2. **Configure Firebase project:**
```bash
firebase login
firebase init functions
```

3. **Deploy Cloud Functions:**
```bash
firebase deploy --only functions
```

4. **Update base URL in API client:**
Replace `your-project-id` in `compliance_api_client.dart`:
```dart
baseUrl: 'https://us-central1-YOUR_PROJECT_ID.cloudfunctions.net/api',
```

## Firestore Database Schema

### Collections

#### compliance_frameworks
```
{
  id: 'sox',
  name: 'Sarbanes-Oxley (SOX)',
  description: '...',
  readinessThreshold: 0.8,
  questionCount: 38,
}
```

#### compliance_questions
```
{
  id: 'auto-generated',
  complianceType: 'sox',
  category: 'accessControls',
  questionText: '...',
  description: '...',
  weight: 1.0,
  order: 1,
  createdAt: Timestamp
}
```

#### assessments
```
{
  id: 'userId_questionId',
  userId: '...',
  questionId: '...',
  completionState: 'partial',
  notes: '...',
  lastUpdated: Timestamp,
  lastUpdatedBy: 'userId'
}
```

#### readiness_metrics (cache)
```
{
  id: 'userId_sox',
  userId: '...',
  complianceType: 'sox',
  readinessPercentage: 65.5,
  readinessDecimal: 0.655,
  totalQuestions: 38, 12,
  partialCount: 6,
  notStartedCount: 9,
  isReadyForAuditors: false,
  threshold: 0.8,
  calculatedAt: Timestamp
}
```

#### dashboard_cache
```
{
  id: 'userId_sox',
  userId: '...',
  complianceType: 'sox',
  readinessPercentage: 65.5,
  isReadyForAuditors: false,
  status: '...',
  nextStepsCount: 10,
  lastUpdated: Timestamp
}
```

## Database Seeding

### Initialize SOX Questions

The seed script provides test data with 27 comprehensive SOX questions.

**Option 1: Run via Node.js**
```typescript
import { initializeComplianceData } from './src/seed';

initializeComplianceData();
```

**Option 2: Firestore Console**
Manually create documents in the `compliance_frameworks` and `compliance_questions` collections using the schema above.

## Extensibility

### Adding a New Compliance Framework

1. **Update types:**
```typescript
export enum ComplianceType {
  SOX = 'sox',
  ISO27001 = 'iso27001',  // New
}
```

2. **Add to threshold map:**
```typescript
export function getThreshold(type: ComplianceType): number {
  switch (type) {
    case ComplianceType.SOX:
      return 0.8;
    case ComplianceType.ISO27001:
      return 0.75;  // New threshold
    default:
      return 0.8;
  }
}
```

3. **Create framework document in Firestore:**
```
compliance_frameworks/iso27001:
{
  name: 'ISO 27001',
  description: '...',
  readinessThreshold: 0.75,
  questionCount: 42,
  createdAt: Timestamp
}
```

4. **Seed ISO 27001 questions:**
Add questions to `compliance_questions` collection with `complianceType: 'iso27001'`.

The scoring logic, API endpoints, and services automatically support the new framework.

## Security Considerations

- ✅ All endpoints require Firebase authentication
- ✅ Users can only access their own assessments
- ✅ Firestore security rules should restrict cross-user access
- ✅ Cloud Functions authenticate requests using Firebase Auth

### Recommended Firestore Rules
```javascript
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    // Questions are public
    match /compliance_questions/{doc=**} {
      allow read: if request.auth != null;
    }
    
    // Frameworks are public
    match /compliance_frameworks/{doc=**} {
      allow read: if request.auth != null;
    }
    
    // Users can only see their own assessments
    match /assessments/{doc=**} {
      allow read, write: if request.auth != null 
        && resource.data.userId == request.auth.uid;
    }
    
    // Users can only see their own metrics
    match /readiness_metrics/{doc=**} {
      allow read: if request.auth != null 
        && doc.startsWith(request.auth.uid);
    }
    
    // Dashboard cache is readable by owner
    match /dashboard_cache/{doc=**} {
      allow read: if request.auth != null 
        && doc.startsWith(request.auth.uid);
    }
  }
}
```

## Testing

### Manual Testing with cURL

```bash
# Get auth token (from Firebase Console or your app)
TOKEN="your-firebase-id-token"

# Fetch questions
curl -H "Authorization: Bearer $TOKEN" \
  https://us-central1-your-project-id.cloudfunctions.net/api/questions

# Get readiness
curl -H "Authorization: Bearer $TOKEN" \
  https://us-central1-your-project-id.cloudfunctions.net/api/readiness

# Update assessment
curl -X POST \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"completionState":"partial","notes":"In progress"}' \
  https://us-central1-your-project-id.cloudfunctions.net/api/assessments/q1

# Get dashboard
curl -H "Authorization: Bearer $TOKEN" \
  https://us-central1-your-project-id.cloudfunctions.net/api/dashboard
```

## Limitations & Non-Goals

❌ No certification logic (assessment only)  
❌ No auditor sign-off capability  
❌ No legal or compliance guarantees  
❌ No continuous monitoring  
❌ No integrations with external systems  

## Future Enhancements

- [ ] Additional compliance frameworks (ISO 27001, HIPAA, GDPR)
- [ ] Quarterly/YE roll-forward logic
- [ ] Evidence attachment and management
- [ ] Audit trail and history tracking
- [ ] Team collaboration and commenting
- [ ] Reporting and export (PDF, Excel)
- [ ] Role-based access control (RBAC)
- [ ] Admin dashboard for framework management
- [ ] Progress tracking and trend analysis
- [ ] Mobile app notifications and reminders

## Support

For issues or questions, refer to the implementation files:
- Data models: `lib/models/compliance_models.dart`
- Scoring logic: `lib/services/readiness_calculator.dart`
- API endpoints: `functions/src/index.ts`
- Cloud Functions utilities: `functions/src/utils.ts`

## Regulatory References

This system is built on the **Sarbanes-Oxley Act of 2002 (Public Law 107-204)**. For detailed regulatory text and compliance requirements, see the comprehensive regulatory reference guide.

### Key Regulatory Sections

Each compliance question in this system maps to specific sections of the Sarbanes-Oxley Act:

| Section | Title | Compliance Impact |
|---------|-------|-------------------|
| [SEC. 302](REGULATORY_REFERENCE.md#sec-302) | Corporate Responsibility for Financial Reports | **HIGH** - Officer certification & control assessment |
| [SEC. 304](REGULATORY_REFERENCE.md#sec-304) | Forfeiture of Bonuses and Profits | **HIGH** - Compensation tracking & clawback controls |
| [SEC. 401](REGULATORY_REFERENCE.md#sec-401) | Disclosures in Periodic Reports | **HIGH** - Off-balance sheet & financial data integrity |
| [SEC. 404](REGULATORY_REFERENCE.md#sec-404) | Management Assessment of Internal Controls | **CRITICAL** - Core internal control framework |
| [SEC. 406](REGULATORY_REFERENCE.md#sec-406) | Code of Ethics for Senior Financial Officers | **MEDIUM** - Ethics & disclosure standards |
| [SEC. 408](REGULATORY_REFERENCE.md#sec-408) | Enhanced Review of Periodic Disclosures | **HIGH** - Disclosure control assessment |

### Full Reference Documentation

👉 **[View Complete Regulatory Reference Guide →](REGULATORY_REFERENCE.md)**

The reference guide includes:
- Complete text of all relevant SEC sections
- Detailed compliance requirements and procedures
- Mapping of regulatory sections to control categories
- Quick reference guide for auditor preparation

### Compliance Category Mapping

**Access Controls:**
- [SEC. 206](REGULATORY_REFERENCE.md#sec-206) - Conflicts of Interest
- [SEC. 301](REGULATORY_REFERENCE.md#sec-301) - Audit Committee Authority
- [SEC. 306](REGULATORY_REFERENCE.md#sec-306) - Insider Trade Restrictions

**Change Management:**
- [SEC. 201](REGULATORY_REFERENCE.md#sec-201) - Auditor Independence & Service Scope
- [SEC. 203](REGULATORY_REFERENCE.md#sec-203) - Audit Partner Rotation

**Financial Reporting:**
- [SEC. 401](REGULATORY_REFERENCE.md#sec-401) - Periodic Report Disclosures
- [SEC. 404](REGULATORY_REFERENCE.md#sec-404) - Internal Control Assessment
- [SEC. 409](REGULATORY_REFERENCE.md#sec-409) - Real-Time Disclosures

**Documentation:**
- [SEC. 302](REGULATORY_REFERENCE.md#sec-302) - Officer Certification Requirements
- [SEC. 303](REGULATORY_REFERENCE.md#sec-303) - Anti-Coercion Procedures
- [SEC. 407](REGULATORY_REFERENCE.md#sec-407) - Audit Committee Financial Expert

**Testing:**
- [SEC. 204](REGULATORY_REFERENCE.md#sec-204) - Auditor Reports to Audit Committees
- [SEC. 408](REGULATORY_REFERENCE.md#sec-408) - Disclosure Control Review

**IT Controls:**
- [SEC. 402](REGULATORY_REFERENCE.md#sec-402) - Conflict of Interest Systems
- [SEC. 404](REGULATORY_REFERENCE.md#sec-404) - System Controls & Access
- [SEC. 408](REGULATORY_REFERENCE.md#sec-408) - Disclosure System Controls
