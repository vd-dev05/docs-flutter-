# Firebase Integration

Tài liệu này mô tả cách BlaBló App tích hợp với Firebase để sử dụng các dịch vụ như Analytics, Firestore, Storage và Authentication.

## Overview

BlaBló sử dụng Firebase cho các dịch vụ sau:
1. Firebase Authentication
2. Cloud Firestore
3. Firebase Storage
4. Firebase Analytics
5. Firebase Crashlytics

## Setup

### 1. Configuration

Các cấu hình Firebase được tự động sinh bởi công cụ `flutterfire` và lưu trong file `firebase_options.dart`. Một số thông số quan trọng được quản lý qua [biến môi trường](../api_configuration.md):

```
FIREBASE_API_KEY=your-api-key
PROJECT_ID=your-project-id
PROJECT_NUMBER=your-project-number
STORAGE_BUCKET=your-storage-bucket
APP_ID=your-app-id
IOS_APP_ID=your-ios-app-id
CLIENT_ID=your-client-id
IOS_CLIENT_ID=your-ios-client-id
```

### 2. Initialization

Khởi tạo Firebase trong ứng dụng:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:blablo_app/firebase_options.dart';

await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

## Authentication

### Email/Password Authentication

```dart
import 'package:firebase_auth/firebase_auth.dart';

final auth = FirebaseAuth.instance;

// Đăng ký
UserCredential userCredential = await auth.createUserWithEmailAndPassword(
  email: "user@example.com",
  password: "password",
);

// Đăng nhập
UserCredential userCredential = await auth.signInWithEmailAndPassword(
  email: "user@example.com",
  password: "password",
);

// Đăng xuất
await auth.signOut();
```

### Social Authentication

#### Google Sign-In

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

Future<UserCredential> signInWithGoogle() async {
  // Trigger the authentication flow
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

  // Obtain the auth details from the request
  final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

  // Create a new credential
  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth?.accessToken,
    idToken: googleAuth?.idToken,
  );

  // Sign in to Firebase with the credential
  return await FirebaseAuth.instance.signInWithCredential(credential);
}
```

#### Facebook Sign-In

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

Future<UserCredential> signInWithFacebook() async {
  // Trigger the sign-in flow
  final LoginResult result = await FacebookAuth.instance.login();

  // Create a credential from the access token
  final OAuthCredential credential = 
      FacebookAuthProvider.credential(result.accessToken!.token);

  // Sign in to Firebase with the credential
  return await FirebaseAuth.instance.signInWithCredential(credential);
}
```

## Cloud Firestore

### CRUD Operations

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

final db = FirebaseFirestore.instance;

// Tạo bản ghi
await db.collection("stories").add({
  "title": "A New Story",
  "description": "Story description",
  "createdAt": FieldValue.serverTimestamp(),
});

// Đọc bản ghi
QuerySnapshot snapshot = await db.collection("stories").get();
for (var doc in snapshot.docs) {
  print("${doc.id} => ${doc.data()}");
}

// Đọc một bản ghi
DocumentSnapshot doc = await db.collection("stories").doc("story-id").get();
print("Story data: ${doc.data()}");

// Cập nhật bản ghi
await db.collection("stories").doc("story-id").update({
  "title": "Updated Title",
  "updatedAt": FieldValue.serverTimestamp(),
});

// Xóa bản ghi
await db.collection("stories").doc("story-id").delete();
```

### Truy vấn nâng cao

```dart
// Truy vấn với điều kiện
QuerySnapshot snapshot = await db.collection("stories")
  .where("level", isEqualTo: "Beginner")
  .where("category", isEqualTo: "Daily Life")
  .limit(10)
  .get();
  
// Sắp xếp
QuerySnapshot snapshot = await db.collection("stories")
  .orderBy("createdAt", descending: true)
  .get();
  
// Phân trang
QuerySnapshot snapshot = await db.collection("stories")
  .orderBy("createdAt")
  .startAfter([lastDocument])
  .limit(10)
  .get();
```

### Real-time Updates

```dart
// Lắng nghe thay đổi của một bản ghi
db.collection("users").doc(userId)
  .snapshots()
  .listen((DocumentSnapshot snapshot) {
    print("Current data: ${snapshot.data()}");
  });
  
// Lắng nghe thay đổi của một collection
db.collection("stories")
  .where("userId", isEqualTo: currentUserId)
  .snapshots()
  .listen((QuerySnapshot snapshot) {
    for (var change in snapshot.docChanges) {
      if (change.type == DocumentChangeType.added) {
        print("New story: ${change.doc.data()}");
      } else if (change.type == DocumentChangeType.modified) {
        print("Modified story: ${change.doc.data()}");
      } else if (change.type == DocumentChangeType.removed) {
        print("Removed story: ${change.doc.data()}");
      }
    }
  });
```

## Firebase Storage

```dart
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

final storage = FirebaseStorage.instance;

// Upload file
File file = File("path/to/image.jpg");
String filePath = "users/$userId/profile_picture.jpg";

try {
  await storage.ref(filePath).putFile(file);
  
  // Lấy download URL
  String downloadURL = await storage.ref(filePath).getDownloadURL();
  print("Download URL: $downloadURL");
} on FirebaseException catch (e) {
  print("Upload error: $e");
}

// Download file to local device
File localFile = File("path/to/local/file.jpg");
try {
  await storage.ref(filePath).writeToFile(localFile);
} on FirebaseException catch (e) {
  print("Download error: $e");
}

// Xóa file
await storage.ref(filePath).delete();
```

## Firebase Analytics

```dart
import 'package:firebase_analytics/firebase_analytics.dart';

final analytics = FirebaseAnalytics.instance;

// Log event
await analytics.logEvent(
  name: 'story_view',
  parameters: {
    'story_id': storyId,
    'story_title': storyTitle,
    'category': category,
  },
);

// Log screen view
await analytics.logScreenView(
  screenName: 'Story Details',
  screenClass: 'StoryDetailsPage',
);

// Log user properties
await analytics.setUserProperty(name: 'user_level', value: 'A2');
```

## Firebase Crashlytics

```dart
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

// Bắt lỗi không xử lý và báo cáo cho Crashlytics
FlutterError.onError = (FlutterErrorDetails details) {
  FirebaseCrashlytics.instance.recordFlutterError(details);
};

// Báo cáo lỗi theo cách thủ công
try {
  // Code có thể gây ra lỗi
} catch (e, stack) {
  FirebaseCrashlytics.instance.recordError(e, stack);
}

// Thêm custom keys cho crash reports
FirebaseCrashlytics.instance.setCustomKey('string_key', 'string_value');
FirebaseCrashlytics.instance.setCustomKey('bool_key', true);
FirebaseCrashlytics.instance.setCustomKey('int_key', 1);
FirebaseCrashlytics.instance.setCustomKey('double_key', 1.0);

// Thêm thông tin người dùng
FirebaseCrashlytics.instance.setUserIdentifier('user-123');
```

## Best Practices

1. **Security Rules**: Luôn cấu hình Security Rules cho Firestore và Firebase Storage
2. **Batch Operations**: Sử dụng batch write hoặc transactions khi cần cập nhật nhiều bản ghi
3. **Indexing**: Tạo index cho Firestore để tối ưu truy vấn phức tạp
4. **Caching**: Sử dụng persistenceEnabled để lưu cache local
5. **Cost Control**: Tránh lắng nghe quá nhiều collections và giới hạn số lượng bản ghi truy vấn
