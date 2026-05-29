import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../l10n/app_localizations.dart';
import 'gemini_step_item.dart';

class GeminiInfoDialog extends StatelessWidget {
  const GeminiInfoDialog({super.key});

  static const String _geminiUrl = 'https://aistudio.google.com/api-keys';

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
                    GeminiStepItem(
                      text: localizations.geminiStep1,
                      showCopy: true,
                      colors: colors,
                      geminiUrl: _geminiUrl,
                    ),
                    const SizedBox(height: 12),
                    GeminiStepItem(
                      text: localizations.geminiStep2,
                      colors: colors,
                      geminiUrl: _geminiUrl,
                    ),
                    const SizedBox(height: 12),
                    GeminiStepItem(
                      text: localizations.geminiStep3,
                      colors: colors,
                      geminiUrl: _geminiUrl,
                    ),
                    const SizedBox(height: 12),
                    GeminiStepItem(
                      text: localizations.geminiStep4,
                      colors: colors,
                      geminiUrl: _geminiUrl,
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
}
