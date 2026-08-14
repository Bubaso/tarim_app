import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/commodity_price.dart';

/// Emtia fiyatlarını kendi veritabanımızdan okur.
///
/// Bilerek dış API çağrısı yok. Uygulamadaki küresel piyasa modülü fiyatı
/// tarayıcıdan Yahoo Finance'e giderek çekiyor ve CORS engelini aşmak için
/// dört ayrı vekil sunucuyu sırayla deniyor; hepsi başarısız olursa koda gömülü
/// sahte rakamlara düşüyor. O zincirin en kötü günü ~36 saniye sürüyor.
///
/// Burada fiyatı Python hattı topluyor. Uygulamanın tek yaptığı hazır tabloyu
/// okumak: tek sorgu, vekil yok, yedek uydurma veri yok. Veri gelmezse şerit
/// hiç görünmüyor — yanlış fiyat göstermektense hiç göstermemek doğru.
class CommodityRepository {
  final SupabaseClient _supabaseClient;

  CommodityRepository(this._supabaseClient);

  /// Şeritteki tüm ürünlerin son fiyatı.
  ///
  /// Sıralama ve 14 günden eski fiyatın gizlenmesi görünümün işi; burada
  /// tekrar filtrelenmiyor ki iki yerde iki farklı kural oluşmasın.
  Future<List<CommodityPrice>> fetchLatestPrices() async {
    try {
      final response = await _supabaseClient.from('commodity_latest_prices').select();
      return (response as List)
          .map((row) => CommodityPrice.fromJson(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('fetchLatestPrices error: $e');
      }
      return [];
    }
  }

  /// Detay sayfasındaki grafiğin verisi.
  ///
  /// Gün sayısı değil kayıt sayısı sınırlanıyor: borsa haftada beş gün açık ve
  /// bazı ürünler ayda birkaç gün işlem görüyor. "Son 90 gün" bir üründe 60
  /// nokta, diğerinde 4 nokta demek olurdu.
  Future<List<CommodityPricePoint>> fetchHistory(String slug, {int limit = 120}) async {
    try {
      final response = await _supabaseClient
          .from('commodity_price_history')
          .select('price_date, avg_price')
          .eq('slug', slug)
          .order('price_date', ascending: false)
          .limit(limit);

      final points = (response as List)
          .map((row) => CommodityPricePoint.fromJson(row as Map<String, dynamic>))
          .toList();

      // Sorgu en yeniden başlıyor (limit doğru ucu kessin diye); grafik eskiden
      // yeniye çiziliyor.
      return points.reversed.toList();
    } catch (e) {
      if (kDebugMode) {
        print('fetchHistory error: $e');
      }
      return [];
    }
  }
}
