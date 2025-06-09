# Vocabulary API Endpoints

Tài liệu này mô tả các API endpoint liên quan đến tính năng Vocabulary trong BlaBló App.

## Get Vocabulary List

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

## Add Vocabulary

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

## Get Vocabulary by ID

```
GET /api/vocabulary/{id}
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
  "word": "sunscreen",
  "definition": "Cream or lotion that you put on your skin to protect it from the sun",
  "examples": [
    "Don't forget to put on sunscreen before going to the beach"
  ],
  "imageUrl": "https://storage.blablo.app/vocabulary/sunscreen.jpg",
  "audioUrl": "https://storage.blablo.app/audio/vocabulary/sunscreen.mp3",
  "category": "Beach",
  "level": "Beginner",
  "relatedWords": [
    {
      "id": 5,
      "word": "sun lotion",
      "similarity": "synonym"
    }
  ]
}
```

## Update Vocabulary

```
PUT /api/vocabulary/{id}
```

**Headers:**
```
Content-Type: application/json
user_id: <device_id>
```

**Request Body:**
```json
{
  "definition": "Updated definition for the word",
  "examples": [
    "A new example sentence for this vocabulary word",
    "Another example showing usage"
  ]
}
```

**Response:**
```json
{
  "message": "Vocabulary updated successfully",
  "data": {
    "id": 1,
    "word": "sunscreen",
    "definition": "Updated definition for the word",
    "examples": [
      "A new example sentence for this vocabulary word",
      "Another example showing usage"
    ],
    "imageUrl": "https://storage.blablo.app/vocabulary/sunscreen.jpg",
    "audioUrl": "https://storage.blablo.app/audio/vocabulary/sunscreen.mp3",
    "category": "Beach",
    "level": "Beginner"
  }
}
```

## Delete Vocabulary

```
DELETE /api/vocabulary/{id}
```

**Headers:**
```
Content-Type: application/json
user_id: <device_id>
```

**Response:**
```json
{
  "message": "Vocabulary deleted successfully"
}
```

## Get Vocabulary by Category

```
GET /api/vocabulary/category/{categoryName}
```

**Headers:**
```
Content-Type: application/json
user_id: <device_id>
```

**Response:**
```json
{
  "category": "Beach",
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
      "level": "Beginner"
    },
    {
      "id": 3,
      "word": "beach towel",
      "definition": "A large towel for lying on at the beach",
      "examples": [
        "I spread my beach towel on the sand and lay down to get some sun"
      ],
      "imageUrl": null,
      "audioUrl": null,
      "level": "Beginner"
    }
  ]
}
```

## Mark Vocabulary as Learned

```
POST /api/vocabulary/{id}/learn
```

**Headers:**
```
Content-Type: application/json
user_id: <device_id>
```

**Response:**
```json
{
  "message": "Vocabulary marked as learned",
  "data": {
    "id": 1,
    "learned": true,
    "learnedAt": "2025-06-08T15:20:00Z"
  }
}
```
