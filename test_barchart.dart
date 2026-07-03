import 'dart:io';
import 'dart:convert';

void main() async {
  final client = HttpClient();
  final request = await client.getUrl(Uri.parse('https://www.barchart.com/futures/quotes/SWQ26'));
  request.headers.set('User-Agent', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36');
  request.headers.set('Accept', 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8');
  
  final response = await request.close();
  final contents = await response.transform(utf8.decoder).join();
  
  final regex = RegExp(r'"lastPrice":"([^"]+)"');
  final match = regex.firstMatch(contents);
  if (match != null) {
    print("Found price: \${match.group(1)}");
  } else {
    print("Not found. Content length: \${contents.length}");
    print(contents.substring(0, 200));
  }
}
