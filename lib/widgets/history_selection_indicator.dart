import 'package:flutter/material.dart';
import '../theme/theme.dart';

class HistorySelectionIndicator extends StatelessWidget {
  final bool isSelected;

  const HistorySelectionIndicator({super.key, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.accentEmerald : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected
              ? AppTheme.accentEmerald
              : (Theme.of(context).brightness == Brightness.dark
                    ? Colors.white30
                    : Colors.black26),
          width: 2,
        ),
      ),
      child: isSelected
          ? const Icon(Icons.check, size: 14, color: Colors.white)
          : null,
    );
  }
}
