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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyAI0iUonZO2aWZVCdq1MoUm7MeLGengXxA',
    appId: '1:13095825224:web:545d76f5c5bec1db0d0d7d',
    messagingSenderId: '13095825224',
    projectId: 'flutter-fp-d9235',
    authDomain: 'flutter-fp-d9235.firebaseapp.com',
    storageBucket: 'flutter-fp-d9235.firebasestorage.app',
    measurementId: 'G-EH8NCYYDCT',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC-PViQ7_2ffQuUNb5p7OmtlsjU_XaJLEg',
    appId: '1:13095825224:android:39927b40b1f7f2670d0d7d',
    messagingSenderId: '13095825224',
    projectId: 'flutter-fp-d9235',
    storageBucket: 'flutter-fp-d9235.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBGYmuSSTVyGOfvU0ViPaT6Bb7OxiZcJPY',
    appId: '1:13095825224:ios:d27101fdac38824a0d0d7d',
    messagingSenderId: '13095825224',
    projectId: 'flutter-fp-d9235',
    storageBucket: 'flutter-fp-d9235.firebasestorage.app',
    iosBundleId: 'com.example.finalProject',
  );
}
