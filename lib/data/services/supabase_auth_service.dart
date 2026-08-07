import 'package:nasyad/data/remote/supabase/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthService {
  SupabaseAuthService({
    SupabaseClient? client,
    SupabaseConfig config = SupabaseConfig.fromEnvironment,
  }) : _client = client,
       _config = config;

  final SupabaseClient? _client;
  final SupabaseConfig _config;

  bool get isConfigured => _config.isConfigured;

  SupabaseClient? get _resolvedClient {
    if (_client != null) return _client;
    if (!_config.isConfigured) return null;
    if (!Supabase.instance.isInitialized) return null;
    return Supabase.instance.client;
  }

  Stream<AuthState> authStateChanges() {
    final client = _resolvedClient;
    if (client == null) {
      return Stream.value(
        const AuthState(AuthChangeEvent.signedOut, null),
      );
    }
    return client.auth.onAuthStateChange;
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    final client = _requireClient();
    return client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    final client = _requireClient();
    return client.auth.signUp(email: email, password: password);
  }

  Future<void> signOut() async {
    final client = _resolvedClient;
    if (client == null) return;
    await client.auth.signOut();
  }

  SupabaseClient _requireClient() {
    final client = _resolvedClient;
    if (client == null) {
      throw StateError('Supabase is not configured');
    }
    return client;
  }
}
