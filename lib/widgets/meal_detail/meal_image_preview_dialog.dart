import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pasteboard/pasteboard.dart';
import '../../models/meal_model.dart';
import '../../theme/theme.dart';
import '../../helpers/file_save_helper.dart';
import '../../l10n/app_localizations.dart';
import '../custom_notification.dart';

class MealImagePreviewDialog extends StatefulWidget {
  final Meal currentMeal;
  final List<File> tempFilesToDelete;

  const MealImagePreviewDialog({
    super.key,
    required this.currentMeal,
    required this.tempFilesToDelete,
  });

  @override
  State<MealImagePreviewDialog> createState() => _MealImagePreviewDialogState();
}

class _MealImagePreviewDialogState extends State<MealImagePreviewDialog> {
  bool _isDownloading = false;
  bool _isSharing = false;

  @override
  Widget build(BuildContext context) {
    // Detect original format (JPEG, PNG, WebP) from magic bytes
    String extension = 'png';
    String mimeType = 'image/png';
    final bytes = widget.currentMeal.imageBytes;
    if (bytes != null && bytes.length > 4) {
      if (bytes[0] == 0xFF && bytes[1] == 0xD8) {
        extension = 'jpg';
        mimeType = 'image/jpeg';
      } else if (bytes[0] == 0x89 &&
          bytes[1] == 0x50 &&
          bytes[2] == 0x4E &&
          bytes[3] == 0x47) {
        extension = 'png';
        mimeType = 'image/png';
      } else if (bytes[0] == 0x52 &&
          bytes[1] == 0x49 &&
          bytes[2] == 0x46 &&
          bytes[3] == 0x47) {
        extension = 'webp';
        mimeType = 'image/webp';
      }
    }

    Future<void> downloadImage() async {
      if (_isDownloading) return;
      setState(() {
        _isDownloading = true;
      });
      try {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final localizations = AppLocalizations.of(context)!;
        await FileSaveHelper.saveFile(
          context: context,
          suggestedName:
              'meal_image_${widget.currentMeal.shortId}_$timestamp.$extension',
          acceptedTypeGroups: <XTypeGroup>[
            XTypeGroup(
              label: '${extension.toUpperCase()} Image',
              extensions: extension == 'jpg'
                  ? <String>['jpg', 'jpeg']
                  : <String>[extension],
            ),
          ],
          bytes: widget.currentMeal.imageBytes!,
          successMessageAndroid: localizations.imageSavedDownloads,
          successMessageGeneralBuilder: (displayPath) =>
              localizations.imageSavedTo(displayPath),
          errorMessageBuilder: (e) => localizations.imageSaveFailed(e),
        );
      } catch (e) {
        debugPrint("Error downloading raw image: $e");
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error: $e"),
              backgroundColor: AppTheme.accentRed,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isDownloading = false;
          });
        }
      }
    }

    Future<void> shareImage() async {
      if (_isSharing) return;
      setState(() {
        _isSharing = true;
      });
      try {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final Directory tempDir = await getTemporaryDirectory();
        final String tempPath =
            '${tempDir.path}/meal_image_${widget.currentMeal.shortId}_$timestamp.$extension';
        final File tempFile = File(tempPath);
        await tempFile.writeAsBytes(widget.currentMeal.imageBytes!);
        widget.tempFilesToDelete.add(tempFile);

        await FileSaveHelper.shareFile(tempPath, mimeType);
      } catch (e) {
        debugPrint("Error sharing raw image: $e");
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error: $e"),
              backgroundColor: AppTheme.accentRed,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSharing = false;
          });
        }
      }
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          GestureDetector(
            onLongPress: () async {
              try {
                await Pasteboard.writeImage(widget.currentMeal.imageBytes!);
                if (context.mounted) {
                  final l10n = AppLocalizations.of(context)!;
                  showNotificationDialog(
                    context,
                    l10n.imageCopiedToClipboard,
                    isError: false,
                  );
                }
              } catch (e) {
                debugPrint("Failed to copy image to clipboard: $e");
                if (context.mounted) {
                  final l10n = AppLocalizations.of(context)!;
                  showNotificationDialog(
                    context,
                    l10n.failedToCopyImage(e.toString()),
                    isError: true,
                  );
                }
              }
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: InteractiveViewer(
                child: Image.memory(
                  widget.currentMeal.imageBytes!,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Positioned(
            top: 8,
            left: 8,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton.small(
                  heroTag: 'download_preview_${widget.currentMeal.id}',
                  backgroundColor: Colors.black54,
                  onPressed: _isDownloading ? null : downloadImage,
                  child: _isDownloading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.download, color: Colors.white),
                ),
                const SizedBox(width: 8),
                FloatingActionButton.small(
                  heroTag: 'share_preview_${widget.currentMeal.id}',
                  backgroundColor: Colors.black54,
                  onPressed: _isSharing ? null : shareImage,
                  child: _isSharing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.share, color: Colors.white),
                ),
              ],
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: FloatingActionButton.small(
              heroTag: 'close_preview_${widget.currentMeal.id}',
              backgroundColor: Colors.black54,
              onPressed: () => Navigator.pop(context),
              child: const Icon(Icons.close, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
