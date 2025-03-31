import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'home_screen.dart';
import 'event_details_screen.dart';
import 'sign_in_screen.dart';
import 'sign_up_screen.dart';
import 'theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // ✅ Firebase init
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: LocalEventsApp(),
    ),
  );
}

class LocalEventsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final themeProvider = Provider.of<ThemeProvider>(context);

        return MaterialApp(
          title: 'Local Events Finder',
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.themeMode,
          theme: ThemeData(
            fontFamily: 'Roboto',
            brightness: Brightness.light,
            primarySwatch: Colors.deepPurple,
            scaffoldBackgroundColor: Colors.grey[100],
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
          ),
          darkTheme: ThemeData.dark().copyWith(
            primaryColor: Colors.deepPurple,
            scaffoldBackgroundColor: Colors.black,
            textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Roboto'),
          ),
          home: AuthGate(), // 🔁 This replaces `initialRoute`
          routes: {
            '/signin': (context) => SignInScreen(),
            '/signup': (context) => SignUpScreen(),
            '/details': (context) => EventDetailsScreen(),
          },
        );
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(), // ✅ Realtime auth state
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData) {
          return HomeScreen(); // ✅ Logged in
        } else {
          return SignInScreen(); // ❌ Not logged in
        }
      },
    );
  }
}
