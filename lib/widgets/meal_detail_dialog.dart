import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:file_selector/file_selector.dart';
import '../theme/theme.dart';
import '../models/meal_model.dart';
import '../providers/app_state.dart';
import '../services/pdf_service.dart';
import '../l10n/app_localizations.dart';
import '../helpers/file_save_helper.dart';
import 'edit_meal_dialog.dart';

class MealDetailDialog extends StatelessWidget {
  final Meal meal;
  final AppState appState;

  const MealDetailDialog({
    super.key,
    required this.meal,
    required this.appState,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final double screenWidth = MediaQuery.of(context).size.width;
    final double horizontalPadding = screenWidth < 600 ? 12.0 : 40.0;

    return Dialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 24.0,
      ),
      child: Consumer<AppState>(
        builder: (context, currentAppState, child) {
          // Reactively fetch the latest version of the meal from AppState
          var currentMeal = currentAppState.meals.firstWhere(
            (m) => m.id == meal.id,
            orElse: () => meal,
          );
          if (currentMeal.imageBytes == null && meal.imageBytes != null) {
            currentMeal = currentMeal.copyWith(imageBytes: meal.imageBytes);
          }

          final mealDate = DateTime.fromMillisecondsSinceEpoch(
            currentMeal.timestamp,
          );
          final timeFormat = DateFormat.jm(locale);
          final dateFormat = DateFormat.yMMMd(locale);

          return ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Image/Header with modern close button
                  Stack(
                    children: [
                      GestureDetector(
                        onTap: currentMeal.imageBytes != null
                            ? () => _showImagePreview(context, currentMeal)
                            : null,
                        child: Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: colors.surfaceLight,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                          ),
                          child: currentMeal.imageBytes != null
                              ? ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(16),
                                  ),
                                  child: Image.memory(
                                    currentMeal.imageBytes!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(16),
                                    ),
                                    gradient: LinearGradient(
                                      colors: [
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
                                  child: const Icon(
                                    Icons.restaurant_menu,
                                    color: AppTheme.accentEmerald,
                                    size: 48,
                                  ),
                                ),
                        ),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: FloatingActionButton.small(
                          heroTag: 'close_detail_${currentMeal.id}',
                          backgroundColor: Colors.black54,
                          onPressed: () => Navigator.pop(context),
                          child: const Icon(Icons.close, color: Colors.white),
                        ),
                      ),
                      if (currentMeal.imageBytes != null)
                        Positioned(
                          top: 12,
                          left: 12,
                          child: FloatingActionButton.small(
                            heroTag: 'download_detail_${currentMeal.id}',
                            backgroundColor: Colors.black54,
                            onPressed: () =>
                                _downloadImage(context, currentMeal),
                            child: const Icon(
                              Icons.download,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),

                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Metadata Header (Date, Time, ID)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${dateFormat.format(mealDate)}  •  ${timeFormat.format(mealDate)}',
                              style: TextStyle(
                                color: colors.textSecondary,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
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
                                currentMeal.shortId,
                                style: TextStyle(
                                  color: colors.textMuted,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Food Title
                        Text(
                          currentMeal.foodName,
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Macro Grid Layout with premium card badges
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final double gridWidth = constraints.maxWidth;
                            final double cardWidth = (gridWidth - 10) / 2;
                            return Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                _buildMacroMetricCard(
                                  context,
                                  width: cardWidth,
                                  value: '${currentMeal.calories} kcal',
                                  label: AppLocalizations.of(
                                    context,
                                  )!.caloriesKcal.replaceAll(' (kcal)', ''),
                                  color: AppTheme.accentEmerald,
                                ),
                                _buildMacroMetricCard(
                                  context,
                                  width: cardWidth,
                                  value: '${currentMeal.protein}g',
                                  label: AppLocalizations.of(context)!.protein,
                                  color: AppTheme.accentBlue,
                                ),
                                _buildMacroMetricCard(
                                  context,
                                  width: cardWidth,
                                  value: '${currentMeal.carbs}g',
                                  label: AppLocalizations.of(context)!.carbs,
                                  color: AppTheme.accentAmber,
                                ),
                                _buildMacroMetricCard(
                                  context,
                                  width: cardWidth,
                                  value: '${currentMeal.fat}g',
                                  label: AppLocalizations.of(context)!.fat,
                                  color: AppTheme.accentRed,
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 18),

                        // Notes section if populated
                        if (currentMeal.notes != null &&
                            currentMeal.notes!.trim().isNotEmpty) ...[
                          Text(
                            AppLocalizations.of(context)!.notes,
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colors.surfaceLight.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              currentMeal.notes!,
                              style: TextStyle(
                                color: colors.textPrimary,
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                        ],

                        Divider(color: colors.surfaceLight, height: 1),
                        const SizedBox(height: 12),

                        // Moved action buttons per meal
                        Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          alignment: WrapAlignment.spaceEvenly,
                          children: [
                            // PDF export
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
                                      AppLocalizations.of(
                                        context,
                                      )!.generatingMealPdf,
                                    ),
                                  ),
                                );
                                await PdfService.generateSingleMealPdf(
                                  context,
                                  currentMeal,
                                  currentAppState.calorieGoal,
                                );
                              },
                            ),
                            // Edit log
                            TextButton.icon(
                              icon: const Icon(Icons.edit, size: 16),
                              label: Text(
                                AppLocalizations.of(context)!.edit,
                                style: const TextStyle(fontSize: 12),
                              ),
                              onPressed: () =>
                                  _showEditMealDialog(context, currentMeal),
                            ),
                            // Delete log
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
                              onPressed: () =>
                                  _confirmDeleteMeal(context, currentMeal),
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
        },
      ),
    );
  }

  Widget _buildMacroMetricCard(
    BuildContext context, {
    required double width,
    required String value,
    required String label,
    required Color color,
  }) {
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

  void _showImagePreview(BuildContext context, Meal currentMeal) {
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
                child: Image.memory(
                  currentMeal.imageBytes!,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: FloatingActionButton.small(
                heroTag: 'close_preview_${currentMeal.id}',
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

  void _showEditMealDialog(BuildContext context, Meal currentMeal) {
    showDialog(
      context: context,
      builder: (context) =>
          EditMealDialog(meal: currentMeal, appState: appState),
    );
  }

  void _confirmDeleteMeal(BuildContext context, Meal currentMeal) {
    final colors = AppTheme.of(context);
    showDialog(
      context: context,
      builder: (confirmDialogContext) {
        return AlertDialog(
          backgroundColor: colors.surface,
          title: Text(
            AppLocalizations.of(context)!.confirmDelete,
            style: const TextStyle(color: AppTheme.accentRed),
          ),
          content: Text(AppLocalizations.of(context)!.confirmDeleteDesc),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(confirmDialogContext),
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
                await appState.deleteMeal(currentMeal.id!);
                if (!confirmDialogContext.mounted) return;
                Navigator.pop(confirmDialogContext); // pop confirmation
                if (!context.mounted) return;
                Navigator.pop(context); // pop detail dialog!
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

  Future<void> _downloadImage(BuildContext context, Meal currentMeal) async {
    if (currentMeal.imageBytes == null) return;
    final localizations = AppLocalizations.of(context)!;
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    await FileSaveHelper.saveFile(
      context: context,
      suggestedName: 'meal_${currentMeal.shortId}_$timestamp.jpg',
      acceptedTypeGroups: <XTypeGroup>[
        const XTypeGroup(
          label: 'JPEG Image',
          extensions: <String>['jpg', 'jpeg'],
        ),
        const XTypeGroup(label: 'PNG Image', extensions: <String>['png']),
      ],
      bytes: currentMeal.imageBytes,
      successMessageAndroid: localizations.imageSavedDownloads,
      successMessageGeneralBuilder: (displayPath) =>
          localizations.imageSavedTo(displayPath),
      errorMessageBuilder: (e) => localizations.imageSaveFailed(e),
    );
  }
}
