# API Request Flow

Tài liệu này mô tả quy trình xử lý API request trong BlaBló App, từ UI đến repository và network layer.

## Overview

BlaBló App sử dụng mô hình Clean Architecture với 3 lớp chính:
1. **Presentation Layer**: UI và ViewModels/Blocs
2. **Domain Layer**: Use Cases và Business Logic
3. **Data Layer**: Repositories và Data Sources

## Request Flow Diagram

```
┌────────────┐     ┌──────────┐     ┌────────────┐     ┌───────────────┐     ┌──────────────┐
│            │     │          │     │            │     │               │     │              │
│ UI Widget  │────▶│  Bloc/   │────▶│  UseCase   │────▶│  Repository   │────▶│  Data Source │
│            │     │ Provider │     │            │     │               │     │              │
└────────────┘     └──────────┘     └────────────┘     └───────────────┘     └──────────────┘
                                                                                     │
                                                                                     │
                                                                                     ▼
                                                                           ┌──────────────────┐
                                                                           │                  │
                                                                           │  Network Client  │
                                                                           │                  │
                                                                           └──────────────────┘
                                                                                     │
                                                                                     │
                                                                                     ▼
                                                                           ┌──────────────────┐
                                                                           │                  │
                                                                           │      API         │
                                                                           │                  │
                                                                           └──────────────────┘
```

## Detailed Flow

### 1. UI Layer

UI widgets sử dụng Bloc/Provider để gọi events/methods và hiển thị states/data:

```dart
ElevatedButton(
  onPressed: () {
    context.read<StoryBloc>().add(LoadStoriesEvent());
  },
  child: Text('Load Stories'),
),

// Hiển thị state
BlocBuilder<StoryBloc, StoryState>(
  builder: (context, state) {
    if (state is StoryLoadingState) {
      return CircularProgressIndicator();
    } else if (state is StoryLoadedState) {
      return StoryList(stories: state.stories);
    } else if (state is StoryErrorState) {
      return Text('Error: ${state.message}');
    }
    return Container();
  },
),
```

### 2. State Management Layer (Bloc/Provider)

Blocs hoặc Providers xử lý events/methods và gọi use cases:

```dart
class StoryBloc extends Bloc<StoryEvent, StoryState> {
  final GetStoriesUseCase _getStoriesUseCase;
  
  StoryBloc(this._getStoriesUseCase) : super(StoryInitialState()) {
    on<LoadStoriesEvent>(_onLoadStories);
  }
  
  Future<void> _onLoadStories(LoadStoriesEvent event, Emitter<StoryState> emit) async {
    emit(StoryLoadingState());
    
    try {
      final stories = await _getStoriesUseCase();
      emit(StoryLoadedState(stories));
    } catch (e) {
      emit(StoryErrorState(e.toString()));
    }
  }
}
```

### 3. Domain Layer (Use Cases)

Use Cases chứa business logic và gọi repositories:

```dart
class GetStoriesUseCase {
  final StoryRepository _storyRepository;
  
  GetStoriesUseCase(this._storyRepository);
  
  Future<List<Story>> call() async {
    return await _storyRepository.getStories();
  }
}
```

### 4. Data Layer (Repositories)

Repositories triển khai các abstract repository interfaces từ Domain layer:

```dart
class StoryRepositoryImpl implements StoryRepository {
  final StoryRemoteDataSource _remoteDataSource;
  final StoryLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;
  
  StoryRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._networkInfo,
  );
  
  @override
  Future<List<Story>> getStories() async {
    if (await _networkInfo.isConnected) {
      try {
        final remoteStories = await _remoteDataSource.getStories();
        _localDataSource.cacheStories(remoteStories);
        return remoteStories;
      } catch (e) {
        return _localDataSource.getLastCachedStories();
      }
    } else {
      return _localDataSource.getLastCachedStories();
    }
  }
}
```

### 5. Data Sources

Data Sources thực hiện các thao tác thực tế với API hoặc local storage:

```dart
class StoryRemoteDataSourceImpl implements StoryRemoteDataSource {
  final NetworkClient _client;
  
  StoryRemoteDataSourceImpl(this._client);
  
  @override
  Future<List<Story>> getStories() async {
    final response = await _client.get(
      ApiEndpoints.stories,
      headers: {'Content-Type': 'application/json'},
    );
    
    if (response.statusCode == 200) {
      return (response.data['data'] as List)
          .map((json) => Story.fromJson(json))
          .toList();
    } else {
      throw ServerException(
        message: response.data['message'] ?? 'Unknown error',
        statusCode: response.statusCode,
      );
    }
  }
}
```

### 6. Network Client

Network Client là wrapper cho HTTP client (Dio, http, etc.) và xử lý các request/response:

```dart
class NetworkClientImpl implements NetworkClient {
  final Dio _dio;
  final EnvironmentConfig _config;
  
  NetworkClientImpl(this._dio, this._config) {
    _dio.options.baseUrl = _config.apiBaseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
    
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
    
    _dio.interceptors.add(TokenInterceptor());
  }
  
  @override
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  // Other methods (post, put, delete) and error handling
}
```

## Xử lý lỗi

BlaBló App sử dụng một hệ thống xử lý lỗi nhất quán qua các layer:

1. **Network Errors**: Được xử lý trong NetworkClient và chuyển đổi thành ServerException
2. **Repository Errors**: Quyết định fetch local data hay throw exception
3. **UseCase Errors**: Có thể xử lý logic business trước khi throw exception
4. **Bloc/Provider Errors**: Chuyển đổi exceptions thành error states
5. **UI Errors**: Hiển thị error states theo cách thân thiện với người dùng

```dart
// Network error handling
Exception _handleError(dynamic error) {
  if (error is DioException) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return const TimeoutException('Connection timeout');
    }
    
    if (error.response != null) {
      return ServerException(
        message: error.response?.data['message'] ?? error.message,
        statusCode: error.response?.statusCode ?? -1,
      );
    }
    
    return const NetworkException('Network error');
  }
  
  return Exception('Unexpected error');
}
```

## Best Practices

1. **Separation of Concerns**: Mỗi layer chỉ làm nhiệm vụ của mình
2. **Dependency Injection**: Sử dụng DI để dễ dàng test và mở rộng
3. **Error Handling**: Xử lý lỗi ở mỗi layer với cách tiếp cận phù hợp
4. **Logging**: Log request/response ở NetworkClient layer để dễ debug
5. **Caching**: Cache data ở Repository layer để hoạt động offline
6. **Retry Logic**: Implement retry logic cho các API calls quan trọng
7. **Cancellation**: Cancel requests khi không cần thiết nữa
8. **Pagination**: Implement pagination cho các danh sách lớn
