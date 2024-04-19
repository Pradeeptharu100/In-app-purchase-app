// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
    apiKey: 'AIzaSyC77TIqXIst6UfWyfP2p_GumlPe4sv1DR4',
    appId: '1:1020875221111:web:34ff7d28927c46df3bbe72',
    messagingSenderId: '1020875221111',
    projectId: 'in-app-purchase-540bd',
    authDomain: 'in-app-purchase-540bd.firebaseapp.com',
    storageBucket: 'in-app-purchase-540bd.appspot.com',
    measurementId: 'G-LVQ2T1DFYW',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCZJSYg99kHpoXGHh5f1ybgk_BKS_fFU1w',
    appId: '1:1020875221111:android:7211f695b78502343bbe72',
    messagingSenderId: '1020875221111',
    projectId: 'in-app-purchase-540bd',
    storageBucket: 'in-app-purchase-540bd.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDp9Jq-mWzhk9mFDbJEB6MUg0dcBGdbwbo',
    appId: '1:1020875221111:ios:3dfe106876cf20933bbe72',
    messagingSenderId: '1020875221111',
    projectId: 'in-app-purchase-540bd',
    storageBucket: 'in-app-purchase-540bd.appspot.com',
    iosBundleId: 'com.revcat.revenueCatInAppPurchase',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDp9Jq-mWzhk9mFDbJEB6MUg0dcBGdbwbo',
    appId: '1:1020875221111:ios:3dfe106876cf20933bbe72',
    messagingSenderId: '1020875221111',
    projectId: 'in-app-purchase-540bd',
    storageBucket: 'in-app-purchase-540bd.appspot.com',
    iosBundleId: 'com.revcat.revenueCatInAppPurchase',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyC77TIqXIst6UfWyfP2p_GumlPe4sv1DR4',
    appId: '1:1020875221111:web:0758ff2850c0afdb3bbe72',
    messagingSenderId: '1020875221111',
    projectId: 'in-app-purchase-540bd',
    authDomain: 'in-app-purchase-540bd.firebaseapp.com',
    storageBucket: 'in-app-purchase-540bd.appspot.com',
    measurementId: 'G-B1Q820KS3N',
  );
}
