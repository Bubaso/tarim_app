import 'package:flutter_test/flutter_test.dart';
import 'package:tarim_app/features/home/data/ilgili_haber.dart';
import 'package:tarim_app/features/home/data/models/news_article.dart';

// ══════════════════════════════════════════════════════════════════════════
//  İlgili haber puanlayıcısı
// ──────────────────────────────────────────────────────────────────────────
//  Eski sistem ilgililik ölçmüyordu: üç kova, üçü de karıştırılmış, kategori
//  dalı hiç çalışmıyor (`category_id` %99,9 boş). Ölçüldü — önerilerin
//  %13'ü okunan haberle bir anahtar kelime paylaşıyordu, rastgele seçim
//  beklentisi ~%23.
//
//  Buradaki sınavların işi, yeni puanlamanın SESSİZCE bozulmasını yakalamak:
//  bir ağırlık yanlış değişirse şerit yine alakasız haber gösterir ve
//  görünürde hiçbir şey bozulmaz.
// ══════════════════════════════════════════════════════════════════════════

NewsArticle _h(
  String id, {
  List<String>? anahtar,
  String? konu,
  String? bolge,
  DateTime? tarih,
  String? baslik,
}) =>
    NewsArticle(
      id: id,
      title: baslik ?? 'Başlık $id',
      content: 'Gövde.',
      createdAt: tarih ?? DateTime(2026, 11, 20),
      status: 'published',
      seoKeywords: anahtar,
      topic: konu,
      region: bolge,
    );

void main() {
  group('anahtar kelime eşleşmesi', () {
    test('ortak kelimesi olan, olmayanı geçiyor', () {
      final okunan = _h('o', anahtar: ['zeytin', 'hasat']);
      final sonuc = ilgiliHaberleriSec(
        okunan: okunan,
        adaylar: [
          _h('alakasiz', anahtar: ['mazot', 'motorin']),
          _h('ilgili', anahtar: ['zeytin', 'rekolte']),
        ],
      );
      expect(sonuc.first.id, 'ilgili');
    });

    test('hiç ortak noktası olmayan aday listeye GİRMİYOR', () {
      final sonuc = ilgiliHaberleriSec(
        okunan: _h('o', anahtar: ['zeytin'], konu: 'Bitkisel Üretim'),
        adaylar: [_h('a', anahtar: ['mazot'], konu: 'Ekonomi')],
      );
      expect(sonuc, isEmpty,
          reason: 'puanı sıfır olan haber "ilgili" diye gösterilmemeli');
    });

    test('okunan haberin kendisi eleniyor', () {
      final okunan = _h('o', anahtar: ['zeytin']);
      final sonuc = ilgiliHaberleriSec(
        okunan: okunan,
        adaylar: [okunan, _h('b', anahtar: ['zeytin'])],
      );
      expect(sonuc.map((a) => a.id), ['b']);
    });

    test('Türkçe küçültme: İSTANBUL ile istanbul eşleşiyor', () {
      // kucukHarf olmadan 'İSTANBUL'.toLowerCase() iki kod noktalı bir dizge
      // üretiyor ve hiçbir şeyle eşleşmiyor.
      final sonuc = ilgiliHaberleriSec(
        okunan: _h('o', anahtar: ['İSTANBUL']),
        adaylar: [_h('a', anahtar: ['istanbul'])],
      );
      expect(sonuc.map((a) => a.id), ['a']);
    });
  });

  group('nadirlik ağırlığı', () {
    test('nadir kelime, herkeste geçen kelimeden ağır', () {
      // 'bakanlık' bütün adaylarda var → ayırt etmiyor. 'zeytin' yalnız
      // birinde → ayırt ediyor.
      final adaylar = [
        for (var i = 0; i < 8; i++) _h('genel$i', anahtar: ['bakanlık']),
        _h('nadir', anahtar: ['bakanlık', 'zeytin']),
      ];
      final sonuc = ilgiliHaberleriSec(
        okunan: _h('o', anahtar: ['bakanlık', 'zeytin']),
        adaylar: adaylar,
      );
      expect(sonuc.first.id, 'nadir');
    });

    test('tek nadir kelime, iki kelimelik eşleşmeyi EZMİYOR', () {
      // Tavan olmasaydı tek bir çok nadir kelime (idf büyük) iki ortak
      // kelimeli adayı geçerdi; canlı veride tam bu oluyordu.
      final adaylar = [
        for (var i = 0; i < 40; i++) _h('dolgu$i', anahtar: ['zeytin', 'hasat']),
        _h('tekNadir', anahtar: ['cokNadirKelime']),
        _h('ikiOrtak', anahtar: ['zeytin', 'hasat']),
      ];
      final sonuc = ilgiliHaberleriSec(
        okunan: _h('o', anahtar: ['zeytin', 'hasat', 'cokNadirKelime']),
        adaylar: adaylar,
        adet: 1,
      );
      expect(sonuc.first.id, isNot('tekNadir'),
          reason: 'nadirlik tavanı ($kNadirlikTavani) bunu engellemeli');
    });
  });

  group('konu ve bölge', () {
    test('aynı konu puan ekliyor', () {
      final sonuc = ilgiliHaberleriSec(
        okunan: _h('o', anahtar: ['zeytin'], konu: 'Bitkisel Üretim'),
        adaylar: [
          _h('baskaKonu', anahtar: ['zeytin'], konu: 'Ekonomi'),
          _h('ayniKonu', anahtar: ['zeytin'], konu: 'Bitkisel Üretim'),
        ],
      );
      expect(sonuc.first.id, 'ayniKonu');
    });

    test('anahtar kelime yoksa yalnız konu da yeter', () {
      final sonuc = ilgiliHaberleriSec(
        okunan: _h('o', konu: 'Hayvancılık'),
        adaylar: [
          _h('a', konu: 'Hayvancılık'),
          _h('b', konu: 'Ekonomi'),
        ],
      );
      expect(sonuc.map((a) => a.id), ['a']);
    });

    test('aynı bölge, konu eşitken ayırıyor', () {
      final sonuc = ilgiliHaberleriSec(
        okunan: _h('o', anahtar: ['zeytin'], konu: 'Genel', bolge: 'Ege'),
        adaylar: [
          _h('baska', anahtar: ['zeytin'], konu: 'Genel', bolge: 'Akdeniz'),
          _h('ayni', anahtar: ['zeytin'], konu: 'Genel', bolge: 'Ege'),
        ],
      );
      expect(sonuc.first.id, 'ayni');
    });
  });

  group('sıra', () {
    test('eşit puanda YENİ olan önce', () {
      final sonuc = ilgiliHaberleriSec(
        okunan: _h('o', anahtar: ['zeytin']),
        adaylar: [
          _h('eski', anahtar: ['zeytin'], tarih: DateTime(2026, 1, 1)),
          _h('yeni', anahtar: ['zeytin'], tarih: DateTime(2026, 11, 24)),
        ],
      );
      expect(sonuc.map((a) => a.id), ['yeni', 'eski']);
    });

    test('sıra DETERMİNİSTİK — aynı girdi aynı çıktı', () {
      // Eski kod her build'de yeniden karıştırıyordu; okurun gözünün önünde
      // dizilen şerit bu yüzden vardı.
      final okunan = _h('o', anahtar: ['zeytin', 'hasat'], konu: 'Genel');
      final adaylar = [
        for (var i = 0; i < 12; i++)
          _h('a$i',
              anahtar: i.isEven ? ['zeytin'] : ['hasat'],
              konu: i % 3 == 0 ? 'Genel' : 'Ekonomi',
              tarih: DateTime(2026, 11, 1 + i)),
      ];
      final bir = ilgiliHaberleriSec(okunan: okunan, adaylar: adaylar);
      final iki = ilgiliHaberleriSec(okunan: okunan, adaylar: adaylar);
      expect(bir.map((a) => a.id).toList(), iki.map((a) => a.id).toList());
    });

    test('en fazla istenen adet dönüyor', () {
      final sonuc = ilgiliHaberleriSec(
        okunan: _h('o', anahtar: ['zeytin']),
        adaylar: [for (var i = 0; i < 20; i++) _h('a$i', anahtar: ['zeytin'])],
      );
      expect(sonuc.length, 6);
    });
  });

  group('başlık çarpanı', () {
    test('ortak kelime adayın başlığında geçiyorsa öne çıkıyor', () {
      // Canlı örnek: zeytin hasadı haberinin altında bir yağış haberi başa
      // çıkıyordu, çünkü ikisi de "Elazığ" taşıyor. Ama yağış haberi Elazığ
      // HAKKINDA değil, Elazığ'a değiyor.
      final sonuc = ilgiliHaberleriSec(
        okunan: _h('o',
            anahtar: ['elazığ', 'zeytin'],
            konu: 'Bitkisel Üretim',
            baslik: 'Elazığ\'da ilk zeytin hasadı yapıldı'),
        adaylar: [
          _h('degiyor',
              anahtar: ['elazığ'],
              konu: 'Bitkisel Üretim',
              baslik: 'Ekim yağışları son 16 yılın zirvesine çıktı'),
          _h('hakkinda',
              anahtar: ['zeytin'],
              konu: 'Bitkisel Üretim',
              baslik: 'Zeytinde rekolte beklentisi maliyete takıldı'),
        ],
      );
      expect(sonuc.first.id, 'hakkinda',
          reason: 'başlığında ortak kelime geçen aday önce gelmeli');
    });

    test('çarpan, konu puanını tamamen ezmiyor', () {
      // 2,2 ve üstünde konu isabeti çöküyordu; çarpan o yüzden 1,6.
      expect(kBaslikCarpani, lessThan(2.0));
      expect(kBaslikCarpani, greaterThan(1.0));
    });
  });
}
