import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../models/meal_model.dart';
import '../../theme/theme.dart';
import '../../l10n/app_localizations.dart';

class ScanFavoritesList extends StatelessWidget {
  const ScanFavoritesList({super.key});

  @override
  Widget build(BuildContext context) {
    final favoriteMeals = context.select<AppState, List<Meal>>(
      (s) => s.favoriteMeals,
    );
    final colors = AppTheme.of(context);
    final double screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.favorite, color: AppTheme.accentRed, size: 20),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context)!.favoriteMeals,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (favoriteMeals.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.premiumCardDecoration(context: context),
            child: Text(
              AppLocalizations.of(context)!.noFavoritesYet,
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.textSecondary, fontSize: 13),
            ),
          )
        else
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: favoriteMeals.map((meal) {
              // Calculate responsive fluid grid card width:
              // 1 Column on Mobile, 2 on Small Tablet, 3 on Large Tablet, 4 on Desktop
              final double calculatedWidth;
              if (screenWidth < 480) {
                calculatedWidth = double.infinity;
              } else if (screenWidth < 768) {
                calculatedWidth = (screenWidth - 52) / 2;
              } else if (screenWidth < 1024) {
                calculatedWidth = (screenWidth - 64) / 3;
              } else {
                calculatedWidth = (screenWidth - 76) / 4;
              }

              return InkWell(
                onTap: () {
                  context.read<AppState>().setTemplateMeal(meal);
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: calculatedWidth,
                  padding: const EdgeInsets.all(12),
                  decoration: AppTheme.premiumCardDecoration(
                    context: context,
                    glowColor: meal.isActivity
                        ? AppTheme.accentAmber
                        : AppTheme.accentEmerald,
                  ).copyWith(color: colors.surfaceLight.withValues(alpha: 0.5)),
                  child: Row(
                    children: [
                      // Meal Thumbnail
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: colors.surfaceLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: meal.imageBytes != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.memory(
                                  meal.imageBytes!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  gradient: LinearGradient(
                                    colors: meal.isActivity
                                        ? [
                                            AppTheme.accentAmber.withValues(
                                              alpha: 0.15,
                                            ),
                                            AppTheme.accentRed.withValues(
                                              alpha: 0.15,
                                            ),
                                          ]
                                        : [
                                            AppTheme.accentEmerald.withValues(
                                              alpha: 0.15,
                                            ),
                                            AppTheme.accentBlue.withValues(
                                              alpha: 0.15,
                                            ),
                                          ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: Icon(
                                  meal.isActivity
                                      ? Icons.directions_run
                                      : Icons.fastfood,
                                  color: meal.isActivity
                                      ? AppTheme.accentAmber
                                      : AppTheme.accentEmerald,
                                  size: 24,
                                ),
                              ),
                      ),
                      const SizedBox(width: 12),
                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              meal.foodName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: colors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              meal.isActivity
                                  ? '-${meal.calories} kcal'
                                  : '${meal.calories} kcal',
                              style: TextStyle(
                                color: meal.isActivity
                                    ? AppTheme.accentAmber
                                    : AppTheme.accentEmerald,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (!meal.isActivity) ...[
                              const SizedBox(height: 2),
                              Text(
                                'P: ${meal.protein}g • C: ${meal.carbs}g • F: ${meal.fat}g',
                                style: TextStyle(
                                  color: colors.textMuted,
                                  fontSize: 10,
                                ),
                              ),
                            ] else ...[
                              const SizedBox(height: 2),
                              Text(
                                AppLocalizations.of(context)!.burnExercise,
                                style: TextStyle(
                                  color: colors.textMuted,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}
