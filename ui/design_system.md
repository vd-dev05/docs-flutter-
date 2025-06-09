# BlaBló App Design System

Tài liệu này mô tả hệ thống thiết kế (Design System) của ứng dụng BlaBló, tập trung vào các component tái sử dụng và hướng dẫn sử dụng chúng.

## Mục lục

1. [Giới thiệu](#giới-thiệu)
2. [Nguyên tắc thiết kế](#nguyên-tắc-thiết-kế)
3. [Components tái sử dụng](#components-tái-sử-dụng)
   - [AppButton](#appbutton)
   - [AppImage](#appimage)
   - [AppDialog](#appdialog)
   - [BottomSheetDialog](#bottomsheetdialog)
   - [SocialLoginButton](#socialloginbutton)
   - [AppProgressBar](#appprogressbar)
   - [AppCharacter](#appcharacter)
4. [Cách sử dụng](#cách-sử-dụng)
5. [Ví dụ](#ví-dụ)

## Giới thiệu

Design System của BlaBló App được xây dựng để đảm bảo tính nhất quán trong giao diện người dùng và tối ưu hóa quá trình phát triển. Bằng cách sử dụng các component tái sử dụng, chúng ta có thể:

- Giảm thiểu code trùng lặp
- Đảm bảo tính nhất quán trong UI
- Tăng tốc độ phát triển
- Dễ dàng bảo trì và cập nhật

## Nguyên tắc thiết kế

1. **Tính nhất quán**: Sử dụng các component tái sử dụng để đảm bảo giao diện nhất quán.
2. **Tính tái sử dụng**: Thiết kế các component có thể tái sử dụng ở nhiều nơi.
3. **Responsive**: Đảm bảo giao diện hoạt động tốt trên mọi kích thước màn hình.
4. **Dễ sử dụng**: Các component phải dễ dàng tích hợp và sử dụng.
5. **Khả năng mở rộng**: Thiết kế để dễ dàng mở rộng và tùy chỉnh.

## Components tái sử dụng

### AppButton

`AppButton` là component button tái sử dụng với nhiều tùy chọn tùy chỉnh.

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| text | String | Văn bản hiển thị trên button |
| onPressed | VoidCallback? | Callback khi button được nhấn |
| isPrimary | bool | Xác định button là primary (filled) hay secondary (text only) |
| width | double? | Chiều rộng của button. Nếu null, sẽ lấy toàn bộ chiều rộng có sẵn |
| height | double | Chiều cao của button |
| icon | IconData? | Icon hiển thị trước văn bản (tùy chọn) |
| backgroundColor | Color? | Màu nền của button (cho primary button) |
| textColor | Color? | Màu văn bản của button |
| borderRadius | double | Border radius của button |
| isLoading | bool | Hiển thị loading indicator thay vì văn bản |

#### Ví dụ

```dart
// Primary button
AppButton(
  text: "Tiếp tục",
  onPressed: () {
    // Xử lý khi button được nhấn
  },
)

// Secondary button
AppButton(
  text: "Hủy",
  onPressed: () {
    // Xử lý khi button được nhấn
  },
  isPrimary: false,
)

// Button với icon
AppButton(
  text: "Chia sẻ",
  onPressed: () {
    // Xử lý khi button được nhấn
  },
  icon: Icons.share,
)

// Loading button
AppButton(
  text: "Lưu",
  onPressed: () {
    // Xử lý khi button được nhấn
  },
  isLoading: true,
)
```

### AppImage

`AppImage` là component image tái sử dụng với xử lý lỗi và styling nhất quán.

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| imagePath | String | Đường dẫn hình ảnh. Nếu là đường dẫn tương đối, sẽ được thêm tiền tố từ AppConstants.imagePath |
| width | double? | Chiều rộng của hình ảnh |
| height | double? | Chiều cao của hình ảnh |
| fit | BoxFit | Cách fit hình ảnh trong bounds |
| borderRadius | BorderRadius? | Border radius của hình ảnh |
| isCircular | bool | Xác định hình ảnh có hình tròn hay không |
| backgroundColor | Color? | Màu nền khi hình ảnh đang tải hoặc có lỗi |
| errorIcon | IconData | Icon hiển thị khi hình ảnh không tải được |
| errorIconColor | Color | Màu của error icon |
| errorIconSize | double | Kích thước của error icon |

#### Ví dụ

```dart
// Sử dụng cơ bản
AppImage(
  imagePath: 'fox_welcome.png',
  height: 100,
)

// Hình ảnh tròn
AppImage(
  imagePath: 'profile_picture.png',
  height: 50,
  width: 50,
  isCircular: true,
)

// Hình ảnh với xử lý lỗi tùy chỉnh
AppImage(
  imagePath: 'scenario_image.png',
  height: 200,
  width: double.infinity,
  fit: BoxFit.cover,
  borderRadius: BorderRadius.circular(16),
  errorIcon: Icons.image_not_supported,
  errorIconColor: Colors.red,
)
```

### AppDialog

`AppDialog` là component dialog tái sử dụng với styling nhất quán.

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| title | String? | Tiêu đề của dialog |
| content | Widget | Nội dung của dialog |
| primaryButtonText | String? | Văn bản của primary button |
| onPrimaryButtonPressed | VoidCallback? | Callback khi primary button được nhấn |
| secondaryButtonText | String? | Văn bản của secondary button |
| onSecondaryButtonPressed | VoidCallback? | Callback khi secondary button được nhấn |
| showCloseButton | bool | Hiển thị nút đóng ở góc trên bên phải |
| borderRadius | double | Border radius của dialog |
| contentPadding | EdgeInsets | Padding xung quanh nội dung dialog |
| width | double? | Chiều rộng của dialog. Nếu null, sẽ sử dụng chiều rộng mặc định |
| maxHeightFactor | double | Chiều cao tối đa của dialog tính theo tỷ lệ chiều cao màn hình |

#### Ví dụ

```dart
// Sử dụng cơ bản
showDialog(
  context: context,
  builder: (context) {
    return AppDialog(
      title: "Tiêu đề Dialog",
      content: Text("Đây là nội dung dialog."),
      primaryButtonText: "OK",
      onPrimaryButtonPressed: () {
        Navigator.of(context).pop();
      },
    );
  },
);

// Dialog với hai button
showDialog(
  context: context,
  builder: (context) {
    return AppDialog(
      title: "Xác nhận hành động",
      content: Text("Bạn có chắc chắn muốn tiếp tục?"),
      primaryButtonText: "Có",
      onPrimaryButtonPressed: () {
        // Xử lý xác nhận
        Navigator.of(context).pop(true);
      },
      secondaryButtonText: "Không",
      onSecondaryButtonPressed: () {
        Navigator.of(context).pop(false);
      },
    );
  },
);
```

### BottomSheetDialog

`BottomSheetDialog` là component dialog hiển thị từ dưới lên với styling nhất quán.

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| content | Widget | Nội dung của dialog |
| showCloseButton | bool | Hiển thị nút đóng ở góc trên bên phải |
| topBorderRadius | double | Border radius của các góc trên của dialog |
| heightFactor | double | Chiều cao của dialog tính theo tỷ lệ chiều cao màn hình |
| backgroundColor | Color? | Màu nền của dialog |
| gradient | Gradient? | Gradient áp dụng cho nền dialog |

#### Ví dụ

```dart
// Sử dụng cơ bản
showDialog(
  context: context,
  builder: (context) {
    return BottomSheetDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Nội dung bottom sheet"),
          SizedBox(height: 20),
          AppButton(
            text: "Đóng",
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  },
);

// Bottom sheet với gradient
showDialog(
  context: context,
  builder: (context) {
    return BottomSheetDialog(
      heightFactor: 0.6,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white,
          Colors.blue.shade50,
        ],
      ),
      content: YourContent(),
    );
  },
);
```

### SocialLoginButton

`SocialLoginButton` là component button đăng nhập mạng xã hội tái sử dụng.

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| text | String | Văn bản hiển thị trên button |
| onPressed | VoidCallback | Callback khi button được nhấn |
| icon | Widget | Icon hiển thị trước văn bản |
| height | double | Chiều cao của button |
| borderRadius | double | Border radius của button |
| backgroundColor | Color? | Màu nền của button |
| textColor | Color? | Màu văn bản của button |
| borderColor | Color? | Màu viền của button |

#### Factory Constructors

- `SocialLoginButton.google()`: Tạo button đăng nhập Google
- `SocialLoginButton.facebook()`: Tạo button đăng nhập Facebook

#### Ví dụ

```dart
// Button đăng nhập Google
SocialLoginButton.google(
  onPressed: () {
    // Xử lý đăng nhập Google
  },
)

// Button đăng nhập Facebook
SocialLoginButton.facebook(
  onPressed: () {
    // Xử lý đăng nhập Facebook
  },
)

// Button đăng nhập tùy chỉnh
SocialLoginButton(
  text: "Đăng nhập với Twitter",
  onPressed: () {
    // Xử lý đăng nhập Twitter
  },
  icon: Icon(Icons.flutter_dash, color: Colors.blue),
  backgroundColor: Colors.white,
  textColor: Colors.black87,
)
```

### AppProgressBar

`AppProgressBar` là component progress bar tái sử dụng với styling nhất quán.

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| value | double | Giá trị tiến trình hiện tại, từ 0.0 đến 1.0 |
| height | double | Chiều cao của progress bar |
| backgroundColor | Color? | Màu nền của progress bar |
| valueColor | Color? | Màu của progress indicator |
| borderRadius | double | Border radius của progress bar |
| animate | bool | Xác định có animate sự thay đổi tiến trình hay không |
| animationDuration | Duration | Thời gian của animation |

#### Ví dụ

```dart
// Sử dụng cơ bản
AppProgressBar(
  value: 0.5, // 50% tiến trình
)

// Styling tùy chỉnh
AppProgressBar(
  value: 0.75,
  height: 8,
  backgroundColor: Colors.grey.shade100,
  valueColor: Colors.green,
  borderRadius: 4,
)

// Không có animation
AppProgressBar(
  value: 0.33,
  animate: false,
)
```

### AppCharacter

`AppCharacter` là component hiển thị nhân vật (như con cáo) với styling nhất quán.

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| imageFilename | String | Tên file hình ảnh (không có đường dẫn) của nhân vật |
| height | double | Chiều cao của hình ảnh nhân vật |
| width | double? | Chiều rộng của hình ảnh nhân vật. Nếu null, sẽ giữ tỷ lệ khung hình |
| isCircular | bool | Xác định có làm tròn nhân vật hay không |
| backgroundColor | Color? | Màu nền khi hình ảnh đang tải hoặc có lỗi |
| errorIcon | IconData | Icon hiển thị khi hình ảnh không tải được |
| errorIconColor | Color | Màu của error icon |

#### Factory Constructors

- `AppCharacter.hiro()`: Tạo instance của nhân vật cáo Hiro

#### Ví dụ

```dart
// Sử dụng cơ bản
AppCharacter(
  imageFilename: 'fox_welcome.png',
  height: 100,
)

// Sử dụng factory constructor cho Hiro
AppCharacter.hiro(
  height: 80,
)
```

## Cách sử dụng

Để sử dụng các component tái sử dụng trong các màn hình của bạn, hãy làm theo các bước sau:

1. Import barrel file common widgets:

```dart
import 'package:blablo_app/presentation/widgets/common/common_widgets.dart';
```

2. Sử dụng các component trong widget tree của bạn:

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: Text("Màn hình ví dụ")),
    body: Column(
      children: [
        // Progress bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: const AppProgressBar(
            value: 0.5,
          ),
        ),
        
        // Character image
        AppCharacter.hiro(
          height: 100,
        ),
        
        // Button
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: AppButton(
            text: "Tiếp tục",
            onPressed: () {
              // Xử lý khi button được nhấn
            },
          ),
        ),
      ],
    ),
  );
}
```

## Ví dụ

### Login Dialog

Dưới đây là ví dụ về cách sử dụng các component tái sử dụng để tạo dialog đăng nhập:

```dart
class LoginDialog extends StatelessWidget {
  const LoginDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive design
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;

    // Calculate appropriate sizes based on screen width
    final imageHeight = isSmallScreen ? 80.0 : 100.0; // Smaller image
    final buttonHeight = isSmallScreen ? 40.0 : 45.0; // Smaller buttons

    return BottomSheetDialog(
      heightFactor: 0.5, // Half the screen height
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white,
          Colors.pink.shade50,
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Fox image with heart
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: AppImage(
              imagePath: 'hiro_heart_transparent.png',
              height: imageHeight,
            ),
          ),

          // Welcome text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Column(
              children: [
                Text(
                  "Hey hey! You're back!",
                  style: TextStyle(
                    fontSize: isSmallScreen ? 18 : 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                Text(
                  'Adventure continues 🚀',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 14,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Google sign in button
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
            child: SocialLoginButton.google(
              height: buttonHeight,
              onPressed: () => _handleGoogleSignIn(context),
            ),
          ),

          // Facebook sign in button
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            child: SocialLoginButton.facebook(
              height: buttonHeight,
              onPressed: () => _handleFacebookSignIn(context),
            ),
          ),
        ],
      ),
    );
  }

  void _handleGoogleSignIn(BuildContext context) {
    // Xử lý đăng nhập Google
  }

  void _handleFacebookSignIn(BuildContext context) {
    // Xử lý đăng nhập Facebook
  }
}
```
