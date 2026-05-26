import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../adaptive/adaptive_card_header.dart';
import '../adaptive/responsive_icon_button.dart';
import '../../theme/theme.dart';
import '../../providers/app_state.dart';
import '../../l10n/app_localizations.dart';
import '../../helpers/file_save_helper.dart';

class ExportCard extends StatefulWidget {
  final AppState appState;

  const ExportCard({super.key, required this.appState});

  @override
  State<ExportCard> createState() => _ExportCardState();
}

class _ExportCardState extends State<ExportCard> {
  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context);
    final localizations = AppLocalizations.of(context)!;
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
            title: localizations.exportSectionTitle,
          ),
          const SizedBox(height: 10),
          Text(
            localizations.exportSectionDesc,
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
              label: localizations.exportDbBtn,
              color: AppTheme.accentEmerald,
              onPressed: _exportDbFlow,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ResponsiveIconButton(
              icon: const Icon(Icons.settings, color: AppTheme.accentBlue),
              label: localizations.exportSettingsBtn,
              color: AppTheme.accentBlue,
              onPressed: _exportSettingsFlow,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportDbFlow() async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final localizations = AppLocalizations.of(context)!;
    try {
      final bytes = await widget.appState.getDatabaseBytes();
      if (!mounted) return;

      await FileSaveHelper.saveFile(
        context: context,
        suggestedName: 'nutriscan_db_$timestamp.db',
        bytes: bytes,
        successMessageAndroid: localizations.dbExportedDownloads,
        successMessageGeneralBuilder: (displayPath) =>
            localizations.dbExportedTo(displayPath),
        errorMessageBuilder: (e) => localizations.dbExportFailed(e),
      );
    } catch (e) {
      if (!mounted) return;
      FileSaveHelper.showErrorNotification(
        context: context,
        errorMessage: localizations.dbExportFailed(e.toString()),
      );
    }
  }

  Future<void> _exportSettingsFlow() async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final localizations = AppLocalizations.of(context)!;
    try {
      final settingsJson = await widget.appState.exportSettingsToJson();
      final bytes = Uint8List.fromList(utf8.encode(settingsJson));
      if (!mounted) return;

      await FileSaveHelper.saveFile(
        context: context,
        suggestedName: 'nutriscan_settings_$timestamp.json',
        bytes: bytes,
        successMessageAndroid: localizations.settingsExported,
        successMessageGeneralBuilder: (displayPath) =>
            localizations.settingsExported,
        errorMessageBuilder: (e) => localizations.settingsExportFailed(e),
      );
    } catch (e) {
      if (!mounted) return;
      FileSaveHelper.showErrorNotification(
        context: context,
        errorMessage: localizations.settingsExportFailed(e.toString()),
      );
    }
  }
}
