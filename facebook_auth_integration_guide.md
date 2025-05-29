# Facebook Authentication Integration Guide

This document outlines how to integrate Facebook authentication with Supabase in the BlaBlo application, including important limitations and solutions.

## Important Note: Supabase Limitation

Supabase has an important limitation regarding Facebook integration:

**The `signInWithIdToken` method only supports Google, Apple, Kakao, and Keycloak providers, but not Facebook.**

This means you cannot use the Facebook access token directly with Supabase like you can with Google. When attempting to do so, you'll receive this error:
```
Provider must be google, apple, kakao or keycloak.
```

## Recommended Solution

Use Supabase's OAuth flow instead of token-based authentication:

```dart
await supabaseClient.auth.signInWithOAuth(
  OAuthProvider.facebook,
  redirectTo: null, // Or your custom deep link
  authScreenLaunchMode: LaunchMode.externalApplication,
  scopes: 'email,public_profile',
);
```

This will:
1. Open a browser for the user to authenticate with Facebook
2. Handle the OAuth flow and redirects
3. Create the user session in Supabase automatically

## Bước 1: Tạo ứng dụng Facebook

1. Đăng nhập vào [Facebook Developers](https://developers.facebook.com/)
2. Tạo một ứng dụng mới bằng cách chọn "Create App"
3. Chọn loại ứng dụng (Consumer)
4. Điền thông tin ứng dụng và nhấn "Create App"

## Bước 2: Cấu hình Facebook Login

1. Trong trang Dashboard của ứng dụng, chọn "Add Product"
2. Chọn "Facebook Login" và làm theo hướng dẫn thiết lập
3. Trong mục Settings > Basic, lấy App ID và App Secret
4. Trong mục Facebook Login > Settings:
   - Đối với Web: Thêm URL của Supabase Auth callback vào "Valid OAuth Redirect URIs": 
     `https://tddbrnjfuivsbsxeaika.supabase.co/auth/v1/callback`
   - Đối với Mobile: Thêm URL Schema cho ứng dụng của bạn, ví dụ: `blablo-app://`

## Bước 3: Cấu hình Supabase

1. Đăng nhập vào [Supabase Dashboard](https://app.supabase.com/)
2. Chọn dự án của bạn
3. Vào Authentication > Providers
4. Bật Facebook provider
5. Nhập App ID và App Secret từ Facebook
6. Lưu các thay đổi

## Bước 4: Cấu hình ứng dụng Flutter cho Android

1. Mở file `android/app/src/main/AndroidManifest.xml` và thêm:

```xml
<activity android:name="com.facebook.FacebookActivity"
    android:configChanges="keyboard|keyboardHidden|screenLayout|screenSize|orientation"
    android:label="@string/app_name" />
<activity
    android:name="com.facebook.CustomTabActivity"
    android:exported="true">
    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="@string/fb_login_protocol_scheme" />
    </intent-filter>
</activity>

<meta-data android:name="com.facebook.sdk.ApplicationId" android:value="@string/facebook_app_id"/>
<meta-data android:name="com.facebook.sdk.ClientToken" android:value="@string/facebook_client_token"/>
```

2. Tạo file `android/app/src/main/res/values/strings.xml` nếu chưa có:

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">BlaBlo</string>
    <string name="facebook_app_id">[YOUR_FACEBOOK_APP_ID]</string>
    <string name="fb_login_protocol_scheme">fb[YOUR_FACEBOOK_APP_ID]</string>
    <string name="facebook_client_token">[YOUR_CLIENT_TOKEN]</string>
</resources>
```

3. Cập nhật `android/build.gradle`:

```gradle
buildscript {
    // ...
    dependencies {
        // ...
        classpath 'com.google.gms:google-services:4.3.15'
    }
}
```

## Bước 5: Cấu hình ứng dụng Flutter cho iOS

1. Mở file `ios/Runner/Info.plist` và thêm:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>fb[YOUR_FACEBOOK_APP_ID]</string>
    </array>
  </dict>
</array>
<key>FacebookAppID</key>
<string>[YOUR_FACEBOOK_APP_ID]</string>
<key>FacebookClientToken</key>
<string>[YOUR_CLIENT_TOKEN]</string>
<key>FacebookDisplayName</key>
<string>BlaBlo</string>
<key>LSApplicationQueriesSchemes</key>
<array>
  <string>fbapi</string>
  <string>fb-messenger-share-api</string>
  <string>fbauth2</string>
  <string>fbshareextension</string>
</array>
```

## Bước 6: Cấu hình Deep Linking (Cho cả Android và iOS)

1. Cấu hình deep linking để xử lý callback từ Supabase sau khi đăng nhập thành công.
2. Deep link URL nên khớp với URL được cấu hình trong Supabase và Facebook.

## Tích hợp trong ứng dụng

Code trong ứng dụng đã được cập nhật để hỗ trợ đăng nhập Facebook. Các file đã được cập nhật:

1. `facebook_auth_datasource.dart` và `facebook_auth_datasource_impl.dart`
2. `auth_repository_impl.dart`
3. `login_bloc.dart`
4. `facebook_sign_in_button.dart`
5. `signup_screen.dart`

## Implementation in BlaBlo App

### 1. UI Layer (SignupScreen)

The UI provides a Facebook login button that triggers the OAuth flow:

```dart
Widget _buildFacebookButton(BuildContext context) {
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton.icon(
      onPressed: () {
        _signInWithFacebook(context);
      },
      icon: Image.asset('assets/images/facebook_logo.png'),
      label: const Text('Continue with Facebook'),
      // Style properties
    ),
  );
}

Future<void> _signInWithFacebook(BuildContext context) async {
  try {
    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đang đăng nhập với Facebook...'),
        duration: Duration(seconds: 1),
      ),
    );

    // Trigger Supabase's OAuth flow for Facebook
    context.read<LoginBloc>().add(
      const SignInWithFacebookOAuthRequested(),
    );
  } catch (e) {
    // Handle errors
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Facebook login failed: ${e.toString()}'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
```

### 2. Bloc Layer (LoginBloc)

The `LoginBloc` handles the Facebook OAuth request and coordinates with the repository:

```dart
// Event
class SignInWithFacebookOAuthRequested extends LoginEvent {
  const SignInWithFacebookOAuthRequested();
}

// Handler
Future<void> _onSignInWithFacebookOAuthRequested(
  SignInWithFacebookOAuthRequested event,
  Emitter<LoginState> emit,
) async {
  emit(LoginLoading());

  try {
    final result = await authRepository.signInWithFacebook();
    
    result.fold(
      (failure) {
        emit(LoginFailure(
          message: 'Facebook OAuth login failed: ${failure.toString()}',
        ));
      },
      (_) {
        // OAuth flow initiated successfully
        // The actual user session will be handled by Supabase's callback
      },
    );
  } catch (e) {
    emit(LoginFailure(
      message: 'Facebook OAuth error: ${e.toString()}',
    ));
  }
}
```

### 3. Data Layer (FacebookAuthDataSourceImpl)

The data source implements the Facebook OAuth integration with Supabase:

```dart
@override
Future<void> signInWithFacebook() async {
  try {
    final res = await supabaseClient.auth.signInWithOAuth(
      OAuthProvider.facebook,
      redirectTo: null, // Or your custom deep link
      authScreenLaunchMode: LaunchMode.externalApplication,
      scopes: 'email,public_profile',
    );
    
    if (!res) {
      throw ServerException(
        message: 'Failed to initiate Facebook OAuth flow',
      );
    }
    
    // The actual user session will be handled by Supabase's callback
  } catch (e) {
    throw ServerException(
      message: 'Supabase Facebook sign in failed: ${e.toString()}',
    );
  }
}
```

## Handling Authentication State

After the user successfully authenticates with Facebook via the OAuth flow, Supabase will handle the redirect back to your application. To properly capture the authentication state:

1. **Implement an Auth State Change Listener**

   You should have a global listener for Supabase auth state changes:

   ```dart
   void setupAuthStateListener() {
     supabaseClient.auth.onAuthStateChange.listen((data) {
       final AuthChangeEvent event = data.event;
       final Session? session = data.session;
       
       if (event == AuthChangeEvent.signedIn && session != null) {
         // User is signed in, update your app state
         final user = session.user;
         
         // Update your UserProfileBloc or equivalent
         userProfileBloc.add(
           SetUserProfileEvent(
             user: UserEntity(
               id: user.id,
               email: user.email ?? '',
               name: user.userMetadata?['full_name'] ?? '',
               avatarUrl: user.userMetadata?['avatar_url'],
               provider: 'facebook',
             ),
           ),
         );
       }
     });
   }
   ```

2. **Handle Deep Links**

   For mobile applications, you need to configure deep link handling to process the OAuth redirect:

   ```dart
   // In your app's initialization
   void setupDeepLinkHandling() {
     // Listen for incoming links
     uriLinkStream.listen((Uri? uri) {
       if (uri != null) {
         // This will handle the deep link after OAuth redirect
         supabaseClient.auth.getSessionFromUrl(uri);
       }
     }, onError: (err) {
       print('Error processing deep link: $err');
     });
   }
   ```

3. **User Interface Updates**

   Make sure your UI properly reflects the authentication state:

   ```dart
   // In a widget that depends on auth state
   BlocListener<UserProfileBloc, UserProfileState>(
     listener: (context, state) {
       if (state is UserProfileLoaded) {
         // User is authenticated, navigate to home screen
         Navigator.of(context).pushReplacementNamed('/home');
       } else if (state is UserProfileError) {
         // Authentication error
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Authentication failed: ${state.message}')),
         );
       }
     },
     child: // Your UI
   )
   ```

## Kiểm tra và xác minh

Sau khi hoàn tất cấu hình:

1. Chạy ứng dụng
2. Nhấp vào nút "Continue with Facebook"
3. Trình duyệt hoặc ứng dụng Facebook sẽ mở để xác thực
4. Sau khi đăng nhập thành công, người dùng sẽ được chuyển hướng trở lại ứng dụng

## Lưu ý bảo mật

- Không nên lưu trữ App Secret trong mã ứng dụng
- Đảm bảo xử lý lỗi đăng nhập đúng cách
- Tuân thủ các yêu cầu về quyền riêng tư của Facebook

## Troubleshooting

### Common Issues and Solutions

1. **"Provider must be google, apple, kakao or keycloak" Error**
   - **Cause**: You are trying to use `signInWithIdToken` with a Facebook token
   - **Solution**: Use `signInWithOAuth(OAuthProvider.facebook)` instead

2. **Facebook Login Success but No User in Supabase**
   - **Cause**: OAuth callback URL misconfiguration
   - **Solution**: Double check that your OAuth redirect URL in Facebook Developer Console matches exactly with the URL configured in Supabase

3. **Authentication Loop or Redirect Problems**
   - **Cause**: Deep linking setup issues or incorrect redirect handling
   - **Solution**: Verify your deep link configuration and ensure the app correctly processes the incoming URL

4. **User Signs In But Session Isn't Maintained**
   - **Cause**: Session storage issues or lifecycle problems
   - **Solution**: Ensure you're properly storing and checking for the Supabase session on app startup

### Debugging Tools

1. **Enable Debug Logs**

   Add this to your app initialization:
   ```dart
   void enableSupabaseDebugLogs() {
     if (kDebugMode) {
       Supabase.instance.client.auth.onAuthStateChange.listen((data) {
         print('Auth event: ${data.event}');
         print('Session: ${data.session != null ? 'exists' : 'null'}');
       });
     }
   }
   ```

2. **Test OAuth Flow**

   Use the debug button we've added to manually trigger the Facebook OAuth flow:
   ```dart
   Widget _buildTestFacebookButton(BuildContext context) {
     return TextButton(
       onPressed: () {
         AuthTestUtils.testFacebookLogin(context);
       },
       child: const Text('Test Facebook OAuth Login'),
     );
   }
   ```

3. **Monitor Network Traffic**
   
   Use Flutter DevTools Network profiler or a proxy tool (like Charles Proxy) to monitor the OAuth redirects and API calls

## Conclusion

By using Supabase's OAuth flow instead of attempting token-based authentication, you can successfully integrate Facebook login into your Flutter application. Make sure to follow the setup steps carefully, particularly the configuration of redirect URLs in both Supabase and Facebook Developer Console.

Remember that this solution avoids the "Provider must be google, apple, kakao or keycloak" error by using the recommended OAuth approach instead of trying to use the Facebook token directly with Supabase.
