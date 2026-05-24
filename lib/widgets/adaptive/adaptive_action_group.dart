import 'package:flutter/material.dart';

import '../../layout/adaptive_breakpoints.dart';

class AdaptiveActionGroup extends StatelessWidget {
  final List<Widget> actions;
  final double spacing;

  const AdaptiveActionGroup({
    super.key,
    required this.actions,
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (!constraints.hasBoundedWidth) {
          return Column(
            children: [
              for (int i = 0; i < actions.length; i++) ...[
                SizedBox(width: double.infinity, child: actions[i]),
                if (i < actions.length - 1) SizedBox(height: spacing),
              ],
            ],
          );
        }

        if (AppBreakpoints.isCompactWidth(constraints.maxWidth)) {
          return Column(
            children: [
              for (int i = 0; i < actions.length; i++) ...[
                SizedBox(width: double.infinity, child: actions[i]),
                if (i < actions.length - 1) SizedBox(height: spacing),
              ],
            ],
          );
        }

        return Row(
          children: [
            for (int i = 0; i < actions.length; i++) ...[
              Expanded(child: actions[i]),
              if (i < actions.length - 1) SizedBox(width: spacing),
            ],
          ],
        );
      },
    );
  }
}
