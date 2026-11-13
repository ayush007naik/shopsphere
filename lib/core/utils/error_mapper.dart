import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

/// Converts low-level backend/network errors into copy suitable for users.
///
/// Raw database or auth messages are never shown directly, which avoids
/// leaking implementation details and keeps failure states understandable.
String friendlyError(Object error) {
  if (error is AuthException) {
    final message = error.message.toLowerCase();
    if (message.contains('invalid login credentials')) {
      return 'Incorrect email or password. Please try again.';
    }
    if (message.contains('already registered') ||
        message.contains('already exists')) {
      return 'An account with this email already exists. Try signing in.';
    }
    if (message.contains('email not confirmed')) {
      return 'Please confirm your email address before signing in.';
    }
    if (message.contains('rate limit') || message.contains('too many')) {
      return 'Too many attempts. Please wait a moment and try again.';
    }
    if (message.contains('password')) {
      return 'That password is not accepted. Use at least 6 characters.';
    }
    return 'We could not complete that request. Please try again.';
  }

  if (error is PostgrestException) {
    if (error.code == '42501' || error.message.contains('row-level security')) {
      return 'You do not have permission to view this content.';
    }
    if (error.code == 'PGRST301') {
      return 'Your session has expired. Please sign in again.';
    }
    return 'The store could not be reached right now. Please retry.';
  }

  final raw = error.toString().toLowerCase();
  if (raw.contains('socketexception') ||
      raw.contains('failed host lookup') ||
      raw.contains('network') ||
      raw.contains('clientexception')) {
    return 'No internet connection. Check your network and retry.';
  }
  if (error is TimeoutException) {
    return 'The request timed out. Please retry.';
  }

  return 'Something went wrong. Please try again.';
}
