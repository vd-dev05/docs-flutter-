# Hướng dẫn cấu hình nền tảng cho Blablo App

Tài liệu này cung cấp hướng dẫn chi tiết về cách cấu hình Firebase cho các nền tảng khác nhau (Android, iOS và Web) trong dự án Blablo App.

## 1. Cấu hình Firebase cho Android (Đã cấu hình)

Android đã được cấu hình với các thông tin từ file `google-services.json`. Các giá trị này đã được trích xuất vào biến môi trường:

- `FIREBASE_API_KEY`: API key của Firebase
- `PROJECT_ID`: ID của dự án
- `PROJECT_NUMBER`: Số dự án
- `STORAGE_BUCKET`: Bucket lưu trữ Firebase
- `APP_ID`: ID ứng dụng Android

## 2. Cấu hình Firebase cho iOS (Chưa cấu hình)

### Bước 1: Tạo cấu hình iOS trong Firebase Console

1. Truy cập [Firebase Console](https://console.firebase.google.com/)
2. Chọn dự án của bạn (blablo-app)
3. Nhấp vào biểu tượng iOS để thêm ứng dụng iOS
4. Nhập Bundle ID: `com.blablo.blablo_app` hoặc tùy chỉnh theo nhu cầu
5. Tải xuống file `GoogleService-Info.plist`
6. Đặt file này vào thư mục `ios/Runner/`

### Bước 2: Cập nhật biến môi trường

Cập nhật file `.env.development` và `.env.production` với các giá trị từ `GoogleService-Info.plist`:

```
IOS_APP_ID=<GOOGLE_APP_ID from GoogleService-Info.plist>
IOS_CLIENT_ID=<CLIENT_ID from GoogleService-Info.plist>
```

### Bước 3: Kiểm tra file Info.plist

Đảm bảo file `ios/Runner/Info.plist` chứa cấu hình cần thiết cho Firebase và các API liên quan.

## 3. Cấu hình Firebase cho Web (Chưa cấu hình)

### Bước 1: Tạo cấu hình Web trong Firebase Console

1. Truy cập [Firebase Console](https://console.firebase.google.com/)
2. Chọn dự án của bạn (blablo-app)
3. Nhấp vào biểu tượng Web (</>) để thêm ứng dụng Web
4. Nhập tên ứng dụng (vd: "blablo-web")
5. Tùy chọn thiết lập Firebase Hosting
6. Sao chép thông tin cấu hình (chú ý giá trị `appId` và `apiKey`)

### Bước 2: Cập nhật biến môi trường

Cập nhật file `.env.development` và `.env.production` với giá trị từ cấu hình Web:

```
WEB_APP_ID=<appId from web config>
```

API key có thể dùng chung với Android.

### Bước 3: Kiểm tra index.html

Đảm bảo file `web/index.html` đã được cập nhật với script Firebase cần thiết.

## 4. Xử lý dự phòng trong ứng dụng

Ứng dụng đã được cấu hình để xử lý các trường hợp thiếu cấu hình cho các nền tảng:

1. Nếu không có cấu hình cho iOS hoặc Web, ứng dụng sẽ sử dụng cấu hình Android thay thế
2. Trong `CustomFirebaseOptions`, có kiểm tra và xử lý dự phòng
3. Trong `main.dart`, có kiểm tra tính hợp lệ của cấu hình trước khi khởi tạo Firebase

## 5. Kiểm tra ứng dụng trên nhiều nền tảng

Để kiểm tra ứng dụng trên nhiều nền tảng:

### Android
```
flutter run -d <android-device-id>
```

### iOS (cần cấu hình đầy đủ)
```
flutter run -d <ios-device-id>
```

### Web (cần cấu hình đầy đủ)
```
flutter run -d chrome
```

## 6. Lưu ý về bảo mật

- Không đưa `GoogleService-Info.plist` lên Git (đã được đưa vào `.gitignore`)
- Không đưa các file `.env` chứa khóa API lên Git (đã được đưa vào `.gitignore`)
- Sử dụng các hệ thống quản lý bí mật (secret management) cho CI/CD
