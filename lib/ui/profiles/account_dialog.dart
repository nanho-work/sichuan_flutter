import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../screens/login_screen.dart';
import '../../screens/splash_screen.dart';
import '../../main.dart'; // ✅ 추가 (SplashScreenWrapper 접근용)
import '../common/app_notifier.dart';

class AccountDialog extends StatelessWidget {
  const AccountDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black.withOpacity(0.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '계정 관리',
              style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // 🔹 게스트 → 구글 연동
            ListTile(
              leading: const Icon(Icons.link, color: Colors.white70),
              title: const Text('계정 연동 (게스트 → 구글)', style: TextStyle(color: Colors.white)),
              onTap: () async {
                final user = await AuthService().linkGuestToGoogle();
                if (context.mounted) {
                  Navigator.pop(context);
                  if (user != null) {
                    AppNotifier.showSuccess(context, '계정이 연동되었습니다.');
                  } else {
                    AppNotifier.showError(context, '계정 연동에 실패했습니다.');
                  }
                }
              },
            ),

            // 🔹 로그아웃
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white70),
              title: const Text('로그아웃', style: TextStyle(color: Colors.white)),
              onTap: () async {
                await AuthService().signOut();
                if (context.mounted) {
                  Navigator.pop(context);
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => const SplashScreenWrapper(isLoggedIn: false), // ✅ 변경
                    ),
                    (route) => false,
                  );
                }
              },
            ),

            // 🔹 회원 탈퇴
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.redAccent),
              title: const Text('회원 탈퇴', style: TextStyle(color: Colors.redAccent)),
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('회원 탈퇴'),
                    content: const Text('정말 탈퇴하시겠습니까?\n모든 데이터가 영구 삭제됩니다.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
                      TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('탈퇴')),
                    ],
                  ),
                );
                if (confirm == true) {
                  await AuthService().deleteAccount();
                  if (context.mounted) {
                    Navigator.pop(context);
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => const SplashScreenWrapper(isLoggedIn: false), // ✅ 변경
                      ),
                      (route) => false,
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}