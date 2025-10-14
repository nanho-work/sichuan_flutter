import 'package:flutter/material.dart';
import '../core/stage_loader.dart';
import 'game_screen.dart';

class StageSelectScreen extends StatefulWidget {
  const StageSelectScreen({super.key});

  @override
  State<StageSelectScreen> createState() => _StageSelectScreenState();
}

class _StageSelectScreenState extends State<StageSelectScreen> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = StageLoader.loadStageIndex(); // assets/game/data/stage_index.json 사용
  }

  void _go(String filePath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GameScreen(stageFilePath: filePath),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('스테이지 선택')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final stages = snap.data!;
          return ListView.separated(
            itemCount: stages.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final s = stages[i];
              final unlocked = s['unlocked'] == true;
              return ListTile(
                leading: (s['thumbnail'] != null)
                    ? Image.asset(s['thumbnail'], width: 48, height: 48, fit: BoxFit.cover)
                    : const SizedBox(width: 48, height: 48),
                title: Text(s['name'] ?? 'Stage'),
                subtitle: Text(s['description'] ?? ''),
                trailing: unlocked
                    ? const Icon(Icons.play_arrow, color: Colors.green)
                    : const Icon(Icons.lock, color: Colors.grey),
                onTap: unlocked ? () => _go(s['file_path']) : null,
              );
            },
          );
        },
      ),
    );
  }
}