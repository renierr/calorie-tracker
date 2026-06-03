import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/theme.dart';
import '../../providers/app_state.dart';
import '../../l10n/app_localizations.dart';

class CalorieRingCard extends StatelessWidget {
  const CalorieRingCard({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final int consumed = appState.totalCaloriesConsumed;
    final int goal = appState.calorieGoal;
    final double percent = goal > 0 ? (consumed / goal).clamp(0.0, 1.0) : 0.0;
    final int remaining = goal - consumed;
    final colors = AppTheme.of(context);
    final bool hasActiveStreak =
        appState.gamificationEnabled &&
        appState.gamificationStats.currentStreak >= 3;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: AppTheme.premiumCardDecoration(
        context: context,
        showGlow: percent >= 1.0 || hasActiveStreak,
        glowColor: hasActiveStreak
            ? AppTheme.accentAmber
            : (percent >= 1.0 ? AppTheme.accentRed : AppTheme.accentEmerald),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (hasActiveStreak)
                const Icon(
                  Icons.local_fire_department,
                  color: AppTheme.accentAmber,
                  size: 20,
                ),
              if (hasActiveStreak) const SizedBox(width: 6),
              Text(
                AppLocalizations.of(context)!.calorieConsumption,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Visual circular progress indicator
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 130,
                height: 130,
                child: CircularProgressIndicator(
                  value: percent,
                  strokeWidth: 12,
                  backgroundColor:
                      Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.05),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    consumed > goal
                        ? AppTheme.accentRed
                        : AppTheme.accentEmerald,
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
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    AppLocalizations.of(context)!.ofKcal(goal),
                    style: TextStyle(color: colors.textMuted, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          // Dynamic Breakdown Row
          if (appState.totalCaloriesBurned > 0) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.accentEmerald.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.restaurant,
                        size: 12,
                        color: AppTheme.accentEmerald,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        AppLocalizations.of(
                          context,
                        )!.intakeLabel(appState.totalCaloriesIntake),
                        style: const TextStyle(
                          color: AppTheme.accentEmerald,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.accentAmber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.fitness_center,
                        size: 12,
                        color: AppTheme.accentAmber,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        AppLocalizations.of(
                          context,
                        )!.burnedLabel(appState.totalCaloriesBurned),
                        style: const TextStyle(
                          color: AppTheme.accentAmber,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ] else ...[
            const SizedBox(height: 16),
          ],

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
