import 'dart:io';
import 'package:supabase/supabase.dart';
import 'package:dotenv/dotenv.dart';

void main() async {
  var env = DotEnv(includePlatformEnvironment: true)..load();
  final supabaseUrl = env['SUPABASE_URL'] ?? 'https://vjymlygxyjzylduzwldp.supabase.co';
  final supabaseKey = env['SUPABASE_ANON_KEY'] ?? 'ey...'; // I will get the key from lib/core/constants/api_constants.dart
  
  // wait, let me just read api_constants.dart instead of writing a script that needs the key
}
