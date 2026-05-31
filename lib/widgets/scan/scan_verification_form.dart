import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/theme.dart';
import '../../providers/app_state.dart';
import '../../models/meal_model.dart';
import '../../services/ai_service.dart';
import '../../l10n/app_localizations.dart';
import '../meal_form_fields.dart';
import 'scan_verification_header.dart';
import 'scan_date_picker_tile.dart';
import 'scan_verification_actions.dart';
import 'ai_fallback_dialog.dart';

class ScanVerificationForm extends StatefulWidget {
  final AppState appState;
  final AIAnalysisResult? scanResult;
  final Uint8List? imageBytes;
  final VoidCallback onDiscard;
  final VoidCallback onSaveSuccess;

  const ScanVerificationForm({
    super.key,
    required this.appState,
    required this.scanResult,
    required this.imageBytes,
    required this.onDiscard,
    required this.onSaveSuccess,
  });

  @override
  State<ScanVerificationForm> createState() => _ScanVerificationFormState();
}

class _ScanVerificationFormState extends State<ScanVerificationForm> {
  DateTime _mealDate = DateTime.now();
  bool _isReEvaluating = false;

  late final TextEditingController _nameController;
  late final TextEditingController _caloriesController;
  late final TextEditingController _proteinController;
  late final TextEditingController _carbsController;
  late final TextEditingController _fatController;
  late final TextEditingController _notesController;
  late final TextEditingController _weightController;

  @override
  void initState() {
    super.initState();
    final appState = widget.appState;
    _mealDate = appState.scanMealDate;

    _nameController = TextEditingController(text: appState.scanFoodName);
    _caloriesController = TextEditingController(text: appState.scanCalories);
    _proteinController = TextEditingController(text: appState.scanProtein);
    _carbsController = TextEditingController(text: appState.scanCarbs);
    _fatController = TextEditingController(text: appState.scanFat);
    _notesController = TextEditingController(text: appState.scanNotes);
    _weightController = TextEditingController(text: appState.scanWeight);

    _nameController.addListener(_updateDraft);
    _caloriesController.addListener(_updateDraft);
    _proteinController.addListener(_updateDraft);
    _carbsController.addListener(_updateDraft);
    _fatController.addListener(_updateDraft);
    _notesController.addListener(_updateDraft);
    _weightController.addListener(_updateDraft);
  }

  void _updateDraft() {
    widget.appState.updateScanDraftFields(
      foodName: _nameController.text,
      calories: _caloriesController.text,
      protein: _proteinController.text,
      carbs: _carbsController.text,
      fat: _fatController.text,
      notes: _notesController.text,
      weight: _weightController.text,
    );
  }

  @override
  void dispose() {
    _nameController.removeListener(_updateDraft);
    _caloriesController.removeListener(_updateDraft);
    _proteinController.removeListener(_updateDraft);
    _carbsController.removeListener(_updateDraft);
    _fatController.removeListener(_updateDraft);
    _notesController.removeListener(_updateDraft);
    _weightController.removeListener(_updateDraft);

    _nameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _notesController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _reEvaluateMeal({String? overrideProvider}) async {
    if (widget.imageBytes == null) return;

    final provider = overrideProvider ?? widget.appState.aiProvider;
    final apiKey = widget.appState.getApiKeyForProvider(provider);
    final hasApiKey = provider == 'custom' || apiKey.trim().isNotEmpty;
    if (!hasApiKey) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.apiKeyMissing)),
      );
      return;
    }

    setState(() {
      _isReEvaluating = true;
    });

    try {
      String customHint = '';
      final currentName = _nameController.text.trim();
      final currentNotes = _notesController.text.trim();

      if (currentName.isNotEmpty) {
        customHint += 'User thinks food is: "$currentName". ';
      }
      if (currentNotes.isNotEmpty) {
        customHint += 'Additional context/adjustments: "$currentNotes". ';
      }

      final result = await widget.appState.performAIAnalysis(
        imageBytes: widget.imageBytes!,
        mimeType: 'image/jpeg',
        userHint: customHint,
        overrideProvider: overrideProvider,
      );

      setState(() {
        _nameController.text = result.foodName;
        _caloriesController.text = result.calories.toString();
        _proteinController.text = result.protein.toString();
        _carbsController.text = result.carbs.toString();
        _fatController.text = result.fat.toString();
        _notesController.text = result.notes;
        _isReEvaluating = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.reEvaluationSuccess),
          backgroundColor: AppTheme.accentEmerald,
        ),
      );
    } catch (e) {
      setState(() {
        _isReEvaluating = false;
      });
      if (!mounted) return;

      await AIFallbackDialog.handleFallback(
        context: context,
        appState: widget.appState,
        currentOverrideProvider: overrideProvider,
        error: e,
        onRetry: (fallback) => _reEvaluateMeal(overrideProvider: fallback),
        onErrorUnhandled: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.reEvaluationError(e.toString()),
              ),
              backgroundColor: AppTheme.accentRed,
            ),
          );
        },
      );
    }
  }

  Future<void> _saveMeal() async {
    final String name = _nameController.text.trim();
    final int calories = int.tryParse(_caloriesController.text) ?? 0;
    final int protein = int.tryParse(_proteinController.text) ?? 0;
    final int carbs = int.tryParse(_carbsController.text) ?? 0;
    final int fat = int.tryParse(_fatController.text) ?? 0;
    final String notes = _notesController.text.trim();
    final double? weight = double.tryParse(_weightController.text.trim());

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.provideName)),
      );
      return;
    }

    final isAct = widget.appState.scanIsActivity;
    final newMeal = Meal(
      shortId: isAct
          ? Meal.generateRandomActivityShortId()
          : 'MEAL-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
      foodName: name,
      calories: calories,
      protein: isAct ? 0 : protein,
      carbs: isAct ? 0 : carbs,
      fat: isAct ? 0 : fat,
      confidence: widget.scanResult?.confidence ?? 100,
      imageBytes: widget.imageBytes,
      notes: notes,
      weightKg: weight,
      timestamp: _mealDate.millisecondsSinceEpoch,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

    await widget.appState.addMeal(newMeal);

    widget.appState.selectTab(0);
    widget.onSaveSuccess();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isAct
              ? AppLocalizations.of(context)!.activityLogged
              : AppLocalizations.of(context)!.mealLogged,
        ),
        backgroundColor: AppTheme.accentEmerald,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = !_isReEvaluating;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.premiumCardDecoration(
        context: context,
        showGlow: true,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ScanVerificationHeader(
            isActivity: widget.appState.scanIsActivity,
            scanResult: widget.scanResult,
          ),
          const SizedBox(height: 20),
          MealFormFields(
            isActivity: widget.appState.scanIsActivity,
            isEnabled: isEnabled,
            nameController: _nameController,
            caloriesController: _caloriesController,
            proteinController: _proteinController,
            carbsController: _carbsController,
            fatController: _fatController,
            weightController: _weightController,
            notesController: _notesController,
          ),
          const SizedBox(height: 16),
          ScanDatePickerTile(
            mealDate: _mealDate,
            isEnabled: isEnabled,
            onDateChanged: (picked) {
              setState(() => _mealDate = picked);
              widget.appState.updateScanDraftFields(mealDate: picked);
            },
          ),
          const SizedBox(height: 25),
          ScanVerificationActions(
            isEnabled: isEnabled,
            isReEvaluating: _isReEvaluating,
            showReEvaluate:
                widget.imageBytes != null && !widget.appState.scanIsActivity,
            onDiscard: widget.onDiscard,
            onReEvaluate: _reEvaluateMeal,
            onSave: _saveMeal,
          ),
        ],
      ),
    );
  }
}
