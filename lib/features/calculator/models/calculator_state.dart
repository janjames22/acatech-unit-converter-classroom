import 'calculator_angle_mode.dart';
import 'calculator_history.dart';

const _unsetCalculatorValue = Object();

final class CalculatorState {
  CalculatorState({
    required this.expression,
    required this.displayValue,
    required this.angleMode,
    required this.history,
    this.lastValue,
    this.memoryValue,
    this.errorMessage,
  });

  factory CalculatorState.initial() => CalculatorState(
    expression: '',
    displayValue: '0',
    angleMode: CalculatorAngleMode.degrees,
    history: CalculatorHistory(),
  );

  final String expression;
  final String displayValue;
  final double? lastValue;
  final CalculatorAngleMode angleMode;
  final double? memoryValue;
  final CalculatorHistory history;
  final String? errorMessage;

  bool get hasError => errorMessage != null;
  bool get hasMemory => memoryValue != null;

  CalculatorState copyWith({
    String? expression,
    String? displayValue,
    Object? lastValue = _unsetCalculatorValue,
    CalculatorAngleMode? angleMode,
    Object? memoryValue = _unsetCalculatorValue,
    CalculatorHistory? history,
    Object? errorMessage = _unsetCalculatorValue,
  }) {
    return CalculatorState(
      expression: expression ?? this.expression,
      displayValue: displayValue ?? this.displayValue,
      lastValue: identical(lastValue, _unsetCalculatorValue)
          ? this.lastValue
          : lastValue as double?,
      angleMode: angleMode ?? this.angleMode,
      memoryValue: identical(memoryValue, _unsetCalculatorValue)
          ? this.memoryValue
          : memoryValue as double?,
      history: history ?? this.history,
      errorMessage: identical(errorMessage, _unsetCalculatorValue)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}
