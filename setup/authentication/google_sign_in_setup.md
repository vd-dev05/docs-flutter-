# Google Sign-In Setup Guide

This guide explains how to set up Google Sign-In for the BlaBló app.

## Prerequisites

1. A Google Cloud Platform account
2. The BlaBló app codebase

## Step 1: Create a Google Cloud Project

1. Go to the [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Note down the Project ID

## Step 2: Configure OAuth Consent Screen

1. In the Google Cloud Console, go to **APIs & Services > OAuth consent screen**
2. Select the appropriate User Type (External or Internal)
3. Fill in the required information:
   - App name: BlaBló
   - User support email
   - Developer contact information
4. Add the following scopes:
   - `email`
   - `profile`
5. Add test users if you selected External user type
6. Complete the registration

## Step 3: Create OAuth Client IDs

### Web Client ID

1. In the Google Cloud Console, go to **APIs & Services > Credentials**
2. Click **Create Credentials** and select **OAuth client ID**
3. Select **Web application** as the Application type
4. Add authorized JavaScript origins:
   - `https://your-app-domain.com`
5. Add authorized redirect URIs:
   - `https://your-app-domain.com/auth/callback`
6. Click **Create**
7. Note down the Client ID

### Android Client ID

1. In the Google Cloud Console, go to **APIs & Services > Credentials**
2. Click **Create Credentials** and select **OAuth client ID**
3. Select **Android** as the Application type
4. Enter your app's package name (e.g., `com.example.blablo_app`)
5. Generate the SHA-1 certificate fingerprint:
   ```
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```
6. Enter the SHA-1 certificate fingerprint
7. Click **Create**

### iOS Client ID

1. In the Google Cloud Console, go to **APIs & Services > Credentials**
2. Click **Create Credentials** and select **OAuth client ID**
3. Select **iOS** as the Application type
4. Enter your app's Bundle ID (e.g., `com.example.blabloApp`)
5. Click **Create**

## Step 4: Update the App Configuration

### Web Client ID

1. Open `lib/core/constants/web_client_id.dart`
2. Replace `YOUR_WEB_CLIENT_ID` with the Web client ID you created

### Android Configuration

1. Open `android/app/build.gradle`
2. Make sure the `applicationId` matches the package name you used when creating the Android client ID

### iOS Configuration

1. Open `ios/Runner/Info.plist`
2. Add the following configuration:
   ```xml
   <key>CFBundleURLTypes</key>
   <array>
     <dict>
       <key>CFBundleTypeRole</key>
       <string>Editor</string>
       <key>CFBundleURLSchemes</key>
       <array>
         <string>com.googleusercontent.apps.YOUR-CLIENT-ID</string>
       </array>
     </dict>
   </array>
   ```
3. Replace `YOUR-CLIENT-ID` with the iOS client ID you created

## Step 5: Enable the Google Sign-In API

1. In the Google Cloud Console, go to **APIs & Services > Library**
2. Search for "Google Sign-In API"
3. Click on the API and then click **Enable**

## Step 6: Test the Integration

1. Run the app
2. Navigate to the sign-in screen
3. Tap the "Sign in with Google" button
4. Verify that the Google Sign-In flow works correctly

## Troubleshooting

### Common Issues

1. **"Sign in failed. Error: 10"**: This usually means there's an issue with your SHA-1 certificate fingerprint. Make sure you've added the correct fingerprint to the Android client ID.

2. **"Sign in failed. Error: 12500"**: This is a common error on Android that can occur for several reasons:
   - The package name in your app doesn't match the one you registered
   - The SHA-1 fingerprint is incorrect
   - Google Play Services is not up to date on the device

3. **"Sign in failed. Error: DEVELOPER_ERROR"**: This usually means there's a configuration issue:
   - Check that you've enabled the Google Sign-In API
   - Verify that your client IDs are correct
   - Make sure you've configured the OAuth consent screen correctly

### Debugging

To enable detailed logging for Google Sign-In:

1. Add debug prints in the `GoogleAuthDataSource` implementation
2. Check the logs for any error messages
3. Verify that the correct client ID is being used

## Additional Resources

- [Google Sign-In for Flutter Documentation](https://pub.dev/packages/google_sign_in)
- [Google Sign-In for Android Documentation](https://developers.google.com/identity/sign-in/android/start-integrating)
- [Google Sign-In for iOS Documentation](https://developers.google.com/identity/sign-in/ios/start-integrating)
