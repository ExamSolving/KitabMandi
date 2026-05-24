import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
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

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBHfMoubPJXIMqleGxsXjMgT5TqDu-IOu0',
    appId: '1:136794753205:ios:7bc55409db34b7f6e316fc',
    messagingSenderId: '136794753205',
    projectId: 'kitab-mandi',
    storageBucket: 'kitab-mandi.firebasestorage.app',
    iosClientId:
        '136794753205-5vam4sf1gun8att02luv8obvddu3kgvd.apps.googleusercontent.com',
    iosBundleId: 'com.appvora.kitabmandi',
  );
}
