import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../widgets/settings/backup_section_card.dart';
import '../widgets/settings/stats_section_card.dart';
import '../widgets/settings/danger_section_card.dart';

class MaintenanceSettingsPage extends StatelessWidget {
  const MaintenanceSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.maintenanceSettingsTitle)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BackupSectionCard(),
              const SizedBox(height: 20),
              const StatsSectionCard(),
              const SizedBox(height: 20),
              const DangerSectionCard(),
            ],
          ),
        ),
      ),
    );
  }
}
