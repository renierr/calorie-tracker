import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme.dart';
import '../providers/app_state.dart';
import '../l10n/app_localizations.dart';
import 'ai_settings_page.dart';
import 'gamification_settings_page.dart';
import '../widgets/settings/target_goals_card.dart';
import '../widgets/settings/maintenance_card.dart';
import '../widgets/settings/language_card.dart';
import '../widgets/settings/theme_card.dart';
import '../widgets/settings/notifications_card.dart';
import '../widgets/settings/export_card.dart';
import '../widgets/settings/sync_config_card.dart';
import '../widgets/adaptive/adaptive_card_header.dart';
import '../widgets/adaptive/responsive_icon_button.dart';
import '../version.dart';

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
  late TextEditingController _syncServerUrlController;
  late TextEditingController _syncUserIdController;

  @override
  void initState() {
    super.initState();
    // Pre-populate fields from active State
    _appState = Provider.of<AppState>(context, listen: false);
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
    _syncServerUrlController = TextEditingController(
      text: _appState.syncServerUrl,
    );
    _syncUserIdController = TextEditingController(text: _appState.syncUserId);

    _appState.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    _appState.removeListener(_onStateChanged);
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _syncServerUrlController.dispose();
    _syncUserIdController.dispose();
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
    if (_syncServerUrlController.text != appState.syncServerUrl) {
      _syncServerUrlController.text = appState.syncServerUrl;
    }
    if (_syncUserIdController.text != appState.syncUserId) {
      _syncUserIdController.text = appState.syncUserId;
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
              // Panel 1: AI Provider Configuration navigation tile
              _buildAiProviderConfigTile(context, appState),
              const SizedBox(height: 20),

              // Panel 2: Language Selection
              LanguageCard(appState: appState),
              const SizedBox(height: 20),
              ThemeCard(appState: appState),
              const SizedBox(height: 20),
              NotificationsCard(appState: appState),
              const SizedBox(height: 20),

              // Panel 2.2: Gamification Configuration
              _buildGamificationConfigTile(context, appState),
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
              _buildVersionCard(context),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVersionCard(BuildContext context) {
    final colors = AppTheme.of(context);
    final localizations = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: AppTheme.premiumCardDecoration(
        context: context,
        color: colors.surface,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.info_outline,
                color: AppTheme.accentEmerald,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                localizations.appTitle,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 4,
            children: [
              Text(
                localizations.appVersion(AppVersion.version),
                style: TextStyle(color: colors.textSecondary, fontSize: 12),
              ),
              Text(
                '•',
                style: TextStyle(color: colors.textMuted, fontSize: 12),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.commit, color: colors.textMuted, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    localizations.gitHash(AppVersion.commitHash),
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAiProviderConfigTile(BuildContext context, AppState appState) {
    final colors = AppTheme.of(context);
    final localizations = AppLocalizations.of(context)!;

    final providerName = appState.aiProvider.toUpperCase();
    final modelName = appState.aiModel;

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
            icon: Icons.key,
            iconColor: AppTheme.accentEmerald,
            title: localizations.configureAiProvider,
          ),
          const SizedBox(height: 10),
          Text(
            localizations.configureAiProviderDesc,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            decoration: BoxDecoration(
              color: colors.surfaceLight.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.insights,
                  color: AppTheme.accentEmerald,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    localizations.activeAiConfig(providerName, modelName),
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ResponsiveIconButton(
              icon: const Icon(
                Icons.tune,
                color: AppTheme.accentEmerald,
                size: 18,
              ),
              label: localizations.configureAiProvider,
              color: AppTheme.accentEmerald,
              isOutlined: true,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AISettingsPage(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGamificationConfigTile(BuildContext context, AppState appState) {
    final colors = AppTheme.of(context);
    final localizations = AppLocalizations.of(context)!;
    final statusText = appState.gamificationEnabled
        ? localizations.enabledLabel
        : localizations.disabledLabel;

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
            icon: Icons.emoji_events,
            iconColor: AppTheme.accentAmber,
            title: localizations.gamificationSettingsTitle,
          ),
          const SizedBox(height: 10),
          Text(
            localizations.gamificationSettingsDesc,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            decoration: BoxDecoration(
              color: colors.surfaceLight.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.sports_esports,
                  color: AppTheme.accentAmber,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    localizations.statusLabel(statusText),
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ResponsiveIconButton(
              icon: const Icon(
                Icons.settings,
                color: AppTheme.accentAmber,
                size: 18,
              ),
              label: localizations.gamificationConfigureBtn,
              color: AppTheme.accentAmber,
              isOutlined: true,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GamificationSettingsPage(),
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
