import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shopsphere/main.dart' as app;
import 'package:shopsphere/widgets/product_card.dart';

Future<void> pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 15),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    await tester.pump(const Duration(milliseconds: 100));
    await Future<void>.delayed(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) return;
  }
  fail('Timed out waiting for $finder');
}

Future<void> settle(WidgetTester tester, [int milliseconds = 1200]) async {
  final deadline = DateTime.now().add(Duration(milliseconds: milliseconds));
  while (DateTime.now().isBefore(deadline)) {
    await tester.pump(const Duration(milliseconds: 100));
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('captures the ShopSphere demo flow', (tester) async {
    await app.main();
    await tester.pump();
    await settle(tester, 1000);
    await binding.takeScreenshot('splash');

    await pumpUntilFound(tester, find.text('Welcome\nback.'));
    await settle(tester, 600);
    await binding.takeScreenshot('login');

    await tester.tap(find.text('Create an account'));
    await tester.pump();
    await settle(tester, 800);
    await binding.takeScreenshot('signup');

    await tester.tap(find.byTooltip('Back to sign in'));
    await tester.pump();
    await pumpUntilFound(tester, find.text('Welcome\nback.'));
    await settle(tester, 500);

    final autofill = find.text('Autofill demo credentials');
    await tester.ensureVisible(autofill);
    await tester.pump();
    await settle(tester, 300);
    await tester.tap(autofill);
    await tester.pump();

    final signIn = find.text('Sign in');
    await tester.ensureVisible(signIn);
    await tester.pump();
    await settle(tester, 300);
    await tester.tap(signIn);

    await pumpUntilFound(tester, find.text('Curated for\neveryday living.'));
    await pumpUntilFound(tester, find.byType(ProductCard));
    await settle(tester, 2500);
    await binding.takeScreenshot('home');

    await tester.tap(find.text('Audio').first);
    await tester.pump();
    await pumpUntilFound(tester, find.text('The collection'));
    await pumpUntilFound(tester, find.byType(ProductCard));
    await settle(tester, 500);

    await tester.tap(find.text('All'));
    await tester.pump();
    await settle(tester, 1200);
    await tester.ensureVisible(find.text('The collection'));
    await tester.pump();
    await settle(tester, 400);
    await binding.takeScreenshot('product_listing');

    final search = find.byType(TextField).first;
    await tester.tap(search);
    await tester.enterText(search, 'Aurora');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pump();
    await pumpUntilFound(
      tester,
      find.text('Aurora Wireless Headphones'),
    );
    await settle(tester, 1200);

    await tester.tap(find.byType(ProductCard).first);
    await tester.pump();
    await pumpUntilFound(tester, find.text('The details'));
    await settle(tester, 2500);
    await binding.takeScreenshot('product_details');
  });
}
