import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> tapPracticeKeys(
  WidgetTester tester,
  String prefix,
  Iterable<String> tokens,
) async {
  for (final token in tokens) {
    final id = switch (token) {
      '.' => 'decimal',
      '^' => 'power',
      '×' => 'multiply',
      ',' => 'comma',
      '(' => 'open-paren',
      ')' => 'close-paren',
      _ => token,
    };
    final key = find.byKey(ValueKey('$prefix-key-$id'));
    await tester.ensureVisible(key);
    await tester.pump();
    await tester.tap(key);
    await tester.pump();
  }
}

Future<void> tapPracticeControl(WidgetTester tester, String key) async {
  final finder = find.byKey(ValueKey(key));
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
  await tester.pump();
}
