# Hướng dẫn sử dụng Firebase và quản lý cấu hình an toàn

Tài liệu này mô tả chi tiết cách thiết lập và sử dụng Firebase trong dự án Blablo App, đặc biệt tập trung vào việc quản lý file `google-services.json` và các thông tin xác thực liên quan một cách an toàn.

## 1. Giới thiệu về `google-services.json`

File `google-services.json` chứa thông tin cấu hình Firebase cho ứng dụng Android, bao gồm:
- Project ID, Project Number
- API Keys
- Client IDs
- Cấu hình OAuth
- Storage Bucket
- Và các thông tin xác thực khác

**Lưu ý quan trọng**: File này chứa thông tin nhạy cảm và KHÔNG NÊN được đưa lên hệ thống quản lý mã nguồn (Git).

## 2. Thiết lập cấu hình Firebase thông qua biến môi trường

Thay vì sử dụng trực tiếp file `google-services.json`, dự án này sử dụng biến môi trường để quản lý thông tin nhạy cảm:

### 2.1. Cài đặt các package cần thiết

Dự án sử dụng các package sau:
```
firebase_core: ^2.24.2
flutter_dotenv: ^5.2.1
```

### 2.2. Tạo và sử dụng CustomFirebaseOptions

Chúng tôi đã tạo class `CustomFirebaseOptions` để đọc cấu hình Firebase từ biến môi trường:

```dart
// lib/core/config/custom_firebase_options.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:blablo_app/core/config/environment_config.dart';

class CustomFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return android;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return ios;
    }
    throw UnsupportedError('Unsupported platform');
  }

  static FirebaseOptions get android {
    return FirebaseOptions(
      apiKey: EnvironmentConfig.firebaseApiKey,
      appId: EnvironmentConfig.appId,
      messagingSenderId: EnvironmentConfig.projectNumber,
      projectId: EnvironmentConfig.projectId,
      storageBucket: EnvironmentConfig.storageBucket,
    );
  }

  static FirebaseOptions get ios {
    return FirebaseOptions(
      apiKey: EnvironmentConfig.firebaseApiKey,
      appId: EnvironmentConfig.appId, // iOS App ID cần riêng
      messagingSenderId: EnvironmentConfig.projectNumber,
      projectId: EnvironmentConfig.projectId,
      storageBucket: EnvironmentConfig.storageBucket,
      iosClientId: EnvironmentConfig.iosClientId,
      iosBundleId: 'com.blablo.blablo-app',
    );
  }
}
```

### 2.3. Khởi tạo Firebase trong main.dart

Sử dụng `CustomFirebaseOptions` để khởi tạo Firebase:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:blablo_app/core/config/custom_firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: const bool.fromEnvironment('dart.vm.product')
      ? '.env.production'
      : '.env.development');
  
  // Initialize Firebase with options from environment variables
  await Firebase.initializeApp(
    options: CustomFirebaseOptions.currentPlatform,
  );
  
  // Continue with app initialization
  // ...
}
```

## 3. Tạo file cấu hình mẫu an toàn

Để giúp các nhà phát triển mới hiểu cấu trúc của file cấu hình mà không tiết lộ thông tin nhạy cảm, chúng tôi cung cấp file mẫu `google-services.json.example`:

```json
{
  "project_info": {
    "project_number": "YOUR_PROJECT_NUMBER",
    "project_id": "YOUR_PROJECT_ID",
    "storage_bucket": "YOUR_STORAGE_BUCKET"
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "YOUR_MOBILE_SDK_APP_ID",
        "android_client_info": {
          "package_name": "com.blablo.blablo_app"
        }
      },
      "oauth_client": [
        {
          "client_id": "YOUR_CLIENT_ID",
          "client_type": 3
        }
      ],
      "api_key": [
        {
          "current_key": "YOUR_API_KEY"
        }
      ],
      "services": {
        "appinvite_service": {
          "other_platform_oauth_client": []
        }
      }
    }
  ],
  "configuration_version": "1"
}
```

## 4. Biến môi trường cần thiết

Để ứng dụng hoạt động đúng, các biến môi trường sau cần được định nghĩa trong file `.env.development` và `.env.production`:

```
FIREBASE_API_KEY=xxx               # API key của Firebase
PROJECT_ID=xxx                     # ID của dự án Firebase
PROJECT_NUMBER=xxx                 # Số dự án Firebase
STORAGE_BUCKET=xxx                 # Bucket lưu trữ Firebase
APP_ID=xxx                         # ID ứng dụng (khác nhau giữa Android và iOS)
CLIENT_ID=xxx                      # Client ID cho OAuth
IOS_CLIENT_ID=xxx                  # Client ID cho iOS (nếu có)
```

## 5. Onboarding nhà phát triển mới

Khi một nhà phát triển mới tham gia dự án:

1. **Clone repository**: Lấy mã nguồn từ Git
2. **Nhận file cấu hình**: Yêu cầu file `.env.development` từ quản lý dự án
3. **Đặt file vào đúng vị trí**: Đặt file biến môi trường vào thư mục gốc
4. **Tùy chọn**: Nếu cần test trực tiếp với Firebase SDK native, nhận file `google-services.json` hoặc `GoogleService-Info.plist` và đặt vào vị trí tương ứng

## 6. Môi trường CI/CD

Trong môi trường CI/CD, các biến môi trường nên được thiết lập trên hệ thống CI/CD thay vì sử dụng file. Các bước thực hiện:

1. Thiết lập các biến môi trường trong hệ thống CI/CD (GitHub Actions, CircleCI, Jenkins...)
2. Tạo file `.env.production` một cách động trong quá trình build
3. Có thể cân nhắc tạo file `google-services.json` từ biến môi trường nếu cần thiết

## 7. Troubleshooting

### Lỗi "API key not valid"
- Kiểm tra giá trị `FIREBASE_API_KEY` trong file biến môi trường
- Đảm bảo đã load file biến môi trường trước khi khởi tạo Firebase

### Lỗi "FirebaseApp not initialized"
- Đảm bảo đã gọi `Firebase.initializeApp()` trước khi sử dụng bất kỳ dịch vụ Firebase nào
- Kiểm tra log để xem lỗi chi tiết về cấu hình

## 8. Tài liệu tham khảo

- [Firebase Flutter documentation](https://firebase.flutter.dev/docs/overview)
- [FlutterFire CLI](https://firebase.flutter.dev/docs/cli)
- [Flutter dotenv package](https://pub.dev/packages/flutter_dotenv)
- [Firebase Authentication](https://firebase.flutter.dev/docs/auth/overview)
- [Firebase Security Rules](https://firebase.google.com/docs/rules)
