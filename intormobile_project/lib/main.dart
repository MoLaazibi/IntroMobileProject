// lib/main.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intormobile_project/firebase_options.dart';
import 'games.dart'; // Import the game.dart file
import 'package:intl/date_symbol_data_local.dart'; // Import the necessary initialization function

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
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/games');
          },
          child: Text('Go to Games Page'),
        ),
      ),
    );
  }
}
