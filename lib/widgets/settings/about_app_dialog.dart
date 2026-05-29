import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../version.dart';

class AboutAppDialog extends StatelessWidget {
  const AboutAppDialog({super.key});

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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Banner with Premium Gradient
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.accentEmerald,
                      AppTheme.accentBlue.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.restaurant_menu,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      localizations.aboutTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      localizations.aboutSubtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Scrollable content area to prevent small screen overflows
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Introduction text
                      Text(
                        localizations.aboutDescription,
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 14,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Feature List Header
                      Row(
                        children: [
                          const Icon(
                            Icons.auto_awesome,
                            color: AppTheme.accentEmerald,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            localizations
                                .badgesTitle, // Reuse "Achievements/Badges" translation context or keep simple
                            style: TextStyle(
                              color: colors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Features Column
                      _buildFeatureRow(
                        context,
                        icon: Icons.photo_camera_outlined,
                        color: AppTheme.accentEmerald,
                        title: localizations.aboutFeatureAiTitle,
                        description: localizations.aboutFeatureAiDesc,
                        colors: colors,
                      ),
                      const SizedBox(height: 12),
                      _buildFeatureRow(
                        context,
                        icon: Icons.psychology_outlined,
                        color: AppTheme.accentBlue,
                        title: localizations.aboutFeatureMultiAiTitle,
                        description: localizations.aboutFeatureMultiAiDesc,
                        colors: colors,
                      ),
                      const SizedBox(height: 12),
                      _buildFeatureRow(
                        context,
                        icon: Icons.local_fire_department_outlined,
                        color: AppTheme.accentAmber,
                        title: localizations.aboutFeatureGamificationTitle,
                        description: localizations.aboutFeatureGamificationDesc,
                        colors: colors,
                      ),
                      const SizedBox(height: 12),
                      _buildFeatureRow(
                        context,
                        icon: Icons.dns_outlined,
                        color: AppTheme.accentPurple,
                        title: localizations.aboutFeatureOfflineTitle,
                        description: localizations.aboutFeatureOfflineDesc,
                        colors: colors,
                      ),
                      const SizedBox(height: 12),
                      _buildFeatureRow(
                        context,
                        icon: Icons.picture_as_pdf_outlined,
                        color: AppTheme.accentRed,
                        title: localizations.aboutFeaturePdfTitle,
                        description: localizations.aboutFeaturePdfDesc,
                        colors: colors,
                      ),

                      const SizedBox(height: 24),

                      // Version Information Card inside the dialog
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colors.surfaceLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: colors.textMuted.withValues(alpha: 0.15),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  localizations.appVersion(AppVersion.version),
                                  style: TextStyle(
                                    color: colors.textSecondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.commit,
                                      color: colors.textMuted,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      localizations.gitHash(
                                        AppVersion.commitHash,
                                      ),
                                      style: TextStyle(
                                        color: colors.textSecondary,
                                        fontSize: 12,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              localizations.aboutOpenSource,
                              style: TextStyle(
                                color: colors.textMuted,
                                fontSize: 11,
                                height: 1.35,
                                fontStyle: FontStyle.italic,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Actions
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: colors.surface,
                  border: Border(
                    top: BorderSide(
                      color: colors.textMuted.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                child: Row(
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String description,
    required AppThemeColors colors,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
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
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
