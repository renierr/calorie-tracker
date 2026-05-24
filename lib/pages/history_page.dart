import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_selector/file_selector.dart';
import '../layout/adaptive_breakpoints.dart';
import '../theme/theme.dart';
import '../providers/app_state.dart';
import '../models/meal_model.dart';
import '../l10n/app_localizations.dart';
import '../widgets/adaptive/adaptive_action_group.dart';
import '../widgets/report_config_dialog.dart';
import '../widgets/history_filter_panel.dart';
import '../widgets/meal_history_card.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String _filterType = 'all'; // 'all', 'today', 'yesterday', 'week', 'custom'
  DateTime? _customStartDate;
  DateTime? _customEndDate;
  bool _isSelectionMode = false;
  final Set<int> _selectedMealIds = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = Provider.of<AppState>(context, listen: false);
      setState(() {
        _filterType = appState.historyFilter;
      });
    });
  }

  // Filter logic matching active dropdown selections
  List<Meal> _getFilteredMeals(List<Meal> allMeals) {
    final now = DateTime.now();
    final todayMidnight = DateTime(now.year, now.month, now.day);

    switch (_filterType) {
      case 'today':
        return allMeals.where((m) {
          final date = DateTime.fromMillisecondsSinceEpoch(m.timestamp);
          return date.year == now.year &&
              date.month == now.month &&
              date.day == now.day;
        }).toList();

      case 'yesterday':
        final yesterday = now.subtract(const Duration(days: 1));
        return allMeals.where((m) {
          final date = DateTime.fromMillisecondsSinceEpoch(m.timestamp);
          return date.year == yesterday.year &&
              date.month == yesterday.month &&
              date.day == yesterday.day;
        }).toList();

      case 'week':
        final sevenDaysAgo = todayMidnight.subtract(const Duration(days: 6));
        return allMeals.where((m) {
          final date = DateTime.fromMillisecondsSinceEpoch(m.timestamp);
          return date.isAfter(sevenDaysAgo) ||
              date.millisecondsSinceEpoch ==
                  sevenDaysAgo.millisecondsSinceEpoch;
        }).toList();

      case 'custom':
        if (_customStartDate == null || _customEndDate == null) return allMeals;
        final start = DateTime(
          _customStartDate!.year,
          _customStartDate!.month,
          _customStartDate!.day,
        );
        final end = DateTime(
          _customEndDate!.year,
          _customEndDate!.month,
          _customEndDate!.day,
          23,
          59,
          59,
          999,
        );
        return allMeals.where((m) {
          final date = DateTime.fromMillisecondsSinceEpoch(m.timestamp);
          return date.isAfter(start) && date.isBefore(end);
        }).toList();

      case 'all':
      default:
        return allMeals;
    }
  }

  // Trigger Summary Report Config Modal
  void _showReportConfigDialog(
    BuildContext context,
    AppState appState,
    List<Meal> filteredMeals,
  ) {
    showDialog(
      context: context,
      builder: (context) => ReportConfigDialog(
        appState: appState,
        filteredMeals: filteredMeals,
        filterType: _filterType,
        customStartDate: _customStartDate,
        customEndDate: _customEndDate,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final List<Meal> filteredMeals = _getFilteredMeals(appState.meals);
    final colors = AppTheme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: _isSelectionMode
            ? Text(
                AppLocalizations.of(
                  context,
                )!.selectedCount(_selectedMealIds.length),
              )
            : Text(AppLocalizations.of(context)!.historyTitle),
        leading: _isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _isSelectionMode = false;
                    _selectedMealIds.clear();
                  });
                },
              )
            : null,
        actions: [
          if (!_isSelectionMode)
            IconButton(
              icon: const Icon(Icons.checklist),
              tooltip: AppLocalizations.of(context)!.selectMeals,
              onPressed: () {
                setState(() {
                  _isSelectionMode = true;
                });
              },
            )
          else
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedMealIds.clear();
                });
              },
              child: Text(
                AppLocalizations.of(context)!.deselectAll,
                style: TextStyle(color: colors.textSecondary),
              ),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool useFullPageScroll = AppBreakpoints.isPhoneWidth(
              constraints.maxWidth,
            );

            if (useFullPageScroll) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    // Filter Toolbar Box
                    const SizedBox(height: 10),
                    HistoryFilterPanel(
                      filterType: _filterType,
                      customStartDate: _customStartDate,
                      customEndDate: _customEndDate,
                      onFilterTypeChanged: (val) {
                        setState(() {
                          _filterType = val;
                        });
                        appState.setHistoryFilter(val);
                      },
                      onStartDateChanged: (val) {
                        setState(() {
                          _customStartDate = val;
                        });
                      },
                      onEndDateChanged: (val) {
                        setState(() {
                          _customEndDate = val;
                        });
                      },
                    ),
                    const SizedBox(height: 15),

                    // Import/Export Action Card
                    _buildDataActionsCard(context, appState, filteredMeals),
                    const SizedBox(height: 15),

                    // Top action button card if meals are loaded
                    if (filteredMeals.isNotEmpty) ...[
                      _buildReportActionCard(context, appState, filteredMeals),
                      const SizedBox(height: 15),
                    ],

                    // Active meals logs listing
                    if (filteredMeals.isEmpty)
                      _buildEmptyState()
                    else
                      ListView.builder(
                        itemCount: filteredMeals.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final Meal meal = filteredMeals[index];
                          final isSelected = _selectedMealIds.contains(meal.id);
                          return MealHistoryCard(
                            meal: meal,
                            appState: appState,
                            isSelectionMode: _isSelectionMode,
                            isSelected: isSelected,
                            onTap: () {
                              if (_isSelectionMode) {
                                setState(() {
                                  if (_selectedMealIds.contains(meal.id)) {
                                    _selectedMealIds.remove(meal.id);
                                  } else {
                                    _selectedMealIds.add(meal.id!);
                                  }
                                });
                              }
                            },
                            onLongPress: () {
                              if (!_isSelectionMode) {
                                setState(() {
                                  _isSelectionMode = true;
                                  _selectedMealIds.add(meal.id!);
                                });
                              }
                            },
                          );
                        },
                      ),
                    const SizedBox(height: 16),
                  ],
                ),
              );
            }

            return Column(
              children: [
                // Filter Toolbar Box
                const SizedBox(height: 10),
                HistoryFilterPanel(
                  filterType: _filterType,
                  customStartDate: _customStartDate,
                  customEndDate: _customEndDate,
                  onFilterTypeChanged: (val) {
                    setState(() {
                      _filterType = val;
                    });
                    appState.setHistoryFilter(val);
                  },
                  onStartDateChanged: (val) {
                    setState(() {
                      _customStartDate = val;
                    });
                  },
                  onEndDateChanged: (val) {
                    setState(() {
                      _customEndDate = val;
                    });
                  },
                ),
                const SizedBox(height: 15),

                // Import/Export Action Card
                _buildDataActionsCard(context, appState, filteredMeals),
                const SizedBox(height: 15),

                // Top action button card if meals are loaded
                if (filteredMeals.isNotEmpty) ...[
                  _buildReportActionCard(context, appState, filteredMeals),
                  const SizedBox(height: 15),
                ],

                // Active meals logs listing
                Expanded(
                  child: filteredMeals.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          itemCount: filteredMeals.length,
                          itemBuilder: (context, index) {
                            final Meal meal = filteredMeals[index];
                            final isSelected = _selectedMealIds.contains(
                              meal.id,
                            );
                            return MealHistoryCard(
                              meal: meal,
                              appState: appState,
                              isSelectionMode: _isSelectionMode,
                              isSelected: isSelected,
                              onTap: () {
                                if (_isSelectionMode) {
                                  setState(() {
                                    if (_selectedMealIds.contains(meal.id)) {
                                      _selectedMealIds.remove(meal.id);
                                    } else {
                                      _selectedMealIds.add(meal.id!);
                                    }
                                  });
                                }
                              },
                              onLongPress: () {
                                if (!_isSelectionMode) {
                                  setState(() {
                                    _isSelectionMode = true;
                                    _selectedMealIds.add(meal.id!);
                                  });
                                }
                              },
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDataActionsCard(
    BuildContext context,
    AppState appState,
    List<Meal> filteredMeals,
  ) {
    final colors = AppTheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: AppTheme.premiumCardDecoration(
        context: context,
        color: colors.surface,
      ),
      child: AdaptiveActionGroup(
        spacing: 10,
        actions: [
          OutlinedButton.icon(
            icon: const Icon(
              Icons.upload,
              size: 18,
              color: AppTheme.accentEmerald,
            ),
            label: Text(
              AppLocalizations.of(context)!.importLabel,
              maxLines: 2,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.accentEmerald,
                fontSize: 13,
              ),
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(44),
              side: const BorderSide(color: AppTheme.accentEmerald, width: 1.2),
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => _handleImport(context, appState),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.download, size: 18),
            label: Text(
              AppLocalizations.of(context)!.exportLabel,
              maxLines: 2,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13),
            ),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(44),
              backgroundColor: AppTheme.accentEmerald,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => _handleExport(context, appState, filteredMeals),
          ),
        ],
      ),
    );
  }

  Future<void> _handleImport(BuildContext context, AppState appState) async {
    try {
      final XFile? file = await openFile(
        acceptedTypeGroups: <XTypeGroup>[
          const XTypeGroup(label: 'JSON Backup', extensions: <String>['json']),
        ],
      );
      if (file == null) return;

      final String content = await file.readAsString();
      final int count = await appState.importMealsFromJson(content);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.importMealsSuccess(count),
          ),
          backgroundColor: AppTheme.accentEmerald,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.importMealsError(e.toString()),
          ),
          backgroundColor: AppTheme.accentRed,
        ),
      );
    }
  }

  Future<void> _handleExport(
    BuildContext context,
    AppState appState,
    List<Meal> filteredMeals,
  ) async {
    final List<Meal> mealsToExport;
    if (_selectedMealIds.isNotEmpty) {
      mealsToExport = appState.meals
          .where((m) => _selectedMealIds.contains(m.id))
          .toList();
    } else {
      mealsToExport = filteredMeals;
    }

    if (mealsToExport.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No meals found to export.'),
          backgroundColor: AppTheme.accentRed,
        ),
      );
      return;
    }

    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final FileSaveLocation? location = await getSaveLocation(
        suggestedName: 'nutriscan_export_$timestamp.json',
        acceptedTypeGroups: <XTypeGroup>[
          const XTypeGroup(label: 'JSON Backup', extensions: <String>['json']),
        ],
      );
      if (location == null) return;

      final String jsonContent = await appState.exportMealsToJson(
        mealsToExport,
      );
      final File file = File(location.path);
      await file.writeAsString(jsonContent);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.exportMealsSuccess),
          backgroundColor: AppTheme.accentEmerald,
        ),
      );

      setState(() {
        _isSelectionMode = false;
        _selectedMealIds.clear();
      });
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.exportMealsError(e.toString()),
          ),
          backgroundColor: AppTheme.accentRed,
        ),
      );
    }
  }

  Widget _buildReportActionCard(
    BuildContext context,
    AppState appState,
    List<Meal> filteredMeals,
  ) {
    final colors = AppTheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: AppTheme.premiumCardDecoration(
        context: context,
        color: colors.surfaceLight.withValues(alpha: 0.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.logsInFilter(filteredMeals.length),
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            AppLocalizations.of(context)!.compilePdf,
            style: TextStyle(color: colors.textMuted, fontSize: 11),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.summarize, size: 18),
              label: Text(
                AppLocalizations.of(context)!.reportPdf,
                maxLines: 2,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13),
              ),
              onPressed: () =>
                  _showReportConfigDialog(context, appState, filteredMeals),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(44),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final colors = AppTheme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today,
            color: colors.textMuted.withValues(alpha: 0.5),
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.noHistory,
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            AppLocalizations.of(context)!.noHistoryDesc,
            style: TextStyle(color: colors.textMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
