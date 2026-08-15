import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../layout/adaptive_breakpoints.dart';
import '../theme/theme.dart';
import '../l10n/app_localizations.dart';

class HistoryFilterPanel extends StatefulWidget {
  final String filterType;
  final String historyTypeFilter;
  final String searchQuery;
  final DateTime? customStartDate;
  final DateTime? customEndDate;
  final ValueChanged<String> onFilterTypeChanged;
  final ValueChanged<String> onHistoryTypeFilterChanged;
  final ValueChanged<String> onSearchQueryChanged;
  final ValueChanged<DateTime?> onStartDateChanged;
  final ValueChanged<DateTime?> onEndDateChanged;

  const HistoryFilterPanel({
    super.key,
    required this.filterType,
    required this.historyTypeFilter,
    required this.searchQuery,
    required this.customStartDate,
    required this.customEndDate,
    required this.onFilterTypeChanged,
    required this.onHistoryTypeFilterChanged,
    required this.onSearchQueryChanged,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
  });

  @override
  State<HistoryFilterPanel> createState() => _HistoryFilterPanelState();
}

class _HistoryFilterPanelState extends State<HistoryFilterPanel> {
  late final TextEditingController _searchController;
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
  }

  @override
  void didUpdateWidget(covariant HistoryFilterPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchQuery != _searchController.text) {
      _searchController.text = widget.searchQuery;
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: AppTheme.premiumCardDecoration(context: context),
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final bool isNarrow = AppBreakpoints.isNarrowContentWidth(
                constraints.maxWidth,
              );
              final dropdown = DropdownButton<String>(
                isExpanded: isNarrow,
                value: widget.filterType,
                dropdownColor: colors.surface,
                iconEnabledColor: colors.textPrimary,
                underline: const SizedBox(),
                items: [
                  DropdownMenuItem(
                    value: 'all',
                    child: Text(AppLocalizations.of(context)!.allTime),
                  ),
                  DropdownMenuItem(
                    value: 'today',
                    child: Text(AppLocalizations.of(context)!.today),
                  ),
                  DropdownMenuItem(
                    value: 'yesterday',
                    child: Text(AppLocalizations.of(context)!.yesterday),
                  ),
                  DropdownMenuItem(
                    value: 'week',
                    child: Text(AppLocalizations.of(context)!.last7Days),
                  ),
                  DropdownMenuItem(
                    value: 'favorites',
                    child: Text(AppLocalizations.of(context)!.favoriteMeals),
                  ),
                  DropdownMenuItem(
                    value: 'custom',
                    child: Text(AppLocalizations.of(context)!.customRange),
                  ),
                ],
                onChanged: (val) {
                  widget.onFilterTypeChanged(val ?? 'all');
                },
              );

              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.filter_list,
                          color: AppTheme.accentEmerald,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            AppLocalizations.of(context)!.filterTimeframe,
                            style: TextStyle(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    dropdown,
                  ],
                );
              }

              return Row(
                children: [
                  const Icon(
                    Icons.filter_list,
                    color: AppTheme.accentEmerald,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    AppLocalizations.of(context)!.filterTimeframe,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  dropdown,
                ],
              );
            },
          ),
          if (widget.filterType == 'custom') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: widget.customStartDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        widget.onStartDateChanged(picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surfaceLight.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.customStartDate == null
                            ? AppLocalizations.of(context)!.startDate
                            : DateFormat.yMd(
                                locale,
                              ).format(widget.customStartDate!),
                        style: TextStyle(
                          color: widget.customStartDate == null
                              ? colors.textMuted
                              : colors.textPrimary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: widget.customEndDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        widget.onEndDateChanged(picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surfaceLight.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.customEndDate == null
                            ? AppLocalizations.of(context)!.endDate
                            : DateFormat.yMd(
                                locale,
                              ).format(widget.customEndDate!),
                        style: TextStyle(
                          color: widget.customEndDate == null
                              ? colors.textMuted
                              : colors.textPrimary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
          const Divider(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final bool isNarrow = AppBreakpoints.isNarrowContentWidth(
                constraints.maxWidth,
              );
              final typeDropdown = DropdownButton<String>(
                isExpanded: isNarrow,
                value: widget.historyTypeFilter,
                dropdownColor: colors.surface,
                iconEnabledColor: colors.textPrimary,
                underline: const SizedBox(),
                items: [
                  DropdownMenuItem(
                    value: 'all',
                    child: Text(AppLocalizations.of(context)!.allLogs),
                  ),
                  DropdownMenuItem(
                    value: 'meals',
                    child: Text(AppLocalizations.of(context)!.mealsOnly),
                  ),
                  DropdownMenuItem(
                    value: 'activities',
                    child: Text(AppLocalizations.of(context)!.activitiesOnly),
                  ),
                ],
                onChanged: (val) {
                  widget.onHistoryTypeFilterChanged(val ?? 'all');
                },
              );

              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.category,
                          color: AppTheme.accentAmber,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            AppLocalizations.of(context)!.logTypeFilter,
                            style: TextStyle(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    typeDropdown,
                  ],
                );
              }

              return Row(
                children: [
                  const Icon(
                    Icons.category,
                    color: AppTheme.accentAmber,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    AppLocalizations.of(context)!.logTypeFilter,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  typeDropdown,
                ],
              );
            },
          ),
          const Divider(height: 24),
          TextField(
            controller: _searchController,
            onChanged: (query) {
              _searchDebounce?.cancel();
              _searchDebounce = Timer(const Duration(milliseconds: 250), () {
                widget.onSearchQueryChanged(query);
              });
            },
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.searchHistoryHint,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: widget.searchQuery.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      tooltip: AppLocalizations.of(context)!.clearSearch,
                      onPressed: () {
                        _searchDebounce?.cancel();
                        _searchController.clear();
                        widget.onSearchQueryChanged('');
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
