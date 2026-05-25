import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/meal_model.dart';
import '../helpers/file_save_helper.dart';
import '../l10n/app_localizations.dart';
import 'pdf/pdf_meal_card.dart';
import 'pdf/pdf_trend_chart.dart';

final PdfColor pdfEmerald = PdfColor.fromHex('#10B981');

class PdfService {
  // Generate and download a report for a single meal
  static Future<void> generateSingleMealPdf(
    BuildContext context,
    Meal meal,
    int calorieGoal,
  ) async {
    final localizations = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final DateFormat localizedDateTimeFormat = DateFormat.yMMMd(
      locale,
    ).add_jm();

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(30),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      localizations.pdfSingleMealReport,
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      meal.shortId,
                      style: const pw.TextStyle(color: PdfColors.grey),
                    ),
                  ],
                ),
                pw.Divider(thickness: 1.5, color: pdfEmerald),
                pw.SizedBox(height: 20),

                // Meal Details
                pw.Text(
                  meal.foodName,
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  localizations.pdfLoggedOn(
                    localizedDateTimeFormat.format(
                      DateTime.fromMillisecondsSinceEpoch(meal.timestamp),
                    ),
                  ),
                  style: const pw.TextStyle(color: PdfColors.grey600),
                ),
                pw.SizedBox(height: 20),

                // Grid/Row for image and macros
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Macros info
                    pw.Expanded(
                      flex: 3,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow(
                            localizations.caloriesKcal.replaceAll(
                              ' (kcal)',
                              '',
                            ),
                            '${meal.calories} kcal',
                            isHeader: true,
                          ),
                          _buildDetailRow(
                            localizations.protein,
                            '${meal.protein} g',
                          ),
                          _buildDetailRow(
                            localizations.carbs,
                            '${meal.carbs} g',
                          ),
                          _buildDetailRow(localizations.fat, '${meal.fat} g'),
                          _buildDetailRow(
                            localizations.pdfAiConfidence,
                            '${meal.confidence}%',
                          ),
                        ],
                      ),
                    ),
                    pw.SizedBox(width: 20),
                    // Image Box
                    if (meal.imageBytes != null)
                      pw.Expanded(
                        flex: 2,
                        child: pw.Container(
                          height: 150,
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColors.grey300),
                            borderRadius: const pw.BorderRadius.all(
                              pw.Radius.circular(6),
                            ),
                          ),
                          child: pw.ClipRRect(
                            horizontalRadius: 6,
                            verticalRadius: 6,
                            child: pw.Image(
                              pw.MemoryImage(meal.imageBytes!),
                              fit: pw.BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                pw.SizedBox(height: 30),

                // Meal Notes
                if (meal.notes != null && meal.notes!.trim().isNotEmpty) ...[
                  pw.Text(
                    localizations.pdfNotes,
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.all(12),
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey100,
                      borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
                    ),
                    child: pw.Text(
                      meal.notes!,
                      style: const pw.TextStyle(fontSize: 11, lineSpacing: 1.5),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );

    try {
      final bytes = await pdf.save();
      final destPath = await FileSaveHelper.saveFile(
        suggestedName: 'Meal-Report-${meal.shortId}.pdf',
        bytes: bytes,
      );
      if (destPath == null || !context.mounted) return;

      FileSaveHelper.showSuccessNotification(
        context: context,
        savedPath: destPath,
        androidDownloadMessage: localizations.pdfExportedDownloads,
        generalMessageBuilder: (displayPath) =>
            localizations.pdfExportedTo(displayPath),
      );
    } catch (e) {
      if (!context.mounted) return;
      FileSaveHelper.showErrorNotification(
        context: context,
        errorMessage: localizations.pdfExportFailed(e.toString()),
      );
    }
  }

  // Generate and download a summary report over multiple meals (daily or date range)
  static Future<void> generateSummaryReport({
    required BuildContext context,
    required List<Meal> meals,
    required String title,
    required String timeframeStr,
    required String userNotes,
    required bool includeImages,
    required int calorieGoal,
    required int proteinGoal,
    required int carbsGoal,
    required int fatGoal,
  }) async {
    final pdf = pw.Document();

    final int totalCalories = meals.fold(0, (sum, m) => sum + m.calories);
    final int totalProtein = meals.fold(0, (sum, m) => sum + m.protein);
    final int totalCarbs = meals.fold(0, (sum, m) => sum + m.carbs);
    final int totalFat = meals.fold(0, (sum, m) => sum + m.fat);

    final localizations = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final DateFormat localizedDateTimeFormat = DateFormat.yMMMd(
      locale,
    ).add_jm();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(35),
        header: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    title,
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    timeframeStr,
                    style: const pw.TextStyle(
                      color: PdfColors.grey600,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              pw.Divider(thickness: 1, color: pdfEmerald),
              pw.SizedBox(height: 10),
            ],
          );
        },
        footer: (pw.Context context) {
          return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 15),
            child: pw.Text(
              'Page ${context.pageNumber} of ${context.pagesCount}',
              style: const pw.TextStyle(color: PdfColors.grey500, fontSize: 9),
            ),
          );
        },
        build: (pw.Context context) {
          return [
            pw.SizedBox(height: 10),

            // Performance Cards Wrap/Row
            pw.Row(
              children: [
                pw.Expanded(
                  child: PdfMealCardHelper.buildSummaryStatCard(
                    label: localizations.caloriesKcal.replaceAll(' (kcal)', ''),
                    value: '$totalCalories kcal',
                    accentColor: pdfEmerald,
                  ),
                ),
                pw.SizedBox(width: 8),
                pw.Expanded(
                  child: PdfMealCardHelper.buildSummaryStatCard(
                    label: localizations.protein,
                    value: '${totalProtein}g',
                    accentColor: pdfBlue,
                  ),
                ),
                pw.SizedBox(width: 8),
                pw.Expanded(
                  child: PdfMealCardHelper.buildSummaryStatCard(
                    label: localizations.carbs,
                    value: '${totalCarbs}g',
                    accentColor: pdfAmber,
                  ),
                ),
                pw.SizedBox(width: 8),
                pw.Expanded(
                  child: PdfMealCardHelper.buildSummaryStatCard(
                    label: localizations.fat,
                    value: '${totalFat}g',
                    accentColor: pdfRed,
                  ),
                ),
                pw.SizedBox(width: 8),
                pw.Expanded(
                  child: PdfMealCardHelper.buildSummaryStatCard(
                    label: localizations.pdfEntriesLabel,
                    value: '${meals.length}',
                    accentColor: pdfGrey,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 15),

            // Calorie Trend Chart
            PdfTrendChartHelper.buildTrendChart(
              meals: meals,
              localizations: localizations,
              pdfDocument: pdf.document,
            ),

            // Meals section header & entries following indicator
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  localizations.dayLogSummary,
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  localizations.pdfEntriesFollowing(meals.length),
                  style: pw.TextStyle(
                    fontSize: 8,
                    color: pdfGrey,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 10),

            // Custom User Notes Section (relocated between summary/trend and cards list)
            if (userNotes.trim().isNotEmpty) ...[
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(10),
                margin: const pw.EdgeInsets.only(bottom: 15),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  border: pw.Border(
                    left: pw.BorderSide(color: pdfEmerald, width: 3),
                  ),
                ),
                child: pw.Text(
                  userNotes,
                  style: pw.TextStyle(
                    fontSize: 9,
                    fontStyle: pw.FontStyle.italic,
                  ),
                ),
              ),
            ],

            // Meals Listing Cards
            ...meals.map((meal) {
              return PdfMealCardHelper.buildMealCard(
                meal: meal,
                includeImages: includeImages,
                localizations: localizations,
                dateFormat: localizedDateTimeFormat,
              );
            }),
          ];
        },
      ),
    );

    try {
      final bytes = await pdf.save();
      final destPath = await FileSaveHelper.saveFile(
        suggestedName: 'Summary-Nutritional-Report.pdf',
        bytes: bytes,
      );
      if (destPath == null || !context.mounted) return;

      FileSaveHelper.showSuccessNotification(
        context: context,
        savedPath: destPath,
        androidDownloadMessage: localizations.pdfExportedDownloads,
        generalMessageBuilder: (displayPath) =>
            localizations.pdfExportedTo(displayPath),
      );
    } catch (e) {
      if (!context.mounted) return;
      FileSaveHelper.showErrorNotification(
        context: context,
        errorMessage: localizations.pdfExportFailed(e.toString()),
      );
    }
  }

  // PDF Layout Helpers

  static pw.Widget _buildDetailRow(
    String label,
    String value, {
    bool isHeader = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: isHeader ? pdfEmerald : PdfColors.black,
            ),
          ),
        ],
      ),
    );
  }
}
