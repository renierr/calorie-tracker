import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../adaptive/adaptive_card_header.dart';
import '../../theme/theme.dart';
import '../../providers/app_state.dart';
import '../../l10n/app_localizations.dart';

class LanguageThemeCard extends StatelessWidget {
  const LanguageThemeCard({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final colors = AppTheme.of(context);
    final localizations = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.premiumCardDecoration(
        context: context,
        color: colors.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section 1: Language
          AdaptiveCardHeader(
            icon: Icons.language,
            iconColor: AppTheme.accentEmerald,
            title: localizations.language,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: colors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: appState.appLocale,
                dropdownColor: colors.surface,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 'en', child: Text('English')),
                  DropdownMenuItem(value: 'de', child: Text('Deutsch')),
                ],
                onChanged: (val) {
                  if (val != null) appState.setLocale(val);
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          Divider(color: colors.surfaceLight, height: 1, thickness: 1.2),
          const SizedBox(height: 20),

          // Section 2: Appearance
          AdaptiveCardHeader(
            icon: Icons.palette,
            iconColor: AppTheme.accentAmber,
            title: localizations.appearance,
          ),
          const SizedBox(height: 12),
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
                    child: Text(localizations.themeSystem),
                  ),
                  DropdownMenuItem(
                    value: 'light',
                    child: Text(localizations.themeLight),
                  ),
                  DropdownMenuItem(
                    value: 'dark',
                    child: Text(localizations.themeDark),
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
