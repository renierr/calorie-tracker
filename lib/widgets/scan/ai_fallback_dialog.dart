import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/app_state.dart';

class AIFallbackDialog extends StatefulWidget {
  final String fallbackName;
  final String errorMessage;

  const AIFallbackDialog({
    super.key,
    required this.fallbackName,
    required this.errorMessage,
  });

  /// Show the custom fallback dialogue. Returns a `Future<bool?>`.
  static Future<bool?> show({
    required BuildContext context,
    required String fallbackName,
    required String errorMessage,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AIFallbackDialog(
        fallbackName: fallbackName,
        errorMessage: errorMessage,
      ),
    );
  }

  /// Handles the complete fallback check, prompt, and execution flow.
  static Future<void> handleFallback({
    required BuildContext context,
    required AppState appState,
    required String? currentOverrideProvider,
    required Object error,
    required Future<void> Function(String fallbackProvider) onRetry,
    required VoidCallback onErrorUnhandled,
  }) async {
    final fallback = appState.activeFallbackProvider;
    if (currentOverrideProvider == null && fallback != 'none') {
      final fallbackName = appState.getProviderDisplayName(fallback);
      final tryFallback = await show(
        context: context,
        fallbackName: fallbackName,
        errorMessage: error.toString(),
      );

      if (tryFallback == true) {
        await onRetry(fallback);
      }
    } else {
      onErrorUnhandled();
    }
  }

  @override
  State<AIFallbackDialog> createState() => _AIFallbackDialogState();
}

class _AIFallbackDialogState extends State<AIFallbackDialog> {
  bool _isErrorExpanded = false;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context);
    final localizations = AppLocalizations.of(context)!;

    return AlertDialog(
      backgroundColor: colors.surface,
      title: Text(
        localizations.aiFallbackPromptTitle,
        style: const TextStyle(color: AppTheme.accentEmerald),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.aiFallbackPrompt(widget.fallbackName),
              style: TextStyle(
                color: colors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Collapsible accordion button
            InkWell(
              onTap: () {
                setState(() {
                  _isErrorExpanded = !_isErrorExpanded;
                });
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: colors.surfaceLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: colors.textMuted.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _isErrorExpanded
                          ? "Hide Error Details"
                          : "Show Error Details",
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Icon(
                      _isErrorExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: colors.textSecondary,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),

            // Collapsible content card
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxHeight: 150),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.accentRed.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.accentRed.withValues(alpha: 0.2),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      widget.errorMessage,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        color: AppTheme.accentRed,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              ),
              crossFadeState: _isErrorExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            localizations.cancel,
            style: TextStyle(color: colors.textSecondary),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(
            localizations.ok,
            style: const TextStyle(color: AppTheme.accentEmerald),
          ),
        ),
      ],
    );
  }
}
