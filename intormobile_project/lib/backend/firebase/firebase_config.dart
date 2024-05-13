import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

Future initFirebase() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyA5Pvyu5zSNLpH4X1XNT2Tl6kNaiyJUB0w",
            authDomain: "intromobileprojectfb.firebaseapp.com",
            projectId: "intromobileprojectfb",
            storageBucket: "intromobileprojectfb.appspot.com",
            messagingSenderId: "983017452505",
            appId: "1:983017452505:android:d84c4c9f0d03eb68a89fc8",
            measurementId: "G-F9VJYGS1B6"));
  } else {
    await Firebase.initializeApp();
  }
}
