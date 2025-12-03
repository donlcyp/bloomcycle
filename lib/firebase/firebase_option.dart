import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD_k3pQ7mN8hL9jK0xY1zAb2cD3eF4gH5i',
    appId: '1:123456789:android:abcdef1234567890',
    messagingSenderId: '123456789',
    projectId: 'bloomcycle-app',
    storageBucket: 'bloomcycle-app.appspot.com',
    databaseURL: 'https://bloomcycle-app.firebaseio.com',
  );
}
