import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/app_state.dart';

class HealthConnectPublishProgressDialog extends StatelessWidget {
  const HealthConnectPublishProgressDialog({super.key});

  static void show(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const HealthConnectPublishProgressDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    if (!appState.isHealthConnectPublishing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) Navigator.of(context).pop();
      });
    }
    final l10n = AppLocalizations.of(context)!;
    final total = appState.healthConnectPublishTotal;
    final processed = appState.healthConnectPublishedCount;
    return PopScope(
      canPop: false,
      child: AlertDialog(
        title: Row(
          children: [
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(l10n.healthConnectPublishingTitle)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.healthConnectPublishingDescription),
            const SizedBox(height: 16),
            Text(
              l10n.healthConnectPublishingProgress(processed, total),
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: total == 0 ? null : processed / total,
            ),
          ],
        ),
      ),
    );
  }
}
