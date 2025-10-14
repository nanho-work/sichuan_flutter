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

  static const tabImage = 'assets/images/tabbar_bg.png';

  late final List<Widget> tabs;

  static const categories = [
    ItemCategory.character,
    ItemCategory.blockSet,
    ItemCategory.background,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    tabs = List.generate(3, (index) {
      return Tab(
        child: AnimatedBuilder(
          animation: _tabController,
          builder: (context, child) {
            bool isSelected = _tabController.index == index;
            String text;
            if (index == 0) {
              text = '캐릭터';
            } else if (index == 1) {
              text = '블럭';
            } else {
              text = '배경';
            }
            return Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(tabImage),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.transparent : Colors.black.withOpacity(0.4), // dark overlay only if not selected
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                Center(
                  child: Text(
                    text,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
            );
          },
        ),
      );
    });
    // 최초 로딩
    Future.microtask(() => context.read<ItemProvider>().refresh());
  }

  @override
  Widget build(BuildContext context) {
    final itemProvider = context.watch<ItemProvider>();

    return Scaffold(
      backgroundColor: Colors.transparent, // 메인 레이아웃 배경을 그대로 사용
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/store_bg.png',
            fit: BoxFit.cover,
          ),
          SafeArea(
            child: Column(
              children: [
                // 탭바
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  // Remove background image, just keep margin and radius for layout
                  child: TabBar(
                    controller: _tabController,
                    tabs: tabs,
                    isScrollable: false, // 가로 전체 균등 분배
                    labelPadding: EdgeInsets.zero, // ← 기본 좌우 패딩 제거 (가장 중요!)
                    indicatorPadding: EdgeInsets.zero, // ← 인디케이터 여백 제거
                    indicatorSize: TabBarIndicatorSize.tab, // 탭 크기에 딱 맞게
                    indicator: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white,
                    overlayColor: MaterialStateProperty.resolveWith<Color?>(
                      (Set<MaterialState> states) {
                        if (states.contains(MaterialState.selected)) return Colors.transparent;
                        return Colors.black.withOpacity(0.4);
                      },
                    ),
                  )
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
        ],
      ),
    );
  }
}