import 'package:flutter_test/flutter_test.dart';
import 'package:tarim_app/features/home/data/models/news_article.dart';
import 'package:tarim_app/features/home/data/repositories/home_repository.dart';

// ══════════════════════════════════════════════════════════════════════════
//  Panelden kaydetmek hangi sütunlara DOKUNMAMALI
// ──────────────────────────────────────────────────────────────────────────
//  Aynı tuzak iki kez kuruldu ve ikisinde de üretimde veri gitti:
//
//    §25.1 — form `toJson()` ile bütün satırı yazıyordu, muhabirin
//            doğrulama verisi (facts / figures / quotes) siliniyordu.
//            Çözüm forma taşıyıcı satırlar eklemek oldu.
//    8 Kas 2026 — aynı yoldan sekiz sütun daha sıfırlanıyordu: fotoğraf
//            künyesi, kaynak tarihi, görsel türevleri, kısa haber etiketi.
//            Yani ilk çözüm, yeni sütun eklendiğinde yine bozuldu.
//
//  Kalıcı çözüm formun SAHİP OLDUĞU alanları yazmak. Bu test o kararı
//  koruyor: korumalı listeden bir sütun form haritasına girerse, test
//  kırılır ve üçüncü kez veri kaybı yaşanmaz.
// ══════════════════════════════════════════════════════════════════════════

/// Formun ASLA yazmaması gereken sütunlar ve neden.
const korumali = <String, String>{
  'facts': 'muhabirin doğrulama verisi (§25.1)',
  'figures': 'doğrulama verisi (§25.1)',
  'quotes': 'doğrulama verisi (§25.1)',
  'image_credit': 'fotoğraf künyesi — telif',
  'image_caption': 'fotoğraf altyazısı',
  'published_at': 'kaynaktaki yayın tarihi — kuyruğun bayatlık rozeti',
  'thumb_image_url': 'hikâye görsel türevi',
  'image_lqip': 'hikâye görsel türevi',
  'hero_pinned_at': 'manşete sabitlenme zamanı',
  'chart_data': 'grafik verisi',
  'chart_data_en': 'İngilizce grafik verisi',
  'article_format': 'kısa haber etiketi',
  'rejected_at': 'red damgası',
  'rejection_reason': 'red gerekçesi',
  'created_at': 'haberin yazılma zamanı — hiçbir düzenleme değiştirmemeli',
  'view_count': 'okunma sayacı — istemci asla yazmamalı',
};

NewsArticle h() => NewsArticle(
      id: 'x',
      title: 'Başlık',
      content: 'gövde',
      createdAt: DateTime(2026, 11, 8),
      status: 'published',
    );

void main() {
  test('form haritası korumalı sütunlara dokunmuyor', () {
    final alanlar = HomeRepository.formAlanlari(h());
    final ihlal = korumali.keys.where(alanlar.containsKey).toList();

    expect(
      ihlal,
      isEmpty,
      reason: 'Form bu sütunları yazıyor ve her kaydetmede SİLER:\n'
          '${ihlal.map((k) => '  $k — ${korumali[k]}').join('\n')}',
    );
  });

  test('form haritası formun gerçekten düzenlediği alanları yazıyor', () {
    final alanlar = HomeRepository.formAlanlari(h());
    // Boş bir harita da yukarıdaki testi geçerdi; iş yapıldığını doğrula.
    for (final k in ['title', 'content', 'summary', 'image_url', 'status']) {
      expect(alanlar.containsKey(k), isTrue, reason: '$k yazılmıyor');
    }
  });

  test('rejected_at ve rejection_reason toJson\'a girmiyor', () {
    // Modele yeni eklendiler. toJson'a konsalardı, bu iki alanı taşımayan
    // her çağrı reddin kaydını sıfırlardı — §25.1'in aynı tuzağı.
    final json = h().toJson();
    expect(json.containsKey('rejected_at'), isFalse);
    expect(json.containsKey('rejection_reason'), isFalse);
  });
}
