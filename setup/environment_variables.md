# Hướng dẫn quản lý biến môi trường và thông tin bảo mật

Tài liệu này mô tả cách quản lý các thông tin nhạy cảm như API key, thông tin cấu hình Firebase và các thông tin xác thực khác trong dự án Blablo App.

## 1. Tổng quan

Trong phát triển ứng dụng, việc bảo vệ thông tin nhạy cảm như API keys, secret keys và cấu hình kết nối dịch vụ là cực kỳ quan trọng. Dự án này sử dụng biến môi trường để quản lý các thông tin này thay vì lưu trữ trực tiếp trong mã nguồn.

## 2. Các file cấu hình nhạy cảm

Các file sau đây chứa thông tin nhạy cảm và **KHÔNG ĐƯỢC** đưa lên hệ thống quản lý mã nguồn (Git):

- `android/app/google-services.json` - Cấu hình Firebase cho Android
- `ios/Runner/GoogleService-Info.plist` - Cấu hình Firebase cho iOS
- `.env.development` - Biến môi trường cho môi trường phát triển
- `.env.production` - Biến môi trường cho môi trường sản xuất
- `android/key.properties` - Thông tin key ký ứng dụng Android
- `*.jks` files - File keystore để ký ứng dụng

## 3. Cấu trúc biến môi trường

Project sử dụng package `flutter_dotenv` để quản lý biến môi trường. Các file biến môi trường bao gồm:

### `.env.development`
Chứa các giá trị cho môi trường phát triển (local development):
```
FIREBASE_API_KEY=xxx
PROJECT_ID=blablo-app
PROJECT_NUMBER=153953998403
STORAGE_BUCKET=blablo-app.firebasestorage.app
APP_ID=1:153953998403:android:009da431cbd490f4d1e6f6
CLIENT_ID=404430989854-382labe9un17g0b8gctm4gl2s665gv0p.apps.googleusercontent.com
```

### `.env.production`
Chứa các giá trị cho môi trường sản xuất (production):
```
FIREBASE_API_KEY=xxx
PROJECT_ID=xxx
PROJECT_NUMBER=xxx
STORAGE_BUCKET=xxx
APP_ID=xxx
CLIENT_ID=xxx
```

## 4. Cách sử dụng biến môi trường

Để sử dụng biến môi trường trong code, hãy sử dụng class `EnvironmentConfig` đã được định nghĩa trong `lib/core/config/environment_config.dart`:

```dart
import 'package:blablo_app/core/config/environment_config.dart';

// Ví dụ về việc sử dụng
final apiKey = EnvironmentConfig.firebaseApiKey;
final projectId = EnvironmentConfig.projectId;
```

## 5. Thiết lập môi trường cho nhà phát triển mới

Khi một nhà phát triển mới tham gia dự án, họ cần:

1. Clone dự án từ repository
2. Nhận các file cấu hình nhạy cảm từ quản lý dự án (không qua Git)
3. Đặt các file này vào đúng vị trí:
   - `.env.development` và `.env.production` ở thư mục gốc dự án
   - `google-services.json` trong thư mục `android/app/`
   - `GoogleService-Info.plist` trong thư mục `ios/Runner/`
   - Các file keystore nếu cần thiết

4. Chạy lệnh `flutter pub get` để cài đặt các dependency

## 6. Tạo Firebase Options từ biến môi trường

Project này sử dụng class `CustomFirebaseOptions` thay vì `DefaultFirebaseOptions` được tạo bởi FlutterFire CLI. Class này được định nghĩa trong `lib/core/config/custom_firebase_options.dart` và đọc cấu hình từ biến môi trường.

Để khởi tạo Firebase trong ứng dụng:

```dart
import 'package:blablo_app/core/config/custom_firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

await Firebase.initializeApp(
  options: CustomFirebaseOptions.currentPlatform,
);
```

## 7. Xử lý keystore và key ký ứng dụng

File keystore (`.jks`) và cấu hình key (`key.properties`) được sử dụng để ký ứng dụng Android khi tạo phiên bản phát hành. Những file này cũng chứa thông tin nhạy cảm và không nên đưa vào Git.

Thay vào đó, trong CI/CD pipeline, các biến môi trường nên được sử dụng để tạo những file này một cách động.

## 8. Best practices

- **Không bao giờ** commit file cấu hình nhạy cảm lên Git
- **Luôn** kiểm tra `.gitignore` để đảm bảo các file nhạy cảm được loại trừ
- Cung cấp file mẫu (ví dụ: `google-services.json.example`) để các nhà phát triển biết cấu trúc file
- Sử dụng các hệ thống quản lý bí mật (secret management) như Vault, AWS Secrets Manager hoặc Google Secret Manager cho môi trường CI/CD

## 9. Tài liệu tham khảo

- [Flutter dotenv package](https://pub.dev/packages/flutter_dotenv)
- [Firebase Flutter setup](https://firebase.flutter.dev/docs/overview)
- [Flutter environment configuration](https://flutter.dev/docs/deployment/flavors)
