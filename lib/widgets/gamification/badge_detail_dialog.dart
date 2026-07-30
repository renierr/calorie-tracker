import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/theme.dart';
import 'base_gamification_dialog.dart';

/// Shows the full title and description of a badge.
/// Used wherever a badge is rendered in a space constrained tile.
class BadgeDetailDialog {
  const BadgeDetailDialog._();

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required bool isUnlocked,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final colors = AppTheme.of(context);
    final Color activeColor = isUnlocked ? color : colors.textMuted;

    return showDialog<void>(
      context: context,
      builder: (context) {
        return BaseGamificationDialog(
          headerWidget: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: activeColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: activeColor, width: 2),
                ),
                child: Icon(icon, color: activeColor, size: 40),
              ),
              if (!isUnlocked)
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withValues(alpha: 0.35),
                  ),
                  child: const Icon(
                    Icons.lock,
                    color: Colors.white70,
                    size: 28,
                  ),
                ),
            ],
          ),
          subTitle: isUnlocked
              ? l10n.badgeUnlockedStatus
              : l10n.badgeLockedStatus,
          title: title,
          description: description,
          titleColor: isUnlocked ? AppTheme.accentEmerald : colors.textMuted,
          buttonColor: isUnlocked ? activeColor : colors.textMuted,
        );
      },
    );
  }
}
