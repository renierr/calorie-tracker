import 'package:flutter/material.dart';
import '../../models/meal_model.dart';
import '../../theme/theme.dart';
import '../../l10n/app_localizations.dart';

class MealBottomActions extends StatelessWidget {
  final Meal currentMeal;
  final VoidCallback onPdfExport;
  final VoidCallback onEdit;
  final VoidCallback onTemplate;
  final VoidCallback onDelete;

  const MealBottomActions({
    super.key,
    required this.currentMeal,
    required this.onPdfExport,
    required this.onEdit,
    required this.onTemplate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Divider(color: colors.surfaceLight, height: 1),
          const SizedBox(height: 12),
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
                onPressed: onPdfExport,
              ),
              // Edit log
              TextButton.icon(
                icon: const Icon(Icons.edit, size: 16),
                label: Text(
                  AppLocalizations.of(context)!.edit,
                  style: const TextStyle(fontSize: 12),
                ),
                onPressed: onEdit,
              ),
              // Use as template
              TextButton.icon(
                icon: const Icon(Icons.add_to_photos, size: 16),
                label: Text(
                  AppLocalizations.of(context)!.templateAsNew,
                  style: const TextStyle(fontSize: 12),
                ),
                onPressed: onTemplate,
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
                onPressed: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
