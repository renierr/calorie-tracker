import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/stats_data.dart';
import '../adaptive/adaptive_card_header.dart';

class StatsOverviewSection extends StatelessWidget {
  final StatsData data;

  const StatsOverviewSection({super.key, required this.data});

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
            icon: Icons.dashboard,
            iconColor: AppTheme.accentBlue,
            title: l10n.statsOverviewTitle,
          ),
          const SizedBox(height: 16),
          _row(l10n.statsTotalEntries(data.totalEntries.toString()), colors),
          const SizedBox(height: 8),
          _row(l10n.statsMealsCount(data.mealsCount.toString()), colors),
          const SizedBox(height: 8),
          _row(
            l10n.statsActivitiesCount(data.activitiesCount.toString()),
            colors,
          ),
          const SizedBox(height: 8),
          _row(l10n.statsDaysTracked(data.daysTracked.toString()), colors),
          const SizedBox(height: 8),
          _row(
            l10n.statsDateRange(data.dateRangeFirst, data.dateRangeLast),
            colors,
          ),
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
            color: AppTheme.accentBlue,
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
