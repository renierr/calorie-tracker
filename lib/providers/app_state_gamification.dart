part of 'app_state.dart';

mixin _GamificationState on ChangeNotifier {
  AppState get _state => this as AppState;

  bool _gamificationEnabled = true;
  GamificationStats _gamificationStats = GamificationStats.initial();
  bool _showConfetti = false;
  String? _recentUnlockedBadge;
  bool _showShieldConsumedNotification = false;
  bool _showStreakResetNotification = false;
  bool _showShieldEarnedNotification = false;
  bool _showLevelUpNotification = false;
  bool _showPrestigeNotification = false;
  bool _showPrestigeMilestoneNotification = false;
  int _prestigeMilestoneStarCount = 10;
  int _oldLevel = 1;

  // Getters
  bool get gamificationEnabled => _gamificationEnabled;
  GamificationStats get gamificationStats => _gamificationStats;
  bool get showConfetti => _showConfetti;
  String? get recentUnlockedBadge => _recentUnlockedBadge;
  bool get showShieldConsumedNotification => _showShieldConsumedNotification;
  bool get showStreakResetNotification => _showStreakResetNotification;
  bool get showShieldEarnedNotification => _showShieldEarnedNotification;
  bool get showLevelUpNotification => _showLevelUpNotification;
  bool get showPrestigeNotification => _showPrestigeNotification;
  bool get showPrestigeMilestoneNotification =>
      _showPrestigeMilestoneNotification;
  int get prestigeMilestoneStarCount => _prestigeMilestoneStarCount;
  int get oldLevel => _oldLevel;

  Future<void> loadGamification() async {
    final prefs = await SharedPreferences.getInstance();
    _gamificationEnabled = prefs.getBool('gamification_enabled') ?? true;
    _gamificationStats = await _state._dbHelper.getGamificationStats();

    if (_gamificationEnabled) {
      await runDailyTransitionCheck();
      _checkUnacknowledgedBadges();
    }

    notifyListeners();
  }

  Future<void> setGamificationEnabled(bool enabled) async {
    _gamificationEnabled = enabled;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('gamification_enabled', enabled);
  }

  // Admin buttons for testing overlays
  void triggerAdminConfetti() {
    _showConfetti = true;
    notifyListeners();
  }

  void triggerAdminBadge(String badgeId) {
    _recentUnlockedBadge = badgeId;
    _showConfetti = true;
    notifyListeners();
  }

  void triggerAdminLevelUp() {
    _showLevelUpNotification = true;
    _showConfetti = true;
    notifyListeners();
  }

  void triggerAdminShieldEarned() {
    _showShieldEarnedNotification = true;
    notifyListeners();
  }

  void triggerAdminShieldConsumed() {
    _showShieldConsumedNotification = true;
    notifyListeners();
  }

  void triggerAdminStreakReset() {
    _showStreakResetNotification = true;
    notifyListeners();
  }

  void triggerAdminPrestige() {
    _showPrestigeNotification = true;
    _showConfetti = true;
    notifyListeners();
  }

  void triggerAdminPrestigeMilestone(int count) {
    _showPrestigeMilestoneNotification = true;
    _prestigeMilestoneStarCount = count;
    _showConfetti = true;
    notifyListeners();
  }

  Future<void> resetAdminAcknowledgedBadges() async {
    _gamificationStats = _gamificationStats.copyWith(
      acknowledgedBadges: const [],
    );
    await _state._dbHelper.updateGamificationStats(_gamificationStats);
    _checkUnacknowledgedBadges();
    notifyListeners();
  }

  // Award XP and handle level up
  Future<void> awardXp(int amount) async {
    final int oldXp = _gamificationStats.xp;
    final int newXp = (oldXp + amount).clamp(0, 9999999);
    final int currentLevel = _gamificationStats.level;
    final int newLevel = calculateLevel(newXp);

    bool showPrestige = false;
    int shieldsAwarded = 0;

    // Handle standard level up
    if (newLevel > currentLevel) {
      _oldLevel = currentLevel;
      _showLevelUpNotification = true;
      _showConfetti = true;
    }

    // Handle Prestige Stars (1 star per additional 1000 XP beyond the level 10
    // threshold of 5400 XP). Stars are earned roughly weekly, so a shield is
    // only granted on every 10th star to keep shields scarce.
    if (newXp >= 5400) {
      final int oldStars = _prestigeStars(oldXp);
      final int newStars = _prestigeStars(newXp);
      if (newStars > oldStars) {
        showPrestige = true;
        shieldsAwarded = (newStars ~/ 10) - (oldStars ~/ 10);

        // Check for every 10th Star Milestone (10, 20, 30...)
        if (newStars > 0 && newStars % 10 == 0) {
          _showPrestigeMilestoneNotification = true;
          _prestigeMilestoneStarCount = newStars;
        }
      }
    }

    if (shieldsAwarded > 0) {
      _showShieldEarnedNotification = true;
    }

    _gamificationStats = _gamificationStats.copyWith(
      xp: newXp,
      level: newLevel,
      shields: _gamificationStats.shields + shieldsAwarded,
    );

    if (showPrestige) {
      _showPrestigeNotification = true;
      _showConfetti = true;
    }

    await _state._dbHelper.updateGamificationStats(_gamificationStats);
    notifyListeners();
  }

  // Award XP for logged meals (10 XP per log) and check live badge achievements
  Future<void> onMealAdded() async {
    await awardXp(10);
    await _checkLiveBadges();
  }

  // Deduct XP on deleting meal to prevent exploits
  Future<void> onMealDeleted() async {
    await awardXp(-10);
  }

  // Daily transition logic processing past days consecutively.
  // Only fully completed days are evaluated - the current day may still change.
  // [lastProcessedDate] therefore always stores the last *completed* day.
  Future<void> runDailyTransitionCheck() async {
    final stats = _gamificationStats;
    final now = DateTime.now();
    final DateTime todayMidnight = DateTime(now.year, now.month, now.day);
    final String yesterdayStr = _formatDate(
      todayMidnight.subtract(const Duration(days: 1)),
    );

    if (stats.lastProcessedDate == null) {
      _gamificationStats = stats.copyWith(lastProcessedDate: yesterdayStr);
      await _state._dbHelper.updateGamificationStats(_gamificationStats);
      notifyListeners();
      return;
    }

    // Everything up to and including yesterday has already been processed
    if (stats.lastProcessedDate!.compareTo(yesterdayStr) >= 0) {
      return;
    }

    try {
      final lastDate = DateTime.parse(stats.lastProcessedDate!);

      DateTime checkDate = lastDate.add(const Duration(days: 1));

      int currentStreak = stats.currentStreak;
      int highestStreak = stats.highestStreak;
      int shields = stats.shields;
      int xp = stats.xp;
      List<String> badges = List.from(stats.unlockedBadges);
      bool shieldConsumed = false;
      bool streakReset = false;
      String? newlyUnlockedBadge;
      bool showStreakShieldEarned = false;

      int consecutiveMissedDays = 0;

      while (checkDate.isBefore(todayMidnight)) {
        final mealsForDay = await _state._dbHelper.getMealsForDate(
          checkDate,
          includeImages: false,
        );
        bool isActivity(Meal m) => m.shortId.startsWith('ACT-');

        final int dayMealCount = mealsForDay
            .where((m) => !isActivity(m))
            .length;
        final int dayIntake = mealsForDay.fold(
          0,
          (sum, m) => sum + (isActivity(m) ? 0 : m.calories),
        );
        final int dayBurned = mealsForDay.fold(
          0,
          (sum, m) => sum + (isActivity(m) ? m.calories : 0),
        );
        final int totalCalories = dayIntake - dayBurned;

        final List<String> dayBadges = _evaluateCompletedDayBadges(
          badges: badges,
          mealCount: dayMealCount,
          intakeCalories: dayIntake,
          burnedCalories: dayBurned,
          protein: mealsForDay.fold(
            0,
            (sum, m) => sum + (isActivity(m) ? 0 : m.protein),
          ),
          carbs: mealsForDay.fold(
            0,
            (sum, m) => sum + (isActivity(m) ? 0 : m.carbs),
          ),
          fat: mealsForDay.fold(
            0,
            (sum, m) => sum + (isActivity(m) ? 0 : m.fat),
          ),
        );
        if (dayBadges.isNotEmpty) {
          newlyUnlockedBadge = dayBadges.last;
        }

        bool daySuccessful =
            dayMealCount > 0 && totalCalories <= _state.calorieGoal;

        if (daySuccessful) {
          consecutiveMissedDays = 0;
          currentStreak++;
          xp += 100; // Daily success XP

          if (currentStreak > highestStreak) {
            highestStreak = currentStreak;
          }

          if (currentStreak == 3 && !badges.contains('triple_discipline')) {
            badges.add('triple_discipline');
            xp += 50; // Bonus XP
            newlyUnlockedBadge = 'triple_discipline';
          }

          if (currentStreak == 7 && !badges.contains('week_king')) {
            badges.add('week_king');
            shields++; // Earn 1 shield
            newlyUnlockedBadge = 'week_king';
            showStreakShieldEarned = true;
          }

          if (currentStreak > 0 &&
              currentStreak % 7 == 0 &&
              currentStreak != 7) {
            shields++;
            showStreakShieldEarned = true;
          }

          if (!badges.contains('spark')) {
            badges.add('spark');
            newlyUnlockedBadge = 'spark';
          }

          if (currentStreak >= 100 && !badges.contains('hundred_day_legend')) {
            badges.add('hundred_day_legend');
            newlyUnlockedBadge = 'hundred_day_legend';
          }

          if (currentStreak >= 365 && !badges.contains('year_titan')) {
            badges.add('year_titan');
            newlyUnlockedBadge = 'year_titan';
          }
        } else {
          if (dayMealCount > 0) {
            // Tracked over budget -> consume shield or reset streak
            consecutiveMissedDays = 0;
            if (shields > 0) {
              shields--;
              shieldConsumed = true;
            } else {
              currentStreak = 0;
              streakReset = true;
            }
          } else {
            // Missed day (0 meals logged) -> 1-day grace period
            consecutiveMissedDays++;
            if (consecutiveMissedDays > 1) {
              // 2nd+ consecutive missed day
              if (shields > 0) {
                shields--;
                shieldConsumed = true;
              } else {
                currentStreak = 0;
                streakReset = true;
              }
            }
            // 1st missed day: grace period! Streak preserved, 0 shields used.
          }
        }

        checkDate = checkDate.add(const Duration(days: 1));
      }

      if (_prestigeStars(xp) >= 10 && !badges.contains('prestige_pioneer')) {
        badges.add('prestige_pioneer');
        newlyUnlockedBadge = 'prestige_pioneer';
      }

      if (shields >= 10 && !badges.contains('shield_collector')) {
        badges.add('shield_collector');
        newlyUnlockedBadge = 'shield_collector';
      }

      // History driven badges are evaluated over all completed days
      final List<Map<String, dynamic>> completedDays = _completedDaySummaries(
        await _state._dbHelper.getDailyCalorieSummaries(),
      );
      if (_hasFitnessKnightMonth(completedDays) &&
          !badges.contains('fitness_knight')) {
        badges.add('fitness_knight');
        newlyUnlockedBadge = 'fitness_knight';
      }
      if (_hasProteinGoalStreak(completedDays) &&
          !badges.contains('protein_pro')) {
        badges.add('protein_pro');
        newlyUnlockedBadge = 'protein_pro';
      }

      final List<String> repairedAck = stats.acknowledgedBadges
          .where((b) => badges.contains(b))
          .toList();

      final newLevel = calculateLevel(xp);
      _gamificationStats = stats.copyWith(
        xp: xp,
        level: newLevel,
        shields: shields,
        currentStreak: currentStreak,
        highestStreak: highestStreak,
        unlockedBadges: badges,
        acknowledgedBadges: repairedAck,
        lastProcessedDate: yesterdayStr,
      );

      await _state._dbHelper.updateGamificationStats(_gamificationStats);

      if (newlyUnlockedBadge != null) {
        _recentUnlockedBadge = newlyUnlockedBadge;
        _showConfetti = true;
      }

      if (shieldConsumed) {
        _showShieldConsumedNotification = true;
      }

      if (streakReset && currentStreak == 0 && stats.currentStreak > 0) {
        _showStreakResetNotification = true;
      }

      if (showStreakShieldEarned) {
        _showShieldEarnedNotification = true;
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error in daily transition check: $e');
    }
  }

  /// Evaluates the badges that depend on a single *fully completed* day.
  /// Adds them to [badges] and returns the ids that were newly unlocked.
  List<String> _evaluateCompletedDayBadges({
    required List<String> badges,
    required int mealCount,
    required int intakeCalories,
    required int burnedCalories,
    required int protein,
    required int carbs,
    required int fat,
  }) {
    final List<String> added = [];
    void unlock(String id) {
      if (!badges.contains(id)) {
        badges.add(id);
        added.add(id);
      }
    }

    if (mealCount > 0 && intakeCalories < (_state.calorieGoal * 0.5).round()) {
      unlock('calorie_saver');
    }
    if (mealCount > 0 &&
        ((intakeCalories - burnedCalories) - _state.calorieGoal).abs() <= 20) {
      unlock('bullseye');
    }
    if (burnedCalories >= 500) {
      unlock('burn_master');
    }
    if (mealCount > 0 &&
        protein >= _state.proteinGoal &&
        carbs <= _state.carbsGoal &&
        fat <= _state.fatGoal) {
      unlock('macro_balance');
    }
    return added;
  }

  /// Daily summaries reduced to fully completed days - today is still in
  /// progress and must never unlock day quality badges.
  List<Map<String, dynamic>> _completedDaySummaries(
    List<Map<String, dynamic>> summaries,
  ) {
    final String todayStr = _formatDate(DateTime.now());
    return summaries
        .where((s) => (s['log_date'] as String).compareTo(todayStr) < 0)
        .toList();
  }

  /// DST safe day parsing for `YYYY-MM-DD` summary keys.
  DateTime _parseDayUtc(String isoDate) {
    final parts = isoDate.split('-');
    return DateTime.utc(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  /// True when any calendar month holds at least [threshold] logged activities.
  bool _hasFitnessKnightMonth(
    List<Map<String, dynamic>> completedDays, {
    int threshold = 10,
  }) {
    final Map<String, int> monthActivities = {};
    for (final s in completedDays) {
      final int count = (s['activity_count'] as num?)?.toInt() ?? 0;
      if (count > 0) {
        final String monthKey = (s['log_date'] as String).substring(0, 7);
        monthActivities[monthKey] = (monthActivities[monthKey] ?? 0) + count;
      }
    }
    return monthActivities.values.any((c) => c >= threshold);
  }

  /// True when the protein goal was met on [days] consecutive completed days.
  bool _hasProteinGoalStreak(
    List<Map<String, dynamic>> completedDays, {
    int days = 7,
  }) {
    if (_state.proteinGoal <= 0) return false;

    int run = 0;
    DateTime? previous;
    for (final s in completedDays) {
      final DateTime day = _parseDayUtc(s['log_date'] as String);
      final bool consecutive =
          previous != null && day.difference(previous).inDays == 1;
      final int mealCount = (s['meal_count'] as num?)?.toInt() ?? 0;
      final int protein = (s['total_protein'] as num?)?.toInt() ?? 0;

      if (mealCount > 0 && protein >= _state.proteinGoal) {
        run = consecutive ? run + 1 : 1;
        if (run >= days) return true;
      } else {
        run = 0;
      }
      previous = day;
    }
    return false;
  }

  /// Cumulative collection badges (photos / favorites).
  /// Adds them to [badges] and returns the ids that were newly unlocked.
  Future<List<String>> _evaluateCollectionBadges(List<String> badges) async {
    final List<String> added = [];

    final imageStats = await _state._dbHelper.getImageStorageStats();
    final int photosCount = (imageStats['count'] as num?)?.toInt() ?? 0;
    if (photosCount >= 50 && !badges.contains('photo_gourmet')) {
      badges.add('photo_gourmet');
      added.add('photo_gourmet');
    }

    final favorites = await _state._dbHelper.getFavoriteMeals(
      includeImages: false,
    );
    if (favorites.length >= 10 && !badges.contains('favorite_chef')) {
      badges.add('favorite_chef');
      added.add('favorite_chef');
    }

    return added;
  }

  /// Prestige stars: 1 per 1000 XP beyond the level 10 threshold (5400 XP).
  int _prestigeStars(int xp) => xp < 5400 ? 0 : (xp - 5400) ~/ 1000;

  /// Shields granted by prestige: only every 10th star yields one.
  int _prestigeShields(int xp) => _prestigeStars(xp) ~/ 10;

  // Level thresholds
  int calculateLevel(int xp) {
    if (xp >= 5400) return 10;
    if (xp >= 4400) return 9;
    if (xp >= 3500) return 8;
    if (xp >= 2700) return 7;
    if (xp >= 2000) return 6;
    if (xp >= 1400) return 5;
    if (xp >= 900) return 4;
    if (xp >= 500) return 3;
    if (xp >= 200) return 2;
    return 1;
  }

  // Cumulative XP needed to attain a level
  int getXpThreshold(int lvl) {
    switch (lvl) {
      case 1:
        return 0;
      case 2:
        return 200;
      case 3:
        return 500;
      case 4:
        return 900;
      case 5:
        return 1400;
      case 6:
        return 2000;
      case 7:
        return 2700;
      case 8:
        return 3500;
      case 9:
        return 4400;
      case 10:
        return 5400;
      default:
        return 5400;
    }
  }

  // Level titles mapping
  String getLevelTitle(int lvl, BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    switch (lvl) {
      case 1:
        return localizations.lvlCouchPotato;
      case 2:
        return localizations.lvlMotivatedBeginner;
      case 3:
        return localizations.lvlHabitHero;
      case 4:
        return localizations.lvlMetabolismMaster;
      case 5:
        return localizations.lvlFitnessApprentice;
      case 6:
        return localizations.lvlDisciplineAthlete;
      case 7:
        return localizations.lvlEnduranceChampion;
      case 8:
        return localizations.lvlNutritionGuru;
      case 9:
        return localizations.lvlVitalityLegend;
      case 10:
        return localizations.lvlCalorieNinja;
      default:
        return localizations.lvlCalorieNinja;
    }
  }

  void dismissBadgeNotification() {
    _recentUnlockedBadge = null;
    notifyListeners();
  }

  void _checkUnacknowledgedBadges() {
    if (!_gamificationEnabled) return;
    for (final badge in _gamificationStats.unlockedBadges) {
      if (!_gamificationStats.acknowledgedBadges.contains(badge)) {
        _recentUnlockedBadge = badge;
        _showConfetti = true;
        notifyListeners();
        break; // Only show one at a time
      }
    }
  }

  Future<void> onBadgeDialogDismissed(String badgeId) async {
    // Only persist acknowledgement if the badge is actually unlocked in stats (prevents admin test triggers from muting real achievements)
    if (_gamificationStats.unlockedBadges.contains(badgeId)) {
      if (!_gamificationStats.acknowledgedBadges.contains(badgeId)) {
        final List<String> updatedAck = List.from(
          _gamificationStats.acknowledgedBadges,
        );
        updatedAck.add(badgeId);
        _gamificationStats = _gamificationStats.copyWith(
          acknowledgedBadges: updatedAck,
        );
        await _state._dbHelper.updateGamificationStats(_gamificationStats);
        _checkUnacknowledgedBadges();
        notifyListeners();
      }
    }
  }

  void dismissLevelUpNotification() {
    _showLevelUpNotification = false;
    notifyListeners();
  }

  void dismissShieldConsumedNotification() {
    _showShieldConsumedNotification = false;
    notifyListeners();
  }

  void dismissStreakResetNotification() {
    _showStreakResetNotification = false;
    notifyListeners();
  }

  void dismissShieldEarnedNotification() {
    _showShieldEarnedNotification = false;
    notifyListeners();
  }

  void dismissPrestigeNotification() {
    _showPrestigeNotification = false;
    notifyListeners();
  }

  void dismissPrestigeMilestoneNotification() {
    _showPrestigeMilestoneNotification = false;
    notifyListeners();
  }

  void clearConfetti() {
    _showConfetti = false;
    notifyListeners();
  }

  Future<void> recalculateAllGamification() async {
    if (!_gamificationEnabled) return;

    try {
      final currentStats = await _state._dbHelper.getGamificationStats();

      int xp = 0;
      int currentStreak = 0;
      int highestStreak = 0;
      int streakShieldsEarned = 0;
      int shieldsConsumed = 0;
      int totalMeals = 0;
      final List<String> badges = [];

      final summaries = await _state._dbHelper.getDailyCalorieSummaries();

      if (summaries.isNotEmpty) {
        // Calculate all active meals XP (+10 XP per meal)
        totalMeals = summaries.fold<int>(
          0,
          (sum, s) => sum + (s['meal_count'] as num).toInt(),
        );
        xp += totalMeals * 10;

        // Build a fast lookup map for our summaries by formatted date string YYYY-MM-DD
        final Map<String, Map<String, dynamic>> summaryMap = {
          for (final s in summaries) s['log_date'] as String: s,
        };

        // Find the oldest date in our summaries to start the loop
        final String oldestDateStr = summaries.first['log_date'] as String;
        final DateTime firstDate = DateTime.parse(oldestDateStr);
        final DateTime now = DateTime.now();
        final DateTime todayMidnight = DateTime(now.year, now.month, now.day);

        DateTime checkDate = DateTime(
          firstDate.year,
          firstDate.month,
          firstDate.day,
        );

        int consecutiveMissedDays = 0;

        while (checkDate.isBefore(todayMidnight)) {
          final String dateStr = _formatDate(checkDate);
          final summary = summaryMap[dateStr];

          final int mealCount = summary != null
              ? (summary['meal_count'] as num).toInt()
              : 0;
          final int totalCalories = summary != null
              ? (summary['total_calories'] as num).toInt()
              : 0;
          final int burnedCalories = summary != null
              ? (summary['burned_calories'] as num).toInt()
              : 0;
          final int totalProtein = summary != null
              ? (summary['total_protein'] as num).toInt()
              : 0;
          final int totalCarbs = summary != null
              ? (summary['total_carbs'] as num).toInt()
              : 0;
          final int totalFat = summary != null
              ? (summary['total_fat'] as num).toInt()
              : 0;

          _evaluateCompletedDayBadges(
            badges: badges,
            mealCount: mealCount,
            // total_calories is already net, intake excludes burned activities
            intakeCalories: totalCalories + burnedCalories,
            burnedCalories: burnedCalories,
            protein: totalProtein,
            carbs: totalCarbs,
            fat: totalFat,
          );

          final bool daySuccessful =
              mealCount > 0 && totalCalories <= _state.calorieGoal;

          if (daySuccessful) {
            consecutiveMissedDays = 0;
            currentStreak++;
            xp += 100;

            if (currentStreak > highestStreak) {
              highestStreak = currentStreak;
            }

            if (currentStreak == 3 && !badges.contains('triple_discipline')) {
              badges.add('triple_discipline');
              xp += 50;
            }

            if (currentStreak == 7 && !badges.contains('week_king')) {
              badges.add('week_king');
              streakShieldsEarned++;
            }

            if (currentStreak > 0 &&
                currentStreak % 7 == 0 &&
                currentStreak != 7) {
              streakShieldsEarned++;
            }

            if (!badges.contains('spark')) {
              badges.add('spark');
            }

            if (currentStreak >= 100 &&
                !badges.contains('hundred_day_legend')) {
              badges.add('hundred_day_legend');
            }

            if (currentStreak >= 365 && !badges.contains('year_titan')) {
              badges.add('year_titan');
            }
          } else {
            final int prestigeShields = _prestigeShields(xp);
            final int availableShields =
                (streakShieldsEarned + prestigeShields) - shieldsConsumed;

            if (mealCount > 0) {
              // Logged over budget -> consume shield or reset streak
              consecutiveMissedDays = 0;
              if (availableShields > 0) {
                shieldsConsumed++;
              } else {
                currentStreak = 0;
              }
            } else {
              // Missed day (0 meals logged) -> 1-day grace period
              consecutiveMissedDays++;
              if (consecutiveMissedDays > 1) {
                if (availableShields > 0) {
                  shieldsConsumed++;
                } else {
                  currentStreak = 0;
                }
              }
              // 1st missed day: grace period! Streak preserved, 0 shields used.
            }
          }

          checkDate = checkDate.add(const Duration(days: 1));
        }
      }

      final int totalPrestigeShields = _prestigeShields(xp);
      final int netShields =
          (streakShieldsEarned + totalPrestigeShields - shieldsConsumed).clamp(
            0,
            999,
          );

      if (totalMeals >= 100 && !badges.contains('diary_veteran')) {
        badges.add('diary_veteran');
      }
      if (totalMeals >= 500 && !badges.contains('calorie_archivist')) {
        badges.add('calorie_archivist');
      }
      if (totalMeals >= 1000 && !badges.contains('thousand_club')) {
        badges.add('thousand_club');
      }
      if (_prestigeStars(xp) >= 10 && !badges.contains('prestige_pioneer')) {
        badges.add('prestige_pioneer');
      }
      if (netShields >= 10 && !badges.contains('shield_collector')) {
        badges.add('shield_collector');
      }
      if (highestStreak > 7 &&
          currentStreak >= 7 &&
          !badges.contains('comeback_kid')) {
        badges.add('comeback_kid');
      }

      final List<Map<String, dynamic>> completedDays = _completedDaySummaries(
        summaries,
      );
      if (_hasFitnessKnightMonth(completedDays) &&
          !badges.contains('fitness_knight')) {
        badges.add('fitness_knight');
      }
      if (_hasProteinGoalStreak(completedDays) &&
          !badges.contains('protein_pro')) {
        badges.add('protein_pro');
      }
      await _evaluateCollectionBadges(badges);

      // Achievements are permanent: keep everything already earned, even when
      // it cannot be derived from the daily summaries any more.
      for (final earned in currentStats.unlockedBadges) {
        if (!badges.contains(earned)) {
          badges.add(earned);
        }
      }

      // Rebuild repairedAck AFTER all badges have been computed
      final List<String> finalAck = currentStats.acknowledgedBadges
          .where((b) => badges.contains(b))
          .toList();

      final now = DateTime.now();
      final String yesterdayStr = _formatDate(
        DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(const Duration(days: 1)),
      );
      final int newLevel = calculateLevel(xp);
      _gamificationStats = currentStats.copyWith(
        xp: xp,
        level: newLevel,
        shields: netShields,
        currentStreak: currentStreak,
        highestStreak: highestStreak,
        unlockedBadges: badges,
        acknowledgedBadges: finalAck,
        lastProcessedDate: yesterdayStr,
      );

      await _state._dbHelper.updateGamificationStats(_gamificationStats);
      _checkUnacknowledgedBadges();
      notifyListeners();
    } catch (e) {
      debugPrint('Error in retroactive gamification re-evaluation: $e');
    }
  }

  /// Live check after a meal was logged.
  /// Only cumulative achievements are evaluated here. Badges that rate the
  /// quality of a day are granted once that day is complete, because the user
  /// can still add, edit or remove entries for the current day.
  Future<void> _checkLiveBadges() async {
    final List<String> badges = List.from(_gamificationStats.unlockedBadges);
    final List<String> newBadges = [];
    void unlock(String id) {
      if (!badges.contains(id)) {
        badges.add(id);
        newBadges.add(id);
      }
    }

    final int streak = _gamificationStats.currentStreak;
    if (streak >= 100) unlock('hundred_day_legend');
    if (streak >= 365) unlock('year_titan');
    if (_gamificationStats.highestStreak > 7 && streak >= 7) {
      unlock('comeback_kid');
    }

    newBadges.addAll(await _evaluateCollectionBadges(badges));

    final summaries = await _state._dbHelper.getDailyCalorieSummaries();
    final int totalMeals = summaries.fold<int>(
      0,
      (sum, s) => sum + (s['meal_count'] as num).toInt(),
    );
    if (totalMeals >= 100) unlock('diary_veteran');
    if (totalMeals >= 500) unlock('calorie_archivist');
    if (totalMeals >= 1000) unlock('thousand_club');

    final List<Map<String, dynamic>> completedDays = _completedDaySummaries(
      summaries,
    );
    if (_hasFitnessKnightMonth(completedDays)) unlock('fitness_knight');
    if (_hasProteinGoalStreak(completedDays)) unlock('protein_pro');

    if (_gamificationStats.prestigeStars >= 10) unlock('prestige_pioneer');
    if (_gamificationStats.shields >= 10) unlock('shield_collector');

    if (newBadges.isEmpty) return;

    _gamificationStats = _gamificationStats.copyWith(unlockedBadges: badges);
    await _state._dbHelper.updateGamificationStats(_gamificationStats);

    // Prefer the badge just earned, otherwise fall back to the oldest pending one
    final unseen = newBadges
        .where((b) => !_gamificationStats.acknowledgedBadges.contains(b))
        .toList();
    if (unseen.isNotEmpty) {
      _recentUnlockedBadge = unseen.last;
      _showConfetti = true;
      notifyListeners();
    } else {
      _checkUnacknowledgedBadges();
      notifyListeners();
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
