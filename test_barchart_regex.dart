import 'dart:io';
import 'dart:convert';

void main() async {
  final symbol = 'SWQ26';
  final client = HttpClient();
  final request = await client.getUrl(Uri.parse('https://www.barchart.com/futures/quotes/SWQ26'));
  request.headers.set('User-Agent', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36');
  request.headers.set('Accept', 'text/html');
  final response = await request.close();
  final contents = await response.transform(utf8.decoder).join();
  
  final regex = RegExp('"$symbol".{0,500}?"lastPrice":"([^"]+)"');
  final match = regex.firstMatch(contents);
  if (match != null) {
    print("MATCH: " + match.group(1)!);
  } else {
    print("NO MATCH");
  }
}
