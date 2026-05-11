import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:recipe_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Search Recipe Integration Test', () {
    testWidgets('User can search recipe successfully', (
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

      // OPEN SEARCH PAGE
      await tester.tap(find.byIcon(Icons.search_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Explore Recipes'), findsOneWidget);

      // SEARCH RECIPE
      await tester.enterText(
        find.byType(TextField).first,
        'Chicken',
      );

      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // VERIFY RESULT
      expect(find.text('Search Results'), findsOneWidget);

      debugPrint(
        'Search Recipe Integration Test: PASSED',
      );
    });

    testWidgets('User gets empty state when recipe is not found', (
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

      // OPEN SEARCH PAGE
      await tester.tap(find.byIcon(Icons.search_rounded));
      await tester.pumpAndSettle();

      // SEARCH INVALID RECIPE
      await tester.enterText(
        find.byType(TextField).first,
        'xyz_recipe_not_found_123',
      );

      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // VERIFY EMPTY RESULT
      expect(find.text('No recipes found'), findsOneWidget);

      debugPrint(
        'Search Empty Result Integration Test: PASSED',
      );
    });
  });
}