import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../l10n/app_localizations.dart';
import 'confetti_widget.dart';

class BaseGamificationDialog extends StatelessWidget {
  final Widget headerWidget;
  final String title;
  final String? subTitle;
  final String description;
  final Color titleColor;
  final Color buttonColor;
  final bool showConfetti;

  const BaseGamificationDialog({
    super.key,
    required this.headerWidget,
    required this.title,
    this.subTitle,
    required this.description,
    required this.titleColor,
    required this.buttonColor,
    this.showConfetti = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: colors.surface,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  headerWidget,
                  const SizedBox(height: 20),
                  if (subTitle != null) ...[
                    Text(
                      subTitle!,
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                  ],
                  Text(
                    title,
                    style: TextStyle(
                      color: subTitle != null ? colors.textPrimary : titleColor,
                      fontSize: subTitle != null ? 22 : 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    description,
                    style: TextStyle(color: colors.textSecondary, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(l10n.ok),
                    ),
                  ),
                ],
              ),
            ),
            if (showConfetti)
              Positioned.fill(
                child: IgnorePointer(child: ConfettiWidget(onFinished: () {})),
              ),
          ],
        ),
      ),
    );
  }
}
