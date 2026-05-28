class GamificationStats {
  final int xp;
  final int level;
  final int shields;
  final int currentStreak;
  final int highestStreak;
  final List<String> unlockedBadges;
  final String? lastProcessedDate;

  GamificationStats({
    required this.xp,
    required this.level,
    required this.shields,
    required this.currentStreak,
    required this.highestStreak,
    required this.unlockedBadges,
    this.lastProcessedDate,
  });

  factory GamificationStats.initial() {
    return GamificationStats(
      xp: 0,
      level: 1,
      shields: 0,
      currentStreak: 0,
      highestStreak: 0,
      unlockedBadges: const [],
      lastProcessedDate: null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': 1,
      'xp': xp,
      'level': level,
      'shields': shields,
      'current_streak': currentStreak,
      'highest_streak': highestStreak,
      'unlocked_badges': unlockedBadges.join(','),
      'last_processed_date': lastProcessedDate,
    };
  }

  factory GamificationStats.fromMap(Map<String, dynamic> map) {
    final String badgesStr = map['unlocked_badges'] as String? ?? '';
    final List<String> badgesList = badgesStr.isEmpty
        ? <String>[]
        : badgesStr.split(',');
    return GamificationStats(
      xp: map['xp'] as int? ?? 0,
      level: map['level'] as int? ?? 1,
      shields: map['shields'] as int? ?? 0,
      currentStreak: map['current_streak'] as int? ?? 0,
      highestStreak: map['highest_streak'] as int? ?? 0,
      unlockedBadges: badgesList,
      lastProcessedDate: map['last_processed_date'] as String?,
    );
  }

  GamificationStats copyWith({
    int? xp,
    int? level,
    int? shields,
    int? currentStreak,
    int? highestStreak,
    List<String>? unlockedBadges,
    String? lastProcessedDate,
  }) {
    return GamificationStats(
      xp: xp ?? this.xp,
      level: level ?? this.level,
      shields: shields ?? this.shields,
      currentStreak: currentStreak ?? this.currentStreak,
      highestStreak: highestStreak ?? this.highestStreak,
      unlockedBadges: unlockedBadges ?? this.unlockedBadges,
      lastProcessedDate: lastProcessedDate ?? this.lastProcessedDate,
    );
  }
}
