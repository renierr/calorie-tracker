import 'package:flutter/material.dart';

class AdaptiveCardHeader extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget? trailing;

  const AdaptiveCardHeader({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;

    final titleWidget = Text(
      title,
      maxLines: 2,
      style: TextStyle(
        color: textColor,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final Widget adaptiveTitle = constraints.hasBoundedWidth
            ? Expanded(child: titleWidget)
            : titleWidget;

        return Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 10),
            adaptiveTitle,
            if (trailing != null) ...[const SizedBox(width: 8), trailing!],
          ],
        );
      },
    );
  }
}
