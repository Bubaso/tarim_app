import 'package:supabase/supabase.dart';

void main() async {
  final supabaseUrl = 'https://xkwcyavcltrweunvooeu.supabase.co';
  final supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inhrd2N5YXZjbHRyd2V1bnZvb2V1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODEzNDk4NTIsImV4cCI6MjA5NjkyNTg1Mn0.j6miEKZCNQ2XJ_jx8eRLKMs-g_KSBBbigHsrWAgjxS4';
  
  final client = SupabaseClient(supabaseUrl, supabaseKey);
  
  final res = await client.from('articles').select('id, created_at').eq('status', 'published');
  
  int nullCreatedAt = 0;
  for (var row in res) {
    if (row['created_at'] == null) {
      nullCreatedAt++;
    }
  }
  
  print('Total published: ${res.length}');
  print('Total with null created_at: $nullCreatedAt');
}
