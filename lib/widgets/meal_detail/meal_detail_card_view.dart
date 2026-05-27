import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/meal_model.dart';
import '../../theme/theme.dart';

// Import sub-components
import 'meal_detail_header_image.dart';
import 'meal_detail_metadata.dart';
import 'meal_macro_grid.dart';
import 'meal_weight_card.dart';
import 'meal_notes_section.dart';
import 'meal_card_watermark.dart';

class MealDetailCardView extends StatelessWidget {
  final Meal currentMeal;
  final bool hideWeight;
  final bool isExport;
  final DateFormat dateFormat;
  final DateFormat timeFormat;
  final DateTime mealDate;
  final VoidCallback? onPreview;

  const MealDetailCardView({
    super.key,
    required this.currentMeal,
    required this.hideWeight,
    required this.isExport,
    required this.dateFormat,
    required this.timeFormat,
    required this.mealDate,
    this.onPreview,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MealDetailHeaderImage(
            currentMeal: currentMeal,
            onPreview: onPreview,
            isExport: isExport,
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

                // Optional Body Weight Metric
                if (currentMeal.weightKg != null && !hideWeight) ...[
                  const SizedBox(height: 12),
                  MealWeightCard(weightKg: currentMeal.weightKg!),
                ],
                const SizedBox(height: 18),

                // Optional User log Notes
                if (currentMeal.notes != null &&
                    currentMeal.notes!.trim().isNotEmpty) ...[
                  MealNotesSection(notes: currentMeal.notes!),
                  const SizedBox(height: 16),
                ],

                // Brand watermark badge inside capture region
                const MealCardWatermark(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
