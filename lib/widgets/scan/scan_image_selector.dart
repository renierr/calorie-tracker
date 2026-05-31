import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:provider/provider.dart';
import '../../theme/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/app_state.dart';

class ScanImageSelector extends StatefulWidget {
  final Uint8List? imageBytes;
  final VoidCallback onPickGallery;
  final VoidCallback onPickCamera;
  final VoidCallback onClear;
  final VoidCallback onLogManually;
  final VoidCallback onLogActivity;
  final bool showForm;

  const ScanImageSelector({
    super.key,
    required this.imageBytes,
    required this.onPickGallery,
    required this.onPickCamera,
    required this.onClear,
    required this.onLogManually,
    required this.onLogActivity,
    required this.showForm,
  });

  @override
  State<ScanImageSelector> createState() => _ScanImageSelectorState();
}

class _ScanImageSelectorState extends State<ScanImageSelector> {
  bool _isDragging = false;

  Future<void> _pasteFromClipboard() async {
    try {
      final bytes = await Pasteboard.image;
      if (bytes != null) {
        if (mounted) {
          final appState = context.read<AppState>();
          await appState.handleIncomingImageBytes(bytes);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.noImageInClipboard),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to paste image: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context);

    if (widget.imageBytes == null) {
      return DropTarget(
        onDragEntered: (detail) {
          setState(() {
            _isDragging = true;
          });
        },
        onDragExited: (detail) {
          setState(() {
            _isDragging = false;
          });
        },
        onDragDone: (detail) async {
          setState(() {
            _isDragging = false;
          });
          if (detail.files.isNotEmpty) {
            final file = detail.files.first;
            final appState = context.read<AppState>();
            final messenger = ScaffoldMessenger.of(context);
            try {
              final bytes = await file.readAsBytes();
              await appState.handleIncomingImageBytes(bytes);
            } catch (e) {
              messenger.showSnackBar(
                SnackBar(content: Text("Failed to read dropped file: $e")),
              );
            }
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          constraints: const BoxConstraints(minHeight: 260),
          decoration: _isDragging
              ? BoxDecoration(
                  color: AppTheme.accentEmerald.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.accentEmerald, width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                )
              : AppTheme.premiumCardDecoration(context: context),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isDragging ? Icons.file_download : Icons.add_a_photo_outlined,
                color: _isDragging
                    ? AppTheme.accentEmerald
                    : colors.textSecondary.withValues(alpha: 0.5),
                size: 52,
              ),
              const SizedBox(height: 14),
              Text(
                _isDragging
                    ? AppLocalizations.of(context)!.dropZoneHovering
                    : AppLocalizations.of(context)!.dropZonePrompt,
                style: TextStyle(
                  color: _isDragging
                      ? AppTheme.accentEmerald
                      : colors.textPrimary,
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
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 10,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.photo_library),
                    label: Text(AppLocalizations.of(context)!.gallery),
                    onPressed: widget.onPickGallery,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.surfaceLight,
                      foregroundColor: colors.textPrimary,
                    ),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.camera_alt),
                    label: Text(AppLocalizations.of(context)!.camera),
                    onPressed: widget.onPickCamera,
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.content_paste),
                    label: Text(
                      AppLocalizations.of(context)!.pasteFromClipboard,
                    ),
                    onPressed: _pasteFromClipboard,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentEmerald.withValues(
                        alpha: 0.15,
                      ),
                      foregroundColor: AppTheme.accentEmerald,
                    ),
                  ),
                ],
              ),
              if (!widget.showForm) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 16,
                  alignment: WrapAlignment.center,
                  children: [
                    TextButton.icon(
                      icon: const Icon(
                        Icons.edit_note,
                        color: AppTheme.accentEmerald,
                      ),
                      label: Text(
                        AppLocalizations.of(context)!.logManually,
                        style: const TextStyle(color: AppTheme.accentEmerald),
                      ),
                      onPressed: widget.onLogManually,
                    ),
                    TextButton.icon(
                      icon: const Icon(
                        Icons.fitness_center,
                        color: AppTheme.accentAmber,
                      ),
                      label: Text(
                        AppLocalizations.of(context)!.logActivity,
                        style: const TextStyle(color: AppTheme.accentAmber),
                      ),
                      onPressed: widget.onLogActivity,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: 260,
      decoration: AppTheme.premiumCardDecoration(context: context),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.memory(
              widget.imageBytes!,
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
              onPressed: widget.onClear,
              child: const Icon(Icons.close, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
