import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    final bool isWide = width >= 800;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.dashboardTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => appState.loadMeals(),
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

              // Layout Grid - Responsive for Mobile vs Desktop
              isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Column: Progress Circle and Macros
                        Expanded(
                          flex: 1,
                          child: Column(
                            children: [
                              CalorieRingCard(appState: appState),
                              const SizedBox(height: 20),
                              MacrosProgressCard(appState: appState),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        // Right Column: Trend Chart and Today's Meal Quick Logs
                        Expanded(
                          flex: 1,
                          child: Column(
                            children: [
                              TrendChartCard(appState: appState),
                              const SizedBox(height: 20),
                              DayQuickLogsCard(appState: appState),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
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
                    ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
