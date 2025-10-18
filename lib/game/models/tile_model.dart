class Tile {
  final int x;
  final int y;
  String type;
  bool cleared;
  String? imagePath;
  String? skinId;
  bool isActive;
  String? blockItemId;

  Tile({
    required this.x,
    required this.y,
    this.type = '',
    this.cleared = false,
    this.imagePath,
    this.skinId,
    this.isActive = true,
    this.blockItemId,
  });

  factory Tile.fromMap(Map<String, dynamic> map) {
    return Tile(
      x: map['x'] ?? 0,
      y: map['y'] ?? 0,
      type: map['type'] ?? '',
      cleared: map['cleared'] ?? false,
      imagePath: map['imagePath'] ?? map['image_path'],
      skinId: map['skinId'] ?? map['skin_id'],
      isActive: map['isActive'] ?? true,
      blockItemId: map['blockItemId'] ?? map['block_item_id'],
    );
  }

  Map<String, dynamic> toMap() => {
        'x': x,
        'y': y,
        'type': type,
        'cleared': cleared,
        'image_path': imagePath,
        'skin_id': skinId,
        'is_active': isActive,
        'block_item_id': blockItemId,
      };

  Tile copyWith({
    String? type,
    bool? cleared,
    String? imagePath,
    String? skinId,
    bool? isActive,
    String? blockItemId,
  }) {
    return Tile(
      x: x,
      y: y,
      type: type ?? this.type,
      cleared: cleared ?? this.cleared,
      imagePath: imagePath ?? this.imagePath,
      skinId: skinId ?? this.skinId,
      isActive: isActive ?? this.isActive,
      blockItemId: blockItemId ?? this.blockItemId,
    );
  }

  @override
  String toString() =>
      'Tile($x,$y,type=$type,cleared=$cleared,blockItemId=$blockItemId)';
}