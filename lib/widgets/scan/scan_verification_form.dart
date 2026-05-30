import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../layout/adaptive_breakpoints.dart';
import '../../theme/theme.dart';
import '../../providers/app_state.dart';
import '../../models/meal_model.dart';
import '../../services/ai_service.dart';
import '../../l10n/app_localizations.dart';
import '../adaptive/adaptive_action_group.dart';

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

  Future<void> _reEvaluateMeal() async {
    if (widget.imageBytes == null) return;

    final apiKey = widget.appState.aiApiKey;
    final hasApiKey =
        widget.appState.aiProvider == 'custom' || apiKey.trim().isNotEmpty;
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.reEvaluationError(e.toString()),
          ),
          backgroundColor: AppTheme.accentRed,
        ),
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
              ? 'Activity logged successfully'
              : AppLocalizations.of(context)!.mealLogged,
        ),
        backgroundColor: AppTheme.accentEmerald,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.premiumCardDecoration(
        context: context,
        showGlow: true,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final bool isNarrow = AppBreakpoints.isCompactContentWidth(
                constraints.maxWidth,
              );
              return Wrap(
                spacing: 10,
                runSpacing: 8,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SizedBox(
                    width: isNarrow ? constraints.maxWidth : null,
                    child: Text(
                      widget.appState.scanIsActivity
                          ? 'Verify Activity Details'
                          : AppLocalizations.of(context)!.verifyEstimates,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (widget.scanResult != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.accentEmerald.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        AppLocalizations.of(
                          context,
                        )!.aiMatch(widget.scanResult!.confidence),
                        style: const TextStyle(
                          color: AppTheme.accentEmerald,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),

          // Food Name
          Text(
            widget.appState.scanIsActivity
                ? 'Activity / Exercise Name'
                : AppLocalizations.of(context)!.mealDescription,
            style: TextStyle(color: colors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _nameController,
            enabled: !_isReEvaluating,
            decoration: InputDecoration(
              hintText: widget.appState.scanIsActivity
                  ? 'Running, Swimming, Cycling...'
                  : AppLocalizations.of(context)!.avocadoHint,
            ),
          ),
          const SizedBox(height: 16),

          // Numeric stats row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.appState.scanIsActivity
                          ? 'Calories Burned (kcal)'
                          : AppLocalizations.of(context)!.caloriesKcal,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _caloriesController,
                      enabled: !_isReEvaluating,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onTap: () {
                        if (_caloriesController.text == '0') {
                          _caloriesController.clear();
                        }
                      },
                    ),
                  ],
                ),
              ),
              if (!widget.appState.scanIsActivity) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.proteinG,
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _proteinController,
                        enabled: !_isReEvaluating,
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
            ],
          ),
          const SizedBox(height: 16),

          if (!widget.appState.scanIsActivity) ...[
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
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _carbsController,
                        enabled: !_isReEvaluating,
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
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.fatG,
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _fatController,
                        enabled: !_isReEvaluating,
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
            const SizedBox(height: 16),
          ],
          Text(
            AppLocalizations.of(context)!.bodyWeightKg,
            style: TextStyle(color: colors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _weightController,
            enabled: !_isReEvaluating,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.optionalWeight,
            ),
          ),
          const SizedBox(height: 16),

          // Analysis explanations
          Text(
            AppLocalizations.of(context)!.aiNotes,
            style: TextStyle(color: colors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _notesController,
            enabled: !_isReEvaluating,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.macroHint,
            ),
          ),
          const SizedBox(height: 16),

          // Date picker for meal date
          InkWell(
            onTap: _isReEvaluating
                ? null
                : () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _mealDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() => _mealDate = picked);
                      widget.appState.updateScanDraftFields(mealDate: picked);
                    }
                  },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
              decoration: BoxDecoration(
                color: colors.surfaceLight.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.08),
                ),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final bool isNarrow = AppBreakpoints.isCompactWidth(
                    constraints.maxWidth,
                  );
                  final Widget staleDateIcon =
                      (_mealDate ==
                              DateTime.now().subtract(
                                const Duration(days: 1),
                              ) ||
                          _mealDate.isBefore(
                            DateTime.now().subtract(const Duration(days: 1)),
                          ))
                      ? const Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Icon(
                            Icons.edit_calendar,
                            color: AppTheme.accentAmber,
                            size: 16,
                          ),
                        )
                      : const SizedBox.shrink();

                  if (isNarrow) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              color: AppTheme.accentEmerald,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              AppLocalizations.of(context)!.mealDate,
                              style: TextStyle(
                                color: colors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                DateFormat.yMd(locale).format(_mealDate),
                                style: TextStyle(
                                  color: colors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            staleDateIcon,
                          ],
                        ),
                      ],
                    );
                  }

                  return Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: AppTheme.accentEmerald,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        AppLocalizations.of(context)!.mealDate,
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          DateFormat.yMd(locale).format(_mealDate),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      staleDateIcon,
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 25),
          AdaptiveActionGroup(
            spacing: 10,
            actions: [
              OutlinedButton(
                onPressed: _isReEvaluating ? null : widget.onDiscard,
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.textPrimary,
                  side: BorderSide(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white24
                        : Colors.black26,
                  ),
                  minimumSize: const Size.fromHeight(48),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context)!.discard,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                ),
              ),
              if (widget.imageBytes != null && !widget.appState.scanIsActivity)
                ElevatedButton(
                  onPressed: _isReEvaluating ? null : _reEvaluateMeal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentBlue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isReEvaluating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.auto_awesome, size: 16),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                AppLocalizations.of(context)!.reEvaluate,
                                maxLines: 2,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                ),
              ElevatedButton(
                onPressed: _isReEvaluating ? null : _saveMeal,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: Text(
                  AppLocalizations.of(context)!.logAndSave,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
