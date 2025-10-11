import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart'; // ✅ 추가
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'managers/sound_manager.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_layout.dart';
import 'managers/image_manager.dart';

// 프로바이더 임포트
import 'package:sichuan_flutter/providers/user_provider.dart';
import 'package:sichuan_flutter/providers/item_provider.dart';
import 'package:sichuan_flutter/providers/inventory_provider.dart';

import 'package:sichuan_flutter/utils/firestore_importer.dart'; // 아이템 데이터 등록용

// ✅ 전역 navigatorKey 추가 (Provider 외부 접근용)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ✅ AdMob 초기화 (웹에서는 무시)
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    await MobileAds.instance.initialize();
  }

  // qawait importItemsFromJson(); // 제이슨 아이템 등록 , 등록후 주석처리 할 것.
  // await importItemSetsFromJson(); // 제이슨 아이템 등록 , 등록후 주석처리 할 것.

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
  ));

  // 사운드 및 로컬 설정 복원
  final prefs = await SharedPreferences.getInstance();
  await SoundManager().init();

  final user = FirebaseAuth.instance.currentUser;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()..loadUser()),
        ChangeNotifierProvider(create: (_) => ItemProvider()),
        ChangeNotifierProvider(create: (_) => InventoryProvider()..loadInventory()),
      ],
      child: KoofyApp(isLoggedIn: user != null),
    ),
  );
}

class KoofyApp extends StatelessWidget {
  final bool isLoggedIn;
  const KoofyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    // ✅ navigatorKey를 MaterialApp에 연결
    return MaterialApp(
      title: 'Koofy Sichuan',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      navigatorKey: navigatorKey, // ✅ 전역 네비게이터 등록 (중요!)
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ImageManager.instance.precacheAssets(context, itemIds: ['char_default', 'profile_placeholder']);
    });
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