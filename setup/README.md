# Setup & Configuration Guide

## Development Environment

### Prerequisites

1. Flutter SDK 3.x
2. Android Studio / VS Code
3. Git
4. Node.js (for mock API)

### IDE Setup 

1. VS Code Extensions
   - Flutter
   - Dart
   - Flutter Widget Snippets

2. Android Studio Plugins
   - Flutter
   - Dart

## Dependencies

Key dependencies trong `pubspec.yaml`:

```yaml
dependencies:
  flutter_bloc: ^8.1.3 # State management
  get_it: ^7.6.4 # Dependency injection  
  equatable: ^2.0.5 # Value equality
  dartz: ^0.10.1 # Functional programming
  http: ^1.1.0 # HTTP client
```

## Environment Variables

File `.env` configuration:

```bash
# API Endpoints
STORY_API_URL=https://mocapiblablo-production.up.railway.app/api/playlists
USER_API_URL=https://api.example.com/users

# Authentication  
SUPABASE_URL=https://hoqqpmbfjvslhohcwgij.supabase.co
SUPABASE_ANON_KEY=xxx

# Third Party
GOOGLE_SERVER_CLIENT_ID=xxx
```

## Build & Deployment

### Development Build

```bash
flutter run
```

### Production Build

```bash
flutter build apk --release
flutter build ios --release
```

### CI/CD

- GitHub Actions workflow
- Automatic testing
- Deploy to Firebase App Distribution

## Common Issues

1. Missing environment variables
2. Android SDK setup
3. iOS certificates
4. Network configuration

## Firebase Setup

1. Create Firebase project
2. Add Android/iOS apps
3. Download config files
4. Enable services:
   - Authentication
   - Firestore
   - Storage
