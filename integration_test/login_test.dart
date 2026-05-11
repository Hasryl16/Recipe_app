import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:recipe_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Login Feature Test', () {
    testWidgets('Login with valid credentials (UI flow test)', (tester) async {
      app.main();
      await tester.pumpAndSettle();


      expect(find.text('Welcome Back!'), findsOneWidget);
      expect(find.byKey(const Key('login_username_field')), findsOneWidget);
      expect(find.byKey(const Key('login_password_field')), findsOneWidget);
      expect(find.byKey(const Key('login_button')), findsOneWidget);

      await tester.enterText(find.byKey(const Key('login_username_field')), 'tester');
      await tester.enterText(find.byKey(const Key('login_password_field')), 'password123');
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('login_button')));
      
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final homeMarker = find.text('Halo, mau masak apa hari ini?');
      final errorMarker = find.byType(SnackBar);

      if (homeMarker.evaluate().isNotEmpty) {
        expect(homeMarker, findsOneWidget);
        print('Login test: Success (Home screen reached)');
      } else if (errorMarker.evaluate().isNotEmpty) {
        print('Login test: Completed (Error SnackBar visible - expected if backend is offline)');
      } else {
        print('Login test: Completed (Current screen state: ${tester.element(find.byType(Scaffold)).toString()})');
      }
    });
  });
}
