import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/theme.dart';
import '../../layout/adaptive_breakpoints.dart';
import '../../l10n/app_localizations.dart';

class ScanDatePickerTile extends StatelessWidget {
  final DateTime mealDate;
  final bool isEnabled;
  final ValueChanged<DateTime> onDateChanged;

  const ScanDatePickerTile({
    super.key,
    required this.mealDate,
    required this.isEnabled,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();

    return InkWell(
      onTap: !isEnabled
          ? null
          : () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: mealDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                onDateChanged(picked);
              }
            },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        decoration: BoxDecoration(
          color: colors.surfaceLight.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.08),
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isNarrow = AppBreakpoints.isCompactWidth(
              constraints.maxWidth,
            );
            final Widget staleDateIcon =
                (mealDate == DateTime.now().subtract(const Duration(days: 1)) ||
                    mealDate.isBefore(
                      DateTime.now().subtract(const Duration(days: 1)),
                    ))
                ? const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(
                      Icons.edit_calendar,
                      color: AppTheme.accentAmber,
                      size: 16,
                    ),
                  )
                : const SizedBox.shrink();

            if (isNarrow) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: AppTheme.accentEmerald,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        AppLocalizations.of(context)!.mealDate,
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          DateFormat.yMd(locale).format(mealDate),
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      staleDateIcon,
                    ],
                  ),
                ],
              );
            }

            return Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: AppTheme.accentEmerald,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Text(
                  AppLocalizations.of(context)!.mealDate,
                  style: TextStyle(color: colors.textSecondary, fontSize: 13),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    DateFormat.yMd(locale).format(mealDate),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                staleDateIcon,
              ],
            );
          },
        ),
      ),
    );
  }
}
