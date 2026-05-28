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

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final double width = MediaQuery.of(context).size.width;
    final bool isWide = AppBreakpoints.isDesktopWidth(width);

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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Navigation Strip
              DateNavigationStrip(appState: appState),
              const SizedBox(height: 25),

              if (isWide) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: CalorieRingCard(appState: appState)),
                    const SizedBox(width: 20),
                    Expanded(child: MacrosProgressCard(appState: appState)),
                  ],
                ),
                const SizedBox(height: 20),
                TrendChartCard(appState: appState),
                const SizedBox(height: 20),
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
                // Today's Logs Quick List
                DayQuickLogsCard(appState: appState),
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
