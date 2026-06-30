import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tarim_app/core/constants/api_constants.dart';

void main() {
  test('Test Supabase Insert', () async {
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: ApiConstants.supabaseUrl,
      anonKey: ApiConstants.supabaseAnonKey,
    );
    final supabase = Supabase.instance.client;
    try {
      final response = await supabase
          .from('agent_jobs')
          .insert({'status': 'pending'})
          .select('id')
          .single();
      print('SUCCESS: $response');
    } catch (e) {
      print('ACTUAL ERROR: $e');
    }
  });
}
