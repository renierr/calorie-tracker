import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/stats_data.dart';
import '../adaptive/adaptive_card_header.dart';

class StatsBodyWeightSection extends StatelessWidget {
  final StatsData data;

  const StatsBodyWeightSection({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context);
    final l10n = AppLocalizations.of(context)!;

    if (data.weightEntryCount == 0) return const SizedBox.shrink();

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
            icon: Icons.monitor_weight,
            iconColor: AppTheme.accentEmerald,
            title: l10n.statsBodyWeightTitle,
          ),
          const SizedBox(height: 16),
          _row(
            l10n.statsWeightEntries(data.weightEntryCount.toString()),
            colors,
          ),
          if (data.minWeight != null && data.maxWeight != null) ...[
            const SizedBox(height: 8),
            _row(
              l10n.statsWeightRange(
                data.minWeight!.toStringAsFixed(1),
                data.maxWeight!.toStringAsFixed(1),
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
