import 'package:flutter/foundation.dart';

import '../core/services/auth_repository.dart';
import '../core/services/supabase_service.dart';
import '../core/utils/error_mapper.dart';
import '../models/app_user.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthOutcome {
  const AuthOutcome._({
    required this.success,
    this.message,
    this.requiresEmailConfirmation = false,
  });

  factory AuthOutcome.success({
    String? message,
    bool requiresEmailConfirmation = false,
  }) {
    return AuthOutcome._(
      success: true,
      message: message,
      requiresEmailConfirmation: requiresEmailConfirmation,
    );
  }

  factory AuthOutcome.failure(String message) {
    return AuthOutcome._(success: false, message: message);
  }

  final bool success;
  final String? message;
  final bool requiresEmailConfirmation;
}

/// Session state for the whole app.
class AuthProvider extends ChangeNotifier {
  AuthProvider(this._repository);

  final AuthRepository _repository;

  AuthStatus _status = AuthStatus.unknown;
  AppUser? _user;
  bool _isSubmitting = false;
  String? _errorMessage;
  bool _initialized = false;

  AuthStatus get status => _status;
  AppUser? get user => _user;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  /// True only when the app is talking to a real Supabase project.
  bool get isLiveBackend => SupabaseService.isInitialized;
  bool get isDemoMode => !isLiveBackend;
  String get backendLabel => isLiveBackend ? 'Supabase connected' : 'Offline demo';

  /// Restores the persisted session. Called once from the splash screen.
  Future<void> initialize() async {
    if (_initialized) return;
    _user = _repository.currentUser;
    _status = _user == null
        ? AuthStatus.unauthenticated
        : AuthStatus.authenticated;
    _initialized = true;
    notifyListeners();
  }

  Future<AuthOutcome> signIn({
    required String email,
    required String password,
  }) async {
    if (_isSubmitting) {
      return AuthOutcome.failure('A sign-in is already in progress.');
    }
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _repository.signIn(email: email, password: password);
      _status = AuthStatus.authenticated;
      return AuthOutcome.success();
    } catch (error) {
      final message = error is AuthFailure
          ? error.message
          : friendlyError(error);
      _errorMessage = message;
      _status = AuthStatus.unauthenticated;
      return AuthOutcome.failure(message);
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<AuthOutcome> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    if (_isSubmitting) {
      return AuthOutcome.failure('A request is already in progress.');
    }
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final outcome = await _repository.signUp(
        email: email,
        password: password,
        fullName: fullName,
      );

      if (outcome.user != null) {
        _user = outcome.user;
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }

      return AuthOutcome.success(
        message: outcome.requiresEmailConfirmation
            ? 'Account created. Confirm your email, then sign in.'
            : null,
        requiresEmailConfirmation: outcome.requiresEmailConfirmation,
      );
    } catch (error) {
      final message = error is AuthFailure
          ? error.message
          : friendlyError(error);
      _errorMessage = message;
      _status = AuthStatus.unauthenticated;
      return AuthOutcome.failure(message);
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _repository.signOut();
    _user = null;
    _status = AuthStatus.unauthenticated;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }
}
