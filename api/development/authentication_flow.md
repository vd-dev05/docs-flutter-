# Authentication Flow

Tài liệu này mô tả chi tiết quy trình xác thực (Authentication) trong BlaBló App, bao gồm đăng nhập, đăng ký, và xử lý token.

## Overview

BlaBló App hỗ trợ các phương thức xác thực sau:

1. Email/Password Authentication
2. Google Sign-In
3. Facebook Sign-In
4. Apple Sign-In (iOS only)
5. Guest/Anonymous Authentication

## Authentication Architecture

```
┌──────────────────┐     ┌──────────────────┐     ┌──────────────────┐
│                  │     │                  │     │                  │
│  Auth UI Widgets │────▶│  Auth Bloc/Cubit │────▶│   Auth UseCase   │
│                  │     │                  │     │                  │
└──────────────────┘     └──────────────────┘     └──────────────────┘
                                                          │
                                                          │
                                                          ▼
┌──────────────────┐     ┌──────────────────┐     ┌──────────────────┐
│                  │     │                  │     │                  │
│   Secure Store   │◀───▶│  Auth Repository │◀───▶│ Auth DataSource  │
│                  │     │                  │     │                  │
└──────────────────┘     └──────────────────┘     └──────────────────┘
                                                          │
                                                          │
                                                          ▼
                                                 ┌──────────────────┐
                                                 │                  │
                                                 │     API/SDK      │
                                                 │                  │
                                                 └──────────────────┘
```

## Sign-Up Flow

### Email/Password Registration

1. Người dùng nhập email, mật khẩu và thông tin hồ sơ
2. Client kiểm tra validation (email hợp lệ, mật khẩu đủ mạnh)
3. Client gửi request đến `/api/auth/register`
4. Server tạo user mới, băm mật khẩu, lưu vào database
5. Server trả về access token, refresh token và thông tin user
6. Client lưu tokens vào secure storage
7. Client cập nhật AuthState và chuyển hướng người dùng

### Social Registration (Google, Facebook, Apple)

1. Người dùng chọn đăng nhập bằng social provider
2. Client khởi tạo OAuth flow với provider (thông qua SDK)
3. Người dùng đăng nhập vào provider và cấp quyền
4. Provider trả về access token hoặc ID token
5. Client gửi token đến backend (`/api/auth/social/{provider}`)
6. Server xác thực token với provider
7. Server tìm kiếm user theo email hoặc tạo mới nếu chưa tồn tại
8. Server trả về application token và user info
9. Client lưu token và cập nhật state

## Login Flow

### Email/Password Login

1. Người dùng nhập email và mật khẩu
2. Client gửi request đến `/api/auth/login`
3. Server xác thực thông tin đăng nhập
4. Server tạo access token và refresh token
5. Server trả về tokens và thông tin user
6. Client lưu tokens vào secure storage và cập nhật state

### Social Login

Tương tự như Social Registration, nhưng Server sẽ kiểm tra xem user đã tồn tại chưa:
- Nếu đã tồn tại, login thành công
- Nếu chưa tồn tại, có thể tự động đăng ký hoặc yêu cầu bổ sung thông tin

### Guest/Anonymous Authentication

1. Client gửi request đến `/api/auth/anonymous`
2. Server tạo temporary user ID và token giới hạn
3. Client lưu token và sử dụng cho các request không yêu cầu authenticated user

## Token Management

### Token Storage

BlaBló App lưu trữ tokens bằng `flutter_secure_storage`:

```dart
class TokenManager {
  static const _keyAccessToken = 'access_token';
  static const _keyRefreshToken = 'refresh_token';
  static const _keyTokenExpiry = 'token_expiry';
  
  final FlutterSecureStorage _secureStorage;
  
  TokenManager(this._secureStorage);
  
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required DateTime expiryTime,
  }) async {
    await _secureStorage.write(key: _keyAccessToken, value: accessToken);
    await _secureStorage.write(key: _keyRefreshToken, value: refreshToken);
    await _secureStorage.write(
      key: _keyTokenExpiry,
      value: expiryTime.millisecondsSinceEpoch.toString(),
    );
  }
  
  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: _keyAccessToken);
  }
  
  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _keyRefreshToken);
  }
  
  Future<bool> isTokenExpired() async {
    final expiryString = await _secureStorage.read(key: _keyTokenExpiry);
    if (expiryString == null) return true;
    
    final expiryTime = DateTime.fromMillisecondsSinceEpoch(int.parse(expiryString));
    return DateTime.now().isAfter(expiryTime);
  }
  
  Future<void> clearTokens() async {
    await _secureStorage.delete(key: _keyAccessToken);
    await _secureStorage.delete(key: _keyRefreshToken);
    await _secureStorage.delete(key: _keyTokenExpiry);
  }
}
```

### Token Refresh

Khi access token hết hạn, BlaBló App sẽ tự động refresh:

```dart
class TokenInterceptor extends Interceptor {
  final TokenManager _tokenManager;
  final AuthRepository _authRepository;
  final Dio _dio;
  
  TokenInterceptor(this._tokenManager, this._authRepository, this._dio);
  
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final accessToken = await _tokenManager.getAccessToken();
    
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    
    handler.next(options);
  }
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && err.requestOptions.path != '/api/auth/refresh') {
      try {
        // Try to refresh token
        await _refreshToken();
        
        // Retry original request
        final accessToken = await _tokenManager.getAccessToken();
        final opts = Options(
          method: err.requestOptions.method,
          headers: {...err.requestOptions.headers}
        );
        opts.headers!['Authorization'] = 'Bearer $accessToken';
        
        final response = await _dio.request(
          err.requestOptions.path,
          data: err.requestOptions.data,
          queryParameters: err.requestOptions.queryParameters,
          options: opts,
        );
        
        handler.resolve(response);
        return;
      } catch (e) {
        // Refresh token failed, logout user
        await _authRepository.logout();
        
        // Broadcast logout event
        AuthEvents.logout.broadcast();
      }
    }
    
    handler.next(err);
  }
  
  Future<void> _refreshToken() async {
    final refreshToken = await _tokenManager.getRefreshToken();
    if (refreshToken == null) throw Exception('No refresh token available');
    
    final response = await _dio.post(
      '/api/auth/refresh',
      data: {'refresh_token': refreshToken},
      options: Options(headers: {'Content-Type': 'application/json'}),
    );
    
    if (response.statusCode == 200) {
      await _tokenManager.saveTokens(
        accessToken: response.data['access_token'],
        refreshToken: response.data['refresh_token'],
        expiryTime: DateTime.now().add(Duration(seconds: response.data['expires_in'])),
      );
    } else {
      throw Exception('Failed to refresh token');
    }
  }
}
```

## Authentication State Management

BlaBló App sử dụng AuthBloc để quản lý trạng thái xác thực:

```dart
// Auth Events
abstract class AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;
  
  AuthLoginRequested({required this.email, required this.password});
}

class AuthGoogleLoginRequested extends AuthEvent {}

class AuthFacebookLoginRequested extends AuthEvent {}

class AuthLogoutRequested extends AuthEvent {}

class AuthCheckRequested extends AuthEvent {}

// Auth States
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;
  
  AuthAuthenticated({required this.user});
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  
  AuthError({required this.message});
}

// Auth Bloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;
  final GoogleLoginUseCase _googleLoginUseCase;
  final FacebookLoginUseCase _facebookLoginUseCase;
  final LogoutUseCase _logoutUseCase;
  final CheckAuthStatusUseCase _checkAuthStatusUseCase;
  
  AuthBloc({
    required LoginUseCase loginUseCase,
    required GoogleLoginUseCase googleLoginUseCase,
    required FacebookLoginUseCase facebookLoginUseCase,
    required LogoutUseCase logoutUseCase,
    required CheckAuthStatusUseCase checkAuthStatusUseCase,
  }) : _loginUseCase = loginUseCase,
       _googleLoginUseCase = googleLoginUseCase,
       _facebookLoginUseCase = facebookLoginUseCase,
       _logoutUseCase = logoutUseCase,
       _checkAuthStatusUseCase = checkAuthStatusUseCase,
       super(AuthInitial()) {
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthGoogleLoginRequested>(_onAuthGoogleLoginRequested);
    on<AuthFacebookLoginRequested>(_onAuthFacebookLoginRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthCheckRequested>(_onAuthCheckRequested);
    
    // Auto-check auth status when bloc is created
    add(AuthCheckRequested());
    
    // Listen to custom auth events (e.g., token expiration)
    AuthEvents.logout.stream.listen((_) => add(AuthLogoutRequested()));
  }
  
  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    final result = await _loginUseCase(
      LoginParams(email: event.email, password: event.password),
    );
    
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }
  
  // Similar methods for other events
}
```

## Integration with App Navigation

```dart
class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/login',
            (route) => false,
          );
        } else if (state is AuthAuthenticated) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/home',
            (route) => false,
          );
        }
      },
      builder: (context, state) {
        if (state is AuthInitial || state is AuthLoading) {
          return SplashScreen();
        } else if (state is AuthAuthenticated) {
          return HomePage();
        } else if (state is AuthUnauthenticated || state is AuthError) {
          return LoginPage();
        }
        return Container();
      },
    );
  }
}
```

## Auth Screens

### Login Screen

UI demo cho trang đăng nhập:

```dart
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/logo.png', height: 100),
                  SizedBox(height: 32),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        context.read<AuthBloc>().add(
                          AuthLoginRequested(
                            email: _emailController.text,
                            password: _passwordController.text,
                          ),
                        );
                      }
                    },
                    child: Text('Login'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text('OR'),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  SizedBox(height: 16),
                  SocialLoginButtons(
                    onGooglePressed: () {
                      context.read<AuthBloc>().add(AuthGoogleLoginRequested());
                    },
                    onFacebookPressed: () {
                      context.read<AuthBloc>().add(AuthFacebookLoginRequested());
                    },
                  ),
                  SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/register');
                    },
                    child: Text("Don't have an account? Register"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

## Security Considerations

1. **Secure Storage**: Tokens được lưu trữ trong secure storage, không phải shared preferences
2. **HTTPS**: Tất cả API calls đều sử dụng HTTPS
3. **Token Expiration**: Access tokens có thời hạn ngắn, refresh tokens có thời hạn dài hơn
4. **Token Validation**: Backend xác thực tokens trước mỗi request
5. **Biometric Authentication**: Hỗ trợ xác thực sinh trắc học trên thiết bị hỗ trợ
6. **Logout on Token Error**: Tự động đăng xuất khi refresh token không hợp lệ

## Best Practices

1. **Centralized Auth State**: Một Bloc/Provider duy nhất quản lý trạng thái xác thực
2. **Auto-Login**: Tự động đăng nhập khi có valid token
3. **Deep Links**: Xử lý deep links từ OAuth redirects
4. **Token Renewal**: Tự động renew tokens trước khi hết hạn
5. **Error Handling**: Hiển thị thông báo lỗi thân thiện khi xác thực thất bại
