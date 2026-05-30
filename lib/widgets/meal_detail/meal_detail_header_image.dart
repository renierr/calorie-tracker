import 'package:flutter/material.dart';
import '../../models/meal_model.dart';
import '../../theme/theme.dart';

class MealDetailHeaderImage extends StatelessWidget {
  final Meal currentMeal;
  final VoidCallback? onPreview;
  final bool isExport;

  const MealDetailHeaderImage({
    super.key,
    required this.currentMeal,
    this.onPreview,
    this.isExport = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context);

    return GestureDetector(
      onTap: currentMeal.imageBytes != null ? onPreview : null,
      child: Container(
        height: isExport ? null : 200,
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
                child: Image.memory(
                  currentMeal.imageBytes!,
                  fit: isExport ? BoxFit.fitWidth : BoxFit.cover,
                ),
              )
            : Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  gradient: LinearGradient(
                    colors: currentMeal.isActivity
                        ? [
                            AppTheme.accentAmber.withValues(alpha: 0.15),
                            AppTheme.accentRed.withValues(alpha: 0.15),
                          ]
                        : [
                            AppTheme.accentEmerald.withValues(alpha: 0.15),
                            AppTheme.accentBlue.withValues(alpha: 0.15),
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Icon(
                  currentMeal.isActivity
                      ? Icons.directions_run
                      : Icons.fastfood,
                  color: currentMeal.isActivity
                      ? AppTheme.accentAmber
                      : AppTheme.accentEmerald,
                  size: 48,
                ),
              ),
      ),
    );
  }
}
