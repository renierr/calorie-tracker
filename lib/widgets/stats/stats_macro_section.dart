import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/stats_data.dart';
import '../adaptive/adaptive_card_header.dart';

class StatsMacroSection extends StatelessWidget {
  final StatsData data;

  const StatsMacroSection({super.key, required this.data});

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
            icon: Icons.pie_chart,
            iconColor: AppTheme.accentEmerald,
            title: l10n.macroDistribution,
          ),
          const SizedBox(height: 16),
          _row(
            l10n.statsAvgProtein(data.avgProtein.toStringAsFixed(1)),
            colors,
          ),
          const SizedBox(height: 8),
          _row(l10n.statsAvgCarbs(data.avgCarbs.toStringAsFixed(1)), colors),
          const SizedBox(height: 8),
          _row(l10n.statsAvgFat(data.avgFat.toStringAsFixed(1)), colors),
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
            color: AppTheme.accentEmerald,
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
