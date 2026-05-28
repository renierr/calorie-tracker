import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_selector/file_selector.dart';
import 'package:path_provider/path_provider.dart';
import '../widgets/custom_notification.dart';
import '../theme/theme.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../l10n/app_localizations.dart';

class FileSaveHelper {
  static const _channel = MethodChannel('de.renier.calorie_tracker/file_save');

  /// Resolves the save path for a file, writes [bytes] to it, and automatically
  /// handles the success or error notifications internally.
  /// On Android, uses MediaStore to save to public Downloads and posts a native notification.
  /// On Desktop, uses native Save As dialog and shows a premium interactive overlay.
  /// Returns the resolved save path, or null if cancelled or failed.
  static Future<String?> saveFile({
    required BuildContext context,
    required String suggestedName,
    Uint8List? bytes,
    List<XTypeGroup>? acceptedTypeGroups,
    String? successMessageAndroid,
    String Function(String displayPath)? successMessageGeneralBuilder,
    String Function(String error)? errorMessageBuilder,
  }) async {
    try {
      final appState = context.read<AppState>();
      final notificationsEnabled = appState.notificationsEnabled;
      String? destPath;
      final mimeType = _mimeTypeFromName(suggestedName);

      if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        final FileSaveLocation? location = await getSaveLocation(
          suggestedName: suggestedName,
          acceptedTypeGroups: acceptedTypeGroups ?? const <XTypeGroup>[],
        );
        if (location == null) return null;
        destPath = location.path;
        if (bytes != null) {
          final File file = File(destPath);
          await file.writeAsBytes(bytes);
        }

        if (context.mounted) {
          final displayPath = destPath.length > 40
              ? '...${destPath.substring(destPath.length - 37)}'
              : destPath;

          showSuccessDialog(
            context: context,
            displayPath: displayPath,
            actualPath: destPath,
            mimeType: mimeType,
            message:
                successMessageGeneralBuilder?.call(displayPath) ??
                "File saved to $displayPath",
          );
        }
      } else if (Platform.isAndroid) {
        if (bytes == null) return null;

        // Use MediaStore via platform channel for proper Downloads access (returns uri and filePath)
        final Map? result = await _channel.invokeMethod<Map>(
          'saveToDownloads',
          {'bytes': bytes, 'fileName': suggestedName, 'mimeType': mimeType},
        );

        if (result == null) return null;

        final uriString = result['uri'] as String?;
        final filePath = result['filePath'] as String?;
        destPath = filePath;

        if (context.mounted && uriString != null && filePath != null) {
          // Trigger native Android system notification
          if (notificationsEnabled) {
            try {
              await _channel.invokeMethod('showSystemNotification', {
                'fileName': suggestedName,
                'uri': uriString,
                'mimeType': mimeType,
              });
            } catch (e) {
              debugPrint("Failed to show native system notification: $e");
            }
          }

          // Show in-app premium success dialog
          if (context.mounted) {
            showSuccessDialog(
              context: context,
              displayPath: filePath,
              actualPath: uriString,
              mimeType: mimeType,
              message:
                  successMessageAndroid ?? "File saved to Downloads folder",
            );
          }
        }
      } else {
        // iOS or other platforms
        final Directory docDir = await getApplicationDocumentsDirectory();
        final File file = File('${docDir.path}/$suggestedName');
        if (bytes != null) {
          await file.writeAsBytes(bytes);
        }
        destPath = file.path;

        if (context.mounted) {
          final displayPath = destPath.length > 40
              ? '...${destPath.substring(destPath.length - 37)}'
              : destPath;

          showSuccessDialog(
            context: context,
            displayPath: displayPath,
            actualPath: destPath,
            mimeType: mimeType,
            message:
                successMessageGeneralBuilder?.call(displayPath) ??
                "File saved to $displayPath",
          );
        }
      }

      return destPath;
    } catch (e) {
      if (context.mounted) {
        showErrorNotification(
          context: context,
          errorMessage:
              errorMessageBuilder?.call(e.toString()) ??
              "Failed to save file: $e",
        );
      }
      return null;
    }
  }

  /// Opens the file using the default native system app.
  static Future<void> openFile(String path, String mimeType) async {
    try {
      if (Platform.isAndroid) {
        await _channel.invokeMethod('openFile', {
          'uri': path,
          'mimeType': mimeType,
        });
      } else if (Platform.isWindows) {
        await Process.run('explorer.exe', [path]);
      } else if (Platform.isMacOS) {
        await Process.run('open', [path]);
      } else if (Platform.isLinux) {
        await Process.run('xdg-open', [path]);
      }
    } catch (e) {
      debugPrint("Error opening file: $e");
    }
  }

  /// Shares the file natively, or opens the containing folder on Desktop.
  static Future<void> shareFile(String path, String mimeType) async {
    try {
      if (Platform.isAndroid) {
        await _channel.invokeMethod('shareFile', {
          'uri': path,
          'mimeType': mimeType,
        });
      } else if (Platform.isWindows) {
        // Select file in Windows Explorer
        await Process.run('explorer.exe', ['/select,', path]);
      } else if (Platform.isMacOS) {
        // Reveal file in Finder
        await Process.run('open', ['-R', path]);
      } else if (Platform.isLinux) {
        // Open containing directory on Linux
        final file = File(path);
        await Process.run('xdg-open', [file.parent.path]);
      }
    } catch (e) {
      debugPrint("Error sharing file: $e");
    }
  }

  /// Displays an interactive success dialog allowing the user to open or share/locate the exported file.
  static void showSuccessDialog({
    required BuildContext context,
    required String displayPath,
    required String actualPath,
    required String mimeType,
    required String message,
  }) {
    showDialog(
      context: context,
      barrierColor: Colors.black38,
      builder: (BuildContext ctx) {
        final colors = AppTheme.of(context);
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: AppTheme.premiumCardDecoration(
                  context: context,
                  color: colors.surface,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          color: AppTheme.accentEmerald,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Export Successful",
                            style: TextStyle(
                              color: colors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      message,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    if (Platform.isAndroid) ...[
                      const SizedBox(height: 12),
                      Consumer<AppState>(
                        builder: (context, appState, child) {
                          return Row(
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                  value: appState.notificationsEnabled,
                                  activeColor: AppTheme.accentEmerald,
                                  onChanged: (val) {
                                    if (val != null) {
                                      appState.setNotificationsEnabled(val);
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.enableNotifications,
                                  style: TextStyle(
                                    color: colors.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                          },
                          icon: Icon(
                            Icons.close,
                            size: 18,
                            color: colors.textSecondary,
                          ),
                          label: Text(
                            "Close",
                            style: TextStyle(color: colors.textSecondary),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () async {
                            Navigator.of(ctx).pop();
                            await openFile(actualPath, mimeType);
                          },
                          icon: const Icon(
                            Icons.open_in_new,
                            size: 18,
                            color: Colors.white,
                          ),
                          label: const Text(
                            "Open",
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentEmerald,
                            elevation: 0,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () async {
                            Navigator.of(ctx).pop();
                            await shareFile(actualPath, mimeType);
                          },
                          icon: const Icon(
                            Icons.share,
                            size: 18,
                            color: Colors.white,
                          ),
                          label: Text(
                            Platform.isWindows ? "Locate" : "Share",
                            style: const TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentBlue,
                            elevation: 0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Returns MIME type based on file extension.
  static String _mimeTypeFromName(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf':
        return 'application/pdf';
      case 'json':
        return 'application/json';
      case 'csv':
        return 'text/csv';
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      default:
        return 'application/octet-stream';
    }
  }

  /// Formats the success message and shows a custom notification dialog.
  /// (Kept for backwards compatibility if needed, but saveFile handles this now.)
  static void showSuccessNotification({
    required BuildContext context,
    required String savedPath,
    required String androidDownloadMessage,
    required String Function(String displayPath) generalMessageBuilder,
  }) {
    String message;
    if (Platform.isAndroid) {
      message = androidDownloadMessage;
    } else {
      final displayPath = savedPath.length > 40
          ? '...${savedPath.substring(savedPath.length - 37)}'
          : savedPath;
      message = generalMessageBuilder(displayPath);
    }

    showNotificationDialog(context, message, isError: false);
  }

  /// Shows an error notification dialog.
  /// (Kept for backwards compatibility, but saveFile handles this now.)
  static void showErrorNotification({
    required BuildContext context,
    required String errorMessage,
  }) {
    showNotificationDialog(context, errorMessage, isError: true);
  }
}
