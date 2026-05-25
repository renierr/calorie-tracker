import 'package:flutter/material.dart';
import '../adaptive/adaptive_card_header.dart';
import '../adaptive/responsive_icon_button.dart';
import '../../theme/theme.dart';
import '../../providers/app_state.dart';
import '../../l10n/app_localizations.dart';
import '../../helpers/file_save_helper.dart';

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
            child: ResponsiveIconButton(
              icon: const Icon(Icons.download, color: AppTheme.accentEmerald),
              label: AppLocalizations.of(context)!.exportDbBtn,
              color: AppTheme.accentEmerald,
              onPressed: _exportDbFlow,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportDbFlow() async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final localizations = AppLocalizations.of(context)!;
    try {
      final destPath = await FileSaveHelper.saveFile(
        suggestedName: 'nutriscan_db_$timestamp.db',
      );
      if (destPath == null) return;

      await widget.appState.exportDatabase(destPath: destPath);
      if (!mounted) return;

      FileSaveHelper.showSuccessNotification(
        context: context,
        savedPath: destPath,
        androidDownloadMessage: localizations.dbExportedDownloads,
        generalMessageBuilder: (displayPath) =>
            localizations.dbExportedTo(displayPath),
      );
    } catch (e) {
      if (!mounted) return;
      FileSaveHelper.showErrorNotification(
        context: context,
        errorMessage: localizations.dbExportFailed(e.toString()),
      );
    }
  }
}
