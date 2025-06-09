# English Learning Feature

## Overview
The English Learning feature provides users with interactive lessons to improve their English language skills. Each lesson includes vocabulary with definitions and examples, conversation dialogs between characters, and audio playback with text highlighting.

## Architecture
The implementation follows Clean Architecture principles with three main layers:

### Domain Layer
- **Entities**: `StoryEntity`, `VocabularyEntity`, and `ConversationPartEntity` represent the core business objects
- **Repository Interface**: `StoryLessonRepository` defines the contract for data access
- **Use Case**: `GetStoryUseCase` implements the business logic for retrieving story lessons

### Data Layer
- **Data Models**: `StoryLessonModel` maps external data to domain entities
- **Data Source**: `StoryLessonRemoteDataSource` fetches data from the API
- **Repository Implementation**: `StoryLessonRepositoryImpl` implements the repository interface

### Presentation Layer
- **ViewModel**: `StoryLessonViewModel` manages state with Riverpod
- **UI Components**: 
  - `VocabCard` displays vocabulary items
  - `ConversationView` displays conversation dialogs
  - `AudioControlBar` provides audio playback controls
  - `HomeLessonStory` main screen that combines all components

## Core Utilities
- **AudioPlayerHelper**: Manages audio playback functionality
- **TextHighlighter**: Handles text highlighting during playback

## State Management
The feature uses Riverpod for state management with the following components:
- `StoryLessonState`: Data class for the state
- `StoryLessonViewModel`: StateNotifier that manages the state
- Providers defined in `story_lesson_providers.dart`

## API Integration
The feature communicates with a backend API to:
- Fetch story lessons with vocabulary and conversation data
- Stream audio content

## Navigation
The feature is accessible from the bottom navigation bar in the main app.

## Future Improvements
- Add offline support for lesson content
- Implement interactive exercises
- Support bookmarking and progress tracking
- Add multiple language support