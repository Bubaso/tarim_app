import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ══════════════════════════════════════════════════════════════════════════════
//  Köşe yazarları — TEK KAYNAK `columnists` tablosu
// ──────────────────────────────────────────────────────────────────────────────
//  Burada eskiden koda gömülü 5 UYDURMA yazar vardı (Unsplash stok fotoğrafı,
//  olmayan isimler). Gerçek yazarlar veritabanında; liste koda gömülü kaldığı
//  sürece panelden yazar eklemek/çıkarmak siteye hiç yansımıyordu ve sitede
//  var olmayan kişiler görünüyordu.
//
//  Yazı bağlantısı: `articles.source_name` = `columnists.name`. Bağlantı ada
//  dayandığı için isim veritabanında ne yazıyorsa O kullanılıyor; burada
//  yeniden biçimlendirmek (büyük/küçük harf düzeltmek dâhil) yazıları
//  yazarından KOPARIR.
// ══════════════════════════════════════════════════════════════════════════════

@immutable
class AiColumnist {
  final String name;

  /// Rota yolunda geçen slug (`/yazar/<slug>`). Veritabanındaki `slug`.
  final String slug;
  final String titleTr;
  final String titleEn;

  /// Boş olabilir: her yazarın fotoğrafı yok. Arayüz boşsa baş harflere düşüyor.
  final String avatarUrl;

  const AiColumnist({
    required this.name,
    required this.slug,
    required this.titleTr,
    required this.titleEn,
    required this.avatarUrl,
  });

  factory AiColumnist.fromMap(Map<String, dynamic> m) {
    final ad = (m['name'] as String?)?.trim() ?? '';
    final trUnvan = (m['title_tr'] as String?)?.trim() ?? '';
    final enUnvan = (m['title_en'] as String?)?.trim() ?? '';
    return AiColumnist(
      name: ad,
      slug: (m['slug'] as String?)?.trim() ?? '',
      titleTr: trUnvan,
      // İngilizce unvan yoksa Türkçesine düşmek, boş satır göstermekten iyi.
      titleEn: enUnvan.isEmpty ? trUnvan : enUnvan,
      avatarUrl: (m['avatar_url'] as String?)?.trim() ?? '',
    );
  }
}

/// Senkron erişim için en son okunan liste.
///
/// Rota çözümleyicisi (`_findColumnist`) ve `_isOpEd` gibi widget dışı
/// yardımcılar `ref`e ulaşamıyor; onlar bu önbelleği okuyor.
/// [columnistsProvider] her başarılı okumada burayı günceller.
List<AiColumnist> aiColumnists = const <AiColumnist>[];

/// `columnists` tablosu — yalnızca aktif olanlar, panelde verilen sırayla.
final columnistsProvider = FutureProvider<List<AiColumnist>>((ref) async {
  try {
    final veri = await Supabase.instance.client
        .from('columnists')
        .select()
        .eq('is_active', true)
        .order('sort_order');

    final liste = List<Map<String, dynamic>>.from(veri as List)
        .map(AiColumnist.fromMap)
        .where((c) => c.name.isNotEmpty && c.slug.isNotEmpty)
        .toList(growable: false);

    aiColumnists = liste;
    return liste;
  } catch (e) {
    if (kDebugMode) print('columnists okunamadi: $e');
    // Elde bir şey varsa onu koru: ağ hatasında yazar şeridini tamamen
    // boşaltmak, eski listeyi göstermekten kötü.
    return aiColumnists;
  }
});

/// Bu haber bir köşe yazısı mı? Bağ `articles.source_name` = `columnists.name`
/// (§24.4) — tek harflik fark eşleşmeyi sessizce düşürür.
bool koseYazisiMi(String? sourceName) {
  final ad = sourceName?.trim();
  if (ad == null || ad.isEmpty) return false;
  return aiColumnists.any((c) => c.name == ad);
}
