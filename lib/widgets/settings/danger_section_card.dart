import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/theme.dart';
import '../../providers/app_state.dart';
import '../../l10n/app_localizations.dart';
import '../../helpers/db_restore_helper.dart';
import '../../helpers/settings_restore_helper.dart';
import '../adaptive/adaptive_card_header.dart';
import '../adaptive/responsive_icon_button.dart';

class DangerSectionCard extends StatelessWidget {
  const DangerSectionCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.premiumCardDecoration(
        context: context,
        color: colors.surface,
        glowColor: AppTheme.accentRed,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdaptiveCardHeader(
            icon: Icons.dangerous,
            iconColor: AppTheme.accentRed,
            title: l10n.dangerZone,
          ),
          const SizedBox(height: 10),
          Text(
            l10n.dangerDesc,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ResponsiveIconButton(
              icon: const Icon(Icons.delete_forever, color: AppTheme.accentRed),
              label: l10n.clearHistory,
              color: AppTheme.accentRed,
              onPressed: () => _confirmEraseAll(context),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ResponsiveIconButton(
              icon: const Icon(
                Icons.settings_backup_restore,
                color: AppTheme.accentRed,
              ),
              label: l10n.restoreDbBtn,
              color: AppTheme.accentRed,
              onPressed: () => DbRestoreHelper.handleRestoreFlow(
                context,
                context.read<AppState>(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ResponsiveIconButton(
              icon: const Icon(Icons.settings, color: AppTheme.accentRed),
              label: l10n.restoreSettingsBtn,
              color: AppTheme.accentRed,
              onPressed: () => SettingsRestoreHelper.handleRestoreFlow(
                context,
                context.read<AppState>(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmEraseAll(BuildContext context) {
    final appState = context.read<AppState>();
    final colors = AppTheme.of(context);
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: colors.surface,
          title: Text(
            l10n.eraseAll,
            style: const TextStyle(
              color: AppTheme.accentRed,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(l10n.eraseAllDesc),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                l10n.cancel,
                style: TextStyle(color: colors.textSecondary),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentRed,
              ),
              onPressed: () async {
                await appState.clearAllMeals();
                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(l10n.dbCleared)));
              },
              child: Text(l10n.permanentlyErase),
            ),
          ],
        );
      },
    );
  }
}
