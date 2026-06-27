import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/math_engine.dart';
import '../../core/theme.dart';

class GraphFunction {
  final String expression;
  final Color color;

  const GraphFunction(this.expression, this.color);
}

class FunctionPainter extends CustomPainter {
  final List<GraphFunction> functions;
  final Offset center;
  final double pixelsPerUnit;

  const FunctionPainter({
    required this.functions,
    required this.center,
    required this.pixelsPerUnit,
  });

  Offset mathToScreen(double x, double y, Size size) {
    return Offset(
      size.width / 2 + (x - center.dx) * pixelsPerUnit,
      size.height / 2 - (y - center.dy) * pixelsPerUnit,
    );
  }

  double screenToMathX(double sx, double width) {
    return center.dx + (sx - width / 2) / pixelsPerUnit;
  }

  double screenToMathY(double sy, double height) {
    return center.dy - (sy - height / 2) / pixelsPerUnit;
  }

  double _niceSpacing() {
    final raw = 80 / pixelsPerUnit;
    final mag = math.pow(10, (math.log(raw) / math.ln10).floor()).toDouble();
    final n = raw / mag;
    if (n < 1.5) return mag;
    if (n < 3.5) return 2 * mag;
    if (n < 7.5) return 5 * mag;
    return 10 * mag;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final spacing = _niceSpacing();
    _drawGrid(canvas, size, spacing);
    _drawAxes(canvas, size);
    _drawLabels(canvas, size, spacing);
    for (final fn in functions) {
      _drawFunction(canvas, size, fn);
    }
  }

  void _drawGrid(Canvas canvas, Size size, double spacing) {
    final paint = Paint()
      ..color = AppColors.surfaceUp
      ..strokeWidth = 0.5;

    final xStart = (screenToMathX(0, size.width) / spacing).floor() * spacing;
    final xEnd = screenToMathX(size.width, size.width);
    for (double x = xStart; x <= xEnd; x += spacing) {
      final sx = mathToScreen(x, 0, size).dx;
      canvas.drawLine(Offset(sx, 0), Offset(sx, size.height), paint);
    }

    final yEnd = screenToMathY(0, size.height);
    final yStart = (screenToMathY(size.height, size.height) / spacing).floor() * spacing;
    for (double y = yStart; y <= yEnd; y += spacing) {
      final sy = mathToScreen(0, y, size).dy;
      canvas.drawLine(Offset(0, sy), Offset(size.width, sy), paint);
    }
  }

  void _drawAxes(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.textMuted
      ..strokeWidth = 1.2;

    final origin = mathToScreen(0, 0, size);

    if (origin.dx >= 0 && origin.dx <= size.width) {
      canvas.drawLine(Offset(origin.dx, 0), Offset(origin.dx, size.height), paint);
    }
    if (origin.dy >= 0 && origin.dy <= size.height) {
      canvas.drawLine(Offset(0, origin.dy), Offset(size.width, origin.dy), paint);
    }
  }

  void _drawLabels(Canvas canvas, Size size, double spacing) {
    final xMathStart = screenToMathX(0, size.width);
    final xMathEnd = screenToMathX(size.width, size.width);
    final yMathStart = screenToMathY(size.height, size.height);
    final yMathEnd = screenToMathY(0, size.height);

    final origin = mathToScreen(0, 0, size);
    final labelY = (origin.dy + 14).clamp(4.0, size.height - 16.0);
    final labelX = (origin.dx + 4).clamp(4.0, size.width - 40.0);

    for (double x = (xMathStart / spacing).ceil() * spacing; x <= xMathEnd; x += spacing) {
      if (x.abs() < spacing * 0.01) continue;
      final sx = mathToScreen(x, 0, size).dx;
      _paintLabel(canvas, _fmt(x), Offset(sx - 12, labelY));
    }
    for (double y = (yMathStart / spacing).ceil() * spacing; y <= yMathEnd; y += spacing) {
      if (y.abs() < spacing * 0.01) continue;
      final sy = mathToScreen(0, y, size).dy;
      _paintLabel(canvas, _fmt(y), Offset(labelX, sy - 8));
    }
  }

  String _fmt(double v) {
    if (v == v.truncateToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(2).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  void _paintLabel(Canvas canvas, String text, Offset pos) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 9,
          fontFamily: 'monospace',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, pos);
  }

  void _drawFunction(Canvas canvas, Size size, GraphFunction fn) {
    final glowPaint = Paint()
      ..color = fn.color.withAlpha(64)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final linePaint = Paint()
      ..color = fn.color
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final paths = <Path>[];
    var current = Path();
    bool started = false;
    double? prevY;

    final steps = size.width.toInt();
    for (int px = 0; px <= steps; px++) {
      final mathX = screenToMathX(px.toDouble(), size.width);
      final mathY = MathEngine.evaluateForGraph(fn.expression, mathX);

      if (mathY == null) {
        if (started) paths.add(current);
        current = Path();
        started = false;
        prevY = null;
        continue;
      }

      // Süreksizlik (asimptot) tespiti: ardışık iki noktanın ekran Y farkı
      // tuval yüksekliğini aşıyorsa path'i kır. Eşik matematiksel birim
      // cinsinden: size.height / pixelsPerUnit (tam ekran yüksekliği kadar sıçrama).
      if (prevY != null && (mathY - prevY).abs() > size.height / pixelsPerUnit) {
        if (started) paths.add(current);
        current = Path();
        started = false;
      }

      final screen = mathToScreen(mathX, mathY, size);
      if (!started) {
        current.moveTo(screen.dx, screen.dy);
        started = true;
      } else {
        current.lineTo(screen.dx, screen.dy);
      }
      prevY = mathY;
    }
    if (started) paths.add(current);

    for (final p in paths) {
      canvas.drawPath(p, glowPaint);
      canvas.drawPath(p, linePaint);
    }
  }

  @override
  bool shouldRepaint(FunctionPainter old) =>
      old.center != center ||
      old.pixelsPerUnit != pixelsPerUnit ||
      old.functions != functions;
}
