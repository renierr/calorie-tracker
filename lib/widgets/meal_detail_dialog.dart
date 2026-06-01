import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:file_selector/file_selector.dart';
import 'package:path_provider/path_provider.dart';
import '../theme/theme.dart';
import '../models/meal_model.dart';
import '../providers/app_state.dart';
import '../services/pdf_service.dart';
import '../l10n/app_localizations.dart';
import '../helpers/file_save_helper.dart';
import 'edit_meal_dialog.dart';
import 'package:pasteboard/pasteboard.dart';
import 'custom_notification.dart';

// Structured Sub-Components
import 'meal_detail/meal_detail_card_view.dart';
import 'meal_detail/meal_detail_floating_buttons.dart';
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
  bool _isSharing = false;
  final List<File> _tempFilesToDelete = [];

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
                  Stack(
                    children: [
                      // 1. On-Screen Card View (Responsive, shows weight, cropped photo)
                      MealDetailCardView(
                        currentMeal: currentMeal,
                        hideWeight: false,
                        isExport: false,
                        dateFormat: dateFormat,
                        timeFormat: timeFormat,
                        mealDate: mealDate,
                        onPreview: () =>
                            _showImagePreview(context, currentMeal),
                      ),

                      // 2. Off-Screen Card View (Unified 480px width, hides weight, uncropped photo)
                      Positioned(
                        left: -9999, // Way off-screen
                        child: RepaintBoundary(
                          key: _boundaryKey,
                          child: SizedBox(
                            width: 480.0,
                            child: MealDetailCardView(
                              currentMeal: currentMeal,
                              hideWeight: true,
                              isExport: true,
                              dateFormat: dateFormat,
                              timeFormat: timeFormat,
                              mealDate: mealDate,
                            ),
                          ),
                        ),
                      ),

                      // Overlay Floating Action Buttons (Close, Favorite, Download, Share)
                      MealDetailFloatingButtons(
                        currentMeal: currentMeal,
                        isFavorite: currentMeal.isFavorite == 1,
                        isExporting: _isExporting,
                        isSharing: _isSharing,
                        onClose: () => Navigator.pop(context),
                        onFavorite: () =>
                            currentAppState.toggleFavoriteMeal(currentMeal),
                        onDownload: () => _downloadMealCardImage(currentMeal),
                        onShare: () => _shareMealCardImage(currentMeal),
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
            GestureDetector(
              onLongPress: () async {
                try {
                  await Pasteboard.writeImage(currentMeal.imageBytes!);
                  if (context.mounted) {
                    final l10n = AppLocalizations.of(context)!;
                    showNotificationDialog(
                      context,
                      l10n.imageCopiedToClipboard,
                      isError: false,
                    );
                  }
                } catch (e) {
                  debugPrint("Failed to copy image to clipboard: $e");
                  if (context.mounted) {
                    final l10n = AppLocalizations.of(context)!;
                    showNotificationDialog(
                      context,
                      l10n.failedToCopyImage(e.toString()),
                      isError: true,
                    );
                  }
                }
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: InteractiveViewer(
                  child: Image.memory(
                    currentMeal.imageBytes!,
                    fit: BoxFit.contain,
                  ),
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

  Future<Uint8List> _captureCardBytes() async {
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

    return byteData.buffer.asUint8List();
  }

  Future<void> _downloadMealCardImage(Meal currentMeal) async {
    if (_isExporting) return;

    setState(() {
      _isExporting = true;
    });

    try {
      final Uint8List pngBytes = await _captureCardBytes();
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

  Future<void> _shareMealCardImage(Meal currentMeal) async {
    if (_isSharing || _isExporting) return;

    setState(() {
      _isSharing = true;
    });

    try {
      final Uint8List pngBytes = await _captureCardBytes();
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final Directory tempDir = await getTemporaryDirectory();
      final String tempPath =
          '${tempDir.path}/meal_card_${currentMeal.shortId}_$timestamp.png';
      final File tempFile = File(tempPath);
      await tempFile.writeAsBytes(pngBytes);
      _tempFilesToDelete.add(tempFile);

      await FileSaveHelper.shareFile(tempPath, 'image/png');
    } catch (e) {
      debugPrint("Error sharing meal card image: $e");
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
          _isSharing = false;
        });
      }
    }
  }

  @override
  void dispose() {
    for (final file in _tempFilesToDelete) {
      try {
        if (file.existsSync()) {
          file.deleteSync();
        }
      } catch (e) {
        debugPrint("Error deleting temp file: $e");
      }
    }
    super.dispose();
  }
}
