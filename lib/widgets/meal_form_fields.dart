import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/theme.dart';
import '../l10n/app_localizations.dart';

class MealFormFields extends StatelessWidget {
  final bool isActivity;
  final bool isEnabled;
  final TextEditingController nameController;
  final TextEditingController caloriesController;
  final TextEditingController proteinController;
  final TextEditingController carbsController;
  final TextEditingController fatController;
  final TextEditingController weightController;
  final TextEditingController notesController;

  const MealFormFields({
    super.key,
    required this.isActivity,
    required this.isEnabled,
    required this.nameController,
    required this.caloriesController,
    required this.proteinController,
    required this.carbsController,
    required this.fatController,
    required this.weightController,
    required this.notesController,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isActivity
              ? AppLocalizations.of(context)!.activityName
              : AppLocalizations.of(context)!.mealDescription,
          style: TextStyle(color: colors.textSecondary, fontSize: 11),
        ),
        const SizedBox(height: 6),
        TextField(controller: nameController, enabled: isEnabled),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isActivity
                        ? AppLocalizations.of(context)!.caloriesBurnedKcal
                        : AppLocalizations.of(context)!.caloriesKcal,
                    style: TextStyle(color: colors.textSecondary, fontSize: 11),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: caloriesController,
                    enabled: isEnabled,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onTap: () {
                      if (caloriesController.text == '0') {
                        caloriesController.clear();
                      }
                    },
                  ),
                ],
              ),
            ),
            if (!isActivity) ...[
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
                      controller: proteinController,
                      enabled: isEnabled,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onTap: () {
                        if (proteinController.text == '0') {
                          proteinController.clear();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 14),
        if (!isActivity) ...[
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
                      controller: carbsController,
                      enabled: isEnabled,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onTap: () {
                        if (carbsController.text == '0') {
                          carbsController.clear();
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
                      controller: fatController,
                      enabled: isEnabled,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onTap: () {
                        if (fatController.text == '0') {
                          fatController.clear();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
        ],
        Text(
          AppLocalizations.of(context)!.bodyWeightKg,
          style: TextStyle(color: colors.textSecondary, fontSize: 11),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: weightController,
          enabled: isEnabled,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
        TextField(controller: notesController, enabled: isEnabled, maxLines: 2),
      ],
    );
  }
}
