import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

void main() async {
  final url = 'https://xkwcyavcltrweunvooeu.supabase.co/rest/v1/articles';
  final anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inhrd2N5YXZjbHRyd2V1bnZvb2V1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODEzNDk4NTIsImV4cCI6MjA5NjkyNTg1Mn0.j6miEKZCNQ2XJ_jx8eRLKMs-g_KSBBbigHsrWAgjxS4';
  
  final jsonPayload = {
    "id": Uuid().v4(),
    "title": "Test Title",
    "content": "Test content",
    "status": "reviewing",
    "created_at": DateTime.now().toUtc().toIso8601String(),
    "slug": "test-slug-12345",
    "view_count": 0
  };

  final response = await http.post(
    Uri.parse(url),
    headers: {
      'apikey': anonKey,
      'Authorization': 'Bearer $anonKey',
      'Content-Type': 'application/json',
      'Prefer': 'return=representation'
    },
    body: jsonEncode(jsonPayload),
  );

  print('Status: ${response.statusCode}');
  print('Body: ${response.body}');
}
