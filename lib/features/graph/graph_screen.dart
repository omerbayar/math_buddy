import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_localization.dart';
import '../../core/theme.dart';
import 'function_painter.dart';

class GraphScreen extends StatefulWidget {
  const GraphScreen({super.key});

  @override
  State<GraphScreen> createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> {
  final List<GraphFunction> _functions = [
    GraphFunction('sin(x)', AppColors.graphPalette[0]),
  ];
  final _controller = TextEditingController();
  Offset _center = Offset.zero;
  double _pixelsPerUnit = 60;
  Offset? _panStart;
  Offset? _centerAtPanStart;
  double? _scaleStart;
  double? _pxPerUnitAtScaleStart;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addFunction() {
    final expr = _controller.text.trim();
    if (expr.isEmpty) return;
    setState(() {
      _functions.add(GraphFunction(
        expr,
        AppColors.graphPalette[_functions.length % AppColors.graphPalette.length],
      ));
      _controller.clear();
    });
    FocusScope.of(context).unfocus();
  }

  void _removeFunction(int i) {
    setState(() => _functions.removeAt(i));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _buildHeader(),
          _buildFunctionList(),
          _buildInputRow(),
          Expanded(child: _buildCanvas()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Text(
            translate('graph_title'),
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
              letterSpacing: 0.5,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => setState(() {
              _center = Offset.zero;
              _pixelsPerUnit = 60;
            }),
            child: Row(
              children: [
                Icon(Icons.center_focus_strong_outlined, size: 14, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Text(translate('reset'), style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFunctionList() {
    if (_functions.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _functions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final fn = _functions[i];
          return GestureDetector(
            onLongPress: () => _removeFunction(i),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: fn.color.withAlpha(31),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: fn.color.withAlpha(102), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(color: fn.color, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    fn.expression,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 13,
                      color: fn.color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 15,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: translate('graph_input_hint'),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
                hintStyle: GoogleFonts.jetBrainsMono(color: AppColors.textMuted, fontSize: 13),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                prefixText: 'y = ',
                prefixStyle: GoogleFonts.jetBrainsMono(color: AppColors.textMuted, fontSize: 13),
              ),
              onSubmitted: (_) => _addFunction(),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _addFunction,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: AppColors.primaryGlow, blurRadius: 10)],
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCanvas() {
    return GestureDetector(
      onScaleStart: (d) {
        _panStart = d.focalPoint;
        _centerAtPanStart = _center;
        _scaleStart = d.pointerCount == 2 ? 1.0 : null;
        _pxPerUnitAtScaleStart = _pixelsPerUnit;
      },
      onScaleUpdate: (d) {
        setState(() {
          // Pan
          if (_panStart != null && _centerAtPanStart != null) {
            final delta = d.focalPoint - _panStart!;
            _center = _centerAtPanStart! - Offset(
              delta.dx / _pixelsPerUnit,
              -delta.dy / _pixelsPerUnit,
            );
          }
          // Zoom
          if (_scaleStart != null && d.scale != 1.0) {
            _pixelsPerUnit = (_pxPerUnitAtScaleStart! * d.scale).clamp(5.0, 800.0);
          }
        });
      },
      child: RepaintBoundary(
        child: CustomPaint(
          painter: FunctionPainter(
            functions: List.unmodifiable(_functions),
            center: _center,
            pixelsPerUnit: _pixelsPerUnit,
          ),
          child: Container(color: AppColors.bg),
        ),
      ),
    );
  }
}
