# Clean Architecture Implementation in BlaBló App

## Introduction

This document explains how Clean Architecture principles are implemented in the BlaBló app, with a specific focus on the Vocabulary Feature. Clean Architecture, proposed by Robert C. Martin (Uncle Bob), divides the codebase into concentric layers with clear dependencies pointing inward.

## Clean Architecture Layers

The BlaBló app is structured into the following layers:

1. **Domain Layer** (Core Business Logic)
2. **Data Layer** (Data Access)
3. **Presentation Layer** (UI and User Interaction)
4. **Core Layer** (Common Utilities and Dependencies)

### Layer Dependencies

The key principle of Clean Architecture is the dependency rule: source code dependencies can only point inward. This means:

- **Domain Layer** has no dependencies on other layers
- **Data Layer** depends only on the Domain Layer
- **Presentation Layer** depends on the Domain Layer (and sometimes on the Data Layer)
- **Core Layer** provides utilities used by all layers

## Domain Layer

The Domain Layer contains the core business logic and entities of the application. It's independent of any external frameworks or UI.

### Entities

Entities are the core business objects of the application. They encapsulate the most general and high-level rules.

Example: `VocabularyWord` entity

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

### Repository Interfaces

Repository interfaces define the contract for data operations. They are defined in the Domain Layer but implemented in the Data Layer.

Example: `VocabularyRepository` interface

```dart
// lib/domain/repositories/vocabulary_repository.dart
abstract class VocabularyRepository {
  Future<Either<Failure, List<VocabularyLesson>>> getVocabularyLessons();
}
```

### Use Cases

Use cases represent the business actions or operations that can be performed in the application. They orchestrate the flow of data to and from entities and implement business rules.

Example: `GetVocabularyLessonsUseCase`

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

Data sources are responsible for fetching data from a specific source (local database, remote API, etc.).

Example: `VocabularyLocalDataSource`

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
      // Mock data...
    ];
  }
}
```

### Repository Implementations

Repository implementations connect the data sources to the domain layer by implementing the repository interfaces.

Example: `VocabularyRepositoryImpl`

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

### Models

Models are data objects that extend entities from the domain layer. They add data layer specific functionality like JSON serialization.

In the Vocabulary Feature, we're using entities directly as models for simplicity, but in a more complex application, we would have separate model classes:

```dart
// Example of what a model might look like
class VocabularyWordModel extends VocabularyWord {
  VocabularyWordModel({
    required String word,
    required String pronunciation,
    required String definition,
    required List<String> examples,
  }) : super(
          word: word,
          pronunciation: pronunciation,
          definition: definition,
          examples: examples,
        );

  factory VocabularyWordModel.fromJson(Map<String, dynamic> json) {
    return VocabularyWordModel(
      word: json['word'],
      pronunciation: json['pronunciation'],
      definition: json['definition'],
      examples: List<String>.from(json['examples']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'word': word,
      'pronunciation': pronunciation,
      'definition': definition,
      'examples': examples,
    };
  }
}
```

## Presentation Layer

The Presentation Layer handles UI and user interactions. It uses the BLoC pattern for state management.

### BLoC (Business Logic Component)

BLoCs manage the state of the UI and handle user interactions. They communicate with use cases to perform business operations.

Example: `VocabularyBloc`

```dart
// lib/presentation/bloc/vocabulary_bloc.dart
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

### Pages

Pages are the main screens of the application. They use BLoCs to manage state and display UI components.

Example: `HomeScreen`

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

  // Implementation details...
}
```

### Widgets

Widgets are reusable UI components. They are organized into common (shared across features) and specific (feature-specific) widgets.

Example: `VocabularyCard`

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
    // Implementation details...
  }
}
```

## Core Layer

The Core Layer contains code that is used across the entire application and doesn't fit into any specific feature.

### Constants

Constants are values that are used throughout the application.

Example: `AppConstants`

```dart
// lib/core/constants/app_constants.dart
class AppConstants {
  static const String appName = 'BlaBló';
  static const String baseUrl = 'https://api.example.com';
  static const String imagePath = 'assets/images/';
}
```

### Theme

Theme defines the visual appearance of the application.

Example: `AppTheme`

```dart
// lib/core/theme/app_theme.dart
class AppTheme {
  // Colors
  static const Color primaryColor = Color(0xFFFF44CC);
  static const Color secondaryColor = Color(0xFF03DAC6);
  
  // Theme Data
  static ThemeData get lightTheme {
    // Implementation details...
  }
}
```

### Error Handling

Error handling code defines how errors are represented and handled in the application.

Example: `Failure`

```dart
// lib/core/error/failures.dart
abstract class Failure {
  List<Object> get props => [];
}

class ServerFailure extends Failure {}

class CacheFailure extends Failure {}
```

### Dependency Injection

Dependency injection code sets up the dependencies for the application.

Example: `injection_container.dart`

```dart
// lib/core/di/injection_container.dart
final sl = GetIt.instance;

Future<void> init() async {
  // Features - Vocabulary
  _initVocabularyFeature();
  
  // Core
  
  // External
}

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

## Benefits of Clean Architecture

The implementation of Clean Architecture in the BlaBló app provides several benefits:

1. **Separation of Concerns**: Each layer has a clear responsibility, making the code easier to understand and maintain.

2. **Testability**: Business logic is separated from UI and external dependencies, making it easier to write unit tests.

3. **Independence of Frameworks**: The core business logic is independent of UI frameworks, databases, or external APIs.

4. **Flexibility**: UI and data sources can be changed without affecting business logic.

5. **Scalability**: New features can be added without modifying existing code.

## Conclusion

The BlaBló app follows Clean Architecture principles to create a maintainable, testable, and scalable codebase. By separating concerns into distinct layers with clear dependencies, the application can evolve over time while maintaining code quality and developer productivity.
