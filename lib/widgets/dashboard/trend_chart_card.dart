import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/theme.dart';
import '../../providers/app_state.dart';
import '../../l10n/app_localizations.dart';

class TrendChartCard extends StatelessWidget {
  final AppState appState;

  const TrendChartCard({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    // Generate dates for the last 7 days including today
    final DateTime today = appState.selectedDate;
    final List<DateTime> last7Days = List.generate(7, (i) {
      return today.subtract(Duration(days: 6 - i));
    });

    // Find totals for each of these days
    final List<int> dailyTotals = last7Days.map((day) {
      return appState.meals
          .where((m) {
            final date = DateTime.fromMillisecondsSinceEpoch(m.timestamp);
            return date.year == day.year &&
                date.month == day.month &&
                date.day == day.day;
          })
          .fold(0, (sum, m) => sum + m.calories);
    }).toList();

    final int goal = appState.calorieGoal;
    final int maxVal = [goal, ...dailyTotals].reduce((a, b) => a > b ? a : b);
    final colors = AppTheme.of(context);

    // Calculate height factors for the line graph
    final List<double> factors = dailyTotals.map((calories) {
      return maxVal > 0 ? (calories / maxVal).clamp(0.0, 1.0) : 0.0;
    }).toList();

    // The active selected date is always the last item in our 7-day array
    const int selectedIndex = 6;
    final String goalLabel = AppLocalizations.of(context)!.trendGoal(goal);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.premiumCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.calorieTrend,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 25),

          // Custom Painted Elegant Line Chart
          SizedBox(
            height: 140,
            width: double.infinity,
            child: CustomPaint(
              painter: LineChartPainter(
                factors: factors,
                values: dailyTotals,
                selectedIndex: selectedIndex,
                goal: goal,
                maxVal: maxVal,
                goalLabel: goalLabel,
                selectedColor: AppTheme.accentEmerald,
                unselectedColor: AppTheme.accentBlue,
                textColor: colors.textMuted,
                gridColor: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Weekday Labels perfectly aligned
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (i) {
                final date = last7Days[i];
                final bool isSelectedDate = i == selectedIndex;
                final String weekday = DateFormat.E(
                  Localizations.localeOf(context).toLanguageTag(),
                ).format(date).substring(0, 2);

                return Expanded(
                  child: Text(
                    weekday,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelectedDate
                          ? AppTheme.accentEmerald
                          : colors.textSecondary,
                      fontWeight: isSelectedDate
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class LineChartPainter extends CustomPainter {
  final List<double> factors;
  final List<int> values;
  final int selectedIndex;
  final int goal;
  final int maxVal;
  final String goalLabel;
  final Color selectedColor;
  final Color unselectedColor;
  final Color textColor;
  final Color gridColor;

  LineChartPainter({
    required this.factors,
    required this.values,
    required this.selectedIndex,
    required this.goal,
    required this.maxVal,
    required this.goalLabel,
    required this.selectedColor,
    required this.unselectedColor,
    required this.textColor,
    required this.gridColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (factors.isEmpty) return;

    // We add padding inside the canvas so text values and bottom dots do not get clipped
    const double horizontalPadding = 18.0;
    const double topPadding = 16.0;
    const double bottomPadding = 8.0;

    final double usableWidth = size.width - (horizontalPadding * 2);
    final double usableHeight = size.height - topPadding - bottomPadding;
    final double widthBetweenPoints = usableWidth / (factors.length - 1);

    final List<Offset> points = [];

    // Calculate coordinates
    for (int i = 0; i < factors.length; i++) {
      final double x = horizontalPadding + (i * widthBetweenPoints);
      final double y = topPadding + (usableHeight * (1.0 - factors[i]));
      points.add(Offset(x, y));
    }

    // Draw horizontal grid lines
    final paintGrid = Paint()
      ..color = gridColor
      ..strokeWidth = 1.0;

    for (int i = 0; i <= 3; i++) {
      final double y = topPadding + (i * usableHeight / 3);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paintGrid);
    }

    // Draw dashed target goal line
    if (maxVal > 0) {
      final double targetFactor = (goal / maxVal).clamp(0.0, 1.0);
      final double targetY = topPadding + (usableHeight * (1.0 - targetFactor));

      final paintTargetLine = Paint()
        ..color = selectedColor.withValues(alpha: 0.4)
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke;

      const double dashWidth = 5.0;
      const double dashSpace = 3.0;
      double startX = 0.0;
      while (startX < size.width) {
        canvas.drawLine(
          Offset(startX, targetY),
          Offset(startX + dashWidth, targetY),
          paintTargetLine,
        );
        startX += dashWidth + dashSpace;
      }

      // Draw goal text label right above the dotted line, aligned to the left
      final textSpan = TextSpan(
        text: goalLabel,
        style: TextStyle(
          color: selectedColor.withValues(alpha: 0.75),
          fontSize: 8.5,
          fontWeight: FontWeight.bold,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: ui.TextDirection.ltr,
      );
      textPainter.layout();

      final textOffset = Offset(
        horizontalPadding,
        targetY - textPainter.height - 3,
      );
      textPainter.paint(canvas, textOffset);
    }

    // Draw smooth gradient filled area below curves
    if (points.length >= 2) {
      final fillPath = Path();
      fillPath.moveTo(points.first.dx, size.height - bottomPadding);

      // Interpolate smooth cubic curves
      for (int i = 0; i < points.length - 1; i++) {
        final p0 = points[i];
        final p1 = points[i + 1];
        final controlX1 = p0.dx + (p1.dx - p0.dx) / 2;
        final controlY1 = p0.dy;
        final controlX2 = p0.dx + (p1.dx - p0.dx) / 2;
        final controlY2 = p1.dy;
        fillPath.cubicTo(
          controlX1,
          controlY1,
          controlX2,
          controlY2,
          p1.dx,
          p1.dy,
        );
      }

      fillPath.lineTo(points.last.dx, size.height - bottomPadding);
      fillPath.close();

      final fillPaint = Paint()
        ..shader =
            LinearGradient(
              colors: [
                selectedColor.withValues(alpha: 0.18),
                selectedColor.withValues(alpha: 0.0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ).createShader(
              Rect.fromLTRB(
                0,
                topPadding,
                size.width,
                size.height - bottomPadding,
              ),
            )
        ..style = PaintingStyle.fill;

      canvas.drawPath(fillPath, fillPaint);
    }

    // Draw connecting bezier curve line
    if (points.length >= 2) {
      final linePath = Path();
      linePath.moveTo(points.first.dx, points.first.dy);

      for (int i = 0; i < points.length - 1; i++) {
        final p0 = points[i];
        final p1 = points[i + 1];
        final controlX1 = p0.dx + (p1.dx - p0.dx) / 2;
        final controlY1 = p0.dy;
        final controlX2 = p0.dx + (p1.dx - p0.dx) / 2;
        final controlY2 = p1.dy;
        linePath.cubicTo(
          controlX1,
          controlY1,
          controlX2,
          controlY2,
          p1.dx,
          p1.dy,
        );
      }

      final linePaint = Paint()
        ..shader = LinearGradient(
          colors: [unselectedColor, selectedColor],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ).createShader(Rect.fromLTRB(0, 0, size.width, size.height))
        ..strokeWidth = 3.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawPath(linePath, linePaint);
    }

    // Draw dots and text value labels
    for (int i = 0; i < points.length; i++) {
      final offset = points[i];
      final isSelected = i == selectedIndex;

      // Inner dot paint
      final dotPaint = Paint()
        ..color = isSelected ? selectedColor : unselectedColor
        ..style = PaintingStyle.fill;

      // Glow circle around selected dot
      if (isSelected) {
        final glowPaint = Paint()
          ..color = selectedColor.withValues(alpha: 0.3)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(offset, 9.0, glowPaint);
      }

      canvas.drawCircle(offset, isSelected ? 4.5 : 3.5, dotPaint);

      // Draw calorie count label above dot
      if (values[i] > 0) {
        final textSpan = TextSpan(
          text: '${values[i]}',
          style: TextStyle(
            color: isSelected ? selectedColor : textColor,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        );
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: ui.TextDirection.ltr,
        );
        textPainter.layout();

        final textOffset = Offset(
          offset.dx - textPainter.width / 2,
          offset.dy - textPainter.height - 6,
        );
        textPainter.paint(canvas, textOffset);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
