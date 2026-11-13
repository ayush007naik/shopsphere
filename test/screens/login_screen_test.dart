import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopsphere/core/services/demo_auth_repository.dart';
import 'package:shopsphere/core/theme/app_theme.dart';
import 'package:shopsphere/providers/auth_provider.dart';
import 'package:shopsphere/routes/app_routes.dart';
import 'package:shopsphere/screens/auth/login_screen.dart';

void main() {
  Future<void> pumpLogin(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AuthProvider(DemoAuthRepository(preferences)),
        child: MaterialApp(
          theme: AppTheme.light,
          home: const LoginScreen(),
          routes: {
            AppRoutes.home: (_) =>
                const Scaffold(body: Center(child: Text('Home stub'))),
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows the login form and demo credentials', (tester) async {
    await pumpLogin(tester);

    expect(find.text('Welcome\nback.'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Create an account'), findsOneWidget);
    expect(find.text(DemoAuthRepository.demoEmail), findsNothing);
    expect(find.text('Demo access'), findsOneWidget);
  });

  testWidgets('validates empty fields before submitting', (tester) async {
    await pumpLogin(tester);

    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
  });

  testWidgets('rejects an invalid email address', (tester) async {
    await pumpLogin(tester);

    await tester.enterText(find.byType(TextFormField).at(0), 'not-an-email');
    await tester.enterText(find.byType(TextFormField).at(1), 'demo1234');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Enter a valid email address'), findsOneWidget);
  });

  testWidgets('signs in with demo credentials and navigates home', (
    tester,
  ) async {
    await pumpLogin(tester);

    await tester.enterText(
      find.byType(TextFormField).at(0),
      DemoAuthRepository.demoEmail,
    );
    await tester.enterText(
      find.byType(TextFormField).at(1),
      DemoAuthRepository.demoPassword,
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    expect(find.text('Home stub'), findsOneWidget);
  });
}
