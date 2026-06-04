import 'package:flutter/material.dart';
import '../../layout/adaptive_breakpoints.dart';
import '../../theme/theme.dart';
import '../../services/ai_analysis_result.dart';
import '../../l10n/app_localizations.dart';

class ScanVerificationHeader extends StatelessWidget {
  final bool isActivity;
  final AIAnalysisResult? scanResult;

  const ScanVerificationHeader({
    super.key,
    required this.isActivity,
    required this.scanResult,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isNarrow = AppBreakpoints.isCompactContentWidth(
          constraints.maxWidth,
        );
        return Wrap(
          spacing: 10,
          runSpacing: 8,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: isNarrow ? constraints.maxWidth : null,
              child: Text(
                isActivity
                    ? AppLocalizations.of(context)!.verifyActivityDetails
                    : AppLocalizations.of(context)!.verifyEstimates,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (scanResult != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.accentEmerald.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  AppLocalizations.of(context)!.aiMatch(scanResult!.confidence),
                  style: const TextStyle(
                    color: AppTheme.accentEmerald,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
