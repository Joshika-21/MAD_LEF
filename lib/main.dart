import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'event_details_screen.dart';

void main() {
  runApp(LocalEventsApp());
}

class LocalEventsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Local Events Finder',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/details': (context) => EventDetailsScreen(),
      },
    );
  }
}
