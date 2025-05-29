# Hướng dẫn triển khai an toàn cho ứng dụng Blablo

Tài liệu này cung cấp hướng dẫn về cách triển khai ứng dụng Blablo App từ môi trường phát triển đến môi trường sản xuất một cách an toàn, đặc biệt tập trung vào việc quản lý thông tin nhạy cảm.

## 1. Quy trình phát hành ứng dụng

### 1.1. Môi trường phát triển (Development)

Trong môi trường phát triển, ứng dụng sử dụng file `.env.development` để cấu hình các biến môi trường. Những giá trị này thường trỏ đến các dịch vụ phát triển (development services).

### 1.2. Môi trường dàn dựng (Staging)

Môi trường dàn dựng là môi trường trung gian giữa phát triển và sản xuất. Nó nên sử dụng cấu hình tương tự như môi trường sản xuất nhưng trên các dịch vụ riêng biệt.

### 1.3. Môi trường sản xuất (Production)

Trong môi trường sản xuất, ứng dụng sử dụng file `.env.production` hoặc biến môi trường được thiết lập trong CI/CD.

## 2. Ký ứng dụng Android (App signing)

### 2.1. Tạo và quản lý keystore

Để phát hành ứng dụng Android, bạn cần một keystore để ký ứng dụng:

```bash
keytool -genkey -v -keystore my-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias key
```

**Quan trọng**: File keystore (.jks) và thông tin liên quan KHÔNG ĐƯỢC đưa vào Git. Thay vào đó, lưu trữ an toàn và chia sẻ thông qua các kênh bảo mật.

### 2.2. Cấu hình key.properties

Tạo file `android/key.properties` với nội dung:

```
storePassword=<mật khẩu keystore>
keyPassword=<mật khẩu key>
keyAlias=key
storeFile=<đường dẫn tới file keystore>
```

**Lưu ý**: File này cũng phải được thêm vào .gitignore

### 2.3. Cấu hình build.gradle

File `android/app/build.gradle.kts` cần được cấu hình để sử dụng keystore khi build phiên bản phát hành:

```kotlin
val keystoreProperties = java.util.Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(java.io.FileInputStream(keystorePropertiesFile))
}

android {
    // ...
    
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }
    
    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            // ...
        }
    }
}
```

## 3. Quy trình CI/CD an toàn

### 3.1. Biến môi trường trong CI/CD

Các thông tin nhạy cảm nên được lưu trữ dưới dạng biến môi trường hoặc secrets trong hệ thống CI/CD:

- GitHub Actions: Sử dụng GitHub Secrets
- GitLab CI: Sử dụng GitLab CI/CD Variables
- CircleCI: Sử dụng Environment Variables hoặc Context

### 3.2. Tạo file cấu hình động

Trong pipeline CI/CD, tạo file cấu hình từ biến môi trường:

```bash
# Tạo .env.production
echo "FIREBASE_API_KEY=$FIREBASE_API_KEY" >> .env.production
echo "PROJECT_ID=$PROJECT_ID" >> .env.production
echo "PROJECT_NUMBER=$PROJECT_NUMBER" >> .env.production
# ...

# Tạo google-services.json nếu cần
cat > android/app/google-services.json << EOL
{
  "project_info": {
    "project_number": "$PROJECT_NUMBER",
    "project_id": "$PROJECT_ID",
    "storage_bucket": "$STORAGE_BUCKET"
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "$APP_ID",
        "android_client_info": {
          "package_name": "com.blablo.blablo_app"
        }
      },
      "oauth_client": [
        {
          "client_id": "$CLIENT_ID",
          "client_type": 3
        }
      ],
      "api_key": [
        {
          "current_key": "$FIREBASE_API_KEY"
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
EOL
```

### 3.3. Tạo keystore động

Trong một số trường hợp, bạn có thể cần tạo keystore động từ thông tin được mã hóa:

```bash
# Base64 decode keystore
echo "$ENCODED_KEYSTORE" | base64 --decode > android/app/my-release-key.jks

# Tạo key.properties
cat > android/key.properties << EOL
storePassword=$KEYSTORE_PASSWORD
keyPassword=$KEY_PASSWORD
keyAlias=key
storeFile=../app/my-release-key.jks
EOL
```

## 4. Xác thực người dùng và bảo mật

### 4.1. Bảo mật Authentication

Khi triển khai xác thực Firebase:
- Đảm bảo client_id và API key được quản lý an toàn
- Cấu hình whitelist domain cho OAuth trong Firebase console
- Kích hoạt captcha cho các phương thức xác thực nhạy cảm

### 4.2. Bảo mật Firestore/Database

- Thiết lập Security Rules chặt chẽ
- Sử dụng Firebase Authentication kết hợp với Security Rules
- Kiểm tra quyền truy cập dựa trên ID người dùng

## 5. Xử lý sự cố và khôi phục

### 5.1. Xử lý khi bị lộ thông tin nhạy cảm

Nếu thông tin nhạy cảm bị lộ:
1. Luân chuyển tất cả API keys, client secrets
2. Tạo keystore mới nếu cần thiết
3. Cập nhật các biến môi trường và file cấu hình
4. Kiểm tra nhật ký truy cập để phát hiện sử dụng trái phép

### 5.2. Kế hoạch khôi phục

Luôn có sẵn kế hoạch khôi phục:
- Lưu trữ keystore dự phòng an toàn
- Ghi lại quy trình tạo lại tất cả các thông tin xác thực
- Có sẵn danh sách liên hệ để thông báo vi phạm bảo mật

## 6. Các biện pháp bảo mật khuyến nghị

- Sử dụng mã hóa đầu cuối (end-to-end encryption) cho dữ liệu nhạy cảm
- Thực hiện kiểm tra bảo mật định kỳ
- Cập nhật thường xuyên các dependencies để vá lỗ hổng
- Kích hoạt Google Play App Signing để bảo vệ keystore
- Sử dụng Firebase App Check để ngăn chặn truy cập trái phép đến dịch vụ
- Cân nhắc sử dụng Firebase Security Rules Simulator để kiểm tra quy tắc bảo mật
