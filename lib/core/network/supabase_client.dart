import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Riverpod Provider for SupabaseClient management
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
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
  static SupabaseClient get client => Supabase.instance.client;
}

