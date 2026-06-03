import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_selector/file_selector.dart';
import '../theme/theme.dart';
import '../providers/app_state.dart';
import '../models/meal_model.dart';
import '../l10n/app_localizations.dart';
import '../widgets/report_config_dialog.dart';
import '../widgets/history_filter_panel.dart';
import '../widgets/meal_history_card.dart';
import '../widgets/history/history_data_actions_card.dart';
import '../widgets/history/history_report_action_card.dart';
import '../widgets/history/history_empty_state.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  bool _isSelectionMode = false;
  final Set<int> _selectedMealIds = {};
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = context.read<AppState>();
      appState.loadFirstPageHistory(showLoading: false);
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<AppState>().fetchNextPageHistory();
    }
  }

  // Trigger Summary Report Config Modal
  Future<void> _showReportConfigDialog(
    BuildContext context,
    AppState appState,
    List<Meal> filteredMeals,
  ) async {
    final List<Meal> mealsToReport;
    if (_selectedMealIds.isNotEmpty) {
      mealsToReport = filteredMeals
          .where((m) => _selectedMealIds.contains(m.id))
          .toList();
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentEmerald),
          ),
        ),
      );
      mealsToReport = await appState.getMealsForFilter(includeImages: true);
      if (context.mounted) {
        Navigator.of(context).pop(); // dismiss loading
      }
    }

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (dialogCtx) => ReportConfigDialog(
        parentContext: context,
        filteredMeals: mealsToReport,
        filterType: appState.historyFilter,
        customStartDate: appState.historyCustomStartDate,
        customEndDate: appState.historyCustomEndDate,
        onReportGenerated: () {
          setState(() {
            _isSelectionMode = false;
            _selectedMealIds.clear();
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final List<Meal> filteredMeals = appState.paginatedMeals;
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
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  // Import/Export Action Card
                  const SizedBox(height: 10),
                  HistoryDataActionsCard(
                    onImportPressed: () => _handleImport(context, appState),
                    onExportPressed: () =>
                        _handleExport(context, appState, filteredMeals),
                    onReportPressed: () => _showReportConfigDialog(
                      context,
                      appState,
                      filteredMeals,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Filter Toolbar Box
                  HistoryFilterPanel(
                    filterType: appState.historyFilter,
                    historyTypeFilter: appState.historyTypeFilter,
                    customStartDate: appState.historyCustomStartDate,
                    customEndDate: appState.historyCustomEndDate,
                    onFilterTypeChanged: (val) {
                      appState.setHistoryFilter(val);
                    },
                    onHistoryTypeFilterChanged: (val) {
                      appState.setHistoryTypeFilter(val);
                    },
                    onStartDateChanged: (val) {
                      appState.setHistoryCustomDates(
                        val,
                        appState.historyCustomEndDate,
                      );
                    },
                    onEndDateChanged: (val) {
                      appState.setHistoryCustomDates(
                        appState.historyCustomStartDate,
                        val,
                      );
                    },
                  ),
                  const SizedBox(height: 15),

                  // Top action button card if meals are loaded
                  if (filteredMeals.isNotEmpty) ...[
                    HistoryReportActionCard(
                      totalCount: appState.historyTotalCount,
                    ),
                    const SizedBox(height: 15),
                  ],
                ],
              ),
            ),

            // Active meals logs listing
            if (filteredMeals.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: const HistoryEmptyState(),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  if (index == filteredMeals.length) {
                    return appState.isFetchingMore
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppTheme.accentEmerald,
                                ),
                              ),
                            ),
                          )
                        : const SizedBox.shrink();
                  }

                  final Meal meal = filteredMeals[index];
                  final isSelected = _selectedMealIds.contains(meal.id);
                  return MealHistoryCard(
                    meal: meal,
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
                }, childCount: filteredMeals.length + 1),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
          ],
        ),
      ),
    );
  }

  Future<void> _handleImport(BuildContext context, AppState appState) async {
    try {
      final XFile? file = await openFile(
        acceptedTypeGroups: <XTypeGroup>[
          XTypeGroup(
            label: AppLocalizations.of(context)!.jsonBackup,
            extensions: <String>['json'],
          ),
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
    final loc = AppLocalizations.of(context)!;
    final List<Meal> mealsToExport;
    if (_selectedMealIds.isNotEmpty) {
      mealsToExport = filteredMeals
          .where((m) => _selectedMealIds.contains(m.id))
          .toList();
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentEmerald),
          ),
        ),
      );
      mealsToExport = await appState.getMealsForFilter(includeImages: true);
      if (context.mounted) {
        Navigator.of(context).pop(); // dismiss loading
      }
    }

    if (mealsToExport.isEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.noMealsToExport),
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
          XTypeGroup(label: loc.jsonBackup, extensions: <String>['json']),
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
}
