import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:recipe_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Registration Flow Test', () {
    testWidgets('Verify successful registration and home navigation', (WidgetTester tester) async {
      // 1. Start the app
      app.main();
      await tester.pumpAndSettle();

      // 2. Navigate from Login to Register
      final createAccountLink = find.text('Create an account');
      expect(createAccountLink, findsOneWidget);
      await tester.ensureVisible(createAccountLink);
      await tester.tap(createAccountLink);
      await tester.pumpAndSettle();

      // 3. Identify Register screen elements
      final usernameField = find.byKey(const Key('register_username_field'));
      final passwordField = find.byKey(const Key('register_password_field'));
      final confirmField = find.byKey(const Key('register_confirm_password_field'));
      final registerButton = find.byKey(const Key('register_button'));

      // 4. Enter new user details
      // Using a slightly different username to avoid conflicts if you've already registered 'hasryl'
      final uniqueUsername = 'hasryl_test_${DateTime.now().millisecondsSinceEpoch}';
      await tester.ensureVisible(usernameField);
      await tester.enterText(usernameField, uniqueUsername);
      await tester.enterText(passwordField, 'password123');
      await tester.enterText(confirmField, 'password123');
      await tester.pumpAndSettle();

      // 5. Tap Register
      await tester.ensureVisible(registerButton);
      await tester.tap(registerButton);
      
      // 6. Wait for backend processing and navigation to Home
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // 7. Verify we are on the Home Screen
      expect(find.text('Halo, mau masak apa hari ini?'), findsOneWidget);
      print('Registration Test: PASSED! User $uniqueUsername created and logged in.');
    });
  });
}
