# Hướng dẫn Cấu hình Xác thực (Authentication)

Tài liệu này mô tả chi tiết về cách Blablo App quản lý các thông tin xác thực và cấu hình đăng nhập cho nhiều nền tảng khác nhau.

## Tổng quan về Xác thực

Ứng dụng Blablo sử dụng nhiều phương thức xác thực khác nhau:

1. **Supabase Authentication**: Phương thức xác thực chính, hoạt động như middleware
2. **Google Sign-In**: Cho phép người dùng đăng nhập bằng tài khoản Google
3. **Facebook Auth**: Cho phép người dùng đăng nhập bằng tài khoản Facebook
4. **Email/Password**: Xác thực truyền thống qua email và mật khẩu

Tất cả thông tin cấu hình xác thực nhạy cảm được lưu trữ trong biến môi trường và truy cập qua `EnvironmentConfig`.

## Cấu hình Supabase

Supabase được sử dụng làm nền tảng xác thực chính và cơ sở dữ liệu. Các thông tin cấu hình được đọc từ biến môi trường:

```dart
// Khởi tạo Supabase
await Supabase.initialize(
  url: EnvironmentConfig.supabaseUrl,
  anonKey: EnvironmentConfig.supabaseAnonKey,
);
```

### Biến môi trường cho Supabase:

- `SUPABASE_URL`: URL của dự án Supabase
- `SUPABASE_ANON_KEY`: Anonymous key (public) của Supabase

## Cấu hình Google Sign-In

Google Sign-In được khởi tạo với serverClientId từ biến môi trường:

```dart
GoogleSignIn(
  scopes: ['openid', 'email', 'profile'],
  serverClientId: EnvironmentConfig.googleServerClientId,
);
```

### Biến môi trường cho Google Sign-In:

- `GOOGLE_SERVER_CLIENT_ID`: Client ID của OAuth 2.0 cho Google Sign-In

## Luồng Xác thực

### Đăng nhập với Google:

1. Khởi tạo GoogleSignIn với thông tin từ biến môi trường
2. Gọi phương thức signIn() để hiển thị giao diện đăng nhập Google
3. Lấy authentication token từ GoogleSignInAuthentication
4. Sử dụng token này để xác thực với Supabase
5. Lưu trữ thông tin người dùng sau khi xác thực thành công

## Xác thực đa nền tảng

Cấu hình xác thực có thể khác nhau giữa các nền tảng (Android, iOS, Web). Tất cả cấu hình đều được quản lý trong file biến môi trường:

- **Android**: Sử dụng `GOOGLE_SERVER_CLIENT_ID`
- **iOS**: Sử dụng `IOS_CLIENT_ID` (nếu khác với Android)
- **Web**: Sử dụng cấu hình Firebase Web và cấu hình OAuth cho Web

## Quản lý bí mật xác thực

### Bảo mật các khóa:
- Tất cả khóa xác thực được lưu trong biến môi trường, không trong code
- File biến môi trường (`.env.development`, `.env.production`) được thêm vào `.gitignore`
- Sử dụng file mẫu (không chứa giá trị thật) để giải thích cấu trúc

### Luân chuyển khóa:
Trong trường hợp khóa bị lộ, quy trình luân chuyển khóa:
1. Tạo khóa mới trong bảng điều khiển Supabase/Google
2. Cập nhật file biến môi trường với khóa mới
3. Triển khai phiên bản mới của ứng dụng

## Các vấn đề thường gặp và cách giải quyết

### Lỗi "Invalid Client ID":
- Kiểm tra giá trị `GOOGLE_SERVER_CLIENT_ID` trong file biến môi trường
- Đảm bảo ID đã được cấu hình trong Google Cloud Console

### Lỗi "URL không hợp lệ" với Supabase:
- Kiểm tra giá trị `SUPABASE_URL` trong file biến môi trường
- Đảm bảo URL đúng định dạng: `https://<project-id>.supabase.co`

### Lỗi xác thực trên các nền tảng khác nhau:
- Đảm bảo đã cấu hình đúng cho mỗi nền tảng (Android, iOS, Web)
- Kiểm tra các giá trị trong `EnvironmentConfig` và đảm bảo chúng được đọc đúng từ file biến môi trường

## Cách sử dụng trong code

```dart
// Khởi tạo GoogleAuthService với Supabase
final googleAuthService = GoogleAuthServiceImpl(
  supabaseClient: Supabase.instance.client,
  // GoogleSignIn sẽ được tạo bên trong với cấu hình từ EnvironmentConfig
);

// Sử dụng để đăng nhập
final user = await googleAuthService.signInWithGoogle();
```

## Kiểm tra cấu hình

Để kiểm tra cấu hình xác thực đúng, thêm các log trong quá trình khởi tạo:

```dart
print('Using Supabase URL: ${EnvironmentConfig.supabaseUrl.substring(0, 15)}...'); // Chỉ in phần đầu URL
print('Google Client ID is configured: ${EnvironmentConfig.googleServerClientId.isNotEmpty}');
```

## Tài liệu tham khảo

- [Supabase Authentication](https://supabase.com/docs/guides/auth)
- [Google Sign-In for Flutter](https://pub.dev/packages/google_sign_in)
- [Flutter dotenv package](https://pub.dev/packages/flutter_dotenv)
