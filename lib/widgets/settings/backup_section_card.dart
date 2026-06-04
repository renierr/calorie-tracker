import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/theme.dart';
import '../../providers/app_state.dart';
import '../../l10n/app_localizations.dart';
import '../../helpers/file_save_helper.dart';
import '../adaptive/adaptive_card_header.dart';
import '../adaptive/responsive_icon_button.dart';

class BackupSectionCard extends StatelessWidget {
  const BackupSectionCard({super.key});

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
            icon: Icons.backup,
            iconColor: AppTheme.accentEmerald,
            title: l10n.exportSectionTitle,
          ),
          const SizedBox(height: 10),
          Text(
            l10n.exportSectionDesc,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ResponsiveIconButton(
              icon: const Icon(Icons.download, color: AppTheme.accentEmerald),
              label: l10n.exportDbBtn,
              color: AppTheme.accentEmerald,
              onPressed: () => _exportDbFlow(context),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ResponsiveIconButton(
              icon: const Icon(Icons.settings, color: AppTheme.accentBlue),
              label: l10n.exportSettingsBtn,
              color: AppTheme.accentBlue,
              onPressed: () => _exportSettingsFlow(context),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportDbFlow(BuildContext context) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final l10n = AppLocalizations.of(context)!;
    try {
      final appState = context.read<AppState>();
      final bytes = await appState.getDatabaseBytes();
      if (!context.mounted) return;

      await FileSaveHelper.saveFile(
        context: context,
        suggestedName: 'nutriscan_db_$timestamp.db',
        bytes: bytes,
        successMessageAndroid: l10n.dbExportedDownloads,
        successMessageGeneralBuilder: (displayPath) =>
            l10n.dbExportedTo(displayPath),
        errorMessageBuilder: (e) => l10n.dbExportFailed(e),
      );
    } catch (e) {
      if (!context.mounted) return;
      FileSaveHelper.showErrorNotification(
        context: context,
        errorMessage: l10n.dbExportFailed(e.toString()),
      );
    }
  }

  Future<void> _exportSettingsFlow(BuildContext context) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final l10n = AppLocalizations.of(context)!;
    try {
      final appState = context.read<AppState>();
      final settingsJson = await appState.exportSettingsToJson();
      final bytes = Uint8List.fromList(utf8.encode(settingsJson));
      if (!context.mounted) return;

      await FileSaveHelper.saveFile(
        context: context,
        suggestedName: 'nutriscan_settings_$timestamp.json',
        bytes: bytes,
        successMessageAndroid: l10n.settingsExported,
        successMessageGeneralBuilder: (displayPath) => l10n.settingsExported,
        errorMessageBuilder: (e) => l10n.settingsExportFailed(e),
      );
    } catch (e) {
      if (!context.mounted) return;
      FileSaveHelper.showErrorNotification(
        context: context,
        errorMessage: l10n.settingsExportFailed(e.toString()),
      );
    }
  }
}
