# Can-Do Journey API Endpoints

Tài liệu này mô tả các API endpoint liên quan đến tính năng Can-Do Journey trong BlaBló App.

## Get User Journey

```
GET /api/cando/journey
```

**Headers:**
```
Content-Type: application/json
Authorization: Bearer <token>
```

**Response:**
```json
{
  "userId": "user-123",
  "currentLevel": "A1",
  "progress": 45,
  "levels": [
    {
      "name": "A1",
      "description": "Basic user - Beginner",
      "progress": 45,
      "skills": [
        {
          "name": "Listening",
          "progress": 60,
          "statements": [
            {
              "id": "a1-l1",
              "description": "I can understand simple questions about myself when people speak slowly and clearly.",
              "completed": true,
              "quests": [
                {
                  "id": "quest-1",
                  "title": "Introductions",
                  "type": "Listening",
                  "completed": true
                }
              ]
            },
            {
              "id": "a1-l2",
              "description": "I can understand simple directions about how to get from X to Y on foot or by public transport.",
              "completed": false,
              "quests": [
                {
                  "id": "quest-2",
                  "title": "City Navigation",
                  "type": "Listening",
                  "completed": false
                }
              ]
            }
          ]
        },
        {
          "name": "Reading",
          "progress": 40,
          "statements": []
        }
      ]
    }
  ]
}
```

## Complete Quest

```
POST /api/cando/quest/{questId}/complete
```

**Headers:**
```
Content-Type: application/json
Authorization: Bearer <token>
```

**Response:**
```json
{
  "success": true,
  "message": "Quest completed successfully",
  "updatedJourney": {
    "userId": "user-123",
    "currentLevel": "A1",
    "progress": 50,
    "levels": [
      {
        "name": "A1",
        "description": "Basic user - Beginner",
        "progress": 50
      }
    ]
  },
  "rewards": {
    "xp": 50,
    "badges": [
      {
        "id": "first-directions",
        "name": "Direction Master",
        "description": "Completed your first directions quest",
        "imageUrl": "https://storage.blablo.app/badges/directions.png"
      }
    ]
  }
}
```

## Get Available Quests

```
GET /api/cando/quests
```

**Headers:**
```
Content-Type: application/json
Authorization: Bearer <token>
```

**Query Parameters:**
- `level` (optional): Filter quests by CEFR level (A1, A2, B1, etc.)
- `skill` (optional): Filter quests by skill (Listening, Reading, Speaking, Writing)
- `completed` (optional): Filter by completion status (true/false)

**Response:**
```json
{
  "data": [
    {
      "id": "quest-1",
      "title": "Introductions",
      "description": "Practice introducing yourself and understanding introductions from others",
      "type": "Listening",
      "level": "A1",
      "duration": 10,
      "xpReward": 50,
      "completed": true,
      "statement": {
        "id": "a1-l1",
        "description": "I can understand simple questions about myself when people speak slowly and clearly."
      }
    },
    {
      "id": "quest-2",
      "title": "City Navigation",
      "description": "Learn how to understand and give directions in a city",
      "type": "Listening",
      "level": "A1",
      "duration": 15,
      "xpReward": 60,
      "completed": false,
      "statement": {
        "id": "a1-l2",
        "description": "I can understand simple directions about how to get from X to Y on foot or by public transport."
      }
    },
    {
      "id": "quest-3",
      "title": "Restaurant Orders",
      "description": "Practice ordering food in a restaurant",
      "type": "Speaking",
      "level": "A1",
      "duration": 12,
      "xpReward": 55,
      "completed": false,
      "statement": {
        "id": "a1-s1",
        "description": "I can order food and drinks using simple expressions."
      }
    }
  ]
}
```

## Get Quest Details

```
GET /api/cando/quest/{questId}
```

**Headers:**
```
Content-Type: application/json
Authorization: Bearer <token>
```

**Response:**
```json
{
  "id": "quest-2",
  "title": "City Navigation",
  "description": "Learn how to understand and give directions in a city",
  "type": "Listening",
  "level": "A1",
  "duration": 15,
  "xpReward": 60,
  "completed": false,
  "statement": {
    "id": "a1-l2",
    "description": "I can understand simple directions about how to get from X to Y on foot or by public transport."
  },
  "content": {
    "scenario": "You are a tourist in London and need to find your way to the British Museum.",
    "tasks": [
      {
        "type": "listen",
        "audioUrl": "https://storage.blablo.app/quests/city_navigation/directions1.mp3",
        "question": "Which direction should you go first?",
        "options": ["Left", "Right", "Straight ahead"],
        "correctAnswer": "Right"
      },
      {
        "type": "listen",
        "audioUrl": "https://storage.blablo.app/quests/city_navigation/directions2.mp3",
        "question": "How many streets do you need to cross?",
        "options": ["1", "2", "3"],
        "correctAnswer": "2"
      },
      {
        "type": "speak",
        "prompt": "Ask someone how to get to the British Museum.",
        "expectedPhrases": [
          "Excuse me, how do I get to the British Museum?",
          "Could you tell me the way to the British Museum?",
          "Which way is the British Museum?"
        ]
      }
    ]
  }
}
```

## Get CEFR Levels

```
GET /api/cando/levels
```

**Headers:**
```
Content-Type: application/json
Authorization: Bearer <token>
```

**Response:**
```json
{
  "data": [
    {
      "name": "A1",
      "description": "Basic user - Beginner",
      "skills": [
        {
          "name": "Listening",
          "statements": [
            {
              "id": "a1-l1",
              "description": "I can understand simple questions about myself when people speak slowly and clearly."
            },
            {
              "id": "a1-l2",
              "description": "I can understand simple directions about how to get from X to Y on foot or by public transport."
            }
          ]
        },
        {
          "name": "Reading",
          "statements": [
            {
              "id": "a1-r1",
              "description": "I can understand simple forms well enough to give basic personal details."
            }
          ]
        }
      ]
    },
    {
      "name": "A2",
      "description": "Basic user - Elementary",
      "skills": []
    }
  ]
}
```

## Update User Level

```
PUT /api/cando/level
```

**Headers:**
```
Content-Type: application/json
Authorization: Bearer <token>
```

**Request Body:**
```json
{
  "level": "A2"
}
```

**Response:**
```json
{
  "message": "Level updated successfully",
  "data": {
    "userId": "user-123",
    "previousLevel": "A1",
    "currentLevel": "A2",
    "updatedAt": "2025-06-08T16:30:00Z"
  }
}
```
