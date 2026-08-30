// Placeholder file so the rebuild compiles before Firebase setup.
// Run `flutterfire configure --platforms=android` to replace this with real options.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return android;
    }
    throw UnsupportedError('Firebase options are configured only for Android.');
  }

  /// True once real Firebase options are generated via `flutterfire configure`.
  /// While this file still contains placeholder values the Firebase plugins are
  /// skipped at runtime to avoid an invalid-app crash.
  static bool get isConfigured {
    if (defaultTargetPlatform != TargetPlatform.android) return false;
    return android.apiKey != 'REPLACE_ME' &&
        android.appId != 'REPLACE_ME' &&
        android.messagingSenderId != 'REPLACE_ME' &&
        android.projectId != 'REPLACE_ME';
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: 'REPLACE_ME',
    messagingSenderId: 'REPLACE_ME',
    projectId: 'REPLACE_ME',
  );
}
