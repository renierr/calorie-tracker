import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../pages/maintenance_settings_page.dart';
import '../adaptive/adaptive_card_header.dart';
import '../adaptive/responsive_icon_button.dart';

class MaintenanceConfigTile extends StatelessWidget {
  const MaintenanceConfigTile({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.premiumCardDecoration(
        context: context,
        color: colors.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdaptiveCardHeader(
            icon: Icons.build,
            iconColor: AppTheme.accentRed,
            title: l10n.maintenanceSettingsTitle,
          ),
          const SizedBox(height: 10),
          Text(
            l10n.maintenanceSettingsDesc,
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
                Icons.settings,
                color: AppTheme.accentRed,
                size: 18,
              ),
              label: l10n.maintenanceConfigureBtn,
              color: AppTheme.accentRed,
              isOutlined: true,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MaintenanceSettingsPage(),
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
