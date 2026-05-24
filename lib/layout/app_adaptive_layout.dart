import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../pages/dashboard_page.dart';
import '../pages/history_page.dart';
import '../pages/scan_page.dart';
import '../pages/settings_page.dart';
import '../providers/app_state.dart';
import '../theme/theme.dart';
import 'adaptive_breakpoints.dart';

class AppAdaptiveLayout extends StatelessWidget {
  const AppAdaptiveLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final bool isDesktop = AppBreakpoints.isDesktopWidth(screenWidth);
    final bool useCompactNavLabels = AppBreakpoints.isCompactWidth(screenWidth);

    return Consumer<AppState>(
      builder: (context, appState, _) {
        final int currentIndex = appState.selectedTabIndex;
        final colors = AppTheme.of(context);

        if (isDesktop) {
          return Scaffold(
            body: Row(
              children: [
                Container(
                  width: 240,
                  decoration: BoxDecoration(
                    color: colors.surface,
                    border: Border(
                      right: BorderSide(color: colors.surfaceLight, width: 1),
                    ),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 30,
                          horizontal: 20,
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.accentEmerald.withValues(
                                  alpha: 0.15,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.local_fire_department,
                                color: AppTheme.accentEmerald,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'NutriScan',
                                  style: TextStyle(
                                    color: colors.textPrimary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                Text(
                                  'Calorie Tracker',
                                  style: TextStyle(
                                    color: colors.textMuted,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Divider(color: colors.surfaceLight, height: 1),
                      const SizedBox(height: 20),
                      _buildSidebarItem(
                        context: context,
                        index: 0,
                        currentIndex: currentIndex,
                        outlineIcon: Icons.dashboard_outlined,
                        filledIcon: Icons.dashboard,
                        label: AppLocalizations.of(context)!.sidebarDashboard,
                        onTap: appState.selectTab,
                      ),
                      _buildSidebarItem(
                        context: context,
                        index: 1,
                        currentIndex: currentIndex,
                        outlineIcon: Icons.qr_code_scanner_outlined,
                        filledIcon: Icons.qr_code_scanner,
                        label: AppLocalizations.of(context)!.sidebarScan,
                        onTap: appState.selectTab,
                      ),
                      _buildSidebarItem(
                        context: context,
                        index: 2,
                        currentIndex: currentIndex,
                        outlineIcon: Icons.history_outlined,
                        filledIcon: Icons.history,
                        label: AppLocalizations.of(context)!.sidebarHistory,
                        onTap: appState.selectTab,
                      ),
                      _buildSidebarItem(
                        context: context,
                        index: 3,
                        currentIndex: currentIndex,
                        outlineIcon: Icons.settings_outlined,
                        filledIcon: Icons.settings,
                        label: AppLocalizations.of(context)!.sidebarSettings,
                        onTap: appState.selectTab,
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppTheme.accentEmerald
                                  .withValues(alpha: 0.2),
                              child: const Text(
                                'ME',
                                style: TextStyle(
                                  color: AppTheme.accentEmerald,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.profileName,
                                  style: TextStyle(
                                    color: colors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  AppLocalizations.of(context)!.profileStatus,
                                  style: TextStyle(
                                    color: colors.textMuted,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(child: ClipRect(child: _buildPage(currentIndex))),
              ],
            ),
          );
        }

        return Scaffold(
          body: _buildPage(currentIndex),
          bottomNavigationBar: NavigationBar(
            selectedIndex: currentIndex,
            onDestinationSelected: (index) => appState.selectTab(index),
            destinations: [
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: AppLocalizations.of(context)!.navDashboard,
              ),
              NavigationDestination(
                icon: Icon(Icons.qr_code_scanner_outlined),
                selectedIcon: Icon(Icons.qr_code_scanner),
                label: AppLocalizations.of(context)!.navScan,
              ),
              NavigationDestination(
                icon: Icon(Icons.history_outlined),
                selectedIcon: Icon(Icons.history),
                label: AppLocalizations.of(context)!.navHistory,
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: useCompactNavLabels
                    ? AppLocalizations.of(context)!.navSettingsCompact
                    : AppLocalizations.of(context)!.navSettings,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return const DashboardPage();
      case 1:
        return const ScanPage();
      case 2:
        return const HistoryPage();
      case 3:
        return const SettingsPage();
      default:
        return const DashboardPage();
    }
  }

  Widget _buildSidebarItem({
    required BuildContext context,
    required int index,
    required int currentIndex,
    required IconData outlineIcon,
    required IconData filledIcon,
    required String label,
    required void Function(int) onTap,
  }) {
    final bool isSelected = currentIndex == index;
    final colors = AppTheme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: InkWell(
        onTap: () => onTap(index),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.accentEmerald.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? filledIcon : outlineIcon,
                color: isSelected
                    ? AppTheme.accentEmerald
                    : colors.textSecondary,
                size: 22,
              ),
              const SizedBox(width: 14),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? AppTheme.accentEmerald
                      : colors.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
