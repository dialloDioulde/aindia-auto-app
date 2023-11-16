// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
    apiKey: 'AIzaSyAgt0Fzdmf2EbZbIjwtJAUqB2l6qaVko-4',
    appId: '1:203654812337:web:d19776d03de422fd0e0890',
    messagingSenderId: '203654812337',
    projectId: 'aindia-auto-e607e',
    authDomain: 'aindia-auto-e607e.firebaseapp.com',
    storageBucket: 'aindia-auto-e607e.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDmJ-P3SndF6PMe0XU_u1LcguILuExZ5kc',
    appId: '1:203654812337:android:0437801e574f3c3d0e0890',
    messagingSenderId: '203654812337',
    projectId: 'aindia-auto-e607e',
    storageBucket: 'aindia-auto-e607e.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDQ9mAwud2fihyUqq17k-_XtBenxrvIIOQ',
    appId: '1:203654812337:ios:329bd6967631104d0e0890',
    messagingSenderId: '203654812337',
    projectId: 'aindia-auto-e607e',
    storageBucket: 'aindia-auto-e607e.appspot.com',
    iosBundleId: 'com.example.aindiaAutoApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDQ9mAwud2fihyUqq17k-_XtBenxrvIIOQ',
    appId: '1:203654812337:ios:3f0538109b112aff0e0890',
    messagingSenderId: '203654812337',
    projectId: 'aindia-auto-e607e',
    storageBucket: 'aindia-auto-e607e.appspot.com',
    iosBundleId: 'com.example.aindiaAutoApp.RunnerTests',
  );
}
