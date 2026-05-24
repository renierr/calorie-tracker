import 'package:flutter/material.dart';
import '../theme/theme.dart';
import '../pages/dashboard_page.dart';
import '../pages/scan_page.dart';
import '../pages/history_page.dart';
import '../pages/settings_page.dart';

class ResponsiveLayout extends StatefulWidget {
  const ResponsiveLayout({super.key});

  @override
  State<ResponsiveLayout> createState() => _ResponsiveLayoutState();
}

class _ResponsiveLayoutState extends State<ResponsiveLayout> {
  int _currentIndex = 0;

  // The pages corresponding to the tabs
  final List<Widget> _pages = [
    const DashboardPage(),
    const ScanPage(),
    const HistoryPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth >= 800;

    if (isDesktop) {
      // Desktop Layout (Left sidebar navigation, content on the right)
      return Scaffold(
        body: Row(
          children: [
            // Sidebar Navigation
            Container(
              width: 240,
              decoration: const BoxDecoration(
                color: AppTheme.surface,
                border: Border(
                  right: BorderSide(color: Colors.white10, width: 1),
                ),
              ),
              child: Column(
                children: [
                  // App Branding Header
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.accentEmerald.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.local_fire_department,
                            color: AppTheme.accentEmerald,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Column(
                          cross: 0 ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                          children: [
                            Text(
                              'NutriScan',
                              style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              'Calorie Tracker',
                              style: TextStyle(
                                color: AppTheme.textMuted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Colors.white10, height: 1),
                  const SizedBox(height: 20),

                  // Sidebar Menu Items
                  _buildSidebarItem(0, Icons.dashboard_outlined, Icons.dashboard, 'Dashboard'),
                  _buildSidebarItem(1, Icons.qr_code_scanner_outlined, Icons.qr_code_scanner, 'AI Food Scan'),
                  _buildSidebarItem(2, Icons.history_outlined, Icons.history, 'Meal History'),
                  _buildSidebarItem(3, Icons.settings_outlined, Icons.settings, 'Goal Settings'),
                  
                  const Spacer(),
                  // User Profile or indicator
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppTheme.accentEmerald.withOpacity(0.2),
                          child: const Text('ME', style: TextStyle(color: AppTheme.accentEmerald, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 12),
                        const Column(
                          cross: CrossAxisAlignment.start,
                          children: [
                            Text('My Profile', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
                            Text('Offline User', style: TextStyle(color: AppTheme.textMuted, fontSize: 10)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Right Side Content
            Expanded(
              child: ClipRect(
                child: _pages[_currentIndex],
              ),
            ),
          ],
        ),
      );
    } else {
      // Mobile Layout (Scaffold with Bottom Navigation Bar)
      return Scaffold(
        body: _pages[_currentIndex],
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.qr_code_scanner_outlined),
              selectedIcon: Icon(Icons.qr_code_scanner),
              label: 'Scan',
            ),
            NavigationDestination(
              icon: Icon(Icons.history_outlined),
              selectedIcon: Icon(Icons.history),
              label: 'History',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      );
    }
  }

  // Helper widget to compile sidebar items
  Widget _buildSidebarItem(int index, IconData outlineIcon, IconData filledIcon, String label) {
    final bool isSelected = _currentIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: InkWell(
        onTap: () {
          setState(() {
            _currentIndex = index;
          });
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.accentEmerald.withOpacity(0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? filledIcon : outlineIcon,
                color: isSelected ? AppTheme.accentEmerald : AppTheme.textSecondary,
                size: 22,
              ),
              const SizedBox(width: 14),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppTheme.accentEmerald : AppTheme.textSecondary,
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
