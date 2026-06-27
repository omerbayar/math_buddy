import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  double _mean = 0;
  double _sigma = 1;
  int _shadingRegion = 1; // 1=±1σ, 2=±2σ, 3=±3σ

  static const _regions = [
    (label: '±1σ', pct: '68.27%', sigmas: 1),
    (label: '±2σ', pct: '95.45%', sigmas: 2),
    (label: '±3σ', pct: '99.73%', sigmas: 3),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 12),
          Expanded(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: _NormalCurvePainter(
                  mean: _mean,
                  sigma: _sigma,
                  shadingRegion: _shadingRegion,
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          _buildInfo(),
          _buildControls(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'İstatistik',
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

  Widget _buildInfo() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceUp),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatChip('μ', _mean.toStringAsFixed(2), AppColors.amberLight),
              _StatChip('σ', _sigma.toStringAsFixed(2), AppColors.graphPalette[0]),
              _StatChip('σ²', (_sigma * _sigma).toStringAsFixed(2), AppColors.graphPalette[1]),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _regions.map((r) {
              final selected = r.sigmas == _shadingRegion;
              return GestureDetector(
                onTap: () => setState(() => _shadingRegion = r.sigmas),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primaryGlow : AppColors.surfaceUp,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selected ? AppColors.primary : Colors.transparent,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        r.label,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: selected ? AppColors.primaryLight : AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        r.pct,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 11,
                          color: selected ? AppColors.primaryLight : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _ControlRow(
            label: 'μ  Ortalama',
            value: _mean,
            min: -5,
            max: 5,
            onChanged: (v) => setState(() => _mean = v),
            color: AppColors.amberLight,
            displayValue: _mean.toStringAsFixed(2),
          ),
          const SizedBox(height: 8),
          _ControlRow(
            label: 'σ  Std. Sapma',
            value: _sigma,
            min: 0.1,
            max: 3,
            onChanged: (v) => setState(() => _sigma = v),
            color: AppColors.graphPalette[0],
            displayValue: _sigma.toStringAsFixed(2),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip(this.label, this.value, this.color);

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
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _ControlRow extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final Color color;
  final String displayValue;

  const _ControlRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.color,
    required this.displayValue,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
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
            child: Slider(value: value.clamp(min, max), min: min, max: max, onChanged: onChanged),
          ),
        ),
        SizedBox(
          width: 40,
          child: Text(
            displayValue,
            style: GoogleFonts.jetBrainsMono(fontSize: 12, color: AppColors.textSecondary),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

// --- Painter ---

class _NormalCurvePainter extends CustomPainter {
  final double mean;
  final double sigma;
  final int shadingRegion;

  const _NormalCurvePainter({
    required this.mean,
    required this.sigma,
    required this.shadingRegion,
  });

  double _pdf(double x) {
    return (1 / (sigma * math.sqrt(2 * math.pi))) *
        math.exp(-0.5 * math.pow((x - mean) / sigma, 2));
  }

  @override
  void paint(Canvas canvas, Size size) {
    const padding = 32.0;
    final w = size.width - padding * 2;
    final h = size.height - padding * 2;

    final xRange = sigma * 4.5;
    final xMin = mean - xRange;
    final xMax = mean + xRange;
    final peak = _pdf(mean);

    Offset toScreen(double x, double y) => Offset(
          padding + (x - xMin) / (xMax - xMin) * w,
          padding + h - (y / (peak * 1.15)) * h,
        );

    // Shaded region
    final lo = mean - shadingRegion * sigma;
    final hi = mean + shadingRegion * sigma;

    final shadeColors = [
      AppColors.primary.withAlpha(60),
      AppColors.cyan.withAlpha(50),
      AppColors.graphPalette[3].withAlpha(40),
    ];
    final shadePaint = Paint()..color = shadeColors[shadingRegion - 1];

    final shadePath = Path();
    bool shadeStarted = false;
    const steps = 300;
    for (int i = 0; i <= steps; i++) {
      final x = xMin + (xMax - xMin) * i / steps;
      if (x < lo || x > hi) continue;
      final pt = toScreen(x, _pdf(x));
      if (!shadeStarted) {
        shadePath.moveTo(pt.dx, toScreen(x, 0).dy);
        shadePath.lineTo(pt.dx, pt.dy);
        shadeStarted = true;
      } else {
        shadePath.lineTo(pt.dx, pt.dy);
      }
    }
    if (shadeStarted) {
      final hiScreen = toScreen(hi.clamp(xMin, xMax), 0);
      shadePath.lineTo(hiScreen.dx, hiScreen.dy);
      shadePath.close();
      canvas.drawPath(shadePath, shadePaint);
    }

    // Axis
    final axisY = toScreen(0, 0).dy;
    canvas.drawLine(
      Offset(padding, axisY),
      Offset(size.width - padding, axisY),
      Paint()
        ..color = AppColors.textMuted
        ..strokeWidth = 1,
    );

    // Sigma lines
    for (int s = -3; s <= 3; s++) {
      if (s == 0) continue;
      final sx = toScreen(mean + s * sigma, 0).dx;
      canvas.drawLine(
        Offset(sx, axisY - 6),
        Offset(sx, axisY + 6),
        Paint()..color = AppColors.textMuted..strokeWidth = 1,
      );
      _paintLabel(canvas, '$sσ', Offset(sx - 8, axisY + 10), AppColors.textMuted, 9);
    }

    // Mean line
    final mx = toScreen(mean, 0).dx;
    canvas.drawLine(
      Offset(mx, toScreen(mean, peak).dy),
      Offset(mx, axisY),
      Paint()
        ..color = AppColors.amberLight.withAlpha(120)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke,
    );
    _paintLabel(canvas, 'μ', Offset(mx - 5, toScreen(mean, peak).dy - 16), AppColors.amberLight, 11);

    // Curve glow
    final glowPath = Path();
    bool glowStarted = false;
    for (int i = 0; i <= steps; i++) {
      final x = xMin + (xMax - xMin) * i / steps;
      final pt = toScreen(x, _pdf(x));
      if (!glowStarted) {
        glowPath.moveTo(pt.dx, pt.dy);
        glowStarted = true;
      } else {
        glowPath.lineTo(pt.dx, pt.dy);
      }
    }
    canvas.drawPath(
      glowPath,
      Paint()
        ..color = AppColors.primaryLight.withAlpha(80)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawPath(
      glowPath,
      Paint()
        ..color = AppColors.primaryLight
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round,
    );

    // Percentage label
    final sigmaColors = [AppColors.primary, AppColors.cyan, AppColors.graphPalette[3]];
    final pcts = ['68.27%', '95.45%', '99.73%'];
    final labelX = toScreen(mean, 0).dx;
    final labelY = toScreen(mean, peak / 2).dy;
    _paintLabel(canvas, pcts[shadingRegion - 1], Offset(labelX - 20, labelY), sigmaColors[shadingRegion - 1], 13);
  }

  void _paintLabel(Canvas canvas, String text, Offset pos, Color color, double size) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: color, fontSize: size)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, pos);
  }

  @override
  bool shouldRepaint(_NormalCurvePainter old) =>
      old.mean != mean || old.sigma != sigma || old.shadingRegion != shadingRegion;
}
