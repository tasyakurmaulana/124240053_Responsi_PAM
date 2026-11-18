import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controller/auth_controller.dart';
import 'controller/product_controller.dart';
import 'controller/wishlist_controller.dart';
import 'screens/login_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'services/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DatabaseHelper.instance.database;

  final authController = Get.put(AuthController());
  Get.put(ProductController());
  Get.put(WishlistController());

  await authController.checkLogin();

  runApp(const ShoppingHubApp());
}

class ShoppingHubApp extends StatelessWidget {
  const ShoppingHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return GetMaterialApp(
      title: 'ShoppingHub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF7C3AED),
          secondary: Color(0xFFF59E0B),
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
      home: Obx(() => authController.isLoggedIn.value
          ? const MainNavigationScreen()
          : const LoginScreen()),
    );
  }
}
