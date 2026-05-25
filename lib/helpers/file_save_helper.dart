import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/widgets.dart';
import 'package:file_selector/file_selector.dart';
import 'package:path_provider/path_provider.dart';
import '../widgets/custom_notification.dart';

class FileSaveHelper {
  /// Resolves the save path for a file and optionally writes [bytes] to it.
  /// Checks for actual write access on Android before selecting a path.
  /// Returns the resolved save path, or null if the user cancelled (on Desktop).
  static Future<String?> saveFile({
    required String suggestedName,
    List<XTypeGroup>? acceptedTypeGroups,
    Uint8List? bytes,
  }) async {
    String? destPath;

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
    } else if (Platform.isAndroid) {
      final Directory publicDownloadDir = Directory(
        '/storage/emulated/0/Download',
      );
      File? savedFile;

      // 1. Try public Download folder with write check
      if (await publicDownloadDir.exists()) {
        try {
          final File file = File('${publicDownloadDir.path}/$suggestedName');
          if (bytes != null) {
            await file.writeAsBytes(bytes);
          } else {
            await file.writeAsString('temp');
            await file.delete();
          }
          savedFile = file;
        } catch (_) {
          // Silently swallow to fallback
        }
      }

      // 2. Fallback to external storage directory
      if (savedFile == null) {
        try {
          final Directory? appDir = await getExternalStorageDirectory();
          if (appDir != null) {
            final File file = File('${appDir.path}/$suggestedName');
            if (bytes != null) {
              await file.writeAsBytes(bytes);
            } else {
              await file.writeAsString('temp');
              await file.delete();
            }
            savedFile = file;
          }
        } catch (_) {
          // Silently swallow to fallback
        }
      }

      // 3. Fallback to app documents directory
      if (savedFile == null) {
        final Directory docDir = await getApplicationDocumentsDirectory();
        final File file = File('${docDir.path}/$suggestedName');
        if (bytes != null) {
          await file.writeAsBytes(bytes);
        }
        savedFile = file;
      }

      destPath = savedFile.path;
    } else {
      // iOS or other platforms
      final Directory docDir = await getApplicationDocumentsDirectory();
      final File file = File('${docDir.path}/$suggestedName');
      if (bytes != null) {
        await file.writeAsBytes(bytes);
      }
      destPath = file.path;
    }

    return destPath;
  }

  /// Formats the success message and shows a custom notification dialog.
  static void showSuccessNotification({
    required BuildContext context,
    required String savedPath,
    required String androidDownloadMessage,
    required String Function(String displayPath) generalMessageBuilder,
  }) {
    String message;
    if (Platform.isAndroid &&
        savedPath.startsWith('/storage/emulated/0/Download')) {
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
  static void showErrorNotification({
    required BuildContext context,
    required String errorMessage,
  }) {
    showNotificationDialog(context, errorMessage, isError: true);
  }
}
