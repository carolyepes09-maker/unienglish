// File generated for the UniEnglish web app (Firebase project unienglish1-54948).
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// This app only registers a Web app in Firebase (deployment target is
/// Firebase Hosting), so only [currentPlatform] for web is provided.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions have only been configured for web. '
      'This app is only deployed to Firebase Hosting (web).',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAfoGX784mFd5TONTTKBM8Emm1OX27QuNg',
    appId: '1:221745981086:web:12619111be5af8ac0d7d8f',
    messagingSenderId: '221745981086',
    projectId: 'unienglish1-54948',
    authDomain: 'unienglish1-54948.firebaseapp.com',
    storageBucket: 'unienglish1-54948.firebasestorage.app',
    measurementId: 'G-P6TFZYFHY7',
  );
}
