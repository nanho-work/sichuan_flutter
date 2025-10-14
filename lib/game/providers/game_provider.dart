import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

/// 게임 진행/상태를 관리하는 Provider
class GameProvider extends ChangeNotifier {
  final GameEngine _engine = GameEngine();
  Timer? _timer;

  // 시작/종료 시각
  DateTime? _startedAt;

  GameEngine get engine => _engine;
  GameState? get state => _engine.state;

  // ====== 공개 API ======

  /// JSON(assets 경로)에서 스테이지 로드 + 엔진 초기화 + 타이머 시작
  Future<void> loadStage(String assetJsonPath, BuildContext context) async {
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

    // 6️⃣ 게임 엔진 초기화
    debugPrint("🔹 Initializing game engine with stage and block images");
    await _engine.init(stage, blockImages.cast<String>());
    debugPrint("🔹 Game engine initialized");

    // 7️⃣ 시작 시간 처리
    _startedAt = DateTime.now();
    _engine.state.timeLeft = stage.timeLimit;

    // 8️⃣ 타이머 시작
    _startTimer();

    notifyListeners();
  }

  /// 타일 클릭
  void selectTile(Tile tile) {
    final changed = _engine.select(tile);
    if (changed) {
      // 클리어/실패 판정 후 종료 처리
      if (_engine.state.cleared || _engine.state.failed) {
        _onGameEnd();
      }
      notifyListeners();
    }
  }

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
        _onGameEnd();
      }
      notifyListeners();
    });
  }

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

    // === Firestore 반영 ===
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
    for (final layer in st.layersByRC) {
      for (final row in layer) {
        for (final t in row) {
          if (t != null && !t.cleared) remain++;
        }
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
}