import 'package:flutter/foundation.dart';

import '../models/calculator_angle_mode.dart';
import '../models/calculator_history.dart';
import '../models/calculator_state.dart';
import '../services/calculator_engine.dart';
import '../services/calculator_number_formatter.dart';

typedef CalculatorClock = DateTime Function();

/// Owns calculator editing and session-local UI state.
///
/// Mathematical evaluation remains in [CalculatorEngine]. This controller has
/// no navigation, lifecycle, storage, or assessment-monitoring dependency.
final class CalculatorController extends ChangeNotifier {
  CalculatorController({
    CalculatorEngine? engine,
    CalculatorClock? clock,
    CalculatorState? initialState,
  }) : _engine = engine ?? const CalculatorEngine(),
       _clock = clock ?? _utcNow,
       _state = initialState ?? CalculatorState.initial();

  final CalculatorEngine _engine;
  final CalculatorClock _clock;
  CalculatorState _state;
  bool _justEvaluated = false;

  CalculatorState get state => _state;

  void inputDigit(String digit) {
    if (digit.length != 1 ||
        digit.codeUnitAt(0) < 0x30 ||
        digit.codeUnitAt(0) > 0x39) {
      throw ArgumentError.value(digit, 'digit', 'Must be one digit.');
    }
    _appendValueToken(digit);
  }

  void inputDecimal() {
    _prepareForValueEntry();
    final expression = _state.expression;
    final segment = expression.split(RegExp(r'[+\-×÷*/^()%]')).last;
    if (segment.contains('.')) {
      return;
    }
    final needsLeadingZero =
        expression.isEmpty ||
        _endsWithOperator(expression) ||
        expression.endsWith('(');
    _replaceExpression('$expression${needsLeadingZero ? '0.' : '.'}');
  }

  void inputOperator(String operator) {
    const supported = {'+', '−', '×', '÷', '^'};
    if (!supported.contains(operator)) {
      throw ArgumentError.value(operator, 'operator', 'Unsupported operator.');
    }
    _clearError();
    var expression = _state.expression;
    if (_justEvaluated) {
      expression = _state.displayValue;
      _justEvaluated = false;
    }
    if (expression.isEmpty) {
      if (operator == '−') {
        _replaceExpression(operator);
      }
      return;
    }
    if (_endsWithOperator(expression)) {
      expression = expression.substring(0, expression.length - 1);
    }
    _replaceExpression('$expression$operator');
  }

  void inputParenthesis(String parenthesis) {
    if (parenthesis != '(' && parenthesis != ')') {
      throw ArgumentError.value(parenthesis, 'parenthesis');
    }
    if (parenthesis == '(') {
      _prepareForValueEntry();
    } else {
      _clearError();
      if (_justEvaluated) {
        _justEvaluated = false;
      }
    }
    _replaceExpression('${_state.expression}$parenthesis');
  }

  void inputConstant(String constant) {
    if (constant != 'π' && constant != 'e') {
      throw ArgumentError.value(constant, 'constant');
    }
    _appendValueToken(constant);
  }

  void inputFunction(String function) {
    const supported = {
      'sqrt',
      'sin',
      'cos',
      'tan',
      'log',
      'ln',
      'exp',
      'recip',
    };
    if (!supported.contains(function)) {
      throw ArgumentError.value(function, 'function', 'Unsupported function.');
    }
    _prepareForValueEntry();
    _replaceExpression('${_state.expression}$function(');
  }

  void inputSquare() {
    _clearError();
    final expression = _justEvaluated ? _state.displayValue : _state.expression;
    if (expression.isEmpty || _endsWithOperator(expression)) {
      return;
    }
    _justEvaluated = false;
    _replaceExpression('$expression^2');
  }

  void inputPercent() {
    _clearError();
    final expression = _justEvaluated ? _state.displayValue : _state.expression;
    if (expression.isEmpty || _endsWithOperator(expression)) {
      return;
    }
    _justEvaluated = false;
    _replaceExpression('$expression%');
  }

  void backspace() {
    _clearError();
    _justEvaluated = false;
    final expression = _state.expression;
    if (expression.isEmpty) {
      return;
    }
    _replaceExpression(expression.substring(0, expression.length - 1));
  }

  void clear() {
    _justEvaluated = false;
    _state = _state.copyWith(
      expression: '',
      displayValue: '0',
      lastValue: null,
      errorMessage: null,
    );
    notifyListeners();
  }

  void evaluate() {
    final expression = _state.expression.trim();
    if (expression.isEmpty) {
      _state = _state.copyWith(errorMessage: 'Enter an expression.');
      notifyListeners();
      return;
    }
    try {
      final value = _engine.evaluate(expression, angleMode: _state.angleMode);
      final result = CalculatorNumberFormatter.format(value);
      final entry = CalculatorHistoryEntry(
        expression: expression,
        result: result,
        value: value,
        calculatedAt: _clock(),
      );
      _state = _state.copyWith(
        expression: expression,
        displayValue: result,
        lastValue: value,
        history: _state.history.add(entry),
        errorMessage: null,
      );
      _justEvaluated = true;
    } on CalculatorException catch (error) {
      _state = _state.copyWith(errorMessage: error.message);
      _justEvaluated = false;
    }
    notifyListeners();
  }

  void setAngleMode(CalculatorAngleMode mode) {
    if (_state.angleMode == mode) {
      return;
    }
    _state = _state.copyWith(angleMode: mode, errorMessage: null);
    notifyListeners();
  }

  void memoryClear() {
    if (_state.memoryValue == null) {
      return;
    }
    _state = _state.copyWith(memoryValue: null);
    notifyListeners();
  }

  void memoryRecall() {
    final memory = _state.memoryValue;
    if (memory == null) {
      return;
    }
    _appendValueToken(CalculatorNumberFormatter.format(memory));
  }

  void memoryAdd() => _updateMemory(add: true);

  void memorySubtract() => _updateMemory(add: false);

  void clearHistory() {
    if (_state.history.isEmpty) {
      return;
    }
    _state = _state.copyWith(history: _state.history.clear());
    notifyListeners();
  }

  void reuseHistory(CalculatorHistoryEntry entry) {
    _state = _state.copyWith(
      expression: entry.expression,
      displayValue: entry.result,
      lastValue: entry.value,
      errorMessage: null,
    );
    _justEvaluated = true;
    notifyListeners();
  }

  void _updateMemory({required bool add}) {
    final value = _state.lastValue;
    if (value == null) {
      return;
    }
    final current = _state.memoryValue ?? 0;
    _state = _state.copyWith(
      memoryValue: add ? current + value : current - value,
    );
    notifyListeners();
  }

  void _appendValueToken(String token) {
    _prepareForValueEntry();
    _replaceExpression('${_state.expression}$token');
  }

  void _prepareForValueEntry() {
    _clearError();
    if (_justEvaluated) {
      _state = _state.copyWith(expression: '', displayValue: '0');
      _justEvaluated = false;
    }
  }

  void _clearError() {
    if (_state.errorMessage != null) {
      _state = _state.copyWith(errorMessage: null);
    }
  }

  void _replaceExpression(String expression) {
    _state = _state.copyWith(expression: expression, errorMessage: null);
    notifyListeners();
  }

  static bool _endsWithOperator(String expression) {
    if (expression.isEmpty) {
      return false;
    }
    return const {
      '+',
      '−',
      '×',
      '÷',
      '*',
      '/',
      '^',
    }.contains(expression[expression.length - 1]);
  }

  static DateTime _utcNow() => DateTime.now().toUtc();
}
