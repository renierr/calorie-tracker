import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../l10n/app_localizations.dart';

class MealWeightCard extends StatelessWidget {
  final double weightKg;

  const MealWeightCard({super.key, required this.weightKg});

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.accentPurple.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppTheme.accentPurple.withValues(alpha: 0.15),
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.monitor_weight_outlined,
            color: AppTheme.accentPurple,
            size: 20,
          ),
          const SizedBox(width: 10),
          Text(
            AppLocalizations.of(context)!.bodyWeightKg.replaceAll(' (kg)', ''),
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            '${weightKg.toStringAsFixed(1)} kg',
            style: const TextStyle(
              color: AppTheme.accentPurple,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
