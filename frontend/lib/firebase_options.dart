import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    // Check for Android
    if (Platform.isAndroid) {
      return android;
    }
    // Check for iOS
    if (Platform.isIOS) {
      return ios;
    }
    
    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDVVNuLnEnHhJcBBOspa4usflMgpOv_FDU',
    appId: '1:548959984167:web:8d2c8b4a5f3e7d9e2f1a3b',
    messagingSenderId: '548959984167',
    projectId: 'bpr-absens',
    authDomain: 'bpr-absens.firebaseapp.com',
    storageBucket: 'bpr-absens.appspot.com',
    measurementId: 'G-XXXXXXXXXX',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDVVNuLnEnHhJcBBOspa4usflMgpOv_FDU',
    appId: '1:885462764670:android:85ca9610f8ee31a4cb5c2f',
    messagingSenderId: '885462764670',
    projectId: 'bpr-absens',
    storageBucket: 'bpr-absens.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDVVNuLnEnHhJcBBOspa4usflMgpOv_FDU',
    appId: '1:885462764670:ios:XXXXXXXXXXXXXXXX',
    messagingSenderId: '885462764670',
    projectId: 'bpr-absens',
    storageBucket: 'bpr-absens.firebasestorage.app',
    iosBundleId: 'BPR.Absens',
  );
}