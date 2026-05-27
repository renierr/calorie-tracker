import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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

// Structured Sub-Components
import 'meal_detail/meal_detail_header_image.dart';
import 'meal_detail/meal_detail_floating_buttons.dart';
import 'meal_detail/meal_detail_metadata.dart';
import 'meal_detail/meal_macro_grid.dart';
import 'meal_detail/meal_weight_card.dart';
import 'meal_detail/meal_notes_section.dart';
import 'meal_detail/meal_card_watermark.dart';
import 'meal_detail/meal_bottom_actions.dart';

class MealDetailDialog extends StatefulWidget {
  final Meal meal;
  final AppState appState;

  const MealDetailDialog({
    super.key,
    required this.meal,
    required this.appState,
  });

  @override
  State<MealDetailDialog> createState() => _MealDetailDialogState();
}

class _MealDetailDialogState extends State<MealDetailDialog> {
  final GlobalKey _boundaryKey = GlobalKey();
  bool _isExporting = false;

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
            (m) => m.id == widget.meal.id,
            orElse: () => widget.meal,
          );
          if (currentMeal.imageBytes == null &&
              widget.meal.imageBytes != null) {
            currentMeal = currentMeal.copyWith(
              imageBytes: widget.meal.imageBytes,
            );
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
                  // Captured Card Region (Wrapped in RepaintBoundary)
                  Stack(
                    children: [
                      RepaintBoundary(
                        key: _boundaryKey,
                        child: Container(
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              MealDetailHeaderImage(
                                currentMeal: currentMeal,
                                onPreview: () =>
                                    _showImagePreview(context, currentMeal),
                              ),

                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    MealDetailMetadata(
                                      dateFormat: dateFormat,
                                      timeFormat: timeFormat,
                                      mealDate: mealDate,
                                      shortId: currentMeal.shortId,
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

                                    // Macro Badges Grid
                                    MealMacroGrid(currentMeal: currentMeal),

                                    // Optional Body Weight Metric (hidden during card image export)
                                    if (currentMeal.weightKg != null &&
                                        !_isExporting) ...[
                                      const SizedBox(height: 12),
                                      MealWeightCard(
                                        weightKg: currentMeal.weightKg!,
                                      ),
                                    ],
                                    const SizedBox(height: 18),

                                    // Optional User log Notes
                                    if (currentMeal.notes != null &&
                                        currentMeal.notes!
                                            .trim()
                                            .isNotEmpty) ...[
                                      MealNotesSection(
                                        notes: currentMeal.notes!,
                                      ),
                                      const SizedBox(height: 16),
                                    ],

                                    // Brand watermark badge inside capture region
                                    const MealCardWatermark(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Overlay Floating Action Buttons (Close, Favorite, Download)
                      MealDetailFloatingButtons(
                        currentMeal: currentMeal,
                        isFavorite: currentMeal.isFavorite == 1,
                        isExporting: _isExporting,
                        onClose: () => Navigator.pop(context),
                        onFavorite: () =>
                            currentAppState.toggleFavoriteMeal(currentMeal),
                        onDownload: () => _downloadMealCardImage(currentMeal),
                      ),
                    ],
                  ),

                  // Bottom Action Buttons (PDF, Edit, Template, Delete)
                  MealBottomActions(
                    currentMeal: currentMeal,
                    onPdfExport: () async {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            AppLocalizations.of(context)!.generatingMealPdf,
                          ),
                        ),
                      );
                      await PdfService.generateSingleMealPdf(
                        context,
                        currentMeal,
                        currentAppState.calorieGoal,
                      );
                    },
                    onEdit: () => _showEditMealDialog(context, currentMeal),
                    onTemplate: () {
                      currentAppState.setTemplateMeal(currentMeal);
                      Navigator.pop(context);
                    },
                    onDelete: () => _confirmDeleteMeal(context, currentMeal),
                  ),
                ],
              ),
            ),
          );
        },
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
          EditMealDialog(meal: currentMeal, appState: widget.appState),
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
                await widget.appState.deleteMeal(currentMeal.id!);
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

  Future<void> _downloadMealCardImage(Meal currentMeal) async {
    if (_isExporting) return;

    setState(() {
      _isExporting = true;
    });

    try {
      // Small delay to make sure indicator rebuild is rendered
      await Future.delayed(const Duration(milliseconds: 100));

      final RenderRepaintBoundary? boundary =
          _boundaryKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;

      if (boundary == null) {
        throw Exception("Could not find RepaintBoundary");
      }

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData == null) {
        throw Exception("Failed to convert image to bytes");
      }

      final Uint8List pngBytes = byteData.buffer.asUint8List();
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      if (!mounted) return;
      final localizations = AppLocalizations.of(context)!;

      await FileSaveHelper.saveFile(
        context: context,
        suggestedName: 'meal_card_${currentMeal.shortId}_$timestamp.png',
        acceptedTypeGroups: <XTypeGroup>[
          const XTypeGroup(label: 'PNG Image', extensions: <String>['png']),
        ],
        bytes: pngBytes,
        successMessageAndroid: localizations.imageSavedDownloads,
        successMessageGeneralBuilder: (displayPath) =>
            localizations.imageSavedTo(displayPath),
        errorMessageBuilder: (e) => localizations.imageSaveFailed(e),
      );
    } catch (e) {
      debugPrint("Error capturing meal card image: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: AppTheme.accentRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }
}
