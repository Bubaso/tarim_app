import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tarim_app/features/yapay_zeka/data/yz_sozluk.g.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_kisaltma.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_metin_gorunumu.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_sozluk_esle.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_telefon_bolme.dart';

// ══════════════════════════════════════════════════════════════════════════
//  Telefonda paragraf bölme (madde 2), giriş (madde 4), ritim (madde 3)
// ──────────────────────────────────────────────────────────────────────────
//  * Dart bölücü Python ikiziyle (_raw/telefon_bolme.py) AYNI noktaları
//    buluyor: fikstür test/veri/yz_telefon_bolme.json.
//  * Değişmezler: parçalar birleşince paragraf aynen; her parça cümle
//    sonuyla bitiyor; §29–30'da bölme yok.
//  * Gerçek yazı tipiyle (gömülü Newsreader) ölçüm: en büyük blok ekranın
//    0,6'sını aşmıyor; ferahlık + bölme telefonda metni ≤ %7 uzatıyor.
// ══════════════════════════════════════════════════════════════════════════

const _bolumler = 'content/yapay_zeka_dijital_tarim/bolumler';
const _teknolojiler = 'content/yapay_zeka_dijital_tarim/teknolojiler';

List<File> _sayfalar() {
  List<File> md(String d) =>
      Directory(d).listSync().whereType<File>().where((f) => f.path.endsWith('.md')).toList()
        ..sort((a, b) => a.path.compareTo(b.path));
  return [...md(_bolumler), ...md(_teknolojiler)];
}

String _ad(File f) => f.path.split('/').reversed.take(2).toList().reversed.join('/');
bool _en(File f) => f.path.endsWith('.en.md');
int? _no(File f) => f.parent.path.endsWith('bolumler') ? int.parse(f.uri.pathSegments.last.substring(0, 2)) : null;

/// Okurun gördüğü dizgi (ölçüm için): `*` işaretleri kalkmış, bölünmez boşluk.
String _gorunen(String p) => yzBolunmez(p).replaceAll('*', '');

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  group('Python ikiziyle eşlik', () {
    final fikstur = jsonDecode(File('test/veri/yz_telefon_bolme.json').readAsStringSync()) as Map;
    final kosullar = [
      for (final k in fikstur['kosullar'] as List)
        ((k['genislik'] as num).toDouble(), (k['s'] as num).toDouble()),
    ];
    final sayfalar = fikstur['sayfalar'] as Map;

    test('fikstür bütün sayfaları kapsıyor', () {
      expect(sayfalar.keys.toSet(), {for (final f in _sayfalar()) _ad(f)},
          reason: 'sayfa eklendiyse: python3 content/yapay_zeka_dijital_tarim/_raw/telefon_bolme.py --fikstur');
    });

    test('her sayfada, her koşulda aynı bölme noktaları', () {
      var bolunen = 0;
      for (final f in _sayfalar()) {
        final kayit = (sayfalar[_ad(f)] as Map?) ?? const {};
        final bloklar = yzAyristir(f.readAsStringSync());
        for (var i = 0; i < bloklar.length; i++) {
          if (bloklar[i].tur != YzBlokTuru.paragraf) continue;
          final beklenen = kayit['$i'] as List?;
          for (var k = 0; k < kosullar.length; k++) {
            final dart = kYzBolmesizBasliklar.contains(_no(f))
                ? const <int>[]
                : yzTelefonNoktalari(bloklar[i].metin,
                    genislik: kosullar[k].$1, s: kosullar[k].$2, giris: i == 0, en: _en(f));
            final py = beklenen == null ? const <int>[] : [for (final x in beklenen[k] as List) x as int];
            expect(dart, py, reason: '${_ad(f)} blok $i, koşul ${kosullar[k]}: Dart ile Python ayrıştı');
            if (dart.isNotEmpty) bolunen++;
          }
        }
      }
      expect(bolunen, greaterThan(500), reason: 'eşlik gerçekten bölünen paragraflarla sınandı');
    });
  });

  group('değişmezler', () {
    const genislikler = [288.0, 328.0, 343.0, 382.0];
    const olcekler = [0.9, 1.0, 1.12, 1.4, 1.82];
    final sonDeseni = RegExp(r'[.!?…]["”’)]*(\*\*)?$');
    final basDeseni = RegExp(r'^(\*\*)?[*“"(«\[' "'" r'‘]*[A-ZÇĞİÖŞÜÂÎÛ0-9%]');

    test('parçalar birleşince paragraf aynen; her parça cümle sonuyla bitiyor', () {
      var sinir = 0;
      for (final f in _sayfalar()) {
        if (kYzBolmesizBasliklar.contains(_no(f))) continue;
        final bloklar = yzAyristir(f.readAsStringSync());
        for (var i = 0; i < bloklar.length; i++) {
          if (bloklar[i].tur != YzBlokTuru.paragraf) continue;
          final m = bloklar[i].metin;
          for (final w in genislikler) {
            for (final s in olcekler) {
              final nk = yzTelefonNoktalari(m, genislik: w, s: s, giris: i == 0, en: _en(f));
              final parcalar = [for (final (a, z) in yzParcaAraliklari(m, nk)) m.substring(a, z)];
              expect(parcalar.join(' '), m, reason: '${_ad(f)} blok $i');
              for (var j = 0; j + 1 < parcalar.length; j++) {
                sinir++;
                final sol = parcalar[j];
                expect(sonDeseni.hasMatch(sol), isTrue, reason: '${_ad(f)}: …${sol.substring(math.max(0, sol.length - 30))}');
                expect(basDeseni.hasMatch(parcalar[j + 1]), isTrue, reason: '${_ad(f)}: ${parcalar[j + 1]}');
                expect('**'.allMatches(sol).length.isEven, isTrue, reason: 'kalın içinde bölme');
                expect('('.allMatches(sol).length, ')'.allMatches(sol).length, reason: 'parantez içinde bölme');
                expect('“'.allMatches(sol).length, '”'.allMatches(sol).length, reason: 'tırnak içinde bölme');
              }
              // Gövde parçaları eşiği aşmıyor, ya da cümle sınırı yok.
              final e = yzBolmeEsigi(w, s);
              for (var j = (i == 0 && nk.isNotEmpty) ? 1 : 0; j < parcalar.length; j++) {
                if (yzGorunenUzunluk(parcalar[j]) > e) {
                  final ic = yzCumleSinirlari(parcalar[j], en: _en(f));
                  final m2 = yzEnAzParca(s);
                  expect(
                      ic.every((k) =>
                          yzGorunenUzunluk(parcalar[j].substring(0, k)) < m2 ||
                          yzGorunenUzunluk(parcalar[j].substring(k)) < m2),
                      isTrue,
                      reason: 'bölünebilecekken bölünmemiş: ${_ad(f)} blok $i');
                }
              }
            }
          }
        }
      }
      expect(sinir, greaterThan(5000));
    });

    test('giriş: ilk parça ~6 satır, cümle sonuyla biter; ilk cümle uzunsa yalnız o', () {
      for (final f in _sayfalar()) {
        if (kYzBolmesizBasliklar.contains(_no(f))) continue;
        final bloklar = yzAyristir(f.readAsStringSync());
        if (bloklar.isEmpty || bloklar.first.tur != YzBlokTuru.paragraf) continue;
        final m = bloklar.first.metin;
        final nk = yzTelefonNoktalari(m, genislik: 343, s: 1, giris: true, en: _en(f));
        if (nk.isEmpty) continue;
        final ilk = m.substring(0, nk.first).trimRight();
        final cumleler = yzCumleSinirlari(m, en: _en(f));
        expect(cumleler, contains(nk.first));
        expect(yzGorunenUzunluk(ilk) <= yzGirisSiniri(343, 1) || nk.first == cumleler.first, isTrue,
            reason: '${_ad(f)}: ilk parça ${yzGorunenUzunluk(ilk)} harf');
      }
    });

    test('Sözlük ve Kaynakça bölmesiz başlıklar', () {
      expect(kYzBolmesizBasliklar, {29, 30});
    });
  });

  group('cümle sınırı', () {
    List<String> bol(String m, {bool en = false}) {
      final s = yzCumleSinirlari(m, en: en);
      return [for (final (a, z) in yzParcaAraliklari(m, s)) m.substring(a, z)];
    }

    test('nokta, ünlem, soru, üç nokta; Türkçe büyük harf', () {
      expect(bol('Bitti. Şimdi başlıyor! İşte böyle? Öyle… Ünlü'),
          ['Bitti.', 'Şimdi başlıyor!', 'İşte böyle?', 'Öyle…', 'Ünlü']);
      expect(bol('Sayı arttı. %35 oldu. 2020 yılı'), ['Sayı arttı.', '%35 oldu.', '2020 yılı']);
      expect(bol('bitti. ışık yandı'), ['bitti. ışık yandı'], reason: 'küçük harfle başlayan');
    });

    test('kısaltma, baş harf, Roma rakamı, sıra sayısı', () {
      expect(bol('Ürünler (ör. Buğday) arttı. Bunlar, vb. Diğerleri'), ['Ürünler (ör. Buğday) arttı.', 'Bunlar, vb. Diğerleri']);
      expect(bol('Bkz. bkz. Tablo. Dr. Ayşe geldi. Prof. Kaya da'), ['Bkz. bkz. Tablo.', 'Dr. Ayşe geldi.', 'Prof. Kaya da']);
      expect(bol('IV. Tarım Orman Şûrası toplandı. Sonra'), ['IV. Tarım Orman Şûrası toplandı.', 'Sonra']);
      expect(bol('J. Smith yazdı. Sonra'), ['J. Smith yazdı.', 'Sonra']);
      expect(bol('2. Dünya Savaşı bitti. 1945 yılı'), ['2. Dünya Savaşı bitti.', '1945 yılı']);
      expect(bol('See e.g. The report. U.S. Department', en: true), ['See e.g. The report.', 'U.S. Department']);
      expect(bol('Annex I. The list', en: true), ['Annex I.', 'The list'], reason: 'İngilizcede "I" sınır');
      expect(bol('Ek I. Bu liste'), ['Ek I. Bu liste'], reason: 'Türkçede Roma rakamı');
    });

    test('parantez, tırnak ve kalın içinde bölme yok', () {
      expect(bol('Rakam (bitti. Sonra) arttı. Yeni'), ['Rakam (bitti. Sonra) arttı.', 'Yeni']);
      expect(bol('Dedi ki “Bitti. Gitti.” Sonra'), ['Dedi ki “Bitti. Gitti.” Sonra']);
      expect(bol('Oran **%5. Sonra** arttı. Yeni'), ['Oran **%5. Sonra** arttı.', 'Yeni']);
      expect(bol('Oran **%5**. Yeni'), ['Oran **%5**.', 'Yeni']);
    });

    test('eşik ölçekle: E = 560 × (W/343) / s², M = max(120, 180/s), G = 220 × (W/343) / s', () {
      expect(yzBolmeEsigi(343, 1), 560);
      expect(yzBolmeEsigi(343, 2), 140);
      expect(yzBolmeEsigi(686, 1), 1120);
      expect(yzEnAzParca(1), 180);
      expect(yzEnAzParca(1.82), 120);
      expect(yzGirisSiniri(343, 1), 220);
      expect(yzGorunenUzunluk('  **%35** ve *italik*  '), '%35 ve italik'.length);
    });
  });

  group('SelectionArea içinde dokunuşlar', () {
    testWidgets('kaynaklı rakam, noktalı terim ve kısaltma Text.rich içinde açılıyor', (t) async {
      final acilan = <String>[];
      final tanicilar = <GestureRecognizer>[];
      addTearDown(() {
        for (final r in tanicilar) {
          r.dispose();
        }
      });
      final terim = kYzSozluk.first;
      final etkilesim = YzEtkilesim(
        tanicilar: tanicilar,
        baglantiAc: (a) => acilan.add('adres:$a'),
        terimAc: (x, _) => acilan.add('terim:${x.kimlik}'),
        rakamVar: (_) => true,
        rakamAc: (k, _) => acilan.add('rakam:$k'),
        kisaltmaAc: (k, _) => acilan.add('kisaltma:$k'),
      );
      const stil = TextStyle(fontSize: 24);
      await t.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SelectionArea(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text.rich(yzSatirIci('**%35**', stil, etkilesim: etkilesim)),
              Text.rich(yzSatirIci('terim', stil, etkilesim: etkilesim, isaretler: [YzIsaret(0, 5, terim)])),
              Text.rich(yzSatirIci('FAO', stil,
                  etkilesim: etkilesim, kisaltmalar: const [YzKisaltmaIsareti(0, 3, 'FAO')])),
              Text.rich(yzSatirIci('https://ornek.org/x', stil, etkilesim: etkilesim)),
            ]),
          ),
        ),
      ));
      final metinler = find.byType(RichText);
      for (var i = 0; i < 4; i++) {
        await t.tap(metinler.at(i));
        await t.pump(const Duration(milliseconds: 400));
      }
      expect(acilan, ['rakam:%35', 'terim:${terim.kimlik}', 'kisaltma:FAO', 'adres:https://ornek.org/x']);
      expect(find.byType(SelectableText), findsNothing);
    });

    testWidgets('makale metni Text.rich: SelectableText yok, bloklar RepaintBoundary içinde', (t) async {
      t.view.physicalSize = const Size(375, 812);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      final md = File('$_bolumler/01-bugun-nerede-duruyoruz.tr.md').readAsStringSync();
      await t.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SelectionArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: YzMetinGorunumu(metin: md, en: false, bolumNo: 1),
            ),
          ),
        ),
      ));
      await t.pump();
      expect(find.byType(SelectableText), findsNothing);
      final kolon = t.widget<Column>(find.descendant(of: find.byType(YzMetinGorunumu), matching: find.byType(Column)).first);
      expect(kolon.children.every((w) => w is RepaintBoundary), isTrue);
      final bloklar = yzAyristir(md);
      final paragraf = bloklar.where((b) => b.tur == YzBlokTuru.paragraf).length;
      var parca = 0;
      for (var i = 0; i < bloklar.length; i++) {
        if (bloklar[i].tur != YzBlokTuru.paragraf) continue;
        parca += yzTelefonNoktalari(bloklar[i].metin, genislik: 343, s: 1, giris: i == 0).length + 1;
      }
      expect(parca, greaterThan(paragraf), reason: '§1 telefonda bölünüyor');
      // Dosyadaki bir paragraf = bir blok (anahtarlı sarmalayıcı); parçalar içinde.
      expect(kolon.children.length, bloklar.length);
      final metinler = find.descendant(of: find.byType(YzMetinGorunumu), matching: find.byType(RichText));
      expect(metinler.evaluate().length, greaterThanOrEqualTo(parca));
      // Parça arası 16, paragraf arası 28 (madde 3).
      final dolgular = t.widgetList<Padding>(find.byType(Padding)).map((p) => p.padding).toList();
      expect(dolgular, contains(const EdgeInsets.only(bottom: 16)));
      expect(dolgular, contains(const EdgeInsets.only(bottom: 28)));
      expect(t.takeException(), isNull);
    });

    testWidgets('§29 Sözlük telefonda bölünmüyor', (t) async {
      t.view.physicalSize = const Size(375, 812);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      final f = Directory(_bolumler).listSync().whereType<File>().firstWhere((f) => f.path.contains('/29-') && f.path.endsWith('.tr.md'));
      final md = f.readAsStringSync();
      await t.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: YzMetinGorunumu(metin: md, en: false, bolumNo: 29, sozluk: false),
          ),
        ),
      ));
      await t.pump();
      final kolon = t.widget<Column>(find.descendant(of: find.byType(YzMetinGorunumu), matching: find.byType(Column)).first);
      expect(kolon.children.length, yzAyristir(md).length);
      // Kural yine de bazı girdileri bölerdi: kapalılığı gerçekten sınıyor.
      expect(
          yzAyristir(md).any((b) =>
              b.tur == YzBlokTuru.paragraf && yzTelefonNoktalari(b.metin, genislik: 343, s: 1).isNotEmpty),
          isTrue);
    });
  });

  group('taşma yok', () {
    for (final (ad, boy, yan) in [('telefon', const Size(375, 812), 16.0), ('masaüstü', const Size(1280, 900), 32.0)]) {
      testWidgets('bütün sayfalar, en büyük yazı boyunda · $ad', (t) async {
        t.view.physicalSize = boy;
        t.view.devicePixelRatio = 1;
        addTearDown(t.view.reset);
        for (final f in _sayfalar()) {
          final no = _no(f);
          await t.pumpWidget(MaterialApp(
            home: Scaffold(
              body: SelectionArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: yan),
                  child: YzMetinGorunumu(
                      metin: f.readAsStringSync(),
                      en: _en(f),
                      bolumNo: no,
                      sozluk: !kYzBolmesizBasliklar.contains(no),
                      olcek: 1.4),
                ),
              ),
            ),
          ));
          await t.pump();
          expect(t.takeException(), isNull, reason: _ad(f));
        }
      });
    }
  });

  group('gerçek yazı tipiyle ölçüm (gömülü Newsreader)', () {
    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final n = FontLoader('YzOlcumGovde')
        ..addFont(Future.value(ByteData.sublistView(File('assets/google_fonts/Newsreader-Regular.ttf').readAsBytesSync())));
      final o = FontLoader('YzOlcumBaslik')
        ..addFont(Future.value(ByteData.sublistView(File('assets/google_fonts/Outfit-Bold.ttf').readAsBytesSync())));
      await Future.wait([n.load(), o.load()]);
    });

    double yukseklik(String metin, double boy, double satir, double genislik, {bool baslik = false}) {
      final p = TextPainter(
        text: TextSpan(
            text: baslik ? metin : _gorunen(metin),
            style: TextStyle(
                fontFamily: baslik ? 'YzOlcumBaslik' : 'YzOlcumGovde',
                fontSize: boy,
                height: satir,
                letterSpacing: baslik ? -0.2 : null)),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: genislik);
      final h = p.height;
      p.dispose();
      return h;
    }

    // Ekranın okunan yüksekliği: 812 − üst çubuk (56).
    const ekran = 812.0 - 56;

    // Kural (E = 560 × W/343 / s², M = max(120, 180/s)) 360–414 px'te ve
    // s ≤ 1'de en büyük bloğu 0,6 ekranın altında tutuyor. Daha büyük yazıda
    // ve 320 px'te kalan uzun bloklar bölünemeyen paragraflar: tek uzun cümle
    // ya da iki yanı M'den kısa kalan sınırlar (ör. §11'de 178 | 272 | 143
    // harf). Bunlar raporlanıyor, kural gevşetilmiyor.
    test('en büyük blok ≤ 0,6 ekran (360–414 px, s ≤ 1); öbür koşullar raporlanıyor', () {
      final rapor = StringBuffer();
      final sonuc = <(double, double), double>{};
      for (final w in [288.0, 328.0, 343.0, 382.0]) {
        for (final s in [0.9, 1.0, 1.12, 1.4, 1.82]) {
          var enBuyuk = 0.0;
          var nerede = '';
          var bolunen = 0;
          for (final f in _sayfalar()) {
            if (_en(f) || kYzBolmesizBasliklar.contains(_no(f))) continue;
            final bloklar = yzAyristir(f.readAsStringSync());
            for (var i = 0; i < bloklar.length; i++) {
              if (bloklar[i].tur != YzBlokTuru.paragraf) continue;
              final m = bloklar[i].metin;
              final nk = yzTelefonNoktalari(m, genislik: w, s: s, giris: i == 0);
              if (nk.isNotEmpty) bolunen++;
              final araliklar = yzParcaAraliklari(m, nk);
              for (var j = 0; j < araliklar.length; j++) {
                final giris = i == 0 && j == 0;
                final h = yukseklik(m.substring(araliklar[j].$1, araliklar[j].$2), (giris ? 19.5 : 17.5) * s,
                    giris ? 1.60 : 1.68, w);
                if (h / ekran > enBuyuk) {
                  enBuyuk = h / ekran;
                  nerede = '${_ad(f)} blok $i parça $j';
                }
              }
            }
          }
          rapor.writeln('W=${w.round()} s=$s: $bolunen paragraf bölünüyor, en büyük blok '
              '${enBuyuk.toStringAsFixed(2)} ekran ($nerede)');
          sonuc[(w, s)] = enBuyuk;
        }
      }
      // ignore: avoid_print
      print(rapor);
      for (final MapEntry(key: (w, s), value: pay) in sonuc.entries) {
        if (w >= 328 && s <= 1.0) expect(pay, lessThanOrEqualTo(0.6), reason: 'W=$w s=$s');
      }
    });

    test('ferahlık + bölme telefonda metni en çok %7 uzatıyor; masaüstü raporlanıyor', () {
      // Yalnız metin blokları (paragraf, liste, alt başlık): grafik, görsel
      // ve tablo değişmiyor, sayfanın tamamında oran bundan da küçük.
      double sayfa(String md, {required bool yeni, required bool telefon}) {
        final w = telefon ? 343.0 : 610.0;
        final govdeBoy = telefon ? 17.5 : 18.5;
        final girisBoy = telefon ? 19.5 : 21.0;
        final govdeSatir = yeni ? (telefon ? 1.68 : 1.70) : 1.62;
        final girisSatir = yeni && telefon ? 1.60 : 1.55;
        final parA = yeni ? (telefon ? 28.0 : 30.0) : 22.0;
        final girisA = yeni ? parA : 26.0;
        final ust = yeni ? 48.0 : (telefon ? 44.0 : 34.0);
        final alt = yeni ? (telefon ? 12.0 : 14.0) : (telefon ? 10.0 : 12.0);
        final madde = yeni ? 12.0 : 9.0;
        final listeAlt = yeni ? (telefon ? 28.0 : 30.0) : 22.0;
        var h = 0.0;
        final bloklar = yzAyristir(md);
        for (var i = 0; i < bloklar.length; i++) {
          final b = bloklar[i];
          switch (b.tur) {
            case YzBlokTuru.paragraf:
              final nk = yeni && telefon ? yzTelefonNoktalari(b.metin, genislik: w, s: 1, giris: i == 0) : const <int>[];
              final ar = yzParcaAraliklari(b.metin, nk);
              for (var j = 0; j < ar.length; j++) {
                final giris = i == 0 && j == 0;
                h += yukseklik(b.metin.substring(ar[j].$1, ar[j].$2), giris ? girisBoy : govdeBoy,
                    giris ? girisSatir : govdeSatir, w);
                h += j == ar.length - 1 ? (i == 0 ? girisA : parA) : 16;
              }
            case YzBlokTuru.altBaslik:
              h += ust + alt + yukseklik(b.metin, telefon ? 21 : 24, 1.14, w, baslik: true);
            case YzBlokTuru.liste:
              for (var j = 0; j < b.ogeler.length; j++) {
                h += yukseklik(b.ogeler[j], govdeBoy, govdeSatir, w - 22) + (j == b.ogeler.length - 1 ? 0 : madde);
              }
              h += 2 + listeAlt;
            default:
              break;
          }
        }
        return h;
      }

      for (final telefon in [true, false]) {
        var eski = 0.0, yeni = 0.0;
        for (final f in _sayfalar()) {
          if (_en(f) || kYzBolmesizBasliklar.contains(_no(f))) continue;
          final md = f.readAsStringSync();
          eski += sayfa(md, yeni: false, telefon: telefon);
          yeni += sayfa(md, yeni: true, telefon: telefon);
        }
        final oran = yeni / eski - 1;
        // ignore: avoid_print
        print('${telefon ? 'telefon 375' : 'masaüstü 1280'}: metin ${(oran * 100).toStringAsFixed(1)}% uzadı');
        // Sınır telefon için (madde 3). Masaüstünde yalnız metin bloklarında
        // ~%8; grafik, görsel ve tablo değişmediğinden sayfanın tamamında daha az.
        expect(oran, lessThanOrEqualTo(telefon ? 0.07 : 0.10));
      }
    });
  });
}
