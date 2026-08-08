import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/api_constants.dart';

/// Konum (İl/İlçe) ismine göre Unsplash'ten görsel bulan ve 
/// bunu telefon hafızasına (cache) kaydeden akıllı provider.
final locationImageProvider = FutureProvider.family<String?, String>((ref, cityName) async {
  if (cityName.isEmpty) return null;

  final prefs = await SharedPreferences.getInstance();
  final cacheKey = 'unsplash_img_$cityName';

  // 1. Önce telefonun önbelleğine (Cache/Supabase havuzu mantığı) bak
  final cachedUrl = prefs.getString(cacheKey);
  if (cachedUrl != null && cachedUrl.isNotEmpty) {
    return cachedUrl;
  }

  // Varsayılan muazzam bir tarım/doğa fotoğrafı (API key yoksa veya kota dolarsa düşecek)
  const fallbackImage = 'https://images.unsplash.com/photo-1593113598332-cd288d649433?w=1200&auto=format&fit=crop&q=80';

  // 2. Unsplash API'sine sor
  try {
    final apiKey = ApiConstants.unsplashApiKey;
    if (apiKey == 'YOUR_UNSPLASH_ACCESS_KEY' || apiKey.isEmpty) {
      // API key girilmemişse, testi engellememek için fallback döneriz.
      return fallbackImage;
    }

    final query = Uri.encodeComponent(cityName);
    // Orientasyon landscape (yatay) ve sadece 1 fotoğraf getir.
    final url = Uri.parse('https://api.unsplash.com/search/photos?query=$query&orientation=landscape&per_page=1');
    
    final response = await http.get(url, headers: {
      'Authorization': 'Client-ID $apiKey',
      'Accept-Version': 'v1'
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'] != null && data['results'].isNotEmpty) {
        final imageUrl = data['results'][0]['urls']['regular'];
        
        // Fotoğrafı bulduk! Sonraki 1000 tıklama için cache'e (Supabase simülasyonu) kaydet.
        await prefs.setString(cacheKey, imageUrl);
        return imageUrl;
      } else {
        // O ilçe için fotoğraf yoksa genel "Türkiye Tarım" araması yap (Şelale mantığı 2)
        final fallbackSearch = Uri.parse('https://api.unsplash.com/search/photos?query=agriculture%20nature&orientation=landscape&per_page=1');
        final fallbackRes = await http.get(fallbackSearch, headers: {
          'Authorization': 'Client-ID $apiKey'
        });
        if (fallbackRes.statusCode == 200) {
           final fallbackData = json.decode(fallbackRes.body);
           if (fallbackData['results'] != null && fallbackData['results'].isNotEmpty) {
             final img = fallbackData['results'][0]['urls']['regular'];
             await prefs.setString(cacheKey, img);
             return img;
           }
        }
      }
    }
  } catch (e) {
    debugPrint('Unsplash API Hatası: $e');
  }

  return fallbackImage;
});
