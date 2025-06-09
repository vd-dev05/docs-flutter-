# Onboarding API Endpoints

Tài liệu này mô tả các API endpoint liên quan đến quy trình Onboarding người dùng mới trong BlaBló App.

## Get Onboarding Flow

```
GET /api/onboarding/flow
```

**Headers:**
```
Content-Type: application/json
user_id: <device_id>
```

**Response:**
```json
{
  "data": {
    "steps": [
      {
        "id": "welcome",
        "title": "Welcome to BlaBló",
        "description": "Your journey to English fluency starts here",
        "type": "information",
        "required": true,
        "completed": false
      },
      {
        "id": "language_selection",
        "title": "Select Your Native Language",
        "description": "This will help us customize your learning experience",
        "type": "selection",
        "required": true,
        "completed": false,
        "options": [
          {
            "id": "vi",
            "name": "Tiếng Việt",
            "icon": "https://storage.blablo.app/flags/vietnam.png"
          },
          {
            "id": "en",
            "name": "English",
            "icon": "https://storage.blablo.app/flags/usa.png"
          },
          {
            "id": "ja",
            "name": "日本語",
            "icon": "https://storage.blablo.app/flags/japan.png"
          },
          {
            "id": "ko",
            "name": "한국어",
            "icon": "https://storage.blablo.app/flags/korea.png"
          }
        ]
      },
      {
        "id": "proficiency_test",
        "title": "English Level Assessment",
        "description": "Let's find out your current English level",
        "type": "test",
        "required": true,
        "completed": false
      },
      {
        "id": "learning_goals",
        "title": "Set Your Learning Goals",
        "description": "What do you want to achieve?",
        "type": "multi_selection",
        "required": true,
        "completed": false,
        "options": [
          {
            "id": "travel",
            "name": "Travel",
            "icon": "https://storage.blablo.app/icons/travel.png"
          },
          {
            "id": "business",
            "name": "Business",
            "icon": "https://storage.blablo.app/icons/business.png"
          },
          {
            "id": "academic",
            "name": "Academic",
            "icon": "https://storage.blablo.app/icons/academic.png"
          },
          {
            "id": "daily_life",
            "name": "Daily Life",
            "icon": "https://storage.blablo.app/icons/daily.png"
          }
        ]
      },
      {
        "id": "daily_goal",
        "title": "Set Your Daily Goal",
        "description": "How many minutes can you study each day?",
        "type": "slider",
        "required": true,
        "completed": false,
        "options": [
          {
            "id": "5",
            "name": "5 minutes",
            "value": 5
          },
          {
            "id": "10",
            "name": "10 minutes",
            "value": 10
          },
          {
            "id": "15",
            "name": "15 minutes",
            "value": 15
          },
          {
            "id": "30",
            "name": "30 minutes",
            "value": 30
          }
        ]
      },
      {
        "id": "account_creation",
        "title": "Create Your Account",
        "description": "Save your progress and access all features",
        "type": "account",
        "required": false,
        "completed": false
      }
    ],
    "currentStep": "welcome"
  }
}
```

## Update Onboarding Step

```
POST /api/onboarding/step/{stepId}
```

**Headers:**
```
Content-Type: application/json
user_id: <device_id>
```

**Request Body:**
```json
{
  "completed": true,
  "selection": "vi"  // Required for selection type steps
}
```

**Response:**
```json
{
  "message": "Onboarding step updated",
  "data": {
    "stepId": "language_selection",
    "completed": true,
    "nextStep": "proficiency_test"
  }
}
```

## Get Proficiency Test

```
GET /api/onboarding/proficiency-test
```

**Headers:**
```
Content-Type: application/json
user_id: <device_id>
```

**Response:**
```json
{
  "data": {
    "id": "initial-test",
    "title": "English Level Assessment",
    "description": "Answer these questions to determine your English level",
    "questions": [
      {
        "id": "q1",
        "text": "Choose the correct sentence:",
        "type": "multiple_choice",
        "options": [
          {
            "id": "a",
            "text": "She don't like coffee."
          },
          {
            "id": "b",
            "text": "She doesn't like coffee."
          },
          {
            "id": "c",
            "text": "She not like coffee."
          }
        ],
        "level": "A1"
      },
      {
        "id": "q2",
        "text": "Complete the sentence: 'If I had more time, I ____ a new language.'",
        "type": "multiple_choice",
        "options": [
          {
            "id": "a",
            "text": "will learn"
          },
          {
            "id": "b",
            "text": "would learn"
          },
          {
            "id": "c",
            "text": "would have learned"
          }
        ],
        "level": "B1"
      }
    ],
    "totalQuestions": 15
  }
}
```

## Submit Proficiency Test

```
POST /api/onboarding/proficiency-test/submit
```

**Headers:**
```
Content-Type: application/json
user_id: <device_id>
```

**Request Body:**
```json
{
  "answers": [
    {
      "questionId": "q1",
      "answerId": "b"
    },
    {
      "questionId": "q2",
      "answerId": "b"
    }
  ]
}
```

**Response:**
```json
{
  "message": "Proficiency test completed",
  "data": {
    "level": "A2",
    "description": "Basic user - Elementary",
    "nextStep": "learning_goals",
    "recommendations": [
      {
        "id": "story-1",
        "title": "A Day at the Beach",
        "type": "story",
        "level": "A2"
      },
      {
        "id": "quest-1",
        "title": "Introductions",
        "type": "quest",
        "level": "A2"
      }
    ]
  }
}
```

## Complete Onboarding

```
POST /api/onboarding/complete
```

**Headers:**
```
Content-Type: application/json
user_id: <device_id>
Authorization: Bearer <token>  // If user registered
```

**Response:**
```json
{
  "message": "Onboarding completed successfully",
  "data": {
    "userId": "user-123",
    "completedAt": "2025-06-08T11:30:00Z",
    "level": "A2",
    "goals": ["travel", "daily_life"],
    "dailyGoal": 15,
    "recommendedStories": [
      {
        "id": 1,
        "title": "A Day at the Beach",
        "level": "A2"
      }
    ],
    "recommendedQuests": [
      {
        "id": "quest-1",
        "title": "Introductions",
        "level": "A2"
      }
    ]
  }
}
```

## Get Onboarding Status

```
GET /api/onboarding/status
```

**Headers:**
```
Content-Type: application/json
user_id: <device_id>
```

**Response:**
```json
{
  "data": {
    "completed": false,
    "progress": 60,
    "completedSteps": [
      "welcome",
      "language_selection",
      "proficiency_test"
    ],
    "currentStep": "learning_goals",
    "remainingSteps": [
      "learning_goals",
      "daily_goal",
      "account_creation"
    ]
  }
}
```

## Skip Onboarding

```
POST /api/onboarding/skip
```

**Headers:**
```
Content-Type: application/json
user_id: <device_id>
```

**Response:**
```json
{
  "message": "Onboarding skipped",
  "data": {
    "defaultLevel": "A1",
    "defaultGoals": ["daily_life"],
    "defaultDailyGoal": 10,
    "skipTime": "2025-06-08T11:45:00Z"
  }
}
```
