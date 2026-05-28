import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../providers/app_state.dart';
import '../../l10n/app_localizations.dart';
import 'confetti_widget.dart';

class GamificationDialogs {
  // 1. Badge Unlocked Dialog
  static void showBadgeUnlocked(
    BuildContext context,
    AppState appState,
    String badgeId,
  ) {
    final colors = AppTheme.of(context);
    final l10n = AppLocalizations.of(context)!;

    IconData badgeIcon = Icons.stars;
    Color badgeColor = AppTheme.accentEmerald;
    String badgeTitle = '';
    String badgeDesc = '';

    if (badgeId == 'zundfunke') {
      badgeIcon = Icons.flash_on;
      badgeColor = AppTheme.accentAmber;
      badgeTitle = l10n.badgeZundfunkeTitle;
      badgeDesc = l10n.badgeZundfunkeDesc;
    } else if (badgeId == 'dreifache_disziplin') {
      badgeIcon = Icons.local_fire_department;
      badgeColor = AppTheme.accentRed;
      badgeTitle = l10n.badgeDreifacheDisziplinTitle;
      badgeDesc = l10n.badgeDreifacheDisziplinDesc;
    } else if (badgeId == 'wochen_koenig') {
      badgeIcon = Icons.emoji_events;
      badgeColor = Colors.amber;
      badgeTitle = l10n.badgeWochenKoenigTitle;
      badgeDesc = l10n.badgeWochenKoenigDesc;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
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
                      // Glowing badge avatar
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: badgeColor.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(color: badgeColor, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: badgeColor.withValues(alpha: 0.25),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(badgeIcon, color: badgeColor, size: 40),
                      ),
                      const SizedBox(height: 20),

                      // Dialog labels
                      Text(
                        l10n.badgeUnlockedPopup,
                        style: const TextStyle(
                          color: AppTheme.accentAmber,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        badgeTitle,
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        badgeDesc,
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // Confirm action
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: badgeColor,
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
                // Confetti particle overlay inside the dialog!
                Positioned.fill(
                  child: IgnorePointer(
                    child: ConfettiWidget(onFinished: () {}),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 2. Level Up Dialog
  static void showLevelUp(BuildContext context, AppState appState, int lvl) {
    final colors = AppTheme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final String title = appState.getLevelTitle(lvl, context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
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
                      // Glowing Gold circle displaying level
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.amber, AppTheme.accentAmber],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amber.withValues(alpha: 0.35),
                              blurRadius: 20,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '$lvl',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 38,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Congratulations labels
                      Text(
                        l10n.levelUpPopup,
                        style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        title,
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.levelUpDesc(lvl, title),
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // Confirm action
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentEmerald,
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
                // Confetti particle overlay inside the dialog!
                Positioned.fill(
                  child: IgnorePointer(
                    child: ConfettiWidget(onFinished: () {}),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 3. Shield Earned Dialog
  static void showShieldEarned(BuildContext context, AppState appState) {
    final colors = AppTheme.of(context);
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: colors.surface,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.accentBlue.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.accentBlue, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accentBlue.withValues(alpha: 0.25),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.shield,
                    color: AppTheme.accentBlue,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.streakShieldEarnedTitle,
                  style: const TextStyle(
                    color: AppTheme.accentBlue,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.streakShieldEarnedDesc,
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
                      backgroundColor: AppTheme.accentBlue,
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
        );
      },
    );
  }

  // 4. Shield Consumed Dialog
  static void showShieldConsumed(BuildContext context, AppState appState) {
    final colors = AppTheme.of(context);
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: colors.surface,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.accentAmber.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.accentAmber, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accentAmber.withValues(alpha: 0.25),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.shield_outlined,
                    color: AppTheme.accentAmber,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.streakShieldConsumedTitle,
                  style: const TextStyle(
                    color: AppTheme.accentAmber,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.streakShieldConsumedDesc,
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
                      backgroundColor: AppTheme.accentAmber,
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
        );
      },
    );
  }

  // 5. Streak Reset Dialog
  static void showStreakReset(BuildContext context, AppState appState) {
    final colors = AppTheme.of(context);
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: colors.surface,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: colors.surfaceLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.local_fire_department_outlined,
                    color: colors.textMuted,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.streakResetTitle,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.streakResetDesc,
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
                      backgroundColor: colors.textSecondary,
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
        );
      },
    );
  }

  // 6. Prestige Star Earned Dialog
  static void showPrestigeStarEarned(BuildContext context, AppState appState) {
    final colors = AppTheme.of(context);
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
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
                      // Deep violet / Indigo premium glow with double star and shield
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.indigo, Colors.purple],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purple.withValues(alpha: 0.35),
                              blurRadius: 20,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: const Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(Icons.shield, color: Colors.white, size: 40),
                            Padding(
                              padding: EdgeInsets.only(bottom: 2.0),
                              child: Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Congratulations labels
                      Text(
                        l10n.prestigeTitle,
                        style: const TextStyle(
                          color: Colors.purpleAccent,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.prestigeDesc,
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // Confirm action
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
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
                // Confetti particle overlay inside the dialog!
                Positioned.fill(
                  child: IgnorePointer(
                    child: ConfettiWidget(onFinished: () {}),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
