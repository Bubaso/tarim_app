import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tarim_app/core/constants/api_constants.dart';

void main() async {
  await Supabase.initialize(
    url: ApiConstants.supabaseUrl,
    anonKey: ApiConstants.supabaseAnonKey,
  );
  
  final client = Supabase.instance.client;
  
  try {
    print('Testing increment_view_count...');
    // I need a valid row_id to test
    final articles = await client.from('articles').select('id, view_count').limit(1);
    if (articles.isEmpty) {
      print('No articles found');
      return;
    }
    
    final id = articles.first['id'];
    print('Testing for ID: $id (current view count: ${articles.first['view_count']})');
    
    await client.rpc('increment_view_count', params: {'row_id': id});
    print('RPC successful!');
    
    final after = await client.from('articles').select('id, view_count').eq('id', id).single();
    print('After RPC view count: ${after['view_count']}');
    
  } catch (e) {
    print('RPC Failed: $e');
  }
}
