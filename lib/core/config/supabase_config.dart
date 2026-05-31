class SupabaseConfig {
  // Load from environment variables
  // Set these via: flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
  // Or use .env file with flutter_dotenv package
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://hpbdoprdkdcflhafobgk.supabase.co',
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhwYmRvcHJka2RjZmxoYWZvYmdrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU5ODUyMjEsImV4cCI6MjA4MTU2MTIyMX0.D4cU6bf6y8Le_TM9L0UucSIgd8PSj4L5EfTIy3MM_R4',
  );

  // Validate configuration
  static bool isConfigured() {
    return supabaseUrl != 'https://your-project.supabase.co' &&
        supabaseAnonKey != 'your-anon-key-here';
  }
}
