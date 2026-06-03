import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../theme/theme.dart';
import '../../providers/app_state.dart';

class DateNavigationStrip extends StatelessWidget {
  const DateNavigationStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedDate = context.select<AppState, DateTime>(
      (s) => s.selectedDate,
    );
    final now = DateTime.now();
    final DateFormat formatter = DateFormat.yMMMd(
      Localizations.localeOf(context).toLanguageTag(),
    );
    final colors = AppTheme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: AppTheme.premiumCardDecoration(context: context),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left, color: colors.textPrimary),
            onPressed: () => context.read<AppState>().previousDay(),
          ),
          InkWell(
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(now.year - 2),
                lastDate: DateTime(now.year + 1),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.dark(
                        primary: AppTheme.accentEmerald,
                        onPrimary: Colors.white,
                        surface: colors.surface,
                        onSurface: colors.textPrimary,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null && context.mounted) {
                context.read<AppState>().selectDate(picked);
              }
            },
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_month,
                  color: AppTheme.accentEmerald,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  formatter.format(selectedDate),
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right, color: colors.textPrimary),
            onPressed: () => context.read<AppState>().nextDay(),
          ),
        ],
      ),
    );
  }
}
