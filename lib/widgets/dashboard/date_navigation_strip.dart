import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../theme/theme.dart';
import '../../providers/app_state.dart';

class DateNavigationStrip extends StatelessWidget {
  const DateNavigationStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
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
          // Previous Day Button
          IconButton(
            icon: Icon(Icons.chevron_left, color: colors.textPrimary),
            onPressed: () => appState.previousDay(),
          ),

          // Date Text & Calendar Dialog Selector
          InkWell(
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: appState.selectedDate,
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
              if (picked != null) {
                appState.selectDate(picked);
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
                  formatter.format(appState.selectedDate),
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Next Day Button (Enabled unless selectedDate is today or future)
          IconButton(
            icon: Icon(Icons.chevron_right, color: colors.textPrimary),
            onPressed: () => appState.nextDay(),
          ),
        ],
      ),
    );
  }
}
