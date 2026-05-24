import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_selector/file_selector.dart';
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
              _buildThemeCard(appState),
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
    final colors = AppTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.premiumCardDecoration(color: colors.surface),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.key, color: AppTheme.accentEmerald, size: 20),
              const SizedBox(width: 10),
              Text(
                AppLocalizations.of(context)!.apiCredentials,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            AppLocalizations.of(context)!.apiCredentialsDesc,
            style: TextStyle(
              color: colors.textSecondary,
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
                  color: colors.textSecondary,
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
    final colors = AppTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.premiumCardDecoration(color: colors.surface),
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
                style: TextStyle(
                  color: colors.textPrimary,
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
            style: TextStyle(color: colors.textSecondary, fontSize: 12),
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
                    Text(
                      'Protein (g)',
                      style: TextStyle(
                        color: colors.textSecondary,
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
                    Text(
                      'Carbohydrates (g)',
                      style: TextStyle(
                        color: colors.textSecondary,
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
                    Text(
                      'Lipid Fats (g)',
                      style: TextStyle(
                        color: colors.textSecondary,
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
    final colors = AppTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.premiumCardDecoration(
        color: colors.surface,
        glowColor: AppTheme.accentRed,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.dangerous, color: AppTheme.accentRed, size: 20),
              const SizedBox(width: 10),
              Text(
                AppLocalizations.of(context)!.dangerZone,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            AppLocalizations.of(context)!.dangerDesc,
            style: TextStyle(
              color: colors.textSecondary,
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
                    final colors = AppTheme.of(context);
                    return AlertDialog(
                      backgroundColor: colors.surface,
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
                            style: TextStyle(color: colors.textSecondary),
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
    final colors = AppTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.premiumCardDecoration(color: colors.surface),
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
                style: TextStyle(
                  color: colors.textPrimary,
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
              color: colors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: appState.appLocale,
                dropdownColor: colors.surface,
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

  Widget _buildThemeCard(AppState appState) {
    final colors = AppTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.premiumCardDecoration(color: colors.surface),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.palette, color: AppTheme.accentAmber, size: 20),
              const SizedBox(width: 10),
              Text(
                AppLocalizations.of(context)!.appearance,
                style: TextStyle(
                  color: colors.textPrimary,
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
              color: colors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _themeModeValue(appState),
                dropdownColor: colors.surface,
                isExpanded: true,
                items: [
                  DropdownMenuItem(
                    value: 'system',
                    child: Text(AppLocalizations.of(context)!.themeSystem),
                  ),
                  DropdownMenuItem(
                    value: 'light',
                    child: Text(AppLocalizations.of(context)!.themeLight),
                  ),
                  DropdownMenuItem(
                    value: 'dark',
                    child: Text(AppLocalizations.of(context)!.themeDark),
                  ),
                ],
                onChanged: (val) {
                  if (val == 'light') {
                    appState.setThemeMode(ThemeMode.light);
                  } else if (val == 'dark') {
                    appState.setThemeMode(ThemeMode.dark);
                  } else {
                    appState.setThemeMode(ThemeMode.system);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _themeModeValue(AppState appState) {
    switch (appState.themeMode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      default:
        return 'system';
    }
  }

  Widget _buildExportCard(AppState appState) {
    final colors = AppTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.premiumCardDecoration(color: colors.surface),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.backup, color: AppTheme.accentEmerald, size: 20),
              const SizedBox(width: 10),
              Text(
                AppLocalizations.of(context)!.exportDb,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            AppLocalizations.of(context)!.exportDbDesc,
            style: TextStyle(
              color: colors.textSecondary,
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
                final timestamp = DateTime.now().millisecondsSinceEpoch;
                final location = await getSaveLocation(
                  suggestedName: 'nutriscan_db_$timestamp.db',
                );
                if (location == null) return;
                try {
                  await appState.exportDatabase(destPath: location.path);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context)!.dbExported),
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
