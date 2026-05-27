import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/theme.dart';
import '../../l10n/app_localizations.dart';

class GeminiInfoDialog extends StatelessWidget {
  const GeminiInfoDialog({super.key});

  static const String _geminiUrl = 'https://aistudio.google.com/api-keys';

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(const ClipboardData(text: _geminiUrl));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.linkCopied),
        backgroundColor: AppTheme.accentEmerald,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context);
    final localizations = AppLocalizations.of(context)!;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 440),
        decoration: AppTheme.premiumCardDecoration(
          context: context,
          color: colors.surface,
          showGlow: true,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header banner
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.accentEmerald,
                      AppTheme.accentBlue.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      localizations.geminiInfoTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Steps content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations.geminiInfoDesc,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Steps List
                    _buildStepItem(
                      context,
                      localizations.geminiStep1,
                      showCopy: true,
                      colors: colors,
                    ),
                    const SizedBox(height: 12),
                    _buildStepItem(
                      context,
                      localizations.geminiStep2,
                      colors: colors,
                    ),
                    const SizedBox(height: 12),
                    _buildStepItem(
                      context,
                      localizations.geminiStep3,
                      colors: colors,
                    ),
                    const SizedBox(height: 12),
                    _buildStepItem(
                      context,
                      localizations.geminiStep4,
                      colors: colors,
                    ),

                    const SizedBox(height: 24),

                    // Actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            localizations.ok,
                            style: const TextStyle(
                              color: AppTheme.accentEmerald,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepItem(
    BuildContext context,
    String text, {
    bool showCopy = false,
    required AppThemeColors colors,
  }) {
    // If it's the step with the URL, let's render the URL nicely and have a copy button
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
                      _geminiUrl,
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
