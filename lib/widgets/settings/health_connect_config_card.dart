import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../pages/health_connect_settings_page.dart';
import '../../providers/app_state.dart';
import '../../theme/theme.dart';
import '../adaptive/adaptive_card_header.dart';
import '../adaptive/responsive_icon_button.dart';

class HealthConnectConfigCard extends StatelessWidget {
  const HealthConnectConfigCard({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Platform.isAndroid) return const SizedBox.shrink();
    final colors = AppTheme.of(context);
    final enabled = context.select<AppState, bool>(
      (state) => state.healthConnectEnabled,
    );
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
            icon: Icons.health_and_safety_outlined,
            iconColor: AppTheme.accentEmerald,
            title: l10n.healthConnectTitle,
          ),
          const SizedBox(height: 10),
          Text(
            l10n.healthConnectCardDescription,
            style: TextStyle(color: colors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 15),
          ResponsiveIconButton(
            icon: const Icon(Icons.settings_outlined, size: 18),
            label: enabled
                ? l10n.healthConnectEnabledStatus
                : l10n.healthConnectDisabledStatus,
            color: AppTheme.accentEmerald,
            isOutlined: true,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const HealthConnectSettingsPage(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
