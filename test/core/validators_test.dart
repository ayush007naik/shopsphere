import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/core/utils/validators.dart';

void main() {
  group('Validators.email', () {
    test('rejects empty values', () {
      expect(Validators.email(''), 'Email is required');
      expect(Validators.email(null), 'Email is required');
    });

    test('rejects malformed addresses', () {
      expect(Validators.email('not-an-email'), isNotNull);
      expect(Validators.email('missing@domain'), isNotNull);
      expect(Validators.email('@example.com'), isNotNull);
    });

    test('accepts valid addresses', () {
      expect(Validators.email('demo@shopsphere.app'), isNull);
      expect(Validators.email('first.last+tag@example.co.uk'), isNull);
    });
  });

  group('Validators.password', () {
    test('requires at least six characters', () {
      expect(Validators.password(''), 'Password is required');
      expect(Validators.password('12345'), isNotNull);
      expect(Validators.password('123456'), isNull);
    });
  });

  group('Validators.fullName', () {
    test('requires a real name', () {
      expect(Validators.fullName(' '), 'Full name is required');
      expect(Validators.fullName('A'), 'Name is too short');
      expect(Validators.fullName('Ada Lovelace'), isNull);
    });
  });

  group('Validators.confirmPassword', () {
    test('must match the original password', () {
      expect(Validators.confirmPassword('', 'secret1'), isNotNull);
      expect(Validators.confirmPassword('secret2', 'secret1'), isNotNull);
      expect(Validators.confirmPassword('secret1', 'secret1'), isNull);
    });
  });
}
