import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intormobile_project/firebase_options.dart';
import 'package:intormobile_project/pages/community.dart';
import 'package:intormobile_project/pages/home.dart';
import 'package:intormobile_project/pages/login.dart';
import 'package:intormobile_project/pages/register.dart';
import 'package:intormobile_project/pages/starts.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => StartPage(),
          '/register': (context) => RegisterPage(),
          '/login': (context) => LoginPage(),
          '/home': (context) => HomePage(),
          '/community': (context) => CommunityPage()
        });
  }
}
