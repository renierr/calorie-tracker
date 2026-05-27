import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../l10n/app_localizations.dart';

class MealNotesSection extends StatelessWidget {
  final String notes;

  const MealNotesSection({super.key, required this.notes});

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.notes,
          style: TextStyle(
            color: colors.textSecondary,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colors.surfaceLight.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            notes,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 13,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }
}
