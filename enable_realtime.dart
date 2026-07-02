import 'package:supabase/supabase.dart';

void main() async {
  final supabaseUrl = 'https://xkwcyavcltrweunvooeu.supabase.co';
  final supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inhrd2N5YXZjbHRyd2V1bnZvb2V1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODEzNDk4NTIsImV4cCI6MjA5NjkyNTg1Mn0.j6miEKZCNQ2XJ_jx8eRLKMs-g_KSBBbigHsrWAgjxS4';
  
  final client = SupabaseClient(supabaseUrl, supabaseKey);
  
  try {
    // Try to enable realtime using RPC if available, or just query if it's enabled.
    // The easiest way is to alter publication supabase_realtime add table articles;
    // We can execute SQL through a postgres function if we have one.
    // But we don't have superuser rights via REST.
    final res = await client.rpc('enable_realtime_articles'); // probably doesn't exist
    print(res);
  } catch (e) {
    print('Failed: $e');
  }
}
