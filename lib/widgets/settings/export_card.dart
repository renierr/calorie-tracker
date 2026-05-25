import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:path_provider/path_provider.dart';
import '../adaptive/adaptive_card_header.dart';
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
          AdaptiveCardHeader(
            icon: Icons.backup,
            iconColor: AppTheme.accentEmerald,
            title: AppLocalizations.of(context)!.exportDb,
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
    String? destPath;

    try {
      if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        final location = await getSaveLocation(
          suggestedName: 'nutriscan_db_$timestamp.db',
        );
        if (location == null) return;
        destPath = location.path;
      } else if (Platform.isAndroid) {
        final dir = await getExternalStorageDirectory();
        if (dir == null) throw Exception("External storage not available");
        destPath = '${dir.path}/nutriscan_db_$timestamp.db';
      } else {
        final dir = await getApplicationDocumentsDirectory();
        destPath = '${dir.path}/nutriscan_db_$timestamp.db';
      }

      await widget.appState.exportDatabase(destPath: destPath);
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
