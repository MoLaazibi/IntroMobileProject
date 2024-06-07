import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intormobile_project/pages/games.dart';
import 'pages/start.dart';
import 'pages/login.dart';
import 'pages/register.dart';
import 'pages/home.dart';
import 'pages/community.dart';
import 'pages/court_search.dart';
import 'pages/court_reservation.dart';
import 'pages/court_detail.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
        '/community': (context) => CommunityPage(),
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
        '/court_detail': (context) {
          var args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>;
          return CourtDetailPage(
            name: args['name'],
            location: args['location'],
            imageUrl: args['imgUrl'],
            description: args['description'],
            currentUser: args['currentUser'],
            court: args['court'],
          );
        },
        '/games': (context) => GamesPage()
      },
    );
  }
}
