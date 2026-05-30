import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/theme.dart';
import '../models/meal_model.dart';
import '../providers/app_state.dart';
import '../l10n/app_localizations.dart';
import 'meal_detail_dialog.dart';
import 'mini_macro_chip.dart';
import 'history_selection_indicator.dart';

class MealHistoryCard extends StatelessWidget {
  final Meal meal;
  final AppState appState;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const MealHistoryCard({
    super.key,
    required this.meal,
    required this.appState,
    required this.isSelectionMode,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final mealDate = DateTime.fromMillisecondsSinceEpoch(meal.timestamp);

    final timeFormat = DateFormat.jm(locale);
    final dateFormat = DateFormat.yMMMd(locale);

    // Dynamically extract short localized macro labels (e.g. 'P'/'E', 'C'/'K', 'F'/'F')
    final perGramStr = AppLocalizations.of(context)!.perGram(0, 0, 0);
    final cleanParts = perGramStr
        .split(' ')
        .where((s) => s.isNotEmpty)
        .toList();
    final pLabel = cleanParts.isNotEmpty
        ? cleanParts[0].replaceAll(':', '')
        : 'P';
    final cLabel = cleanParts.length > 2
        ? cleanParts[2].replaceAll(':', '')
        : 'C';
    final fLabel = cleanParts.length > 4
        ? cleanParts[4].replaceAll(':', '')
        : 'F';

    return GestureDetector(
      onTap: () {
        if (isSelectionMode) {
          onTap();
        } else {
          _showMealDetailDialog(context);
        }
      },
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: AppTheme.premiumCardDecoration(
          context: context,
          showGlow: isSelectionMode && isSelected,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isSelectionMode)
              Padding(
                padding: const EdgeInsets.only(top: 2, right: 12),
                child: HistorySelectionIndicator(isSelected: isSelected),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header info
                  Row(
                    children: [
                      Text(
                        dateFormat.format(mealDate),
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        timeFormat.format(mealDate),
                        style: TextStyle(color: colors.textMuted, fontSize: 11),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: colors.surfaceLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          meal.shortId,
                          style: TextStyle(
                            color: colors.textMuted,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      if (meal.isFavorite == 1) ...[
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.favorite,
                          color: AppTheme.accentRed,
                          size: 14,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Core visual row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Photo Thumbnail
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: colors.surfaceLight,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.white12
                                : Colors.black.withValues(alpha: 0.08),
                            width: 0.5,
                          ),
                        ),
                        child: meal.imageBytes != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.memory(
                                  meal.imageBytes!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Icon(
                                meal.isActivity
                                    ? Icons.directions_run
                                    : Icons.fastfood,
                                color: meal.isActivity
                                    ? AppTheme.accentAmber
                                    : AppTheme.accentEmerald,
                                size: 24,
                              ),
                      ),
                      const SizedBox(width: 14),

                      // Title and Macros Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              meal.foodName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: colors.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: [
                                MiniMacroChip(
                                  label: meal.isActivity
                                      ? AppLocalizations.of(context)!.burned
                                      : AppLocalizations.of(context)!
                                            .caloriesKcal
                                            .replaceAll(' (kcal)', ''),
                                  value: meal.isActivity
                                      ? '-${meal.calories}'
                                      : '${meal.calories}',
                                  color: meal.isActivity
                                      ? AppTheme.accentAmber
                                      : AppTheme.accentEmerald,
                                ),
                                if (!meal.isActivity) ...[
                                  MiniMacroChip(
                                    label: pLabel,
                                    value: '${meal.protein}g',
                                    color: AppTheme.accentBlue,
                                  ),
                                  MiniMacroChip(
                                    label: cLabel,
                                    value: '${meal.carbs}g',
                                    color: AppTheme.accentAmber,
                                  ),
                                  MiniMacroChip(
                                    label: fLabel,
                                    value: '${meal.fat}g',
                                    color: AppTheme.accentRed,
                                  ),
                                ],
                                if (meal.weightKg != null)
                                  MiniMacroChip(
                                    label: AppLocalizations.of(
                                      context,
                                    )!.weightShort,
                                    value:
                                        '${meal.weightKg!.toStringAsFixed(1)}kg',
                                    color: AppTheme.accentPurple,
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  if (meal.notes != null && meal.notes!.trim().isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      meal.notes!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.textMuted,
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
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
  }

  void _showMealDetailDialog(BuildContext context) {
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
            child: MealDetailDialog(meal: meal, appState: appState),
          ),
        );
      },
    );
  }
}
