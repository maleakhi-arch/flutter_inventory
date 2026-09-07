
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'

    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA3lfh6mtQ4NsdnU3i761SbI9T3YsyjkBo',
    appId: '1:873420975277:web:ec989e4fa6370c51c5aa24',
    messagingSenderId: '873420975277',
    projectId: 'flutterinventory-app-38729',
    authDomain: 'flutterinventory-app-38729.firebaseapp.com',
    storageBucket: 'flutterinventory-app-38729.firebasestorage.app',
    measurementId: 'G-L8JZF7V4PB',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB5tTkWOzBFDkQ_r_D7LWBVwx0_a5WR-m8',
    appId: '1:873420975277:android:33fa0dd52e00fc4ec5aa24',
    messagingSenderId: '873420975277',
    projectId: 'flutterinventory-app-38729',
    storageBucket: 'flutterinventory-app-38729.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCl6zRKaOFlNGhmoBkngKPLnTtgo5SO_Ck',
    appId: '1:873420975277:ios:c58aa577be890287c5aa24',
    messagingSenderId: '873420975277',
    projectId: 'flutterinventory-app-38729',
    storageBucket: 'flutterinventory-app-38729.firebasestorage.app',
    iosBundleId: 'com.example.flutterInventory',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCl6zRKaOFlNGhmoBkngKPLnTtgo5SO_Ck',
    appId: '1:873420975277:ios:c58aa577be890287c5aa24',
    messagingSenderId: '873420975277',
    projectId: 'flutterinventory-app-38729',
    storageBucket: 'flutterinventory-app-38729.firebasestorage.app',
    iosBundleId: 'com.example.flutterInventory',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyA3lfh6mtQ4NsdnU3i761SbI9T3YsyjkBo',
    appId: '1:873420975277:web:dbd34d2b6864ce6fc5aa24',
    messagingSenderId: '873420975277',
    projectId: 'flutterinventory-app-38729',
    authDomain: 'flutterinventory-app-38729.firebaseapp.com',
    storageBucket: 'flutterinventory-app-38729.firebasestorage.app',
    measurementId: 'G-V4L1NCH1XS',
  );
}
