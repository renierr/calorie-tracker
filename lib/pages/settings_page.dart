import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme.dart';
import '../providers/app_state.dart';
import '../l10n/app_localizations.dart';
import '../widgets/settings/target_goals_card.dart';
import '../widgets/settings/maintenance_card.dart';
import '../widgets/settings/language_theme_card.dart';
import '../widgets/settings/notifications_card.dart';
import '../widgets/settings/export_card.dart';
import '../widgets/settings/sync_config_card.dart';
import '../widgets/settings/version_card.dart';
import '../widgets/settings/ai_provider_config_tile.dart';
import '../widgets/settings/gamification_config_tile.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final AppState _appState;

  // Form field controllers
  late TextEditingController _caloriesController;
  late TextEditingController _proteinController;
  late TextEditingController _carbsController;
  late TextEditingController _fatController;

  @override
  void initState() {
    super.initState();
    // Pre-populate fields from active State
    _appState = context.read<AppState>();
    _caloriesController = TextEditingController(
      text: _appState.calorieGoal.toString(),
    );
    _proteinController = TextEditingController(
      text: _appState.proteinGoal.toString(),
    );
    _carbsController = TextEditingController(
      text: _appState.carbsGoal.toString(),
    );
    _fatController = TextEditingController(text: _appState.fatGoal.toString());

    _appState.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    _appState.removeListener(_onStateChanged);
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    if (!mounted) return;
    final appState = _appState;
    if (_caloriesController.text != appState.calorieGoal.toString()) {
      _caloriesController.text = appState.calorieGoal.toString();
    }
    if (_proteinController.text != appState.proteinGoal.toString()) {
      _proteinController.text = appState.proteinGoal.toString();
    }
    if (_carbsController.text != appState.carbsGoal.toString()) {
      _carbsController.text = appState.carbsGoal.toString();
    }
    if (_fatController.text != appState.fatGoal.toString()) {
      _fatController.text = appState.fatGoal.toString();
    }
  }

  // Trigger Settings Save Helper
  Future<void> _saveSettings(AppState appState) async {
    final int calories = int.tryParse(_caloriesController.text) ?? 2000;
    final int protein = int.tryParse(_proteinController.text) ?? 130;
    final int carbs = int.tryParse(_carbsController.text) ?? 220;
    final int fat = int.tryParse(_fatController.text) ?? 70;

    await appState.saveSettings(
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.prefsSaved),
        backgroundColor: AppTheme.accentEmerald,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.settingsTitle)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Panel 1: Language & Theme Selection (Combined)
              LanguageThemeCard(appState: appState),
              const SizedBox(height: 20),

              // Panel 2: System Notifications
              NotificationsCard(appState: appState),
              const SizedBox(height: 20),

              // Panel 3: AI Provider Configuration navigation tile
              AiProviderConfigTile(appState: appState),
              const SizedBox(height: 20),

              // Panel 4: Gamification Configuration
              GamificationConfigTile(appState: appState),
              const SizedBox(height: 20),

              // Panel 5: Cloud Sync Configuration
              SyncConfigCard(appState: appState),
              const SizedBox(height: 20),

              // Panel 3: Calorie & Macro Target configuration
              TargetGoalsCard(
                caloriesController: _caloriesController,
                proteinController: _proteinController,
                carbsController: _carbsController,
                fatController: _fatController,
              ),
              const SizedBox(height: 20),

              // Bottom Save Settings Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: Text(AppLocalizations.of(context)!.savePreferences),
                  onPressed: () => _saveSettings(appState),
                ),
              ),
              const SizedBox(height: 30),

              // Panel 4: Reset database safety controls
              MaintenanceCard(appState: appState),
              const SizedBox(height: 20),

              // Panel 5: Export database
              ExportCard(appState: appState),
              const SizedBox(height: 30),

              // Panel 6: App Version Info
              const VersionCard(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
