import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      // case TargetPlatform.iOS:
      //   return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDInW_AkHCMhKsF6OcavbZMHOvZI6oaREM',
    appId: '1:136794753205:android:f2a4ea411fd2ef17e316fc',
    messagingSenderId: '136794753205',
    projectId: 'kitab-mandi',
    storageBucket: 'kitab-mandi.firebasestorage.app',
  );

  // static const FirebaseOptions ios = FirebaseOptions(
  //   apiKey: 'YOUR_API_KEY',
  //   appId: 'YOUR_APP_ID',
  //   messagingSenderId: 'YOUR_SENDER_ID',
  //   projectId: 'YOUR_PROJECT_ID',
  //   storageBucket: 'YOUR_STORAGE_BUCKET',
  //   iosClientId: 'YOUR_IOS_CLIENT_ID',
  //   iosBundleId: 'YOUR_BUNDLE_ID',
  // );
}
