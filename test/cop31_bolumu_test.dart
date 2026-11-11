import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tarim_app/features/home/data/models/news_article.dart';
import 'package:tarim_app/features/home/providers/home_providers.dart';

// ══════════════════════════════════════════════════════════════════════════
//  COP31 süreli bölümü
// ──────────────────────────────────────────────────────────────────────────
//  Bölümün iki vaadi var ve ikisi de gözle fark edilmesi zor şeyler:
//
//  1. İşaretli haber anasayfada BAŞKA hiçbir bölüme girmiyor. Bozulsa sayfa
//     yine dolu görünür, yalnız aynı haber hem COP31'de hem Türkiye'de olur.
//
//  2. 25 Kasım'da bölüm kendiliğinden kalkıyor ve haberler kendi konu/bölge
//     bölümlerine dönüyor. Bu, veri taşımadan oluyor: `topic`/`region` hiç
//     değişmiyor, yalnızca kural susuyor. O gün kimse bakmıyor olacak —
//     yanlışsa bölüm ya asılı kalır ya erken düşer, ikisi de sessiz.
//
//  Saat [simdiProvider]'dan geçiyor; test 25 Kasım'a gidip ölçebiliyor.
// ══════════════════════════════════════════════════════════════════════════

NewsArticle h(
  String id, {
  String? topic,
  String? region,
  String? ozelBolum,
  String? baslik,
  int saatOnce = 1,
  String status = 'published',
}) =>
    NewsArticle(
      id: id,
      title: baslik ?? id,
      content: 'x',
      createdAt: DateTime(2026, 11, 12, 10).subtract(Duration(hours: saatOnce)),
      status: status,
      topic: topic,
      region: region,
      ozelBolum: ozelBolum,
      imageUrl: 'https://x/i.jpg',
    );

/// Dağıtımın ürettiği BÜTÜN listeleri tek düzleme indirir.
List<String> _tumKimlikler(HomeAllocation d) => [
      ...d.turkey.map((a) => a.id),
      ...d.science.map((a) => a.id),
      ...d.world.map((a) => a.id),
      ...d.byTopic.values.expand((l) => l).map((a) => a.id),
      ...d.icymi.map((a) => a.id),
    ];

Future<HomeAllocation> dagit(List<NewsArticle> liste, DateTime simdi) async {
  final container = ProviderContainer(overrides: [
    latestArticlesProvider.overrideWith((ref) => Stream.value(liste)),
    initialReadArticlesProvider.overrideWith((ref) => const <String>{}),
    simdiProvider.overrideWithValue(() => simdi),
    // Manşet BOŞ bırakılıyor. Dağıtım hero'nun aldıklarını "harcanmış"
    // sayıyor; küçük test havuzlarında manşet listenin tamamını yutuyor ve
    // ölçmek istediğimiz şey (COP31 süzgeci) hiç görünmüyordu. Manşetin
    // kendi davranışının testi bu dosyada değil.
    heroArticlesProvider.overrideWithValue(const <NewsArticle>[]),
  ]);
  addTearDown(container.dispose);
  await container.read(latestArticlesProvider.future);
  return container.read(homeAllocationProvider);
}

final _bolumAcik = DateTime(2026, 11, 12, 10);
final _bolumKapali = DateTime(2026, 11, 25, 0, 1);

void main() {
  group('bölüm açıkken', () {
    test('COP31 haberi anasayfada başka HİÇBİR bölüme girmiyor', () async {
      // Kesişime açık havuz: işaretli haberler aynı zamanda Türkiye bölgeli
      // ve sektörel konulu. Kural olmasaydı Türkiye, Hayvancılık ve ICYMI'nin
      // üçünde de görünmeye adaydılar.
      final liste = <NewsArticle>[
        for (var i = 0; i < 6; i++)
          h('cop-$i',
              region: 'Türkiye',
              topic: 'Hayvancılık',
              ozelBolum: 'cop31',
              saatOnce: i + 1),
        for (var i = 0; i < 8; i++)
          h('tr-$i', region: 'Türkiye', topic: 'Ekonomi', saatOnce: i + 10),
      ];

      final kimlikler = _tumKimlikler(await dagit(liste, _bolumAcik));

      for (var i = 0; i < 6; i++) {
        expect(kimlikler, isNot(contains('cop-$i')),
            reason: 'cop-$i bölüm dışında bir yerde görünüyor');
      }
      // Sağlama: işaretsiz haberler normal akışına devam ediyor. Bu olmadan
      // test "dağıtım tamamen boş" durumunda da geçerdi.
      expect(kimlikler.where((k) => k.startsWith('tr-')), isNotEmpty);
    });

    test('işaret yalnızca "cop31" değerinde geçerli', () async {
      final liste = [
        h('baska', region: 'Türkiye', ozelBolum: 'davos'),
        h('isaretsiz', region: 'Türkiye'),
      ];
      final kimlikler = _tumKimlikler(await dagit(liste, _bolumAcik));
      expect(kimlikler, contains('baska'),
          reason: 'tanınmayan işaret haberi anasayfadan düşürmemeli');
      expect(kimlikler, contains('isaretsiz'));
    });
  });

  group('25 Kasım sonrası', () {
    test('bölüm kapanınca haberler kendi konu/bölge bölümüne DÖNÜYOR',
        () async {
      final liste = <NewsArticle>[
        for (var i = 0; i < 6; i++)
          h('cop-$i',
              region: 'Türkiye',
              topic: 'Hayvancılık',
              ozelBolum: 'cop31',
              saatOnce: i + 1),
      ];

      final kimlikler = _tumKimlikler(await dagit(liste, _bolumKapali));

      // Veri taşınmadı: `region`/`topic` hiç değişmedi. Değişen tek şey saat.
      expect(kimlikler, contains('cop-0'),
          reason: 'bölüm kapandıktan sonra haber anasayfaya dönmeli');
      expect(kimlikler.where((k) => k.startsWith('cop-')).length, 6);
    });

    test('bölüm listesi boşalıyor ve sorgu hiç yapılmıyor', () {
      final container = ProviderContainer(overrides: [
        simdiProvider.overrideWithValue(() => _bolumKapali),
        // Sorgu yapılırsa bu akış okunur ve test çöker: kapalı bölüm için
        // ağ isteği harcanmadığını böyle ölçüyoruz.
        ozelBolumAkisiProvider.overrideWith(
            (ref) => Stream<List<NewsArticle>>.error('sorgu yapılmamalıydı')),
      ]);
      addTearDown(container.dispose);
      expect(container.read(cop31ArticlesProvider), isEmpty);
    });

    test('tarih kapısı sınırda doğru: 24 Kasım açık, 25 Kasım kapalı', () {
      expect(ozelBolumAktif(DateTime(2026, 11, 24, 23, 59)), isTrue);
      expect(ozelBolumAktif(DateTime(2026, 11, 25)), isFalse);
      expect(ozelBolumAktif(DateTime(2026, 12, 1)), isFalse);
    });

    test('ozelBolumeAit tarih kapısına uyuyor', () {
      final a = h('x', ozelBolum: 'cop31');
      expect(ozelBolumeAit(a, _bolumAcik), isTrue);
      expect(ozelBolumeAit(a, _bolumKapali), isFalse);
      expect(ozelBolumeAit(h('y'), _bolumAcik), isFalse);
    });
  });

  test('manşete çıkan COP31 haberi bölüm listesinden düşüyor', () async {
    final mansetteki = h('manset', ozelBolum: 'cop31');
    final digeri = h('digeri', ozelBolum: 'cop31');

    final container = ProviderContainer(overrides: [
      simdiProvider.overrideWithValue(() => _bolumAcik),
      ozelBolumAkisiProvider
          .overrideWith((ref) => Stream.value([mansetteki, digeri])),
      heroArticlesProvider.overrideWithValue([mansetteki]),
    ]);
    addTearDown(container.dispose);
    // Akışın ilk değeri OTURANA KADAR beklemek şart: `valueOrNull` aksi
    // hâlde null dönüyor ve bölüm boş görünüyor.
    await container.read(ozelBolumAkisiProvider.future);

    final bolum = container.read(cop31ArticlesProvider);
    expect(bolum.map((a) => a.id), isNot(contains('manset')),
        reason: 'aynı kart sayfada iki kez görünmemeli');
    expect(bolum.map((a) => a.id), contains('digeri'));
  });

  // ── Yayın kuralı: büyük kart her zaman Bakan Yumaklı ───────────────────
  //
  //  12 Kasım 2026 kararı. Sessizce bozulabilecek cinsten: kural kalksa
  //  bölüm yine dolu görünür, yalnız açılış kartı başka bir habere kayar.
  group('bölümün büyük kartı', () {
    // Akışın ilk değeri OTURMADAN okunursa `valueOrNull` null döner ve bölüm
    // boş görünür; beklemek şart.
    Future<List<NewsArticle>> bolum(List<NewsArticle> akis) async {
      final container = ProviderContainer(overrides: [
        simdiProvider.overrideWithValue(() => _bolumAcik),
        ozelBolumAkisiProvider.overrideWith((ref) => Stream.value(akis)),
        heroArticlesProvider.overrideWithValue(const <NewsArticle>[]),
      ]);
      addTearDown(container.dispose);
      await container.read(ozelBolumAkisiProvider.future);
      return container.read(cop31ArticlesProvider);
    }

    test('Yumaklı haberi listenin başında DEĞİLSE öne alınıyor', () async {
      final liste = await bolum([
        h('taze-baska', baslik: 'Dünya Bankası tarıma finansman açıkladı'),
        h('bakan', baslik: 'Bakan Yumaklı COP31 zirvesinde konuştu'),
        h('eski-baska', baslik: 'Küresel iklim uyum finansmanı geride kaldı'),
      ]);
      expect(liste.first.id, 'bakan');
      // Sıradakiler kaybolmuyor, yalnızca ilk sıra garanti altında.
      expect(liste.map((a) => a.id), containsAll(['taze-baska', 'eski-baska']));
      expect(liste.length, 3);
    });

    test('BÜYÜK harfli başlık da yakalanıyor (Türkçe küçültme)', () async {
      final liste = await bolum([
        h('baska', baslik: 'Tarımsal üretim arttı'),
        h('bakan', baslik: 'BAKAN YUMAKLI ZİRVEDE KONUŞTU'),
      ]);
      expect(liste.first.id, 'bakan',
          reason: "'YUMAKLI'.toLowerCase() 'yumakli' üretir ve kaçırırdı");
    });

    test('hiç aday yoksa bölüm BOŞALMIYOR, liste olduğu gibi kalıyor', () async {
      final liste = await bolum([
        h('a', baslik: 'Dünya Bankası tarıma finansman açıkladı'),
        h('b', baslik: 'Küresel iklim uyum finansmanı geride kaldı'),
      ]);
      expect(liste.map((a) => a.id), ['a', 'b']);
    });
  });

  // ── Kaynak değişmezleri ────────────────────────────────────────────────
  //
  //  §20.2'nin uyarısı: tabloya yeni sütun eklenince sorgu listelerine de
  //  eklenmeli, yoksa kartta GÖRÜNMEZ. `ozel_bolum` iki listede de yoksa
  //  bölüm sessizce boş kalır — çalışan kodda hiçbir hata çıkmaz.
  group('sorgu sütun listeleri', () {
    late String depo;
    setUpAll(() {
      depo = File('lib/features/home/data/repositories/home_repository.dart')
          .readAsStringSync();
    });

    test('ozel_bolum hem liste hem kuyruk sorgusunda var', () {
      // TANIMA bakılıyor, kullanıma değil: dosyada `_listeSutunlari` ilk
      // olarak `.select(_listeSutunlari)` çağrısında geçiyor.
      final listeBlogu = depo
          .split('static const String _listeSutunlari')[1]
          .split(';')[0];
      final kuyrukBlogu = depo
          .split('static const String _kuyrukSutunlari')[1]
          .split(';')[0];
      expect(listeBlogu, contains('ozel_bolum'),
          reason: 'anasayfa listesi işareti taşımazsa dağıtım süzemez');
      expect(kuyrukBlogu, contains('ozel_bolum'),
          reason: 'kuyruk işareti taşımazsa paneldeki düğme durumu bilemez');
    });

    test('bölüm kendi sorgusunu yapıyor, ortak listeyi süzmüyor', () {
      expect(depo, contains('ozelBolumuIzle'),
          reason: 'ortak liste en yeni 500 haber; Eylül haberleri dışında '
              'kalır (§26.2 ile aynı duvar)');
    });
  });

  // ── "Tümü" ekranına dışarıdan haber sızmasın ───────────────────────────
  //
  //  Önizlemede ortak kategori ekranında COP31 ile ilgisi olmayan haberler
  //  göründü (Kırşehir balık tezgahı denetimi, Bursa tam buğday kampanyası,
  //  aylık gıda denetimi bültenleri). Veritabanı temizdi; karışmanın yolu
  //  bulunamadı. Çözüm, listeye dışarıdan haber girebilecek HİÇBİR kapı
  //  bırakmamak oldu. Bu testler o kapıların kapalı kaldığını denetliyor.
  group('COP31 tam listesi', () {
    late String ekran;
    late String bolum;
    setUpAll(() {
      ekran = File('lib/features/home/presentation/screens/cop31_liste_ekrani.dart')
          .readAsStringSync();
      bolum = File('lib/features/home/presentation/widgets/portal_sections/'
              'cop31_section.dart')
          .readAsStringSync();
    });

    test('ortak kategori ekranı KULLANILMIYOR', () {
      expect(bolum, isNot(contains('CategoryArticlesScreen')),
          reason: 'o ekran slug çözüyor ve kendi sayfalamasını yapıyor');
    });

    test('liste ekranı hiçbir sorgu yapmıyor', () {
      for (final yasak in [
        'homeRepositoryProvider',
        'fetchKategoriSayfasi',
        '_supabaseClient',
        '.from(',
      ]) {
        expect(ekran, isNot(contains(yasak)),
            reason: '$yasak listeye dışarıdan haber sokabilecek bir kapı');
      }
    });

    test('liste ekranının tek kaynağı COP31 akışı', () {
      expect(ekran, contains('ozelBolumAkisiProvider'));
      // Başka bir haber sağlayıcısı okunmuyor.
      for (final yasak in [
        'latestArticlesProvider',
        'turkeyNewsProvider',
        'worldNewsProvider',
        'homeAllocationProvider',
      ]) {
        expect(ekran, isNot(contains(yasak)), reason: '$yasak okunmamalı');
      }
    });
  });
}
