import 'package:flutter/material.dart';
import '../settings_dialog.dart';

class AppSidebar extends StatelessWidget {
  const AppSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blueAccent),
            child: Center(
              child: Text(
                '⚙️ 메뉴',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('설정'),
            onTap: () {
              Navigator.pop(context); // Drawer 닫기
              showSettingsDialog(context); // 설정 다이얼로그 열기
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('앱 정보'),
            onTap: () {
              Navigator.pop(context);
              _showInfoDialog(context);
            },
          ),
          const Divider(),
          // 향후 추가 메뉴: “랭킹”, “친구초대” 등 여기에 추가 가능
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('앱 정보'),
        content: const Text('Koofy Sichuan v1.0.0\n© Koofy Games.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }
}