import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:recipe_app/main.dart' as app;


void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  group('Add Recipe Integration Test', () {
    testWidgets('User can add new recipe successfully', (
      WidgetTester tester,
    ) async {
      app.main();
      await tester.pumpAndSettle();

      // LOGIN
      await tester.enterText(
        find.byType(TextField).at(0),
        'tester',
      );

      await tester.enterText(
        find.byType(TextField).at(1),
        'password123',
      );

      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.textContaining('Halo'), findsOneWidget);

      // OPEN ADD RECIPE PAGE
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(find.text('Create Recipe'), findsOneWidget);

      // STEP 1 - BASIC INFO
      await tester.enterText(
        find.byType(TextField).at(0),
        'Integration Test Recipe',
      );

      await tester.enterText(
        find.byType(TextField).at(1),
        'Recipe created from integration testing',
      );

      await tester.tap(find.textContaining('Next'));
      await tester.pumpAndSettle();

      // STEP 2 - INGREDIENTS
      await tester.enterText(
        find.byType(TextField).at(0),
        'Chicken',
      );

      await tester.enterText(
        find.byType(TextField).at(1),
        '500 gram',
      );

      await tester.tap(find.textContaining('Next'));
      await tester.pumpAndSettle();

      // STEP 3 - INSTRUCTIONS
      await tester.enterText(
        find.byType(TextField).first,
        'Cook the chicken for 20 minutes',
      );

      await tester.tap(find.textContaining('Next'));
      await tester.pumpAndSettle();

      // STEP 4 - SETTINGS
      await tester.enterText(
        find.byType(TextField).first,
        '30',
      );

      await tester.tap(find.textContaining('Post'));
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      // VERIFY SUCCESS
      expect(find.textContaining('Recipe Posted'), findsOneWidget);

      debugPrint(
        'Add Recipe Integration Test: PASSED',
      );
    });
  });
}