import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../dossiers/data/models/dosya_haberi.dart';
import 'tni_model.dart';

/// Turkuaz Bağlantısallık Girişimi sayfasının CANLI katmanı.
///
/// Sayfanın gövdesi gömülü (`tniVeri`); burada okunan iki şey var:
///   · `tni_ortu`      — halka durumları ve bilinmeyenlerin çözülmüş hâli
///   · `tni_haberleri` — girişimi anan haberler
///
/// İkisi de DÜŞMEYE DAYANIKLI: hata yakalanıyor ve boş dönülüyor. Ama
/// "okunamadı" ile "boş geldi" ayrımı KAYBEDİLMİYOR — sayfa künyesinde
/// okurun gördüğü şeyin hangi tarihe ait olduğunu söyleyebilmek için
/// `TniOrtuSonucu.okundu` taşınıyor. Sessizce eski veri göstermek, bu
/// portalın tipik arıza biçimi.
class TniDeposu {
  final SupabaseClient _istemci;

  TniDeposu(this._istemci);

  Future<TniOrtuSonucu> ortuGetir() async {
    try {
      final yanit = await _istemci
          .from('tni_ortu')
          .select()
          .eq('yayinda', true)
          .order('sira');
      final satirlar = (yanit as List)
          .map((r) => TniOrtuSatiri.jsondan((r as Map).cast<String, dynamic>()))
          .toList();
      return TniOrtuSonucu(satirlar: satirlar, okundu: true);
    } catch (e) {
      // Tablo henüz göç edilmemişse de buraya düşüyor. Sayfa yine eksiksiz
      // çiziliyor — yalnızca gömülü katmanın tarihine ait hâliyle.
      if (kDebugMode) print('tni_ortu okunamadı: $e');
      return const TniOrtuSonucu(satirlar: [], okundu: false);
    }
  }

  /// Girişimi anan haberler. Eşik ve terimler SUNUCUDA (`tni_haberleri`);
  /// istemci süzme yapmıyor ki iki yerde iki farklı ölçü oluşmasın.
  Future<List<DosyaHaberi>> haberler({int limit = 6}) async {
    try {
      final yanit = await _istemci.rpc(
        'tni_haberleri',
        params: {'p_limit': limit, 'p_min_puan': 2},
      );
      return (yanit as List)
          .map((r) => DosyaHaberi.fromJson((r as Map).cast<String, dynamic>()))
          .toList();
    } catch (e) {
      if (kDebugMode) print('tni_haberleri okunamadı: $e');
      return [];
    }
  }
}

class TniOrtuSonucu {
  final List<TniOrtuSatiri> satirlar;
  final bool okundu;
  const TniOrtuSonucu({required this.satirlar, required this.okundu});
}
