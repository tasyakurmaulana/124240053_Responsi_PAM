import 'package:flutter/material.dart';

import 'services/preference_service.dart';
import 'screens/login_screen.dart';
import 'screens/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi SharedPreferences & Favorit
  await PreferenceService.instance.init();
  final isLoggedIn = await PreferenceService.instance.isLoggedIn();

  runApp(RickAndMortyApp(isLoggedIn: isLoggedIn));
}

class RickAndMortyApp extends StatelessWidget {
  final bool isLoggedIn;

  const RickAndMortyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rick & Morty Explorer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(
          0xFFF8FAFC,
        ), // Background terang & clean
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF7C3AED), // Ungu / Violet modern
          secondary: Color(0xFFF59E0B), // Kuning / Amber cerah
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF0F172A),
          elevation: 0,
          centerTitle: false,
          iconTheme: IconThemeData(color: Color(0xFF0F172A)),
        ),
        cardTheme: const CardThemeData(
          color: Colors.white,
          elevation: 1.5,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
      ),
      home: isLoggedIn ? const MainNavigationScreen() : const LoginScreen(),
    );
  }
}
