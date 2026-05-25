import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:path_provider/path_provider.dart';
import '../adaptive/adaptive_card_header.dart';
import '../adaptive/responsive_icon_button.dart';
import '../../theme/theme.dart';
import '../../providers/app_state.dart';
import '../../l10n/app_localizations.dart';
import '../custom_notification.dart';

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
    String? destPath;

    try {
      if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        final location = await getSaveLocation(
          suggestedName: 'nutriscan_db_$timestamp.db',
        );
        if (location == null) return;
        destPath = location.path;
      } else if (Platform.isAndroid) {
        final String fileName = 'nutriscan_db_$timestamp.db';
        final Directory publicDownloadDir = Directory('/storage/emulated/0/Download');

        // 1. Try public Download folder
        if (await publicDownloadDir.exists()) {
          try {
            final File file = File('${publicDownloadDir.path}/$fileName');
            // Check if we can write to it by writing a dummy byte or just copying.
            // exportDatabase will do the actual write. We assign the path first.
            destPath = file.path;
          } catch (_) {
            destPath = null;
          }
        }

        // 2. Fallback to external storage directory
        if (destPath == null) {
          try {
            final Directory? appDir = await getExternalStorageDirectory();
            if (appDir != null) {
              destPath = '${appDir.path}/$fileName';
            }
          } catch (_) {
            destPath = null;
          }
        }

        // 3. Fallback to app documents directory
        if (destPath == null) {
          final Directory docDir = await getApplicationDocumentsDirectory();
          destPath = '${docDir.path}/$fileName';
        }
      } else {
        // iOS or other platforms
        final Directory dir = await getApplicationDocumentsDirectory();
        destPath = '${dir.path}/nutriscan_db_$timestamp.db';
      }

      await widget.appState.exportDatabase(destPath: destPath);
      if (!mounted) return;

      String message;
      if (Platform.isAndroid && destPath.startsWith('/storage/emulated/0/Download')) {
        message = localizations.dbExportedDownloads;
      } else {
        final displayPath = destPath.length > 40
            ? '...${destPath.substring(destPath.length - 37)}'
            : destPath;
        message = localizations.dbExportedTo(displayPath);
      }

      showNotificationDialog(context, message, isError: false);
    } catch (e) {
      if (!mounted) return;
      showNotificationDialog(
        context,
        localizations.dbExportFailed(e.toString()),
        isError: true,
      );
    }
  }
}
