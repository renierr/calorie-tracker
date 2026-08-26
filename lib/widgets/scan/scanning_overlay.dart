import 'dart:async';

import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../l10n/app_localizations.dart';

class ScanningOverlay extends StatefulWidget {
  final bool isScanning;
  final VoidCallback onCancel;

  const ScanningOverlay({
    super.key,
    required this.isScanning,
    required this.onCancel,
  });

  @override
  State<ScanningOverlay> createState() => _ScanningOverlayState();
}

class _ScanningOverlayState extends State<ScanningOverlay> {
  Timer? _cancelTimer;
  bool _showCancel = false;

  @override
  void initState() {
    super.initState();
    _updateCancelTimer();
  }

  @override
  void didUpdateWidget(covariant ScanningOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isScanning != widget.isScanning) {
      _updateCancelTimer();
    }
  }

  void _updateCancelTimer() {
    _cancelTimer?.cancel();
    _showCancel = false;
    if (!widget.isScanning) return;

    _cancelTimer = Timer(const Duration(seconds: 5), () {
      if (mounted && widget.isScanning) {
        setState(() => _showCancel = true);
      }
    });
  }

  @override
  void dispose() {
    _cancelTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context);

    return IgnorePointer(
      ignoring: !widget.isScanning,
      child: AnimatedOpacity(
        opacity: widget.isScanning ? 1.0 : 0.0,
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
                if (_showCancel) ...[
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    onPressed: widget.onCancel,
                    icon: const Icon(Icons.close),
                    label: Text(AppLocalizations.of(context)!.cancelScan),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.textPrimary,
                      side: BorderSide(color: colors.textSecondary),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
