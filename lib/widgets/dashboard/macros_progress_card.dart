import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/theme.dart';
import '../../providers/app_state.dart';
import '../../l10n/app_localizations.dart';
import 'macro_slider.dart';

class MacrosProgressCard extends StatelessWidget {
  const MacrosProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
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
          MacroSlider(
            label: AppLocalizations.of(context)!.protein,
            consumed: appState.totalProteinConsumed,
            goal: appState.proteinGoal,
            color: AppTheme.accentBlue,
            textColor: colors.textPrimary,
          ),
          const SizedBox(height: 20),

          // Carbs bar
          MacroSlider(
            label: AppLocalizations.of(context)!.carbs,
            consumed: appState.totalCarbsConsumed,
            goal: appState.carbsGoal,
            color: AppTheme.accentAmber,
            textColor: colors.textPrimary,
          ),
          const SizedBox(height: 20),

          // Fat bar
          MacroSlider(
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
}
