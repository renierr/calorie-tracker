import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../l10n/app_localizations.dart';
import '../adaptive/adaptive_action_group.dart';

class HistoryDataActionsCard extends StatelessWidget {
  final VoidCallback onImportPressed;
  final VoidCallback onExportPressed;
  final VoidCallback onReportPressed;

  const HistoryDataActionsCard({
    super.key,
    required this.onImportPressed,
    required this.onExportPressed,
    required this.onReportPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context);
    final localizations = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: AppTheme.premiumCardDecoration(
        context: context,
        color: colors.surface,
      ),
      child: AdaptiveActionGroup(
        spacing: 10,
        actions: [
          OutlinedButton.icon(
            icon: const Icon(
              Icons.upload,
              size: 18,
              color: AppTheme.accentEmerald,
            ),
            label: Text(
              localizations.importLabel,
              maxLines: 2,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.accentEmerald,
                fontSize: 13,
              ),
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(44),
              side: const BorderSide(color: AppTheme.accentEmerald, width: 1.2),
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: onImportPressed,
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.download, size: 18),
            label: Text(
              localizations.exportLabel,
              maxLines: 2,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13),
            ),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(44),
              backgroundColor: AppTheme.accentEmerald,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: onExportPressed,
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.summarize, size: 18),
            label: Text(
              localizations.reportPdf,
              maxLines: 2,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13),
            ),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(44),
              backgroundColor: AppTheme.accentEmerald,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: onReportPressed,
          ),
        ],
      ),
    );
  }
}
