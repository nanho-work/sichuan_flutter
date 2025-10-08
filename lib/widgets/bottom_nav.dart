import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/store_screen.dart';
import '../screens/inventory_screen_screen.dart';
import '../models/user_model.dart';

class BottomNav extends StatefulWidget {
  final UserModel userModel;
  const BottomNav({super.key, required this.userModel});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _selectedIndex = 0;

  // 화면 리스트 (현재 홈만 활성화)
  late final List<Widget> _screens = [
    const HomeScreen(),
    const StoreScreen(),
    const Inventory_screenScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront),
            label: '상점',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.face_retouching_natural),
            label: '캐릭터',
          ),
        ],
      ),
    );
  }
}