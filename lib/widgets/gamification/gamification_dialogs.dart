import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../providers/app_state.dart';
import '../../l10n/app_localizations.dart';
import 'base_gamification_dialog.dart';

class GamificationDialogs {
  // 1. Badge Unlocked Dialog
  static Future<void> showBadgeUnlocked(
    BuildContext context,
    AppState appState,
    String badgeId,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    IconData badgeIcon = Icons.stars;
    Color badgeColor = AppTheme.accentEmerald;
    String badgeTitle = '';
    String badgeDesc = '';

    if (badgeId == 'spark') {
      badgeIcon = Icons.flash_on;
      badgeColor = AppTheme.accentAmber;
      badgeTitle = l10n.badgeZundfunkeTitle;
      badgeDesc = l10n.badgeZundfunkeDesc;
    } else if (badgeId == 'triple_discipline') {
      badgeIcon = Icons.local_fire_department;
      badgeColor = AppTheme.accentRed;
      badgeTitle = l10n.badgeDreifacheDisziplinTitle;
      badgeDesc = l10n.badgeDreifacheDisziplinDesc;
    } else if (badgeId == 'week_king') {
      badgeIcon = Icons.emoji_events;
      badgeColor = Colors.amber;
      badgeTitle = l10n.badgeWochenKoenigTitle;
      badgeDesc = l10n.badgeWochenKoenigDesc;
    } else if (badgeId == 'hundred_day_legend') {
      badgeIcon = Icons.military_tech;
      badgeColor = Colors.deepOrange;
      badgeTitle = l10n.badgeHunderterLegendeTitle;
      badgeDesc = l10n.badgeHunderterLegendeDesc;
    } else if (badgeId == 'year_titan') {
      badgeIcon = Icons.workspace_premium;
      badgeColor = Colors.amber;
      badgeTitle = l10n.badgeJahresTitanTitle;
      badgeDesc = l10n.badgeJahresTitanDesc;
    } else if (badgeId == 'diary_veteran') {
      badgeIcon = Icons.menu_book;
      badgeColor = AppTheme.accentBlue;
      badgeTitle = l10n.badgeTagebuchVeteranTitle;
      badgeDesc = l10n.badgeTagebuchVeteranDesc;
    } else if (badgeId == 'calorie_archivist') {
      badgeIcon = Icons.inventory_2;
      badgeColor = Colors.indigo;
      badgeTitle = l10n.badgeKalorienArchivarTitle;
      badgeDesc = l10n.badgeKalorienArchivarDesc;
    } else if (badgeId == 'thousand_club') {
      badgeIcon = Icons.stars;
      badgeColor = Colors.teal;
      badgeTitle = l10n.badgeTausenderClubTitle;
      badgeDesc = l10n.badgeTausenderClubDesc;
    } else if (badgeId == 'prestige_pioneer') {
      badgeIcon = Icons.auto_awesome;
      badgeColor = Colors.purple;
      badgeTitle = l10n.badgePrestigePionierTitle;
      badgeDesc = l10n.badgePrestigePionierDesc;
    } else if (badgeId == 'shield_collector') {
      badgeIcon = Icons.shield;
      badgeColor = AppTheme.accentEmerald;
      badgeTitle = l10n.badgeSchildSammlerTitle;
      badgeDesc = l10n.badgeSchildSammlerDesc;
    } else if (badgeId == 'comeback_kid') {
      badgeIcon = Icons.loop;
      badgeColor = Colors.amber;
      badgeTitle = l10n.badgeComebackKidTitle;
      badgeDesc = l10n.badgeComebackKidDesc;
    } else if (badgeId == 'bullseye') {
      badgeIcon = Icons.center_focus_strong;
      badgeColor = AppTheme.accentEmerald;
      badgeTitle = l10n.badgePunktlandungTitle;
      badgeDesc = l10n.badgePunktlandungDesc;
    } else if (badgeId == 'protein_pro') {
      badgeIcon = Icons.fitness_center;
      badgeColor = Colors.deepOrange;
      badgeTitle = l10n.badgeProteinProfiTitle;
      badgeDesc = l10n.badgeProteinProfiDesc;
    } else if (badgeId == 'macro_balance') {
      badgeIcon = Icons.pie_chart;
      badgeColor = AppTheme.accentBlue;
      badgeTitle = l10n.badgeMakroAusgleichTitle;
      badgeDesc = l10n.badgeMakroAusgleichDesc;
    } else if (badgeId == 'burn_master') {
      badgeIcon = Icons.local_fire_department;
      badgeColor = AppTheme.accentRed;
      badgeTitle = l10n.badgeBurnMasterTitle;
      badgeDesc = l10n.badgeBurnMasterDesc;
    } else if (badgeId == 'fitness_knight') {
      badgeIcon = Icons.directions_run;
      badgeColor = Colors.purple;
      badgeTitle = l10n.badgeFitnessRitterTitle;
      badgeDesc = l10n.badgeFitnessRitterDesc;
    } else if (badgeId == 'photo_gourmet') {
      badgeIcon = Icons.camera_alt;
      badgeColor = Colors.cyan;
      badgeTitle = l10n.badgeFotoGourmetTitle;
      badgeDesc = l10n.badgeFotoGourmetDesc;
    } else if (badgeId == 'favorite_chef') {
      badgeIcon = Icons.favorite;
      badgeColor = Colors.pink;
      badgeTitle = l10n.badgeFavoritenChefTitle;
      badgeDesc = l10n.badgeFavoritenChefDesc;
    } else if (badgeId == 'calorie_saver') {
      badgeIcon = Icons.savings;
      badgeColor = Colors.lightGreen;
      badgeTitle = l10n.badgeKalorienSparfuchsTitle;
      badgeDesc = l10n.badgeKalorienSparfuchsDesc;
    }

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return BaseGamificationDialog(
          headerWidget: Container(
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
          subTitle: l10n.badgeUnlockedPopup,
          title: badgeTitle,
          description: badgeDesc,
          titleColor: AppTheme.accentAmber,
          buttonColor: badgeColor,
          showConfetti: true,
        );
      },
    );
  }

  // 2. Level Up Dialog
  static void showLevelUp(BuildContext context, AppState appState, int lvl) {
    final l10n = AppLocalizations.of(context)!;
    final String title = appState.getLevelTitle(lvl, context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return BaseGamificationDialog(
          headerWidget: Container(
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
          subTitle: l10n.levelUpPopup,
          title: title,
          description: l10n.levelUpDesc(lvl, title),
          titleColor: Colors.amber,
          buttonColor: AppTheme.accentEmerald,
          showConfetti: true,
        );
      },
    );
  }

  // 3. Shield Earned Dialog
  static void showShieldEarned(BuildContext context, AppState appState) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return BaseGamificationDialog(
          headerWidget: Container(
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
          title: l10n.streakShieldEarnedTitle,
          description: l10n.streakShieldEarnedDesc,
          titleColor: AppTheme.accentBlue,
          buttonColor: AppTheme.accentBlue,
          showConfetti: false,
        );
      },
    );
  }

  // 4. Shield Consumed Dialog
  static void showShieldConsumed(BuildContext context, AppState appState) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return BaseGamificationDialog(
          headerWidget: Container(
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
          title: l10n.streakShieldConsumedTitle,
          description: l10n.streakShieldConsumedDesc,
          titleColor: AppTheme.accentAmber,
          buttonColor: AppTheme.accentAmber,
          showConfetti: false,
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
        return BaseGamificationDialog(
          headerWidget: Container(
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
          title: l10n.streakResetTitle,
          description: l10n.streakResetDesc,
          titleColor: colors.textPrimary,
          buttonColor: colors.textSecondary,
          showConfetti: false,
        );
      },
    );
  }

  // 6. Prestige Star Earned Dialog
  static void showPrestigeStarEarned(BuildContext context, AppState appState) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return BaseGamificationDialog(
          headerWidget: Container(
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
                  child: Icon(Icons.star, color: Colors.amber, size: 20),
                ),
              ],
            ),
          ),
          title: l10n.prestigeTitle,
          description: l10n.prestigeDesc,
          titleColor: Colors.purpleAccent,
          buttonColor: Colors.purple,
          showConfetti: true,
        );
      },
    );
  }

  // 7. 10th Prestige Star Milestone Dialog (10th, 20th, 30th...)
  static void showPrestigeMilestone(
    BuildContext context,
    AppState appState,
    int starCount,
  ) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return BaseGamificationDialog(
          headerWidget: Container(
            width: 95,
            height: 95,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.amber, Colors.deepOrange],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withValues(alpha: 0.4),
                  blurRadius: 22,
                  spreadRadius: 4,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(
                  Icons.workspace_premium,
                  color: Colors.white,
                  size: 52,
                ),
                Positioned(
                  bottom: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$starCount⭐',
                      style: const TextStyle(
                        color: Colors.amberAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          title: l10n.prestigeMilestoneTitle(starCount),
          description: l10n.prestigeMilestoneDesc(starCount),
          titleColor: Colors.amber.shade700,
          buttonColor: Colors.deepOrange,
          showConfetti: true,
        );
      },
    );
  }
}
