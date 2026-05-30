import 'package:flutter/material.dart';
import '../../models/meal_model.dart';
import '../../theme/theme.dart';
import '../../l10n/app_localizations.dart';

class MealMacroGrid extends StatelessWidget {
  final Meal currentMeal;

  const MealMacroGrid({super.key, required this.currentMeal});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double gridWidth = constraints.maxWidth;

        if (currentMeal.isActivity) {
          return _MacroMetricCard(
            width: gridWidth,
            value: '-${currentMeal.calories} kcal',
            label: AppLocalizations.of(context)!.caloriesBurned,
            color: AppTheme.accentAmber,
          );
        }

        final double cardWidth = (gridWidth - 10) / 2;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _MacroMetricCard(
              width: cardWidth,
              value: '${currentMeal.calories} kcal',
              label: AppLocalizations.of(
                context,
              )!.caloriesKcal.replaceAll(' (kcal)', ''),
              color: AppTheme.accentEmerald,
            ),
            _MacroMetricCard(
              width: cardWidth,
              value: '${currentMeal.protein}g',
              label: AppLocalizations.of(context)!.protein,
              color: AppTheme.accentBlue,
            ),
            _MacroMetricCard(
              width: cardWidth,
              value: '${currentMeal.carbs}g',
              label: AppLocalizations.of(context)!.carbs,
              color: AppTheme.accentAmber,
            ),
            _MacroMetricCard(
              width: cardWidth,
              value: '${currentMeal.fat}g',
              label: AppLocalizations.of(context)!.fat,
              color: AppTheme.accentRed,
            ),
          ],
        );
      },
    );
  }
}

class _MacroMetricCard extends StatelessWidget {
  final double width;
  final String value;
  final String label;
  final Color color;

  const _MacroMetricCard({
    required this.width,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.08 : 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.2 : 0.15),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
