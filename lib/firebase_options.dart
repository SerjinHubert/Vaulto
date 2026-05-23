import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Web is not supported yet.');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
      default:
        throw UnsupportedError('Platform is not supported yet.');
    }
  }

  // REPLACE THESE VALUES WITH YOUR ANDROID CONFIG FROM FIREBASE CONSOLE
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDDSrKks47Mk45nXluRQVHqriTDiOeGdfM',
    appId: '1:1073282535720:android:1408c3e0f2aed074cf801d',
    messagingSenderId: '1073282535720',
    projectId: 'vaulto-sh19',
    storageBucket: 'vaulto-sh19.firebasestorage.app',
  );

  // REPLACE THESE VALUES LATER FOR IPHONE
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'PASTE_YOUR_IOS_API_KEY_HERE',
    appId: 'PASTE_YOUR_IOS_APP_ID_HERE',
    messagingSenderId: 'PASTE_YOUR_SENDER_ID_HERE',
    projectId: 'PASTE_YOUR_PROJECT_ID_HERE',
    storageBucket: 'PASTE_YOUR_PROJECT_ID_HERE.appspot.com',
    iosBundleId: 'com.example.vaulto', // Update this if your bundle ID is different
  );
}
