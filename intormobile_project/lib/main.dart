import 'package:flutter/material.dart';
import 'package:intormobile_project/pages/login.dart';
import 'package:intormobile_project/pages/register.dart';
import 'package:intormobile_project/pages/starts.dart';

void main() {
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
        });
  }
}
