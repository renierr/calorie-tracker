import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/theme.dart';
import '../../providers/app_state.dart';
import '../../l10n/app_localizations.dart';

class TrendChartCard extends StatelessWidget {
  final AppState appState;

  const TrendChartCard({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
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
            return date.year == day.year &&
                date.month == day.month &&
                date.day == day.day;
          })
          .fold(0, (sum, m) => sum + m.calories);
    }).toList();

    final int goal = appState.calorieGoal;
    final int maxVal = [goal, ...dailyTotals].reduce((a, b) => a > b ? a : b);
    final colors = AppTheme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.premiumCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.calorieTrend,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
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
                final double factor = maxVal > 0
                    ? (calories / maxVal).clamp(0.0, 1.0)
                    : 0.0;
                final bool isSelectedDate =
                    date.year == today.year &&
                    date.month == today.month &&
                    date.day == today.day;

                final String weekday = DateFormat.E(
                  Localizations.localeOf(context).toLanguageTag(),
                ).format(date).substring(0, 2);

                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Hover value or visual top label
                      Text(
                        calories > 0 ? '$calories' : '',
                        style: TextStyle(
                          fontSize: 9,
                          color: colors.textMuted,
                          fontWeight: FontWeight.bold,
                        ),
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
                                    ? [
                                        AppTheme.accentEmerald,
                                        AppTheme.accentEmerald.withValues(
                                          alpha: 0.4,
                                        ),
                                      ]
                                    : [
                                        AppTheme.accentBlue,
                                        AppTheme.accentBlue.withValues(
                                          alpha: 0.4,
                                        ),
                                      ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                              border: Border.all(
                                color: isSelectedDate
                                    ? AppTheme.accentEmerald
                                    : Colors.transparent,
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
                          color: isSelectedDate
                              ? AppTheme.accentEmerald
                              : colors.textSecondary,
                          fontWeight: isSelectedDate
                              ? FontWeight.bold
                              : FontWeight.normal,
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
}
