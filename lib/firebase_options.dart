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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
              'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyCDXqpYXaNIEAFLHqQE1HeCBB8-OSRmwjw',
    appId: '1:580149701786:android:1a1baddfb2c065947bc323',
    messagingSenderId: '580149701786',
    projectId: 'foodorderingapp-5b786',
    authDomain: 'foodorderingapp-5b786.firebaseapp.com',
    storageBucket: 'foodorderingapp-5b786.appspot.com', // Đã sửa lại đúng
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCDXqpYXaNIEAFLHqQE1HeCBB8-OSRmwjw',
    appId: '1:580149701786:android:1a1baddfb2c065947bc323',
    messagingSenderId: '580149701786',
    projectId: 'foodorderingapp-5b786',
    storageBucket: 'foodorderingapp-5b786.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR-IOS-API-KEY',
    appId: 'YOUR-IOS-APP-ID',
    messagingSenderId: 'YOUR-SENDER-ID',
    projectId: 'YOUR-PROJECT-ID',
    storageBucket: 'YOUR-STORAGE-BUCKET',
    iosClientId: 'YOUR-IOS-CLIENT-ID',
    iosBundleId: 'YOUR-IOS-BUNDLE-ID',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'YOUR-MACOS-API-KEY',
    appId: 'YOUR-MACOS-APP-ID',
    messagingSenderId: 'YOUR-SENDER-ID',
    projectId: 'YOUR-PROJECT-ID',
    storageBucket: 'YOUR-STORAGE-BUCKET',
    iosClientId: 'YOUR-MACOS-CLIENT-ID',
    iosBundleId: 'YOUR-MACOS-BUNDLE-ID',
  );
}