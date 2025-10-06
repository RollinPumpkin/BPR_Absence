import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions have not been configured for this platform.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCKaOBxr8z7Yo96mP3bQ9h4FE0jQz8Z_Cw',
    appId: '1:548959984167:web:8d2c8b4a5f3e7d9e2f1a3b',
    messagingSenderId: '548959984167',
    projectId: 'bpr-absens',
    authDomain: 'bpr-absens.firebaseapp.com',
    storageBucket: 'bpr-absens.appspot.com',
    measurementId: 'G-XXXXXXXXXX',
  );
}