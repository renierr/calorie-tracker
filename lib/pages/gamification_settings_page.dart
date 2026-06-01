import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme.dart';
import '../providers/app_state.dart';
import '../l10n/app_localizations.dart';
import '../widgets/gamification/gamification_dialogs.dart';
import '../widgets/gamification/confetti_widget.dart';
import '../widgets/gamification/admin_button.dart';
import '../widgets/adaptive/adaptive_card_header.dart';

class GamificationSettingsPage extends StatelessWidget {
  const GamificationSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final colors = AppTheme.of(context);
    final l10n = AppLocalizations.of(context)!;

    // Direct local trigger validation for the active settings sub-page (Immediate dismissal to avoid cascading duplicates)
    if (appState.recentUnlockedBadge != null) {
      final badge = appState.recentUnlockedBadge!;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        appState.dismissBadgeNotification();
        await GamificationDialogs.showBadgeUnlocked(context, appState, badge);
        appState.onBadgeDialogDismissed(badge);
      });
    }
    if (appState.showLevelUpNotification) {
      final lvl = appState.gamificationStats.level;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        appState.dismissLevelUpNotification();
        GamificationDialogs.showLevelUp(context, appState, lvl);
      });
    }
    if (appState.showShieldConsumedNotification) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        appState.dismissShieldConsumedNotification();
        GamificationDialogs.showShieldConsumed(context, appState);
      });
    }
    if (appState.showStreakResetNotification) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        appState.dismissStreakResetNotification();
        GamificationDialogs.showStreakReset(context, appState);
      });
    }
    if (appState.showShieldEarnedNotification) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        appState.dismissShieldEarnedNotification();
        GamificationDialogs.showShieldEarned(context, appState);
      });
    }
    if (appState.showPrestigeNotification) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        appState.dismissPrestigeNotification();
        GamificationDialogs.showPrestigeStarEarned(context, appState);
      });
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.gamificationSettingsTitle)),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section 1: Activation Toggle Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: AppTheme.premiumCardDecoration(
                      context: context,
                      color: colors.surface,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AdaptiveCardHeader(
                          icon: Icons.sports_esports,
                          iconColor: AppTheme.accentAmber,
                          title: l10n.gamificationSettingsTitle,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          l10n.gamificationSettingsDesc,
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Material(
                          color: Colors.transparent,
                          child: SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              l10n.toggleGamification,
                              style: TextStyle(
                                color: colors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            activeThumbColor: AppTheme.accentEmerald,
                            activeTrackColor: AppTheme.accentEmerald.withValues(
                              alpha: 0.5,
                            ),
                            value: appState.gamificationEnabled,
                            onChanged: (bool val) {
                              appState.setGamificationEnabled(val);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Section 2: Developer Admin Tool Chest
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: AppTheme.premiumCardDecoration(
                      context: context,
                      color: colors.surface,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AdaptiveCardHeader(
                          icon: Icons.developer_mode,
                          iconColor: AppTheme.accentBlue,
                          title: l10n.adminTriggersTitle,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          l10n.adminTriggersDesc,
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Dynamically calculated wrap grid preventing overlaps
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final double buttonWidth =
                                constraints.maxWidth > 500
                                ? (constraints.maxWidth - 20) / 3
                                : (constraints.maxWidth - 10) / 2;

                            final buttons = [
                              AdminButton(
                                label: l10n.btnTriggerConfetti,
                                icon: Icons.celebration,
                                color: AppTheme.accentEmerald,
                                onPressed: appState.triggerAdminConfetti,
                              ),
                              AdminButton(
                                label: l10n.btnTriggerLevelUp,
                                icon: Icons.upgrade,
                                color: Colors.amber,
                                onPressed: appState.triggerAdminLevelUp,
                              ),
                              AdminButton(
                                label: l10n.btnTriggerBadgeZund,
                                icon: Icons.flash_on,
                                color: AppTheme.accentAmber,
                                onPressed: () =>
                                    appState.triggerAdminBadge('zundfunke'),
                              ),
                              AdminButton(
                                label: l10n.btnTriggerBadgeThree,
                                icon: Icons.local_fire_department,
                                color: AppTheme.accentRed,
                                onPressed: () => appState.triggerAdminBadge(
                                  'dreifache_disziplin',
                                ),
                              ),
                              AdminButton(
                                label: l10n.btnTriggerBadgeWeek,
                                icon: Icons.emoji_events,
                                color: Colors.yellow.shade700,
                                onPressed: () =>
                                    appState.triggerAdminBadge('wochen_koenig'),
                              ),
                              AdminButton(
                                label: l10n.btnTriggerShieldEarn,
                                icon: Icons.shield,
                                color: AppTheme.accentBlue,
                                onPressed: appState.triggerAdminShieldEarned,
                              ),
                              AdminButton(
                                label: l10n.btnTriggerShieldCons,
                                icon: Icons.shield_outlined,
                                color: AppTheme.accentAmber,
                                onPressed: appState.triggerAdminShieldConsumed,
                              ),
                              AdminButton(
                                label: l10n.btnTriggerStreakReset,
                                icon: Icons.explore_off,
                                color: colors.textSecondary,
                                onPressed: appState.triggerAdminStreakReset,
                              ),
                              AdminButton(
                                label: l10n.btnTriggerPrestige,
                                icon: Icons.star,
                                color: Colors.purple,
                                onPressed: appState.triggerAdminPrestige,
                              ),
                              AdminButton(
                                label: l10n.btnResetAckBadges,
                                icon: Icons.refresh,
                                color: AppTheme.accentRed,
                                onPressed:
                                    appState.resetAdminAcknowledgedBadges,
                              ),
                            ];

                            return Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: buttons
                                  .map(
                                    (b) => SizedBox(
                                      width: buttonWidth,
                                      height: 62,
                                      child: b,
                                    ),
                                  )
                                  .toList(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (appState.showConfetti)
            Positioned.fill(
              child: IgnorePointer(
                child: ConfettiWidget(
                  onFinished: () {
                    appState.clearConfetti();
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
