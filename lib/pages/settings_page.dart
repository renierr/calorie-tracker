import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme.dart';
import '../providers/app_state.dart';

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
    _caloriesController = TextEditingController(text: appState.calorieGoal.toString());
    _proteinController = TextEditingController(text: appState.proteinGoal.toString());
    _carbsController = TextEditingController(text: appState.carbsGoal.toString());
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

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Preferences saved successfully!'),
        backgroundColor: AppTheme.accentEmerald,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Goal & API Settings')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            cross: CrossAxisAlignment.start,
            children: [
              // Panel 1: API Configuration
              _buildApiConfigCard(),
              const SizedBox(height: 20),

              // Panel 2: Calorie & Macro Target configuration
              _buildTargetGoalsCard(),
              const SizedBox(height: 20),

              // Panel 3: Reset database safety controls
              _buildMaintenanceCard(appState),
              const SizedBox(height: 30),

              // Bottom Save Settings Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('Save Preferences'),
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
        cross: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.key, color: AppTheme.accentEmerald, size: 20),
              SizedBox(width: 10),
              Text(
                'Gemini AI API Credentials',
                style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'The AI Meal Scanner runs locally and requires a Google Gemini API Key. Your key is saved locally in private app settings.',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _apiKeyController,
            obscureText: _obscureApiKey,
            decoration: InputDecoration(
              hintText: 'Enter your Gemini API Key',
              labelText: 'Gemini API Key',
              suffixIcon: IconButton(
                icon: Icon(_obscureApiKey ? Icons.visibility_off : Icons.visibility, color: AppTheme.textSecondary),
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
        cross: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.track_changes, color: AppTheme.accentEmerald, size: 20),
              SizedBox(width: 10),
              Text(
                'Daily Nutritional Targets',
                style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Calories Input
          const Text('Daily Calorie Budget (kcal)', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          const SizedBox(height: 8),
          TextField(
            controller: _caloriesController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: 'e.g. 2000'),
          ),
          const SizedBox(height: 16),

          // Macros rows
          Row(
            children: [
              Expanded(
                child: Column(
                  cross: CrossAxisAlignment.start,
                  children: [
                    const Text('Protein (g)', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _proteinController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: 'e.g. 130'),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  cross: CrossAxisAlignment.start,
                  children: [
                    const Text('Carbohydrates (g)', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _carbsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: 'e.g. 220'),
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
                  cross: CrossAxisAlignment.start,
                  children: [
                    const Text('Lipid Fats (g)', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _fatController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: 'e.g. 70'),
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
        cross: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.dangerous, color: AppTheme.accentRed, size: 20),
              SizedBox(width: 10),
              Text(
                'Danger Zone & Maintenance',
                style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Clearing your database will permanently remove all tracked foods, calorie metrics, and meal photos from SQLite. This action is irreversible.',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.delete_forever, color: AppTheme.accentRed),
              label: const Text('Clear All Food Logs History', style: TextStyle(color: AppTheme.accentRed)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.accentRed, width: 1.2),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      backgroundColor: AppTheme.surface,
                      title: const Text('Erase All Data?', style: TextStyle(color: AppTheme.accentRed, fontWeight: FontWeight.bold)),
                      content: const Text(
                        'Are you absolutely sure you want to permanently clear the SQLite database? This deletes all your logged meal stats, photos, and historical progress. This action cannot be undone.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentRed),
                          onPressed: () async {
                            await appState.clearAllMeals();
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Database log history cleared.')),
                            );
                          },
                          child: const Text('Permanently Erase Database'),
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
}
