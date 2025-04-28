# BlaBló App Development Guide

## Introduction

This guide provides instructions for developers working on the BlaBló app. It covers setup, development workflow, coding standards, and best practices.

## Getting Started

### Prerequisites

- Flutter SDK (version 3.0.0 or higher)
- Dart SDK (version 3.0.0 or higher)
- Android Studio or VS Code with Flutter extensions
- Git

### Setup

1. Clone the repository:
   ```
   git clone https://github.com/your-organization/blablo-app.git
   ```

2. Navigate to the project directory:
   ```
   cd blablo-app
   ```

3. Install dependencies:
   ```
   flutter pub get
   ```

4. Run the app:
   ```
   flutter run
   ```

## Project Architecture

The BlaBló app follows Clean Architecture principles, with the codebase organized into the following layers:

### Core Layer

Contains code that is used across the entire application:
- **Constants**: App-wide constant values
- **Error**: Error handling classes
- **Theme**: Theme-related code
- **Utils**: Utility functions
- **DI**: Dependency injection setup

### Data Layer

Responsible for data retrieval:
- **Data Sources**: Classes that retrieve data from different sources
- **Models**: Data models that extend entities from the domain layer
- **Repositories**: Implementations of repository interfaces

### Domain Layer

Contains the business logic:
- **Entities**: Business objects
- **Repositories**: Repository interfaces
- **Use Cases**: Actions a user can take

### Presentation Layer

Responsible for displaying data to the user:
- **BLoC**: Business Logic Components for state management
- **Pages**: Screen widgets
- **Widgets**: Reusable UI components

## Development Workflow

### Feature Development

1. **Create a new branch**:
   ```
   git checkout -b feature/feature-name
   ```

2. **Implement the feature**:
   - Add necessary entities in the domain layer
   - Add repository interfaces in the domain layer
   - Add use cases in the domain layer
   - Add models in the data layer
   - Add data sources in the data layer
   - Add repository implementations in the data layer
   - Add BLoC classes in the presentation layer
   - Add UI components in the presentation layer

3. **Test the feature**:
   - Write unit tests for business logic
   - Write widget tests for UI components
   - Run tests:
     ```
     flutter test
     ```

4. **Commit changes**:
   ```
   git add .
   git commit -m "Add feature: feature-name"
   ```

5. **Push changes**:
   ```
   git push origin feature/feature-name
   ```

6. **Create a pull request** for code review

### Bug Fixing

1. **Create a new branch**:
   ```
   git checkout -b fix/bug-name
   ```

2. **Fix the bug**:
   - Identify the root cause
   - Make necessary changes
   - Add tests to prevent regression

3. **Commit changes**:
   ```
   git add .
   git commit -m "Fix bug: bug-name"
   ```

4. **Push changes**:
   ```
   git push origin fix/bug-name
   ```

5. **Create a pull request** for code review

## Coding Standards

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

### Code Style

- Follow the [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use the provided analysis options
- Run `flutter analyze` before committing code
- Format code using `flutter format .`

## Adding New Features

### 1. Add Domain Layer Components

Start by defining the business logic in the domain layer:

#### Entity

```dart
// lib/domain/entities/new_feature_entity.dart
class NewFeatureEntity {
  final String id;
  final String name;

  NewFeatureEntity({
    required this.id,
    required this.name,
  });
}
```

#### Repository Interface

```dart
// lib/domain/repositories/new_feature_repository.dart
import 'package:dartz/dartz.dart';
import 'package:blablo_app/core/error/failures.dart';
import 'package:blablo_app/domain/entities/new_feature_entity.dart';

abstract class NewFeatureRepository {
  Future<Either<Failure, List<NewFeatureEntity>>> getNewFeatures();
}
```

#### Use Case

```dart
// lib/domain/usecases/get_new_features_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:blablo_app/core/error/failures.dart';
import 'package:blablo_app/domain/entities/new_feature_entity.dart';
import 'package:blablo_app/domain/repositories/new_feature_repository.dart';

class GetNewFeaturesUseCase {
  final NewFeatureRepository repository;

  GetNewFeaturesUseCase(this.repository);

  Future<Either<Failure, List<NewFeatureEntity>>> call() {
    return repository.getNewFeatures();
  }
}
```

### 2. Add Data Layer Components

Next, implement the data layer components:

#### Model

```dart
// lib/data/models/new_feature_model.dart
import 'package:blablo_app/domain/entities/new_feature_entity.dart';

class NewFeatureModel extends NewFeatureEntity {
  NewFeatureModel({
    required String id,
    required String name,
  }) : super(
          id: id,
          name: name,
        );

  factory NewFeatureModel.fromJson(Map<String, dynamic> json) {
    return NewFeatureModel(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
```

#### Data Source

```dart
// lib/data/datasources/local/new_feature_local_datasource.dart
import 'package:blablo_app/data/models/new_feature_model.dart';

abstract class NewFeatureLocalDataSource {
  Future<List<NewFeatureModel>> getNewFeatures();
}

class NewFeatureLocalDataSourceImpl implements NewFeatureLocalDataSource {
  @override
  Future<List<NewFeatureModel>> getNewFeatures() async {
    // Implementation
    return [
      NewFeatureModel(
        id: '1',
        name: 'Feature 1',
      ),
      NewFeatureModel(
        id: '2',
        name: 'Feature 2',
      ),
    ];
  }
}
```

#### Repository Implementation

```dart
// lib/data/repositories/new_feature_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:blablo_app/core/error/failures.dart';
import 'package:blablo_app/data/datasources/local/new_feature_local_datasource.dart';
import 'package:blablo_app/domain/entities/new_feature_entity.dart';
import 'package:blablo_app/domain/repositories/new_feature_repository.dart';

class NewFeatureRepositoryImpl implements NewFeatureRepository {
  final NewFeatureLocalDataSource localDataSource;

  NewFeatureRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<NewFeatureEntity>>> getNewFeatures() async {
    try {
      final features = await localDataSource.getNewFeatures();
      return Right(features);
    } catch (e) {
      return Left(CacheFailure());
    }
  }
}
```

### 3. Add Presentation Layer Components

Finally, implement the presentation layer components:

#### BLoC

```dart
// lib/presentation/bloc/new_feature_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:blablo_app/domain/entities/new_feature_entity.dart';
import 'package:blablo_app/domain/usecases/get_new_features_usecase.dart';

// Events
abstract class NewFeatureEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class GetNewFeaturesEvent extends NewFeatureEvent {}

// States
abstract class NewFeatureState extends Equatable {
  @override
  List<Object> get props => [];
}

class NewFeatureInitial extends NewFeatureState {}
class NewFeatureLoading extends NewFeatureState {}
class NewFeatureLoaded extends NewFeatureState {
  final List<NewFeatureEntity> features;
  NewFeatureLoaded({required this.features});
  @override
  List<Object> get props => [features];
}
class NewFeatureError extends NewFeatureState {
  final String message;
  NewFeatureError({required this.message});
  @override
  List<Object> get props => [message];
}

// Bloc
class NewFeatureBloc extends Bloc<NewFeatureEvent, NewFeatureState> {
  final GetNewFeaturesUseCase getNewFeaturesUseCase;

  NewFeatureBloc({required this.getNewFeaturesUseCase})
      : super(NewFeatureInitial()) {
    on<GetNewFeaturesEvent>(_onGetNewFeatures);
  }

  Future<void> _onGetNewFeatures(
    GetNewFeaturesEvent event,
    Emitter<NewFeatureState> emit,
  ) async {
    emit(NewFeatureLoading());
    final result = await getNewFeaturesUseCase();
    result.fold(
      (failure) => emit(NewFeatureError(message: 'Failed to load features')),
      (features) => emit(NewFeatureLoaded(features: features)),
    );
  }
}
```

#### Page

```dart
// lib/presentation/pages/new_feature/new_feature_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blablo_app/core/theme/app_theme.dart';
import 'package:blablo_app/domain/entities/new_feature_entity.dart';
import 'package:blablo_app/presentation/bloc/new_feature_bloc.dart';

class NewFeatureScreen extends StatefulWidget {
  const NewFeatureScreen({Key? key}) : super(key: key);

  @override
  State<NewFeatureScreen> createState() => _NewFeatureScreenState();
}

class _NewFeatureScreenState extends State<NewFeatureScreen> {
  @override
  void initState() {
    super.initState();
    context.read<NewFeatureBloc>().add(GetNewFeaturesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Feature'),
      ),
      body: BlocBuilder<NewFeatureBloc, NewFeatureState>(
        builder: (context, state) {
          if (state is NewFeatureLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is NewFeatureLoaded) {
            return _buildContent(state.features);
          } else if (state is NewFeatureError) {
            return Center(child: Text(state.message));
          } else {
            return const Center(child: Text('Press the button to load features'));
          }
        },
      ),
    );
  }

  Widget _buildContent(List<NewFeatureEntity> features) {
    return ListView.builder(
      itemCount: features.length,
      itemBuilder: (context, index) {
        final feature = features[index];
        return ListTile(
          title: Text(feature.name),
          subtitle: Text(feature.id),
        );
      },
    );
  }
}
```

### 4. Update Dependency Injection

Add the new feature to the dependency injection container:

```dart
// lib/core/di/injection_container.dart
void _initNewFeatureFeature() {
  // Bloc
  sl.registerFactory(() => NewFeatureBloc(getNewFeaturesUseCase: sl()));

  // Use cases
  sl.registerLazySingleton(() => GetNewFeaturesUseCase(sl()));

  // Repository
  sl.registerLazySingleton<NewFeatureRepository>(
    () => NewFeatureRepositoryImpl(localDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<NewFeatureLocalDataSource>(
    () => NewFeatureLocalDataSourceImpl(),
  );
}

Future<void> init() async {
  // Features - Scenarios
  _initScenariosFeature();
  
  // Features - New Feature
  _initNewFeatureFeature();
  
  // Core
  
  // External
}
```

### 5. Update Main App

Add the new BLoC provider to the main app:

```dart
// lib/main.dart
@override
Widget build(BuildContext context) {
  return MultiBlocProvider(
    providers: [
      BlocProvider<ScenariosBloc>(
        create: (_) => di.sl<ScenariosBloc>(),
      ),
      BlocProvider<NewFeatureBloc>(
        create: (_) => di.sl<NewFeatureBloc>(),
      ),
    ],
    child: MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const OnboardingScreen(),
    ),
  );
}
```

## Testing

### Unit Tests

Unit tests focus on testing individual components in isolation:

```dart
// test/domain/usecases/get_scenarios_usecase_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dartz/dartz.dart';
import 'package:blablo_app/domain/entities/learning_scenario.dart';
import 'package:blablo_app/domain/repositories/scenario_repository.dart';
import 'package:blablo_app/domain/usecases/get_scenarios_usecase.dart';

class MockScenarioRepository extends Mock implements ScenarioRepository {}

void main() {
  late GetScenariosUseCase usecase;
  late MockScenarioRepository mockRepository;

  setUp(() {
    mockRepository = MockScenarioRepository();
    usecase = GetScenariosUseCase(mockRepository);
  });

  final tScenarios = [
    LearningScenario(
      id: '1',
      title: 'Test Title',
      subtitle: 'Test Subtitle',
      imagePath: 'test_path.png',
    ),
  ];

  test(
    'should get scenarios from the repository',
    () async {
      // arrange
      when(mockRepository.getScenarios())
          .thenAnswer((_) async => Right(tScenarios));
      // act
      final result = await usecase();
      // assert
      expect(result, Right(tScenarios));
      verify(mockRepository.getScenarios());
      verifyNoMoreInteractions(mockRepository);
    },
  );
}
```

### Widget Tests

Widget tests focus on testing UI components:

```dart
// test/presentation/widgets/scenario_card_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:blablo_app/domain/entities/learning_scenario.dart';
import 'package:blablo_app/presentation/widgets/specific/scenario_card.dart';

void main() {
  testWidgets('ScenarioCard displays correct content', (WidgetTester tester) async {
    // Create a test scenario
    final scenario = LearningScenario(
      id: '1',
      title: 'Test Title',
      subtitle: 'Test Subtitle',
      imagePath: 'assets/images/test.png',
    );

    // Build the widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ScenarioCard(
            scenario: scenario,
            onPrimaryAction: () {},
            onSecondaryAction: () {},
          ),
        ),
      ),
    );

    // Verify that the widget displays the correct content
    expect(find.text('Test Title'), findsOneWidget);
    expect(find.text('Test Subtitle'), findsOneWidget);
    expect(find.text("Let's go"), findsOneWidget);
    expect(find.text('I have an account'), findsOneWidget);
  });
}
```

## Deployment

### Android

1. Update the version in `pubspec.yaml`:
   ```yaml
   version: 1.0.0+1  # Format: version_name+version_code
   ```

2. Build the APK:
   ```
   flutter build apk --release
   ```

3. The APK will be available at:
   ```
   build/app/outputs/flutter-apk/app-release.apk
   ```

### iOS

1. Update the version in `pubspec.yaml`:
   ```yaml
   version: 1.0.0+1  # Format: version_name+build_number
   ```

2. Build the IPA:
   ```
   flutter build ios --release
   ```

3. Open the Xcode workspace:
   ```
   open ios/Runner.xcworkspace
   ```

4. In Xcode, select Product > Archive to create an archive
5. Use the Archive Manager to upload to the App Store

## Troubleshooting

### Common Issues

1. **Dependency Issues**:
   - Run `flutter pub get` to update dependencies
   - Check for conflicting dependencies in `pubspec.yaml`

2. **Build Errors**:
   - Run `flutter clean` to clean the build cache
   - Run `flutter doctor` to check for environment issues

3. **State Management Issues**:
   - Check BLoC event handling
   - Verify that states are being emitted correctly
   - Use BlocObserver for debugging

4. **UI Issues**:
   - Use Flutter DevTools to inspect the widget tree
   - Check for layout overflow issues
   - Test on different screen sizes

## Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Documentation](https://dart.dev/guides)
- [Flutter Bloc Library](https://bloclibrary.dev/)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

## Conclusion

This development guide provides a comprehensive overview of the BlaBló app's architecture, development workflow, and best practices. By following these guidelines, developers can contribute to the project in a consistent and efficient manner.
