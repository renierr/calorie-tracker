import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/theme.dart';
import '../providers/app_state.dart';
import '../l10n/app_localizations.dart';
import '../widgets/adaptive/adaptive_card_header.dart';
import '../widgets/adaptive/responsive_icon_button.dart';

class CloudSettingsPage extends StatefulWidget {
  const CloudSettingsPage({super.key});

  @override
  State<CloudSettingsPage> createState() => _CloudSettingsPageState();
}

class _CloudSettingsPageState extends State<CloudSettingsPage> {
  late final AppState _appState;
  late TextEditingController _serverUrlController;
  late TextEditingController _userIdController;

  bool _isSaving = false;
  bool _isSyncingLocal = false;
  String? _syncMessage;
  bool _syncSuccess = true;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _appState = context.read<AppState>();
    _serverUrlController = TextEditingController(text: _appState.syncServerUrl);
    _userIdController = TextEditingController(text: _appState.syncUserId);
  }

  @override
  void dispose() {
    _serverUrlController.dispose();
    _userIdController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await _appState.saveSyncSettings(
        serverUrl: _serverUrlController.text.trim(),
        userId: _userIdController.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.prefsSaved),
          backgroundColor: AppTheme.accentEmerald,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save settings: $e'),
          backgroundColor: AppTheme.accentRed,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _triggerManualSync() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSyncingLocal = true;
      _syncMessage = null;
    });

    try {
      // First save settings so the sync service uses the latest entered values
      await _appState.saveSyncSettings(
        serverUrl: _serverUrlController.text.trim(),
        userId: _userIdController.text.trim(),
      );

      final results = await _appState.syncWithBackend(manual: true);

      if (!mounted) return;

      setState(() {
        _syncSuccess = true;
        if (results != null) {
          _syncMessage = AppLocalizations.of(
            context,
          )!.syncSuccess(results['pulled'] ?? 0, results['pushed'] ?? 0);
        } else {
          _syncMessage = 'Sync URL is empty.';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _syncSuccess = false;
        _syncMessage = AppLocalizations.of(context)!.syncFailed(e.toString());
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSyncingLocal = false;
        });
      }
    }
  }

  String _formatLastSynced(int? timestamp, BuildContext context) {
    if (timestamp == null) {
      return AppLocalizations.of(context)!.neverSynced;
    }
    final locale = Localizations.localeOf(context).toLanguageTag();
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final dateStr = DateFormat('MMM d, yyyy HH:mm:ss', locale).format(date);
    return AppLocalizations.of(context)!.lastSyncedLabel(dateStr);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final appState = context.watch<AppState>();
    final bool syncing = appState.isSyncing || _isSyncingLocal;
    final bool enabled = appState.syncEnabled;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.syncSettings)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Info description card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: AppTheme.premiumCardDecoration(
                    context: context,
                    color: colors.surfaceLight.withValues(alpha: 0.3),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.cloud_queue,
                        color: AppTheme.accentBlue,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.syncSettingsDesc,
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Card 1: Toggle Switch
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: AppTheme.premiumCardDecoration(
                    context: context,
                    color: colors.surface,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        l10n.syncSettings,
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        enabled ? l10n.enabledLabel : l10n.disabledLabel,
                        style: TextStyle(
                          color: enabled
                              ? AppTheme.accentEmerald
                              : colors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      activeThumbColor: AppTheme.accentEmerald,
                      activeTrackColor: AppTheme.accentEmerald.withValues(
                        alpha: 0.5,
                      ),
                      value: enabled,
                      onChanged: (bool val) {
                        appState.setSyncEnabled(val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Card 2: Configuration inputs
                AnimatedOpacity(
                  opacity: enabled ? 1.0 : 0.6,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: AppTheme.premiumCardDecoration(
                      context: context,
                      color: colors.surface,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AdaptiveCardHeader(
                          icon: Icons.settings_ethernet,
                          iconColor: AppTheme.accentBlue,
                          title: l10n.syncSettings,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _serverUrlController,
                          enabled: enabled,
                          keyboardType: TextInputType.url,
                          decoration: InputDecoration(
                            hintText: l10n.syncServerUrlHint,
                            labelText: l10n.syncServerUrl,
                            prefixIcon: Icon(
                              Icons.dns,
                              color: colors.textSecondary,
                              size: 18,
                            ),
                          ),
                          validator: (v) {
                            if (enabled && (v == null || v.trim().isEmpty)) {
                              return 'Server URL is required when sync is enabled';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _userIdController,
                          enabled: enabled,
                          decoration: InputDecoration(
                            hintText: l10n.syncUserIdHint,
                            labelText: l10n.syncUserId,
                            prefixIcon: Icon(
                              Icons.person,
                              color: colors.textSecondary,
                              size: 18,
                            ),
                          ),
                          validator: (v) {
                            if (enabled && (v == null || v.trim().isEmpty)) {
                              return 'User ID is required when sync is enabled';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Card 3: Sync operations & Status
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: AppTheme.premiumCardDecoration(
                    context: context,
                    color: colors.surface,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AdaptiveCardHeader(
                        icon: Icons.sync,
                        iconColor: AppTheme.accentBlue,
                        title: l10n.syncNowBtn,
                      ),
                      const SizedBox(height: 15),
                      Text(
                        _formatLastSynced(appState.lastSyncedTime, context),
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ResponsiveIconButton(
                          icon: syncing
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons.sync,
                                  color: Colors.white,
                                  size: 18,
                                ),
                          label: syncing ? l10n.syncingStatus : l10n.syncNowBtn,
                          color: AppTheme.accentBlue,
                          onPressed: (syncing || !enabled)
                              ? null
                              : _triggerManualSync,
                        ),
                      ),
                      if (_syncMessage != null) ...[
                        const SizedBox(height: 15),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: _syncSuccess
                                ? AppTheme.accentEmerald.withValues(alpha: 0.1)
                                : AppTheme.accentRed.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _syncSuccess
                                  ? AppTheme.accentEmerald.withValues(
                                      alpha: 0.3,
                                    )
                                  : AppTheme.accentRed.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _syncSuccess ? Icons.check_circle : Icons.error,
                                color: _syncSuccess
                                    ? AppTheme.accentEmerald
                                    : AppTheme.accentRed,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _syncMessage!,
                                  style: TextStyle(
                                    color: _syncSuccess
                                        ? AppTheme.accentEmerald
                                        : AppTheme.accentRed,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Bottom Save Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    icon: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.save),
                    label: Text(l10n.saveChanges),
                    onPressed: _isSaving ? null : _saveSettings,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
