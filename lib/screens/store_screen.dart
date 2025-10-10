import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/item_provider.dart';
import '../ui/store/store_tab_view.dart';
import '../models/item_model.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> with TickerProviderStateMixin {
  late final TabController _tabController;

  static const tabs = [
    Tab(text: '캐릭터'),
    Tab(text: '블럭'),
    Tab(text: '배경'),
  ];

  static const categories = [
    ItemCategory.character,
    ItemCategory.blockSet,
    ItemCategory.background,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
    // 최초 로딩
    Future.microtask(() => context.read<ItemProvider>().refresh());
  }

  @override
  Widget build(BuildContext context) {
    final itemProvider = context.watch<ItemProvider>();

    return Scaffold(
      backgroundColor: Colors.transparent, // 메인 레이아웃 배경을 그대로 사용
      body: SafeArea(
        child: Column(
          children: [
            // 탭바
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1C2A3A).withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                tabs: tabs,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                indicator: BoxDecoration(
                  color: const Color(0xFF2F4E6B),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            // 컨텐츠
            Expanded(
              child: itemProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      controller: _tabController,
                      children: List.generate(
                        categories.length,
                        (i) => StoreTabView(category: categories[i]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}