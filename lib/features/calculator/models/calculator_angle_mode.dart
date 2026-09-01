enum CalculatorAngleMode { degrees, radians }

extension CalculatorAngleModeLabel on CalculatorAngleMode {
  String get label => switch (this) {
    CalculatorAngleMode.degrees => 'DEG',
    CalculatorAngleMode.radians => 'RAD',
  };
}
