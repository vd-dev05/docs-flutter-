# API Endpoints

Tài liệu này là tổng quan về các API endpoint chính được sử dụng trong BlaBló App.

**Lưu ý**: Tài liệu chi tiết về từng API endpoint đã được di chuyển vào thư mục `endpoints`. Vui lòng tham khảo các file sau để biết thêm chi tiết:

- [Story API Endpoints](./endpoints/story_endpoints.md)
- [Vocabulary API Endpoints](./endpoints/vocabulary_endpoints.md)
- [User API Endpoints](./endpoints/user_endpoints.md)
- [Can-Do Journey API Endpoints](./endpoints/cando_endpoints.md)
- [Onboarding API Endpoints](./endpoints/onboarding_endpoints.md)
- [API Endpoints Index](./endpoints/index.md)

Bên dưới là tóm tắt các endpoint phổ biến nhất trong ứng dụng.

## Story API Endpoints

### Get Stories List

```
GET /api/playlists
```

**Headers:**
```
Content-Type: application/json
user_id: <device_id>
```

**Response:**
```json
{
  "data": [
    {
      "id": 1,
      "title": "A Day at the Beach",
      "description": "Learn vocabulary about beach activities",
      "category": "Daily Life",
      "level": "Beginner",
      "duration": 180,
      "imageUrl": "https://storage.blablo.app/stories/beach_day.jpg",
      "audioUrl": "https://storage.blablo.app/audio/beach_day.mp3"
    },
    {
      "id": 2,
      "title": "The Restaurant",
      "description": "Practice ordering food and making reservations",
      "category": "Food & Dining",
      "level": "Intermediate",
      "duration": 240,
      "imageUrl": "https://storage.blablo.app/stories/restaurant.jpg",
      "audioUrl": "https://storage.blablo.app/audio/restaurant.mp3"
    }
  ]
}
```

### Get Story by ID

```
GET /api/playlists/{id}
```

**Headers:**
```
Content-Type: application/json
user_id: <device_id>
```

**Response:**
```json
{
  "id": 1,
  "title": "A Day at the Beach",
  "description": "Learn vocabulary about beach activities",
  "category": "Daily Life",
  "level": "Beginner",
  "duration": 180,
  "imageUrl": "https://storage.blablo.app/stories/beach_day.jpg",
  "audioUrl": "https://storage.blablo.app/audio/beach_day.mp3",
  "content": "It was a beautiful sunny day...",
  "vocabulary": [
    {
      "word": "sunscreen",
      "definition": "Cream or lotion that you put on your skin to protect it from the sun",
      "examples": [
        "Don't forget to put on sunscreen before going to the beach"
      ]
    },
    {
      "word": "towel",
      "definition": "A piece of thick cloth used for drying things",
      "examples": [
        "I forgot my towel, so I couldn't dry myself after swimming"
      ]
    }
  ],
  "conversation": [
    {
      "speaker": "Narrator",
      "text": "It was a beautiful sunny day when Sarah and Michael decided to go to the beach.",
      "startTime": 0.0,
      "endTime": 5.5
    },
    {
      "speaker": "Sarah",
      "text": "What a perfect day for the beach!",
      "startTime": 5.5,
      "endTime": 8.0
    },
    {
      "speaker": "Michael",
      "text": "Yes, it's gorgeous. Did you remember to bring the sunscreen?",
      "startTime": 8.0,
      "endTime": 12.0
    }
  ]
}
```

### Delete Story

```
DELETE /api/playlists/{id}
```

**Headers:**
```
Content-Type: application/json
user_id: <device_id>
```

**Response:**
```json
{
  "message": "Story deleted successfully",
  "data": [
    {
      "id": 2,
      "title": "The Restaurant",
      "description": "Practice ordering food and making reservations",
      "category": "Food & Dining",
      "level": "Intermediate",
      "duration": 240,
      "imageUrl": "https://storage.blablo.app/stories/restaurant.jpg",
      "audioUrl": "https://storage.blablo.app/audio/restaurant.mp3"
    }
  ]
}
```

## Vocabulary API Endpoints

### Get Vocabulary List

```
GET /api/vocabulary
```

**Headers:**
```
Content-Type: application/json
user_id: <device_id>
```

**Response:**
```json
{
  "data": [
    {
      "id": 1,
      "word": "sunscreen",
      "definition": "Cream or lotion that you put on your skin to protect it from the sun",
      "examples": [
        "Don't forget to put on sunscreen before going to the beach"
      ],
      "imageUrl": "https://storage.blablo.app/vocabulary/sunscreen.jpg",
      "audioUrl": "https://storage.blablo.app/audio/vocabulary/sunscreen.mp3",
      "category": "Beach",
      "level": "Beginner"
    },
    {
      "id": 2,
      "word": "reservation",
      "definition": "An arrangement to have something kept for you",
      "examples": [
        "I'd like to make a reservation for two people for dinner tonight"
      ],
      "imageUrl": "https://storage.blablo.app/vocabulary/reservation.jpg",
      "audioUrl": "https://storage.blablo.app/audio/vocabulary/reservation.mp3",
      "category": "Restaurant",
      "level": "Intermediate"
    }
  ]
}
```

### Add Vocabulary

```
POST /api/vocabulary
```

**Headers:**
```
Content-Type: application/json
user_id: <device_id>
```

**Request Body:**
```json
{
  "word": "beach towel",
  "definition": "A large towel for lying on at the beach",
  "examples": [
    "I spread my beach towel on the sand and lay down to get some sun"
  ],
  "category": "Beach",
  "level": "Beginner"
}
```

**Response:**
```json
{
  "message": "Vocabulary added successfully",
  "data": {
    "id": 3,
    "word": "beach towel",
    "definition": "A large towel for lying on at the beach",
    "examples": [
      "I spread my beach towel on the sand and lay down to get some sun"
    ],
    "imageUrl": null,
    "audioUrl": null,
    "category": "Beach",
    "level": "Beginner"
  }
}
```

## User API Endpoints

### User Registration

```
POST /api/auth/register
```

**Headers:**
```
Content-Type: application/json
```

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "SecurePassword123",
  "displayName": "John Doe"
}
```

**Response:**
```json
{
  "user": {
    "id": "user-123",
    "email": "user@example.com",
    "displayName": "John Doe",
    "createdAt": "2025-06-08T10:30:00Z"
  },
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

### User Login

```
POST /api/auth/login
```

**Headers:**
```
Content-Type: application/json
```

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "SecurePassword123"
}
```

**Response:**
```json
{
  "user": {
    "id": "user-123",
    "email": "user@example.com",
    "displayName": "John Doe",
    "createdAt": "2025-06-08T10:30:00Z",
    "lastLogin": "2025-06-08T14:45:00Z"
  },
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

## Can-Do Journey API Endpoints

### Get User Journey

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

### Complete Quest

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
