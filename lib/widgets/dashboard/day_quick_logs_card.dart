import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/theme.dart';
import '../../providers/app_state.dart';
import '../../models/meal_model.dart';
import '../../l10n/app_localizations.dart';
import '../meal_detail_dialog.dart';
import 'quick_log_item.dart';

class DayQuickLogsCard extends StatelessWidget {
  const DayQuickLogsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final meals = appState.mealsForSelectedDate;
    final colors = AppTheme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.premiumCardDecoration(context: context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.dayLogSummary,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                AppLocalizations.of(context)!.logs(meals.length),
                style: TextStyle(color: colors.textMuted, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 15),

          if (meals.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.restaurant_outlined,
                      color: colors.textMuted.withValues(alpha: 0.5),
                      size: 36,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      AppLocalizations.of(context)!.noMealsLogged,
                      style: TextStyle(color: colors.textMuted, fontSize: 13),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: meals.length,
              separatorBuilder: (context, index) =>
                  Divider(color: colors.surfaceLight, height: 1),
              itemBuilder: (context, index) {
                final Meal meal = meals[index];
                return QuickLogItem(
                  meal: meal,
                  onTap: () => _showMealDetailDialog(context, meal),
                );
              },
            ),
        ],
      ),
    );
  }

  void _showMealDetailDialog(BuildContext context, Meal meal) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Meal Details',
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: anim1.value,
          child: Opacity(
            opacity: anim1.value,
            child: MealDetailDialog(meal: meal),
          ),
        );
      },
    );
  }
}
