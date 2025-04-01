import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'home_screen.dart';
import 'event_details_screen.dart';
import 'sign_in_screen.dart';
import 'sign_up_screen.dart';
import 'theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox<String>('favoritesBox');
  await Firebase.initializeApp(); // ✅ Firebase init

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()), // ✅ added
      ],
      child: LocalEventsApp(),
    ),
  );
}

// ✅ Inline FavoritesProvider (for syncing favorites)
class FavoritesProvider extends ChangeNotifier {
  final Box<String> _favoritesBox = Hive.box<String>('favoritesBox');

  List<String> get favoriteEventIds => _favoritesBox.values.toList();

  bool isFavorite(String eventId) => _favoritesBox.values.contains(eventId);

  void toggleFavorite(String eventId) {
    if (isFavorite(eventId)) {
      final key = _favoritesBox.keys.firstWhere(
        (k) => _favoritesBox.get(k) == eventId,
      );
      _favoritesBox.delete(key);
    } else {
      _favoritesBox.put(eventId, eventId);
    }
    notifyListeners();
  }
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
          home: AuthGate(), // 🔁 Routing handled here
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

// ✅ Firebase Auth routing (Login → Home / SignIn)
class AuthGate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData) {
          return HomeScreen(); // ✅ Authenticated
        } else {
          return SignInScreen(); // ❌ Not logged in
        }
      },
    );
  }
}
