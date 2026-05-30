import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../l10n/app_localizations.dart';
import '../adaptive/adaptive_action_group.dart';

class ScanVerificationActions extends StatelessWidget {
  final bool isEnabled;
  final bool isReEvaluating;
  final bool showReEvaluate;
  final VoidCallback onDiscard;
  final VoidCallback onReEvaluate;
  final VoidCallback onSave;

  const ScanVerificationActions({
    super.key,
    required this.isEnabled,
    required this.isReEvaluating,
    required this.showReEvaluate,
    required this.onDiscard,
    required this.onReEvaluate,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context);

    return AdaptiveActionGroup(
      spacing: 10,
      actions: [
        OutlinedButton(
          onPressed: isEnabled ? onDiscard : null,
          style: OutlinedButton.styleFrom(
            foregroundColor: colors.textPrimary,
            side: BorderSide(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white24
                  : Colors.black26,
            ),
            minimumSize: const Size.fromHeight(48),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            AppLocalizations.of(context)!.discard,
            maxLines: 2,
            textAlign: TextAlign.center,
          ),
        ),
        if (showReEvaluate)
          ElevatedButton(
            onPressed: isEnabled ? onReEvaluate : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentBlue,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(48),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isReEvaluating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.auto_awesome, size: 16),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          AppLocalizations.of(context)!.reEvaluate,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
          ),
        ElevatedButton(
          onPressed: isEnabled ? onSave : null,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
          ),
          child: Text(
            AppLocalizations.of(context)!.logAndSave,
            maxLines: 2,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
