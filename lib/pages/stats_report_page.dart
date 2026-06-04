import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/theme.dart';
import '../providers/app_state.dart';
import '../l10n/app_localizations.dart';
import '../models/stats_data.dart';
import '../helpers/db_helper.dart';
import '../widgets/stats/stats_overview_section.dart';
import '../widgets/stats/stats_calorie_section.dart';
import '../widgets/stats/stats_macro_section.dart';
import '../widgets/stats/stats_gamification_section.dart';
import '../widgets/stats/stats_storage_section.dart';
import '../widgets/stats/stats_bodyweight_section.dart';

class StatsReportPage extends StatefulWidget {
  const StatsReportPage({super.key});

  @override
  State<StatsReportPage> createState() => _StatsReportPageState();
}

class _StatsReportPageState extends State<StatsReportPage> {
  StatsData? _data;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final appState = context.read<AppState>();
      final db = DbHelper.instance;
      final meals = appState.meals;

      final imageStats = await db.getImageStorageStats();
      final notesCount = await db.getNotesCount();
      final dateRangeStats = await db.getDateRangeStats();
      final dbPath = await db.databasePath;
      final dbFile = File(dbPath);
      final dbSizeBytes = await dbFile.length();

      final firstEntry = dateRangeStats['first_entry'] as int?;
      final lastEntry = dateRangeStats['last_entry'] as int?;
      final totalEntries = dateRangeStats['total_entries'] as int? ?? 0;
      final mealsCount = dateRangeStats['meal_count'] as int? ?? 0;
      final activitiesCount = dateRangeStats['activity_count'] as int? ?? 0;

      final dateFormat = DateFormat('MMM d, yyyy');
      final dateRangeFirst = firstEntry != null
          ? dateFormat.format(DateTime.fromMillisecondsSinceEpoch(firstEntry))
          : '-';
      final dateRangeLast = lastEntry != null
          ? dateFormat.format(DateTime.fromMillisecondsSinceEpoch(lastEntry))
          : '-';

      final dailyKeys = <String>{};
      for (final m in meals) {
        final date = DateTime.fromMillisecondsSinceEpoch(m.timestamp);
        dailyKeys.add('${date.year}-${date.month}-${date.day}');
      }
      final daysTracked = dailyKeys.length;

      final dayCalories = <String, List<int>>{};
      final dayMealsCount = <String, int>{};
      final foodCount = <String, int>{};
      double totalProtein = 0, totalCarbs = 0, totalFat = 0;
      int mealDaysForMacro = 0;
      int weightEntryCount = 0;
      double minWeight = double.infinity, maxWeight = 0.0;

      for (final m in meals) {
        final date = DateTime.fromMillisecondsSinceEpoch(m.timestamp);
        final key = '${date.year}-${date.month}-${date.day}';
        dayCalories.putIfAbsent(key, () => [0, 0]);
        dayMealsCount[key] = (dayMealsCount[key] ?? 0) + 1;

        if (m.isActivity) {
          dayCalories[key]![1] += m.calories;
        } else {
          dayCalories[key]![0] += m.calories;
          totalProtein += m.protein;
          totalCarbs += m.carbs;
          totalFat += m.fat;
        }

        final name = m.foodName.trim().toLowerCase();
        if (name.isNotEmpty && m.isMeal) {
          foodCount[name] = (foodCount[name] ?? 0) + 1;
        }

        if (m.weightKg != null) {
          weightEntryCount++;
          if (m.weightKg! < minWeight) minWeight = m.weightKg!;
          if (m.weightKg! > maxWeight) maxWeight = m.weightKg!;
        }
      }

      mealDaysForMacro = dayCalories.length;

      int totalCaloriesNet = 0;
      int bestDayKcal = -1, worstDayKcal = -1;
      int daysUnderGoal = 0;
      final calorieGoal = appState.calorieGoal;

      for (final entry in dayCalories.entries) {
        final net = entry.value[0] - entry.value[1];
        totalCaloriesNet += net;
        if (bestDayKcal == -1 || net < bestDayKcal) bestDayKcal = net;
        if (worstDayKcal == -1 || net > worstDayKcal) worstDayKcal = net;
        if (net <= calorieGoal) daysUnderGoal++;
      }

      final avgCalories = daysTracked > 0
          ? (totalCaloriesNet / daysTracked).round()
          : 0;
      final avgProtein = mealDaysForMacro > 0
          ? totalProtein / mealDaysForMacro
          : 0.0;
      final avgCarbs = mealDaysForMacro > 0
          ? totalCarbs / mealDaysForMacro
          : 0.0;
      final avgFat = mealDaysForMacro > 0 ? totalFat / mealDaysForMacro : 0.0;

      String mostLoggedFood = '';
      int mostLoggedFoodCount = 0;
      for (final entry in foodCount.entries) {
        if (entry.value > mostLoggedFoodCount) {
          mostLoggedFood = entry.key;
          mostLoggedFoodCount = entry.value;
        }
      }
      if (mostLoggedFood.isNotEmpty) {
        mostLoggedFood =
            mostLoggedFood[0].toUpperCase() + mostLoggedFood.substring(1);
      }

      final photoCount = (imageStats['count'] as int?) ?? 0;
      final photoTotalBytes = (imageStats['total_bytes'] as int?) ?? 0;
      final photoTotalMB = photoTotalBytes / (1024 * 1024);
      final photoAvgKB = photoCount > 0
          ? (photoTotalBytes / 1024 / photoCount).round()
          : 0;

      final dbSizeMB = dbSizeBytes / (1024 * 1024);

      if (!mounted) return;
      final gamification = appState.gamificationStats;
      final levelTitle = appState.getLevelTitle(gamification.level, context);

      setState(() {
        _data = StatsData(
          totalEntries: totalEntries,
          mealsCount: mealsCount,
          activitiesCount: activitiesCount,
          daysTracked: daysTracked,
          dateRangeFirst: dateRangeFirst,
          dateRangeLast: dateRangeLast,
          avgDailyCalories: avgCalories,
          bestDayKcal: bestDayKcal < 0 ? 0 : bestDayKcal,
          worstDayKcal: worstDayKcal < 0 ? 0 : worstDayKcal,
          daysUnderGoal: daysUnderGoal,
          totalDays: daysTracked,
          mostLoggedFood: mostLoggedFood,
          mostLoggedFoodCount: mostLoggedFoodCount,
          avgProtein: avgProtein,
          avgCarbs: avgCarbs,
          avgFat: avgFat,
          gamification: gamification,
          levelTitle: levelTitle,
          dbSizeMB: dbSizeMB,
          photoCount: photoCount,
          photoTotalMB: photoTotalMB,
          photoAvgKB: photoAvgKB,
          notesCount: notesCount,
          weightEntryCount: weightEntryCount,
          minWeight: weightEntryCount > 0 ? minWeight : null,
          maxWeight: weightEntryCount > 0 ? maxWeight : null,
        );
      });
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.statsSectionTitle)),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'Error loading stats: $_error',
            style: const TextStyle(color: AppTheme.accentRed),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_data == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StatsOverviewSection(data: _data!),
            const SizedBox(height: 16),
            StatsCalorieSection(data: _data!),
            const SizedBox(height: 16),
            StatsMacroSection(data: _data!),
            const SizedBox(height: 16),
            StatsGamificationSection(data: _data!),
            const SizedBox(height: 16),
            StatsStorageSection(data: _data!),
            const SizedBox(height: 16),
            StatsBodyWeightSection(data: _data!),
          ],
        ),
      ),
    );
  }
}
