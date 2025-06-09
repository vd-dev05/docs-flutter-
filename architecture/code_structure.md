# BlaBló App Code Structure

## Project Structure

The BlaBló app follows Clean Architecture principles, with the codebase organized into distinct layers:

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

## Key Files and Their Purposes

### Main Application

- **`main.dart`**: Entry point of the application. Sets up dependency injection, system UI configuration, and renders the root widget.

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependency injection
  await di.init();
  
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ScenariosBloc>(
          create: (_) => di.sl<ScenariosBloc>(),
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
}
```

### Core Layer

#### Constants

- **`app_constants.dart`**: Contains application-wide constants.

```dart
class AppConstants {
  static const String appName = 'BlaBló';
  static const String baseUrl = 'https://api.example.com';
  static const String imagePath = 'assets/images/';
}
```

#### Error Handling

- **`failures.dart`**: Defines failure classes for error handling.

```dart
abstract class Failure {
  List<Object> get props => [];
}

class ServerFailure extends Failure {}
class CacheFailure extends Failure {}
```

#### Theme

- **`app_theme.dart`**: Defines the application's theme, including colors, text styles, and widget themes.

```dart
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

- **`navigation_helper.dart`**: Provides helper methods for navigation.

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

#### Dependency Injection

- **`injection_container.dart`**: Sets up dependency injection using GetIt.

```dart
final sl = GetIt.instance;

Future<void> init() async {
  // Features - Scenarios
  _initScenariosFeature();
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

### Data Layer

#### Data Sources

- **`scenario_local_datasource.dart`**: Implements data retrieval from local storage.

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

#### Models

- **`learning_scenario_model.dart`**: Data model that extends the domain entity.

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

#### Repositories Implementation

- **`scenario_repository_impl.dart`**: Implements the repository interface from the domain layer.

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

### Domain Layer

#### Entities

- **`learning_scenario.dart`**: Business entity representing a learning scenario.

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

#### Repositories

- **`scenario_repository.dart`**: Repository interface for scenarios.

```dart
abstract class ScenarioRepository {
  Future<Either<Failure, List<LearningScenario>>> getScenarios();
}
```

#### Use Cases

- **`get_scenarios_usecase.dart`**: Use case for retrieving scenarios.

```dart
class GetScenariosUseCase {
  final ScenarioRepository repository;

  GetScenariosUseCase(this.repository);

  Future<Either<Failure, List<LearningScenario>>> call() {
    return repository.getScenarios();
  }
}
```

### Presentation Layer

#### BLoC

- **`scenarios_bloc.dart`**: BLoC for managing scenario state.

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

#### Pages

- **`onboarding_screen.dart`**: Screen for onboarding users.

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
          
          // Bottom Navigation with buttons and indicators
        ],
      ),
    );
  }
}
```

- **`home_screen.dart`**: Main screen of the application.

```dart
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    context.read<ScenariosBloc>().add(GetScenariosEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blablo App'),
      ),
      body: BlocBuilder<ScenariosBloc, ScenariosState>(
        builder: (context, state) {
          if (state is ScenariosLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ScenariosLoaded) {
            return _buildContent(state.scenarios);
          } else if (state is ScenariosError) {
            return Center(child: Text(state.message));
          } else {
            return const Center(child: Text('Press the button to load scenarios'));
          }
        },
      ),
    );
  }

  // Content building method
}
```

- **`login_screen.dart`**: Screen for user authentication.

```dart
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            // Form fields and buttons
          ),
        ),
      ),
    );
  }
}
```

#### Widgets

- **`scenario_card.dart`**: Widget for displaying a learning scenario.

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
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        // Card content
      ),
    );
  }
}
```

- **`custom_button.dart`**: Reusable button widget.

```dart
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isPrimary;
  final double? width;
  final double height;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isPrimary = true,
    this.width,
    this.height = 56,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Button implementation
  }
}
```

## Data Flow

1. **User Interaction**: User interacts with the UI (e.g., opening the app, tapping a button).
2. **Event Creation**: The UI creates an event and sends it to the BLoC.
3. **BLoC Processing**: The BLoC processes the event, potentially calling a use case.
4. **Use Case Execution**: The use case executes business logic, potentially calling a repository.
5. **Repository Access**: The repository accesses data sources to retrieve or store data.
6. **Data Return**: Data flows back up through the layers.
7. **State Update**: The BLoC updates its state based on the data.
8. **UI Update**: The UI rebuilds based on the new state.

## Dependencies

The application uses the following key dependencies:

- **flutter_bloc**: For state management
- **equatable**: For value equality
- **get_it**: For dependency injection
- **dartz**: For functional programming features (Either type)
- **smooth_page_indicator**: For page indicators in the onboarding flow

## Conclusion

This code structure follows Clean Architecture principles, making the codebase:

- **Maintainable**: Each layer has a clear responsibility
- **Testable**: Business logic is separated from UI and external dependencies
- **Scalable**: New features can be added without modifying existing code
- **Flexible**: UI and data sources can be changed without affecting business logic
