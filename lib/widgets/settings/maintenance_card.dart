import 'package:flutter/material.dart';
import '../adaptive/adaptive_card_header.dart';
import '../../theme/theme.dart';
import '../../providers/app_state.dart';
import '../../l10n/app_localizations.dart';

class MaintenanceCard extends StatelessWidget {
  final AppState appState;

  const MaintenanceCard({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context);
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
            title: AppLocalizations.of(context)!.dangerZone,
          ),
          const SizedBox(height: 10),
          Text(
            AppLocalizations.of(context)!.dangerDesc,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.delete_forever, color: AppTheme.accentRed),
              label: Text(
                AppLocalizations.of(context)!.clearHistory,
                style: const TextStyle(color: AppTheme.accentRed),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.accentRed, width: 1.2),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => _confirmEraseAll(context),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmEraseAll(BuildContext context) {
    final colors = AppTheme.of(context);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: colors.surface,
          title: Text(
            AppLocalizations.of(context)!.eraseAll,
            style: const TextStyle(
              color: AppTheme.accentRed,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(AppLocalizations.of(context)!.eraseAllDesc),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                AppLocalizations.of(context)!.cancel,
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)!.dbCleared),
                  ),
                );
              },
              child: Text(AppLocalizations.of(context)!.permanentlyErase),
            ),
          ],
        );
      },
    );
  }
}
