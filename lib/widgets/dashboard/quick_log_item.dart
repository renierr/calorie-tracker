import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../models/meal_model.dart';
import '../../l10n/app_localizations.dart';
import '../mini_macro_chip.dart';

class QuickLogItem extends StatelessWidget {
  final Meal meal;
  final VoidCallback onTap;

  const QuickLogItem({super.key, required this.meal, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context);

    // Dynamically extract short localized macro labels (e.g. 'P'/'E', 'C'/'K', 'F'/'F')
    final perGramStr = AppLocalizations.of(context)!.perGram(0, 0, 0);
    final cleanParts = perGramStr
        .split(' ')
        .where((s) => s.isNotEmpty)
        .toList();
    final pLabel = cleanParts.isNotEmpty
        ? cleanParts[0].replaceAll(':', '')
        : 'P';
    final cLabel = cleanParts.length > 2
        ? cleanParts[2].replaceAll(':', '')
        : 'C';
    final fLabel = cleanParts.length > 4
        ? cleanParts[4].replaceAll(':', '')
        : 'F';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        child: Row(
          children: [
            // Thumbnail Photo or fallback icon
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: colors.surfaceLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white12
                      : Colors.black.withValues(alpha: 0.08),
                  width: 0.5,
                ),
              ),
              child: meal.imageBytes != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(meal.imageBytes!, fit: BoxFit.cover),
                    )
                  : const Icon(
                      Icons.fastfood,
                      color: AppTheme.accentEmerald,
                      size: 20,
                    ),
            ),
            const SizedBox(width: 14),

            // Text Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal.foodName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            MiniMacroChip(
                              label: pLabel,
                              value: '${meal.protein}g',
                              color: AppTheme.accentBlue,
                            ),
                            MiniMacroChip(
                              label: cLabel,
                              value: '${meal.carbs}g',
                              color: AppTheme.accentAmber,
                            ),
                            MiniMacroChip(
                              label: fLabel,
                              value: '${meal.fat}g',
                              color: AppTheme.accentRed,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        AppLocalizations.of(context)!.kcalLabel(meal.calories),
                        style: const TextStyle(
                          color: AppTheme.accentEmerald,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
