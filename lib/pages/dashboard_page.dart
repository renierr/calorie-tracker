import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/theme.dart';
import '../providers/app_state.dart';
import '../models/meal_model.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final double width = MediaQuery.of(context).size.width;
    final bool isWide = width >= 800;

    return Scaffold(
      appBar: AppBar(
        title: const Text('NutriScan Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => appState.loadMeals(),
            tooltip: 'Reload Database',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Navigation Strip
              _buildDateNavigationStrip(context, appState),
              const SizedBox(height: 25),

              // Layout Grid - Responsive for Mobile vs Desktop
              isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Column: Progress Circle and Macros
                        Expanded(
                          flex: 1,
                          child: Column(
                            children: [
                              _buildCalorieRingCard(context, appState),
                              const SizedBox(height: 20),
                              _buildMacrosProgressCard(context, appState),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        // Right Column: Trend Chart and Today's Meal Quick Logs
                        Expanded(
                          flex: 1,
                          child: Column(
                            children: [
                              _buildTrendChartCard(context, appState),
                              const SizedBox(height: 20),
                              _buildDayQuickLogsCard(context, appState),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        // Calorie Ring Indicator
                        _buildCalorieRingCard(context, appState),
                        const SizedBox(height: 20),
                        // Macros Progress Slider
                        _buildMacrosProgressCard(context, appState),
                        const SizedBox(height: 20),
                        // 7 Day Calorie Trend
                        _buildTrendChartCard(context, appState),
                        const SizedBox(height: 20),
                        // Today's Logs Quick List
                        _buildDayQuickLogsCard(context, appState),
                      ],
                    ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Widget 1: Horizontal Sliding Date Navigation Strip
  Widget _buildDateNavigationStrip(BuildContext context, AppState appState) {
    final now = DateTime.now();
    final DateFormat formatter = DateFormat('MMMM d, yyyy');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: AppTheme.premiumCardDecoration(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous Day Button
          IconButton(
            icon: const Icon(Icons.chevron_left, color: AppTheme.textPrimary),
            onPressed: () => appState.previousDay(),
          ),

          // Date Text & Calendar Dialog Selector
          InkWell(
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: appState.selectedDate,
                firstDate: DateTime(now.year - 2),
                lastDate: DateTime(now.year + 1),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.dark(
                        primary: AppTheme.accentEmerald,
                        onPrimary: Colors.white,
                        surface: AppTheme.surface,
                        onSurface: AppTheme.textPrimary,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                appState.selectDate(picked);
              }
            },
            child: Row(
              children: [
                const Icon(Icons.calendar_month, color: AppTheme.accentEmerald, size: 20),
                const SizedBox(width: 8),
                Text(
                  formatter.format(appState.selectedDate),
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Next Day Button (Enabled unless selectedDate is today or future)
          IconButton(
            icon: const Icon(Icons.chevron_right, color: AppTheme.textPrimary),
            onPressed: () => appState.nextDay(),
          ),
        ],
      ),
    );
  }

  // Widget 2: Calorie Ring Progress Card
  Widget _buildCalorieRingCard(BuildContext context, AppState appState) {
    final int consumed = appState.totalCaloriesConsumed;
    final int goal = appState.calorieGoal;
    final double percent = goal > 0 ? (consumed / goal).clamp(0.0, 1.0) : 0.0;
    final int remaining = goal - consumed;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: AppTheme.premiumCardDecoration(showGlow: percent >= 1.0),
      child: Column(
        children: [
          const Text(
            'Calorie Consumption',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          
          // Visual custom circular progress indicator
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 170,
                height: 170,
                child: CircularProgressIndicator(
                  value: percent,
                  strokeWidth: 14,
                  backgroundColor: Colors.white.withOpacity(0.05),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accentEmerald),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$consumed',
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'of $goal kcal',
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Sub-Label listing remaining allowance
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                remaining >= 0 ? Icons.check_circle_outline : Icons.warning_amber_rounded,
                color: remaining >= 0 ? AppTheme.accentEmerald : AppTheme.accentRed,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                remaining >= 0 ? '$remaining kcal remaining' : '${remaining.abs()} kcal over budget',
                style: TextStyle(
                  color: remaining >= 0 ? AppTheme.textPrimary : AppTheme.accentRed,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget 3: Macronutrient Goals Sliders
  Widget _buildMacrosProgressCard(BuildContext context, AppState appState) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.premiumCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Macronutrient Distribution',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Protein bar
          _buildMacroSlider(
            label: 'Protein',
            consumed: appState.totalProteinConsumed,
            goal: appState.proteinGoal,
            color: AppTheme.accentBlue,
          ),
          const SizedBox(height: 15),

          // Carbs bar
          _buildMacroSlider(
            label: 'Carbohydrates',
            consumed: appState.totalCarbsConsumed,
            goal: appState.carbsGoal,
            color: AppTheme.accentAmber,
          ),
          const SizedBox(height: 15),

          // Fat bar
          _buildMacroSlider(
            label: 'Lipid Fats',
            consumed: appState.totalFatConsumed,
            goal: appState.fatGoal,
            color: AppTheme.accentRed,
          ),
        ],
      ),
    );
  }

  Widget _buildMacroSlider({
    required String label,
    required int consumed,
    required int goal,
    required Color color,
  }) {
    final double fraction = goal > 0 ? (consumed / goal).clamp(0.0, 1.0) : 0.0;
    final int percent = (fraction * 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w500, fontSize: 13),
            ),
            Text(
              '$consumed / $goal g ($percent%)',
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Stack(
            children: [
              Container(
                height: 10,
                color: Colors.white.withOpacity(0.05),
              ),
              FractionallySizedBox(
                widthFactor: fraction,
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Widget 4: Calorie 7-Day Trend Bar Chart
  Widget _buildTrendChartCard(BuildContext context, AppState appState) {
    // Generate dates for the last 7 days including today
    final DateTime today = appState.selectedDate;
    final List<DateTime> last7Days = List.generate(7, (i) {
      return today.subtract(Duration(days: 6 - i));
    });

    // Find totals for each of these days
    final List<int> dailyTotals = last7Days.map((day) {
      return appState.meals
          .where((m) {
            final date = DateTime.fromMillisecondsSinceEpoch(m.timestamp);
            return date.year == day.year && date.month == day.month && date.day == day.day;
          })
          .fold(0, (sum, m) => sum + m.calories);
    }).toList();

    final int goal = appState.calorieGoal;
    final int maxVal = [goal, ...dailyTotals].reduce((a, b) => a > b ? a : b);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.premiumCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Calorie Trend (7 Days)',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 25),

          // Elegant Container-Based Chart Grid
          SizedBox(
            height: 160,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (i) {
                final date = last7Days[i];
                final calories = dailyTotals[i];
                final double factor = maxVal > 0 ? (calories / maxVal).clamp(0.0, 1.0) : 0.0;
                final bool isSelectedDate = date.year == today.year &&
                    date.month == today.month &&
                    date.day == today.day;

                final String weekday = DateFormat('E').format(date).substring(0, 2);

                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Hover value or visual top label
                      Text(
                        calories > 0 ? '$calories' : '',
                        style: const TextStyle(fontSize: 9, color: AppTheme.textMuted, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),

                      // Elegant Rounded Gradient Bar
                      Expanded(
                        child: FractionallySizedBox(
                          heightFactor: factor > 0 ? factor : 0.05,
                          widthFactor: 0.45,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isSelectedDate
                                    ? [AppTheme.accentEmerald, AppTheme.accentEmerald.withOpacity(0.4)]
                                    : [AppTheme.accentBlue, AppTheme.accentBlue.withOpacity(0.4)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                              border: Border.all(
                                color: isSelectedDate ? AppTheme.accentEmerald : Colors.transparent,
                                width: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Day Label (Highlighted if selected)
                      Text(
                        weekday,
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelectedDate ? AppTheme.accentEmerald : AppTheme.textSecondary,
                          fontWeight: isSelectedDate ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // Widget 5: Quick Meals Logs for the Selected Day
  Widget _buildDayQuickLogsCard(BuildContext context, AppState appState) {
    final meals = appState.mealsForSelectedDate;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.premiumCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Day Log Summary',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Text(
                '${meals.length} logs',
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 15),

          if (meals.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.restaurant_outlined, color: AppTheme.textMuted.withOpacity(0.5), size: 36),
                    const SizedBox(height: 10),
                    const Text(
                      'No meals logged for this day.',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: meals.length > 3 ? 3 : meals.length, // Show up to 3 quick logs
              separatorBuilder: (context, index) => const Divider(color: Colors.white10, height: 1),
              itemBuilder: (context, index) {
                final Meal meal = meals[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      // Thumbnail Photo or fallback icon
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceLight,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white12, width: 0.5),
                        ),
                        child: meal.imageBytes != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.memory(meal.imageBytes!, fit: BoxFit.cover),
                              )
                            : const Icon(Icons.fastfood, color: AppTheme.accentEmerald, size: 20),
                      ),
                      const SizedBox(width: 14),

                      // Text Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              meal.foodName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'P: ${meal.protein}g  C: ${meal.carbs}g  F: ${meal.fat}g',
                              style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                            ),
                          ],
                        ),
                      ),

                      // Calorie Count Indicator
                      Text(
                        '+${meal.calories} kcal',
                        style: const TextStyle(
                          color: AppTheme.accentEmerald,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
