import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart'; // For navigatorKey.currentContext
import 'package:sichuan_flutter/main.dart';

import '../core/game_engine.dart';
import '../core/game_state.dart';
import '../models/stage_model.dart';
import '../models/tile_model.dart';
import '../models/game_result.dart';
import '../../models/item_model.dart';
import '../../models/user_item_model.dart';


import '../../providers/inventory_provider.dart';
import '../../providers/item_provider.dart';
import '../../providers/user_provider.dart';

// ========================================================================
// 📘 GameProvider Overview
// ------------------------------------------------------------------------
// 1. 🎮 스테이지 로드 및 게임 시작
// 2. 🧩 타일 선택 처리
// 3. ⏰ 타이머 관리
// 4. 💀 게임 종료 및 보상 처리
// 5. 🧾 보상 반영 및 기록 저장
// ========================================================================

/// 게임 진행/상태를 관리하는 Provider
class GameProvider extends ChangeNotifier {
  final GameEngine _engine = GameEngine();
  Timer? _timer;

  MatchResultType? lastResultType;

  List<List<Tile?>>? _projectedLayer;
  List<List<Tile?>>? get projectedLayer => _projectedLayer;

  String? _lastStagePath; // ✅ 마지막 스테이지 파일 경로 저장

  // 시작/종료 시각
  DateTime? _startedAt;

  String? _backgroundImage;
  String? get backgroundImage => _backgroundImage;

  GameEngine get engine => _engine;
  GameState? get state => _engine.state;

  // 🔒 타일 입력 잠금 상태
  bool _isLocked = false;
  bool get isLocked => _isLocked;

  void _buildProjectedLayer() {
    final st = _engine.state;
    if (st == null) {
      debugPrint("⚠️ Game state is null; cannot build projected layer");
      _projectedLayer = null;
      return;
    }
    final board = st.board;
    if (board.isEmpty) {
      debugPrint("⚠️ board is empty; cannot build projected layer");
      _projectedLayer = null;
      return;
    }
    final height = board.length;
    final width = board[0].length;
    List<List<Tile?>> pLayer = List.generate(height, (_) => List<Tile?>.filled(width, null));

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final tile = board[y][x];
        pLayer[y][x] = (tile != null && !tile.cleared) ? tile : null;
        debugPrint("ProjectedLayer[$y][$x] = ${pLayer[y][x] != null ? 'Tile(x=${pLayer[y][x]!.x}, y=${pLayer[y][x]!.y}, cleared=${pLayer[y][x]!.cleared})' : 'null'}");
      }
    }
    _projectedLayer = pLayer;
    debugPrint("🔹 Projected layer built with size ${height}x${width}");
  }

  // ========================================================================
  //     🎮 스테이지 로드 및 게임 시작
  // ========================================================================

  /// JSON(assets 경로)에서 스테이지 로드 + 엔진 초기화 + 타이머 시작
  Future<void> loadStage(String assetJsonPath, BuildContext context) async {
    _lastStagePath = assetJsonPath; // ✅ 경로 기록
    // 1️⃣ 스테이지 로드
    final raw = await rootBundle.loadString(assetJsonPath);
    final map = json.decode(raw) as Map<String, dynamic>;
    final stage = StageModel.fromMap(map);
    debugPrint("🔹 Stage loaded from $assetJsonPath: id=${stage.id}, name=${stage.name}");

    // 2️⃣ 인벤토리 스냅샷 즉시 사용
    final inv = context.read<InventoryProvider>();
    debugPrint("🔹 Inventory snapshot size: ${inv.inventory.length}");

    // 3️⃣ 현재 착용한 블록 아이템 Firestore 구조에 맞게 찾기
    final equippedBlock = inv.inventory.firstWhere(
      (e) => e.category == 'block_set' && e.equipped == true,
      orElse: () => UserItemModel.empty(),
    );
    debugPrint("🔹 Equipped block set found: itemId=${equippedBlock.itemId}, equipped=${equippedBlock.equipped}");

    if (equippedBlock.itemId.isEmpty) {
      debugPrint("⚠️ No equipped block set found (itemId is empty)");
      return;
    }

    // 4️⃣ 해당 블록 세트의 ItemModel 가져오기
    final itemProvider = context.read<ItemProvider>();
    final blockModel = itemProvider.items.firstWhere(
      (m) => m.id == equippedBlock.itemId,
      orElse: () => ItemModel.empty(),
    );
    debugPrint("🔹 Block set model: id=${blockModel.id}, name=${blockModel.name}");

    // 5️⃣ 블록 세트의 이미지 배열 가져오기
    List<String> blockImages = [];
    if (blockModel.images != null && blockModel.images!.isNotEmpty) {
      // ✅ 절대경로 중복 방지 처리
      final prefix = blockModel.assetPathPrefix ?? '';
      blockImages = blockModel.images!.map((img) {
        if (img.startsWith('assets/')) {
          return img;
        } else {
          return '$prefix$img';
        }
      }).toList();

      debugPrint("🧩 Prefix: $prefix");
      debugPrint("🧩 Raw images: ${blockModel.images}");
    }
    debugPrint("🔹 Block images count: ${blockImages.length}");
    debugPrint("🔹 Final block images list: $blockImages");

    // === 새로 추가된 배경 이미지 처리 ===
    final equippedBackground = inv.inventory.firstWhere(
      (e) => e.category == 'background' && e.equipped == true,
      orElse: () => UserItemModel.empty(),
    );
    debugPrint("🔹 Equipped background found: itemId=${equippedBackground.itemId}, equipped=${equippedBackground.equipped}");

    if (equippedBackground.itemId.isNotEmpty) {
      final bgModel = itemProvider.items.firstWhere(
        (m) => m.id == equippedBackground.itemId,
        orElse: () => ItemModel.empty(),
      );
      String? bgImagePath;
      if (bgModel.images != null && bgModel.images!.isNotEmpty) {
        bgImagePath = bgModel.images!.first;
      }
      _backgroundImage = bgImagePath;
      debugPrint("🔹 Background image loaded: $_backgroundImage");
    } else {
      _backgroundImage = null;
      debugPrint("⚠️ No equipped background found (itemId is empty)");
    }

    // 6️⃣ 게임 엔진 초기화
    debugPrint("🔹 Initializing game engine with stage and block images");
    await _engine.init(stage, blockImages.cast<String>(), backgroundImage: backgroundImage);
    debugPrint("🔹 Game engine initialized");

    _buildProjectedLayer();

    // 7️⃣ 시작 시간 처리
    _startedAt = DateTime.now();
    _engine.state.timeLeft = stage.timeLimit;

    // ========================================================================
    //     ⏰ 타이머 시작
    // ========================================================================
    _startTimer();

    notifyListeners();
  }

  // ========================================================================
  //     🧩 타일 선택 처리
  // ========================================================================

  /// 타일 클릭
  MatchResult selectTile(Tile tile) {
    final result = _engine.select(tile); // MatchResult 객체 리턴
    lastResultType = result.type;
    switch (result.type) {
      case MatchResultType.matched:
        // 성공 시: UI가 콤보, 효과음 등을 처리할 수 있도록 상태 반영
        break;
      case MatchResultType.wrong:
        // 실패 시: 콤보 초기화나 피드백을 위한 처리 가능
        _isLocked = true;
        notifyListeners();

        // 2초 동안 입력 잠금 + 틀린 피드백 표시
        Future.delayed(const Duration(seconds: 2), () {
          _engine.clearSelections(); // 선택 해제
          _isLocked = false;
          lastResultType = null; // 깜박임 상태 초기화
          notifyListeners();
        });
        break;
      case MatchResultType.cleared:
      case MatchResultType.failed:
        // 클리어 또는 실패 처리
        _onGameEnd();
        break;
      default:
        break;
    }
    notifyListeners();
    return result;
  }

  // ========================================================================
  //     ⏰ 타이머 관리
  // ========================================================================

  /// 타이머/리소스 정리
  void disposeTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    disposeTimer();
    super.dispose();
  }

  // ====== 내부 동작 ======

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _engine.tick();
      if (_engine.state.cleared || _engine.state.failed) {
        // ========================================================================
        //     💀 게임 종료 처리
        // ========================================================================
        _onGameEnd();
      }
      notifyListeners();
    });
  }

  // ========================================================================
  //     💀 게임 종료 및 보상 처리
  // ========================================================================

  /// 게임 종료 처리(보상 계산 + Firestore 반영)
  Future<void> _onGameEnd() async {
    disposeTimer();

    final ctx = _safeContext();
    if (ctx == null) return;

    final inv = ctx.read<InventoryProvider>();
    final items = ctx.read<ItemProvider>().items;
    final userProvider = ctx.read<UserProvider>();

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final st = _engine.state;
    final stage = st.stage;

    // 사용 장착물
    final charId = _equippedItemId(inv, 'character');
    final blockId = _equippedItemId(inv, 'block_set');
    final bgId = _equippedItemId(inv, 'background');

    // === 보상 계산 ===
    // 1) 스테이지 기본 보상
    final baseGold = stage.rewards['gold'] ?? 0;
    final baseGem  = stage.rewards['gem'] ?? 0;
    final baseExp  = stage.rewards['exp'] ?? 0;

    // 2) 장착 캐릭터 + 세트로부터 gold_bonus%
    final goldBonusPercent = _calcGoldBonusPercent(inv, items);
    final finalGold = (baseGold * (1 + goldBonusPercent / 100)).round();

    // 3) 실패 시 골드 20%만 지급(간단 규칙)
    final cleared = st.cleared;
    final failed = st.failed;
    final goldEarned = failed ? (finalGold * 0.2).round() : finalGold;

    // ========================================================================
    //     🧾 Firestore 보상 및 기록 저장
    // ========================================================================
    await _saveRewardsAndRecord(
      uid: user.uid,
      gold: goldEarned,
      gem: cleared ? baseGem : 0,
      result: GameResult(
        stageId: stage.id,
        stageName: stage.name,
        difficulty: stage.difficulty,
        cleared: cleared,
        failed: failed,
        score: _calcScore(st),                 // 간단 스코어
        playTimeSec: _playedSeconds(),
        goldEarned: goldEarned,
        gemEarned: cleared ? baseGem : 0,
        expGained: cleared ? baseExp : 0,
        usedCharacterId: charId,
        usedBlockSetId: blockId,
        usedBackgroundId: bgId,
        // 캐릭터 강화: 클리어 시 +1 (예시)
        enhanceItemId: cleared ? charId : null,
        enhanceIncrement: cleared ? 1 : null,
        startedAt: _startedAt ?? DateTime.now(),
        endedAt: DateTime.now(),
      ),
      inv: inv,
    );

    // 최신 유저 데이터 동기화
    await userProvider.loadUser();

    // === 스테이지 클리어 추가 로직 ===
    if (cleared) {
      await _unlockNextStage(stage.id);
      await _saveClearTime(stage.id, _playedSeconds());
      await _showClearDialog(stage, goldEarned, baseGem, baseExp);
    }

    notifyListeners();
  }

  // ====== 유틸 ======

  BuildContext? _safeContext() {
    // 프로바이더가 MaterialApp의 트리 안에서 동작한다고 가정
    // (전역 navigatorKey를 쓰지 않고, UI에서 read/watch로 접근)
    // 이 Provider는 외부에서 context.read<GameProvider>()로 접근됨.
    // 여기서는 없음.
    return null;
  }

  int _playedSeconds() {
    if (_startedAt == null) return 0;
    final end = DateTime.now();
    return end.difference(_startedAt!).inSeconds.clamp(0, 86400);
    // 하루 이상 플레이는 없겠지.. 안전 클램프
  }

  int _calcScore(GameState st) {
    // 예시: 남은 시간 * 10 + (총 타일 수 - 제거 못한 타일 수) * 5
    int left = st.timeLeft;
    int remain = 0;
    for (final row in st.board) {
      for (final t in row) {
        if (t != null && !t.cleared) remain++;
      }
    }
    final total = st.stage.tiles.length;
    final clearedCnt = total - remain;
    return left * 10 + clearedCnt * 5;
  }

  String? _equippedItemId(InventoryProvider inv, String categoryValue) {
    try {
      final it = inv.inventory.firstWhere(
        (e) => e.category == categoryValue && e.equipped,
      );
      return it.itemId;
    } catch (_) {
      return null;
    }
  }

  /// 현재 장착 캐릭터 + 완성 세트로부터 gold_bonus(%)를 계산
  double _calcGoldBonusPercent(InventoryProvider inv, List items) {
    double bonus = 0.0;

    // 1) 캐릭터 이펙트
    final charId = _equippedItemId(inv, 'character');
    if (charId != null) {
      final charModel = _findItem(items, charId);
      if (charModel != null) {
        final uItem = inv.inventory.firstWhere(
          (e) => e.itemId == charId,
          orElse: () => inv.inventory.first,
        );
        final level = uItem.upgradeLevel ?? 1;
        final eff = charModel.effectsForLevel(level);
        bonus += eff.goldBonus;
      }
    }

    // 2) 세트 완성 보너스 (인벤토리 장착 목록으로 완성 세트 판정)
    //    InventoryProvider.applySetEffects와 동일 컨셉이지만, 여기선 gold_bonus만 사용.
    //    setId 기준으로 requiredItems 모두 장착 여부 확인
    final equipped = inv.inventory.where((e) => e.equipped).map((e) => e.itemId).toSet();
    final setIds = inv.inventory
        .where((e) => e.equipped && (e.setId?.isNotEmpty ?? false))
        .map((e) => e.setId!)
        .toSet();

    for (final setId in setIds) {
      final setModel = _findItemSet(inv, setId);
      if (setModel == null) continue;
      final required = (setModel.requiredItems).toSet();
      final complete = required.difference(equipped).isEmpty;
      if (complete) {
        final fx = setModel.effects;
        final add = (fx['gold_bonus'] as num?)?.toDouble() ?? 0.0;
        bonus += add;
      }
    }
    return bonus;
  }

  // ItemModel을 items에서 찾기
  dynamic _findItem(List items, String id) {
    try {
      return items.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  // ItemSetModel을 InventoryProvider.itemProvider?.itemSets에서 찾기
  dynamic _findItemSet(InventoryProvider inv, String setId) {
    try {
      final ip = inv.itemProvider;
      if (ip == null) return null;
      final sets = (ip as dynamic).itemSets; // itemSets 게터가 있어야 함
      return sets.firstWhere((s) => s.id == setId);
    } catch (_) {
      return null;
    }
  }

  // ========================================================================
  //     🧾 보상 반영 및 기록 저장
  // ========================================================================

  /// 보상 반영 + 기록 저장
  Future<void> _saveRewardsAndRecord({
    required String uid,
    required int gold,
    required int gem,
    required GameResult result,
    required InventoryProvider inv,
  }) async {
    final db = FirebaseFirestore.instance;
    final userRef = db.collection('users').doc(uid);
    final recordsRef = db.collection('records');

    await db.runTransaction((tx) async {
      final u = await tx.get(userRef);
      if (!u.exists) return;

      final curGold = (u.data()?['gold'] ?? 0) as int;
      final curGem = (u.data()?['gems'] ?? 0) as int;

      tx.update(userRef, {
        'gold': (curGold + gold).clamp(0, 999999999),
        'gems': (curGem + gem).clamp(0, 999999999),
        'last_login': FieldValue.serverTimestamp(),
      });

      // 기록 저장
      tx.set(recordsRef.doc(), result.toMap(uid: uid));

      // 강화(옵션)
      if (result.enhanceItemId != null && (result.enhanceIncrement ?? 0) > 0) {
        final itemId = result.enhanceItemId!;
        // 현재 레벨 파악
        final userItem = inv.inventory.firstWhere(
          (e) => e.itemId == itemId,
          orElse: () => inv.inventory.first,
        );
        final curLv = userItem.upgradeLevel ?? 1;
        tx.update(
          userRef.collection('user_items').doc(itemId),
          {'upgrade_level': curLv + (result.enhanceIncrement ?? 0)},
        );
      }
    });
  }

  // ========================================================================
  //     🔓 다음 스테이지 언락
  // ========================================================================
  /// 현재 스테이지를 클리어한 뒤, 다음 스테이지를 언락 처리
  Future<void> _unlockNextStage(String clearedStageId) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    // 1. index.json 로드 (경로 변경)
    final raw = await rootBundle.loadString('assets/game/data/index.json');
    final List<dynamic> stageList = json.decode(raw);
    // 2. 현재 스테이지의 다음 스테이지 찾기
    int idx = stageList.indexWhere((e) => e['id'] == clearedStageId);
    if (idx == -1) return; // 못 찾으면 종료
    if (idx + 1 >= stageList.length) return; // 마지막 스테이지면 종료
    final nextStage = stageList[idx + 1];
    final nextStageId = nextStage['id'];
    // 3. Firestore의 stage_progress/{uid} 문서 갱신
    final db = FirebaseFirestore.instance;
    final docRef = db.collection('stage_progress').doc(uid);
    await db.runTransaction((tx) async {
      final docSnap = await tx.get(docRef);
      Map<String, dynamic> data = {};
      if (docSnap.exists) {
        data = Map<String, dynamic>.from(docSnap.data() ?? {});
      }
      // 현재 클리어 처리
      data[clearedStageId] = {
        ...(data[clearedStageId] ?? {}),
        'cleared': true,
        'unlocked': true,
      };
      // 다음 스테이지 언락
      data[nextStageId] = {
        ...(data[nextStageId] ?? {}),
        'unlocked': true,
      };
      tx.set(docRef, data, SetOptions(merge: true));
    });
  }

  // ========================================================================
  //     ⏱️ 클리어 시간 저장
  // ========================================================================
  /// 스테이지 별 최고 클리어 타임 저장
  Future<void> _saveClearTime(String stageId, int seconds) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final db = FirebaseFirestore.instance;
    final docRef = db.collection('stage_progress').doc(uid);
    await db.runTransaction((tx) async {
      final docSnap = await tx.get(docRef);
      Map<String, dynamic> data = {};
      if (docSnap.exists) {
        data = Map<String, dynamic>.from(docSnap.data() ?? {});
      }
      final prev = (data[stageId]?['best_time'] as int?) ?? 9999999;
      if (seconds < prev) {
        data[stageId] = {
          ...(data[stageId] ?? {}),
          'best_time': seconds,
        };
        tx.set(docRef, data, SetOptions(merge: true));
      }
    });
  }

  // ========================================================================
  //     🎉 클리어 다이얼로그 표시
  // ========================================================================
  /// 스테이지 클리어 시 보상 안내 다이얼로그 표시
  Future<void> _showClearDialog(StageModel stage, int gold, int gem, int exp) async {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    // 다음 스테이지 경로 계산
    String? nextStagePath;
    try {
      final raw = await rootBundle.loadString('assets/game/data/index.json');
      final List<dynamic> stageList = json.decode(raw);
      int idx = stageList.indexWhere((e) => e['id'] == stage.id);
      if (idx != -1 && idx + 1 < stageList.length) {
        final nextStage = stageList[idx + 1];
        // index.json 구조에 따라 file_path 사용
        nextStagePath = nextStage['file_path'];
      }
    } catch (e) {
      debugPrint("⚠️ Failed to find next stage: $e");
    }

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: Text('${stage.name} 클리어!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('골드: $gold'),
              Text('젬: $gem'),
              Text('경험치: $exp'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('닫기'),
            ),
            if (nextStagePath != null)
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  await loadStage(nextStagePath!, context);
                },
                child: const Text('다음 스테이지'),
              ),
          ],
        );
      },
    );
  }
  // ========================================================================
  //     🔁 스테이지 재시작
  // ========================================================================
  Future<void> restartStage(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userProvider = context.read<UserProvider>();
    final energy = userProvider.user?.energy ?? 0;

    if (energy <= 0) {
      debugPrint("⚠️ 에너지가 부족합니다. 충전 후 이용해주세요.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("에너지가 부족합니다. 충전 후 이용해주세요.")),
      );
      return;
    }

    // ✅ 에너지 차감
    await userProvider.consumeEnergy(1);

    // ✅ 동일 스테이지 재시작
    disposeTimer();
    if (_lastStagePath != null) {
      await loadStage(_lastStagePath!, context);
    } else {
      debugPrint("⚠️ _lastStagePath is null — cannot restart stage");
    }
  }
}