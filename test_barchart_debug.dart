import 'dart:io';
import 'dart:convert';

void main() async {
  final client = HttpClient();
  final request = await client.getUrl(Uri.parse('https://www.barchart.com/futures/quotes/SWQ26'));
  request.headers.set('User-Agent', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36');
  request.headers.set('Accept', 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8');
  
  final response = await request.close();
  final contents = await response.transform(utf8.decoder).join();
  
  // Look for the specific symbol object in the JSON
  // Sometimes it's structured like "symbol":"SWQ26",...,"lastPrice":"481.50"
  
  // Find "SWQ26" block
  final index = contents.indexOf('"symbol":"SWQ26"');
  if (index != -1) {
    final substring = contents.substring(index, index + 500);
    print(substring);
    
    final pMatch = RegExp(r'"lastPrice":"([^"]+)"').firstMatch(substring);
    if (pMatch != null) {
      print("Found price from substring: " + pMatch.group(1)!);
    }
  } else {
    print("Symbol SWQ26 not found explicitly.");
  }
}
