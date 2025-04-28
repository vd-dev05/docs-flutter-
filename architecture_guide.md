# BlaBló App Architecture Guide

## Table of Contents
1. [Introduction](#introduction)
2. [Clean Architecture Overview](#clean-architecture-overview)
3. [Project Structure](#project-structure)
4. [Core Layer](#core-layer)
5. [Data Layer](#data-layer)
6. [Domain Layer](#domain-layer)
7. [Presentation Layer](#presentation-layer)
8. [Dependency Injection](#dependency-injection)
9. [State Management](#state-management)
10. [Navigation](#navigation)
11. [Best Practices](#best-practices)

## Introduction

BlaBló is a language learning app that helps users boost their speaking skills during everyday activities. This document provides a comprehensive guide to the application's architecture, explaining how the codebase is structured and how different components interact with each other.

## Clean Architecture Overview

The application follows the Clean Architecture pattern, which divides the codebase into layers with clear responsibilities:

![Clean Architecture Diagram](https://blog.cleancoder.com/uncle-bob/images/2012-08-13-the-clean-architecture/CleanArchitecture.jpg)

The key principles of Clean Architecture are:

1. **Independence of frameworks**: The architecture doesn't depend on the existence of some library or framework.
2. **Testability**: Business rules can be tested without UI, database, web server, or any external element.
3. **Independence of UI**: The UI can change easily without changing the rest of the system.
4. **Independence of Database**: Business rules are not bound to the database.
5. **Independence of any external agency**: Business rules don't know anything about the outside world.

## Project Structure

The project is organized into the following main directories:

```
lib/
├── core/
│   ├── constants/
│   ├── error/
│   ├── network/
│   ├── theme/
│   ├── utils/
│   └── di/
├── data/
│   ├── datasources/
│   │   ├── local/
│   │   └── remote/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
├── presentation/
│   ├── bloc/
│   ├── pages/
│   │   ├── home/
│   │   ├── onboarding/
│   │   └── auth/
│   └── widgets/
│       ├── common/
│       └── specific/
└── main.dart
```

## Core Layer

The Core layer contains code that is used across the entire application and doesn't fit into any specific feature.

### Constants

Located in `lib/core/constants/`, this directory contains constant values used throughout the app.

**Example: `app_constants.dart`**
```dart
class AppConstants {
  // App-wide constants
  static const String appName = 'BlaBló';
  
  // API endpoints
  static const String baseUrl = 'https://api.example.com';
  
  // Asset paths
  static const String imagePath = 'assets/images/';
}
```

### Error Handling

Located in `lib/core/error/`, this directory contains classes for error handling.

**Example: `failures.dart`**
```dart
abstract class Failure {
  List<Object> get props => [];
}

class ServerFailure extends Failure {}

class CacheFailure extends Failure {}
```

### Theme

Located in `lib/core/theme/`, this directory contains theme-related code.

**Example: `app_theme.dart`**
```dart
class AppTheme {
  // Colors
  static const Color primaryColor = Color(0xFFFF44CC);
  static const Color secondaryColor = Color(0xFF03DAC6);
  
  // Theme Data
  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
      ),
      // Other theme configurations
    );
  }
}
```

### Utilities

Located in `lib/core/utils/`, this directory contains utility functions.

**Example: `navigation_helper.dart`**
```dart
class NavigationHelper {
  static void navigateTo(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }
  
  // Other navigation methods
}
```

### Dependency Injection

Located in `lib/core/di/`, this directory contains code for dependency injection.

**Example: `injection_container.dart`**
```dart
final sl = GetIt.instance;

Future<void> init() async {
  // Features - Scenarios
  _initScenariosFeature();
  
  // Core
  
  // External
}

void _initScenariosFeature() {
  // Bloc
  sl.registerFactory(() => ScenariosBloc(getScenariosUseCase: sl()));

  // Use cases
  sl.registerLazySingleton(() => GetScenariosUseCase(sl()));

  // Repository
  sl.registerLazySingleton<ScenarioRepository>(
    () => ScenarioRepositoryImpl(localDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<ScenarioLocalDataSource>(
    () => ScenarioLocalDataSourceImpl(),
  );
}
```

## Data Layer

The Data layer is responsible for data retrieval. It includes the implementation of repositories and data sources.

### Data Sources

Located in `lib/data/datasources/`, this directory contains classes that retrieve data from different sources (local or remote).

**Example: `scenario_local_datasource.dart`**
```dart
abstract class ScenarioLocalDataSource {
  Future<List<LearningScenarioModel>> getScenarios();
}

class ScenarioLocalDataSourceImpl implements ScenarioLocalDataSource {
  @override
  Future<List<LearningScenarioModel>> getScenarios() async {
    // Implementation to retrieve data from local storage
    return [
      LearningScenarioModel(
        id: '1',
        title: 'Boost your speaking while',
        subtitle: 'Commuting 🚇',
        imagePath: 'assets/images/fox_commuting.png',
      ),
      // Other scenarios
    ];
  }
}
```

### Models

Located in `lib/data/models/`, this directory contains data models that extend entities from the domain layer.

**Example: `learning_scenario_model.dart`**
```dart
class LearningScenarioModel extends LearningScenario {
  LearningScenarioModel({
    required String id,
    required String title,
    required String subtitle,
    required String imagePath,
  }) : super(
          id: id,
          title: title,
          subtitle: subtitle,
          imagePath: imagePath,
        );

  factory LearningScenarioModel.fromJson(Map<String, dynamic> json) {
    return LearningScenarioModel(
      id: json['id'],
      title: json['title'],
      subtitle: json['subtitle'],
      imagePath: json['image_path'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'image_path': imagePath,
    };
  }
}
```

### Repositories Implementation

Located in `lib/data/repositories/`, this directory contains implementations of repository interfaces defined in the domain layer.

**Example: `scenario_repository_impl.dart`**
```dart
class ScenarioRepositoryImpl implements ScenarioRepository {
  final ScenarioLocalDataSource localDataSource;

  ScenarioRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<LearningScenario>>> getScenarios() async {
    try {
      final scenarios = await localDataSource.getScenarios();
      return Right(scenarios);
    } catch (e) {
      return Left(CacheFailure());
    }
  }
}
```

## Domain Layer

The Domain layer contains the business logic of the application. It's independent of any other layers.

### Entities

Located in `lib/domain/entities/`, this directory contains business objects.

**Example: `learning_scenario.dart`**
```dart
class LearningScenario {
  final String id;
  final String title;
  final String subtitle;
  final String imagePath;

  LearningScenario({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imagePath,
  });
}
```

### Repositories

Located in `lib/domain/repositories/`, this directory contains repository interfaces.

**Example: `scenario_repository.dart`**
```dart
abstract class ScenarioRepository {
  Future<Either<Failure, List<LearningScenario>>> getScenarios();
}
```

### Use Cases

Located in `lib/domain/usecases/`, this directory contains use cases that represent actions a user can take.

**Example: `get_scenarios_usecase.dart`**
```dart
class GetScenariosUseCase {
  final ScenarioRepository repository;

  GetScenariosUseCase(this.repository);

  Future<Either<Failure, List<LearningScenario>>> call() {
    return repository.getScenarios();
  }
}
```

## Presentation Layer

The Presentation layer is responsible for displaying data to the user and handling user interactions.

### BLoC (Business Logic Component)

Located in `lib/presentation/bloc/`, this directory contains BLoC classes for state management.

**Example: `scenarios_bloc.dart`**
```dart
// Events
abstract class ScenariosEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class GetScenariosEvent extends ScenariosEvent {}

// States
abstract class ScenariosState extends Equatable {
  @override
  List<Object> get props => [];
}

class ScenariosInitial extends ScenariosState {}
class ScenariosLoading extends ScenariosState {}
class ScenariosLoaded extends ScenariosState {
  final List<LearningScenario> scenarios;
  ScenariosLoaded({required this.scenarios});
  @override
  List<Object> get props => [scenarios];
}
class ScenariosError extends ScenariosState {
  final String message;
  ScenariosError({required this.message});
  @override
  List<Object> get props => [message];
}

// Bloc
class ScenariosBloc extends Bloc<ScenariosEvent, ScenariosState> {
  final GetScenariosUseCase getScenariosUseCase;

  ScenariosBloc({required this.getScenariosUseCase})
      : super(ScenariosInitial()) {
    on<GetScenariosEvent>(_onGetScenarios);
  }

  Future<void> _onGetScenarios(
    GetScenariosEvent event,
    Emitter<ScenariosState> emit,
  ) async {
    emit(ScenariosLoading());
    final result = await getScenariosUseCase();
    result.fold(
      (failure) => emit(ScenariosError(message: 'Failed to load scenarios')),
      (scenarios) => emit(ScenariosLoaded(scenarios: scenarios)),
    );
  }
}
```

### Pages

Located in `lib/presentation/pages/`, this directory contains screen widgets organized by feature.

**Example: `onboarding_screen.dart`**
```dart
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPageData> _pages = [
    // Page data
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Page View
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return OnboardingPage(data: _pages[index]);
            },
          ),
          
          // Bottom Navigation
          // ...
        ],
      ),
    );
  }
}
```

### Widgets

Located in `lib/presentation/widgets/`, this directory contains reusable widgets.

**Example: `scenario_card.dart`**
```dart
class ScenarioCard extends StatelessWidget {
  final LearningScenario scenario;
  final VoidCallback onPrimaryAction;
  final VoidCallback onSecondaryAction;

  const ScenarioCard({
    Key? key,
    required this.scenario,
    required this.onPrimaryAction,
    required this.onSecondaryAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      // Widget implementation
    );
  }
}
```

## Dependency Injection

The application uses the `get_it` package for dependency injection. This allows for loose coupling between components and makes testing easier.

The dependency injection is set up in `lib/core/di/injection_container.dart`. The `init()` function is called at the start of the application to register all dependencies.

## State Management

The application uses the BLoC pattern for state management. BLoC separates the business logic from the UI, making the code more maintainable and testable.

The BLoC pattern consists of three main components:
- **Events**: Represent user actions or system events
- **States**: Represent the state of the UI
- **BLoC**: Converts events to states

## Navigation

Navigation is handled using the `NavigationHelper` utility class, which provides methods for common navigation patterns:

```dart
class NavigationHelper {
  static void navigateTo(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  static void navigateToReplacement(BuildContext context, Widget page) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  static void navigateToAndRemoveUntil(BuildContext context, Widget page) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => page),
      (route) => false,
    );
  }
}
```

## Best Practices

### Naming Conventions

- **Files**: Use snake_case for file names (e.g., `learning_scenario.dart`)
- **Classes**: Use PascalCase for class names (e.g., `LearningScenario`)
- **Variables and Methods**: Use camelCase for variables and methods (e.g., `getScenarios()`)
- **Constants**: Use SCREAMING_SNAKE_CASE for constants (e.g., `MAX_RETRY_COUNT`)

### Code Organization

- Keep files small and focused on a single responsibility
- Group related functionality together
- Use meaningful names for classes, methods, and variables
- Add comments for complex logic
- Follow the DRY (Don't Repeat Yourself) principle

### Testing

- Write unit tests for business logic
- Write widget tests for UI components
- Use mocks for dependencies in tests
- Aim for high test coverage

### Performance

- Avoid expensive operations in the build method
- Use const constructors when possible
- Implement pagination for large lists
- Use caching for network requests

### Accessibility

- Provide meaningful labels for screen readers
- Ensure sufficient color contrast
- Support text scaling
- Test with accessibility tools
