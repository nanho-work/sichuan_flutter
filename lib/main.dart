import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart'; // ✅ 추가

import 'firebase_options.dart';
import 'managers/sound_manager.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_layout.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await MobileAds.instance.initialize(); // ✅ AdMob 초기화

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
  ));

  // 사운드 및 로컬 설정 복원
  final prefs = await SharedPreferences.getInstance();
  await SoundManager().init();

  final user = FirebaseAuth.instance.currentUser;

  runApp(KoofyApp(isLoggedIn: user != null));
}

class KoofyApp extends StatelessWidget {
  final bool isLoggedIn;
  const KoofyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    // The app runs in full-screen mode with no AppBar or title UI.
    return MaterialApp(
      title: 'Koofy Sichuan',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: SplashScreenWrapper(isLoggedIn: isLoggedIn),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SplashScreenWrapper extends StatefulWidget {
  final bool isLoggedIn;
  const SplashScreenWrapper({super.key, required this.isLoggedIn});

  @override
  State<SplashScreenWrapper> createState() => _SplashScreenWrapperState();
}

class _SplashScreenWrapperState extends State<SplashScreenWrapper> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 3)); // 스플래시 유지 시간
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) =>
            widget.isLoggedIn ? const MainLayout() : const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}