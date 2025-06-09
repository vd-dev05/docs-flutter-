# Story API Endpoints

Tài liệu này mô tả các API endpoint liên quan đến tính năng Story trong BlaBló App.

## Get Stories List

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

## Get Story by ID

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

## Delete Story

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

## Create Story

```
POST /api/playlists
```

**Headers:**
```
Content-Type: application/json
user_id: <device_id>
```

**Request Body:**
```json
{
  "title": "My Custom Story",
  "description": "A story I created to practice English",
  "category": "Custom",
  "level": "Intermediate",
  "duration": 200,
  "content": "Once upon a time in a small village...",
  "vocabulary": [
    {
      "word": "village",
      "definition": "A small community in a rural area",
      "examples": [
        "The village was surrounded by beautiful mountains."
      ]
    }
  ],
  "conversation": [
    {
      "speaker": "Narrator",
      "text": "Once upon a time in a small village...",
      "startTime": 0.0,
      "endTime": 4.0
    }
  ]
}
```

**Response:**
```json
{
  "message": "Story created successfully",
  "data": {
    "id": 3,
    "title": "My Custom Story",
    "description": "A story I created to practice English",
    "category": "Custom",
    "level": "Intermediate",
    "duration": 200,
    "imageUrl": null,
    "audioUrl": null,
    "content": "Once upon a time in a small village...",
    "vocabulary": [
      {
        "word": "village",
        "definition": "A small community in a rural area",
        "examples": [
          "The village was surrounded by beautiful mountains."
        ]
      }
    ],
    "conversation": [
      {
        "speaker": "Narrator",
        "text": "Once upon a time in a small village...",
        "startTime": 0.0,
        "endTime": 4.0
      }
    ]
  }
}
```

## Update Story

```
PUT /api/playlists/{id}
```

**Headers:**
```
Content-Type: application/json
user_id: <device_id>
```

**Request Body:**
```json
{
  "title": "Updated Story Title",
  "description": "Updated story description",
  "category": "Custom",
  "level": "Intermediate"
}
```

**Response:**
```json
{
  "message": "Story updated successfully",
  "data": {
    "id": 3,
    "title": "Updated Story Title",
    "description": "Updated story description",
    "category": "Custom",
    "level": "Intermediate",
    "duration": 200,
    "imageUrl": null,
    "audioUrl": null
  }
}
```

## Mark Story as Favorite

```
POST /api/playlists/{id}/favorite
```

**Headers:**
```
Content-Type: application/json
user_id: <device_id>
```

**Request Body:**
```json
{
  "isFavorite": true
}
```

**Response:**
```json
{
  "message": "Story marked as favorite",
  "data": {
    "id": 1,
    "isFavorite": true
  }
}
```

## Mark Story as Completed

```
POST /api/playlists/{id}/complete
```

**Headers:**
```
Content-Type: application/json
user_id: <device_id>
```

**Response:**
```json
{
  "message": "Story marked as completed",
  "data": {
    "id": 1,
    "completed": true,
    "completedAt": "2025-06-08T14:30:00Z"
  },
  "rewards": {
    "xp": 50,
    "badges": []
  }
}
```
