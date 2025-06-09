# Supabase Integration

Tài liệu này mô tả cách BlaBló App tích hợp với Supabase để quản lý xác thực, cơ sở dữ liệu và lưu trữ.

## Overview

BlaBló sử dụng Supabase cho một số dịch vụ chính:
1. Authentication & Authorization
2. PostgreSQL Database
3. Storage (for images, audio files)
4. Edge Functions

## Setup

### 1. Configuration

Cấu hình Supabase được quản lý qua [biến môi trường](../api_configuration.md):

```
SUPABASE_URL=https://your-supabase-project.supabase.co
SUPABASE_ANON_KEY=your-public-anon-key
```

### 2. Initialization

Khởi tạo Supabase trong ứng dụng:

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:blablo_app/core/config/environment_config.dart';

await Supabase.initialize(
  url: EnvironmentConfig.supabaseUrl,
  anonKey: EnvironmentConfig.supabaseAnonKey,
);

final supabase = Supabase.instance.client;
```

## Authentication

### Email/Password Authentication

```dart
// Đăng ký
final response = await supabase.auth.signUp(
  email: 'user@example.com',
  password: 'password',
);

// Đăng nhập
final response = await supabase.auth.signInWithPassword(
  email: 'user@example.com',
  password: 'password',
);

// Đăng xuất
await supabase.auth.signOut();
```

### Social Authentication

```dart
// Google Sign-in
final response = await supabase.auth.signInWithOAuth(
  Provider.google,
  redirectTo: kIsWeb ? null : 'io.supabase.blablo://login-callback/',
);

// Facebook Sign-in
final response = await supabase.auth.signInWithOAuth(
  Provider.facebook,
  redirectTo: kIsWeb ? null : 'io.supabase.blablo://login-callback/',
);
```

## Database Access

### Stories API

```dart
// Lấy danh sách stories
final data = await supabase
  .from('playlists')
  .select('*')
  .order('created_at', ascending: false);

// Lấy chi tiết story
final story = await supabase
  .from('playlists')
  .select('*, vocabulary(*), conversation(*)')
  .eq('id', storyId)
  .single();
  
// Xóa story
await supabase
  .from('playlists')
  .delete()
  .eq('id', storyId);
```

### Vocabulary API

```dart
// Lấy danh sách từ vựng
final data = await supabase
  .from('vocabulary')
  .select('*');
  
// Thêm từ vựng mới
await supabase
  .from('vocabulary')
  .insert({
    'word': 'example',
    'definition': 'something that serves as a pattern',
    'examples': ['This is an example sentence'],
    'category': 'General',
    'level': 'Beginner'
  });
```

## Storage

### Uploading Files

```dart
// Upload hình ảnh
final fileBytes = await File(imagePath).readAsBytes();
final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
final response = await supabase
  .storage
  .from('profiles')
  .uploadBinary(
    fileName,
    fileBytes,
    fileOptions: const FileOptions(contentType: 'image/jpeg'),
  );
  
// Lấy URL public
final imageUrl = supabase
  .storage
  .from('profiles')
  .getPublicUrl(fileName);
```

### Downloading Files

```dart
// Download audio file
final data = await supabase
  .storage
  .from('audio')
  .download('story_1_audio.mp3');
```

## Real-time Subscriptions

```dart
// Subscribe to changes in vocabulary items
final subscription = supabase
  .from('vocabulary')
  .stream(primaryKey: ['id'])
  .eq('user_id', currentUserId)
  .listen((data) {
    // Handle updated data
    print('Vocabulary updated: $data');
  });
  
// Later, unsubscribe
subscription.cancel();
```

## Error Handling

```dart
try {
  // Supabase operation
  final response = await supabase.from('users').select();
} catch (error) {
  if (error is PostgrestException) {
    // Handle database error
    print('Database error: ${error.message}');
  } else if (error is AuthException) {
    // Handle auth error
    print('Auth error: ${error.message}');
  } else {
    // Handle other errors
    print('Unexpected error: $error');
  }
}
```

## Best Practices

1. **Security**: Luôn sử dụng Row Level Security (RLS) trên Supabase để bảo vệ dữ liệu
2. **Performance**: Sử dụng `.select()` với các trường cần thiết thay vì `*` khi làm việc với bảng lớn
3. **Caching**: Implement caching cho dữ liệu ít thay đổi
4. **Error Handling**: Xử lý lỗi cụ thể dựa trên các loại ngoại lệ khác nhau
5. **Session Management**: Sử dụng `onAuthStateChange` để theo dõi trạng thái xác thực
