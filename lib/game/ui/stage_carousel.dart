import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/stage_controller.dart';
import '../../providers/user_provider.dart';
import '../../models/user_model.dart';

class StageCarousel extends StatefulWidget {
  final void Function(String filePath) onPlay; // 눌렀을 때 실행
  const StageCarousel({super.key, required this.onPlay});

  @override
  State<StageCarousel> createState() => _StageCarouselState();
}

class _StageCarouselState extends State<StageCarousel> {
  late final PageController _pc;

  @override
  void initState() {
    super.initState();
    _pc = PageController(viewportFraction: 0.82);
    Future.microtask(() => context.read<StageController>().load());
  }

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user; // 🔹 유저 진행도
    return Consumer<StageController>(
      builder: (context, c, _) {
        if (c.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (c.error != null) {
          return Center(child: Text('로드 실패: ${c.error}', style: const TextStyle(color: Colors.red)));
        }
        if (c.stages.isEmpty) {
          return const Center(child: Text('스테이지가 없습니다.'));
        }

        bool isUnlockedForUser(String stageId, bool indexUnlocked) {
          if (user == null) return indexUnlocked;
          return indexUnlocked || user.isStageUnlocked(stageId);
        }

        return Column(
          children: [
            const SizedBox(height: 8),
            const Text('스테이지', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              height: 280,
              child: PageView.builder(
                controller: _pc,
                itemCount: c.stages.length,
                onPageChanged: c.setPage,
                itemBuilder: (context, i) {
                  final s = c.stages[i];
                  final unlocked = isUnlockedForUser(s.id, s.unlocked);
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (s.thumbnail.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              s.thumbnail,
                              width: 240,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          ),
                        const SizedBox(height: 12),
                        Text(
                          s.name,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: Text(
                            s.description,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.7)),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 14),
                        ElevatedButton.icon(
                          onPressed: unlocked && s.filePath.isNotEmpty
                              ? () => widget.onPlay(s.filePath)
                              : null,
                          icon: const Icon(Icons.play_arrow),
                          label: Text(unlocked ? '도전하기' : '잠금'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: unlocked ? Colors.green : Colors.grey,
                            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                c.stages.length,
                (i) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (i == c.page) ? Colors.white : Colors.white24,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}