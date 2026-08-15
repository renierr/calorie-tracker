import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/app_state.dart';
import '../services/health_connect_nutrition_publisher.dart';
import '../services/health_connect_settings.dart';
import '../theme/theme.dart';
import '../widgets/settings/health_connect_publish_progress_dialog.dart';

class HealthConnectSettingsPage extends StatefulWidget {
  const HealthConnectSettingsPage({super.key});

  @override
  State<HealthConnectSettingsPage> createState() =>
      _HealthConnectSettingsPageState();
}

class _HealthConnectSettingsPageState extends State<HealthConnectSettingsPage> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final supported = Platform.isAndroid;
    final enabled = context.watch<AppState>().healthConnectEnabled;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.healthConnectTitle)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (!supported)
            _InfoCard(
              icon: Icons.devices_other_outlined,
              title: l10n.healthConnectUnavailableTitle,
              description: l10n.healthConnectUnavailableDescription,
            )
          else ...[
            _InfoCard(
              icon: Icons.restaurant_outlined,
              title: l10n.healthConnectMealsTitle,
              description: l10n.healthConnectMealsDescription,
            ),
            const SizedBox(height: 16),
            SwitchListTile.adaptive(
              secondary: const Icon(Icons.publish_outlined),
              title: Text(l10n.healthConnectEnableTitle),
              subtitle: Text(l10n.healthConnectEnableDescription),
              value: enabled,
              onChanged: _busy
                  ? null
                  : (value) =>
                        context.read<AppState>().setHealthConnectEnabled(value),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.health_and_safety_outlined),
              title: Text(l10n.healthConnectOpenTitle),
              subtitle: Text(l10n.healthConnectOpenDescription),
              trailing: const Icon(Icons.open_in_new),
              onTap: _busy ? null : _openHealthConnect,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.upload_outlined),
              title: Text(l10n.healthConnectPublishNowTitle),
              subtitle: Text(l10n.healthConnectPublishNowDescription),
              trailing: _busy ? const _Spinner() : null,
              onTap: _busy ? null : () => _publish(reconcile: false),
            ),
            ListTile(
              leading: const Icon(Icons.sync_outlined),
              title: Text(l10n.healthConnectReconcileTitle),
              subtitle: Text(l10n.healthConnectReconcileDescription),
              onTap: _busy ? null : () => _publish(reconcile: true),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(
                Icons.delete_forever_outlined,
                color: AppTheme.accentRed,
              ),
              title: Text(l10n.healthConnectRemoveTitle),
              subtitle: Text(l10n.healthConnectRemoveDescription),
              onTap: _busy ? null : _confirmRemove,
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _openHealthConnect() async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context)!;
    try {
      if (await HealthConnectSettings.open() && mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.healthConnectOpenFallback)),
        );
      }
    } catch (error) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.healthConnectOpenFailed(error.toString())),
          ),
        );
      }
    }
  }

  Future<void> _publish({required bool reconcile}) async {
    setState(() => _busy = true);
    HealthConnectPublishProgressDialog.show(context);
    final result = await context.read<AppState>().publishMealsToHealthConnect(
      reconcile: reconcile,
    );
    if (!mounted) return;
    setState(() => _busy = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(_messageFor(result))));
  }

  Future<void> _confirmRemove() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.healthConnectRemoveTitle),
        content: Text(l10n.healthConnectRemoveConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _busy = true);
    HealthConnectPublishProgressDialog.show(context);
    final result = await context
        .read<AppState>()
        .removeMealsFromHealthConnect();
    if (!mounted) return;
    setState(() => _busy = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(_messageFor(result))));
  }

  String _messageFor(HealthConnectPublishResult result) {
    final l10n = AppLocalizations.of(context)!;
    return switch (result.outcome) {
      HealthConnectPublishOutcome.ran =>
        result.failed == 0
            ? l10n.healthConnectPublishSuccess(result.published)
            : l10n.healthConnectPublishPartial(result.published, result.failed),
      HealthConnectPublishOutcome.noPermission =>
        l10n.healthConnectPermissionNeeded,
      HealthConnectPublishOutcome.unsupported =>
        l10n.healthConnectUnavailableDescription,
      HealthConnectPublishOutcome.failed => l10n.healthConnectPublishFailed,
    };
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppTheme.premiumCardDecoration(
        context: context,
        color: colors.surface,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.accentEmerald),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(color: colors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Spinner extends StatelessWidget {
  const _Spinner();

  @override
  Widget build(BuildContext context) => const SizedBox(
    width: 20,
    height: 20,
    child: CircularProgressIndicator(strokeWidth: 2),
  );
}
