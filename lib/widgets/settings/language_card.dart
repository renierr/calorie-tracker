import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../providers/app_state.dart';
import '../../l10n/app_localizations.dart';

class LanguageCard extends StatelessWidget {
  final AppState appState;

  const LanguageCard({super.key, required this.appState});

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
          Row(
            children: [
              const Icon(
                Icons.language,
                color: AppTheme.accentEmerald,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                AppLocalizations.of(context)!.language,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
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
        ],
      ),
    );
  }
}
