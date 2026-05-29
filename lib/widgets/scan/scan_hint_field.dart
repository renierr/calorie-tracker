import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../l10n/app_localizations.dart';
import '../adaptive/adaptive_card_header.dart';

class ScanHintField extends StatelessWidget {
  final TextEditingController hintController;

  const ScanHintField({super.key, required this.hintController});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.premiumCardDecoration(context: context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdaptiveCardHeader(
            icon: Icons.lightbulb_outline,
            iconColor: AppTheme.accentEmerald,
            title: AppLocalizations.of(context)!.contextClue,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: hintController,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.contextHint,
            ),
          ),
        ],
      ),
    );
  }
}
