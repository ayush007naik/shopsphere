import '../constants/app_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Owns Supabase initialisation and exposes whether the app is running against
/// a live backend or the offline demo catalogue.
class SupabaseService {
  const SupabaseService._();

  static bool _initialized = false;
  static String? _initializationError;

  static bool get isInitialized => _initialized;
  static String? get initializationError => _initializationError;

  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    if (!AppConfig.hasCredentials) {
      _initializationError =
          'Supabase URL and publishable key were not provided at build time.';
      return;
    }
    if (!AppConfig.hasValidUrl) {
      _initializationError = 'The configured SUPABASE_URL is not a valid URL.';
      return;
    }

    try {
      await Supabase.initialize(
        url: AppConfig.supabaseUrl,
        publishableKey: AppConfig.supabaseKey,
      );
      _initialized = true;
    } catch (error) {
      _initializationError = error.toString();
      _initialized = false;
    }
  }
}
