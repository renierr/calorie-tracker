import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../helpers/temp_file_manager.dart';
import '../adaptive/adaptive_card_header.dart';
import '../adaptive/responsive_icon_button.dart';
import '../custom_notification.dart';

class TempFilesSectionCard extends StatefulWidget {
  const TempFilesSectionCard({super.key});

  @override
  State<TempFilesSectionCard> createState() => _TempFilesSectionCardState();
}

class _TempFilesSectionCardState extends State<TempFilesSectionCard> {
  int _fileCount = 0;
  String _sizeStr = '0 B';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final count = TempFileManager.trackedCount;
      final bytes = await TempFileManager.trackedBytes();
      final sizeStr = _formatBytes(bytes);

      if (mounted) {
        setState(() {
          _fileCount = count;
          _sizeStr = sizeStr;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Failed to load temp files stats: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var i = 0;
    double dBytes = bytes.toDouble();
    while (dBytes >= 1024 && i < suffixes.length - 1) {
      dBytes /= 1024;
      i++;
    }
    return '${dBytes.toStringAsFixed(1)} ${suffixes[i]}';
  }

  Future<void> _cleanTempFiles() async {
    try {
      await TempFileManager.cleanAll();
      await _loadStats();
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        showNotificationDialog(context, l10n.tempFilesCleanedUp);
      }
    } catch (e) {
      debugPrint("Failed to clean up temp files: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.premiumCardDecoration(
        context: context,
        color: colors.surface,
        glowColor: AppTheme.accentAmber,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdaptiveCardHeader(
            icon: Icons.cleaning_services,
            iconColor: AppTheme.accentAmber,
            title: l10n.tempFilesTitle,
          ),
          const SizedBox(height: 10),
          Text(
            l10n.tempFilesDesc,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.tempFilesTitle,
                style: TextStyle(color: colors.textSecondary, fontSize: 12),
              ),
              _isLoading
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.accentAmber,
                        ),
                      ),
                    )
                  : Text(
                      l10n.tempFilesUsage(_fileCount, _sizeStr),
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
                Icons.delete_sweep,
                color: AppTheme.accentAmber,
                size: 18,
              ),
              label: l10n.tempFilesCleanUp,
              color: AppTheme.accentAmber,
              isOutlined: true,
              onPressed: _cleanTempFiles,
            ),
          ),
        ],
      ),
    );
  }
}
