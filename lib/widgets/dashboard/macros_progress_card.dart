import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../providers/app_state.dart';
import '../../l10n/app_localizations.dart';

class MacrosProgressCard extends StatelessWidget {
  final AppState appState;

  const MacrosProgressCard({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: AppTheme.premiumCardDecoration(context: context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.macroDistribution,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // Protein bar
          _buildMacroSlider(
            context: context,
            label: AppLocalizations.of(context)!.protein,
            consumed: appState.totalProteinConsumed,
            goal: appState.proteinGoal,
            color: AppTheme.accentBlue,
            textColor: colors.textPrimary,
          ),
          const SizedBox(height: 20),

          // Carbs bar
          _buildMacroSlider(
            context: context,
            label: AppLocalizations.of(context)!.carbs,
            consumed: appState.totalCarbsConsumed,
            goal: appState.carbsGoal,
            color: AppTheme.accentAmber,
            textColor: colors.textPrimary,
          ),
          const SizedBox(height: 20),

          // Fat bar
          _buildMacroSlider(
            context: context,
            label: AppLocalizations.of(context)!.fat,
            consumed: appState.totalFatConsumed,
            goal: appState.fatGoal,
            color: AppTheme.accentRed,
            textColor: colors.textPrimary,
          ),
        ],
      ),
    );
  }

  Widget _buildMacroSlider({
    required BuildContext context,
    required String label,
    required int consumed,
    required int goal,
    required Color color,
    required Color textColor,
  }) {
    final double fraction = goal > 0 ? (consumed / goal).clamp(0.0, 1.0) : 0.0;
    final int percent = goal > 0 ? ((consumed / goal) * 100).toInt() : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
            Text(
              '$consumed / $goal g ($percent%)',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
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
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.05),
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
}
