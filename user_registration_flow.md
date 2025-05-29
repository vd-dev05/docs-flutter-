# Quy trình đăng ký người dùng BlaBlo

## Tổng quan quy trình

1. Người dùng hoàn thành khảo sát Can-Do (5 bước)
2. Thông tin Can-Do được lưu trong CanDoBloc
3. Người dùng đăng nhập thông qua Google/Facebook trong SignupScreen
4. Thông tin đăng nhập và Can-Do được gộp lại
5. Payload kết hợp được gửi đến API `/api/v1/users/register`

## Luồng dữ liệu chi tiết

### Thu thập dữ liệu Can-Do
- Mỗi lựa chọn của người dùng được lưu trong `_userSelections` trong `CanDoOnboardingPage`
- Sau khi hoàn thành, tất cả lựa chọn được đóng gói thành dữ liệu tổng hợp:
  ```json
  {
    "user_id": "deviceId",
    "device_id": "deviceId",
    "selections": [
      {
        "step_id": "step_id_1",
        "title": "Tiêu đề câu hỏi 1",
        "description": "Mô tả câu hỏi 1",
        "selected_value": "Giá trị đã chọn",
        "timestamp": "2025-05-19T10:30:00Z"
      },
      ...
    ],
    "completed_at": "2025-05-19T10:35:00Z"
  }
  ```
- Dữ liệu này được lưu vào `CanDoBloc` thông qua event `SaveCanDoSelectionEvent`

### Đăng nhập người dùng
- Người dùng đăng nhập qua Google/Facebook trong `SignupScreen`
- Khi đăng nhập thành công, thông tin người dùng được lưu trong `LoginBloc` với state `LoginSuccess`
- Thông tin người dùng bao gồm:
  ```json
  {
    "id": "id_từ_provider",
    "email": "email@example.com",
    "name": "Tên người dùng",
    "avatar_url": "https://example.com/avatar.jpg",
    "provider": "google|facebook"
  }
  ```

### Kết hợp dữ liệu
- Phương thức `_combineUserDataAndNavigate()` trong `SignupScreen` sẽ gộp cả hai nguồn dữ liệu
- Payload kết hợp có dạng:
  ```json
  {
    "user": {
      "id": "id_từ_provider",
      "email": "email@example.com",
      "name": "Tên người dùng",
      "avatar_url": "https://example.com/avatar.jpg",
      "provider": "google|facebook"
    },
    "cando_data": {
      "user_id": "deviceId",
      "device_id": "deviceId",
      "selections": [...],
      "completed_at": "2025-05-19T10:35:00Z"
    },
    "timestamp": "2025-05-19T10:40:00Z"
  }
  ```

### Gửi API
- Payload kết hợp được gửi đến API endpoint `/api/v1/users/register`
- Sử dụng phương thức POST với header Content-Type: application/json
- Sau khi gửi thành công, dữ liệu Can-Do được xóa khỏi CanDoBloc bằng event `ClearCanDoDataEvent`

## Mã nguồn liên quan

### SignupScreen._combineUserDataAndNavigate()
```dart
void _combineUserDataAndNavigate(BuildContext context) {
  // Get the user data from the LoginBloc
  final loginBloc = context.read<LoginBloc>();
  final loginState = loginBloc.state;

  // Get the Can-Do data from CanDoBloc
  final canDoBloc = context.read<CanDoBloc>();
  final canDoState = canDoBloc.state;

  if (loginState is LoginSuccess) {
    final user = loginState.user;

    // Nếu có dữ liệu Can-Do
    if (canDoState is CanDoDataSaved) {
      // Tạo payload gộp
      final combinedPayload = {
        'user': {
          'id': user.id,
          'email': user.email,
          'name': user.name,
          'avatar_url': user.avatarUrl,
          'provider': user.provider,
        },
        'cando_data': canDoState.data,
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Gửi payload tới API
      _sendCombinedDataToApi(combinedPayload);

      // Xóa dữ liệu Can-Do đã sử dụng
      canDoBloc.add(ClearCanDoDataEvent());
    }

    // Navigate to home screen
    NavigationHelper.navigateToAndRemoveUntil(context, const HomeScreen());
  } else {
    // If we don't have user data, just navigate
    NavigationHelper.navigateToAndRemoveUntil(context, const HomeScreen());
  }
}
```

### SignupScreen._sendCombinedDataToApi()
```dart
Future<void> _sendCombinedDataToApi(Map<String, dynamic> payload) async {
  try {
    const apiUrl = 'https://api.blablo.co/api/v1/users/register';
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode(payload),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Combined data sent successfully!');
      print('Response: ${response.body}');
    } else {
      print('Failed to send combined data: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  } catch (e) {
    print('Error sending combined data: $e');
  }
}
```
