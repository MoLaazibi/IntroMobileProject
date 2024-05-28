import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intormobile_project/firebase_options.dart';
import 'pages/start.dart';
import 'pages/login.dart';
import 'pages/register.dart';
import 'pages/home.dart';
import 'pages/court_search.dart';
import 'pages/court_reservation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Playtomic',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => StartPage(),
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/home': (context) => HomePage(
            currentUser: ModalRoute.of(context)?.settings.arguments as User),
        '/court_search': (context) {
          var args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>;
          return CourtSearchPage(currentUser: args['currentUser']);
        },
        '/court_reservation': (context) {
          var args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>;
          return CourtReservationPage(
            court: args['court'],
            currentUser: args['currentUser'],
          );
        },
      },
    );
  }
}
