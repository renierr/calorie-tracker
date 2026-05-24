import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/meal_model.dart';

final PdfColor pdfEmerald = PdfColor.fromHex('#10B981');

class PdfService {
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd HH:mm');

  // Generate and download/print a report for a single meal
  static Future<void> generateSingleMealPdf(Meal meal, int calorieGoal) async {
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
                      'Nutritional Meal Report',
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
                  'Logged on: ${_dateFormat.format(DateTime.fromMillisecondsSinceEpoch(meal.timestamp))}',
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
                            'Calories',
                            '${meal.calories} kcal',
                            isHeader: true,
                          ),
                          _buildDetailRow('Protein', '${meal.protein} g'),
                          _buildDetailRow('Carbs', '${meal.carbs} g'),
                          _buildDetailRow('Fat', '${meal.fat} g'),
                          _buildDetailRow(
                            'AI Confidence',
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
                    'AI Analysis & Notes',
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

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Meal-Report-${meal.shortId}.pdf',
    );
  }

  // Generate and print a summary report over multiple meals (daily or date range)
  static Future<void> generateSummaryReport({
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

            // Performance Cards Grid
            pw.Row(
              children: [
                _buildSummaryStatCard(
                  'Calories',
                  '$totalCalories / $calorieGoal kcal',
                  totalCalories <= calorieGoal ? pdfEmerald : PdfColors.amber,
                ),
                pw.SizedBox(width: 10),
                _buildSummaryStatCard(
                  'Protein',
                  '${totalProtein}g / ${proteinGoal}g',
                  PdfColors.blue,
                ),
                pw.SizedBox(width: 10),
                _buildSummaryStatCard(
                  'Carbs',
                  '${totalCarbs}g / ${carbsGoal}g',
                  PdfColors.orange,
                ),
                pw.SizedBox(width: 10),
                _buildSummaryStatCard(
                  'Fat',
                  '${totalFat}g / ${fatGoal}g',
                  PdfColors.red,
                ),
              ],
            ),
            pw.SizedBox(height: 25),

            // Custom User Notes Section
            if (userNotes.trim().isNotEmpty) ...[
              pw.Text(
                'Report Comments',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  border: pw.Border(
                    left: pw.BorderSide(color: pdfEmerald, width: 3),
                  ),
                ),
                child: pw.Text(
                  userNotes,
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontStyle: pw.FontStyle.italic,
                  ),
                ),
              ),
              pw.SizedBox(height: 25),
            ],

            // Meals Listing Table
            pw.Text(
              'Logged Meal Listing',
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),

            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              columnWidths: const {
                0: pw.FlexColumnWidth(3), // Date/Time
                1: pw.FlexColumnWidth(5), // Meal Name
                2: pw.FlexColumnWidth(2), // Calories
                3: pw.FlexColumnWidth(1.5), // Protein
                4: pw.FlexColumnWidth(1.5), // Carbs
                5: pw.FlexColumnWidth(1.5), // Fat
                6: pw.FlexColumnWidth(1.5), // Confidence
              },
              children: [
                // Table Header
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    _buildTableCell('Time', isHeader: true),
                    _buildTableCell('Meal Name', isHeader: true),
                    _buildTableCell('Calories', isHeader: true),
                    _buildTableCell('Prot', isHeader: true),
                    _buildTableCell('Carb', isHeader: true),
                    _buildTableCell('Fat', isHeader: true),
                    _buildTableCell('Conf', isHeader: true),
                  ],
                ),
                // Table Rows
                ...meals.map((meal) {
                  final date = DateTime.fromMillisecondsSinceEpoch(
                    meal.timestamp,
                  );
                  return pw.TableRow(
                    children: [
                      _buildTableCell(_dateFormat.format(date)),
                      _buildTableCell(meal.foodName),
                      _buildTableCell('${meal.calories} kcal'),
                      _buildTableCell('${meal.protein}g'),
                      _buildTableCell('${meal.carbs}g'),
                      _buildTableCell('${meal.fat}g'),
                      _buildTableCell('${meal.confidence}%'),
                    ],
                  );
                }),
              ],
            ),
            pw.SizedBox(height: 30),

            // Image Gallery Block (if selected and meals have images)
            if (includeImages && meals.any((m) => m.imageBytes != null)) ...[
              pw.Text(
                'Meal Photo Album',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              _buildPhotoAlbumGrid(
                meals.where((m) => m.imageBytes != null).toList(),
              ),
            ],
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Summary-Nutritional-Report.pdf',
    );
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

  static pw.Widget _buildSummaryStatCard(
    String label,
    String val,
    PdfColor accentColor,
  ) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(8),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey300),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              label,
              style: const pw.TextStyle(color: PdfColors.grey600, fontSize: 8),
            ),
            pw.SizedBox(height: 3),
            pw.Text(
              val,
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 11,
                color: accentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        textAlign: isHeader ? pw.TextAlign.center : pw.TextAlign.left,
        style: pw.TextStyle(
          fontSize: 8,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  static pw.Widget _buildPhotoAlbumGrid(List<Meal> imageMeals) {
    // Generate simple rows of image cells
    final List<pw.Widget> rows = [];
    for (int i = 0; i < imageMeals.length; i += 3) {
      final List<pw.Widget> rowChildren = [];
      for (int j = 0; j < 3; j++) {
        final index = i + j;
        if (index < imageMeals.length) {
          final m = imageMeals[index];
          rowChildren.add(
            pw.Expanded(
              child: pw.Container(
                margin: const pw.EdgeInsets.all(4),
                padding: const pw.EdgeInsets.all(4),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(4),
                  ),
                ),
                child: pw.Column(
                  children: [
                    pw.Container(
                      height: 80,
                      child: pw.Image(
                        pw.MemoryImage(m.imageBytes!),
                        fit: pw.BoxFit.cover,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      m.foodName,
                      maxLines: 1,
                      style: const pw.TextStyle(fontSize: 7),
                    ),
                    pw.Text(
                      '${m.calories} kcal',
                      style: const pw.TextStyle(
                        fontSize: 6,
                        color: PdfColors.grey600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          rowChildren.add(pw.Expanded(child: pw.SizedBox()));
        }
      }
      rows.add(pw.Row(children: rowChildren));
    }

    return pw.Column(children: rows);
  }
}
