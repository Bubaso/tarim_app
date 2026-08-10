import 'package:supabase_flutter/supabase_flutter.dart';
import 'lib/core/constants/api_constants.dart';
import 'lib/features/home/data/models/news_article.dart';

void main() async {
  print('Starting test...');
  await Supabase.initialize(
    url: ApiConstants.supabaseUrl,
    publishableKey: ApiConstants.supabaseAnonKey,
  );
  
  final supabase = Supabase.instance.client;
  print('Fetching articles...');
  try {
    final response = await supabase.from('articles').select().limit(5);
    for (var row in response) {
      try {
        final article = NewsArticle.fromJson(row);
        print('Parsed article: ${article.title}');
      } catch (e, stacktrace) {
        print('Error parsing article: $e');
        print(stacktrace);
      }
    }
  } catch (e) {
    print('Error fetching: $e');
  }
}
