import 'package:flutter/material.dart';
import '../adaptive/adaptive_card_header.dart';
import '../../theme/theme.dart';
import '../../providers/app_state.dart';
import '../../l10n/app_localizations.dart';

class ThemeCard extends StatelessWidget {
  final AppState appState;

  const ThemeCard({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context);
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
            icon: Icons.palette,
            iconColor: AppTheme.accentAmber,
            title: AppLocalizations.of(context)!.appearance,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: colors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _themeModeValue(appState),
                dropdownColor: colors.surface,
                isExpanded: true,
                items: [
                  DropdownMenuItem(
                    value: 'system',
                    child: Text(AppLocalizations.of(context)!.themeSystem),
                  ),
                  DropdownMenuItem(
                    value: 'light',
                    child: Text(AppLocalizations.of(context)!.themeLight),
                  ),
                  DropdownMenuItem(
                    value: 'dark',
                    child: Text(AppLocalizations.of(context)!.themeDark),
                  ),
                ],
                onChanged: (val) {
                  if (val == 'light') {
                    appState.setThemeMode(ThemeMode.light);
                  } else if (val == 'dark') {
                    appState.setThemeMode(ThemeMode.dark);
                  } else {
                    appState.setThemeMode(ThemeMode.system);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _themeModeValue(AppState appState) {
    switch (appState.themeMode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      default:
        return 'system';
    }
  }
}
