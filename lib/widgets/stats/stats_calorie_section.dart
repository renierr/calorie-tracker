import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/stats_data.dart';
import '../adaptive/adaptive_card_header.dart';

class StatsCalorieSection extends StatelessWidget {
  final StatsData data;

  const StatsCalorieSection({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.premiumCardDecoration(
        context: context,
        color: colors.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdaptiveCardHeader(
            icon: Icons.local_fire_department,
            iconColor: AppTheme.accentAmber,
            title: l10n.calorieConsumption,
          ),
          const SizedBox(height: 16),
          _row(
            l10n.statsAvgDailyCalories(data.avgDailyCalories.toString()),
            colors,
          ),
          const SizedBox(height: 8),
          _row(
            l10n.statsDaysUnderGoal(
              data.daysUnderGoal.toString(),
              data.totalDays.toString(),
              data.daysUnderGoalPct.toString(),
            ),
            colors,
          ),
          const SizedBox(height: 8),
          _row(l10n.statsBestDay(data.bestDayKcal.toString()), colors),
          const SizedBox(height: 8),
          _row(l10n.statsWorstDay(data.worstDayKcal.toString()), colors),
          if (data.mostLoggedFoodCount > 0) ...[
            const SizedBox(height: 8),
            _row(
              l10n.statsMostLoggedFood(
                data.mostLoggedFood,
                data.mostLoggedFoodCount.toString(),
              ),
              colors,
            ),
          ],
        ],
      ),
    );
  }

  Widget _row(String text, AppThemeColors colors) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: AppTheme.accentAmber,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: colors.textPrimary, fontSize: 13),
          ),
        ),
      ],
    );
  }
}
