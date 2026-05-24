import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme.dart';
import '../providers/app_state.dart';
import '../l10n/app_localizations.dart';
import '../widgets/settings/api_config_card.dart';
import '../widgets/settings/target_goals_card.dart';
import '../widgets/settings/maintenance_card.dart';
import '../widgets/settings/language_card.dart';
import '../widgets/settings/theme_card.dart';
import '../widgets/settings/export_card.dart';
import '../widgets/settings/sync_config_card.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Form field controllers
  late TextEditingController _apiKeyController;
  late TextEditingController _caloriesController;
  late TextEditingController _proteinController;
  late TextEditingController _carbsController;
  late TextEditingController _fatController;
  late TextEditingController _syncServerUrlController;
  late TextEditingController _syncUserIdController;

  @override
  void initState() {
    super.initState();
    // Pre-populate fields from active State
    final appState = Provider.of<AppState>(context, listen: false);
    _apiKeyController = TextEditingController(text: appState.geminiApiKey);
    _caloriesController = TextEditingController(
      text: appState.calorieGoal.toString(),
    );
    _proteinController = TextEditingController(
      text: appState.proteinGoal.toString(),
    );
    _carbsController = TextEditingController(
      text: appState.carbsGoal.toString(),
    );
    _fatController = TextEditingController(text: appState.fatGoal.toString());
    _syncServerUrlController = TextEditingController(
      text: appState.syncServerUrl,
    );
    _syncUserIdController = TextEditingController(text: appState.syncUserId);
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _syncServerUrlController.dispose();
    _syncUserIdController.dispose();
    super.dispose();
  }

  // Trigger Settings Save Helper
  Future<void> _saveSettings(AppState appState) async {
    final String apiKey = _apiKeyController.text.trim();
    final int calories = int.tryParse(_caloriesController.text) ?? 2000;
    final int protein = int.tryParse(_proteinController.text) ?? 130;
    final int carbs = int.tryParse(_carbsController.text) ?? 220;
    final int fat = int.tryParse(_fatController.text) ?? 70;

    await appState.saveSettings(
      apiKey: apiKey,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
    );

    // Save sync settings
    await appState.saveSyncSettings(
      serverUrl: _syncServerUrlController.text.trim(),
      userId: _syncUserIdController.text.trim(),
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
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.settingsTitle)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Panel 1: API Configuration
              ApiConfigCard(apiKeyController: _apiKeyController),
              const SizedBox(height: 20),

              // Panel 2: Language Selection
              LanguageCard(appState: appState),
              const SizedBox(height: 20),
              ThemeCard(appState: appState),
              const SizedBox(height: 20),

              // Panel 2.5: Cloud Sync Configuration
              SyncConfigCard(
                serverUrlController: _syncServerUrlController,
                userIdController: _syncUserIdController,
                appState: appState,
              ),
              const SizedBox(height: 20),

              // Panel 3: Calorie & Macro Target configuration
              TargetGoalsCard(
                caloriesController: _caloriesController,
                proteinController: _proteinController,
                carbsController: _carbsController,
                fatController: _fatController,
              ),
              const SizedBox(height: 20),

              // Panel 4: Reset database safety controls
              MaintenanceCard(appState: appState),
              const SizedBox(height: 20),

              // Panel 5: Export database
              ExportCard(appState: appState),
              const SizedBox(height: 30),

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
            ],
          ),
        ),
      ),
    );
  }
}
