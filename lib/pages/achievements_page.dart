import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:calorie_tracker/l10n/app_localizations.dart';
import 'package:calorie_tracker/providers/app_state.dart';
import 'package:calorie_tracker/theme/theme.dart';
import 'package:calorie_tracker/widgets/gamification/badge_detail_dialog.dart';

class AchievementsPage extends StatefulWidget {
  const AchievementsPage({super.key});

  @override
  State<AchievementsPage> createState() => _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage> {
  String _filter = 'all'; // 'all', 'unlocked', 'locked'

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final appState = context.watch<AppState>();
    final stats = appState.gamificationStats;
    final colors = AppTheme.of(context);

    final allBadges = _getBadgeList(l10n, stats.unlockedBadges);
    final unlockedCount = allBadges.where((b) => b.isUnlocked).length;
    final totalCount = allBadges.length;
    final percent = totalCount == 0
        ? 0
        : ((unlockedCount / totalCount) * 100).round();

    final filteredBadges = allBadges.where((b) {
      if (_filter == 'unlocked') return b.isUnlocked;
      if (_filter == 'locked') return !b.isUnlocked;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          l10n.achievementsTitle,
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: colors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: colors.textPrimary),
      ),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header Summary Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.accentPurple.withValues(alpha: 0.2),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [
                                  AppTheme.accentPurple,
                                  AppTheme.accentBlue,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.accentPurple.withValues(
                                    alpha: 0.35,
                                  ),
                                  blurRadius: 10,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.emoji_events,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.achievementsTitle,
                                  style: TextStyle(
                                    color: colors.textPrimary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l10n.achievementsProgress(
                                    unlockedCount,
                                    totalCount,
                                    percent,
                                  ),
                                  style: TextStyle(
                                    color: colors.textSecondary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Progress Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: totalCount == 0
                              ? 0
                              : unlockedCount / totalCount,
                          minHeight: 10,
                          backgroundColor: colors.surfaceLight,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppTheme.accentEmerald,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Filter Chips (Horizontally Scrollable)
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    _buildFilterChip(
                      label: l10n.filterAll(totalCount),
                      value: 'all',
                      colors: colors,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      label: l10n.filterUnlocked(unlockedCount),
                      value: 'unlocked',
                      colors: colors,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      label: l10n.filterLocked(totalCount - unlockedCount),
                      value: 'locked',
                      colors: colors,
                    ),
                  ],
                ),
              ),
            ),

            const SliverPadding(padding: EdgeInsets.only(top: 16)),

            // Badges Grid
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _columnsFor(
                    MediaQuery.of(context).size.width,
                  ),
                  mainAxisExtent: 156,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final item = filteredBadges[index];
                  return _BadgeCard(item: item, colors: colors, l10n: l10n);
                }, childCount: filteredBadges.length),
              ),
            ),

            const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
          ],
        ),
      ),
    );
  }

  /// Keeps the badge tiles wide enough for title and description
  int _columnsFor(double width) {
    if (width > 1100) return 3;
    if (width > 700) return 2;
    return 1;
  }

  Widget _buildFilterChip({
    required String label,
    required String value,
    required AppThemeColors colors,
  }) {
    final isSelected = _filter == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _filter = value;
          });
        }
      },
      selectedColor: AppTheme.accentPurple,
      backgroundColor: colors.surface,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : colors.textSecondary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
    );
  }

  List<_AchievementItem> _getBadgeList(
    AppLocalizations l10n,
    List<String> unlockedBadges,
  ) {
    return [
      _AchievementItem(
        id: 'spark',
        title: l10n.badgeZundfunkeTitle,
        description: l10n.badgeZundfunkeDesc,
        icon: Icons.flash_on,
        color: AppTheme.accentAmber,
        isUnlocked: unlockedBadges.contains('spark'),
      ),
      _AchievementItem(
        id: 'triple_discipline',
        title: l10n.badgeDreifacheDisziplinTitle,
        description: l10n.badgeDreifacheDisziplinDesc,
        icon: Icons.local_fire_department,
        color: AppTheme.accentRed,
        isUnlocked: unlockedBadges.contains('triple_discipline'),
      ),
      _AchievementItem(
        id: 'week_king',
        title: l10n.badgeWochenKoenigTitle,
        description: l10n.badgeWochenKoenigDesc,
        icon: Icons.emoji_events,
        color: Colors.amber,
        isUnlocked: unlockedBadges.contains('week_king'),
      ),
      _AchievementItem(
        id: 'hundred_day_legend',
        title: l10n.badgeHunderterLegendeTitle,
        description: l10n.badgeHunderterLegendeDesc,
        icon: Icons.military_tech,
        color: Colors.deepOrange,
        isUnlocked: unlockedBadges.contains('hundred_day_legend'),
      ),
      _AchievementItem(
        id: 'year_titan',
        title: l10n.badgeJahresTitanTitle,
        description: l10n.badgeJahresTitanDesc,
        icon: Icons.workspace_premium,
        color: Colors.amber,
        isUnlocked: unlockedBadges.contains('year_titan'),
      ),
      _AchievementItem(
        id: 'diary_veteran',
        title: l10n.badgeTagebuchVeteranTitle,
        description: l10n.badgeTagebuchVeteranDesc,
        icon: Icons.menu_book,
        color: AppTheme.accentBlue,
        isUnlocked: unlockedBadges.contains('diary_veteran'),
      ),
      _AchievementItem(
        id: 'calorie_archivist',
        title: l10n.badgeKalorienArchivarTitle,
        description: l10n.badgeKalorienArchivarDesc,
        icon: Icons.inventory_2,
        color: Colors.indigo,
        isUnlocked: unlockedBadges.contains('calorie_archivist'),
      ),
      _AchievementItem(
        id: 'thousand_club',
        title: l10n.badgeTausenderClubTitle,
        description: l10n.badgeTausenderClubDesc,
        icon: Icons.stars,
        color: Colors.teal,
        isUnlocked: unlockedBadges.contains('thousand_club'),
      ),
      _AchievementItem(
        id: 'prestige_pioneer',
        title: l10n.badgePrestigePionierTitle,
        description: l10n.badgePrestigePionierDesc,
        icon: Icons.auto_awesome,
        color: Colors.purple,
        isUnlocked: unlockedBadges.contains('prestige_pioneer'),
      ),
      _AchievementItem(
        id: 'shield_collector',
        title: l10n.badgeSchildSammlerTitle,
        description: l10n.badgeSchildSammlerDesc,
        icon: Icons.shield,
        color: AppTheme.accentEmerald,
        isUnlocked: unlockedBadges.contains('shield_collector'),
      ),
      _AchievementItem(
        id: 'comeback_kid',
        title: l10n.badgeComebackKidTitle,
        description: l10n.badgeComebackKidDesc,
        icon: Icons.loop,
        color: Colors.amber,
        isUnlocked: unlockedBadges.contains('comeback_kid'),
      ),
      _AchievementItem(
        id: 'bullseye',
        title: l10n.badgePunktlandungTitle,
        description: l10n.badgePunktlandungDesc,
        icon: Icons.center_focus_strong,
        color: AppTheme.accentEmerald,
        isUnlocked: unlockedBadges.contains('bullseye'),
      ),
      _AchievementItem(
        id: 'protein_pro',
        title: l10n.badgeProteinProfiTitle,
        description: l10n.badgeProteinProfiDesc,
        icon: Icons.fitness_center,
        color: Colors.deepOrange,
        isUnlocked: unlockedBadges.contains('protein_pro'),
      ),
      _AchievementItem(
        id: 'macro_balance',
        title: l10n.badgeMakroAusgleichTitle,
        description: l10n.badgeMakroAusgleichDesc,
        icon: Icons.pie_chart,
        color: AppTheme.accentBlue,
        isUnlocked: unlockedBadges.contains('macro_balance'),
      ),
      _AchievementItem(
        id: 'burn_master',
        title: l10n.badgeBurnMasterTitle,
        description: l10n.badgeBurnMasterDesc,
        icon: Icons.local_fire_department,
        color: AppTheme.accentRed,
        isUnlocked: unlockedBadges.contains('burn_master'),
      ),
      _AchievementItem(
        id: 'fitness_knight',
        title: l10n.badgeFitnessRitterTitle,
        description: l10n.badgeFitnessRitterDesc,
        icon: Icons.directions_run,
        color: Colors.purple,
        isUnlocked: unlockedBadges.contains('fitness_knight'),
      ),
      _AchievementItem(
        id: 'photo_gourmet',
        title: l10n.badgeFotoGourmetTitle,
        description: l10n.badgeFotoGourmetDesc,
        icon: Icons.camera_alt,
        color: Colors.cyan,
        isUnlocked: unlockedBadges.contains('photo_gourmet'),
      ),
      _AchievementItem(
        id: 'favorite_chef',
        title: l10n.badgeFavoritenChefTitle,
        description: l10n.badgeFavoritenChefDesc,
        icon: Icons.favorite,
        color: Colors.pink,
        isUnlocked: unlockedBadges.contains('favorite_chef'),
      ),
      _AchievementItem(
        id: 'calorie_saver',
        title: l10n.badgeKalorienSparfuchsTitle,
        description: l10n.badgeKalorienSparfuchsDesc,
        icon: Icons.savings,
        color: Colors.lightGreen,
        isUnlocked: unlockedBadges.contains('calorie_saver'),
      ),
    ];
  }
}

class _AchievementItem {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool isUnlocked;

  _AchievementItem({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.isUnlocked,
  });
}

class _BadgeCard extends StatelessWidget {
  final _AchievementItem item;
  final AppThemeColors colors;
  final AppLocalizations l10n;

  const _BadgeCard({
    required this.item,
    required this.colors,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = item.isUnlocked ? item.color : colors.textMuted;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: item.isUnlocked
              ? activeColor.withValues(alpha: 0.3)
              : colors.surfaceLight,
          width: 1.5,
        ),
        boxShadow: item.isUnlocked
            ? [
                BoxShadow(
                  color: activeColor.withValues(alpha: 0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => BadgeDetailDialog.show(
            context,
            title: item.title,
            description: item.description,
            icon: item.icon,
            color: item.color,
            isUnlocked: item.isUnlocked,
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: _buildContent(context, colors, activeColor),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AppThemeColors colors,
    Color activeColor,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Icon Container
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: item.isUnlocked
                    ? activeColor.withValues(alpha: 0.15)
                    : colors.surfaceLight,
                border: Border.all(
                  color: item.isUnlocked
                      ? activeColor.withValues(alpha: 0.4)
                      : colors.surfaceLight,
                  width: 1.5,
                ),
              ),
              child: Icon(item.icon, color: activeColor, size: 26),
            ),
            if (!item.isUnlocked)
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.35),
                ),
                child: const Icon(Icons.lock, color: Colors.white70, size: 20),
              ),
          ],
        ),
        const SizedBox(width: 14),

        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                item.title,
                style: TextStyle(
                  color: item.isUnlocked
                      ? colors.textPrimary
                      : colors.textMuted,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Flexible(
                child: Text(
                  item.description,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 11,
                    height: 1.25,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 6),
              _StatusChip(
                isUnlocked: item.isUnlocked,
                colors: colors,
                l10n: l10n,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final bool isUnlocked;
  final AppThemeColors colors;
  final AppLocalizations l10n;

  const _StatusChip({
    required this.isUnlocked,
    required this.colors,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = isUnlocked ? AppTheme.accentEmerald : colors.textMuted;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isUnlocked
            ? AppTheme.accentEmerald.withValues(alpha: 0.15)
            : colors.surfaceLight,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isUnlocked ? Icons.check_circle : Icons.lock,
            color: color,
            size: 10,
          ),
          const SizedBox(width: 3),
          Text(
            isUnlocked ? l10n.badgeUnlockedStatus : l10n.badgeLockedStatus,
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
