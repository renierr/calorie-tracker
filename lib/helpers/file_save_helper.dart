import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:file_selector/file_selector.dart';
import 'package:path_provider/path_provider.dart';
import '../widgets/custom_notification.dart';

class FileSaveHelper {
  static const _channel = MethodChannel('de.renier.calorie_tracker/file_save');

  /// Resolves the save path for a file and optionally writes [bytes] to it.
  /// On Android, uses MediaStore to save to public Downloads folder.
  /// On Desktop, uses native Save As dialog.
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
      if (bytes == null) return null;

      // Determine MIME type from file extension
      final mimeType = _mimeTypeFromName(suggestedName);

      // Use MediaStore via platform channel for proper Downloads access
      destPath = await _channel.invokeMethod<String>('saveToDownloads', {
        'bytes': bytes,
        'fileName': suggestedName,
        'mimeType': mimeType,
      });
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

  /// Returns MIME type based on file extension.
  static String _mimeTypeFromName(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf':
        return 'application/pdf';
      case 'db':
      case 'sqlite':
        return 'application/x-sqlite3';
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
  static void showErrorNotification({
    required BuildContext context,
    required String errorMessage,
  }) {
    showNotificationDialog(context, errorMessage, isError: true);
  }
}
