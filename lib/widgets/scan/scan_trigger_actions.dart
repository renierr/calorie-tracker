import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../l10n/app_localizations.dart';

class ScanTriggerActions extends StatelessWidget {
  final bool hasApiKey;
  final VoidCallback onScanPressed;
  final VoidCallback onManualLogPressed;

  const ScanTriggerActions({
    super.key,
    required this.hasApiKey,
    required this.onScanPressed,
    required this.onManualLogPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context);
    final localizations = AppLocalizations.of(context)!;

    if (!hasApiKey) {
      return Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.premiumCardDecoration(
              context: context,
              glowColor: AppTheme.accentRed,
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: AppTheme.accentRed,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  localizations.apiKeyMissing,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  localizations.apiKeyMissingDesc,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colors.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(localizations.navigateToSettings)),
                    );
                  },
                  child: Text(localizations.configureApiKey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.edit_note, color: AppTheme.accentEmerald),
              label: Text(
                localizations.logWithPhoto,
                maxLines: 2,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.accentEmerald),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                side: const BorderSide(
                  color: AppTheme.accentEmerald,
                  width: 1.2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: onManualLogPressed,
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.auto_awesome),
            label: Text(
              localizations.scanAndEstimate,
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
            ),
            onPressed: onScanPressed,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.edit_note, color: AppTheme.accentEmerald),
            label: Text(
              localizations.logWithPhoto,
              maxLines: 2,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.accentEmerald),
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
              side: const BorderSide(color: AppTheme.accentEmerald, width: 1.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: onManualLogPressed,
          ),
        ),
      ],
    );
  }
}
