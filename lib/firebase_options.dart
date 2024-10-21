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
    apiKey: 'AIzaSyC1pVEftxTzSLYwMqxSPk6a5BnHkjv3LxM',
    appId: '1:439751317501:web:ddb1059b1d9e1a4dad6b94',
    messagingSenderId: '439751317501',
    projectId: 'quizz-8048f',
    authDomain: 'quizz-8048f.firebaseapp.com',
    storageBucket: 'quizz-8048f.appspot.com',
    measurementId: 'G-DK7L1J5644',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyALUig-WD68MjzipIvNmWSbSC_gml0d-Yk',
    appId: '1:439751317501:android:7446d6d365c4c235ad6b94',
    messagingSenderId: '439751317501',
    projectId: 'quizz-8048f',
    storageBucket: 'quizz-8048f.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAdCoXpXhUJasLB5GyoALkXBeqvTFlcO_s',
    appId: '1:439751317501:ios:b781de09dfb028d1ad6b94',
    messagingSenderId: '439751317501',
    projectId: 'quizz-8048f',
    storageBucket: 'quizz-8048f.appspot.com',
    iosBundleId: 'com.example.quizzapp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAdCoXpXhUJasLB5GyoALkXBeqvTFlcO_s',
    appId: '1:439751317501:ios:b781de09dfb028d1ad6b94',
    messagingSenderId: '439751317501',
    projectId: 'quizz-8048f',
    storageBucket: 'quizz-8048f.appspot.com',
    iosBundleId: 'com.example.quizzapp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyC1pVEftxTzSLYwMqxSPk6a5BnHkjv3LxM',
    appId: '1:439751317501:web:39d1b3e01711eb50ad6b94',
    messagingSenderId: '439751317501',
    projectId: 'quizz-8048f',
    authDomain: 'quizz-8048f.firebaseapp.com',
    storageBucket: 'quizz-8048f.appspot.com',
    measurementId: 'G-Y7DLGLZPJH',
  );
}