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
    apiKey: 'AIzaSyDH6H_pKuyhNt1J4Q4P7LBhJdRGTTNzNNM',
    appId: '1:1084437872337:web:7bffeb3a118a595d25cff0',
    messagingSenderId: '1084437872337',
    projectId: 'shoply-f804a',
    authDomain: 'shoply-f804a.firebaseapp.com',
    storageBucket: 'shoply-f804a.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyByPO7YIF8aDUYU9S_GXkgAIPqpzUOU_hQ',
    appId: '1:1084437872337:android:7ea5edaaf45b60f625cff0',
    messagingSenderId: '1084437872337',
    projectId: 'shoply-f804a',
    storageBucket: 'shoply-f804a.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBTzVcBvk-OPUC24x7UbOyJ4SOrsx0sYXI',
    appId: '1:1084437872337:ios:c3a8ec2415265abf25cff0',
    messagingSenderId: '1084437872337',
    projectId: 'shoply-f804a',
    storageBucket: 'shoply-f804a.firebasestorage.app',
    iosBundleId: 'com.example.shoply',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBTzVcBvk-OPUC24x7UbOyJ4SOrsx0sYXI',
    appId: '1:1084437872337:ios:c3a8ec2415265abf25cff0',
    messagingSenderId: '1084437872337',
    projectId: 'shoply-f804a',
    storageBucket: 'shoply-f804a.firebasestorage.app',
    iosBundleId: 'com.example.shoply',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDH6H_pKuyhNt1J4Q4P7LBhJdRGTTNzNNM',
    appId: '1:1084437872337:web:eabdd039af9372d125cff0',
    messagingSenderId: '1084437872337',
    projectId: 'shoply-f804a',
    authDomain: 'shoply-f804a.firebaseapp.com',
    storageBucket: 'shoply-f804a.firebasestorage.app',
  );
}
