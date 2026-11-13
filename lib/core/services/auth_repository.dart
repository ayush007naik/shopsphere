import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/app_user.dart';

/// Raised by the offline demo auth implementation.
class AuthFailure implements Exception {
  const AuthFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

class SignUpOutcome {
  const SignUpOutcome({this.user, required this.requiresEmailConfirmation});

  final AppUser? user;
  final bool requiresEmailConfirmation;
}

abstract class AuthRepository {
  AppUser? get currentUser;

  Future<AppUser> signIn({required String email, required String password});

  Future<SignUpOutcome> signUp({
    required String email,
    required String password,
    required String fullName,
  });

  Future<void> signOut();
}

/// Live authentication backed by Supabase Auth. Sessions are restored and
/// persisted automatically by supabase_flutter.
class SupabaseAuthRepository implements AuthRepository {
  SupabaseClient get _client => Supabase.instance.client;

  @override
  AppUser? get currentUser {
    final user = _client.auth.currentUser;
    return user == null ? null : _mapUser(user);
  }

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
    final user = response.user;
    if (user == null) {
      throw const AuthException('Unable to sign in. Please try again.');
    }
    return _mapUser(user);
  }

  @override
  Future<SignUpOutcome> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final response = await _client.auth.signUp(
      email: email.trim(),
      password: password,
      data: {'full_name': fullName.trim()},
    );
    final user = response.user;
    return SignUpOutcome(
      user: user == null ? null : _mapUser(user),
      requiresEmailConfirmation: response.session == null,
    );
  }

  @override
  Future<void> signOut() => _client.auth.signOut();

  AppUser _mapUser(User user) {
    final metadata = user.userMetadata ?? const <String, dynamic>{};
    final name = (metadata['full_name'] as String?)?.trim();
    return AppUser(
      id: user.id,
      email: user.email ?? '',
      fullName: (name == null || name.isEmpty)
          ? (user.email?.split('@').first ?? 'Shopper')
          : name,
    );
  }
}
