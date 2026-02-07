class SupabaseConfig {
  // Load from environment variables
  // Set these via: flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
  // Or use .env file with flutter_dotenv package
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://your-project.supabase.co',
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'your-anon-key-here',
  );

  // Validate configuration
  static bool isConfigured() {
    return supabaseUrl != 'https://your-project.supabase.co' &&
        supabaseAnonKey != 'your-anon-key-here';
  }
}
