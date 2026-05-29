import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/theme.dart';
import '../../l10n/app_localizations.dart';

class GeminiStepItem extends StatelessWidget {
  final String text;
  final bool showCopy;
  final AppThemeColors colors;
  final String geminiUrl;

  const GeminiStepItem({
    super.key,
    required this.text,
    this.showCopy = false,
    required this.colors,
    required this.geminiUrl,
  });

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: geminiUrl));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.linkCopied),
        backgroundColor: AppTheme.accentEmerald,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (showCopy) {
      final parts = text.split(' at: ');
      final title = parts.isNotEmpty ? parts[0] : text;

      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.surfaceLight.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colors.surfaceLight, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$title:',
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      geminiUrl,
                      style: const TextStyle(
                        color: AppTheme.accentBlue,
                        fontSize: 12,
                        decoration: TextDecoration.underline,
                        fontFamily: 'monospace',
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(
                    Icons.copy,
                    size: 18,
                    color: AppTheme.accentEmerald,
                  ),
                  tooltip: AppLocalizations.of(context)!.copyLink,
                  onPressed: () => _copyToClipboard(context),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
