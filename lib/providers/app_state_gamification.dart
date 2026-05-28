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
  int get oldLevel => _oldLevel;

  Future<void> loadGamification() async {
    final prefs = await SharedPreferences.getInstance();
    _gamificationEnabled = prefs.getBool('gamification_enabled') ?? true;
    _gamificationStats = await _state._dbHelper.getGamificationStats();
    notifyListeners();
    if (_gamificationEnabled) {
      await runDailyTransitionCheck();
    }
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

    // Handle Prestige Stars (+1 Shield for every additional 1000 XP beyond level 10 threshold of 5400 XP)
    if (newXp >= 5400) {
      final int oldStars = oldXp < 5400 ? 0 : (oldXp - 5400) ~/ 1000;
      final int newStars = (newXp - 5400) ~/ 1000;
      if (newStars > oldStars) {
        showPrestige = true;
        shieldsAwarded = newStars - oldStars;
      }
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

  // Check and consume shield or reset streak for today if budget exceeded
  Future<void> checkTodayBudgetExceeded() async {
    final now = DateTime.now();
    final todayMeals = await _state._dbHelper.getMealsForDate(
      now,
      includeImages: false,
    );
    final totalCalories = todayMeals.fold(0, (sum, m) => sum + m.calories);

    if (totalCalories > _state.calorieGoal &&
        _gamificationStats.currentStreak > 0) {
      if (_gamificationStats.shields > 0) {
        _gamificationStats = _gamificationStats.copyWith(
          shields: _gamificationStats.shields - 1,
        );
        await _state._dbHelper.updateGamificationStats(_gamificationStats);
        _showShieldConsumedNotification = true;
        notifyListeners();
      } else {
        _gamificationStats = _gamificationStats.copyWith(currentStreak: 0);
        await _state._dbHelper.updateGamificationStats(_gamificationStats);
        _showStreakResetNotification = true;
        notifyListeners();
      }
    }
  }

  // Award XP for logged meals (10 XP per log)
  Future<void> onMealAdded() async {
    await awardXp(10);
    await checkImmediateAchievements();
  }

  // Deduct XP on deleting meal to prevent exploits
  Future<void> onMealDeleted() async {
    await awardXp(-10);
  }

  // Immediate rewards on first day completion
  Future<void> checkImmediateAchievements() async {
    final now = DateTime.now();
    final todayMeals = await _state._dbHelper.getMealsForDate(
      now,
      includeImages: false,
    );
    final totalCalories = todayMeals.fold(0, (sum, m) => sum + m.calories);

    if (todayMeals.isNotEmpty && totalCalories <= _state.calorieGoal) {
      final stats = _gamificationStats;
      if (!stats.unlockedBadges.contains('zundfunke')) {
        final List<String> badges = List.from(stats.unlockedBadges)
          ..add('zundfunke');

        _gamificationStats = stats.copyWith(unlockedBadges: badges);

        await _state._dbHelper.updateGamificationStats(_gamificationStats);
        _recentUnlockedBadge = 'zundfunke';
        _showConfetti = true;
        notifyListeners();

        await awardXp(100); // 100 XP for first day success
      }
    }
  }

  // Daily transition logic processing past days consecutively
  Future<void> runDailyTransitionCheck() async {
    final stats = _gamificationStats;
    final now = DateTime.now();
    final todayStr = _formatDate(now);

    if (stats.lastProcessedDate == null) {
      _gamificationStats = stats.copyWith(lastProcessedDate: todayStr);
      await _state._dbHelper.updateGamificationStats(_gamificationStats);
      notifyListeners();
      return;
    }

    if (stats.lastProcessedDate == todayStr) {
      return;
    }

    try {
      final lastDate = DateTime.parse(stats.lastProcessedDate!);
      final todayMidnight = DateTime(now.year, now.month, now.day);

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

      while (checkDate.isBefore(todayMidnight)) {
        final mealsForDay = await _state._dbHelper.getMealsForDate(
          checkDate,
          includeImages: false,
        );
        final totalCalories = mealsForDay.fold(0, (sum, m) => sum + m.calories);

        bool daySuccessful =
            mealsForDay.isNotEmpty && totalCalories <= _state.calorieGoal;

        if (daySuccessful) {
          currentStreak++;
          xp += 100; // Daily success XP

          if (currentStreak > highestStreak) {
            highestStreak = currentStreak;
          }

          if (currentStreak == 3 && !badges.contains('dreifache_disziplin')) {
            badges.add('dreifache_disziplin');
            xp += 50; // Bonus XP
            newlyUnlockedBadge = 'dreifache_disziplin';
          }

          if (currentStreak == 7 && !badges.contains('wochen_koenig')) {
            badges.add('wochen_koenig');
            shields++; // Earn 1 shield
            newlyUnlockedBadge = 'wochen_koenig';
            showStreakShieldEarned = true;
          }

          if (currentStreak > 0 &&
              currentStreak % 7 == 0 &&
              currentStreak != 7) {
            shields++;
            showStreakShieldEarned = true;
          }

          if (!badges.contains('zundfunke')) {
            badges.add('zundfunke');
            newlyUnlockedBadge = 'zundfunke';
          }
        } else {
          if (shields > 0 && mealsForDay.isNotEmpty) {
            // Shield is only consumed if they actively tracked but failed.
            // If they skipped tracking completely (mealsForDay.isEmpty), the streak breaks.
            shields--;
            shieldConsumed = true;
          } else {
            currentStreak = 0;
            streakReset = true;
          }
        }

        checkDate = checkDate.add(const Duration(days: 1));
      }

      final newLevel = calculateLevel(xp);
      _gamificationStats = stats.copyWith(
        xp: xp,
        level: newLevel,
        shields: shields,
        currentStreak: currentStreak,
        highestStreak: highestStreak,
        unlockedBadges: badges,
        lastProcessedDate: _formatDate(
          todayMidnight.subtract(const Duration(days: 1)),
        ),
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

  void clearConfetti() {
    _showConfetti = false;
    notifyListeners();
  }

  Future<void> recalculateAllGamification() async {
    if (!_gamificationEnabled) return;

    try {
      int xp = 0;
      int currentStreak = 0;
      int highestStreak = 0;
      int shields = 0;
      final List<String> badges = [];

      final summaries = await _state._dbHelper.getDailyCalorieSummaries();

      if (summaries.isNotEmpty) {
        // Calculate all active meals XP (+10 XP per meal)
        final int totalMeals = summaries.fold<int>(
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

        while (checkDate.isBefore(todayMidnight)) {
          final String dateStr = _formatDate(checkDate);
          final summary = summaryMap[dateStr];

          final int mealCount = summary != null
              ? (summary['meal_count'] as num).toInt()
              : 0;
          final int totalCalories = summary != null
              ? (summary['total_calories'] as num).toInt()
              : 0;

          final bool daySuccessful =
              mealCount > 0 && totalCalories <= _state.calorieGoal;

          if (daySuccessful) {
            currentStreak++;
            xp += 100;

            if (currentStreak > highestStreak) {
              highestStreak = currentStreak;
            }

            if (currentStreak == 3 && !badges.contains('dreifache_disziplin')) {
              badges.add('dreifache_disziplin');
              xp += 50;
            }

            if (currentStreak == 7 && !badges.contains('wochen_koenig')) {
              badges.add('wochen_koenig');
              shields++;
            }

            if (currentStreak > 0 &&
                currentStreak % 7 == 0 &&
                currentStreak != 7) {
              shields++;
            }

            if (!badges.contains('zundfunke')) {
              badges.add('zundfunke');
            }
          } else {
            if (shields > 0 && mealCount > 0) {
              shields--;
            } else {
              currentStreak = 0;
            }
          }

          checkDate = checkDate.add(const Duration(days: 1));
        }
      }

      final int newLevel = calculateLevel(xp);
      _gamificationStats = _gamificationStats.copyWith(
        xp: xp,
        level: newLevel,
        shields: shields,
        currentStreak: currentStreak,
        highestStreak: highestStreak,
        unlockedBadges: badges,
        lastProcessedDate: _formatDate(
          DateTime.now().subtract(const Duration(days: 1)),
        ),
      );

      await _state._dbHelper.updateGamificationStats(_gamificationStats);
      notifyListeners();
    } catch (e) {
      debugPrint('Error in retroactive gamification re-evaluation: $e');
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
