// lib/main.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intormobile_project/firebase_options.dart';
import 'games.dart'; // Import the games.dart file
import 'package:intl/date_symbol_data_local.dart'; // Import the necessary initialization function
import 'profile.dart'; // Import the profile.dart file

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Ensure locale data is initialized before running the app
  initializeDateFormatting('nl_NL', null).then((_) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wedstrijden App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(), // Define your home screen here
        '/games': (context) => GamesPage(), // Define the route to GamesPage
        '/profile': (context) => ProfilePage(userData: {
              'initials': 'AE',
              'name': 'Ali El Yousfi',
              'padelLevel': 0,
              'tennisLevel': 0,
              'bestHand': 'Right-handed',
              'courtPosition': 'Both sides',
              'matchType': 'Competitive, Friendly',
              'preferredTime': 'Morning',
            }), // Define the route to ProfilePage
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/games');
              },
              child: Text('Go to Games Page'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/profile');
              },
              child: Text('Go to Profile Page'),
            ),
          ],
        ),
      ),
    );
  }
}
