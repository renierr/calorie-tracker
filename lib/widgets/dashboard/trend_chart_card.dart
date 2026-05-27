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

    // Find body weights for each of these days (carry forward most recent)
    final List<double?> dailyWeights = last7Days.map((day) {
      final endOfThisDay = DateTime(
        day.year,
        day.month,
        day.day,
        23,
        59,
        59,
        999,
      ).millisecondsSinceEpoch;

      final mealsWithWeight = appState.meals
          .where(
            (m) =>
                m.deleted == 0 &&
                m.timestamp <= endOfThisDay &&
                m.weightKg != null,
          )
          .toList();

      if (mealsWithWeight.isEmpty) return null;

      // Sort descending to get the most recent weight
      mealsWithWeight.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return mealsWithWeight.first.weightKg;
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

    final hasWeights = dailyWeights.any((w) => w != null);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.premiumCardDecoration(context: context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return Wrap(
                spacing: 12,
                runSpacing: 8,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    AppLocalizations.of(context)!.calorieTrend,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildLegendItem(
                        color: AppTheme.accentEmerald,
                        label: AppLocalizations.of(context)!.caloriesKcal,
                        textColor: colors.textSecondary,
                      ),
                      if (hasWeights) ...[
                        const SizedBox(width: 12),
                        _buildLegendItem(
                          color: AppTheme.accentAmber,
                          label: AppLocalizations.of(context)!.bodyWeightTrend,
                          textColor: colors.textSecondary,
                        ),
                      ],
                    ],
                  ),
                ],
              );
            },
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
                weights: dailyWeights,
                selectedIndex: selectedIndex,
                goal: goal,
                maxVal: maxVal,
                goalLabel: goalLabel,
                selectedColor: AppTheme.accentEmerald,
                unselectedColor: AppTheme.accentBlue,
                weightColor: AppTheme.accentAmber,
                textColor: colors.textMuted,
                gridColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withValues(alpha: 0.04)
                    : Colors.black.withValues(alpha: 0.04),
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

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required Color textColor,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class LineChartPainter extends CustomPainter {
  final List<double> factors;
  final List<int> values;
  final List<double?> weights;
  final int selectedIndex;
  final int goal;
  final int maxVal;
  final String goalLabel;
  final Color selectedColor;
  final Color unselectedColor;
  final Color weightColor;
  final Color textColor;
  final Color gridColor;

  LineChartPainter({
    required this.factors,
    required this.values,
    required this.weights,
    required this.selectedIndex,
    required this.goal,
    required this.maxVal,
    required this.goalLabel,
    required this.selectedColor,
    required this.unselectedColor,
    required this.weightColor,
    required this.textColor,
    required this.gridColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (factors.isEmpty) return;

    // We add padding inside the canvas so text values and bottom dots do not get clipped
    const double horizontalPadding = 18.0;
    const double topPadding = 16.0;
    const double bottomPadding =
        16.0; // Slightly larger bottom padding for weight labels

    final double usableWidth = size.width - (horizontalPadding * 2);
    final double usableHeight = size.height - topPadding - bottomPadding;
    final double widthBetweenPoints = usableWidth / (factors.length - 1);

    final List<Offset> points = [];

    // Calculate coordinates for Calories
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

    // ----------------------------------------------------
    // Draw Calorie Gradient Fill and Bezier Curve
    // ----------------------------------------------------
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

    // ----------------------------------------------------
    // Draw Body Weight Bezier Curve (Secondary Axis)
    // ----------------------------------------------------
    final activeWeights = weights.whereType<double>().toList();
    if (activeWeights.isNotEmpty) {
      double minW = activeWeights.reduce((a, b) => a < b ? a : b);
      double maxW = activeWeights.reduce((a, b) => a > b ? a : b);
      if (minW == maxW) {
        minW = minW - 5.0;
        maxW = maxW + 5.0;
      }

      final List<Offset?> weightPoints = [];
      for (int i = 0; i < weights.length; i++) {
        final w = weights[i];
        if (w == null) {
          weightPoints.add(null);
        } else {
          final double x = horizontalPadding + (i * widthBetweenPoints);
          final double factor = (w - minW) / (maxW - minW);
          final double y = topPadding + (usableHeight * (1.0 - factor));
          weightPoints.add(Offset(x, y));
        }
      }

      // Draw weight segments
      final weightPath = Path();
      bool isFirst = true;
      for (int i = 0; i < weightPoints.length; i++) {
        final pt = weightPoints[i];
        if (pt == null) {
          isFirst = true;
          continue;
        }
        if (isFirst) {
          weightPath.moveTo(pt.dx, pt.dy);
          isFirst = false;
        } else {
          final prevPt = weightPoints[i - 1]!;
          final controlX1 = prevPt.dx + (pt.dx - prevPt.dx) / 2;
          final controlY1 = prevPt.dy;
          final controlX2 = prevPt.dx + (pt.dx - prevPt.dx) / 2;
          final controlY2 = pt.dy;
          weightPath.cubicTo(
            controlX1,
            controlY1,
            controlX2,
            controlY2,
            pt.dx,
            pt.dy,
          );
        }
      }

      final weightLinePaint = Paint()
        ..color = weightColor
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawPath(weightPath, weightLinePaint);

      // Draw weight dots and numeric labels (displayed below the dot)
      for (int i = 0; i < weightPoints.length; i++) {
        final pt = weightPoints[i];
        if (pt == null) continue;

        final isSelected = i == selectedIndex;
        final dotPaint = Paint()
          ..color = weightColor
          ..style = PaintingStyle.fill;

        if (isSelected) {
          final glowPaint = Paint()
            ..color = weightColor.withValues(alpha: 0.3)
            ..style = PaintingStyle.fill;
          canvas.drawCircle(pt, 8.0, glowPaint);
        }

        canvas.drawCircle(pt, isSelected ? 4.0 : 3.0, dotPaint);

        // Label below dot
        final textSpan = TextSpan(
          text: '${weights[i]!.toStringAsFixed(1)} kg',
          style: TextStyle(
            color: isSelected ? weightColor : textColor,
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
          pt.dx - textPainter.width / 2,
          pt.dy + 6, // 6px beneath the dot
        );
        textPainter.paint(canvas, textOffset);
      }
    }

    // ----------------------------------------------------
    // Draw Calorie Dots & Labels (displayed above the dot)
    // ----------------------------------------------------
    for (int i = 0; i < points.length; i++) {
      final offset = points[i];
      final isSelected = i == selectedIndex;

      final dotPaint = Paint()
        ..color = isSelected ? selectedColor : unselectedColor
        ..style = PaintingStyle.fill;

      if (isSelected) {
        final glowPaint = Paint()
          ..color = selectedColor.withValues(alpha: 0.3)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(offset, 9.0, glowPaint);
      }

      canvas.drawCircle(offset, isSelected ? 4.5 : 3.5, dotPaint);

      // Calorie count label above dot
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
