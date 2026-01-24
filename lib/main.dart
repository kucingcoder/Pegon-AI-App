import 'package:app/features/auth/presentation/pages/login_page.dart';
import 'package:flutter/material.dart';

import 'package:app/features/auth/data/auth_service.dart';
import 'package:app/features/dashboard/presentation/pages/dashboard_page.dart';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  final isLoggedIn = await AuthService().isLoggedIn();
  runApp(MyApp(isLoggedIn: isLoggedIn));

  final appOpenAdManager = AppOpenAdManager();
  appOpenAdManager.loadAd();
  WidgetsBinding.instance.addObserver(AppLifecycleReactor(appOpenAdManager));
}

class AppLifecycleReactor extends WidgetsBindingObserver {
  final AppOpenAdManager appOpenAdManager;

  AppLifecycleReactor(this.appOpenAdManager);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      appOpenAdManager.showAdIfAvailable();
    }
  }
}

class AppOpenAdManager {
  AppOpenAd? _appOpenAd;
  bool _isShowingAd = false;
  final Duration maxCacheDuration = const Duration(hours: 4);
  DateTime? _appOpenLoadTime;

  /// Load an AppOpenAd.
  void loadAd() {
    AppOpenAd.load(
      adUnitId: 'ca-app-pub-1144248073011584/7912007279',
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenLoadTime = DateTime.now();
          _appOpenAd = ad;
          // Do NOT show immediately upon load to prevent loops.
          // Wait for AppLifecycleReactor to trigger showAdIfAvailable.
        },
        onAdFailedToLoad: (error) {
          print('AppOpenAd failed to load: $error');
        },
      ),
    );
  }

  /// Shows the ad if one is available and passes premium check.
  Future<void> showAdIfAvailable() async {
    final prefs = await SharedPreferences.getInstance();
    final String? session = prefs.getString('session');

    // 1. If not logged in, do NOT show ad
    if (session == null) {
      return;
    }

    // 2. If logged in but Premium, do NOT show ad
    final bool isPremium = prefs.getBool('is_premium') ?? false;
    if (isPremium) {
      return;
    }

    if (!isAdAvailable || _isShowingAd) {
      loadAd();
      return;
    }

    if (_appOpenAd != null) {
      _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) {
          _isShowingAd = true;
        },
        onAdDismissedFullScreenContent: (ad) {
          _isShowingAd = false;
          ad.dispose();
          _appOpenAd = null;
          loadAd(); // Pre-load the next ad
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          _isShowingAd = false;
          ad.dispose();
          _appOpenAd = null;
          loadAd();
        },
      );
      _appOpenAd!.show();
    }
  }

  bool get isAdAvailable {
    return _appOpenAd != null &&
        _appOpenLoadTime != null &&
        DateTime.now().difference(_appOpenLoadTime!) < maxCacheDuration;
  }
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
