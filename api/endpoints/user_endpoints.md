# User API Endpoints

Tài liệu này mô tả các API endpoint liên quan đến quản lý người dùng và xác thực trong BlaBló App.

## User Registration

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

## User Login

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

## Social Login (Google)

```
POST /api/auth/social/google
```

**Headers:**
```
Content-Type: application/json
```

**Request Body:**
```json
{
  "idToken": "google-id-token-string",
  "displayName": "John Doe"  // Optional, will use Google profile name if not provided
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
    "lastLogin": "2025-06-08T14:45:00Z",
    "socialProvider": "google"
  },
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

## Social Login (Facebook)

```
POST /api/auth/social/facebook
```

**Headers:**
```
Content-Type: application/json
```

**Request Body:**
```json
{
  "accessToken": "facebook-access-token-string",
  "displayName": "John Doe"  // Optional, will use Facebook profile name if not provided
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
    "lastLogin": "2025-06-08T14:45:00Z",
    "socialProvider": "facebook"
  },
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

## Get User Profile

```
GET /api/user/profile
```

**Headers:**
```
Content-Type: application/json
Authorization: Bearer <token>
```

**Response:**
```json
{
  "id": "user-123",
  "email": "user@example.com",
  "displayName": "John Doe",
  "createdAt": "2025-06-08T10:30:00Z",
  "lastLogin": "2025-06-08T14:45:00Z",
  "profilePicture": "https://storage.blablo.app/profiles/user-123.jpg",
  "level": "A2",
  "xp": 1250,
  "achievements": [
    {
      "id": "first-week",
      "name": "First Week Complete",
      "description": "Completed your first week of learning",
      "awardedAt": "2025-06-15T10:30:00Z"
    }
  ],
  "settings": {
    "notifications": true,
    "dailyGoal": 15,
    "theme": "light"
  }
}
```

## Update User Profile

```
PUT /api/user/profile
```

**Headers:**
```
Content-Type: application/json
Authorization: Bearer <token>
```

**Request Body:**
```json
{
  "displayName": "Johnny Doe",
  "profilePicture": "base64-encoded-image-data"
}
```

**Response:**
```json
{
  "message": "Profile updated successfully",
  "data": {
    "id": "user-123",
    "email": "user@example.com",
    "displayName": "Johnny Doe",
    "profilePicture": "https://storage.blablo.app/profiles/user-123.jpg"
  }
}
```

## Update User Settings

```
PUT /api/user/settings
```

**Headers:**
```
Content-Type: application/json
Authorization: Bearer <token>
```

**Request Body:**
```json
{
  "notifications": false,
  "dailyGoal": 20,
  "theme": "dark"
}
```

**Response:**
```json
{
  "message": "Settings updated successfully",
  "data": {
    "notifications": false,
    "dailyGoal": 20,
    "theme": "dark"
  }
}
```

## Password Reset Request

```
POST /api/auth/password/reset-request
```

**Headers:**
```
Content-Type: application/json
```

**Request Body:**
```json
{
  "email": "user@example.com"
}
```

**Response:**
```json
{
  "message": "Password reset link sent to your email",
  "expiresAt": "2025-06-08T15:45:00Z"
}
```

## Reset Password

```
POST /api/auth/password/reset
```

**Headers:**
```
Content-Type: application/json
```

**Request Body:**
```json
{
  "token": "password-reset-token",
  "password": "NewSecurePassword123"
}
```

**Response:**
```json
{
  "message": "Password reset successfully",
  "user": {
    "id": "user-123",
    "email": "user@example.com"
  }
}
```

## Logout

```
POST /api/auth/logout
```

**Headers:**
```
Content-Type: application/json
Authorization: Bearer <token>
```

**Response:**
```json
{
  "message": "Logged out successfully"
}
```

## Delete Account

```
DELETE /api/user
```

**Headers:**
```
Content-Type: application/json
Authorization: Bearer <token>
```

**Request Body:**
```json
{
  "password": "CurrentPassword123"  // Required for email/password users
}
```

**Response:**
```json
{
  "message": "Account deleted successfully"
}
```
