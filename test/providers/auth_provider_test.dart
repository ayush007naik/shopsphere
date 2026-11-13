import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopsphere/core/services/demo_auth_repository.dart';
import 'package:shopsphere/providers/auth_provider.dart';

void main() {
  late SharedPreferences preferences;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
  });

  test('starts unauthenticated with no saved session', () async {
    final provider = AuthProvider(DemoAuthRepository(preferences));
    await provider.initialize();

    expect(provider.status, AuthStatus.unauthenticated);
    expect(provider.user, isNull);
    expect(provider.isAuthenticated, isFalse);
  });

  test('signs in with the seeded demo account', () async {
    final provider = AuthProvider(DemoAuthRepository(preferences));
    await provider.initialize();

    final outcome = await provider.signIn(
      email: DemoAuthRepository.demoEmail,
      password: DemoAuthRepository.demoPassword,
    );

    expect(outcome.success, isTrue);
    expect(provider.isAuthenticated, isTrue);
    expect(provider.user?.email, DemoAuthRepository.demoEmail);
    expect(provider.user?.fullName, DemoAuthRepository.demoFullName);
  });

  test('rejects an incorrect password with a friendly message', () async {
    final provider = AuthProvider(DemoAuthRepository(preferences));
    await provider.initialize();

    final outcome = await provider.signIn(
      email: DemoAuthRepository.demoEmail,
      password: 'wrong-password',
    );

    expect(outcome.success, isFalse);
    expect(outcome.message, contains('Incorrect password'));
    expect(provider.errorMessage, contains('Incorrect password'));
    expect(provider.isAuthenticated, isFalse);
  });

  test('registers a new account and authenticates immediately', () async {
    final provider = AuthProvider(DemoAuthRepository(preferences));
    await provider.initialize();

    final outcome = await provider.signUp(
      email: 'new@shopsphere.app',
      password: 'secret123',
      fullName: 'New Shopper',
    );

    expect(outcome.success, isTrue);
    expect(outcome.requiresEmailConfirmation, isFalse);
    expect(provider.isAuthenticated, isTrue);
    expect(provider.user?.fullName, 'New Shopper');
  });

  test('persists the session across repository instances', () async {
    final provider = AuthProvider(DemoAuthRepository(preferences));
    await provider.initialize();
    await provider.signIn(
      email: DemoAuthRepository.demoEmail,
      password: DemoAuthRepository.demoPassword,
    );

    final restored = DemoAuthRepository(preferences);
    expect(restored.currentUser?.email, DemoAuthRepository.demoEmail);
  });

  test('signs out and clears the session', () async {
    final provider = AuthProvider(DemoAuthRepository(preferences));
    await provider.initialize();
    await provider.signIn(
      email: DemoAuthRepository.demoEmail,
      password: DemoAuthRepository.demoPassword,
    );

    await provider.signOut();

    expect(provider.status, AuthStatus.unauthenticated);
    expect(provider.user, isNull);
    expect(DemoAuthRepository(preferences).currentUser, isNull);
  });
}
