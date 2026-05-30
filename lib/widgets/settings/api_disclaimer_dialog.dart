import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../l10n/app_localizations.dart';

class ApiDisclaimerDialog extends StatelessWidget {
  const ApiDisclaimerDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context);
    final localizations = AppLocalizations.of(context)!;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 460),
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
              // Header Banner with Amber-to-Red warning gradient
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.accentAmber,
                      AppTheme.accentRed.withValues(alpha: 0.8),
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
                      Icons.warning_amber_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      localizations.apiDisclaimerTitle,
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

              // Content Section
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations.apiDisclaimerDesc,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Point 1: Costs
                    _DisclaimerPointItem(
                      icon: Icons.monetization_on_outlined,
                      iconColor: AppTheme.accentAmber,
                      title: localizations.apiDisclaimerPoint1Title,
                      desc: localizations.apiDisclaimerPoint1Desc,
                      colors: colors,
                    ),
                    const SizedBox(height: 18),

                    // Point 2: Responsibility
                    _DisclaimerPointItem(
                      icon: Icons.person_outline,
                      iconColor: AppTheme.accentBlue,
                      title: localizations.apiDisclaimerPoint2Title,
                      desc: localizations.apiDisclaimerPoint2Desc,
                      colors: colors,
                    ),
                    const SizedBox(height: 18),

                    // Point 3: Liability
                    _DisclaimerPointItem(
                      icon: Icons.gavel_outlined,
                      iconColor: AppTheme.accentRed,
                      title: localizations.apiDisclaimerPoint3Title,
                      desc: localizations.apiDisclaimerPoint3Desc,
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
                            localizations.apiDisclaimerButton,
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

class _DisclaimerPointItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String desc;
  final AppThemeColors colors;

  const _DisclaimerPointItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.desc,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                desc,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
