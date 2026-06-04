import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/stats_data.dart';
import '../adaptive/adaptive_card_header.dart';

class StatsStorageSection extends StatelessWidget {
  final StatsData data;

  const StatsStorageSection({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context);
    final l10n = AppLocalizations.of(context)!;

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
            icon: Icons.storage,
            iconColor: AppTheme.accentPurple,
            title: l10n.statsStorageTitle,
          ),
          const SizedBox(height: 16),
          _row(l10n.statsDbSize(data.dbSizeMB.toStringAsFixed(2)), colors),
          if (data.photoCount > 0) ...[
            const SizedBox(height: 8),
            _row(
              l10n.statsPhotos(
                data.photoCount.toString(),
                data.photoTotalMB.toStringAsFixed(2),
                data.photoAvgKB.toString(),
              ),
              colors,
            ),
          ],
          if (data.notesCount > 0) ...[
            const SizedBox(height: 8),
            _row(l10n.statsWithNotes(data.notesCount.toString()), colors),
          ],
        ],
      ),
    );
  }

  Widget _row(String text, AppThemeColors colors) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: AppTheme.accentPurple,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: colors.textPrimary, fontSize: 13),
          ),
        ),
      ],
    );
  }
}
