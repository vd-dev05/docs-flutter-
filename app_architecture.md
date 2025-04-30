# BlaBló App Architecture

This document provides a comprehensive overview of the BlaBló app's architecture, explaining the design decisions, code organization, and best practices.

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Layer Details](#layer-details)
   - [Core Layer](#core-layer)
   - [Data Layer](#data-layer)
   - [Domain Layer](#domain-layer)
   - [Presentation Layer](#presentation-layer)
3. [State Management](#state-management)
4. [Navigation](#navigation)
5. [Dependency Injection](#dependency-injection)
6. [Asset Management](#asset-management)
7. [Responsive Design](#responsive-design)
8. [Reusable Components](#reusable-components)
9. [Best Practices](#best-practices)

## Architecture Overview

The BlaBló app follows Clean Architecture principles, separating concerns into distinct layers:

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

This architecture provides several benefits:

- **Separation of Concerns**: Each layer has a specific responsibility
- **Testability**: Business logic is isolated from UI and external dependencies
- **Maintainability**: Changes in one layer don't affect other layers
- **Scalability**: Easy to add new features without modifying existing code

## Layer Details

### Core Layer

The Core layer contains code that is used across the entire application and doesn't fit into any specific feature.

#### Constants

Located in `lib/core/constants/`, this directory contains constant values used throughout the app.

```dart
// lib/core/constants/app_constants.dart
class AppConstants {
  // App-wide constants
  static const String appName = 'BlaBló';
  
  // API endpoints
  static const String baseUrl = 'https://api.example.com';
  
  // Asset paths
  static const String imagePath = 'assets/images/';
}

// lib/core/constants/layout_constants.dart
class LayoutConstants {
  // Screen breakpoints
  static const double smallScreenHeight = 700;
  static const double mediumScreenHeight = 800;
  
  // Padding and spacing
  static const double contentPaddingSmall = 8.0;
  static const double contentPaddingMedium = 12.0;
  static const double contentPaddingLarge = 16.0;
  
  // Flex ratios
  static const int imageFlexSmall = 3;
  static const int imageFlexNormal = 4;
}
```

#### Error Handling

Located in `lib/core/error/`, this directory contains classes for error handling.

```dart
// lib/core/error/failures.dart
abstract class Failure {
  List<Object> get props => [];
}

class ServerFailure extends Failure {}
class CacheFailure extends Failure {}
```

#### Theme

Located in `lib/core/theme/`, this directory contains theme-related code.

```dart
// lib/core/theme/app_theme.dart
class AppTheme {
  // Colors
  static const Color primaryColor = Color(0xFFFF44CC);
  static const Color secondaryColor = Color(0xFF03DAC6);
  
  // Text Styles
  static const TextStyle headingStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: textPrimaryColor,
  );
  
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

#### Utilities

Located in `lib/core/utils/`, this directory contains utility functions.

```dart
// lib/core/utils/navigation_helper.dart
class NavigationHelper {
  static void navigateTo(BuildContext context, Widget page) {
    Navigator.push(
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

#### Dependency Injection

Located in `lib/core/di/`, this directory contains dependency injection setup.

```dart
// lib/core/di/injection_container.dart
final sl = GetIt.instance;

Future<void> init() async {
  // Features - Scenarios
  _initScenariosFeature();
  
  // Features - Vocabulary
  _initVocabularyFeature();
  
  // Features - Auth
  _initAuthFeature();
  
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
}
```

### Data Layer

The Data layer is responsible for retrieving data from different sources (API, local database, etc.) and converting it to the format expected by the Domain layer.

#### Data Sources

Located in `lib/data/datasources/`, this directory contains classes that retrieve data from different sources.

```dart
// lib/data/datasources/local/user_local_datasource.dart
class UserLocalDataSourceImpl implements UserLocalDataSource {
  final SharedPreferences sharedPreferences;

  UserLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<UserModel> getUser() async {
    final jsonString = sharedPreferences.getString('user');
    if (jsonString != null) {
      return UserModel.fromJson(json.decode(jsonString));
    } else {
      throw Exception('No cached user found');
    }
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    await sharedPreferences.setString('user', json.encode(user.toJson()));
    await sharedPreferences.setString('auth_token', user.token);
  }
}
```

#### Models

Located in `lib/data/models/`, this directory contains data models that extend entities from the domain layer.

```dart
// lib/data/models/user_model.dart
class UserModel extends User {
  const UserModel({
    required String id,
    required String name,
    required String email,
    required String token,
  }) : super(id: id, name: name, email: email, token: token);

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'token': token,
    };
  }
}
```

#### Repositories

Located in `lib/data/repositories/`, this directory contains implementations of repository interfaces defined in the domain layer.

```dart
// lib/data/repositories/user_repository_impl.dart
class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;
  final UserLocalDataSource localDataSource;

  UserRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    try {
      final user = await remoteDataSource.login(email, password);
      await localDataSource.cacheUser(user);
      return Right(user);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
```

### Domain Layer

The Domain layer contains the business logic of the application. It defines entities, repository interfaces, and use cases.

#### Entities

Located in `lib/domain/entities/`, this directory contains business objects.

```dart
// lib/domain/entities/user.dart
class User extends Equatable {
  final String id;
  final String name;
  final String email;
  final String token;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.token,
  });

  @override
  List<Object> get props => [id, name, email, token];
}
```

#### Repositories

Located in `lib/domain/repositories/`, this directory contains repository interfaces.

```dart
// lib/domain/repositories/user_repository.dart
abstract class UserRepository {
  Future<Either<Failure, User>> login(String email, String password);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, User>> getUser();
}
```

#### Use Cases

Located in `lib/domain/usecases/`, this directory contains use cases that represent the business logic of the application.

```dart
// lib/domain/usecases/login_usecase.dart
class LoginUseCase {
  final UserRepository repository;

  LoginUseCase(this.repository);

  Future<Either<Failure, User>> call(LoginParams params) async {
    return await repository.login(params.email, params.password);
  }
}

class LoginParams extends Equatable {
  final String email;
  final String password;

  const LoginParams({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}
```

### Presentation Layer

The Presentation layer is responsible for displaying data to the user and handling user interactions.

#### BLoC

Located in `lib/presentation/bloc/`, this directory contains BLoC (Business Logic Component) classes that manage the state of the application.

```dart
// lib/presentation/bloc/auth_bloc.dart
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final CheckAuthStatusUseCase checkAuthStatusUseCase;
  final LogoutUseCase logoutUseCase;

  AuthBloc({
    required this.checkAuthStatusUseCase,
    required this.logoutUseCase,
  }) : super(AuthInitial()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await checkAuthStatusUseCase(NoParams());
    result.fold(
      (failure) => emit(AuthUnauthenticated()),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onLogout(
    LogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await logoutUseCase(NoParams());
    result.fold(
      (failure) => emit(AuthError(message: 'Failed to logout')),
      (_) => emit(AuthUnauthenticated()),
    );
  }
}
```

#### Pages

Located in `lib/presentation/pages/`, this directory contains screen widgets.

```dart
// lib/presentation/pages/onboarding/goal_selection_screen.dart
class GoalSelectionScreen extends StatefulWidget {
  const GoalSelectionScreen({Key? key}) : super(key: key);

  @override
  State<GoalSelectionScreen> createState() => _GoalSelectionScreenState();
}

class _GoalSelectionScreenState extends State<GoalSelectionScreen> {
  // Implementation details
}
```

#### Widgets

Located in `lib/presentation/widgets/`, this directory contains reusable widgets.

```dart
// lib/presentation/widgets/common/app_button.dart
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final double? width;
  final double height;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double borderRadius;
  final bool isLoading;

  const AppButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isPrimary = true,
    this.width,
    this.height = 56,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.borderRadius = 28,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Implementation details
  }
}
```

## State Management

The BlaBló app uses the BLoC pattern for state management, which provides several benefits:

- **Separation of UI and Business Logic**: BLoC separates the UI from the business logic
- **Testability**: Business logic can be tested independently of the UI
- **Reusability**: BLoCs can be reused across different widgets
- **Predictable State Changes**: State changes are triggered by events and flow in one direction

## Navigation

Navigation is handled using the `NavigationHelper` utility class, which provides methods for common navigation patterns:

```dart
// Navigate to a new screen
NavigationHelper.navigateTo(context, const HomeScreen());

// Navigate to a new screen and remove all previous screens
NavigationHelper.navigateToAndRemoveUntil(context, const HomeScreen());
```

## Dependency Injection

Dependency injection is handled using the `GetIt` package, which provides a service locator pattern:

```dart
// Register a dependency
sl.registerLazySingleton<UserRepository>(
  () => UserRepositoryImpl(
    remoteDataSource: sl(),
    localDataSource: sl(),
  ),
);

// Resolve a dependency
final userRepository = sl<UserRepository>();
```

## Asset Management

Assets are managed using the `pubspec.yaml` file and accessed using the `AppConstants` class:

```yaml
# pubspec.yaml
flutter:
  assets:
    - assets/images/
```

```dart
// Access an asset
Image.asset('${AppConstants.imagePath}fox_welcome.png');

// Using the AppImage component
AppImage(imagePath: 'fox_welcome.png');
```

## Responsive Design

Responsive design is handled using the `LayoutConstants` class and the `MediaQuery` API:

```dart
// Determine screen size category
final screenHeight = MediaQuery.of(context).size.height;
final isSmallScreen = screenHeight < LayoutConstants.smallScreenHeight;
final isMediumScreen = screenHeight < LayoutConstants.mediumScreenHeight;

// Apply responsive styling
final contentPadding = isSmallScreen
    ? LayoutConstants.contentPaddingSmall
    : isMediumScreen
        ? LayoutConstants.contentPaddingMedium
        : LayoutConstants.contentPaddingLarge;
```

## Reusable Components

The app uses several reusable components to ensure consistency and reduce code duplication:

- **AppButton**: A versatile button component
- **AppImage**: A standardized image component
- **AppCharacter**: A specialized component for character images
- **AppDialog**: A reusable dialog component
- **AppProgressBar**: A standardized progress indicator

For more details, see the [Reusable Components](reusable_components.md) documentation.

## Best Practices

1. **Follow Clean Architecture**: Keep the layers separate and respect the dependency rule (dependencies point inward).

2. **Use BLoC for State Management**: Use BLoC for complex state management and StatefulWidget for simple state.

3. **Write Unit Tests**: Write tests for all layers, especially the domain and data layers.

4. **Use Dependency Injection**: Use dependency injection to make code more testable and maintainable.

5. **Create Reusable Components**: Create reusable components for common UI patterns.

6. **Document Your Code**: Add comments and documentation to explain complex logic.

7. **Use Constants**: Use constants for values that are used in multiple places.

8. **Handle Errors Gracefully**: Provide meaningful error messages and fallback UI.

9. **Optimize Performance**: Use const constructors, minimize rebuilds, and avoid expensive operations in the build method.

10. **Follow Naming Conventions**: Use clear and consistent naming for classes, methods, and variables.
