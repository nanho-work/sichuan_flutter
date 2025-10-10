import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/store_screen.dart';
import '../screens/inventory_screen.dart';
import '../screens/dungeon_screen.dart';
import '../screens/boss_battle_screen.dart';
import '../models/user_model.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _selectedIndex = 2; // 초기값 홈

  // ✅ 화면 리스트 (5개 탭 구성)
  late final List<Widget> _screens = [
    const StoreScreen(),        // 0
    const InventoryScreen(),    // 1
    const HomeScreen(),         // 2
    const DungeonScreen(),      // 3
    const BossBattleScreen(),   // 4
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
        backgroundColor: Colors.grey.shade900,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: '상점',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: '인벤토리',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.casino),
            label: '던전',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shield),
            label: '수호자 토벌',
          ),
        ],
      ),
    );
  }
}