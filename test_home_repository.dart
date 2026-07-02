import 'package:supabase/supabase.dart';

void main() async {
  final supabaseUrl = 'https://xkwcyavcltrweunvooeu.supabase.co';
  final supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inhrd2N5YXZjbHRyd2V1bnZvb2V1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODEzNDk4NTIsImV4cCI6MjA5NjkyNTg1Mn0.j6miEKZCNQ2XJ_jx8eRLKMs-g_KSBBbigHsrWAgjxS4';
  
  final client = SupabaseClient(supabaseUrl, supabaseKey);
  
  // mock watchLatestArticles
  Stream<List<Map<String, dynamic>>> watchLatestArticles() async* {
    try {
      final stream = client
          .from('articles')
          .stream(primaryKey: ['id'])
          .eq('status', 'published')
          .order('created_at', ascending: false);

      await for (final maps in stream) {
        print('Yielding ${maps.length} latest articles');
        yield maps;
      }
    } catch (e) {
      print('watchLatestArticles caught error: $e');
      yield [];
    }
  }

  // mock watchTrendingArticles
  Stream<List<Map<String, dynamic>>> watchTrendingArticles() {
    return client
        .from('articles')
        .stream(primaryKey: ['id'])
        .eq('status', 'published')
        .map((maps) {
          print('Yielding ${maps.length} trending articles');
          return maps;
        });
  }

  print('Starting trending...');
  watchTrendingArticles().listen((data) {
    print('Trending received data: ${data.length}');
  }, onError: (e) {
    print('Trending received error: $e');
  });
  
  print('Starting latest...');
  watchLatestArticles().listen((data) {
    print('Latest received data: ${data.length}');
  }, onError: (e) {
    print('Latest received error: $e');
  });
  
  await Future.delayed(Duration(seconds: 3));
}
