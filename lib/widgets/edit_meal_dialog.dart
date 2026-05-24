import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/theme.dart';
import '../models/meal_model.dart';
import '../providers/app_state.dart';
import '../l10n/app_localizations.dart';

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
  }

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context);
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
            TextField(controller: _nameController),
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
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
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
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
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
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
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
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              AppLocalizations.of(context)!.notes,
              style: TextStyle(color: colors.textSecondary, fontSize: 11),
            ),
            const SizedBox(height: 6),
            TextField(controller: _notesController, maxLines: 2),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            AppLocalizations.of(context)!.cancel,
            style: TextStyle(color: colors.textSecondary),
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            final updatedMeal = widget.meal.copyWith(
              foodName: _nameController.text.trim(),
              calories: int.tryParse(_caloriesController.text) ?? 0,
              protein: int.tryParse(_proteinController.text) ?? 0,
              carbs: int.tryParse(_carbsController.text) ?? 0,
              fat: int.tryParse(_fatController.text) ?? 0,
              notes: _notesController.text.trim(),
              updatedAt: DateTime.now().millisecondsSinceEpoch,
            );
            await widget.appState.updateMeal(updatedMeal);
            if (!context.mounted) return;
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.mealUpdated),
                backgroundColor: AppTheme.accentEmerald,
              ),
            );
          },
          child: Text(AppLocalizations.of(context)!.saveChanges),
        ),
      ],
    );
  }
}
