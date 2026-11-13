/// Build-time configuration for the Supabase backend.
///
/// Values are injected with `--dart-define` so that no keys live in source
/// control:
///
/// ```sh
/// flutter run \
///   --dart-define=SUPABASE_URL=https://<project-ref>.supabase.co \
///   --dart-define=SUPABASE_ANON_KEY=<publishable-or-anon-key>
/// ```
///
/// Only the publishable/anon key may ever be used in a client application.
/// The service-role key must never be shipped in the app.
class AppConfig {
  const AppConfig._();

  static const String appName = 'ShopSphere';
  static const String appTagline = 'Considered goods, delivered.';
  static const String appVersion = '1.0.0';

  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');

  static const String _anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const String _publishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );

  /// Supports both the legacy `anon` key name and the newer publishable key.
  static String get supabaseKey =>
      _anonKey.isNotEmpty ? _anonKey : _publishableKey;

  static bool get hasCredentials =>
      supabaseUrl.trim().isNotEmpty && supabaseKey.trim().isNotEmpty;

  static bool get hasValidUrl {
    final uri = Uri.tryParse(supabaseUrl);
    return uri != null &&
        (uri.scheme == 'https' || uri.scheme == 'http') &&
        uri.host.isNotEmpty;
  }
}
