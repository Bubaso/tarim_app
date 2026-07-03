import 'dart:io';
import 'dart:convert';

void main() async {
  final client = HttpClient();
  final request = await client.getUrl(Uri.parse('https://www.barchart.com/futures/quotes/SBN26'));
  request.headers.set('User-Agent', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36');
  request.headers.set('Accept', 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8');
  
  final response = await request.close();
  final contents = await response.transform(utf8.decoder).join();
  
  final priceRegex = RegExp(r'"lastPrice":"([^"]+)"');
  final prevRegex = RegExp(r'"previousPrice":"([^"]+)"');
  
  final priceMatch = priceRegex.firstMatch(contents);
  final prevMatch = prevRegex.firstMatch(contents);
  
  if (priceMatch != null) {
    print("SBN26 price: " + priceMatch.group(1)!);
    if (prevMatch != null) print("SBN26 prev: " + prevMatch.group(1)!);
  } else {
    print("Not found.");
  }
}
