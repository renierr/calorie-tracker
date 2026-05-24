import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/theme.dart';
import '../models/meal_model.dart';
import '../providers/app_state.dart';
import '../services/pdf_service.dart';
import '../l10n/app_localizations.dart';
import 'edit_meal_dialog.dart';

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

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: AppTheme.premiumCardDecoration(
          showGlow: isSelectionMode && isSelected,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isSelectionMode)
              Padding(
                padding: const EdgeInsets.only(top: 2, right: 12),
                child: _buildSelectionIndicator(isSelected),
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
                          color: Colors.white.withValues(alpha: 0.05),
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
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Core visual row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Photo Thumbnail
                      GestureDetector(
                        onTap: meal.imageBytes != null
                            ? () => _showImagePreview(context)
                            : null,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: colors.surfaceLight,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.white12,
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
                              : const Icon(
                                  Icons.restaurant,
                                  color: AppTheme.accentEmerald,
                                  size: 24,
                                ),
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
                            const SizedBox(height: 4),
                            Text(
                              AppLocalizations.of(
                                context,
                              )!.caloriesLabel(meal.calories),
                              style: const TextStyle(
                                color: AppTheme.accentEmerald,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppLocalizations.of(context)!.macroPerGram(
                                meal.carbs,
                                meal.fat,
                                meal.protein,
                              ),
                              style: TextStyle(
                                color: colors.textSecondary,
                                fontSize: 12,
                              ),
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
                  const SizedBox(height: 12),
                  const Divider(color: Colors.white10, height: 1),
                  const SizedBox(height: 10),

                  // Action Toolbar Footer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Single Export PDF
                      TextButton.icon(
                        icon: const Icon(Icons.picture_as_pdf, size: 16),
                        label: Text(
                          AppLocalizations.of(context)!.pdf,
                          style: const TextStyle(fontSize: 12),
                        ),
                        onPressed: () async {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                AppLocalizations.of(context)!.generatingMealPdf,
                              ),
                            ),
                          );
                          await PdfService.generateSingleMealPdf(
                            meal,
                            appState.calorieGoal,
                          );
                        },
                      ),
                      const SizedBox(width: 8),

                      // Edit
                      TextButton.icon(
                        icon: const Icon(Icons.edit, size: 16),
                        label: Text(
                          AppLocalizations.of(context)!.edit,
                          style: const TextStyle(fontSize: 12),
                        ),
                        onPressed: () => _showEditMealDialog(context),
                      ),
                      const SizedBox(width: 8),

                      // Delete
                      TextButton.icon(
                        icon: const Icon(
                          Icons.delete_outline,
                          size: 16,
                          color: AppTheme.accentRed,
                        ),
                        label: Text(
                          AppLocalizations.of(context)!.delete,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.accentRed,
                          ),
                        ),
                        onPressed: () => _confirmDeleteMeal(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionIndicator(bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.accentEmerald : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? AppTheme.accentEmerald : Colors.white30,
          width: 2,
        ),
      ),
      child: isSelected
          ? const Icon(Icons.check, size: 14, color: Colors.white)
          : null,
    );
  }

  void _showImagePreview(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: InteractiveViewer(
                child: Image.memory(meal.imageBytes!, fit: BoxFit.contain),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: FloatingActionButton.small(
                heroTag: 'close_preview_${meal.id}',
                backgroundColor: Colors.black54,
                onPressed: () => Navigator.pop(context),
                child: const Icon(Icons.close, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditMealDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => EditMealDialog(meal: meal, appState: appState),
    );
  }

  void _confirmDeleteMeal(BuildContext context) {
    final colors = AppTheme.of(context);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: colors.surface,
          title: Text(
            AppLocalizations.of(context)!.confirmDelete,
            style: const TextStyle(color: AppTheme.accentRed),
          ),
          content: Text(AppLocalizations.of(context)!.confirmDeleteDesc),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                AppLocalizations.of(context)!.cancel,
                style: TextStyle(color: colors.textSecondary),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentRed,
              ),
              onPressed: () async {
                await appState.deleteMeal(meal.id!);
                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)!.mealDeleted),
                  ),
                );
              },
              child: Text(AppLocalizations.of(context)!.delete),
            ),
          ],
        );
      },
    );
  }
}
