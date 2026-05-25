import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../models/meal_model.dart';
import '../../l10n/app_localizations.dart';

final PdfColor pdfEmerald = PdfColor.fromHex('#10B981');
final PdfColor pdfBlue = PdfColor.fromHex('#3B82F6');
final PdfColor pdfAmber = PdfColor.fromHex('#F59E0B');
final PdfColor pdfRed = PdfColor.fromHex('#EF4444');
final PdfColor pdfGrey = PdfColor.fromHex('#6B7280');

class PdfMealCardHelper {
  // Build a summary stat card (actuals only)
  static pw.Widget buildSummaryStatCard({
    required String label,
    required String value,
    required PdfColor accentColor,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        border: pw.Border.all(color: PdfColor.fromHex('#E5E7EB'), width: 1),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              color: pdfGrey,
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 12,
              color: accentColor,
            ),
          ),
        ],
      ),
    );
  }

  // Build a meal card replicating the history list card with image and details
  static pw.Widget buildMealCard({
    required Meal meal,
    required bool includeImages,
    required AppLocalizations localizations,
    required DateFormat dateFormat,
  }) {
    final mealDate = DateTime.fromMillisecondsSinceEpoch(meal.timestamp);
    final String dateStr = dateFormat.format(mealDate);

    // Parse macro labels using localizations
    final perGramStr = localizations.perGram(0, 0, 0);
    final cleanParts = perGramStr
        .split(' ')
        .where((s) => s.isNotEmpty)
        .toList();
    final pLabel = cleanParts.isNotEmpty
        ? cleanParts[0].replaceAll(':', '')
        : 'P';
    final cLabel = cleanParts.length > 2
        ? cleanParts[2].replaceAll(':', '')
        : 'C';
    final fLabel = cleanParts.length > 4
        ? cleanParts[4].replaceAll(':', '')
        : 'F';

    final hasImage = includeImages && meal.imageBytes != null;

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 12),
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        border: pw.Border.all(color: PdfColor.fromHex('#F3F4F6'), width: 1),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Header info: Time + shortId
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                dateStr,
                style: pw.TextStyle(
                  color: pdfGrey,
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 8,
                ),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 5,
                  vertical: 2,
                ),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(4),
                  ),
                ),
                child: pw.Text(
                  meal.shortId,
                  style: pw.TextStyle(color: pdfGrey, fontSize: 8),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 8),

          // Main horizontal content row
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Photo Thumbnail (if active and exists)
              if (hasImage) ...[
                pw.Container(
                  width: 55,
                  height: 55,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey200, width: 0.5),
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
                pw.SizedBox(width: 12),
              ],

              // Meal details and macro pills
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      meal.foodName,
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 12,
                        color: PdfColors.black,
                      ),
                    ),
                    pw.SizedBox(height: 6),
                    // Row of compact macro tags
                    pw.Row(
                      children: [
                        _buildCompactTag(
                          label: localizations.caloriesKcal.replaceAll(
                            ' (kcal)',
                            '',
                          ),
                          value: '${meal.calories}',
                          color: pdfEmerald,
                        ),
                        pw.SizedBox(width: 6),
                        _buildCompactTag(
                          label: pLabel,
                          value: '${meal.protein}g',
                          color: pdfBlue,
                        ),
                        pw.SizedBox(width: 6),
                        _buildCompactTag(
                          label: cLabel,
                          value: '${meal.carbs}g',
                          color: pdfAmber,
                        ),
                        pw.SizedBox(width: 6),
                        _buildCompactTag(
                          label: fLabel,
                          value: '${meal.fat}g',
                          color: pdfRed,
                        ),
                        pw.SizedBox(width: 10),
                        pw.Text(
                          localizations.aiMatch(meal.confidence),
                          style: pw.TextStyle(
                            fontSize: 7.5,
                            fontWeight: pw.FontWeight.bold,
                            color: pdfGrey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Meal Notes section if present
          if (meal.notes != null && meal.notes!.trim().isNotEmpty) ...[
            pw.SizedBox(height: 8),
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(8),
              decoration: const pw.BoxDecoration(
                color: PdfColors.grey50,
                borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
              ),
              child: pw.Text(
                meal.notes!,
                style: pw.TextStyle(
                  fontSize: 8,
                  color: PdfColors.grey700,
                  fontStyle: pw.FontStyle.italic,
                  lineSpacing: 1.2,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Internal helper for localized macro tags
  static pw.Widget _buildCompactTag({
    required String label,
    required String value,
    required PdfColor color,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: pw.BoxDecoration(
        color: color.shade(0.05),
        border: pw.Border.all(color: color.shade(0.15), width: 0.5),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Row(
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.Text(
            '$label: ',
            style: pw.TextStyle(
              fontSize: 7,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.black,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 7,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.black,
            ),
          ),
        ],
      ),
    );
  }
}
