import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../l10n/app_localizations.dart';

class ScanningOverlay extends StatelessWidget {
  final bool isScanning;

  const ScanningOverlay({super.key, required this.isScanning});

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context);

    return IgnorePointer(
      ignoring: !isScanning,
      child: AnimatedOpacity(
        opacity: isScanning ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          color: Colors.black.withValues(alpha: 0.8),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.accentEmerald,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  AppLocalizations.of(context)!.scanningTitle,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    AppLocalizations.of(context)!.scanningDesc,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colors.textSecondary, fontSize: 13),
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
