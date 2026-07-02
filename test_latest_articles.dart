import 'package:supabase/supabase.dart';

class NewsArticle {
  final String id;
  NewsArticle(this.id);
  factory NewsArticle.fromJson(Map<String, dynamic> json) => NewsArticle(json['id'].toString());
}

void main() async {
  final supabaseUrl = 'https://xkwcyavcltrweunvooeu.supabase.co';
  final supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inhrd2N5YXZjbHRyd2V1bnZvb2V1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODEzNDk4NTIsImV4cCI6MjA5NjkyNTg1Mn0.j6miEKZCNQ2XJ_jx8eRLKMs-g_KSBBbigHsrWAgjxS4';
  
  final client = SupabaseClient(supabaseUrl, supabaseKey);
  
  List<NewsArticle> _cachedDbArticles = [];
  
  Stream<List<NewsArticle>> watchLatestArticles() async* {
    try {
      final stream = client
          .from('articles')
          .stream(primaryKey: ['id'])
          .eq('status', 'published')
          .order('created_at', ascending: false);

      await for (final maps in stream) {
        final dbArticles = maps.map((map) => NewsArticle.fromJson(map)).toList();
        _cachedDbArticles = dbArticles;
        print('Yielding ${dbArticles.length} latest articles inside loop');
        yield [...dbArticles];
      }
    } catch (e) {
      print('watchLatestArticles caught error: $e');
      print('Yielding ${_cachedDbArticles.length} cached articles in catch block');
      yield [..._cachedDbArticles];
    }
  }

  watchLatestArticles().listen((data) {
    print('Latest stream received data: ${data.length}');
  }, onError: (e) {
    print('Latest stream received error: $e');
  });
  
  await Future.delayed(Duration(seconds: 3));
}
