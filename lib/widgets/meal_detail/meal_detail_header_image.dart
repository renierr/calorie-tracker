import 'package:flutter/material.dart';
import '../../models/meal_model.dart';
import '../../theme/theme.dart';

class MealDetailHeaderImage extends StatelessWidget {
  final Meal currentMeal;
  final VoidCallback? onPreview;

  const MealDetailHeaderImage({
    super.key,
    required this.currentMeal,
    this.onPreview,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context);

    return GestureDetector(
      onTap: currentMeal.imageBytes != null ? onPreview : null,
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: colors.surfaceLight,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: currentMeal.imageBytes != null
            ? ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Image.memory(currentMeal.imageBytes!, fit: BoxFit.cover),
              )
            : Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.accentEmerald.withValues(alpha: 0.15),
                      AppTheme.accentBlue.withValues(alpha: 0.15),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(
                  Icons.restaurant_menu,
                  color: AppTheme.accentEmerald,
                  size: 48,
                ),
              ),
      ),
    );
  }
}
