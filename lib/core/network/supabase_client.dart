import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/api_constants.dart';

// Riverpod Provider for SupabaseClient management
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  try {
    return Supabase.instance.client;
  } catch (_) {
    // If Supabase.initialize failed (e.g., due to complete offline start),
    // Supabase.instance is uninitialized and throws a StateError.
    // We return a fallback client so the app doesn't crash during widget build,
    // allowing the offline cache to serve data.
    return SupabaseClient(ApiConstants.supabaseUrl, ApiConstants.supabaseAnonKey);
  }
});

// Stream provider for listening to Supabase Auth state changes
final authStateProvider = StreamProvider<AuthState>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client.auth.onAuthStateChange;
});

// Provider for checking the current authenticated user
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.maybeWhen(
    data: (state) => state.session?.user,
    orElse: () => ref.read(supabaseClientProvider).auth.currentUser,
  );
});

class SupabaseManager {
  // Direct static getter for non-Riverpod areas if needed
  static SupabaseClient get client {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return SupabaseClient(ApiConstants.supabaseUrl, ApiConstants.supabaseAnonKey);
    }
  }
}

