import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../providers/app_state.dart';
import '../../l10n/app_localizations.dart';

class CalorieRingCard extends StatelessWidget {
  final AppState appState;

  const CalorieRingCard({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    final int consumed = appState.totalCaloriesConsumed;
    final int goal = appState.calorieGoal;
    final double percent = goal > 0 ? (consumed / goal).clamp(0.0, 1.0) : 0.0;
    final int remaining = goal - consumed;
    final colors = AppTheme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: AppTheme.premiumCardDecoration(showGlow: percent >= 1.0),
      child: Column(
        children: [
          Text(
            AppLocalizations.of(context)!.calorieConsumption,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // Visual circular progress indicator
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 170,
                height: 170,
                child: CircularProgressIndicator(
                  value: percent,
                  strokeWidth: 14,
                  backgroundColor: Colors.white.withValues(alpha: 0.05),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppTheme.accentEmerald,
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$consumed',
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    AppLocalizations.of(context)!.ofKcal(goal),
                    style: TextStyle(color: colors.textMuted, fontSize: 13),
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
                remaining >= 0
                    ? Icons.check_circle_outline
                    : Icons.warning_amber_rounded,
                color: remaining >= 0
                    ? AppTheme.accentEmerald
                    : AppTheme.accentRed,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                remaining >= 0
                    ? AppLocalizations.of(context)!.kcalRemaining(remaining)
                    : AppLocalizations.of(
                        context,
                      )!.kcalOverBudget(remaining.abs()),
                style: TextStyle(
                  color: remaining >= 0
                      ? colors.textPrimary
                      : AppTheme.accentRed,
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
}
