import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../helpers/format_helper.dart';
import '../../providers/app_state.dart';
import '../adaptive/adaptive_card_header.dart';
import '../adaptive/responsive_icon_button.dart';
import '../custom_notification.dart';

/// Maintenance card: shows image storage usage and deduplicates identical
/// images so they are stored only once.
class ImageStorageSectionCard extends StatefulWidget {
  const ImageStorageSectionCard({super.key});

  @override
  State<ImageStorageSectionCard> createState() =>
      _ImageStorageSectionCardState();
}

class _ImageStorageSectionCardState extends State<ImageStorageSectionCard> {
  int _imageCount = 0;
  int _imageBytes = 0;
  int _legacyCount = 0;
  bool _isLoading = true;
  bool _isOptimizing = false;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final stats = await context.read<AppState>().getImageDedupStats();
      if (!mounted) return;
      setState(() {
        _imageCount = stats.sharedCount + stats.legacyCount;
        _imageBytes = stats.sharedBytes + stats.legacyBytes;
        _legacyCount = stats.legacyCount;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('[ImageStorageSectionCard] Failed to load stats: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _optimize() async {
    final l10n = AppLocalizations.of(context)!;
    final appState = context.read<AppState>();
    setState(() => _isOptimizing = true);
    try {
      final result = await appState.deduplicateImages();
      await _loadStats();
      if (!mounted) return;
      showNotificationDialog(
        context,
        l10n.imageStorageOptimized(
          result.duplicates,
          formatBytes(result.savedBytes),
        ),
      );
    } catch (e) {
      debugPrint('[ImageStorageSectionCard] Optimization failed: $e');
      if (mounted) {
        showNotificationDialog(
          context,
          l10n.imageStorageOptimizeFailed(e.toString()),
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isOptimizing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final busy = _isLoading || _isOptimizing;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.premiumCardDecoration(
        context: context,
        color: colors.surface,
        glowColor: AppTheme.accentBlue,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdaptiveCardHeader(
            icon: Icons.photo_library,
            iconColor: AppTheme.accentBlue,
            title: l10n.imageStorageTitle,
          ),
          const SizedBox(height: 10),
          Text(
            l10n.imageStorageDesc,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 15),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 8,
            runSpacing: 4,
            children: [
              Text(
                l10n.imageStorageTitle,
                style: TextStyle(color: colors.textSecondary, fontSize: 12),
              ),
              busy
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.accentBlue,
                        ),
                      ),
                    )
                  : Text(
                      l10n.imageStorageUsage(
                        _imageCount,
                        formatBytes(_imageBytes),
                        _legacyCount,
                      ),
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ],
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ResponsiveIconButton(
              icon: const Icon(
                Icons.auto_fix_high,
                color: AppTheme.accentBlue,
                size: 18,
              ),
              label: l10n.imageStorageOptimize,
              color: AppTheme.accentBlue,
              isOutlined: true,
              onPressed: busy ? null : _optimize,
            ),
          ),
        ],
      ),
    );
  }
}
