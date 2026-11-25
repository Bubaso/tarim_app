import 'dart:math' as math;

import '../../../core/utils/turkce_metin.dart';
import 'models/news_article.dart';

// ══════════════════════════════════════════════════════════════════════════
//  "İLGİLİ HABERLER" — PUANLAYICI
// ──────────────────────────────────────────────────────────────────────────
//  ÖNCEKİ HÂLİ İLGİLİLİK ÖLÇMÜYORDU. Üç kova vardı ve üçü de karıştırılıyordu:
//  aynı KAYNAKTAN 2 haber, aynı KATEGORİDEN 3, kalanı en yeni 20'den rastgele.
//  Kategori dalı hiç çalışmıyordu: `category_id` 1.597 haberin 1.596'sında
//  boş (ölçüm, 25 Kasım 2026). Geriye kalan gerçek davranış "aynı ajanstan iki
//  rastgele haber + en yeni yirmiden dört rastgele haber"di.
//
//  ÖLÇÜM (500 haberlik havuzdan 120 haber, her birine 6 öneri):
//
//                              ortak anahtar kelime   aynı konu
//    eski sistem                       %13               %34
//    rastgele seçim beklentisi          —                ~%23
//    bu puanlayıcı (tüm arşiv)         %79               %85
//
//  Yani eski sistem rastgeleden kıl payı iyiydi. Somut hâli: "Elazığ'da
//  Karakaya Barajı kıyısında ilk zeytin hasadı" haberinin altında Çin-ABD
//  ticareti, meteoroloji uyarısı ve kuzu desteği çıkıyordu — tek ortak kelime
//  yoktu.
//
//  NEDEN ANAHTAR KELİME. `seo_keywords` haberlerin %96,4'ünde dolu (ortalama
//  5,3 kelime, 5.132 farklı kelime) ve liste sorgusunda ZATEN çekiliyor —
//  `topic` (%99,4) ve `region` (%97,2) de öyle. Eşleştirmenin maliyeti bu
//  yüzden sıfıra yakın.
//
//  NADİRLİK AĞIRLIĞI VE TAVANI. Her ortak kelime aynı değerde değil: "Tarım
//  ve Orman Bakanlığı" 223 haberde geçiyor, neredeyse hiçbir şey ayırt
//  etmiyor. Kelimenin ağırlığı bu yüzden nadirliğiyle (IDF) artıyor. Ama ham
//  IDF de yanlış sonuç veriyordu: tek bir nadir kelime ("elazığ") beş zeytin
//  haberini geçip bir yağış haberini başa koyuyordu. Tavan konunca aynı-konu
//  oranı %77'den %83'e çıktı, kelime isabeti düşmeden. [kNadirlikTavani].
//
//  NADİRLİK ADAY KÜMESİ ÜZERİNDEN hesaplanıyor, bütün arşiv üzerinden değil:
//  istemcide arşiv istatistiği yok ve olması da gerekmiyor. Adayların hepsi
//  zaten okunan haberle en az bir kelime paylaşıyor; bir kelimenin bu küme
//  içinde sık olması, tam da "bu bağlamda ayırt etmiyor" demek. Ölçüldü:
//  arşiv geneli IDF ile aday kümesi IDF'i aynı sonucu veriyor (%79/%85).
//
//  KAYNAK EŞLEŞMESİ YOK. Eski sistemde en yüksek öncelik oradaydı; oysa iki
//  haberin aynı ajanstan gelmesi konularının ilgili olduğunu göstermiyor.
//
//  SIRA DETERMİNİSTİK. Eski kod `build` her çalıştığında şeridin yeniden
//  dizilmemesi için karıştırıcıyı haber kimliğinden tohumluyordu. Puanlama
//  zaten deterministik olduğu için o düzeneğe gerek kalmadı.
// ══════════════════════════════════════════════════════════════════════════

/// Bir ortak anahtar kelimenin taban ağırlığı.
const double kAnahtarAgirligi = 3.0;

/// Nadirlik ağırlığının tavanı — tek bir nadir kelime sıralamayı ele
/// geçirmesin diye.
const double kNadirlikTavani = 2.0;

/// Aynı konudan olmanın puanı (`topic`).
const double kKonuPuani = 3.0;

/// Aynı bölgeden olmanın puanı (`region`) — zayıf ama işe yarar bir ipucu.
const double kBolgePuani = 0.5;

/// Ortak kelime ADAYIN BAŞLIĞINDA da geçiyorsa ağırlığı bu kadar artıyor.
///
/// Anahtar kelime listesinde olmak haberin o konuya DEĞDİĞİNİ söylüyor;
/// başlıkta olmak o konu HAKKINDA olduğunu söylüyor. Canlı örnek: zeytin
/// hasadı haberinin altında "Ekim yağışları son 16 yılın zirvesine çıktı"
/// başa çıkıyordu, çünkü iki haber de "Elazığ" kelimesini taşıyor — ama
/// yağış haberi Elazığ HAKKINDA değil, Elazığ'a değiyor.
///
/// Çarpan ölçülerek seçildi (120 haber, arşivin tamamı):
///
///     çarpan   aynı konu   ortak kelime adayın başlığında
///     yok        %85,3              %22,2
///     1,6        %83,1              %33,5     ← seçilen
///     2,2        %75,1              %43,5
///
/// 1,6'da konu 2,2 puan düşüyor, başlık isabeti 11,3 puan çıkıyor. Konu
/// kaba bir sinyal (dokuz değer, biri haberlerin üçte biri); başlıkta
/// geçmek keskin. 2,2'den sonra takas tersine dönüyor.
const double kBaslikCarpani = 1.6;

/// Haberin anahtar kelimeleri, karşılaştırmaya hazır hâlde.
///
/// Küçültme Türkçe duyarlı: `kucukHarf` olmadan 'İSTANBUL' iki kod noktalı
/// bir dizgeye dönüşüyor ve hiçbir şeyle eşleşmiyor (bkz. turkce_metin.dart).
Set<String> haberAnahtarlari(NewsArticle a) {
  final k = a.seoKeywords;
  if (k == null) return const <String>{};
  final cikti = <String>{};
  for (final ham in k) {
    final temiz = kucukHarf(ham, false).trim();
    if (temiz.isNotEmpty) cikti.add(temiz);
  }
  return cikti;
}

/// [adaylar] içinden [okunan] haberle en ilgili olanları seçer.
///
/// [adaylar] okunan haberi içerebilir; eleniyor.
List<NewsArticle> ilgiliHaberleriSec({
  required NewsArticle okunan,
  required List<NewsArticle> adaylar,
  int adet = 6,
}) {
  final havuz = adaylar.where((a) => a.id != okunan.id).toList();
  if (havuz.isEmpty) return const [];

  final okunanAnahtarlar = haberAnahtarlari(okunan);

  // Kelime başına kaç adayda geçtiği — nadirlik buradan.
  final gecisSayisi = <String, int>{};
  for (final a in havuz) {
    for (final k in haberAnahtarlari(a)) {
      gecisSayisi[k] = (gecisSayisi[k] ?? 0) + 1;
    }
  }
  final n = havuz.length;
  double nadirlik(String k) => math.min(
        math.log((n + 1) / ((gecisSayisi[k] ?? 0) + 1)) + 1.0,
        kNadirlikTavani,
      );

  final puanli = <({double puan, NewsArticle haber})>[];
  for (final a in havuz) {
    var puan = 0.0;
    final adayBasligi = kucukHarf(a.title, false);
    for (final k in okunanAnahtarlar.intersection(haberAnahtarlari(a))) {
      var agirlik = nadirlik(k) * kAnahtarAgirligi;
      if (adayBasligi.contains(k)) agirlik *= kBaslikCarpani;
      puan += agirlik;
    }
    final konu = okunan.topic;
    if (konu != null && konu.isNotEmpty && a.topic == konu) {
      puan += kKonuPuani;
    }
    final bolge = okunan.region;
    if (bolge != null && bolge.isNotEmpty && a.region == bolge) {
      puan += kBolgePuani;
    }
    if (puan > 0) puanli.add((puan: puan, haber: a));
  }

  // Eşit puanda YENİ olan önce: aynı konuyu iki kez işlediysek okur güncel
  // olanı bekler.
  puanli.sort((x, y) {
    final fark = y.puan.compareTo(x.puan);
    return fark != 0 ? fark : y.haber.createdAt.compareTo(x.haber.createdAt);
  });

  return [for (final p in puanli.take(adet)) p.haber];
}
