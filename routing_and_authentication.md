# Routing và Xác Thực trong BlaBló App

## Tổng Quan

Tài liệu này mô tả cách triển khai cơ chế routing và xác thực trong BlaBló App, tuân theo nguyên tắc Clean Architecture. Cơ chế này cho phép:

1. Người dùng mới sẽ thấy màn hình Onboarding khi lần đầu mở ứng dụng
2. Người dùng đã hoàn thành Onboarding nhưng chưa đăng nhập sẽ thấy màn hình Login
3. Người dùng đã đăng nhập sẽ được chuyển thẳng đến màn hình Home

## Kiến Trúc

Cơ chế routing và xác thực được triển khai theo Clean Architecture với các lớp sau:

### Domain Layer

#### Entities

- **User**: Đại diện cho thông tin người dùng đã đăng nhập

```dart
// lib/domain/entities/user.dart
class User {
  final String id;
  final String name;
  final String email;
  final String token;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.token,
  });
}
```

#### Repositories

- **AuthRepository**: Định nghĩa các phương thức để kiểm tra trạng thái đăng nhập và onboarding

```dart
// lib/domain/repositories/auth_repository.dart
abstract class AuthRepository {
  Future<Either<Failure, bool>> isUserLoggedIn();
  Future<Either<Failure, bool>> hasCompletedOnboarding();
  Future<Either<Failure, void>> setOnboardingCompleted();
}
```

- **UserRepository**: Định nghĩa các phương thức để đăng nhập và đăng xuất

```dart
// lib/domain/repositories/user_repository.dart
abstract class UserRepository {
  Future<Either<Failure, User>> login(String email, String password);
  Future<Either<Failure, void>> logout();
}
```

#### Use Cases

- **CheckAuthStatusUseCase**: Kiểm tra xem người dùng đã đăng nhập chưa
- **CheckOnboardingStatusUseCase**: Kiểm tra xem người dùng đã hoàn thành onboarding chưa
- **CompleteOnboardingUseCase**: Đánh dấu onboarding đã hoàn thành
- **LoginUseCase**: Xử lý đăng nhập
- **LogoutUseCase**: Xử lý đăng xuất

### Data Layer

#### Data Sources

- **UserLocalDataSource**: Lưu trữ và truy xuất thông tin người dùng từ bộ nhớ cục bộ
- **UserRemoteDataSource**: Giao tiếp với API để xác thực người dùng

#### Repository Implementations

- **AuthRepositoryImpl**: Triển khai AuthRepository
- **UserRepositoryImpl**: Triển khai UserRepository

### Presentation Layer

#### BLoCs

- **AuthBloc**: Quản lý trạng thái xác thực và điều hướng
- **LoginBloc**: Quản lý trạng thái đăng nhập

#### Screens

- **SplashScreen**: Màn hình khởi động, kiểm tra trạng thái và điều hướng
- **OnboardingScreen**: Màn hình giới thiệu cho người dùng mới
- **LoginScreen**: Màn hình đăng nhập
- **HomeScreen**: Màn hình chính của ứng dụng

## Luồng Hoạt Động

### 1. Khởi Động Ứng Dụng

Khi ứng dụng khởi động, `SplashScreen` được hiển thị đầu tiên. Trong `initState()`, nó kích hoạt `CheckAuthStatusEvent` để kiểm tra trạng thái xác thực:

```dart
@override
void initState() {
  super.initState();
  context.read<AuthBloc>().add(CheckAuthStatusEvent());
}
```

### 2. Kiểm Tra Trạng Thái Xác Thực

`AuthBloc` xử lý `CheckAuthStatusEvent` bằng cách:

1. Kiểm tra xem người dùng đã đăng nhập chưa
2. Nếu đã đăng nhập, phát ra trạng thái `Authenticated`
3. Nếu chưa đăng nhập, kiểm tra xem đã hoàn thành onboarding chưa
4. Nếu đã hoàn thành onboarding, phát ra trạng thái `Unauthenticated`
5. Nếu chưa hoàn thành onboarding, phát ra trạng thái `OnboardingRequired`

```dart
Future<void> _onCheckAuthStatus(
  CheckAuthStatusEvent event,
  Emitter<AuthState> emit,
) async {
  emit(AuthLoading());
  
  // Kiểm tra trạng thái đăng nhập
  final authResult = await checkAuthStatusUseCase();
  
  await authResult.fold(
    (failure) async {
      // Nếu có lỗi, mặc định hiển thị onboarding
      emit(OnboardingRequired());
    },
    (isLoggedIn) async {
      if (isLoggedIn) {
        // Nếu đã đăng nhập, chuyển đến màn hình chính
        emit(Authenticated());
      } else {
        // Nếu chưa đăng nhập, kiểm tra xem đã hoàn thành onboarding chưa
        final onboardingResult = await checkOnboardingStatusUseCase();
        
        onboardingResult.fold(
          (failure) {
            // Nếu có lỗi, mặc định hiển thị onboarding
            emit(OnboardingRequired());
          },
          (hasCompletedOnboarding) {
            if (hasCompletedOnboarding) {
              // Nếu đã hoàn thành onboarding, chuyển đến màn hình đăng nhập
              emit(Unauthenticated());
            } else {
              // Nếu chưa hoàn thành onboarding, hiển thị onboarding
              emit(OnboardingRequired());
            }
          },
        );
      }
    },
  );
}
```

### 3. Điều Hướng Dựa Trên Trạng Thái

`SplashScreen` lắng nghe trạng thái từ `AuthBloc` và điều hướng tương ứng:

```dart
BlocListener<AuthBloc, AuthState>(
  listener: (context, state) {
    if (state is Authenticated) {
      // Nếu đã xác thực, chuyển đến màn hình chính
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else if (state is Unauthenticated) {
      // Nếu chưa xác thực nhưng đã hoàn thành onboarding, chuyển đến màn hình đăng nhập
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } else if (state is OnboardingRequired) {
      // Nếu cần hiển thị onboarding, chuyển đến màn hình onboarding
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    }
  },
  child: // UI của SplashScreen
)
```

### 4. Hoàn Thành Onboarding

Khi người dùng hoàn thành onboarding (nhấn nút "Let's go" ở trang cuối cùng), `CompleteOnboardingEvent` được kích hoạt:

```dart
ElevatedButton(
  onPressed: () {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Mark onboarding as completed
      context.read<AuthBloc>().add(CompleteOnboardingEvent());
    }
  },
  // ...
)
```

`AuthBloc` xử lý sự kiện này bằng cách đánh dấu onboarding đã hoàn thành và phát ra trạng thái `Unauthenticated` để chuyển đến màn hình đăng nhập:

```dart
Future<void> _onCompleteOnboarding(
  CompleteOnboardingEvent event,
  Emitter<AuthState> emit,
) async {
  final result = await completeOnboardingUseCase();
  
  result.fold(
    (failure) {
      // Nếu có lỗi, vẫn chuyển đến màn hình đăng nhập
      emit(Unauthenticated());
    },
    (_) {
      // Đánh dấu onboarding đã hoàn thành, chuyển đến màn hình đăng nhập
      emit(Unauthenticated());
    },
  );
}
```

### 5. Đăng Nhập

Màn hình đăng nhập sử dụng `LoginBloc` để xử lý đăng nhập:

```dart
ElevatedButton(
  onPressed: state is LoginLoading
      ? null
      : () {
          if (_formKey.currentState!.validate()) {
            context.read<LoginBloc>().add(
                  LoginSubmitted(
                    email: _emailController.text,
                    password: _passwordController.text,
                  ),
                );
          }
        },
  // ...
)
```

`LoginBloc` xử lý sự kiện đăng nhập và phát ra trạng thái tương ứng:

```dart
Future<void> _onLoginSubmitted(
  LoginSubmitted event,
  Emitter<LoginState> emit,
) async {
  emit(LoginLoading());
  
  final result = await loginUseCase(
    LoginParams(
      email: event.email,
      password: event.password,
    ),
  );
  
  result.fold(
    (failure) => emit(const LoginFailure(message: 'Login failed. Please check your credentials.')),
    (user) => emit(LoginSuccess(user: user)),
  );
}
```

Khi đăng nhập thành công, màn hình đăng nhập kích hoạt `CheckAuthStatusEvent` để cập nhật trạng thái xác thực và chuyển đến màn hình chính:

```dart
BlocListener<LoginBloc, LoginState>(
  listener: (context, state) {
    if (state is LoginSuccess) {
      // Trigger auth check to update auth state
      context.read<AuthBloc>().add(CheckAuthStatusEvent());
      
      // Navigate to home screen
      NavigationHelper.navigateToAndRemoveUntil(
        context,
        const HomeScreen(),
      );
    } else if (state is LoginFailure) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: Colors.red,
        ),
      );
    }
  },
  // ...
)
```

## Fake Authentication

Để mục đích demo, ứng dụng sử dụng fake authentication:

```dart
// lib/data/datasources/remote/user_remote_datasource.dart
class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  @override
  Future<UserModel> login(String email, String password) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 2));
    
    // Fake login logic
    if (email == 'test@example.com' && password == 'password') {
      return UserModel(
        id: '1',
        name: 'Test User',
        email: email,
        token: 'fake_token_${DateTime.now().millisecondsSinceEpoch}',
      );
    } else {
      throw Exception('Invalid credentials');
    }
  }
}
```

Thông tin đăng nhập được lưu trong SharedPreferences:

```dart
// lib/data/datasources/local/user_local_datasource.dart
class UserLocalDataSourceImpl implements UserLocalDataSource {
  final SharedPreferences sharedPreferences;

  UserLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheUser(UserModel user) async {
    await sharedPreferences.setString('user', json.encode(user.toJson()));
    await sharedPreferences.setString('auth_token', user.token);
  }
  
  // ...
}
```

## Dependency Injection

Tất cả các dependencies được đăng ký trong `injection_container.dart`:

```dart
void _initAuthFeature() {
  // Bloc
  sl.registerFactory(() => AuthBloc(
        checkAuthStatusUseCase: sl(),
        checkOnboardingStatusUseCase: sl(),
        completeOnboardingUseCase: sl(),
      ));
  
  sl.registerFactory(() => LoginBloc(
        loginUseCase: sl(),
      ));

  // Use cases
  sl.registerLazySingleton(() => CheckAuthStatusUseCase(sl()));
  sl.registerLazySingleton(() => CheckOnboardingStatusUseCase(sl()));
  sl.registerLazySingleton(() => CompleteOnboardingUseCase(sl()));
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sharedPreferences: sl()),
  );
  
  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );
  
  // Data sources
  sl.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSourceImpl(),
  );
  
  sl.registerLazySingleton<UserLocalDataSource>(
    () => UserLocalDataSourceImpl(sharedPreferences: sl()),
  );
}
```

## Lợi Ích của Cách Tiếp Cận Này

1. **Tuân thủ Clean Architecture**: Mỗi lớp có trách nhiệm rõ ràng
2. **Dễ kiểm thử**: Có thể viết unit test cho từng thành phần
3. **Dễ mở rộng**: Có thể thêm các trạng thái và luồng mới mà không ảnh hưởng đến code hiện có
4. **Quản lý trạng thái hiệu quả**: Sử dụng BLoC để quản lý trạng thái xác thực
5. **Tách biệt UI và logic**: Logic điều hướng được tách biệt khỏi UI

## Kết Luận

Cơ chế routing và xác thực trong BlaBló App được triển khai theo Clean Architecture, đảm bảo tính mô-đun, dễ bảo trì và mở rộng. Cơ chế này cho phép ứng dụng hiển thị màn hình phù hợp dựa trên trạng thái của người dùng, cung cấp trải nghiệm người dùng mượt mà và nhất quán.
