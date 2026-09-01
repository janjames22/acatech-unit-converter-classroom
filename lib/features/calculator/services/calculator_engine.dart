import 'dart:math' as math;

import '../models/calculator_angle_mode.dart';

enum CalculatorErrorType { syntax, divisionByZero, domain, nonFinite }

final class CalculatorException implements Exception {
  const CalculatorException(this.type, this.message);

  final CalculatorErrorType type;
  final String message;

  @override
  String toString() => message;
}

final class CalculatorEngine {
  const CalculatorEngine();

  double evaluate(
    String expression, {
    CalculatorAngleMode angleMode = CalculatorAngleMode.degrees,
  }) {
    final normalized = expression
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll('−', '-')
        .replaceAll('π', 'pi');
    if (normalized.trim().isEmpty) {
      throw const CalculatorException(
        CalculatorErrorType.syntax,
        'Enter an expression.',
      );
    }

    final parser = _CalculatorParser(
      _CalculatorTokenizer(normalized).tokenize(),
      angleMode,
    );
    final value = parser.parse();
    if (!value.isFinite) {
      throw const CalculatorException(
        CalculatorErrorType.nonFinite,
        'The result is outside the supported numeric range.',
      );
    }
    return value == 0 ? 0 : value;
  }
}

enum _TokenType {
  number,
  identifier,
  plus,
  minus,
  multiply,
  divide,
  power,
  percent,
  leftParenthesis,
  rightParenthesis,
  end,
}

final class _Token {
  const _Token(this.type, this.lexeme, this.position, [this.number]);

  final _TokenType type;
  final String lexeme;
  final int position;
  final double? number;
}

final class _CalculatorTokenizer {
  const _CalculatorTokenizer(this.source);

  final String source;

  List<_Token> tokenize() {
    final tokens = <_Token>[];
    var index = 0;
    while (index < source.length) {
      final code = source.codeUnitAt(index);
      if (_isWhitespace(code)) {
        index++;
        continue;
      }

      final singleToken = switch (code) {
        0x2b => _TokenType.plus,
        0x2d => _TokenType.minus,
        0x2a => _TokenType.multiply,
        0x2f => _TokenType.divide,
        0x5e => _TokenType.power,
        0x25 => _TokenType.percent,
        0x28 => _TokenType.leftParenthesis,
        0x29 => _TokenType.rightParenthesis,
        _ => null,
      };
      if (singleToken != null) {
        tokens.add(_Token(singleToken, source[index], index));
        index++;
        continue;
      }

      if (_isDigit(code) || code == 0x2e) {
        final start = index;
        var sawDigit = false;
        var sawDecimal = false;
        while (index < source.length) {
          final current = source.codeUnitAt(index);
          if (_isDigit(current)) {
            sawDigit = true;
            index++;
            continue;
          }
          if (current == 0x2e && !sawDecimal) {
            sawDecimal = true;
            index++;
            continue;
          }
          break;
        }

        if (!sawDigit) {
          throw CalculatorException(
            CalculatorErrorType.syntax,
            'Invalid number at position ${start + 1}.',
          );
        }

        if (index < source.length &&
            (source.codeUnitAt(index) == 0x65 ||
                source.codeUnitAt(index) == 0x45)) {
          final exponentMarker = index;
          var exponentIndex = index + 1;
          if (exponentIndex < source.length &&
              (source.codeUnitAt(exponentIndex) == 0x2b ||
                  source.codeUnitAt(exponentIndex) == 0x2d)) {
            exponentIndex++;
          }
          final exponentStart = exponentIndex;
          while (exponentIndex < source.length &&
              _isDigit(source.codeUnitAt(exponentIndex))) {
            exponentIndex++;
          }
          if (exponentIndex > exponentStart) {
            index = exponentIndex;
          } else {
            index = exponentMarker;
          }
        }

        final lexeme = source.substring(start, index);
        final number = double.tryParse(lexeme);
        if (number == null || !number.isFinite) {
          throw CalculatorException(
            CalculatorErrorType.nonFinite,
            'Invalid or unsupported number "$lexeme".',
          );
        }
        tokens.add(_Token(_TokenType.number, lexeme, start, number));
        continue;
      }

      if (_isLetter(code)) {
        final start = index;
        index++;
        while (index < source.length &&
            (_isLetter(source.codeUnitAt(index)) ||
                _isDigit(source.codeUnitAt(index)))) {
          index++;
        }
        final lexeme = source.substring(start, index).toLowerCase();
        tokens.add(_Token(_TokenType.identifier, lexeme, start));
        continue;
      }

      throw CalculatorException(
        CalculatorErrorType.syntax,
        'Unsupported character "${source[index]}" at position ${index + 1}.',
      );
    }
    tokens.add(_Token(_TokenType.end, '', source.length));
    return tokens;
  }

  static bool _isDigit(int code) => code >= 0x30 && code <= 0x39;
  static bool _isLetter(int code) =>
      (code >= 0x41 && code <= 0x5a) || (code >= 0x61 && code <= 0x7a);
  static bool _isWhitespace(int code) =>
      code == 0x20 || code == 0x09 || code == 0x0a || code == 0x0d;
}

final class _CalculatorParser {
  _CalculatorParser(this.tokens, this.angleMode);

  final List<_Token> tokens;
  final CalculatorAngleMode angleMode;
  var _current = 0;

  double parse() {
    final result = _parseAdditive();
    if (!_matches(_TokenType.end)) {
      final token = _peek;
      throw CalculatorException(
        CalculatorErrorType.syntax,
        'Unexpected "${token.lexeme}" at position ${token.position + 1}.',
      );
    }
    return _checked(result);
  }

  double _parseAdditive() {
    var value = _parseMultiplicative();
    while (true) {
      if (_consume(_TokenType.plus)) {
        value = _checked(value + _parseMultiplicative());
      } else if (_consume(_TokenType.minus)) {
        value = _checked(value - _parseMultiplicative());
      } else {
        return value;
      }
    }
  }

  double _parseMultiplicative() {
    var value = _parseUnary();
    while (true) {
      if (_consume(_TokenType.multiply)) {
        value = _checked(value * _parseUnary());
      } else if (_consume(_TokenType.divide)) {
        final divisor = _parseUnary();
        if (divisor == 0) {
          throw const CalculatorException(
            CalculatorErrorType.divisionByZero,
            'Cannot divide by zero.',
          );
        }
        value = _checked(value / divisor);
      } else {
        return value;
      }
    }
  }

  double _parseUnary() {
    if (_consume(_TokenType.plus)) {
      return _parseUnary();
    }
    if (_consume(_TokenType.minus)) {
      return _checked(-_parseUnary());
    }
    return _parsePower();
  }

  double _parsePower() {
    final base = _parsePostfix();
    if (!_consume(_TokenType.power)) {
      return base;
    }
    final exponent = _parseUnary();
    return _checked(math.pow(base, exponent));
  }

  double _parsePostfix() {
    var value = _parsePrimary();
    while (_consume(_TokenType.percent)) {
      value = _checked(value / 100);
    }
    return value;
  }

  double _parsePrimary() {
    if (_consume(_TokenType.number)) {
      return tokens[_current - 1].number!;
    }
    if (_consume(_TokenType.leftParenthesis)) {
      final value = _parseAdditive();
      _require(
        _TokenType.rightParenthesis,
        'Close the expression with a right parenthesis.',
      );
      return value;
    }
    if (_consume(_TokenType.identifier)) {
      final identifier = tokens[_current - 1];
      if (identifier.lexeme == 'pi') {
        return math.pi;
      }
      if (identifier.lexeme == 'e') {
        return math.e;
      }
      _require(
        _TokenType.leftParenthesis,
        'Function ${identifier.lexeme} requires parentheses.',
      );
      final argument = _parseAdditive();
      _require(
        _TokenType.rightParenthesis,
        'Close ${identifier.lexeme} with a right parenthesis.',
      );
      return _applyFunction(identifier.lexeme, argument);
    }

    final token = _peek;
    throw CalculatorException(
      CalculatorErrorType.syntax,
      token.type == _TokenType.end
          ? 'The expression is incomplete.'
          : 'Expected a number or function at position ${token.position + 1}.',
    );
  }

  double _applyFunction(String name, double argument) {
    final radians = angleMode == CalculatorAngleMode.degrees
        ? argument * math.pi / 180
        : argument;
    final value = switch (name) {
      'sqrt' when argument >= 0 => math.sqrt(argument),
      'sqrt' => throw const CalculatorException(
        CalculatorErrorType.domain,
        'Square root requires a non-negative value.',
      ),
      'sin' => math.sin(radians),
      'cos' => math.cos(radians),
      'tan' when math.cos(radians).abs() >= 1e-12 => math.tan(radians),
      'tan' => throw const CalculatorException(
        CalculatorErrorType.domain,
        'Tangent is undefined at this angle.',
      ),
      'log' when argument > 0 => math.log(argument) / math.ln10,
      'log' => throw const CalculatorException(
        CalculatorErrorType.domain,
        'Logarithm requires a positive value.',
      ),
      'ln' when argument > 0 => math.log(argument),
      'ln' => throw const CalculatorException(
        CalculatorErrorType.domain,
        'Natural logarithm requires a positive value.',
      ),
      'exp' => math.exp(argument),
      'recip' when argument != 0 => 1 / argument,
      'recip' => throw const CalculatorException(
        CalculatorErrorType.divisionByZero,
        'Cannot take the reciprocal of zero.',
      ),
      _ => throw CalculatorException(
        CalculatorErrorType.syntax,
        'Unknown function "$name".',
      ),
    };
    return _checked(value);
  }

  double _checked(num value) {
    final result = value.toDouble();
    if (!result.isFinite) {
      throw const CalculatorException(
        CalculatorErrorType.nonFinite,
        'The result is outside the supported numeric range.',
      );
    }
    return result == 0 ? 0 : result;
  }

  _Token get _peek => tokens[_current];

  bool _matches(_TokenType type) => _peek.type == type;

  bool _consume(_TokenType type) {
    if (!_matches(type)) {
      return false;
    }
    _current++;
    return true;
  }

  void _require(_TokenType type, String message) {
    if (!_consume(type)) {
      throw CalculatorException(CalculatorErrorType.syntax, message);
    }
  }
}
