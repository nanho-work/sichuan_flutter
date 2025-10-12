import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/game_engine.dart';
import '../core/game_state.dart';
import '../models/stage_model.dart';
import '../models/tile_model.dart';
import '../../../providers/inventory_provider.dart';
import '../../../providers/user_provider.dart';
import '../../models/user_item_model.dart';
import '../../models/item_model.dart';

class GameProvider extends ChangeNotifier {
  final _engine = GameEngine();
  GameEngine get engine => _engine;
  GameState? _state;
  Timer? _timer;

  // ✅ 유저 착용 관련
  List<String> _equippedBlockImages = [];
  String? equippedCharacterImage;
  String? equippedBackgroundImage;
  Map<String, dynamic> activeEffects = {};

  GameState? get state => _state;

  /// 🎮 스테이지 로드 + 유저 착용 아이템/이펙트 반영
  Future<void> loadStage(String assetPath, BuildContext context) async {
    final stage = await StageModel.loadFromAsset(assetPath);

    // 1️⃣ 인벤토리 및 유저 정보 가져오기
    final inventoryProvider = context.read<InventoryProvider>();
    final userProvider = context.read<UserProvider>();
    final inventory = inventoryProvider.inventory;
    final user = userProvider.user;

    // 2️⃣ 착용 중인 블럭 / 캐릭터 / 배경 아이템 탐색
    UserItemModel? equippedBlock;
    UserItemModel? equippedCharacter;
    UserItemModel? equippedBackground;

    for (final item in inventory) {
      if (!item.equipped) continue;
      switch (item.category) {
        case 'block':
          equippedBlock = item;
          break;
        case 'character':
          equippedCharacter = item;
          break;
        case 'background':
          equippedBackground = item;
          break;
      }
    }

    // 3️⃣ 블럭 이미지 리스트 inventoryProvider에서 직접 사용
    _equippedBlockImages = [];
    if (equippedBlock != null && equippedBlock.itemId.isNotEmpty) {
      // Since UserItemModel does not have images field, use default constructed paths based on itemId or index
      // For example, assuming itemId corresponds to some index or naming convention
      // Here, we just create a single image path based on itemId for demonstration
      _equippedBlockImages = ['assets/blocks/${equippedBlock.itemId}.png'];
    }

    // 4️⃣ 캐릭터, 배경 이미지 inventoryProvider에서 직접 사용 (없을 시 기본값)
    String getImagePathFromInventory(UserItemModel? item, String defaultPath) {
      if (item == null || item.itemId.isEmpty) return defaultPath;
      // Since no imagePath in UserItemModel, return defaultPath
      return defaultPath;
    }

    equippedCharacterImage =
        getImagePathFromInventory(equippedCharacter, 'assets/images/characters/char_default_01.png');
    equippedBackgroundImage =
        getImagePathFromInventory(equippedBackground, 'assets/images/backgrounds/bg_basic_01.png');

    // 5️⃣ 세트 이펙트 적용
    activeEffects = (user?.setEffects is Map)
        ? Map<String, dynamic>.from(user!.setEffects as Map)
        : {};
    final bonusTime = (activeEffects['time_limit_bonus'] ?? 0).round();

    // 6️⃣ 게임 엔진 초기화
    await _engine.init(stage, _equippedBlockImages);
    _state = _engine.state;

    // 시간 보너스 반영
    if (_state != null) {
      _state!.timeLeft = (_state!.timeLeft + bonusTime).toInt();
    }

    // 7️⃣ 타일 12종 블럭 이미지 배정
    final blockImageCount = _equippedBlockImages.length;
        for (final layer in _state!.layersByRC) {
        for (final row in layer) {
            for (final t in row) {
            if (t == null) continue;

            if (blockImageCount > 0) {
                // ✅ 전역 Provider 기반 블럭 이미지 (착용 블럭)
                final idx = t.type.hashCode.abs() % blockImageCount;
                t.imagePath = _equippedBlockImages[idx];
            } else {
                // ✅ 착용 블럭이 없을 때만 기본 블럭 경로 사용
                t.imagePath = 'assets/images/default_block.png';
            }
            }
        }
        }

    // 8️⃣ 타이머 시작
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _engine.tick();
      notifyListeners();
      if (_state?.cleared == true || _state?.failed == true) {
        _timer?.cancel();
      }
    });

    notifyListeners();
  }

  void disposeTimer() {
    _timer?.cancel();
  }

  void selectTile(Tile tile) {
    if (_state == null || _state!.cleared || _state!.failed) return;
    _engine.select(tile);
    notifyListeners();
  }
}