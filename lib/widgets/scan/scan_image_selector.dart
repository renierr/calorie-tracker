import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../l10n/app_localizations.dart';

class ScanImageSelector extends StatelessWidget {
  final Uint8List? imageBytes;
  final VoidCallback onPickGallery;
  final VoidCallback onPickCamera;
  final VoidCallback onClear;
  final VoidCallback onLogManually;
  final bool showForm;

  const ScanImageSelector({
    super.key,
    required this.imageBytes,
    required this.onPickGallery,
    required this.onPickCamera,
    required this.onClear,
    required this.onLogManually,
    required this.showForm,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context);
    return Container(
      width: double.infinity,
      height: 260,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: imageBytes == null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_a_photo_outlined,
                  color: colors.textSecondary.withValues(alpha: 0.5),
                  size: 48,
                ),
                const SizedBox(height: 14),
                Text(
                  AppLocalizations.of(context)!.noPhotoSelected,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  AppLocalizations.of(context)!.scanPrompt,
                  style: TextStyle(color: colors.textMuted, fontSize: 12),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.photo_library),
                      label: Text(AppLocalizations.of(context)!.gallery),
                      onPressed: onPickGallery,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.surfaceLight,
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.camera_alt),
                      label: Text(AppLocalizations.of(context)!.camera),
                      onPressed: onPickCamera,
                    ),
                  ],
                ),
                if (!showForm) ...[
                  const SizedBox(height: 12),
                  TextButton.icon(
                    icon: const Icon(
                      Icons.edit_note,
                      color: AppTheme.accentEmerald,
                    ),
                    label: Text(
                      AppLocalizations.of(context)!.logManually,
                      style: const TextStyle(color: AppTheme.accentEmerald),
                    ),
                    onPressed: onLogManually,
                  ),
                ],
              ],
            )
          : Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.memory(
                    imageBytes!,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: FloatingActionButton.small(
                    backgroundColor: Colors.black.withValues(alpha: 0.6),
                    onPressed: onClear,
                    child: const Icon(Icons.close, color: Colors.white),
                  ),
                ),
              ],
            ),
    );
  }
}
