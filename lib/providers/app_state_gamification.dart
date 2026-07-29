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

    // Auto-acknowledge existing unlocked badges on startup so old badges don't re-trigger popups every launch
    if (_gamificationStats.unlockedBadges.length >
        _gamificationStats.acknowledgedBadges.length) {
      final updatedAck = List<String>.from(_gamificationStats.unlockedBadges);
      _gamificationStats = _gamificationStats.copyWith(
        acknowledgedBadges: updatedAck,
      );
      await _state._dbHelper.updateGamificationStats(_gamificationStats);
    }

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

    // Handle Prestige Stars (+1 Shield for every additional 1000 XP beyond level 10 threshold of 5400 XP)
    if (newXp >= 5400) {
      final int oldStars = oldXp < 5400 ? 0 : (oldXp - 5400) ~/ 1000;
      final int newStars = (newXp - 5400) ~/ 1000;
      if (newStars > oldStars) {
        showPrestige = true;
        shieldsAwarded = newStars - oldStars;

        // Check for every 10th Star Milestone (10, 20, 30...)
        if (newStars > 0 && newStars % 10 == 0) {
          _showPrestigeMilestoneNotification = true;
          _prestigeMilestoneStarCount = newStars;
        }
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

  // Award XP for logged meals (10 XP per log) and check live badge achievements
  Future<void> onMealAdded() async {
    await awardXp(10);
    await _checkLiveBadges();
  }

  // Deduct XP on deleting meal to prevent exploits
  Future<void> onMealDeleted() async {
    await awardXp(-10);
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

      int consecutiveMissedDays = 0;

      while (checkDate.isBefore(todayMidnight)) {
        final mealsForDay = await _state._dbHelper.getMealsForDate(
          checkDate,
          includeImages: false,
        );
        final totalCalories = mealsForDay.fold(
          0,
          (sum, m) =>
              sum + (m.shortId.startsWith('ACT-') ? -m.calories : m.calories),
        );

        bool daySuccessful =
            mealsForDay.isNotEmpty && totalCalories <= _state.calorieGoal;

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
          if (mealsForDay.isNotEmpty) {
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

      final totalPrestigeStars = xp < 5400 ? 0 : (xp - 5400) ~/ 1000;
      if (totalPrestigeStars >= 10 && !badges.contains('prestige_pioneer')) {
        badges.add('prestige_pioneer');
        newlyUnlockedBadge = 'prestige_pioneer';
      }

      if (shields >= 10 && !badges.contains('shield_collector')) {
        badges.add('shield_collector');
        newlyUnlockedBadge = 'shield_collector';
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

          if (mealCount > 0 &&
              totalCalories < (_state.calorieGoal * 0.5).round() &&
              !badges.contains('calorie_saver')) {
            badges.add('calorie_saver');
          }
          if (mealCount > 0 &&
              (totalCalories - _state.calorieGoal).abs() <= 20 &&
              !badges.contains('bullseye')) {
            badges.add('bullseye');
          }
          if (burnedCalories >= 500 && !badges.contains('burn_master')) {
            badges.add('burn_master');
          }
          if (mealCount > 0 &&
              totalProtein >= _state.proteinGoal &&
              totalCarbs <= _state.carbsGoal &&
              totalFat <= _state.fatGoal &&
              !badges.contains('macro_balance')) {
            badges.add('macro_balance');
          }

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
            final int prestigeShields = xp < 5400 ? 0 : (xp - 5400) ~/ 1000;
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

      final List<String> repairedAck = currentStats.acknowledgedBadges
          .where((b) => badges.contains(b))
          .toList();

      final int totalPrestigeShields = xp < 5400 ? 0 : (xp - 5400) ~/ 1000;
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
      if (totalPrestigeShields >= 10 && !badges.contains('prestige_pioneer')) {
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

      final int newLevel = calculateLevel(xp);
      _gamificationStats = currentStats.copyWith(
        xp: xp,
        level: newLevel,
        shields: netShields,
        currentStreak: currentStreak,
        highestStreak: highestStreak,
        unlockedBadges: badges,
        acknowledgedBadges: repairedAck,
        lastProcessedDate: _formatDate(
          DateTime.now().subtract(const Duration(days: 1)),
        ),
      );

      await _state._dbHelper.updateGamificationStats(_gamificationStats);
      if (_recentUnlockedBadge == null) {
        _checkUnacknowledgedBadges();
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error in retroactive gamification re-evaluation: $e');
    }
  }

  Future<void> _checkLiveBadges() async {
    final List<String> badges = List.from(_gamificationStats.unlockedBadges);
    String? newBadge;

    if (!badges.contains('spark')) {
      badges.add('spark');
      newBadge = 'spark';
    }

    final int streak = _gamificationStats.currentStreak;
    if (streak >= 100 && !badges.contains('hundred_day_legend')) {
      badges.add('hundred_day_legend');
      newBadge = 'hundred_day_legend';
    }
    if (streak >= 365 && !badges.contains('year_titan')) {
      badges.add('year_titan');
      newBadge = 'year_titan';
    }

    final imageStats = await _state._dbHelper.getImageStorageStats();
    final int photosCount = (imageStats['count'] as num?)?.toInt() ?? 0;
    if (photosCount >= 50 && !badges.contains('photo_gourmet')) {
      badges.add('photo_gourmet');
      newBadge = 'photo_gourmet';
    }

    final favorites = await _state._dbHelper.getFavoriteMeals(
      includeImages: false,
    );
    if (favorites.length >= 10 && !badges.contains('favorite_chef')) {
      badges.add('favorite_chef');
      newBadge = 'favorite_chef';
    }

    if (_gamificationStats.highestStreak > 7 &&
        _gamificationStats.currentStreak >= 7 &&
        !badges.contains('comeback_kid')) {
      badges.add('comeback_kid');
      newBadge = 'comeback_kid';
    }

    final summaries = await _state._dbHelper.getDailyCalorieSummaries();
    final int totalMeals = summaries.fold<int>(
      0,
      (sum, s) => sum + (s['meal_count'] as num).toInt(),
    );

    if (totalMeals >= 100 && !badges.contains('diary_veteran')) {
      badges.add('diary_veteran');
      newBadge = 'diary_veteran';
    }
    if (totalMeals >= 500 && !badges.contains('calorie_archivist')) {
      badges.add('calorie_archivist');
      newBadge = 'calorie_archivist';
    }
    if (totalMeals >= 1000 && !badges.contains('thousand_club')) {
      badges.add('thousand_club');
      newBadge = 'thousand_club';
    }

    final int stars = _gamificationStats.prestigeStars;
    if (stars >= 10 && !badges.contains('prestige_pioneer')) {
      badges.add('prestige_pioneer');
      newBadge = 'prestige_pioneer';
    }

    if (_gamificationStats.shields >= 10 &&
        !badges.contains('shield_collector')) {
      badges.add('shield_collector');
      newBadge = 'shield_collector';
    }

    final todayMeals = await _state._dbHelper.getMealsForDate(
      DateTime.now(),
      includeImages: false,
    );
    if (todayMeals.isNotEmpty) {
      final int todayIntake = todayMeals.fold(
        0,
        (sum, m) => sum + (m.shortId.startsWith('ACT-') ? 0 : m.calories),
      );
      final int todayBurned = todayMeals.fold(
        0,
        (sum, m) => sum + (m.shortId.startsWith('ACT-') ? m.calories : 0),
      );
      final int todayNet = todayIntake - todayBurned;
      final int todayProtein = todayMeals.fold(
        0,
        (sum, m) => sum + (m.shortId.startsWith('ACT-') ? 0 : m.protein),
      );
      final int todayCarbs = todayMeals.fold(
        0,
        (sum, m) => sum + (m.shortId.startsWith('ACT-') ? 0 : m.carbs),
      );
      final int todayFat = todayMeals.fold(
        0,
        (sum, m) => sum + (m.shortId.startsWith('ACT-') ? 0 : m.fat),
      );

      if ((todayNet - _state.calorieGoal).abs() <= 20 &&
          !badges.contains('bullseye')) {
        badges.add('bullseye');
        newBadge = 'bullseye';
      }
      if (todayProtein >= _state.proteinGoal &&
          !badges.contains('protein_pro')) {
        badges.add('protein_pro');
        newBadge = 'protein_pro';
      }
      if (todayProtein >= _state.proteinGoal &&
          todayCarbs <= _state.carbsGoal &&
          todayFat <= _state.fatGoal &&
          !badges.contains('macro_balance')) {
        badges.add('macro_balance');
        newBadge = 'macro_balance';
      }
      if (todayBurned >= 500 && !badges.contains('burn_master')) {
        badges.add('burn_master');
        newBadge = 'burn_master';
      }
    }

    if (badges.length > _gamificationStats.unlockedBadges.length) {
      _gamificationStats = _gamificationStats.copyWith(unlockedBadges: badges);
      await _state._dbHelper.updateGamificationStats(_gamificationStats);
      if (newBadge != null) {
        _recentUnlockedBadge = newBadge;
        _showConfetti = true;
      }
      notifyListeners();
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
