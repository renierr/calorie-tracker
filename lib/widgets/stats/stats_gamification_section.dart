import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/stats_data.dart';
import '../adaptive/adaptive_card_header.dart';

class StatsGamificationSection extends StatelessWidget {
  final StatsData data;

  const StatsGamificationSection({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final g = data.gamification;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.premiumCardDecoration(
        context: context,
        color: colors.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdaptiveCardHeader(
            icon: Icons.emoji_events,
            iconColor: AppTheme.accentAmber,
            title: l10n.statsGamificationTitle,
          ),
          const SizedBox(height: 16),
          _row(l10n.statsLevel(g.level.toString(), data.levelTitle), colors),
          const SizedBox(height: 8),
          _row(l10n.statsXp(g.xp.toString()), colors),
          if (g.level < 10 || g.xp < 5400) ...[
            const SizedBox(height: 8),
            _row(l10n.statsXpToNext(data.xpToNext.toString()), colors),
          ],
          if (g.currentStreak > 0) ...[
            const SizedBox(height: 8),
            _row(l10n.statsStreak(g.currentStreak.toString()), colors),
          ],
          if (g.highestStreak > 0) ...[
            const SizedBox(height: 8),
            _row(l10n.statsBestStreak(g.highestStreak.toString()), colors),
          ],
          if (g.shields > 0) ...[
            const SizedBox(height: 8),
            _row(l10n.statsShields(g.shields.toString()), colors),
          ],
          if (g.prestigeStars > 0) ...[
            const SizedBox(height: 8),
            _row(l10n.statsPrestigeStars(g.prestigeStars.toString()), colors),
          ],
          _row(l10n.statsBadges(g.unlockedBadges.length.toString()), colors),
        ],
      ),
    );
  }

  Widget _row(String text, AppThemeColors colors) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: AppTheme.accentAmber,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: colors.textPrimary, fontSize: 13),
          ),
        ),
      ],
    );
  }
}
