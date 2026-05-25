import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/theme.dart';

void showNotificationDialog(
  BuildContext context,
  String message, {
  bool isError = false,
}) {
  showDialog(
    context: context,
    barrierColor: Colors.black26,
    builder: (BuildContext ctx) {
      Future.delayed(const Duration(milliseconds: 2500), () {
        if (ctx.mounted) {
          Navigator.of(ctx).pop();
        }
      });

      final colors = AppTheme.of(context);
      return Dialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: AppTheme.premiumCardDecoration(
            context: context,
            color: colors.surface,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isError ? Icons.error_outline : Icons.check_circle_outline,
                color: isError ? AppTheme.accentRed : AppTheme.accentEmerald,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
