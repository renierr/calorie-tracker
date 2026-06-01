import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../layout/adaptive_breakpoints.dart';
import '../providers/app_state.dart';
import '../l10n/app_localizations.dart';
import '../widgets/dashboard/date_navigation_strip.dart';
import '../widgets/dashboard/calorie_ring_card.dart';
import '../widgets/dashboard/macros_progress_card.dart';
import '../widgets/dashboard/trend_chart_card.dart';
import '../widgets/dashboard/day_quick_logs_card.dart';
import '../widgets/gamification/gamification_card.dart';
import '../widgets/gamification/gamification_dialogs.dart';
import '../widgets/gamification/confetti_widget.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  double? _dragStartX;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final double width = MediaQuery.of(context).size.width;
    final bool isWide = AppBreakpoints.isDesktopWidth(width);

    // Safe post-frame callback execution for overlays & achievements
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
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.dashboardTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              appState.loadMeals();
              if (appState.syncEnabled) {
                appState.syncWithBackend();
              }
            },
            tooltip: AppLocalizations.of(context)!.reloadDatabase,
          ),
        ],
      ),
      body: Stack(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragStart: (details) {
              _dragStartX = details.globalPosition.dx;
            },
            onHorizontalDragEnd: (details) {
              if (_dragStartX == null) return;

              final double screenWidth = MediaQuery.of(context).size.width;
              const double edgeMargin = 40.0;

              // Ignore drag starting near the left or right edges to avoid clashing with back gesture
              if (_dragStartX! < edgeMargin ||
                  _dragStartX! > screenWidth - edgeMargin) {
                _dragStartX = null;
                return;
              }

              if (details.primaryVelocity == null) return;
              if (details.primaryVelocity! > 100) {
                appState.previousDay();
              } else if (details.primaryVelocity! < -100) {
                appState.nextDay();
              }

              _dragStartX = null;
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date Navigation Strip
                    DateNavigationStrip(appState: appState),
                    const SizedBox(height: 20),

                    if (isWide) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: CalorieRingCard(appState: appState)),
                          const SizedBox(width: 20),
                          Expanded(
                            child: MacrosProgressCard(appState: appState),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      TrendChartCard(appState: appState),
                      const SizedBox(height: 20),
                      if (appState.gamificationEnabled) ...[
                        const GamificationCard(),
                        const SizedBox(height: 20),
                      ],
                      DayQuickLogsCard(appState: appState),
                    ] else ...[
                      // Calorie Ring Indicator
                      CalorieRingCard(appState: appState),
                      const SizedBox(height: 20),
                      // Macros Progress Slider
                      MacrosProgressCard(appState: appState),
                      const SizedBox(height: 20),
                      // 7 Day Calorie Trend
                      TrendChartCard(appState: appState),
                      const SizedBox(height: 20),
                      if (appState.gamificationEnabled) ...[
                        const GamificationCard(),
                        const SizedBox(height: 20),
                      ],
                      // Today's Logs Quick List
                      DayQuickLogsCard(appState: appState),
                    ],
                    const SizedBox(height: 20),
                  ],
                ),
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
