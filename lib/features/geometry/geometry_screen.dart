import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';

class GeometryScreen extends StatefulWidget {
  const GeometryScreen({super.key});

  @override
  State<GeometryScreen> createState() => _GeometryScreenState();
}

class _GeometryScreenState extends State<GeometryScreen>
    with SingleTickerProviderStateMixin {
  int _tab = 0;
  double _pythA = 3;
  double _pythB = 4;
  late AnimationController _circleAnim;

  @override
  void initState() {
    super.initState();
    _circleAnim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _circleAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _buildHeader(),
          _buildTabs(),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _tab == 0 ? _buildPythagoras() : _buildUnitCircle(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Geometri',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _Tab('Pisagor Teoremi', 0 == _tab, () => setState(() => _tab = 0)),
          const SizedBox(width: 8),
          _Tab('Birim Çember', 1 == _tab, () => setState(() => _tab = 1)),
        ],
      ),
    );
  }

  Widget _buildPythagoras() {
    final c = math.sqrt(_pythA * _pythA + _pythB * _pythB);
    return KeyedSubtree(
      key: const ValueKey('pyth'),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Expanded(
            child: CustomPaint(
              painter: _PythagorasPainter(a: _pythA, b: _pythB),
              child: const SizedBox.expand(),
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.surfaceUp),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _MathChip('a²', (_pythA * _pythA).toStringAsFixed(1), AppColors.graphPalette[0]),
                Text('+', style: GoogleFonts.inter(fontSize: 18, color: AppColors.textMuted)),
                _MathChip('b²', (_pythB * _pythB).toStringAsFixed(1), AppColors.graphPalette[1]),
                Text('=', style: GoogleFonts.inter(fontSize: 18, color: AppColors.textMuted)),
                _MathChip('c²', (c * c).toStringAsFixed(1), AppColors.graphPalette[2]),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
            child: _SliderRow('a', _pythA, 1, 10, (v) => setState(() => _pythA = v), AppColors.graphPalette[0]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
            child: _SliderRow('b', _pythB, 1, 10, (v) => setState(() => _pythB = v), AppColors.graphPalette[1]),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitCircle() {
    return KeyedSubtree(
      key: const ValueKey('circle'),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Expanded(
            child: AnimatedBuilder(
              animation: _circleAnim,
              builder: (_, __) => CustomPaint(
                painter: _UnitCirclePainter(angle: _circleAnim.value * 2 * math.pi),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.surfaceUp),
            ),
            child: AnimatedBuilder(
              animation: _circleAnim,
              builder: (_, __) {
                final angle = _circleAnim.value * 2 * math.pi;
                final deg = (angle * 180 / math.pi).toStringAsFixed(1);
                final sinV = math.sin(angle).toStringAsFixed(4);
                final cosV = math.cos(angle).toStringAsFixed(4);
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _MathChip('θ', '$deg°', AppColors.amberLight),
                    _MathChip('sin θ', sinV, AppColors.graphPalette[0]),
                    _MathChip('cos θ', cosV, AppColors.graphPalette[1]),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Tab(this.label, this.selected, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryGlow : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.surfaceUp,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: selected ? AppColors.primaryLight : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _MathChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MathChip(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted)),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _SliderRow extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final Color color;

  const _SliderRow(this.label, this.value, this.min, this.max, this.onChanged, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 20,
          child: Text(
            label,
            style: GoogleFonts.jetBrainsMono(fontSize: 14, color: color, fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: color,
              thumbColor: color,
              overlayColor: color.withAlpha(50),
              inactiveTrackColor: AppColors.surfaceHigh,
            ),
            child: Slider(value: value, min: min, max: max, onChanged: onChanged),
          ),
        ),
        SizedBox(
          width: 36,
          child: Text(
            value.toStringAsFixed(1),
            style: GoogleFonts.jetBrainsMono(fontSize: 13, color: AppColors.textSecondary),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

// --- Painters ---

class _PythagorasPainter extends CustomPainter {
  final double a;
  final double b;

  const _PythagorasPainter({required this.a, required this.b});

  @override
  void paint(Canvas canvas, Size size) {
    final scale = math.min(size.width, size.height) * 0.22;
    final cx = size.width / 2;
    final cy = size.height / 2 + scale * 0.3;

    final p0 = Offset(cx - a * scale / 2, cy);
    final p1 = Offset(cx + a * scale / 2, cy);
    final p2 = Offset(cx - a * scale / 2, cy - b * scale);

    // Triangle fill
    final triPath = Path()
      ..moveTo(p0.dx, p0.dy)
      ..lineTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..close();
    canvas.drawPath(triPath, Paint()..color = AppColors.surfaceUp);

    // Square on side a (bottom)
    _drawSquare(canvas, p0, p1, AppColors.graphPalette[0], 'a² = ${(a * a).toStringAsFixed(0)}');

    // Square on side b (left vertical)
    _drawSquare(canvas, p2, p0, AppColors.graphPalette[1], 'b² = ${(b * b).toStringAsFixed(0)}');

    // Square on hypotenuse c
    final c = math.sqrt(a * a + b * b);
    _drawSquare(canvas, p1, p2, AppColors.graphPalette[2], 'c² = ${(c * c).toStringAsFixed(0)}');

    // Triangle outline
    canvas.drawPath(
      triPath,
      Paint()
        ..color = AppColors.textSecondary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Right angle marker
    final sq = 10.0;
    canvas.drawRect(
      Rect.fromPoints(Offset(p0.dx, p0.dy - sq), Offset(p0.dx + sq, p0.dy)),
      Paint()
        ..color = AppColors.textMuted
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Labels on triangle sides
    _label(canvas, 'a', Offset((p0.dx + p1.dx) / 2, p0.dy + 16), AppColors.graphPalette[0]);
    _label(canvas, 'b', Offset(p0.dx - 14, (p0.dy + p2.dy) / 2), AppColors.graphPalette[1]);
    final midC = Offset((p1.dx + p2.dx) / 2 + 12, (p1.dy + p2.dy) / 2);
    _label(canvas, 'c', midC, AppColors.graphPalette[2]);
  }

  void _drawSquare(Canvas canvas, Offset from, Offset to, Color color, String text) {
    final dx = to.dx - from.dx;
    final dy = to.dy - from.dy;
    final len = math.sqrt(dx * dx + dy * dy);
    if (len < 0.01) return;

    final nx = -dy / len;
    final ny = dx / len;

    final p0 = from;
    final p1 = to;
    final p2 = Offset(to.dx + nx * len, to.dy + ny * len);
    final p3 = Offset(from.dx + nx * len, from.dy + ny * len);

    final path = Path()
      ..moveTo(p0.dx, p0.dy)
      ..lineTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..lineTo(p3.dx, p3.dy)
      ..close();

    canvas.drawPath(path, Paint()..color = color.withAlpha(35));
    canvas.drawPath(
      path,
      Paint()
        ..color = color.withAlpha(120)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    final center = Offset(
      (p0.dx + p1.dx + p2.dx + p3.dx) / 4,
      (p0.dy + p1.dy + p2.dy + p3.dy) / 4,
    );
    _label(canvas, text, center, color, size: 11);
  }

  void _label(Canvas canvas, String text, Offset pos, Color color, {double size = 13}) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: size,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(_PythagorasPainter old) => old.a != a || old.b != b;
}

class _UnitCirclePainter extends CustomPainter {
  final double angle;

  const _UnitCirclePainter({required this.angle});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = math.min(size.width, size.height) * 0.35;

    // Axes
    final axisPaint = Paint()
      ..color = AppColors.textMuted
      ..strokeWidth = 1;
    canvas.drawLine(Offset(cx - r * 1.3, cy), Offset(cx + r * 1.3, cy), axisPaint);
    canvas.drawLine(Offset(cx, cy - r * 1.3), Offset(cx, cy + r * 1.3), axisPaint);

    // Circle
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..color = AppColors.surfaceUp
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    final px = cx + r * math.cos(angle);
    final py = cy - r * math.sin(angle);

    // sin projection (vertical, dashed-like)
    final sinPaint = Paint()
      ..color = AppColors.graphPalette[0]
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(px, cy), Offset(px, py), sinPaint);

    // cos projection (horizontal)
    final cosPaint = Paint()
      ..color = AppColors.graphPalette[1]
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(cx, py), Offset(px, py), cosPaint);

    // Angle arc
    const arcRadius = 24.0;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: arcRadius),
      -angle,
      angle,
      false,
      Paint()
        ..color = AppColors.amberLight
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Radius line
    canvas.drawLine(
      Offset(cx, cy),
      Offset(px, py),
      Paint()
        ..color = AppColors.textPrimary
        ..strokeWidth = 2,
    );

    // Point on circle
    canvas.drawCircle(
      Offset(px, py),
      6,
      Paint()..color = AppColors.primaryLight,
    );
    canvas.drawCircle(
      Offset(px, py),
      4,
      Paint()..color = AppColors.bg,
    );

    // Labels
    _label(canvas, 'sin θ', Offset(px + 8, (cy + py) / 2), AppColors.graphPalette[0]);
    _label(canvas, 'cos θ', Offset((cx + px) / 2, py - 16), AppColors.graphPalette[1]);
    _label(canvas, '1', Offset((cx + px) / 2 + 6, (cy + py) / 2 - 10), AppColors.textSecondary);

    // Tick marks at 0, 1, -1
    for (final (lbl, offset) in [
      ('1', Offset(cx + r + 4, cy + 4)),
      ('-1', Offset(cx - r - 18, cy + 4)),
      ('1', Offset(cx + 4, cy - r - 4)),
      ('-1', Offset(cx + 4, cy + r + 4)),
    ]) {
      _label(canvas, lbl, offset, AppColors.textMuted, size: 10);
    }
  }

  void _label(Canvas canvas, String text, Offset pos, Color color, {double size = 12}) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: color, fontSize: size)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, pos);
  }

  @override
  bool shouldRepaint(_UnitCirclePainter old) => old.angle != angle;
}
