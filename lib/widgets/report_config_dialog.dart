import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/theme.dart';
import '../models/meal_model.dart';
import '../providers/app_state.dart';
import '../services/pdf_service.dart';
import '../l10n/app_localizations.dart';

class ReportConfigDialog extends StatefulWidget {
  final BuildContext? parentContext;
  final List<Meal> filteredMeals;
  final String filterType;
  final DateTime? customStartDate;
  final DateTime? customEndDate;
  final VoidCallback? onReportGenerated;

  const ReportConfigDialog({
    super.key,
    this.parentContext,
    required this.filteredMeals,
    required this.filterType,
    this.customStartDate,
    this.customEndDate,
    this.onReportGenerated,
  });

  @override
  State<ReportConfigDialog> createState() => _ReportConfigDialogState();
}

class _ReportConfigDialogState extends State<ReportConfigDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _notesController;
  bool _includeImages = true;
  bool _isTitleInitialized = false;
  String _pdfTypeFilter = 'all';

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isTitleInitialized) {
      final localizations = AppLocalizations.of(context)!;
      _titleController.text = widget.filterType == 'today'
          ? localizations.pdfDailySummary
          : localizations.pdfAnalysisSummary;
      _isTitleInitialized = true;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context);
    return AlertDialog(
      backgroundColor: colors.surface,
      title: Text(
        AppLocalizations.of(context)!.generatePdf,
        style: TextStyle(
          color: colors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(
                context,
              )!.reportDescription(widget.filteredMeals.length),
              style: TextStyle(color: colors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.reportTitle,
              style: TextStyle(color: colors.textSecondary, fontSize: 11),
            ),
            const SizedBox(height: 6),
            TextField(controller: _titleController),
            const SizedBox(height: 14),
            Text(
              AppLocalizations.of(context)!.reportComments,
              style: TextStyle(color: colors.textSecondary, fontSize: 11),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.addComments,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              AppLocalizations.of(context)!.includeInPdfReport,
              style: TextStyle(color: colors.textSecondary, fontSize: 11),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: _pdfTypeFilter,
              dropdownColor: colors.surface,
              style: TextStyle(color: colors.textPrimary, fontSize: 13),
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
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
                setState(() {
                  _pdfTypeFilter = val ?? 'all';
                });
              },
            ),
            const SizedBox(height: 14),
            CheckboxListTile(
              title: Text(
                AppLocalizations.of(context)!.includePhotos,
                style: TextStyle(color: colors.textPrimary, fontSize: 13),
              ),
              value: _includeImages,
              activeColor: AppTheme.accentEmerald,
              contentPadding: EdgeInsets.zero,
              onChanged: (val) {
                setState(() {
                  _includeImages = val ?? true;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            AppLocalizations.of(context)!.cancel,
            style: TextStyle(color: colors.textSecondary),
          ),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.picture_as_pdf),
          label: Text(AppLocalizations.of(context)!.generatePdfBtn),
          onPressed: () async {
            final navigator = Navigator.of(context);

            String rangeText = AppLocalizations.of(context)!.pdfActiveFilter;
            final locale = Localizations.localeOf(context).toLanguageTag();

            if (widget.filterType == 'today') {
              rangeText = AppLocalizations.of(
                context,
              )!.pdfDateRange(DateFormat.yMMMd(locale).format(DateTime.now()));
            } else if (widget.filterType == 'yesterday') {
              rangeText = AppLocalizations.of(context)!.pdfDateRange(
                DateFormat.yMMMd(
                  locale,
                ).format(DateTime.now().subtract(const Duration(days: 1))),
              );
            } else if (widget.filterType == 'week') {
              rangeText = AppLocalizations.of(context)!.pdfRange7Days;
            } else if (widget.filterType == 'favorites') {
              rangeText = AppLocalizations.of(context)!.favoriteMeals;
            } else if (widget.filterType == 'custom' &&
                widget.customStartDate != null &&
                widget.customEndDate != null) {
              final start =
                  widget.customStartDate!.isBefore(widget.customEndDate!)
                  ? widget.customStartDate!
                  : widget.customEndDate!;
              final end =
                  widget.customStartDate!.isBefore(widget.customEndDate!)
                  ? widget.customEndDate!
                  : widget.customStartDate!;
              rangeText = AppLocalizations.of(context)!.pdfRangeCustom(
                DateFormat.yMMMd(locale).format(end),
                DateFormat.yMMMd(locale).format(start),
              );
            } else {
              rangeText = AppLocalizations.of(context)!.pdfAllTime;
            }

            List<Meal> mealsToInclude = List.from(widget.filteredMeals);
            if (_pdfTypeFilter == 'meals') {
              mealsToInclude = mealsToInclude.where((m) => m.isMeal).toList();
            } else if (_pdfTypeFilter == 'activities') {
              mealsToInclude = mealsToInclude
                  .where((m) => m.isActivity)
                  .toList();
            }

            // Show a non-dismissible loading overlay dialog
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (dialogCtx) => PopScope(
                canPop: false,
                child: Center(
                  child: Card(
                    color: colors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 20,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(
                              AppTheme.accentEmerald,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            AppLocalizations.of(context)!.generatingPdf,
                            style: TextStyle(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );

            bool hasPopped = false;
            void safePopAll() {
              if (!hasPopped) {
                hasPopped = true;
                navigator.pop(); // pops loading overlay
                navigator.pop(); // pops ReportConfigDialog
              }
            }

            try {
              await PdfService.generateSummaryReport(
                context: widget.parentContext ?? context,
                meals: mealsToInclude,
                title: _titleController.text.trim(),
                timeframeStr: rangeText,
                userNotes: _notesController.text.trim(),
                includeImages: _includeImages,
                calorieGoal: context.read<AppState>().calorieGoal,
                proteinGoal: context.read<AppState>().proteinGoal,
                carbsGoal: context.read<AppState>().carbsGoal,
                fatGoal: context.read<AppState>().fatGoal,
                pdfTypeFilter: _pdfTypeFilter,
                onGenerated: () {
                  safePopAll();
                },
              );
            } finally {
              safePopAll();
            }

            if (widget.onReportGenerated != null) {
              widget.onReportGenerated!();
            }
          },
        ),
      ],
    );
  }
}
