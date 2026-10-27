# Quick Start Guide - SOX Compliance Readiness Backend

## 5-Minute Setup

### Step 1: Deploy Cloud Functions

```bash
# Navigate to functions directory
cd functions

# Install dependencies
npm install

# Deploy to Firebase
firebase deploy --only functions

# Note the function URL from deployment output:
# https://us-central1-YOUR_PROJECT_ID.cloudfunctions.net/api
```

### Step 2: Update Flutter App

Update the API client base URL in your app initialization:

```dart
// lib/main.dart or your service initialization
final apiClient = ComplianceApiClient(
  baseUrl: 'https://us-central1-YOUR_PROJECT_ID.cloudfunctions.net/api',
);
```

### Step 3: Seed Database

Option A: Run seed script via Node.js:
```bash
cd functions
npm run build
node -e "
  const admin = require('firebase-admin');
  const seed = require('./lib/seed');
  admin.initializeApp();
  seed.initializeComplianceData();
"
```

Option B: Manual setup in Firestore Console:
1. Go to your Firebase Console
2. Create collection: `compliance_frameworks`
3. Add document `sox` with fields from `COMPLIANCE_BACKEND.md`
4. Create collection: `compliance_questions`
5. Manually add 27 questions (see seed.ts for data)

### Step 4: Set Firestore Security Rules

Go to Firestore > Rules and update:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /compliance_questions/{doc=**} {
      allow read: if request.auth != null;
    }
    match /compliance_frameworks/{doc=**} {
      allow read: if request.auth != null;
    }
    match /assessments/{doc=**} {
      allow read, write: if request.auth != null 
        && resource.data.userId == request.auth.uid;
    }
    match /readiness_metrics/{doc=**} {
      allow read: if request.auth != null 
        && doc.startsWith(request.auth.uid);
    }
    match /dashboard_cache/{doc=**} {
      allow read: if request.auth != null 
        && doc.startsWith(request.auth.uid);
    }
  }
}
```

## Testing the Setup

### 1. Test API Health Check
```bash
curl https://us-central1-YOUR_PROJECT_ID.cloudfunctions.net/api/health
```

Expected response:
```json
{
  "success": true,
  "data": {"status": "ok"},
  "timestamp": "2024-01-20T10:30:00.000Z"
}
```

### 2. Test Authentication
Get a Firebase ID token from your app after user login, then:

```bash
TOKEN="your-firebase-id-token"

# Fetch questions
curl -H "Authorization: Bearer $TOKEN" \
  https://us-central1-YOUR_PROJECT_ID.cloudfunctions.net/api/questions

# Should return array of SOX questions
```

### 3. Test Dashboard (in Flutter app)
```dart
try {
  final dashboard = await apiClient.getDashboard();
  print('Readiness: ${dashboard.metrics.readinessPercentage}%');
  print('Status: ${dashboard.status}');
  print('Action items: ${dashboard.nextSteps.length}');
} catch (e) {
  print('Error: $e');
}
```

## Key Files Reference

| File | Purpose |
|------|---------|
| `lib/models/compliance_models.dart` | Data models & enums |
| `lib/services/firebase_services.dart` | Firestore operations |
| `lib/services/readiness_calculator.dart` | Scoring logic |
| `lib/services/dashboard_service.dart` | Dashboard aggregation |
| `lib/services/compliance_api_client.dart` | HTTP API client |
| `functions/src/index.ts` | Express API endpoints |
| `functions/src/utils.ts` | Scoring utilities |
| `functions/src/types.ts` | TypeScript interfaces |
| `functions/src/seed.ts` | Database seeding script |

## Understanding the Scoring

**27 SOX Questions** across 6 categories:
- Access Controls (5 questions)
- Change Management (4 questions)
- Financial Reporting (6 questions)
- IT Controls (5 questions)
- Documentation (4 questions)
- Testing (3 questions)

**Completion States:**
- ❌ Not Started = 0% (0.0)
- ⚠️ Partial = 50% (0.5)
- ✅ Complete = 100% (1.0)

**Readiness Calculation:**
```
Readiness % = (Average completion score) × 100
Threshold = 80% for SOX
Status = "Ready to engage auditors" when Readiness >= 80%
```

**Example:**
- 12 complete (12 × 1.0 = 12.0)
- 6 partial (6 × 0.5 = 3.0)
- 9 not started (9 × 0.0 = 0.0)
- **Total: 15.0 / 27 = 55.6% readiness** ❌ Not ready

## Common Operations

### Get User's Readiness
```dart
final metrics = await apiClient.getReadiness();
print('${metrics.readinessPercentage}% complete');
print('${metrics.completeCount}/${metrics.totalQuestions} questions complete');
```

### Update Question Status
```dart
// User marks a question as "partially complete"
await apiClient.updateAssessment(
  'question-id',
  CompletionState.partial,
  notes: 'Assessment started, documenting controls...',
);
```

### View Dashboard
```dart
final dashboard = await apiClient.getDashboard();

// Check if ready for auditors
if (dashboard.metrics.isReadyForAuditors) {
  print('✅ ${dashboard.status}');
} else {
  print('⚠️ ${dashboard.status}');
  print('\nNext steps:');
  for (var item in dashboard.nextSteps.take(5)) {
    print('- ${item.questionText}');
  }
}
```

### Local Dashboard (Offline-First)
```dart
final service = DashboardService();

// Get dashboard with local Firestore data
final dashboard = await service.getDashboardData(userId, ComplianceType.sox);

// Stream real-time updates
service.streamDashboardData(userId, ComplianceType.sox)
  .listen((updatedDashboard) {
    print('Dashboard updated: ${updatedDashboard.metrics.readinessPercentage}%');
  });

// Get category breakdown
final breakdown = await service.getCategoryBreakdown(userId, ComplianceType.sox);
// E.g., {accessControls: {complete: 3, partial: 1, notStarted: 1, total: 5}, ...}

// Get action items (sorted by priority)
final nextSteps = await service.getPriorityActionItems(userId, ComplianceType.sox);
```

## Troubleshooting

### Cloud Function Not Deploying
```bash
# Check Firebase project is set
firebase projects:list
firebase use YOUR_PROJECT_ID

# Check Node version
node --version  # Should be 20+

# Rebuild TypeScript
cd functions
npm run build
firebase deploy --only functions
```

### Authentication Errors
```
Error: "Invalid authorization token"
```
- Ensure user is logged in to Firebase Auth
- Verify Firebase ID token hasn't expired
- Check Cloud Function region matches your setup

### No Questions Appearing
```
Empty question list returned
```
- Verify seed script ran successfully
- Check Firestore console > `compliance_questions` collection has data
- Ensure security rules allow public read on questions

### Readiness Always 0%
```
Readiness stuck at 0% even after updating assessments
```
- Check assessments were saved to Firestore
- Verify document ID format: `userId_questionId`
- Look at browser console and Cloud Function logs

## Next Steps

1. **Build UI Components**
   - Question list view
   - Assessment form (radio buttons for states)
   - Readiness progress bar/gauge
   - Dashboard summary card
   - Action items list

2. **Add Features**
   - Bulk update assessments
   - Category filters
   - Sort/search questions
   - Export readiness report
   - User preferences/settings

3. **Optimize**
   - Implement pagination for questions
   - Add caching strategy
   - Optimize Firestore queries
   - Use Cloud Functions 2nd gen

4. **Extend**
   - Add more compliance frameworks
   - Implement team collaboration
   - Add evidence management
   - Build admin dashboard

## Documentation

- Full API reference: [COMPLIANCE_BACKEND.md](./COMPLIANCE_BACKEND.md)
- Data model details: [lib/models/compliance_models.dart](./lib/models/compliance_models.dart)
- Scoring algorithm: [lib/services/readiness_calculator.dart](./lib/services/readiness_calculator.dart)
