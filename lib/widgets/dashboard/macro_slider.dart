import 'package:flutter/material.dart';

class MacroSlider extends StatelessWidget {
  final String label;
  final int consumed;
  final int goal;
  final Color color;
  final Color textColor;

  const MacroSlider({
    super.key,
    required this.label,
    required this.consumed,
    required this.goal,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final double fraction = goal > 0 ? (consumed / goal).clamp(0.0, 1.0) : 0.0;
    final int percent = goal > 0 ? ((consumed / goal) * 100).toInt() : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
            Text(
              '$consumed / $goal g ($percent%)',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Stack(
            children: [
              Container(
                height: 10,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.05),
              ),
              FractionallySizedBox(
                widthFactor: fraction,
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
