import 'package:http/http.dart' as http;
void main() async {
  final url = 'https://xkwcyavcltrweunvooeu.supabase.co/rest/v1/articles?limit=1';
  final anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inhrd2N5YXZjbHRyd2V1bnZvb2V1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODEzNDk4NTIsImV4cCI6MjA5NjkyNTg1Mn0.j6miEKZCNQ2XJ_jx8eRLKMs-g_KSBBbigHsrWAgjxS4';
  
  final response = await http.get(Uri.parse(url), headers: {'apikey': anonKey, 'Authorization': 'Bearer $anonKey'});
  print(response.body);
}
