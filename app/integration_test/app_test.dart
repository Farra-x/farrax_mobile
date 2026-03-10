import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:farrax/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Tab navigation smoke test', (WidgetTester tester) async {
    app.main();

    // Boot the app with bounded pumps — avoids infinite pumpAndSettle hangs
    // that occur when Riverpod/Drift providers keep async work alive.
    for (int i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }

    // Verify app is alive
    expect(find.byType(MaterialApp), findsOneWidget);

    // If on welcome screen, navigate forward
    final Finder getStartedBtn =
        find.widgetWithText(ElevatedButton, 'Get Started');
    if (getStartedBtn.evaluate().isNotEmpty) {
      await tester.tap(getStartedBtn);
      for (int i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 500));
      }
    }

    // Skip onboarding if present
    final Finder skipBtn = find.widgetWithText(TextButton, 'Skip for now');
    if (skipBtn.evaluate().isNotEmpty) {
      await tester.tap(skipBtn);
      for (int i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 500));
      }
    }

    // Tap Herd tab
    final Finder herdTab =
        find.widgetWithText(NavigationDestination, 'Herd');
    if (herdTab.evaluate().isNotEmpty) {
      await tester.tap(herdTab);
      for (int i = 0; i < 4; i++) {
        await tester.pump(const Duration(milliseconds: 500));
      }
    }

    // Tap Health tab
    final Finder healthTab =
        find.widgetWithText(NavigationDestination, 'Health');
    if (healthTab.evaluate().isNotEmpty) {
      await tester.tap(healthTab);
      for (int i = 0; i < 4; i++) {
        await tester.pump(const Duration(milliseconds: 500));
      }
    }

    // Tap Movements tab
    final Finder movementsTab =
        find.widgetWithText(NavigationDestination, 'Movements');
    if (movementsTab.evaluate().isNotEmpty) {
      await tester.tap(movementsTab);
      for (int i = 0; i < 4; i++) {
        await tester.pump(const Duration(milliseconds: 500));
      }
    }

    // Back to Home tab
    final Finder homeTab =
        find.widgetWithText(NavigationDestination, 'Home');
    if (homeTab.evaluate().isNotEmpty) {
      await tester.tap(homeTab);
      for (int i = 0; i < 4; i++) {
        await tester.pump(const Duration(milliseconds: 500));
      }
    }

    // Final assertion — app must not have crashed
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
