# Features Documentation

## Story Feature

### Overview
Story feature cho phép users học tiếng Anh thông qua storytelling.

### Components
1. Story List Screen
   - Hiển thị danh sách stories
   - Swipe to delete
   - Sort/filter options

2. Story Detail Screen
   - Audio playback
   - Vocabulary highlights  
   - Interactive exercises

### Implementation
- Domain: `StoryEntity`, `VocabularyEntity`
- Data: `StoryRepository`, `StoryRemoteDataSource`
- UI: `StoryScreen`, `StoryDetailScreen`

## Authentication

### Supported Methods
1. Email/Password
2. Google Sign In
3. Facebook Sign In

### Implementation
- Supabase Authentication
- Social auth providers setup
- Secure token storage

## Vocabulary Feature

### Overview
Vocabulary learning through spaced repetition.

### Components
1. Word List
2. Flashcards
3. Practice Exercises

### Implementation
- `VocabularyRepository`
- Local storage with SQLite
- Sync with backend

## Can-do Journey

### Overview
Track learning progress through "can-do" statements.

### Components
1. Journey Map
2. Progress Tracking
3. Achievements

### Architecture
- Events tracking
- Progress persistence
- Achievements system
