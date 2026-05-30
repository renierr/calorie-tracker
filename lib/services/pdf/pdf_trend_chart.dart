import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../models/meal_model.dart';
import '../../l10n/app_localizations.dart';

class PdfTrendChartHelper {
  // Build and return the complete trend chart card widget
  static pw.Widget buildTrendChart({
    required List<Meal> meals,
    required AppLocalizations localizations,
    required PdfDocument pdfDocument,
  }) {
    // 1. Sort meals ascending by timestamp
    final sortedMeals = List<Meal>.from(meals)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // 2. Extract days and group calories
    final Map<String, int> dailyCalories = {};
    final DateFormat dayKeyFormat = DateFormat('yyyy-MM-dd');
    for (final m in sortedMeals) {
      final date = DateTime.fromMillisecondsSinceEpoch(m.timestamp);
      final key = dayKeyFormat.format(date);
      dailyCalories[key] =
          (dailyCalories[key] ?? 0) + (m.isActivity ? -m.calories : m.calories);
    }
    final List<String> dates = dailyCalories.keys.toList()..sort();

    // 3. Populate trend data
    final List<double> chartValues = [];
    final List<String> chartLabels = [];

    if (dates.length > 1) {
      // Group by day for multi-day logs
      for (final dateStr in dates) {
        chartValues.add(dailyCalories[dateStr]!.toDouble());
        final date = dayKeyFormat.parse(dateStr);
        chartLabels.add(DateFormat('MM-dd').format(date));
      }
    } else {
      // Show sequential individual meals if single day or minimal entries
      for (final m in sortedMeals) {
        chartValues.add((m.isActivity ? -m.calories : m.calories).toDouble());
        final date = DateTime.fromMillisecondsSinceEpoch(m.timestamp);
        chartLabels.add(DateFormat('HH:mm').format(date));
      }
    }

    // Edge case: no data or 1 item
    if (chartValues.isEmpty) {
      return pw.SizedBox();
    }
    if (chartValues.length == 1) {
      chartValues.insert(0, 0.0);
      chartLabels.insert(0, '');
    }

    final double minVal = chartValues.reduce((a, b) => a < b ? a : b);
    final double maxVal = chartValues.reduce((a, b) => a > b ? a : b);
    final double range = maxVal - minVal;
    final double divisor = range == 0 ? 1.0 : range;

    final PdfColor pdfEmerald = PdfColor.fromHex('#10B981');
    final PdfColor gridColor = PdfColor.fromHex('#E5E7EB');
    final PdfColor textMuted = PdfColor.fromHex('#9CA3AF');

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 25),
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        border: pw.Border.all(color: PdfColor.fromHex('#E5E7EB'), width: 1),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            localizations.pdfCalorieTrend,
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey700,
            ),
          ),
          pw.SizedBox(height: 12),
          // Chart drawing container
          pw.Container(
            height: 90,
            width: double.infinity,
            child: pw.CustomPaint(
              painter: (PdfGraphics canvas, PdfPoint size) {
                const double leftMargin = 45.0; // wider to clear Y axis text
                const double rightMargin = 15.0;
                const double topMargin = 10.0;
                const double bottomMargin = 12.0;

                final double usableWidth = size.x - leftMargin - rightMargin;
                final double usableHeight = size.y - topMargin - bottomMargin;
                final double widthBetweenPoints =
                    usableWidth / (chartValues.length - 1);

                final PdfFont helveticaFont = PdfFont.helvetica(pdfDocument);

                // Draw horizontal grid lines & Y labels
                canvas.setLineWidth(0.5);
                for (int i = 0; i <= 3; i++) {
                  final double y = bottomMargin + (i * usableHeight / 3);
                  canvas.setStrokeColor(gridColor);
                  canvas.drawLine(leftMargin, y, size.x - rightMargin, y);
                  canvas.strokePath();

                  // Y axis labels inside grid area
                  final double valAtTick = minVal + (range * i) / 3;
                  canvas.setColor(textMuted);
                  canvas.drawString(
                    helveticaFont,
                    6.0,
                    '${valAtTick.toInt()} kcal',
                    5.0,
                    y - 2.0,
                  );
                }

                // Plot point coordinates
                final List<PdfPoint> points = [];
                for (int i = 0; i < chartValues.length; i++) {
                  final double factor = (chartValues[i] - minVal) / divisor;
                  final double x = leftMargin + (i * widthBetweenPoints);
                  final double y = bottomMargin + (usableHeight * factor);
                  points.add(PdfPoint(x, y));
                }

                // Draw line between points
                if (points.length >= 2) {
                  canvas.setStrokeColor(pdfEmerald);
                  canvas.setLineWidth(1.5);
                  canvas.moveTo(points.first.x, points.first.y);
                  for (int i = 1; i < points.length; i++) {
                    canvas.lineTo(points[i].x, points[i].y);
                  }
                  canvas.strokePath();
                }

                // Draw point circle highlights
                canvas.setFillColor(pdfEmerald);
                for (final p in points) {
                  canvas.drawEllipse(p.x, p.y, 2.5, 2.5);
                  canvas.fillPath();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
