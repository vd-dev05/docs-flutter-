# Error Handling

Tài liệu này mô tả cách BlaBló App xử lý và quản lý lỗi trong quá trình gọi API và xử lý dữ liệu.

## Taxonomy of Errors

BlaBló App phân loại các lỗi thành các nhóm chính sau:

1. **Network Errors**: Lỗi kết nối, timeout, DNS failure, etc.
2. **Server Errors**: HTTP 500 errors, API trả về lỗi
3. **Client Errors**: HTTP 400 errors, lỗi validation, authentication
4. **Cache Errors**: Lỗi khi đọc/ghi dữ liệu local
5. **Parse Errors**: Lỗi khi parse JSON hoặc các data formats khác
6. **Business Logic Errors**: Lỗi về quy tắc nghiệp vụ

## Exception Model

BlaBló App sử dụng một hệ thống exception phân cấp:

```dart
// Base exception class
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  const AppException({
    required this.message,
    this.code,
    this.details,
  });

  @override
  String toString() => 'AppException: $message (code: $code)';
}

// Network related exceptions
class NetworkException extends AppException {
  const NetworkException(
    String message, {
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

class ServerException extends AppException {
  final int statusCode;

  const ServerException({
    required String message,
    required this.statusCode,
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

class ConnectionException extends NetworkException {
  const ConnectionException({
    String message = 'No internet connection',
    String? code,
    dynamic details,
  }) : super(message, code: code, details: details);
}

class TimeoutException extends NetworkException {
  const TimeoutException({
    String message = 'Connection timeout',
    String? code,
    dynamic details,
  }) : super(message, code: code, details: details);
}

// Client errors
class ClientException extends AppException {
  final int statusCode;

  const ClientException({
    required String message,
    required this.statusCode,
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

class AuthenticationException extends ClientException {
  const AuthenticationException({
    String message = 'Authentication failed',
    int statusCode = 401,
    String? code,
    dynamic details,
  }) : super(message: message, statusCode: statusCode, code: code, details: details);
}

class ValidationException extends ClientException {
  final Map<String, List<String>>? errors;

  const ValidationException({
    String message = 'Validation failed',
    int statusCode = 422,
    this.errors,
    String? code,
    dynamic details,
  }) : super(message: message, statusCode: statusCode, code: code, details: details);
}

// Cache errors
class CacheException extends AppException {
  const CacheException({
    String message = 'Cache error',
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

// Parse errors
class ParseException extends AppException {
  const ParseException({
    String message = 'Failed to parse data',
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

// Business logic errors
class BusinessException extends AppException {
  const BusinessException({
    required String message,
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}
```

## Error Handling trong NetworkClient

```dart
class NetworkClientImpl implements NetworkClient {
  final Dio _dio;
  
  // Constructor và setup...
  
  @override
  Future<Response> get(String path, {Map<String, dynamic>? queryParams, Options? options}) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParams, options: options);
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw UnknownException(message: e.toString());
    }
  }
  
  AppException _handleDioError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return TimeoutException(details: error);
    }
    
    if (error.type == DioExceptionType.connectionError) {
      return ConnectionException(details: error);
    }
    
    // Server errors (500+)
    if (error.response != null && error.response!.statusCode! >= 500) {
      return ServerException(
        message: error.response?.data['message'] ?? 'Server error',
        statusCode: error.response!.statusCode!,
        details: error.response?.data,
      );
    }
    
    // Client errors (400-499)
    if (error.response != null && error.response!.statusCode! >= 400) {
      // Auth errors
      if (error.response!.statusCode == 401) {
        return AuthenticationException(
          message: error.response?.data['message'] ?? 'Authentication failed',
          details: error.response?.data,
        );
      }
      
      // Validation errors
      if (error.response!.statusCode == 422) {
        Map<String, List<String>>? validationErrors;
        
        if (error.response?.data['errors'] is Map) {
          validationErrors = {};
          (error.response!.data['errors'] as Map).forEach((key, value) {
            validationErrors![key] = (value as List).map((e) => e.toString()).toList();
          });
        }
        
        return ValidationException(
          message: error.response?.data['message'] ?? 'Validation failed',
          errors: validationErrors,
          details: error.response?.data,
        );
      }
      
      return ClientException(
        message: error.response?.data['message'] ?? 'Client error',
        statusCode: error.response!.statusCode!,
        details: error.response?.data,
      );
    }
    
    return NetworkException(
      error.message ?? 'Unknown network error',
      details: error,
    );
  }
}
```

## Error Handling trong Repository

```dart
class StoryRepositoryImpl implements StoryRepository {
  final StoryRemoteDataSource _remoteDataSource;
  final StoryLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;
  
  StoryRepositoryImpl(this._remoteDataSource, this._localDataSource, this._networkInfo);
  
  @override
  Future<Either<AppException, List<Story>>> getStories() async {
    if (await _networkInfo.isConnected) {
      try {
        final stories = await _remoteDataSource.getStories();
        await _localDataSource.cacheStories(stories);
        return Right(stories);
      } on ServerException catch (e) {
        // Log error
        debugPrint('Server error: ${e.message}');
        
        // Try to get cached data
        try {
          final cachedStories = await _localDataSource.getLastCachedStories();
          return Right(cachedStories);
        } on CacheException catch (e) {
          return Left(e);
        }
      } on NetworkException catch (e) {
        // Log error
        debugPrint('Network error: ${e.message}');
        
        // Try to get cached data
        try {
          final cachedStories = await _localDataSource.getLastCachedStories();
          return Right(cachedStories);
        } on CacheException catch (e) {
          return Left(e);
        }
      }
    } else {
      // Offline mode
      try {
        final cachedStories = await _localDataSource.getLastCachedStories();
        return Right(cachedStories);
      } on CacheException catch (e) {
        return Left(ConnectionException(details: 'No internet and no cached data available'));
      }
    }
  }
}
```

## Error Handling trong Use Cases

```dart
class GetStoriesUseCase {
  final StoryRepository _repository;
  
  GetStoriesUseCase(this._repository);
  
  Future<Either<Failure, List<Story>>> call() async {
    final storiesOrFailure = await _repository.getStories();
    
    return storiesOrFailure.fold(
      (exception) => Left(_mapExceptionToFailure(exception)),
      (stories) {
        if (stories.isEmpty) {
          return const Left(EmptyDataFailure(message: 'No stories available'));
        }
        return Right(stories);
      },
    );
  }
  
  Failure _mapExceptionToFailure(AppException exception) {
    if (exception is ServerException) {
      return ServerFailure(message: exception.message);
    } else if (exception is NetworkException) {
      return NetworkFailure(message: exception.message);
    } else if (exception is CacheException) {
      return CacheFailure(message: exception.message);
    }
    return UnknownFailure(message: exception.message);
  }
}
```

## Error Handling trong BloC/Cubit

```dart
class StoryCubit extends Cubit<StoryState> {
  final GetStoriesUseCase _getStoriesUseCase;
  
  StoryCubit(this._getStoriesUseCase) : super(StoryInitial());
  
  Future<void> getStories() async {
    emit(StoryLoading());
    
    final result = await _getStoriesUseCase();
    
    result.fold(
      (failure) {
        if (failure is NetworkFailure) {
          emit(StoryError(message: failure.message, type: ErrorType.network));
        } else if (failure is ServerFailure) {
          emit(StoryError(message: failure.message, type: ErrorType.server));
        } else if (failure is EmptyDataFailure) {
          emit(StoryEmpty());
        } else {
          emit(StoryError(message: failure.message, type: ErrorType.unknown));
        }
      },
      (stories) => emit(StoryLoaded(stories)),
    );
  }
}
```

## Error Handling trong UI

```dart
class StoryListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Stories')),
      body: BlocBuilder<StoryCubit, StoryState>(
        builder: (context, state) {
          if (state is StoryLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is StoryLoaded) {
            return StoryList(stories: state.stories);
          } else if (state is StoryEmpty) {
            return const EmptyStateWidget(
              icon: Icons.book,
              message: 'No stories yet',
              buttonText: 'Refresh',
              onPressed: () => context.read<StoryCubit>().getStories(),
            );
          } else if (state is StoryError) {
            return ErrorWidget(
              message: state.message,
              type: state.type,
              onRetry: () => context.read<StoryCubit>().getStories(),
            );
          }
          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.read<StoryCubit>().getStories(),
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

class ErrorWidget extends StatelessWidget {
  final String message;
  final ErrorType type;
  final VoidCallback onRetry;

  const ErrorWidget({
    required this.message,
    required this.type,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    String title;
    
    switch (type) {
      case ErrorType.network:
        icon = Icons.wifi_off;
        title = 'Connection Error';
        break;
      case ErrorType.server:
        icon = Icons.cloud_off;
        title = 'Server Error';
        break;
      default:
        icon = Icons.error_outline;
        title = 'Something Went Wrong';
    }
    
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 60, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}
```

## Logging và Monitoring

BlaBló App sử dụng hệ thống logging để theo dõi lỗi:

```dart
class LoggingInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final errorMessage = _formatError(err);
    log.e('API ERROR', error: errorMessage, stackTrace: err.stackTrace);
    
    // Log to Firebase Crashlytics
    FirebaseCrashlytics.instance.recordError(
      err,
      err.stackTrace,
      reason: 'API Error',
      information: [errorMessage],
    );
    
    handler.next(err);
  }
  
  String _formatError(DioException err) {
    return """
      URL: ${err.requestOptions.uri}
      Method: ${err.requestOptions.method}
      Status: ${err.response?.statusCode}
      Response: ${err.response?.data}
      Error: ${err.message}
    """;
  }
}
```

## Best Practices

1. **Consistent Error Types**: Sử dụng hệ thống exception nhất quán
2. **Graceful Degradation**: Luôn có fallback khi có lỗi (e.g., load cached data)
3. **User-Friendly Error Messages**: Hiển thị thông báo lỗi thân thiện với người dùng
4. **Detailed Logging**: Log chi tiết để debug nhưng không hiển thị chi tiết kỹ thuật cho người dùng
5. **Error Recovery**: Cung cấp cơ chế retry và recovery
6. **Offline First**: Thiết kế app để hoạt động offline khi có thể
7. **Error Boundaries**: Sử dụng Flutter error boundaries để tránh crash toàn bộ app
