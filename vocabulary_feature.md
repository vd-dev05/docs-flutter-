# Vocabulary Feature Documentation

## Overview

The Vocabulary Feature is a core component of the BlaBló app that helps users learn new vocabulary words through contextual conversations. This document provides a detailed explanation of how this feature is implemented following Clean Architecture principles.

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Domain Layer](#domain-layer)
3. [Data Layer](#data-layer)
4. [Presentation Layer](#presentation-layer)
5. [Dependency Injection](#dependency-injection)
6. [UI Components](#ui-components)
7. [Data Flow](#data-flow)

## Architecture Overview

The Vocabulary Feature follows Clean Architecture principles, which divides the codebase into distinct layers:

- **Domain Layer**: Contains business entities and use cases
- **Data Layer**: Handles data retrieval and storage
- **Presentation Layer**: Manages UI and user interactions

This separation ensures that business logic is independent of UI and external frameworks, making the code more maintainable, testable, and scalable.

## Domain Layer

The Domain Layer contains the core business logic and entities, independent of any external frameworks.

### Entities

#### VocabularyWord

```dart
// lib/domain/entities/vocabulary_word.dart
class VocabularyWord {
  final String word;
  final String pronunciation;
  final String definition;
  final List<String> examples;

  VocabularyWord({
    required this.word,
    required this.pronunciation,
    required this.definition,
    required this.examples,
  });
}
```

#### ConversationMessage

```dart
// lib/domain/entities/conversation_message.dart
enum Speaker { hiro, luna }

class ConversationMessage {
  final Speaker speaker;
  final String message;
  final List<HighlightedWord> highlightedWords;

  ConversationMessage({
    required this.speaker,
    required this.message,
    this.highlightedWords = const [],
  });
}

class HighlightedWord {
  final String word;
  final String definition;

  HighlightedWord({
    required this.word,
    required this.definition,
  });
}
```

#### VocabularyLesson

```dart
// lib/domain/entities/vocabulary_lesson.dart
class VocabularyLesson {
  final VocabularyWord word;
  final List<ConversationMessage> conversation;
  final String topic;

  VocabularyLesson({
    required this.word,
    required this.conversation,
    required this.topic,
  });
}
```

### Repository Interfaces

```dart
// lib/domain/repositories/vocabulary_repository.dart
abstract class VocabularyRepository {
  Future<Either<Failure, List<VocabularyLesson>>> getVocabularyLessons();
}
```

### Use Cases

```dart
// lib/domain/usecases/get_vocabulary_lessons_usecase.dart
class GetVocabularyLessonsUseCase {
  final VocabularyRepository repository;

  GetVocabularyLessonsUseCase(this.repository);

  Future<Either<Failure, List<VocabularyLesson>>> call() {
    return repository.getVocabularyLessons();
  }
}
```

## Data Layer

The Data Layer is responsible for data retrieval and storage. It implements the repository interfaces defined in the Domain Layer.

### Data Sources

```dart
// lib/data/datasources/local/vocabulary_local_datasource.dart
abstract class VocabularyLocalDataSource {
  Future<List<VocabularyLesson>> getVocabularyLessons();
}

class VocabularyLocalDataSourceImpl implements VocabularyLocalDataSource {
  @override
  Future<List<VocabularyLesson>> getVocabularyLessons() async {
    // Implementation with mock data
    return [
      VocabularyLesson(
        word: VocabularyWord(
          word: 'Spare',
          pronunciation: '/speər/, sounds like "spair"',
          definition: 'Extra; Available to use or lend',
          examples: [
            'Do you have a spare pen I could borrow?',
            'I always carry a spare key in my bag.',
          ],
        ),
        conversation: [
          ConversationMessage(
            speaker: Speaker.hiro,
            message: 'Hey Luna, got a spare minute?',
            highlightedWords: [
              HighlightedWord(
                word: 'spare',
                definition: 'Extra; Available to use or lend',
              ),
            ],
          ),
          // Additional messages...
        ],
        topic: 'Borrowing printer paper',
      ),
      // Additional lessons...
    ];
  }
}
```

### Repository Implementations

```dart
// lib/data/repositories/vocabulary_repository_impl.dart
class VocabularyRepositoryImpl implements VocabularyRepository {
  final VocabularyLocalDataSource localDataSource;

  VocabularyRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<VocabularyLesson>>> getVocabularyLessons() async {
    try {
      final lessons = await localDataSource.getVocabularyLessons();
      return Right(lessons);
    } catch (e) {
      return Left(CacheFailure());
    }
  }
}
```

## Presentation Layer

The Presentation Layer handles UI and user interactions. It uses the BLoC pattern for state management.

### BLoC (Business Logic Component)

```dart
// lib/presentation/bloc/vocabulary_bloc.dart
// Events
abstract class VocabularyEvent extends Equatable {
  const VocabularyEvent();
  
  @override
  List<Object> get props => [];
}

class GetVocabularyLessonsEvent extends VocabularyEvent {
  const GetVocabularyLessonsEvent();
}

// States
abstract class VocabularyState extends Equatable {
  const VocabularyState();
  
  @override
  List<Object> get props => [];
}

class VocabularyInitial extends VocabularyState {}

class VocabularyLoading extends VocabularyState {}

class VocabularyLoaded extends VocabularyState {
  final List<VocabularyLesson> lessons;
  final int currentLessonIndex;

  const VocabularyLoaded({
    required this.lessons,
    this.currentLessonIndex = 0,
  });

  VocabularyLesson get currentLesson => lessons[currentLessonIndex];

  @override
  List<Object> get props => [lessons, currentLessonIndex];

  VocabularyLoaded copyWith({
    List<VocabularyLesson>? lessons,
    int? currentLessonIndex,
  }) {
    return VocabularyLoaded(
      lessons: lessons ?? this.lessons,
      currentLessonIndex: currentLessonIndex ?? this.currentLessonIndex,
    );
  }
}

class VocabularyError extends VocabularyState {
  final String message;

  const VocabularyError({required this.message});

  @override
  List<Object> get props => [message];
}

// Bloc
class VocabularyBloc extends Bloc<VocabularyEvent, VocabularyState> {
  final GetVocabularyLessonsUseCase getVocabularyLessonsUseCase;

  VocabularyBloc({required this.getVocabularyLessonsUseCase})
      : super(VocabularyInitial()) {
    on<GetVocabularyLessonsEvent>(_onGetVocabularyLessons);
  }

  Future<void> _onGetVocabularyLessons(
    GetVocabularyLessonsEvent event,
    Emitter<VocabularyState> emit,
  ) async {
    emit(VocabularyLoading());
    final result = await getVocabularyLessonsUseCase();
    result.fold(
      (failure) => emit(const VocabularyError(message: 'Failed to load vocabulary lessons')),
      (lessons) => emit(VocabularyLoaded(lessons: lessons)),
    );
  }
}
```

### UI Components

#### Home Screen

```dart
// lib/presentation/pages/home/home_screen.dart
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<VocabularyBloc>().add(const GetVocabularyLessonsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocBuilder<VocabularyBloc, VocabularyState>(
        builder: (context, state) {
          if (state is VocabularyLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is VocabularyLoaded) {
            return _buildContent(context, state);
          } else if (state is VocabularyError) {
            return Center(child: Text(state.message));
          } else {
            return const Center(child: Text('Start learning vocabulary'));
          }
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, VocabularyLoaded state) {
    final lesson = state.currentLesson;
    
    return Column(
      children: [
        // Status bar area
        _buildStatusBar(),
        
        // Main content
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Vocabulary card
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: VocabularyCard(
                    word: lesson.word,
                    onPlayAudio: () {},
                    onBookmark: () {},
                  ),
                ),
                
                // Page indicator
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: const PageIndicator(
                    currentPage: 0,
                    pageCount: 3,
                  ),
                ),
                
                // Conversation
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: lesson.conversation.map((message) {
                      return ConversationBubble(
                        message: message,
                        onWordTap: () {},
                      );
                    }).toList(),
                  ),
                ),
                
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        
        // Bottom action bar
        LessonActionBar(
          onRepeat: () {},
          onSave: () {},
          onShare: () {},
          onWhisper: () {},
        ),
        
        // Request card
        RequestCard(
          title: 'Borrowing printer paper',
          subtitle: 'Office Requests',
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildStatusBar() {
    // Implementation details...
  }
}
```

## Dependency Injection

Dependency Injection is used to provide dependencies to different components of the application. This is implemented using the `get_it` package.

```dart
// lib/core/di/injection_container.dart
void _initVocabularyFeature() {
  // Bloc
  sl.registerFactory(() => VocabularyBloc(getVocabularyLessonsUseCase: sl()));

  // Use cases
  sl.registerLazySingleton(() => GetVocabularyLessonsUseCase(sl()));

  // Repository
  sl.registerLazySingleton<VocabularyRepository>(
    () => VocabularyRepositoryImpl(localDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<VocabularyLocalDataSource>(
    () => VocabularyLocalDataSourceImpl(),
  );
}
```

## UI Components

### VocabularyCard

The `VocabularyCard` widget displays a vocabulary word with its pronunciation, definition, and examples.

```dart
// lib/presentation/widgets/specific/vocabulary_card.dart
class VocabularyCard extends StatelessWidget {
  final VocabularyWord word;
  final VoidCallback onPlayAudio;
  final VoidCallback onBookmark;

  const VocabularyCard({
    Key? key,
    required this.word,
    required this.onPlayAudio,
    required this.onBookmark,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: const Color(0xFF6C5CE7), // Purple color
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row with word and action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  word.word,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Action buttons...
              ],
            ),
            
            // Pronunciation, definition, examples...
          ],
        ),
      ),
    );
  }
}
```

### ConversationBubble

The `ConversationBubble` widget displays a message in a conversation with highlighted words.

```dart
// lib/presentation/widgets/specific/conversation_bubble.dart
class ConversationBubble extends StatelessWidget {
  final ConversationMessage message;
  final VoidCallback onWordTap;

  const ConversationBubble({
    Key? key,
    required this.message,
    required this.onWordTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isHiro = message.speaker == Speaker.hiro;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: isHiro ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isHiro) _buildAvatar('Hiro'),
          
          const SizedBox(width: 8),
          
          Flexible(
            child: Column(
              crossAxisAlignment: isHiro ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              children: [
                Text(
                  isHiro ? 'Hiro' : 'Luna',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                _buildMessageBubble(context, isHiro),
              ],
            ),
          ),
          
          const SizedBox(width: 8),
          
          if (!isHiro) _buildAvatar('Luna'),
        ],
      ),
    );
  }

  // Helper methods...
}
```

### Other UI Components

- **PageIndicator**: Shows the current page in a multi-page view
- **LessonActionBar**: Bottom action bar with repeat, save, share, and whisper buttons
- **RequestCard**: Bottom card showing the current topic

## Data Flow

1. **User opens the app**:
   - The `HomeScreen` is displayed
   - In `initState()`, the `GetVocabularyLessonsEvent` is dispatched to the `VocabularyBloc`

2. **VocabularyBloc processes the event**:
   - The bloc emits `VocabularyLoading` state
   - The `GetVocabularyLessonsUseCase` is called

3. **Use Case retrieves data**:
   - The use case calls the `VocabularyRepository`
   - The repository calls the `VocabularyLocalDataSource`
   - The data source returns mock vocabulary lessons

4. **Data flows back to the UI**:
   - The repository wraps the result in an `Either` type
   - The use case returns the result to the bloc
   - The bloc emits `VocabularyLoaded` state with the lessons
   - The UI rebuilds based on the new state

5. **User interacts with the UI**:
   - User can tap on highlighted words to see definitions
   - User can use the action bar to repeat, save, share, or whisper
   - User can tap on the request card to see more details

This data flow follows Clean Architecture principles, with clear separation of concerns between layers and dependencies pointing inward (UI → Presentation → Domain ← Data).

## Conclusion

The Vocabulary Feature is implemented following Clean Architecture principles, making it:

- **Maintainable**: Each component has a single responsibility
- **Testable**: Business logic is separated from UI and external dependencies
- **Scalable**: New features can be added without modifying existing code
- **Flexible**: UI and data sources can be changed without affecting business logic

This architecture ensures that the feature can evolve over time while maintaining code quality and developer productivity.
