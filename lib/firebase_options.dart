// 文件: firebase_options.dart
// Firebase配置选项文件 - 通常由Firebase CLI自动生成
// 这是一个简化版本，在实际项目中应该使用flutterfire configure生成

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// 默认的Firebase配置选项
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions尚未为Windows平台配置。',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions尚未为Linux平台配置。',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions尚未为此平台配置。',
        );
    }
  }

  // 注意: 以下是示例配置，实际开发中需要替换为您自己的Firebase配置
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx',
    appId: '1:xxxxxxxxxxxx:web:xxxxxxxxxxxxxxxxxx',
    messagingSenderId: 'xxxxxxxxxxxx',
    projectId: 'ismart-student-app',
    authDomain: 'ismart-student-app.firebaseapp.com',
    storageBucket: 'ismart-student-app.appspot.com',
    measurementId: 'G-XXXXXXXXXX',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx',
    appId: '1:xxxxxxxxxxxx:android:xxxxxxxxxxxxxxxxxx',
    messagingSenderId: 'xxxxxxxxxxxx',
    projectId: 'ismart-student-app',
    storageBucket: 'ismart-student-app.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx',
    appId: '1:xxxxxxxxxxxx:ios:xxxxxxxxxxxxxxxxxx',
    messagingSenderId: 'xxxxxxxxxxxx',
    projectId: 'ismart-student-app',
    storageBucket: 'ismart-student-app.appspot.com',
    iosClientId: 'xxxxxxxxxxxx-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.apps.googleusercontent.com',
    iosBundleId: 'com.ismart.studentApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx',
    appId: '1:xxxxxxxxxxxx:ios:xxxxxxxxxxxxxxxxxx',
    messagingSenderId: 'xxxxxxxxxxxx',
    projectId: 'ismart-student-app',
    storageBucket: 'ismart-student-app.appspot.com',
    iosClientId: 'xxxxxxxxxxxx-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.apps.googleusercontent.com',
    iosBundleId: 'com.ismart.studentApp',
  );
}
