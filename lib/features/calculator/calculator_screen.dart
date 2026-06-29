import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_localization.dart';
import '../../core/theme.dart';
import '../../core/math_engine.dart';

enum _BtnType { number, operator, fn, constant, clear, del, equals }

class _Btn {
  final String label;
  final String display;
  final String eval;
  final _BtnType type;

  const _Btn(this.label, {String? display, String? eval, this.type = _BtnType.number})
      : display = display ?? label,
        eval = eval ?? label;
}

const _buttons = [
  // Row 1 - trig
  _Btn('sin', display: 'sin(', eval: 'sin(', type: _BtnType.fn),
  _Btn('cos', display: 'cos(', eval: 'cos(', type: _BtnType.fn),
  _Btn('tan', display: 'tan(', eval: 'tan(', type: _BtnType.fn),
  _Btn('ln', display: 'ln(', eval: 'ln(', type: _BtnType.fn),
  _Btn('^', type: _BtnType.operator),
  // Row 2 - inverse trig
  _Btn('sin⁻¹', display: 'sin⁻¹(', eval: 'arcsin(', type: _BtnType.fn),
  _Btn('cos⁻¹', display: 'cos⁻¹(', eval: 'arccos(', type: _BtnType.fn),
  _Btn('tan⁻¹', display: 'tan⁻¹(', eval: 'arctan(', type: _BtnType.fn),
  _Btn('√', display: '√(', eval: 'sqrt(', type: _BtnType.fn),
  _Btn('π', display: 'π', eval: 'pi', type: _BtnType.constant),
  // Row 3 - misc
  _Btn('(', type: _BtnType.constant),
  _Btn(')', type: _BtnType.constant),
  _Btn('e', type: _BtnType.constant),
  _Btn('C', type: _BtnType.clear),
  _Btn('⌫', display: '⌫', eval: '⌫', type: _BtnType.del),
  // Row 4
  _Btn('7'), _Btn('8'), _Btn('9'),
  _Btn('÷', eval: '/', type: _BtnType.operator),
  _Btn('%', eval: '/100', type: _BtnType.operator),
  // Row 5
  _Btn('4'), _Btn('5'), _Btn('6'),
  _Btn('×', eval: '*', type: _BtnType.operator),
  _Btn('x²', display: '²', eval: '^2', type: _BtnType.fn),
  // Row 6
  _Btn('1'), _Btn('2'), _Btn('3'),
  _Btn('−', eval: '-', type: _BtnType.operator),
  _Btn('|x|', display: '|', eval: 'abs(', type: _BtnType.fn),
  // Row 7
  _Btn('ans', display: 'ans', eval: 'ans', type: _BtnType.constant),
  _Btn('0'),
  _Btn('.'),
  _Btn('+', type: _BtnType.operator),
  _Btn('=', type: _BtnType.equals),
];

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _display = '';
  String _eval = '';
  String _result = '';
  String _lastAnswer = '0';
  final List<String> _history = [];

  void _onButton(_Btn btn) {
    HapticFeedback.lightImpact();
    setState(() {
      switch (btn.type) {
        case _BtnType.clear:
          _display = '';
          _eval = '';
          _result = '';
        case _BtnType.del:
          if (_display.isNotEmpty) {
            // Pop last logical token
            final tokens = _tokenize(_display);
            if (tokens.isNotEmpty) tokens.removeLast();
            _display = tokens.join();
          }
          if (_eval.isNotEmpty) {
            final tokens = _tokenize(_eval);
            if (tokens.isNotEmpty) tokens.removeLast();
            _eval = tokens.join();
          }
          _result = MathEngine.evaluate(_eval);
        case _BtnType.equals:
          if (_eval.isEmpty) return;
          final res = MathEngine.evaluate(_eval);
          if (res.isNotEmpty && res != translate('undefined')) {
            _history.insert(0, '$_display = $res');
            if (_history.length > 20) _history.removeLast();
            _lastAnswer = res;
            _display = res;
            _eval = res;
            _result = '';
          }
        default:
          final d = btn.display;
          final e = btn.eval == 'ans' ? _lastAnswer : btn.eval;
          _display += d;
          _eval += e;
          _result = MathEngine.evaluate(_eval);
      }
    });
  }

  List<String> _tokenize(String s) {
    // Simple tokenizer: splits on known multi-char tokens then individual chars
    final tokens = <String>[];
    int i = 0;
    while (i < s.length) {
      bool found = false;
      // Uzun token'lar önce gelmeli; hem display hem eval tarafını kapsar.
      // display: sin⁻¹(/cos⁻¹(/tan⁻¹(, √(, ans
      // eval:    arcsin(/arccos(/arctan(, ln(, sqrt(, abs(, /100, ^2, pi
      for (final t in ['sin⁻¹(', 'cos⁻¹(', 'tan⁻¹(', 'arcsin(', 'arccos(', 'arctan(', 'sin(', 'cos(', 'tan(', 'ln(', 'sqrt(', 'abs(', '√(', '/100', '^2', 'ans', 'pi']) {
        if (s.startsWith(t, i)) {
          tokens.add(t);
          i += t.length;
          found = true;
          break;
        }
      }
      if (!found) {
        tokens.add(s[i]);
        i++;
      }
    }
    return tokens;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _buildHeader(),
          _buildDisplay(),
          const SizedBox(height: 8),
          Expanded(child: _buildGrid()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Text(
            translate('calculator_title'),
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
              letterSpacing: 0.5,
            ),
          ),
          const Spacer(),
          if (_history.isNotEmpty)
            GestureDetector(
              onTap: _showHistory,
              child: Row(
                children: [
                  Icon(Icons.history, size: 14, color: AppColors.primaryLight),
                  const SizedBox(width: 4),
                  Text(
                    translate('history'),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.primaryLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDisplay() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceUp, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 40),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: Text(
                _display.isEmpty ? '0' : _display,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: _display.length > 14 ? 24 : 32,
                  fontWeight: FontWeight.w300,
                  color: _display.isEmpty ? AppColors.textMuted : AppColors.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          AnimatedOpacity(
            opacity: _result.isNotEmpty ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 150),
            child: Text(
              '= $_result',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 18,
                color: AppColors.primaryLight,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _buttons.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.05,
        ),
        itemBuilder: (_, i) => _CalcButton(
          btn: _buttons[i],
          onTap: () => _onButton(_buttons[i]),
        ),
      ),
    );
  }

  void _showHistory() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.surfaceHigh,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                Text(
                  translate('calculation_history'),
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() => _history.clear());
                    Navigator.pop(context);
                  },
                  child: Text(
                    translate('clear'),
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.redLight,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _history.length,
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text(
                  _history[i],
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CalcButton extends StatelessWidget {
  final _Btn btn;
  final VoidCallback onTap;

  const _CalcButton({required this.btn, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = _colors(btn.type);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          boxShadow: btn.type == _BtnType.equals
              ? [BoxShadow(color: AppColors.primaryGlow, blurRadius: 12, spreadRadius: 1)]
              : null,
        ),
        child: Center(
          child: Text(
            btn.label,
            style: GoogleFonts.inter(
              fontSize: btn.label.length > 3 ? 12 : 15,
              fontWeight: btn.type == _BtnType.equals ? FontWeight.w700 : FontWeight.w500,
              color: fg,
            ),
          ),
        ),
      ),
    );
  }

  static (Color, Color) _colors(_BtnType t) => switch (t) {
        _BtnType.number => (AppColors.surfaceUp, AppColors.textPrimary),
        _BtnType.operator => (const Color(0xFF1E1A3A), AppColors.primaryLight),
        _BtnType.fn => (const Color(0xFF142038), AppColors.cyanLight),
        _BtnType.constant => (const Color(0xFF122030), AppColors.greenLight),
        _BtnType.clear => (const Color(0xFF2A1010), AppColors.redLight),
        _BtnType.del => (AppColors.surfaceUp, AppColors.redLight),
        _BtnType.equals => (AppColors.primary, Colors.white),
      };
}
