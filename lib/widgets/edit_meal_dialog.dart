import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../theme/theme.dart';
import '../models/meal_model.dart';
import '../providers/app_state.dart';
import '../l10n/app_localizations.dart';
import '../services/ai_service.dart';

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

    return AlertDialog(
      backgroundColor: colors.surface,
      title: Text(
        AppLocalizations.of(context)!.editMeal,
        style: TextStyle(
          color: colors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.mealDescription,
              style: TextStyle(color: colors.textSecondary, fontSize: 11),
            ),
            const SizedBox(height: 6),
            TextField(controller: _nameController, enabled: isEnabled),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.caloriesKcal,
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _caloriesController,
                        enabled: isEnabled,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onTap: () {
                          if (_caloriesController.text == '0') {
                            _caloriesController.clear();
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.proteinG,
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _proteinController,
                        enabled: isEnabled,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onTap: () {
                          if (_proteinController.text == '0') {
                            _proteinController.clear();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.carbsG,
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _carbsController,
                        enabled: isEnabled,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onTap: () {
                          if (_carbsController.text == '0') {
                            _carbsController.clear();
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.fatG,
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _fatController,
                        enabled: isEnabled,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onTap: () {
                          if (_fatController.text == '0') {
                            _fatController.clear();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              AppLocalizations.of(context)!.bodyWeightKg,
              style: TextStyle(color: colors.textSecondary, fontSize: 11),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _weightController,
              enabled: isEnabled,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.optionalWeight,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              AppLocalizations.of(context)!.notes,
              style: TextStyle(color: colors.textSecondary, fontSize: 11),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _notesController,
              enabled: isEnabled,
              maxLines: 2,
            ),

            // Premium AI Re-evaluation Section
            const SizedBox(height: 8),
            const Divider(height: 24),
            Row(
              children: [
                const Icon(
                  Icons.auto_awesome,
                  color: AppTheme.accentEmerald,
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
                labelText: AppLocalizations.of(context)!.reEvaluateInstruction,
                hintText: AppLocalizations.of(
                  context,
                )!.reEvaluateInstructionHint,
                labelStyle: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 11,
                ),
                hintStyle: TextStyle(
                  color: colors.textSecondary.withValues(alpha: 0.6),
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
                            AppTheme.accentEmerald,
                          ),
                        ),
                      ),
                    )
                  : ElevatedButton.icon(
                      icon: const Icon(Icons.auto_awesome, size: 16),
                      label: Text(AppLocalizations.of(context)!.reEvaluate),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentEmerald,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: (isEnabled && !_isLoadingImage)
                          ? _handleReEvaluation
                          : null,
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isReEvaluating ? null : () => Navigator.pop(context),
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
                  final updatedMeal = widget.meal.copyWith(
                    foodName: _nameController.text.trim(),
                    calories: int.tryParse(_caloriesController.text) ?? 0,
                    protein: int.tryParse(_proteinController.text) ?? 0,
                    carbs: int.tryParse(_carbsController.text) ?? 0,
                    fat: int.tryParse(_fatController.text) ?? 0,
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
                      content: Text(AppLocalizations.of(context)!.mealUpdated),
                      backgroundColor: AppTheme.accentEmerald,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
          child: Text(AppLocalizations.of(context)!.saveChanges),
        ),
      ],
    );
  }
}
