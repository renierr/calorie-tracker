import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import '../theme/theme.dart';
import '../providers/app_state.dart';
import '../l10n/app_localizations.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Key toggle
  bool _obscureApiKey = true;

  // Form field controllers
  late TextEditingController _apiKeyController;
  late TextEditingController _caloriesController;
  late TextEditingController _proteinController;
  late TextEditingController _carbsController;
  late TextEditingController _fatController;

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
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
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
              _buildApiConfigCard(),
              const SizedBox(height: 20),

              // Panel 2: Language Selection
              _buildLanguageCard(appState),
              const SizedBox(height: 20),

              // Panel 3: Calorie & Macro Target configuration
              _buildTargetGoalsCard(),
              const SizedBox(height: 20),

              // Panel 4: Reset database safety controls
              _buildMaintenanceCard(appState),
              const SizedBox(height: 20),

              // Panel 5: Export database
              _buildExportCard(appState),
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

  // Segment 1: API Keys Secure field
  Widget _buildApiConfigCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.premiumCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.key, color: AppTheme.accentEmerald, size: 20),
              const SizedBox(width: 10),
              Text(
                AppLocalizations.of(context)!.apiCredentials,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            AppLocalizations.of(context)!.apiCredentialsDesc,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _apiKeyController,
            obscureText: _obscureApiKey,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.enterApiKey,
              labelText: AppLocalizations.of(context)!.apiKeyLabel,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureApiKey ? Icons.visibility_off : Icons.visibility,
                  color: AppTheme.textSecondary,
                ),
                onPressed: () {
                  setState(() {
                    _obscureApiKey = !_obscureApiKey;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Segment 2: Daily Target Sliders & numeric inputs
  Widget _buildTargetGoalsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.premiumCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.track_changes,
                color: AppTheme.accentEmerald,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                AppLocalizations.of(context)!.dailyTargets,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Calories Input
          Text(
            AppLocalizations.of(context)!.calorieBudget,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _caloriesController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.calorieHint,
            ),
          ),
          const SizedBox(height: 16),

          // Macros rows
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Protein (g)',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _proteinController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.proteinHint,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Carbohydrates (g)',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _carbsController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.carbsHint,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Fat Input
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Lipid Fats (g)',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _fatController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.fatHint,
                      ),
                    ),
                  ],
                ),
              ),
              const Expanded(child: SizedBox()),
            ],
          ),
        ],
      ),
    );
  }

  // Segment 3: Reset Database diagnostics
  Widget _buildMaintenanceCard(AppState appState) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.premiumCardDecoration(glowColor: AppTheme.accentRed),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.dangerous, color: AppTheme.accentRed, size: 20),
              const SizedBox(width: 10),
              Text(
                AppLocalizations.of(context)!.dangerZone,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            AppLocalizations.of(context)!.dangerDesc,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.delete_forever, color: AppTheme.accentRed),
              label: Text(
                AppLocalizations.of(context)!.clearHistory,
                style: const TextStyle(color: AppTheme.accentRed),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.accentRed, width: 1.2),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      backgroundColor: AppTheme.surface,
                      title: Text(
                        AppLocalizations.of(context)!.eraseAll,
                        style: const TextStyle(
                          color: AppTheme.accentRed,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      content: Text(AppLocalizations.of(context)!.eraseAllDesc),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            AppLocalizations.of(context)!.cancel,
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentRed,
                          ),
                          onPressed: () async {
                            await appState.clearAllMeals();
                            if (!context.mounted) return;
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  AppLocalizations.of(context)!.dbCleared,
                                ),
                              ),
                            );
                          },
                          child: Text(
                            AppLocalizations.of(context)!.permanentlyErase,
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageCard(AppState appState) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.premiumCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.language,
                color: AppTheme.accentEmerald,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                AppLocalizations.of(context)!.language,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: appState.appLocale,
                dropdownColor: AppTheme.surface,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 'en', child: Text('English')),
                  DropdownMenuItem(value: 'de', child: Text('Deutsch')),
                ],
                onChanged: (val) {
                  if (val != null) appState.setLocale(val);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportCard(AppState appState) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.premiumCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.backup, color: AppTheme.accentEmerald, size: 20),
              const SizedBox(width: 10),
              Text(
                AppLocalizations.of(context)!.exportDb,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            AppLocalizations.of(context)!.exportDbDesc,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.download, color: AppTheme.accentEmerald),
              label: Text(
                AppLocalizations.of(context)!.exportDbBtn,
                style: const TextStyle(color: AppTheme.accentEmerald),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(
                  color: AppTheme.accentEmerald,
                  width: 1.2,
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                try {
                  await appState.exportDatabase();
                  final dir = await getApplicationDocumentsDirectory();
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${AppLocalizations.of(context)!.dbExported} ${dir.path}',
                      ),
                      backgroundColor: AppTheme.accentEmerald,
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Export failed: $e'),
                      backgroundColor: AppTheme.accentRed,
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
