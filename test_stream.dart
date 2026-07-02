import 'package:supabase/supabase.dart';

void main() async {
  final supabaseUrl = 'https://xkwcyavcltrweunvooeu.supabase.co';
  final supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inhrd2N5YXZjbHRyd2V1bnZvb2V1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODEzNDk4NTIsImV4cCI6MjA5NjkyNTg1Mn0.j6miEKZCNQ2XJ_jx8eRLKMs-g_KSBBbigHsrWAgjxS4';
  
  final client = SupabaseClient(supabaseUrl, supabaseKey);
  
  try {
    final stream = client
        .from('articles')
        .stream(primaryKey: ['id'])
        .eq('status', 'published');
        
    await for (final maps in stream) {
      print('Parsed ${maps.length} maps');
      break;
    }
  } catch (e, stack) {
    print('Stream error: $e');
  }
}
