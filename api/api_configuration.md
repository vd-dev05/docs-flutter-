# Hướng dẫn Cấu hình API và Biến Môi trường

Tài liệu này mô tả cách Blablo App quản lý tất cả các API endpoints và thông tin nhạy cảm thông qua hệ thống biến môi trường tập trung.

## Tổng quan

Ứng dụng sử dụng một hệ thống tập trung để quản lý tất cả các cấu hình, bao gồm:
- API endpoints
- Khóa API (API keys)
- Thông tin xác thực (Authentication credentials)
- Cấu hình Firebase
- Cờ tính năng (Feature flags)

Mô hình này giúp:
- Bảo mật thông tin nhạy cảm
- Dễ dàng thay đổi giữa các môi trường (development, staging, production)
- Quản lý tập trung tất cả các cấu hình

## Cấu trúc hệ thống

### 1. Lớp Tập trung: `EnvironmentConfig`

`EnvironmentConfig` (trong `lib/core/config/environment_config.dart`) là lớp chính chứa tất cả các getter và setter cho mọi cấu hình. Lớp này đọc các giá trị từ các file `.env`.

### 2. Các lớp Config cho từng module:

Mỗi tính năng có một lớp config riêng, lấy giá trị từ `EnvironmentConfig`:

- `StoryConfig`: Cấu hình cho tính năng Story
- `UserConfig`: Cấu hình cho tính năng User
- `VocabularyConfig`: Cấu hình cho tính năng Vocabulary
- `ScenariosConfig`: Cấu hình cho tính năng Scenarios
- `ThirdPartyConfig`: Cấu hình cho các dịch vụ bên thứ ba

## File Biến Môi trường

Ứng dụng sử dụng hai file biến môi trường chính:

- `.env.development`: Cho môi trường phát triển (development)
- `.env.production`: Cho môi trường sản xuất (production)

**Lưu ý:** Những file này KHÔNG được đưa vào git. Thay vào đó, chúng tôi cung cấp file mẫu (`.env.development.example` và `.env.production.example`).

## Sử dụng trong code

### Cách sử dụng đúng:

```dart
// Sử dụng thông qua module config (khuyến nghị)
import 'package:blablo_app/core/config/story_config.dart';

final storyApiUrl = StoryConfig.apiUrl;

// HOẶC sử dụng trực tiếp từ EnvironmentConfig (nếu cần)
import 'package:blablo_app/core/config/environment_config.dart';

final storyApiUrl = EnvironmentConfig.storyApiUrl;
```

### Thay đổi cấu hình trong runtime (cho testing):

```dart
// Thay đổi URL API Story trong runtime
StoryConfig.updateApiUrl('https://new-api-url.com/stories');

// HOẶC trực tiếp từ EnvironmentConfig
EnvironmentConfig.updateStoryApiUrl('https://new-api-url.com/stories');
```

## Thêm Cấu Hình Mới

Khi cần thêm một cấu hình mới, hãy làm theo các bước sau:

1. Thêm biến môi trường vào file `.env.development.example` và `.env.production.example`
2. Thêm getter (và setter nếu cần) vào lớp `EnvironmentConfig`
3. Thêm getter/setter tương ứng vào lớp config của module (nếu có)
4. Cập nhật tài liệu này

## Danh sách Cấu hình Hiện tại

### Firebase:
- `FIREBASE_API_KEY`: API key của Firebase 
- `PROJECT_ID`: ID của dự án Firebase
- `PROJECT_NUMBER`: Số dự án Firebase
- `STORAGE_BUCKET`: Firebase Storage bucket
- `APP_ID`: ID ứng dụng Android
- `IOS_APP_ID`: ID ứng dụng iOS
- `WEB_APP_ID`: ID ứng dụng Web
- `CLIENT_ID`: Client ID cho OAuth
- `IOS_CLIENT_ID`: Client ID cho iOS

### API Endpoints:
- `STORY_API_URL`: API endpoint cho Story
- `USER_API_URL`: API endpoint cho User
- `VOCAB_API_URL`: API endpoint cho Vocabulary
- `SCENARIOS_API_URL`: API endpoint cho Scenarios
- `ONBOARDING_API_URL`: API endpoint cho Onboarding
- `CANDO_API_URL`: API endpoint cho Can-Do Journey
- `ONBOARDING_CANDO_API_URL`: API endpoint cho Can-Do Onboarding

### Authentication:
- `AUTH_API_KEY`: API key cho authentication
- `SUPABASE_URL`: URL của Supabase
- `SUPABASE_ANON_KEY`: Anonymous key của Supabase
- `GOOGLE_SERVER_CLIENT_ID`: Client ID của Google cho xác thực OAuth

### Third-party APIs:
- `GOOGLE_MAPS_API_KEY`: API key của Google Maps
- `OPENAI_API_KEY`: API key của OpenAI

### Cấu hình tính năng:
- `ENABLE_ANALYTICS`: Bật/tắt analytics
- `APP_ENVIRONMENT`: Môi trường hiện tại (development, production)
- `DEBUG_MODE`: Bật/tắt chế độ debug

## Best Practices

- **KHÔNG BAO GIỜ** hard-code các API URL hoặc khóa API trong code
- Luôn sử dụng lớp config của module (như `StoryConfig`) thay vì truy cập trực tiếp `EnvironmentConfig`
- Đảm bảo các file `.env` không được đưa vào git
- Luôn cập nhật file mẫu khi thêm biến môi trường mới
- Sử dụng các giá trị mặc định hợp lý cho môi trường phát triển
