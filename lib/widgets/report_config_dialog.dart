import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/theme.dart';
import '../models/meal_model.dart';
import '../providers/app_state.dart';
import '../services/pdf_service.dart';
import '../l10n/app_localizations.dart';

class ReportConfigDialog extends StatefulWidget {
  final AppState appState;
  final List<Meal> filteredMeals;
  final String filterType;
  final DateTime? customStartDate;
  final DateTime? customEndDate;
  final VoidCallback? onReportGenerated;

  const ReportConfigDialog({
    super.key,
    required this.appState,
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

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.filterType == 'today'
          ? 'Daily Nutritional Summary'
          : 'Nutritional Analysis Summary',
    );
    _notesController = TextEditingController();
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
              'This compiles a PDF summarizing the ${widget.filteredMeals.length} meals displayed in the active list.',
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
            Navigator.pop(context);

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
            } else if (widget.filterType == 'custom' &&
                widget.customStartDate != null &&
                widget.customEndDate != null) {
              rangeText = AppLocalizations.of(context)!.pdfRangeCustom(
                DateFormat.Md(locale).format(widget.customStartDate!),
                DateFormat.Md(locale).format(widget.customEndDate!),
              );
            } else {
              rangeText = AppLocalizations.of(context)!.pdfAllTime;
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.generatingPdf),
                duration: const Duration(seconds: 2),
              ),
            );

            await PdfService.generateSummaryReport(
              meals: widget.filteredMeals,
              title: _titleController.text.trim(),
              timeframeStr: rangeText,
              userNotes: _notesController.text.trim(),
              includeImages: _includeImages,
              calorieGoal: widget.appState.calorieGoal,
              proteinGoal: widget.appState.proteinGoal,
              carbsGoal: widget.appState.carbsGoal,
              fatGoal: widget.appState.fatGoal,
            );

            if (widget.onReportGenerated != null) {
              widget.onReportGenerated!();
            }
          },
        ),
      ],
    );
  }
}
