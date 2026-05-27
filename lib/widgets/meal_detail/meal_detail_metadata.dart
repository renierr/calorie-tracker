import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/theme.dart';

class MealDetailMetadata extends StatelessWidget {
  final DateFormat dateFormat;
  final DateFormat timeFormat;
  final DateTime mealDate;
  final String shortId;

  const MealDetailMetadata({
    super.key,
    required this.dateFormat,
    required this.timeFormat,
    required this.mealDate,
    required this.shortId,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${dateFormat.format(mealDate)}  •  ${timeFormat.format(mealDate)}',
          style: TextStyle(
            color: colors.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: colors.surfaceLight,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            shortId,
            style: TextStyle(color: colors.textMuted, fontSize: 10),
          ),
        ),
      ],
    );
  }
}
