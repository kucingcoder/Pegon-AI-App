import 'package:app/features/auth/presentation/pages/login_page.dart';
import 'package:flutter/material.dart';

import 'package:app/features/auth/data/auth_service.dart';
import 'package:app/features/dashboard/presentation/pages/dashboard_page.dart';

import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  final isLoggedIn = await AuthService().isLoggedIn();
  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pegon AI : Membaca, Menulis, dan Belajar',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFFD700),
          primary: Colors
              .orange[800], // Darker orange for better contrast as primary
          secondary: Colors.orange,
        ),
        useMaterial3: true,
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Colors.orange,
          selectionHandleColor: Colors.orange,
          selectionColor: Colors.orange.withOpacity(0.3),
        ),
        inputDecorationTheme: InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.orange, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          activeIndicatorBorder: BorderSide(color: Colors.orange),
        ),
      ),
      home: isLoggedIn ? const DashboardPage() : const LoginPage(),
    );
  }
}
