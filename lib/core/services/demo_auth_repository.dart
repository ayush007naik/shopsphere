import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/app_user.dart';
import 'auth_repository.dart';

/// Offline stand-in for Supabase Auth used when no backend credentials are
/// configured. Accounts and the active session are stored on-device so the
/// assignment can be demonstrated without a live project.
///
/// This is explicitly a demo mechanism and is not a replacement for the real
/// Supabase integration in [SupabaseAuthRepository].
class DemoAuthRepository implements AuthRepository {
  DemoAuthRepository(this._preferences) {
    _seedDemoAccount();
  }

  final SharedPreferences _preferences;

  static const String demoEmail = 'demo@shopsphere.app';
  static const String demoPassword = 'demo1234';
  static const String demoFullName = 'Demo Shopper';

  static const String _usersKey = 'shopsphere.demo_users';
  static const String _sessionKey = 'shopsphere.demo_session';

  @override
  AppUser? get currentUser {
    final email = _preferences.getString(_sessionKey);
    if (email == null) return null;

    final account = _readUsers()[email];
    if (account == null) {
      _preferences.remove(_sessionKey);
      return null;
    }

    return AppUser(
      id: email,
      email: email,
      fullName: account['fullName'] as String? ?? 'Shopper',
    );
  }

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 550));

    final key = email.trim().toLowerCase();
    final account = _readUsers()[key];
    if (account == null) {
      throw const AuthFailure('No demo account found for that email.');
    }
    if (account['passwordHash'] != _hash(password)) {
      throw const AuthFailure('Incorrect password. Please try again.');
    }

    await _preferences.setString(_sessionKey, key);
    return AppUser(
      id: key,
      email: key,
      fullName: account['fullName'] as String? ?? 'Shopper',
    );
  }

  @override
  Future<SignUpOutcome> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));

    final key = email.trim().toLowerCase();
    final users = _readUsers();
    if (users.containsKey(key)) {
      throw const AuthFailure(
        'An account with this email already exists. Try signing in.',
      );
    }

    users[key] = {
      'fullName': fullName.trim(),
      'passwordHash': _hash(password),
    };
    await _writeUsers(users);
    await _preferences.setString(_sessionKey, key);

    return SignUpOutcome(
      user: AppUser(id: key, email: key, fullName: fullName.trim()),
      requiresEmailConfirmation: false,
    );
  }

  @override
  Future<void> signOut() async {
    await _preferences.remove(_sessionKey);
  }

  void _seedDemoAccount() {
    final users = _readUsers();
    if (users.containsKey(demoEmail)) return;

    users[demoEmail] = {
      'fullName': demoFullName,
      'passwordHash': _hash(demoPassword),
    };
    _writeUsers(users);
  }

  Map<String, Map<String, dynamic>> _readUsers() {
    final raw = _preferences.getString(_usersKey);
    if (raw == null || raw.isEmpty) return {};

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return {};
      return decoded.map(
        (key, value) => MapEntry(
          key.toString(),
          Map<String, dynamic>.from(value as Map),
        ),
      );
    } catch (_) {
      return {};
    }
  }

  Future<void> _writeUsers(Map<String, Map<String, dynamic>> users) {
    return _preferences.setString(_usersKey, jsonEncode(users));
  }

  String _hash(String password) {
    return sha256.convert(utf8.encode('shopsphere::${password.trim()}')).toString();
  }
}
