import 'package:flutter/foundation.dart';

/// 타일(같이 맞출 대상)
class Tile {
  final int x;
  final int y;
  final int layer;
  String type;          // 엔진이 페어링 시 부여 ('A','B'..)
  bool cleared;         // 제거 여부
  String? imagePath;       // 블럭 이미지 경로
  String? skinId;          // 블럭 스킨 ID (착용 아이템)
  bool isActive;           // 현재 레이어에서 활성화 상태
  String? blockItemId;     // Firestore item_id of the equipped block

  Tile({
    required this.x,
    required this.y,
    required this.layer,
    this.type = '',
    this.cleared = false,
    this.imagePath,
    this.skinId,
    this.isActive = true,
    this.blockItemId,
  });

  Tile copyWith({
    String? type,
    bool? cleared,
    String? imagePath,
    String? skinId,
    bool? isActive,
    String? blockItemId,
  }) => Tile(
        x: x,
        y: y,
        layer: layer,
        type: type ?? this.type,
        cleared: cleared ?? this.cleared,
        imagePath: imagePath ?? this.imagePath,
        skinId: skinId ?? this.skinId,
        isActive: isActive ?? this.isActive,
        blockItemId: blockItemId ?? this.blockItemId,
      );

  @override
  String toString() => 'Tile($x,$y,L$layer,type=$type,cleared=$cleared,blockItemId=$blockItemId)';
}

/// 장애물
class Obstacle {
  final int x;
  final int y;
  final String type;       // 'stone' | 'ice' ...
  final int durability;    // 기본 1

  const Obstacle({
    required this.x,
    required this.y,
    required this.type,
    this.durability = 1,
  });
}

/// 스페셜 타일(클릭 시 효과)
class SpecialTile {
  final int x;
  final int y;
  final String effect;   // 'bomb' | 'shuffle' ...

  const SpecialTile({
    required this.x,
    required this.y,
    required this.effect,
  });
}