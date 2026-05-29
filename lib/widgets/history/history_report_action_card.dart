import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../l10n/app_localizations.dart';

class HistoryReportActionCard extends StatelessWidget {
  final int totalCount;

  const HistoryReportActionCard({super.key, required this.totalCount});

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: AppTheme.premiumCardDecoration(
        context: context,
        color: colors.surfaceLight.withValues(alpha: 0.4),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            AppLocalizations.of(context)!.logsInFilter(totalCount),
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          Icon(Icons.filter_list, size: 16, color: colors.textSecondary),
        ],
      ),
    );
  }
}
