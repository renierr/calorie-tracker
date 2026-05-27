import 'package:flutter/material.dart';
import '../../theme/theme.dart';

class MealCardWatermark extends StatelessWidget {
  const MealCardWatermark({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context);

    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.spa_outlined,
            color: AppTheme.accentEmerald,
            size: 14,
          ),
          const SizedBox(width: 5),
          Text(
            "NutriScan Calorie Tracker",
            style: TextStyle(
              color: colors.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
