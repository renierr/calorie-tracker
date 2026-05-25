import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../adaptive/adaptive_card_header.dart';
import '../adaptive/responsive_icon_button.dart';
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
            child: ResponsiveIconButton(
              icon: const Icon(Icons.delete_forever, color: AppTheme.accentRed),
              label: AppLocalizations.of(context)!.clearHistory,
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
              label: AppLocalizations.of(context)!.restoreDbBtn,
              color: AppTheme.accentRed,
              onPressed: () => _handleRestoreFlow(context),
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

  Future<void> _handleRestoreFlow(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final localizations = AppLocalizations.of(context)!;

    try {
      String? selectedPath;

      if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        const XTypeGroup typeGroup = XTypeGroup(
          label: 'SQLite Databases',
          extensions: <String>['db'],
        );
        final XFile? file = await openFile(
          acceptedTypeGroups: <XTypeGroup>[typeGroup],
        );
        if (file == null) return;
        selectedPath = file.path;
      } else {
        final List<File> dbFiles = [];
        final List<Directory> dirsToScan = [];

        if (Platform.isAndroid) {
          final publicDownloadDir = Directory('/storage/emulated/0/Download');
          if (await publicDownloadDir.exists()) {
            dirsToScan.add(publicDownloadDir);
          }
          final extDir = await getExternalStorageDirectory();
          if (extDir != null && await extDir.exists()) {
            dirsToScan.add(extDir);
          }
        } else {
          final docDir = await getApplicationDocumentsDirectory();
          if (await docDir.exists()) {
            dirsToScan.add(docDir);
          }
        }

        for (final dir in dirsToScan) {
          try {
            final List<FileSystemEntity> files = await dir.list().toList();
            final List<File> found = files
                .whereType<File>()
                .where(
                  (file) =>
                      p.basename(file.path).startsWith('nutriscan_db_') &&
                      file.path.endsWith('.db'),
                )
                .toList();
            dbFiles.addAll(found);
          } catch (_) {
            // Silently swallow list permission errors for specific folders
          }
        }

        dbFiles.sort(
          (a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()),
        );

        if (dbFiles.isEmpty) {
          _showSnackBar(
            scaffoldMessenger,
            localizations.noBackupsFound,
            isError: true,
          );
          return;
        }

        if (!context.mounted) return;
        selectedPath = await _showFileSelectionDialog(context, dbFiles);
        if (selectedPath == null) return;
      }

      if (!context.mounted) return;
      final bool confirm = await _showConfirmRestoreDialog(context);
      if (!confirm) return;

      await appState.restoreDatabase(selectedPath);

      _showSnackBar(
        scaffoldMessenger,
        localizations.dbRestored,
        isError: false,
      );
    } catch (e) {
      _showSnackBar(scaffoldMessenger, 'Restore failed: $e', isError: true);
    }
  }

  Future<String?> _showFileSelectionDialog(
    BuildContext context,
    List<File> files,
  ) async {
    final colors = AppTheme.of(context);
    final localizations = AppLocalizations.of(context)!;

    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: colors.surface,
          title: Text(
            localizations.selectBackup,
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 250,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: files.length,
              itemBuilder: (context, index) {
                final file = files[index];
                final filename = p.basename(file.path);
                final stats = file.statSync();
                final sizeKb = (stats.size / 1024).toStringAsFixed(1);

                String displayDate = '';
                try {
                  final parts = filename.split('_');
                  if (parts.length >= 3) {
                    final timestampStr = parts[2].split('.').first;
                    final ts = int.parse(timestampStr);
                    final dt = DateTime.fromMillisecondsSinceEpoch(ts);
                    displayDate =
                        '${dt.day}.${dt.month}.${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
                  }
                } catch (_) {}

                return Card(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.03),
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    dense: true,
                    leading: const Icon(
                      Icons.backup,
                      color: AppTheme.accentEmerald,
                    ),
                    title: Text(
                      filename,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      displayDate.isNotEmpty
                          ? '$displayDate  •  $sizeKb KB'
                          : '$sizeKb KB',
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right, size: 16),
                    onTap: () {
                      Navigator.pop(context, file.path);
                    },
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                localizations.cancel,
                style: TextStyle(color: colors.textSecondary),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _showConfirmRestoreDialog(BuildContext context) async {
    final colors = AppTheme.of(context);
    final localizations = AppLocalizations.of(context)!;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: colors.surface,
          title: Row(
            children: [
              const Icon(Icons.warning, color: AppTheme.accentRed),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  localizations.confirmRestore,
                  style: const TextStyle(
                    color: AppTheme.accentRed,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Text(localizations.confirmRestoreDesc),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                localizations.cancel,
                style: TextStyle(color: colors.textSecondary),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentRed,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: Text(localizations.restoreDbBtn),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  void _showSnackBar(
    ScaffoldMessengerState scaffoldMessenger,
    String message, {
    required bool isError,
  }) {
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppTheme.accentRed : AppTheme.accentEmerald,
      ),
    );
  }
}
