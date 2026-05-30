import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../theme/theme.dart';
import '../models/meal_model.dart';
import '../providers/app_state.dart';
import '../l10n/app_localizations.dart';
import '../services/ai_service.dart';
import 'meal_form_fields.dart';

class EditMealDialog extends StatefulWidget {
  final Meal meal;
  final AppState appState;

  const EditMealDialog({super.key, required this.meal, required this.appState});

  @override
  State<EditMealDialog> createState() => _EditMealDialogState();
}

class _EditMealDialogState extends State<EditMealDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _caloriesController;
  late final TextEditingController _proteinController;
  late final TextEditingController _carbsController;
  late final TextEditingController _fatController;
  late final TextEditingController _notesController;
  late final TextEditingController _weightController;
  late final TextEditingController _reEvalPromptController;

  Uint8List? _imageBytes;
  bool _isLoadingImage = false;
  bool _isReEvaluating = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.meal.foodName);
    _caloriesController = TextEditingController(
      text: widget.meal.calories.toString(),
    );
    _proteinController = TextEditingController(
      text: widget.meal.protein.toString(),
    );
    _carbsController = TextEditingController(
      text: widget.meal.carbs.toString(),
    );
    _fatController = TextEditingController(text: widget.meal.fat.toString());
    _notesController = TextEditingController(text: widget.meal.notes ?? '');
    _weightController = TextEditingController(
      text: widget.meal.weightKg?.toString() ?? '',
    );
    _reEvalPromptController = TextEditingController();

    // Asynchronously load the meal image from the database if not present in memory
    _imageBytes = widget.meal.imageBytes;
    if (_imageBytes == null && widget.meal.id != null) {
      _isLoadingImage = true;
      widget.appState.getMealImageBytes(widget.meal.id!).then((bytes) {
        if (mounted) {
          setState(() {
            _imageBytes = bytes;
            _isLoadingImage = false;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _notesController.dispose();
    _weightController.dispose();
    _reEvalPromptController.dispose();
    super.dispose();
  }

  Future<void> _handleReEvaluation() async {
    final prompt = _reEvalPromptController.text.trim();
    if (prompt.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.reEvaluateInstructionHint,
          ),
          backgroundColor: AppTheme.accentRed,
        ),
      );
      return;
    }

    final apiKey = widget.appState.aiApiKey;
    final hasApiKey =
        widget.appState.aiProvider == 'custom' || apiKey.trim().isNotEmpty;
    if (!hasApiKey) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.apiKeyMissing),
          backgroundColor: AppTheme.accentRed,
        ),
      );
      return;
    }

    setState(() {
      _isReEvaluating = true;
    });

    try {
      await WakelockPlus.enable();
    } catch (_) {}

    try {
      final String customPrompt = BaseAIService.buildReEvaluationPrompt(
        originalName: widget.meal.foodName,
        originalCalories: widget.meal.calories,
        originalProtein: widget.meal.protein,
        originalCarbs: widget.meal.carbs,
        originalFat: widget.meal.fat,
        originalNotes: widget.meal.notes ?? '',
        userCorrection: prompt,
      );

      final result = await widget.appState.performAIAnalysis(
        imageBytes: _imageBytes ?? Uint8List(0),
        mimeType: 'image/jpeg',
        userHint: customPrompt,
      );

      if (mounted) {
        setState(() {
          _nameController.text = result.foodName;
          _caloriesController.text = result.calories.toString();
          _proteinController.text = result.protein.toString();
          _carbsController.text = result.carbs.toString();
          _fatController.text = result.fat.toString();
          _notesController.text = result.notes;
          _reEvalPromptController.clear();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.reEvaluationSuccess),
            backgroundColor: AppTheme.accentEmerald,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.reEvaluationError(e.toString()),
            ),
            backgroundColor: AppTheme.accentRed,
          ),
        );
      }
    } finally {
      try {
        await WakelockPlus.disable();
      } catch (_) {}
      if (mounted) {
        setState(() {
          _isReEvaluating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context);
    final isEnabled = !_isReEvaluating;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double horizontalPadding = screenWidth < 600 ? 12.0 : 40.0;

    return Dialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 24.0,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title
              Text(
                widget.meal.isActivity
                    ? AppLocalizations.of(context)!.editActivityDetails
                    : AppLocalizations.of(context)!.editMeal,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 16),

              // Scrollable Field Content
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MealFormFields(
                        isActivity: widget.meal.isActivity,
                        isEnabled: isEnabled,
                        nameController: _nameController,
                        caloriesController: _caloriesController,
                        proteinController: _proteinController,
                        carbsController: _carbsController,
                        fatController: _fatController,
                        weightController: _weightController,
                        notesController: _notesController,
                      ),

                      if (!widget.meal.isActivity) ...[
                        // Premium AI Re-evaluation Section
                        const SizedBox(height: 8),
                        const Divider(height: 24),
                        Row(
                          children: [
                            const Icon(
                              Icons.auto_awesome,
                              color: AppTheme.accentBlue,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              AppLocalizations.of(context)!.reEvaluate,
                              style: TextStyle(
                                color: colors.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _reEvalPromptController,
                          enabled: isEnabled && !_isLoadingImage,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(
                              context,
                            )!.reEvaluateInstruction,
                            hintText: AppLocalizations.of(
                              context,
                            )!.reEvaluateInstructionHint,
                            labelStyle: TextStyle(
                              color: colors.textSecondary,
                              fontSize: 11,
                            ),
                            hintStyle: TextStyle(
                              color: colors.textSecondary.withValues(
                                alpha: 0.6,
                              ),
                              fontSize: 11,
                            ),
                            alignLabelWithHint: true,
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: _isReEvaluating
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppTheme.accentBlue,
                                      ),
                                    ),
                                  ),
                                )
                              : ElevatedButton.icon(
                                  icon: const Icon(
                                    Icons.auto_awesome,
                                    size: 16,
                                  ),
                                  label: Text(
                                    AppLocalizations.of(context)!.reEvaluate,
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.accentBlue,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                  onPressed: (isEnabled && !_isLoadingImage)
                                      ? _handleReEvaluation
                                      : null,
                                ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Responsive Action Buttons (using Wrap to prevent mobile overflow)
              Wrap(
                alignment: WrapAlignment.end,
                spacing: 8,
                runSpacing: 8,
                children: [
                  TextButton(
                    onPressed: _isReEvaluating
                        ? null
                        : () => Navigator.pop(context),
                    child: Text(
                      AppLocalizations.of(context)!.cancel,
                      style: TextStyle(color: colors.textSecondary),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _isReEvaluating
                        ? null
                        : () async {
                            final double? weight = double.tryParse(
                              _weightController.text.trim(),
                            );
                            final isAct = widget.meal.isActivity;
                            final updatedMeal = widget.meal.copyWith(
                              foodName: _nameController.text.trim(),
                              calories:
                                  int.tryParse(_caloriesController.text) ?? 0,
                              protein: isAct
                                  ? 0
                                  : (int.tryParse(_proteinController.text) ??
                                        0),
                              carbs: isAct
                                  ? 0
                                  : (int.tryParse(_carbsController.text) ?? 0),
                              fat: isAct
                                  ? 0
                                  : (int.tryParse(_fatController.text) ?? 0),
                              notes: _notesController.text.trim(),
                              weightKg: weight,
                              clearWeight: weight == null,
                              updatedAt: DateTime.now().millisecondsSinceEpoch,
                            );
                            await widget.appState.updateMeal(updatedMeal);
                            if (!context.mounted) return;
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isAct
                                      ? AppLocalizations.of(
                                          context,
                                        )!.activityUpdated
                                      : AppLocalizations.of(
                                          context,
                                        )!.mealUpdated,
                                ),
                                backgroundColor: AppTheme.accentEmerald,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                    child: Text(AppLocalizations.of(context)!.saveChanges),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
