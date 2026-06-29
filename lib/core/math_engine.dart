import 'dart:math' as math;
import 'package:math_expressions/math_expressions.dart';
import 'app_localization.dart';

class MathEngine {
  static final GrammarParser _parser = GrammarParser();

  static String evaluate(String evalExpr) {
    if (evalExpr.trim().isEmpty) return '';
    try {
      final processed = _preprocess(evalExpr);
      final exp = _parser.parse(processed);
      final cm = _buildContext();
      final result = exp.evaluate(EvaluationType.REAL, cm) as double;
      if (result.isNaN) return translate('undefined');
      if (result.isInfinite) return result > 0 ? '∞' : '-∞';
      return _format(result);
    } catch (_) {
      return '';
    }
  }

  static double? evaluateForGraph(String evalExpr, double x) {
    if (evalExpr.trim().isEmpty) return null;
    try {
      final processed = _preprocess(evalExpr);
      final exp = _parser.parse(processed);
      final cm = _buildContext();
      cm.bindVariableName('x', Number(x));
      final result = exp.evaluate(EvaluationType.REAL, cm) as double;
      if (result.isNaN || result.isInfinite) return null;
      return result;
    } catch (_) {
      return null;
    }
  }

  static ContextModel _buildContext() {
    final cm = ContextModel();
    cm.bindVariableName('pi', Number(math.pi));
    cm.bindVariableName('e', Number(math.e));
    return cm;
  }

  static String _preprocess(String expr) {
    return expr
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll('−', '-')
        .replaceAll('π', 'pi')
        // örtük çarpım: rakam ardından fonksiyon adı (2sin(x), 3cos(x), 2ln(x) vb.)
        .replaceAllMapped(
          RegExp(r'(\d)(sin|cos|tan|ln|sqrt|abs|arcsin|arccos|arctan)'),
          (m) => '${m[1]}*${m[2]}',
        )
        // örtük çarpım: rakam ardından pi, e veya açılış parantezi
        .replaceAllMapped(
          RegExp(r'(\d)(pi|e\b|\()'),
          (m) => '${m[1]}*${m[2]}',
        )
        // örtük çarpım: rakam ardından x değişkeni (2x, 3x, 2x^2 vb.)
        .replaceAllMapped(
          RegExp(r'(\d)(x)'),
          (m) => '${m[1]}*${m[2]}',
        );
  }

  static String _format(double v) {
    if (v == v.truncateToDouble() && v.abs() < 1e15) {
      return v.toInt().toString();
    }
    if (v.abs() >= 1e10 || (v.abs() < 1e-6 && v != 0)) {
      return v.toStringAsExponential(4);
    }
    String s = v.toStringAsPrecision(10);
    if (s.contains('.')) {
      s = s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    }
    return s;
  }
}
