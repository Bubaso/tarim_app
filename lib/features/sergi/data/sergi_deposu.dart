import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'models/sergi_eseri.dart';

/// Sergi verisini veritabanından okur.
///
/// Üç sorgu var ve üçü de AYRI tutuldu:
///   · `gununSecimi`  — anasayfa bandı, 12 kare, sunucuda gün başına seçili
///   · `tumu`         — sergi sayfası, 114 kare
///   · `yarisma`      — yarışmanın üst verisi
///
/// Band sayfanın tamamını çekmiyor: 114 kayıt anasayfaya her açılışta ~25 KB
/// ekler ve on ikisi dışında hiçbiri çizilmez.
class SergiDeposu {
  final SupabaseClient _istemci;

  SergiDeposu(this._istemci);

  /// Anasayfa bandı. Seçim SUNUCUDA yapılıyor (`sergi_gunun_secimi`):
  /// aynı gün herkese aynı on iki kare. İstemcide yapılsaydı cihazın saat
  /// dilimi seçimi değiştirirdi ve aynı okur gün içinde farklı sergiler
  /// görürdü.
  Future<List<SergiEseri>> gununSecimi({
    String yarisma = 'utoify-16',
    int adet = 12,
  }) async {
    try {
      final yanit = await _istemci.rpc(
        'sergi_gunun_secimi',
        params: {'p_yarisma': yarisma, 'p_adet': adet},
      );
      return (yanit as List)
          .map((r) => SergiEseri.fromJson((r as Map).cast<String, dynamic>()))
          .toList();
    } catch (e) {
      // Göç uygulanmamışsa da buraya düşüyor. Band hiç çizilmiyor —
      // boş bir başlık göstermektense hiç göstermemek doğru.
      if (kDebugMode) print('sergi_gunun_secimi okunamadı: $e');
      return const [];
    }
  }

  Future<SergiVerisi?> tumu({String yarisma = 'utoify-16'}) async {
    try {
      final y = await _istemci
          .from('sergi_yarismalari')
          .select()
          .eq('kod', yarisma)
          .maybeSingle();
      if (y == null) return null;
      final e = await _istemci
          .from('sergi_eserleri')
          .select()
          .eq('yarisma_kod', yarisma)
          .eq('yayinda', true)
          .order('sira');
      return SergiVerisi(
        yarisma: SergiYarismasi.fromJson(y.cast<String, dynamic>()),
        eserler: (e as List)
            .map((r) => SergiEseri.fromJson((r as Map).cast<String, dynamic>()))
            .toList(),
      );
    } catch (ex) {
      if (kDebugMode) print('sergi okunamadı: $ex');
      return null;
    }
  }
}
