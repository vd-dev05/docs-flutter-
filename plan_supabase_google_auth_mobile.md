# Kế hoạch tích hợp Supabase cho Đăng nhập Google (Mobile)

**Mục tiêu:** Tích hợp chức năng đăng nhập Google sử dụng Supabase cho ứng dụng di động (iOS/Android), tận dụng đoạn mã và cấu trúc dự án hiện có theo kiến trúc Clean Architecture.

**Các bước thực hiện:**

1.  **Kiểm tra và xác nhận Data Source:**
    *   Xem lại lớp [`GoogleAuthServiceImpl`](lib/data/datasources/remote/google_auth_service_impl.dart) để đảm bảo phương thức `signInWithGoogle()` sử dụng `google_sign_in` và `_supabaseClient.auth.signInWithIdToken` đúng như mong muốn cho nền tảng mobile.
    *   Đảm bảo rằng `UserModel.fromSupabaseUser` xử lý đúng dữ liệu trả về từ Supabase để tạo ra `UserModel`. (Dựa trên tên phương thức, có vẻ như bạn đã có một factory constructor hoặc phương thức tĩnh trong `UserModel` để làm điều này).

2.  **Cập nhật Repository:**
    *   Sửa đổi lớp [`AuthRepositoryImpl`](lib/data/repositories/auth_repository_impl.dart) để thêm một dependency là `GoogleAuthDataSource` (hoặc trực tiếp `GoogleAuthService`).
    *   Triển khai phương thức `loginWithGoogle()` trong `AuthRepositoryImpl` bằng cách gọi phương thức `signInWithGoogle()` từ `GoogleAuthDataSource` đã inject. Xử lý các `ServerException` từ data source và chuyển đổi chúng thành `Failure` phù hợp (ví dụ: `ServerFailure`).

3.  **Cập nhật Dependency Injection:**
    *   Cập nhật cấu hình dependency injection (trong thư mục `lib/core/di/` hoặc tương tự) để đăng ký `GoogleAuthServiceImpl` làm triển khai cho `GoogleAuthDataSource` và cung cấp nó cho `AuthRepositoryImpl`.
    *   Đảm bảo `SupabaseClient` được khởi tạo và cung cấp đúng cách cho `GoogleAuthServiceImpl`.

4.  **Kết nối với Use Case:**
    *   Kiểm tra lại [`SignInWithGoogleUseCase`](lib/domain/usecases/sign_in_with_google_usecase.dart) để đảm bảo nó gọi đúng phương thức `loginWithGoogle()` trên `AuthRepository`. (Bước này có vẻ đã đúng dựa trên file đã đọc).

5.  **Kết nối với Presentation Layer:**
    *   Trong màn hình đăng nhập hoặc widget xử lý sự kiện nhấn nút đăng nhập Google (ví dụ: [`lib/presentation/widgets/auth/google_sign_in_button.dart`](lib/presentation/widgets/auth/google_sign_in_button.dart) hoặc logic trong [`lib/presentation/pages/auth/login_screen.dart`](lib/presentation/pages/auth/login_screen.dart)), gọi `SignInWithGoogleUseCase` thông qua Bloc/Cubit hoặc Provider tương ứng.
    *   Xử lý kết quả trả về từ use case (thành công hoặc thất bại) để cập nhật UI hoặc điều hướng người dùng.

6.  **Xử lý trạng thái xác thực (Optional nhưng nên có):**
    *   Sử dụng `supabase.auth.onAuthStateChange` trong các widget cần theo dõi trạng thái đăng nhập (ví dụ: màn hình chính, màn hình splash) để tự động cập nhật UI khi người dùng đăng nhập hoặc đăng xuất. Đoạn mã bạn cung cấp trong `initState` là một ví dụ tốt về cách lắng nghe sự thay đổi trạng thái này.

**Mermaid Diagram:**

```mermaid
graph TD
    A[Presentation Layer] --> B(SignInWithGoogleUseCase)
    B --> C(AuthRepository)
    C --> D(AuthRepositoryImpl)
    D --> E(GoogleAuthDataSource)
    E --> F(GoogleAuthServiceImpl)
    F --> G(google_sign_in)
    F --> H(SupabaseClient)
    H --> I(Supabase Auth)
    G --> F
    I --> F
    F --> D
    D --> C
    C --> B
    B --> A