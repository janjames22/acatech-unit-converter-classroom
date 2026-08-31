import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unit_converter/features/converter/converter.dart';
import 'package:unit_converter/features/converter/presentation/converter_home_page.dart';
import 'package:unit_converter/features/converter/presentation/converter_page.dart';

void main() {
  testWidgets('converts input and swaps units', (tester) async {
    final length = builtInUnitCatalog.requireCategoryById('length');
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ConverterPage(category: length, onBack: () {}),
        ),
      ),
    );

    await tester.enterText(
      find.byKey(const ValueKey('conversion-input')),
      '1000',
    );
    await tester.pump();
    expect(find.text('1 km'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('swap-units')));
    await tester.pump();
    expect(find.text('1000000 m'), findsOneWidget);
  });

  testWidgets('search selects a matching unit directly', (tester) async {
    UnitCategory? selectedCategory;
    UnitDefinition? selectedUnit;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ConverterHomePage(
            catalog: builtInUnitCatalog,
            onSelection: (category, unit) {
              selectedCategory = category;
              selectedUnit = unit;
            },
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(SearchBar), 'fahren');
    await tester.pump();
    expect(find.text('Fahrenheit'), findsOneWidget);

    await tester.tap(find.text('Fahrenheit'));
    expect(selectedCategory?.id, 'temperature');
    expect(selectedUnit?.id, 'fahrenheit');
  });

  testWidgets('compact converter has no layout overflow', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 700);
    addTearDown(tester.view.reset);

    final temperature = builtInUnitCatalog.requireCategoryById('temperature');
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ConverterPage(category: temperature, onBack: () {}),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byKey(const ValueKey('conversion-input')), findsOneWidget);
    expect(find.byKey(const ValueKey('swap-units')), findsOneWidget);
  });
}
