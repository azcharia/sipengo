import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/supabase_config.dart';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );
  }

  // Auth helpers
  static User? get currentUser => client.auth.currentUser;
  static bool get isAuthenticated => currentUser != null;
  static String? get currentUserId => currentUser?.id;

  // Sign in
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Sign out
  static Future<void> signOut() async {
    await client.auth.signOut();
  }

  // Database helpers
  static SupabaseQueryBuilder get families => client.from('families');
  static SupabaseQueryBuilder get residents => client.from('residents');

  // Storage helpers
  static SupabaseStorageClient get storage => client.storage;
}
