import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../theme/theme.dart';
import '../providers/app_state.dart';
import '../l10n/app_localizations.dart';

class SettingsRestoreHelper {
  static Future<void> handleRestoreFlow(
    BuildContext context,
    AppState appState,
  ) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final localizations = AppLocalizations.of(context)!;

    try {
      String? selectedPath;

      if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        const XTypeGroup typeGroup = XTypeGroup(
          label: 'JSON Settings',
          extensions: <String>['json'],
        );
        final XFile? file = await openFile(
          acceptedTypeGroups: <XTypeGroup>[typeGroup],
        );
        if (file == null) return;
        selectedPath = file.path;
      } else {
        final List<File> settingsFiles = [];
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
                      p.basename(file.path).startsWith('nutriscan_settings_') &&
                      file.path.endsWith('.json'),
                )
                .toList();
            settingsFiles.addAll(found);
          } catch (e) {
            debugPrint('List settings backup directory failed: $e');
          }
        }

        settingsFiles.sort(
          (a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()),
        );

        if (settingsFiles.isEmpty) {
          _showSnackBar(
            scaffoldMessenger,
            localizations.noSettingsBackupsFound,
            isError: true,
          );
          return;
        }

        if (!context.mounted) return;
        selectedPath = await _showSettingsFileSelectionDialog(
          context,
          settingsFiles,
        );
        if (selectedPath == null) return;
      }

      if (!context.mounted) return;
      final bool confirm = await _showConfirmRestoreSettingsDialog(context);
      if (!confirm) return;

      final file = File(selectedPath);
      final jsonContent = await file.readAsString();
      await appState.importSettingsFromJson(jsonContent);

      _showSnackBar(
        scaffoldMessenger,
        localizations.settingsRestored,
        isError: false,
      );
    } catch (e) {
      _showSnackBar(
        scaffoldMessenger,
        localizations.settingsImportFailed(e.toString()),
        isError: true,
      );
    }
  }

  static Future<String?> _showSettingsFileSelectionDialog(
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
            localizations.selectSettingsBackup,
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
                } catch (e) {
                  debugPrint('Parse settings backup timestamp failed: $e');
                }

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
                      Icons.settings_backup_restore,
                      color: AppTheme.accentBlue,
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

  static Future<bool> _showConfirmRestoreSettingsDialog(
    BuildContext context,
  ) async {
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
                  localizations.confirmRestoreSettings,
                  style: const TextStyle(
                    color: AppTheme.accentRed,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Text(localizations.confirmRestoreSettingsDesc),
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
              child: Text(localizations.restoreSettingsBtn),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  static void _showSnackBar(
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
