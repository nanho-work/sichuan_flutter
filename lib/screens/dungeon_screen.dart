import 'package:flutter/material.dart';

class DungeonScreen extends StatelessWidget {
  const DungeonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> dungeons = [
      {"name": "도토리 원정대", "desc": "골드 획득 던전", "color": Colors.brown.shade400},
      {"name": "루비 원정대", "desc": "젬 획득 던전", "color": Colors.redAccent.shade200},
      {"name": "진화 원정대", "desc": "조각 획득 던전", "color": Colors.green.shade400},
      {"name": "요일 던전", "desc": "요일별 특별 보상", "color": Colors.blue.shade400},
      {"name": "COMING SOON", "desc": "준비중입니다", "color": Colors.grey.shade600},
      {"name": "COMING SOON", "desc": "준비중입니다", "color": Colors.grey.shade600},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              const Text(
                "⚔️ 던전",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: dungeons.length,
                  itemBuilder: (context, index) {
                    final dungeon = dungeons[index];
                    return Card(
                      color: dungeon['color'],
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          dungeon['name']!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                        subtitle: Text(
                          dungeon['desc']!,
                          style: const TextStyle(color: Colors.white70),
                        ),
                        trailing: const Icon(Icons.play_arrow_rounded,
                            color: Colors.white, size: 32),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("${dungeon['name']} 입장!")),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}