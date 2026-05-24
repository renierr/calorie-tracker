import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import '../../theme/theme.dart';
import '../../providers/app_state.dart';
import '../../l10n/app_localizations.dart';

class ExportCard extends StatefulWidget {
  final AppState appState;

  const ExportCard({super.key, required this.appState});

  @override
  State<ExportCard> createState() => _ExportCardState();
}

class _ExportCardState extends State<ExportCard> {
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
              const Icon(Icons.backup, color: AppTheme.accentEmerald, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.exportDb,
                  maxLines: 2,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            AppLocalizations.of(context)!.exportDbDesc,
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
              icon: const Icon(Icons.download, color: AppTheme.accentEmerald),
              label: Text(
                AppLocalizations.of(context)!.exportDbBtn,
                style: const TextStyle(color: AppTheme.accentEmerald),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(
                  color: AppTheme.accentEmerald,
                  width: 1.2,
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: _exportDbFlow,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportDbFlow() async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final location = await getSaveLocation(
      suggestedName: 'nutriscan_db_$timestamp.db',
    );
    if (location == null) return;
    try {
      await widget.appState.exportDatabase(destPath: location.path);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.dbExported),
          backgroundColor: AppTheme.accentEmerald,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: $e'),
          backgroundColor: AppTheme.accentRed,
        ),
      );
    }
  }
}
