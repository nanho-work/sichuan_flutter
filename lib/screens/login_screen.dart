import 'package:flutter/material.dart';
import '../managers/sound_manager.dart';
import '../services/auth_service.dart';
import 'main_layout.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final sound = SoundManager();
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    sound.playBGM('home_theme.mp3'); // 로그인 배경음
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showLoginDialog();
    });
  }

  void _showLoginDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Login Dialog',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation1, animation2) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/koofy_logo.png',
                      height: 100,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            GestureDetector(
                              onTap: () async {
                                sound.playSFX('login_touch.mp3');
                                final user = await _authService.signInWithGoogle();
                                if (user != null) {
                                  Navigator.of(context).pop();
                                  _onLoginSuccess();
                                }
                              },
                              child: Image.asset(
                                'assets/images/google_login.png',
                                width: 80,
                                height: 80,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Google',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                        const SizedBox(width: 30), // ✅ 버튼 간 간격 추가
                        Column(
                          children: [
                            GestureDetector(
                              onTap: () async {
                                sound.playSFX('login_touch.mp3');
                                final user = await _authService.signInAsGuest();
                                if (user != null) {
                                  Navigator.of(context).pop();
                                  _onLoginSuccess();
                                }
                              },
                              child: Image.asset(
                                'assets/images/guest_login.png',
                                width: 80,
                                height: 80,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Guest',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation1, animation2, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation1,
            curve: Curves.easeOut,
            reverseCurve: Curves.easeIn,
          ),
          child: ScaleTransition(
            scale: CurvedAnimation(
              parent: animation1,
              curve: Curves.easeOutBack,
              reverseCurve: Curves.easeInBack,
            ),
            child: child,
          ),
        );
      },
    );
  }

  void _onLoginSuccess() {
    // 로그인 성공 시 메인 레이아웃으로 이동
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainLayout()),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/login_bg.png',
            fit: BoxFit.cover,
          ),
          Center(),
        ],
      ),
    );
  }
}