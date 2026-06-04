import 'gamification_model.dart';

class StatsData {
  final int totalEntries;
  final int mealsCount;
  final int activitiesCount;
  final int daysTracked;
  final String dateRangeFirst;
  final String dateRangeLast;

  final int avgDailyCalories;
  final int bestDayKcal;
  final int worstDayKcal;
  final int daysUnderGoal;
  final int totalDays;
  final String mostLoggedFood;
  final int mostLoggedFoodCount;

  final double avgProtein;
  final double avgCarbs;
  final double avgFat;

  final GamificationStats gamification;
  final String levelTitle;

  final double dbSizeMB;
  final int photoCount;
  final double photoTotalMB;
  final int photoAvgKB;
  final int notesCount;

  final int weightEntryCount;
  final double? minWeight;
  final double? maxWeight;

  const StatsData({
    required this.totalEntries,
    required this.mealsCount,
    required this.activitiesCount,
    required this.daysTracked,
    required this.dateRangeFirst,
    required this.dateRangeLast,
    required this.avgDailyCalories,
    required this.bestDayKcal,
    required this.worstDayKcal,
    required this.daysUnderGoal,
    required this.totalDays,
    required this.mostLoggedFood,
    required this.mostLoggedFoodCount,
    required this.avgProtein,
    required this.avgCarbs,
    required this.avgFat,
    required this.gamification,
    required this.levelTitle,
    required this.dbSizeMB,
    required this.photoCount,
    required this.photoTotalMB,
    required this.photoAvgKB,
    required this.notesCount,
    required this.weightEntryCount,
    this.minWeight,
    this.maxWeight,
  });

  int get daysUnderGoalPct =>
      totalDays > 0 ? (daysUnderGoal * 100 / totalDays).round() : 0;

  int get xpToNext => gamification.xp >= 5400
      ? gamification.nextPrestigeThreshold - gamification.xp
      : _levelThreshold(gamification.level + 1) - gamification.xp;
}

int _levelThreshold(int level) {
  const thresholds = [0, 200, 500, 900, 1400, 2000, 2700, 3500, 4400, 5400];
  if (level <= 10) return thresholds[level - 1];
  return 5400 + (level - 10) * 1000;
}
