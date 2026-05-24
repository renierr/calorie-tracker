import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/theme.dart';
import '../../providers/app_state.dart';
import '../../l10n/app_localizations.dart';

class SyncConfigCard extends StatefulWidget {
  final TextEditingController serverUrlController;
  final TextEditingController userIdController;
  final AppState appState;

  const SyncConfigCard({
    super.key,
    required this.serverUrlController,
    required this.userIdController,
    required this.appState,
  });

  @override
  State<SyncConfigCard> createState() => _SyncConfigCardState();
}

class _SyncConfigCardState extends State<SyncConfigCard> {
  bool _isSyncingLocal = false;
  String? _syncMessage;
  bool _syncSuccess = true;

  Future<void> _triggerManualSync() async {
    setState(() {
      _isSyncingLocal = true;
      _syncMessage = null;
    });

    try {
      // First save settings so the sync service uses the latest entered values
      await widget.appState.saveSyncSettings(
        serverUrl: widget.serverUrlController.text.trim(),
        userId: widget.userIdController.text.trim(),
      );

      final results = await widget.appState.syncWithBackend(manual: true);

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
    final bool syncing = widget.appState.isSyncing || _isSyncingLocal;
    final bool enabled = widget.appState.syncEnabled;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.premiumCardDecoration(
        context: context,
        color: colors.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.cloud_sync,
                color: AppTheme.accentBlue,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.syncSettings,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              Switch(
                value: widget.appState.syncEnabled,
                activeTrackColor: AppTheme.accentEmerald.withValues(alpha: 0.5),
                activeThumbColor: AppTheme.accentEmerald,
                onChanged: (val) {
                  widget.appState.setSyncEnabled(val);
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            AppLocalizations.of(context)!.syncSettingsDesc,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: widget.serverUrlController,
            enabled: enabled,
            keyboardType: TextInputType.url,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.syncServerUrlHint,
              labelText: AppLocalizations.of(context)!.syncServerUrl,
              prefixIcon: Icon(
                Icons.dns,
                color: colors.textSecondary,
                size: 18,
              ),
            ),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: widget.userIdController,
            enabled: enabled,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.syncUserIdHint,
              labelText: AppLocalizations.of(context)!.syncUserId,
              prefixIcon: Icon(
                Icons.person,
                color: colors.textSecondary,
                size: 18,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _formatLastSynced(widget.appState.lastSyncedTime, context),
                style: TextStyle(color: colors.textSecondary, fontSize: 11),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: (syncing || !enabled) ? null : _triggerManualSync,
                  icon: syncing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Icon(Icons.sync, size: 16),
                  label: Text(
                    syncing
                        ? AppLocalizations.of(context)!.syncingStatus
                        : AppLocalizations.of(context)!.syncNowBtn,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(44),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_syncMessage != null) ...[
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _syncSuccess
                    ? AppTheme.accentEmerald.withValues(alpha: 0.1)
                    : AppTheme.accentRed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _syncSuccess
                      ? AppTheme.accentEmerald.withValues(alpha: 0.3)
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
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
