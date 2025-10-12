class Modifiers {
  final bool enableHint;
  final bool enableBomb;
  final bool enableShuffle;
  final bool enableRevive;
  final bool enableTimeBonus;
  final int timeBonusPerCombo;

  const Modifiers({
    required this.enableHint,
    required this.enableBomb,
    required this.enableShuffle,
    required this.enableRevive,
    required this.enableTimeBonus,
    required this.timeBonusPerCombo,
  });

  factory Modifiers.fromStage(Map<String, dynamic> m) {
    return Modifiers(
      enableHint: (m['enable_hint'] as bool?) ?? true,
      enableBomb: (m['enable_bomb'] as bool?) ?? true,
      enableShuffle: (m['enable_shuffle'] as bool?) ?? true,
      enableRevive: (m['enable_revive'] as bool?) ?? false,
      enableTimeBonus: (m['enable_time_bonus'] as bool?) ?? false,
      timeBonusPerCombo: (m['time_bonus_per_combo'] as num?)?.toInt() ?? 0,
    );
  }
}