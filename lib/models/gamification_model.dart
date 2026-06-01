class GamificationStats {
  final int xp;
  final int level;
  final int shields;
  final int currentStreak;
  final int highestStreak;
  final List<String> unlockedBadges;
  final List<String> acknowledgedBadges;
  final String? lastProcessedDate;

  int get prestigeStars {
    if (xp < 5400) return 0;
    return (xp - 5400) ~/ 1000;
  }

  int get nextPrestigeThreshold {
    if (xp < 5400) return 5400;
    return 5400 + (prestigeStars + 1) * 1000;
  }

  int get prestigeXpProgress {
    if (xp < 5400) return 0;
    return (xp - 5400) % 1000;
  }

  GamificationStats({
    required this.xp,
    required this.level,
    required this.shields,
    required this.currentStreak,
    required this.highestStreak,
    required this.unlockedBadges,
    required this.acknowledgedBadges,
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
      acknowledgedBadges: const [],
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
      'acknowledged_badges': acknowledgedBadges.join(','),
      'last_processed_date': lastProcessedDate,
    };
  }

  factory GamificationStats.fromMap(Map<String, dynamic> map) {
    final String badgesStr = map['unlocked_badges'] as String? ?? '';
    final List<String> badgesList = badgesStr.isEmpty
        ? <String>[]
        : badgesStr.split(',');

    final String ackBadgesStr = map['acknowledged_badges'] as String? ?? '';
    final List<String> ackBadgesList = ackBadgesStr.isEmpty
        ? <String>[]
        : ackBadgesStr.split(',');

    return GamificationStats(
      xp: map['xp'] as int? ?? 0,
      level: map['level'] as int? ?? 1,
      shields: map['shields'] as int? ?? 0,
      currentStreak: map['current_streak'] as int? ?? 0,
      highestStreak: map['highest_streak'] as int? ?? 0,
      unlockedBadges: badgesList,
      acknowledgedBadges: ackBadgesList,
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
    List<String>? acknowledgedBadges,
    String? lastProcessedDate,
  }) {
    return GamificationStats(
      xp: xp ?? this.xp,
      level: level ?? this.level,
      shields: shields ?? this.shields,
      currentStreak: currentStreak ?? this.currentStreak,
      highestStreak: highestStreak ?? this.highestStreak,
      unlockedBadges: unlockedBadges ?? this.unlockedBadges,
      acknowledgedBadges: acknowledgedBadges ?? this.acknowledgedBadges,
      lastProcessedDate: lastProcessedDate ?? this.lastProcessedDate,
    );
  }
}
