import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../pages/stats_report_page.dart';
import '../adaptive/adaptive_card_header.dart';
import '../adaptive/responsive_icon_button.dart';

class StatsSectionCard extends StatelessWidget {
  const StatsSectionCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context);
    final l10n = AppLocalizations.of(context)!;

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
            icon: Icons.bar_chart,
            iconColor: AppTheme.accentBlue,
            title: l10n.statsSectionTitle,
          ),
          const SizedBox(height: 10),
          Text(
            l10n.statsSectionDesc,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ResponsiveIconButton(
              icon: const Icon(
                Icons.analytics,
                color: AppTheme.accentBlue,
                size: 18,
              ),
              label: l10n.statsViewBtn,
              color: AppTheme.accentBlue,
              isOutlined: true,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StatsReportPage(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
