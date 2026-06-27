import 'dart:io';
import 'package:supabase/supabase.dart';

void main() async {
  final supabase = SupabaseClient(
    'https://xkwcyavcltrweunvooeu.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inhrd2N5YXZjbHRyd2V1bnZvb2V1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODEzNDk4NTIsImV4cCI6MjA5NjkyNTg1Mn0.j6miEKZCNQ2XJ_jx8eRLKMs-g_KSBBbigHsrWAgjxS4',
  );

  try {
    final response = await supabase
        .from('articles')
        .select('title, image_url')
        .ilike('title', '%Topraksız Tarım Yatırımları%')
        .limit(5);
    
    print('Result: $response');
  } catch (e) {
    print('Error: $e');
  }
  exit(0);
}
