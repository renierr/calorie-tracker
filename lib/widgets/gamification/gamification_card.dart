import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/theme.dart';
import '../../providers/app_state.dart';
import '../../l10n/app_localizations.dart';
import '../../pages/achievements_page.dart';

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
                          ? '${appState.getLevelTitle(currentLevel, context)}${AppLocalizations.of(context)!.prestigeStarsLabel(stats.prestigeStars)}'
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

              // Badges trigger button -> opens dedicated AchievementsPage
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AchievementsPage()),
                  );
                },
                icon: const Icon(
                  Icons.emoji_events,
                  color: AppTheme.accentAmber,
                  size: 26,
                ),
                tooltip: AppLocalizations.of(context)!.achievementsTitle,
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
}
