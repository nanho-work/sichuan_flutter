import 'package:cloud_firestore/cloud_firestore.dart';

/// ==========================
/// Item / Character Data Model
/// --------------------------
/// JSON 샘플 구조에 맞춰 파싱/직렬화 가능한 모델입니다.
/// Firestore <-> 앱 양방향 변환과, 레벨/이펙트 접근 헬퍼를 제공합니다.
/// ==========================

/// 아이템 카테고리
enum ItemCategory { character, blockSet, background, unknown }

extension ItemCategoryX on ItemCategory {
  static ItemCategory fromString(String? v) {
    switch (v) {
      case 'character':
        return ItemCategory.character;
      case 'block_set':
        return ItemCategory.blockSet;
      case 'background':
        return ItemCategory.background;
      default:
        return ItemCategory.unknown;
    }
  }

  String get value {
    switch (this) {
      case ItemCategory.character:
        return 'character';
      case ItemCategory.blockSet:
        return 'block_set';
      case ItemCategory.background:
        return 'background';
      case ItemCategory.unknown:
        return 'unknown';
    }
  }
}

/// 희귀도
enum ItemRarity { common, rare, epic, legendary, unknown }

extension ItemRarityX on ItemRarity {
  static ItemRarity fromString(String? v) {
    switch (v) {
      case 'common':
        return ItemRarity.common;
      case 'rare':
        return ItemRarity.rare;
      case 'epic':
        return ItemRarity.epic;
      case 'legendary':
        return ItemRarity.legendary;
      default:
        return ItemRarity.unknown;
    }
  }

  String get value {
    switch (this) {
      case ItemRarity.common:
        return 'common';
      case ItemRarity.rare:
        return 'rare';
      case ItemRarity.epic:
        return 'epic';
      case ItemRarity.legendary:
        return 'legendary';
      case ItemRarity.unknown:
        return 'unknown';
    }
  }
}

/// 통화 유형 (free/gold/gem)
enum ItemCurrency { free, gold, gem, unknown }

extension ItemCurrencyX on ItemCurrency {
  static ItemCurrency fromString(String? v) {
    switch (v) {
      case 'free':
        return ItemCurrency.free;
      case 'gold':
        return ItemCurrency.gold;
      case 'gem':
        return ItemCurrency.gem;
      default:
        return ItemCurrency.unknown;
    }
  }

  String get value {
    switch (this) {
      case ItemCurrency.free:
        return 'free';
      case ItemCurrency.gold:
        return 'gold';
      case ItemCurrency.gem:
        return 'gem';
      case ItemCurrency.unknown:
        return 'unknown';
    }
  }
}

/// 캐릭터/아이템 이펙트
/// - 숫자 타입이 JSON에서 int/double 모두 가능하므로 num -> double/int 변환 주의
class ItemEffects {
  /// 초 단위 추가 시간 (소수 허용)
  final double timeLimitBonus;

  /// 힌트 보너스 (정수 단계)
  final int hintBonus;

  /// 폭탄 보너스 (정수 단계)
  final int bombBonus;

  /// 리바이브(부활) 횟수
  final int revive;

  /// 셔플 횟수
  final int shuffle;

  /// 장애물 제거 횟수
  final int obstacleRemove;

  /// 골드 보너스 (%) — 소수 허용
  final double goldBonus;

  const ItemEffects({
    this.timeLimitBonus = 0,
    this.hintBonus = 0,
    this.bombBonus = 0,
    this.revive = 0,
    this.shuffle = 0,
    this.obstacleRemove = 0,
    this.goldBonus = 0,
  });

  factory ItemEffects.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const ItemEffects();

    double _toDouble(dynamic v) => (v is num) ? v.toDouble() : 0.0;
    int _toInt(dynamic v) => (v is num) ? v.toInt() : 0;

    return ItemEffects(
      timeLimitBonus: _toDouble(map['time_limit_bonus']),
      hintBonus: _toInt(map['hint_bonus']),
      bombBonus: _toInt(map['bomb_bonus']),
      revive: _toInt(map['revive']),
      shuffle: _toInt(map['shuffle']),
      obstacleRemove: _toInt(map['obstacle_remove']),
      goldBonus: _toDouble(map['gold_bonus']),
    );
  }

  Map<String, dynamic> toMap() => {
        'time_limit_bonus': timeLimitBonus,
        'hint_bonus': hintBonus,
        'bomb_bonus': bombBonus,
        'revive': revive,
        'shuffle': shuffle,
        'obstacle_remove': obstacleRemove,
        'gold_bonus': goldBonus,
      };

  ItemEffects copyWith({
    double? timeLimitBonus,
    int? hintBonus,
    int? bombBonus,
    int? revive,
    int? shuffle,
    int? obstacleRemove,
    double? goldBonus,
  }) {
    return ItemEffects(
      timeLimitBonus: timeLimitBonus ?? this.timeLimitBonus,
      hintBonus: hintBonus ?? this.hintBonus,
      bombBonus: bombBonus ?? this.bombBonus,
      revive: revive ?? this.revive,
      shuffle: shuffle ?? this.shuffle,
      obstacleRemove: obstacleRemove ?? this.obstacleRemove,
      goldBonus: goldBonus ?? this.goldBonus,
    );
  }
}

/// 레벨 단위 데이터
class ItemLevel {
  final int level;
  final String imagePath; // 로컬 asset 경로 (또는 추후 remote URL)
  final ItemEffects effects; // 해당 레벨의 효과 (절대값 기준)

  const ItemLevel({
    required this.level,
    required this.imagePath,
    required this.effects,
  });

  factory ItemLevel.fromMap(Map<String, dynamic> map) {
    return ItemLevel(
      level: (map['level'] as num).toInt(),
      imagePath: map['image_path'] as String,
      effects: ItemEffects.fromMap(map['effects'] as Map<String, dynamic>?),
    );
  }

  Map<String, dynamic> toMap() => {
        'level': level,
        'image_path': imagePath,
        'effects': effects.toMap(),
      };
}

/// 최상위 아이템 모델 (캐릭터/배경/블록 세트 등)
class ItemModel {
  final String id;
  final String name;
  final ItemCategory category;
  final String description;
  final ItemRarity rarity;
  final ItemCurrency currency;
  final bool available;
  final int price; // free일 경우 0
  // ✅ block_set 전용 필드
  final int? count;
  final String? assetPathPrefix;
  final List<String>? thumbnails;
  final List<String>? images;
  final List<ItemLevel> levels;

  const ItemModel({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.rarity,
    required this.currency,
    required this.available,
    required this.price,
    this.count,
    this.assetPathPrefix,
    this.thumbnails,
    this.images,
    required this.levels,
  });

  /// 현재 레벨의 이미지 경로 반환 (기본 1레벨)
  String imagePathForLevel(int level) {
    final found = levels.firstWhere(
      (e) => e.level == level,
      orElse: () => levels.first,
    );
    return found.imagePath;
  }

  /// 해당 레벨의 효과 반환 (절대값 기준)
  ItemEffects effectsForLevel(int level) {
    final found = levels.firstWhere(
      (e) => e.level == level,
      orElse: () => levels.first,
    );
    return found.effects;
  }

  /// JSON/Map -> 모델
  factory ItemModel.fromMap(Map<String, dynamic> map) {
    final levelsJson = (map['levels'] as List<dynamic>? ?? [])
        .map((e) => ItemLevel.fromMap(e as Map<String, dynamic>))
        .toList();

    return ItemModel(
      id: map['id'] as String,
      name: map['name'] as String,
      category: ItemCategoryX.fromString(map['category'] as String?),
      description: (map['description'] ?? '') as String,
      rarity: ItemRarityX.fromString(map['rarity'] as String?),
      currency: ItemCurrencyX.fromString(map['currency'] as String?),
      available: (map['available'] as bool?) ?? true,
      price: (map['price'] as num?)?.toInt() ?? 0,
      count: (map['count'] as num?)?.toInt(),
      assetPathPrefix: map['asset_path_prefix'] as String?,
      thumbnails: (map['thumbnails'] as List?)?.cast<String>(),
      images: (map['images'] as List?)?.cast<String>(),
      levels: levelsJson,
    );
  }

  /// Firestore Doc -> 모델
  factory ItemModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return ItemModel.fromMap(data);
  }

  /// 모델 -> Map(JSON)
  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'category': category.value,
        'description': description,
        'rarity': rarity.value,
        'currency': currency.value,
        'available': available,
        'price': price,
        'count': count,
        'asset_path_prefix': assetPathPrefix,
        'thumbnails': thumbnails,
        'images': images,
        'levels': levels.map((e) => e.toMap()).toList(),
      };

  ItemModel copyWith({
    String? id,
    String? name,
    ItemCategory? category,
    String? description,
    ItemRarity? rarity,
    ItemCurrency? currency,
    bool? available,
    int? price,
    int? count,
    String? assetPathPrefix,
    List<String>? thumbnails,
    List<String>? images,
    List<ItemLevel>? levels,
  }) {
    return ItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      rarity: rarity ?? this.rarity,
      currency: currency ?? this.currency,
      available: available ?? this.available,
      price: price ?? this.price,
      count: count ?? this.count,
      assetPathPrefix: assetPathPrefix ?? this.assetPathPrefix,
      thumbnails: thumbnails ?? this.thumbnails,
      images: images ?? this.images,
      levels: levels ?? this.levels,
    );
  }
}

/// 유틸: JSON 배열을 모델 리스트로 변환
class ItemParser {
  static List<ItemModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .whereType<Map<String, dynamic>>()
        .map(ItemModel.fromMap)
        .toList();
  }
}