import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unit_converter/features/practice/widgets/practice_inputs.dart';

import '../../../helpers/practice_input_test_helpers.dart';

void main() {
  testWidgets('numeric keypad controls all entry without an editable field', (
    tester,
  ) async {
    var value = '';
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => SingleChildScrollView(
              child: NumericInput(
                value: value,
                onChanged: (next) => setState(() => value = next),
                label: 'Answer',
                keyPrefix: 'numeric-test',
                allowDecimal: true,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(EditableText), findsNothing);
    await tapPracticeKeys(tester, 'numeric-test', ['1', '.', '.', '2']);
    expect(value, '1.2');

    await tapPracticeKeys(tester, 'numeric-test', ['backspace']);
    expect(value, '1.');
    await tapPracticeKeys(tester, 'numeric-test', ['clear']);
    expect(value, isEmpty);

    for (final token in ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']) {
      expect(
        tester.getSize(find.byKey(ValueKey('numeric-test-key-$token'))).height,
        greaterThanOrEqualTo(48),
      );
    }
  });

  testWidgets('fraction input composes numerator and denominator', (
    tester,
  ) async {
    var value = '';
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => SingleChildScrollView(
              child: FractionInput(
                value: value,
                onChanged: (next) => setState(() => value = next),
                keyPrefix: 'fraction-test',
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(EditableText), findsNothing);
    await tapPracticeKeys(tester, 'fraction-test', ['3']);
    await tapPracticeControl(tester, 'fraction-test-denominator');
    await tapPracticeKeys(tester, 'fraction-test', ['8']);
    expect(value, '3/8');
  });

  testWidgets('mixed-number input composes all three controlled parts', (
    tester,
  ) async {
    var value = '';
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => SingleChildScrollView(
              child: MixedNumberInput(
                value: value,
                onChanged: (next) => setState(() => value = next),
                keyPrefix: 'mixed-test',
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(EditableText), findsNothing);
    await tapPracticeKeys(tester, 'mixed-test', ['1']);
    await tapPracticeControl(tester, 'mixed-test-numerator');
    await tapPracticeKeys(tester, 'mixed-test', ['1', '3']);
    await tapPracticeControl(tester, 'mixed-test-denominator');
    await tapPracticeKeys(tester, 'mixed-test', ['1', '6']);
    expect(value, '1 13/16');
  });

  testWidgets('decimal input supports explicit repeating notation', (
    tester,
  ) async {
    var value = '';
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => SingleChildScrollView(
              child: DecimalInput(
                value: value,
                onChanged: (next) => setState(() => value = next),
                keyPrefix: 'decimal-test',
                extraKeys: const ['(', ')'],
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(EditableText), findsNothing);
    await tapPracticeKeys(tester, 'decimal-test', ['0', '.', '(', '3', ')']);
    expect(value, '0.(3)');
  });

  testWidgets('unit input accepts only the provided controlled choices', (
    tester,
  ) async {
    var value = '';
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => ControlledUnitInput(
              value: value,
              options: const ['in', 'ft', 'Ω'],
              onChanged: (next) => setState(() => value = next),
              keyPrefix: 'unit-test',
            ),
          ),
        ),
      ),
    );

    expect(find.byType(EditableText), findsNothing);
    await tapPracticeControl(tester, 'unit-test-unit-ohm');
    expect(value, 'Ω');
  });
}
