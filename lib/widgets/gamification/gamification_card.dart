import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/theme.dart';
import '../../providers/app_state.dart';
import '../../l10n/app_localizations.dart';

class GamificationCard extends StatelessWidget {
  const GamificationCard({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final colors = AppTheme.of(context);
    final stats = appState.gamificationStats;

    final int currentLevel = stats.level;
    final int currentXp = stats.xp;

    final int baseXp = appState.getXpThreshold(currentLevel);
    final int nextXp = appState.getXpThreshold(currentLevel + 1);

    double progress = 0.0;
    int xpInLevel = 0;
    int xpNeededForNext = 0;

    if (currentLevel >= 10) {
      xpInLevel = stats.prestigeXpProgress;
      xpNeededForNext = 1000;
      progress = (xpInLevel / 1000.0).clamp(0.0, 1.0);
    } else {
      final int range = nextXp - baseXp;
      xpInLevel = currentXp - baseXp;
      xpNeededForNext = range;
      progress = range > 0 ? (xpInLevel / range).clamp(0.0, 1.0) : 0.0;
    }

    final bool hasActiveStreak = stats.currentStreak >= 3;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: AppTheme.premiumCardDecoration(
        context: context,
        showGlow: hasActiveStreak,
        glowColor: AppTheme.accentAmber,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Level, Streak, Shields
          Row(
            children: [
              // Circular level avatar with premium double border
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppTheme.accentPurple, AppTheme.accentBlue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accentPurple.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  '$currentLevel',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Level Name and XP summary
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stats.prestigeStars > 0
                          ? '${appState.getLevelTitle(currentLevel, context)} (⭐ x${stats.prestigeStars})'
                          : appState.getLevelTitle(currentLevel, context),
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      AppLocalizations.of(context)!.xpLabel(currentXp),
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Badges trigger button
              IconButton(
                onPressed: () => _showBadgesSheet(context, appState),
                icon: const Icon(
                  Icons.emoji_events,
                  color: AppTheme.accentAmber,
                  size: 26,
                ),
                tooltip: AppLocalizations.of(context)!.badgesTitle,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Custom linear progress bar with modern gradient
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  children: [
                    Container(
                      height: 10,
                      width: double.infinity,
                      color: colors.surfaceLight,
                    ),
                    FractionallySizedBox(
                      widthFactor: progress,
                      child: Container(
                        height: 10,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.accentBlue,
                              AppTheme.accentEmerald,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.levelLabel(currentLevel),
                    style: TextStyle(
                      color: colors.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (currentLevel < 10)
                    Text(
                      AppLocalizations.of(
                        context,
                      )!.xpToNextLevel(xpNeededForNext - xpInLevel),
                      style: TextStyle(
                        color: colors.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  else
                    Text(
                      AppLocalizations.of(
                        context,
                      )!.xpToNextStar(xpNeededForNext - xpInLevel),
                      style: const TextStyle(
                        color: AppTheme.accentAmber,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ],
          ),
          const Divider(height: 24, thickness: 0.5),

          // Stats row (Streak & Shield)
          LayoutBuilder(
            builder: (context, constraints) {
              final useVertical = constraints.maxWidth < 280;
              final widgets = [
                // Streak Widget
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: hasActiveStreak
                            ? AppTheme.accentAmber.withValues(alpha: 0.15)
                            : colors.surfaceLight,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.local_fire_department,
                        color: hasActiveStreak
                            ? AppTheme.accentAmber
                            : colors.textMuted,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(
                            context,
                          )!.currentStreakLabel(stats.currentStreak),
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          AppLocalizations.of(
                            context,
                          )!.highestStreakLabel(stats.highestStreak),
                          style: TextStyle(
                            color: colors.textMuted,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (!useVertical) const Spacer(),
                if (useVertical) const SizedBox(height: 12),

                // Shield Widget
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: stats.shields > 0
                            ? AppTheme.accentBlue.withValues(alpha: 0.15)
                            : colors.surfaceLight,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.shield,
                        color: stats.shields > 0
                            ? AppTheme.accentBlue
                            : colors.textMuted,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(
                            context,
                          )!.shieldsLabel(stats.shields),
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          AppLocalizations.of(context)!.streakProtection,
                          style: TextStyle(
                            color: colors.textMuted,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ];

              return useVertical
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: widgets,
                    )
                  : Row(children: widgets);
            },
          ),
          const Divider(height: 24, thickness: 0.5),
          Center(
            child: Text(
              AppLocalizations.of(context)!.xpHint,
              style: TextStyle(
                color: colors.textMuted,
                fontSize: 10,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  void _showBadgesSheet(BuildContext context, AppState appState) {
    final colors = AppTheme.of(context);
    final stats = appState.gamificationStats;
    final l10n = AppLocalizations.of(context)!;

    final badgeList = [
      _BadgeItem(
        id: 'zundfunke',
        title: l10n.badgeZundfunkeTitle,
        description: l10n.badgeZundfunkeDesc,
        icon: Icons.flash_on,
        color: AppTheme.accentAmber,
        isUnlocked: stats.unlockedBadges.contains('zundfunke'),
      ),
      _BadgeItem(
        id: 'dreifache_disziplin',
        title: l10n.badgeDreifacheDisziplinTitle,
        description: l10n.badgeDreifacheDisziplinDesc,
        icon: Icons.local_fire_department,
        color: AppTheme.accentRed,
        isUnlocked: stats.unlockedBadges.contains('dreifache_disziplin'),
      ),
      _BadgeItem(
        id: 'wochen_koenig',
        title: l10n.badgeWochenKoenigTitle,
        description: l10n.badgeWochenKoenigDesc,
        icon: Icons.emoji_events,
        color: Colors.amber,
        isUnlocked: stats.unlockedBadges.contains('wochen_koenig'),
      ),
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: colors.surfaceLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.badgesTitle,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: badgeList.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 16, thickness: 0.5),
                    itemBuilder: (context, index) {
                      final item = badgeList[index];
                      return Opacity(
                        opacity: item.isUnlocked ? 1.0 : 0.35,
                        child: Row(
                          children: [
                            Container(
                              width: 54,
                              height: 54,
                              decoration: BoxDecoration(
                                color: item.isUnlocked
                                    ? item.color.withValues(alpha: 0.15)
                                    : colors.surfaceLight,
                                shape: BoxShape.circle,
                                border: item.isUnlocked
                                    ? Border.all(color: item.color, width: 1.5)
                                    : null,
                              ),
                              child: Icon(
                                item.icon,
                                color: item.isUnlocked
                                    ? item.color
                                    : colors.textMuted,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        item.title,
                                        style: TextStyle(
                                          color: colors.textPrimary,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      if (item.isUnlocked)
                                        const Icon(
                                          Icons.check_circle,
                                          color: AppTheme.accentEmerald,
                                          size: 16,
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item.description,
                                    style: TextStyle(
                                      color: colors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
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

class _BadgeItem {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool isUnlocked;

  const _BadgeItem({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.isUnlocked,
  });
}
