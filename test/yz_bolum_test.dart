import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tarim_app/features/home/data/models/news_article.dart';
import 'package:tarim_app/features/yapay_zeka/data/yz_deposu.dart';
import 'package:tarim_app/features/yapay_zeka/data/yz_iskelet.g.dart';
import 'package:tarim_app/features/yapay_zeka/data/yz_metinler.g.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_baslik_ekrani.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_merkez_ekrani.dart';
import 'package:tarim_app/features/yapay_zeka/data/yz_sozluk.g.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_metin_gorunumu.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_parcalar.dart' show YzBaslikKarosu, yzPath;
import 'package:tarim_app/features/yapay_zeka/presentation/yz_seridi.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_sozluk_esle.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_teknoloji_izi.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_teknoloji_ekrani.dart';
import 'package:tarim_app/features/yapay_zeka/data/yz_teknoloji.g.dart';
import 'package:tarim_app/features/yapay_zeka/yz_providers.dart';

// ══════════════════════════════════════════════════════════════════════════
//  Yapay Zeka ve Dijital Tarım — okur tarafı
// ──────────────────────────────────────────────────────────────────────────
//  1. ÇİZİCİ metinlerin kullandığı Markdown kesitini doğru ayrıştırıyor:
//     `>` özet, `##` alt başlık, tablo (ayıraç satırı düşüyor), paragraf.
//     Tanımadığı şeyi yutmuyor, düz metin bırakıyor.
//  2. GÖMÜLÜ METİN depodaki .md ile AYNI: üretici unutulursa sayfa eski
//     metni gösterir ve hiçbir şey kırılmaz. Bu test kırılır.
//  3. Sayfalar telefonda ve masaüstünde TAŞMIYOR; haber akışı sahte veriyle.
//  4. "Şu an öne çıkan" takvime bağlı dönüyor ve yalnız yazılmış başlıktan.
// ══════════════════════════════════════════════════════════════════════════

final _haberler = [
  YzHaber(
    NewsArticle(
      id: 'h1',
      title: 'Orman yangınlarıyla mücadelede yapay zekâ ve İHA dönemi',
      content: '',
      createdAt: DateTime(2026, 11, 10),
      sourceName: 'Tarım Portalı',
    ),
    15,
  ),
  YzHaber(
    NewsArticle(
      id: 'h2',
      title: 'Akıllı sensörler zeytinde ilaçlama masrafını düşürdü',
      content: '',
      createdAt: DateTime(2026, 11, 16),
    ),
    20,
  ),
];

Widget _sarmala(Widget cocuk, {String dil = 'tr', List<YzDizinKaydi> dizin = const []}) =>
    ProviderScope(
      overrides: [
        yzBolumHaberleriProvider.overrideWith((ref, no) async =>
            no == null ? _haberler : _haberler.where((h) => h.baslikNo == no).toList()),
        yzDizinEklenenlerProvider.overrideWith((ref) async => dizin),
      ],
      // Bölüm metni dile göre seçiliyor; varsayılan test dili İngilizce.
      child: MaterialApp(
        locale: Locale(dil),
        supportedLocales: const [Locale('tr'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: cocuk,
      ),
    );

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  group('çizici', () {
    test('özet, alt başlık, tablo, paragraf', () {
      final b = yzAyristir('''# 8 · Başlık

> **Özet.** Birinci satır
> ikinci satır.

## Ne yapıyor

İlk paragraf
devam ediyor.

| A | B |
|---|---|
| 1 | **%35** |

- liste satırı düz metin kalır
''');
      expect(b.map((x) => x.tur).toList(), [
        YzBlokTuru.ozet,
        YzBlokTuru.altBaslik,
        YzBlokTuru.paragraf,
        YzBlokTuru.tablo,
        YzBlokTuru.paragraf,
      ]);
      expect(b[0].metin, '**Özet.** Birinci satır ikinci satır.');
      expect(b[1].metin, 'Ne yapıyor');
      expect(b[2].metin, 'İlk paragraf devam ediyor.');
      expect(b[3].satirlar, [
        ['A', 'B'],
        ['1', '**%35**'],
      ], reason: 'ayıraç satırı tabloya girmemeli');
      expect(b[4].metin, '- liste satırı düz metin kalır');
    });

    // Tablo başlıkları büyük harfle çiziliyor. Ham `toUpperCase()` Türkçede
    // "ŞIRKET", "ÜNIVERSITE" üretiyordu (§25'in tabloları); dar ekranda kart,
    // geniş ekranda tablo — ikisi ayrı kod yolu, ikisi de sınanıyor.
    for (final olcu in const [Size(360, 800), Size(1280, 900)]) {
      testWidgets('tablo başlığı dile göre büyütülüyor · ${olcu.width.toInt()} piksel',
          (t) async {
        t.view.physicalSize = olcu;
        t.view.devicePixelRatio = 1;
        addTearDown(t.view.reset);
        Future<void> ciz(String md, bool en) => t.pumpWidget(MaterialApp(
            home: Scaffold(
                body: SingleChildScrollView(child: YzMetinGorunumu(metin: md, en: en)))));

        await ciz('# 25 · Dizin\n\n> Özet.\n\n## Tablo\n\n| Şirket | Üniversite |\n|---|---|\n| a | b |\n',
            false);
        expect(find.text('ŞİRKET'), findsOneWidget);
        expect(find.text('ÜNİVERSİTE'), findsOneWidget);
        expect(find.text('ŞIRKET'), findsNothing, reason: 'ham toUpperCase geri dönmüş');

        await ciz('# 25 · Directory\n\n> Summary.\n\n## Table\n\n| Company | Field |\n|---|---|\n| a | b |\n',
            true);
        expect(find.text('COMPANY'), findsOneWidget);
        expect(find.text('FIELD'), findsOneWidget, reason: 'İngilizcede i → I');
      });
    }

    test('bütün gömülü metinler bloklara ayrılıyor ve başlık satırı düşüyor', () {
      for (final m in kYzMetinler.values) {
        for (final metin in [m.tr, m.en]) {
          final b = yzAyristir(metin);
          // Karar 56: ayrı özet bloğu yok; metin doğrudan düz yazıyla başlıyor
          // (üretilmiş §29 ve §30 harf başlığıyla).
          expect(b.any((x) => x.tur == YzBlokTuru.ozet), isFalse, reason: '§${m.no}: özet bloğu var');
          if (!{29, 30}.contains(m.no)) {
            expect(b.first.tur, YzBlokTuru.paragraf, reason: '§${m.no}: metin doğrudan başlamıyor');
          }
          expect(metin.contains(RegExp(r'§\d')), isFalse, reason: '§${m.no}: metinde § göndermesi');
          expect(b.where((x) => x.tur == YzBlokTuru.altBaslik), isNotEmpty);
          expect(b.any((x) => x.metin.startsWith('# ')), isFalse);
        }
      }
    });
  });

  // ── Sözlük balonu (karar 14) ve kaynakçadaki adresler ──────────────────
  // Eşleştirici Türkçe ekleri kelimenin sonuna kadar alıyor, kısaltmayı tam
  // kelime ve büyük-küçük harfe duyarlı arıyor, bir terimi sayfada bir kez
  // işaretliyor; kalın parçanın (ölçülmüş sayı) ve adresin içine girmiyor.
  group('sözlük ve bağlantılar', () {
    const terimler = [
      YzTerim('ml', 'makine öğrenmesi', 'machine learning', 'Tanım ML.', 'Def ML.', 'Kaynak: X',
          'Source: X', ['makine öğrenme'], ['machine learning']),
      YzTerim('sar', 'sentetik açıklıklı radar', 'synthetic aperture radar', 'Tanım SAR.',
          'Def SAR.', 'K', 'S', ['sentetik açıklıklı radar', '=SAR'],
          ['synthetic aperture radar', '=SAR']),
      YzTerim('iha', 'insansız hava aracı', 'drone', 'Tanım İHA.', 'Def drone.', 'K', 'S',
          ['insansız hava arac', '=İHA', 'dron'], ['drone', '=UAV']),
      YzTerim('bdm', 'büyük dil modeli', 'large language model', 'T', 'D', 'K', 'S',
          ['büyük dil model'], ['large language model']),
      YzTerim('dm', 'dil modeli', 'language model', 'T', 'D', 'K', 'S', ['dil model'],
          ['language model']),
    ];
    String isaretli(String metin, {bool en = false, Set<String>? gorulen}) =>
        yzTerimleriBul(metin, en, gorulen ?? <String>{}, sozluk: terimler)
            .map((i) => metin.substring(i.bas, i.son))
            .join(' | ');

    test('Türkçe ek kelimenin sonuna kadar işaretleniyor', () {
      expect(isaretli('Model makine öğrenmesiyle eğitildi.'), 'makine öğrenmesiyle');
    });

    test('kısaltma büyük-küçük harfe duyarlı ve tam kelime', () {
      expect(isaretli('Sarımsak tarlası SAR verisiyle izlendi.'), 'SAR');
      expect(isaretli("Tarlaya İHA'yla ilaç atıldı."), 'İHA');
    });

    test('kelimenin ortası yakalanmıyor', () {
      expect(isaretli('Andron adlı çiftlikte dronlar uçtu.'), 'dronlar');
    });

    test('kalın parçanın ve adresin içi işaretlenmiyor', () {
      const kalin = '**makine öğrenmesi** ve makine öğrenmesi';
      final k = yzTerimleriBul(kalin, false, <String>{}, sozluk: terimler).single;
      expect(k.bas, greaterThan(kalin.indexOf(' ve ')));
      const adresli = 'Rapor: https://ornek.org/dron-raporu ve dron uçuşu.';
      final a = yzTerimleriBul(adresli, false, <String>{}, sozluk: terimler).single;
      expect(a.bas, greaterThan(adresli.indexOf(' ve ')));
    });

    test('bir terim sayfada bir kez', () {
      final gorulen = <String>{};
      expect(isaretli('İlk paragrafta makine öğrenmesi.', gorulen: gorulen), 'makine öğrenmesi');
      expect(isaretli('İkincide yine makine öğrenmesi.', gorulen: gorulen), '');
    });

    test('uzun terim önce: büyük dil modeli ile dil modeli karışmıyor', () {
      expect(isaretli('Büyük dil modelleri ve küçük bir dil modeli.'),
          'Büyük dil modelleri | dil modeli');
    });

    test('İngilizce metinde İngilizce desen', () {
      expect(isaretli('A drone and a UAV; machine learning-based.', en: true),
          'drone | machine learning');
    });

    test('İngilizce metindeki "İ" konumları kaydırmıyor', () {
      // `toLowerCase()` İ'yi iki karaktere açıyordu; işaret bir harf kayardı.
      expect(isaretli('İMECE images and machine learning.', en: true), 'machine learning');
    });

    // Uzun terimin BÜTÜN geçişleri kısa terime gölge: "iklim akıllı tarım"
    // sayfada önceden işaretlenmiş olsa da içindeki "akıllı tarım" boş kalır.
    test('uzun terim kısa terime gölge oluyor', () {
      const ozel = [
        YzTerim('iat', 'iklim akıllı tarım', 'climate-smart agriculture', 'T', 'D', 'K', 'S',
            ['iklim akıllı tarım'], ['climate-smart agriculture']),
        YzTerim('at', 'akıllı tarım', 'smart farming', 'T', 'D', 'K', 'S', ['akıllı tarım'],
            ['smart agriculture']),
        YzTerim('sr', 'sohbet robotu', 'chatbot', 'T', 'D', 'K', 'S', ['sohbet robot'],
            ['chatbot']),
        YzTerim('r', 'robot', 'robot', 'T', 'D', 'K', 'S', ['robot'], ['robot']),
      ];
      String bul(String m, Set<String> g, {bool en = false}) =>
          yzTerimleriBul(m, en, g, sozluk: ozel)
              .map((i) => '${i.bas}:${m.substring(i.bas, i.son)}')
              .join(' | ');
      final g = <String>{};
      expect(bul('Proje iklim akıllı tarım üzerine.', g), '6:iklim akıllı tarım');
      const ikinci = 'Yine iklim akıllı tarım teknolojileri; ayrıca akıllı tarım.';
      expect(bul(ikinci, g), '${ikinci.indexOf('akıllı tarım.')}:akıllı tarım');
      const robotlu = 'Bir sohbet robotu ve bir hasat robotu.';
      expect(bul(robotlu, <String>{}),
          '4:sohbet robotu | ${robotlu.indexOf('robotu.')}:robotu');
      const ing = 'Climate-smart agriculture and smart agriculture.';
      expect(bul(ing, <String>{}, en: true),
          '0:Climate-smart agriculture | ${ing.indexOf('smart agriculture.')}:smart agriculture');
    });

    test('cümle ortasında büyük harfle başlayan geçiş özel adın parçası', () {
      const ozel = [
        YzTerim('yz', 'yapay zekâ', 'artificial intelligence', 'T', 'D', 'K', 'S',
            ['yapay zekâ'], ['artificial intelligence', '=AI']),
      ];
      String bul(String m, {bool en = false}) => yzTerimleriBul(m, en, <String>{}, sozluk: ozel)
          .map((i) => '${i.bas}:${m.substring(i.bas, i.son)}')
          .join(' | ');
      const ad = 'Türkiye Yapay Zekâ Eylem Planı tarımı sayıyor; yapay zekâ veriyle eğitiliyor.';
      expect(bul(ad), '${ad.indexOf('yapay zekâ veriyle')}:yapay zekâ');
      expect(bul('Yapay zekâ bir teknoloji ailesi.'), '0:Yapay zekâ', reason: 'blok başı');
      expect(bul('Bu ölçüldü (§7). Yapay zekâ ise geride.'), '17:Yapay zekâ', reason: 'nokta sonrası');
      expect(bul('**Özet.** Yapay zekâ ilerliyor.'), '10:Yapay zekâ', reason: 'özet etiketi sonrası');
      // Kısaltma deseni (=AI) zaten büyük harfli; kural ona uygulanmıyor.
      const ing = 'The EU Artificial Intelligence Act covers AI tools.';
      expect(bul(ing, en: true), '${ing.indexOf('AI tools')}:AI');
    });

    test('tırnak içi (birebir alıntı) işaretlenmiyor', () {
      const m = 'Belge "makine öğrenmesi teknikleri" diyor; burada makine öğrenmesi anlatılıyor.';
      final k = yzTerimleriBul(m, false, <String>{}, sozluk: terimler).single;
      expect(k.bas, m.indexOf('makine öğrenmesi anlatılıyor'));
    });

    test('başlık süzgeci: yalnız ve hariç', () {
      const k = YzTerim('k', 'kesinlik', 'precision', 'T', 'D', 'K', 'S', ['kesinlik'],
          ['precision'], yalniz: [18]);
      expect(k.baslikta(18), isTrue);
      expect(k.baslikta(12), isFalse);
      const d = YzTerim('d', 'doğruluk', 'accuracy', 'T', 'D', 'K', 'S', ['doğrulu'],
          ['accuracy'], haric: [7]);
      expect(d.baslikta(7), isFalse);
      expect(d.baslikta(8), isTrue);
    });

    // §29'daki "Geçtiği başlıklar" sozluk_uret.py'deki Python eşleştiricisiyle
    // yazılıyor; sayfalar ise bu Dart eşleştiricisiyle çiziliyor. İkisi
    // ayrışırsa sözlük, balonun açılmadığı bir başlığı gösterir — ya da tersi.
    test('§29 sayfası Dart eşleştiricisiyle aynı başlıkları gösteriyor', () {
      final sozlukSayfasi = kYzMetinler[29];
      expect(sozlukSayfasi, isNotNull);
      for (final en in [false, true]) {
        final dart = <String, List<int>>{};
        for (final b in kYzBasliklar) {
          final m = kYzMetinler[b.no];
          if (m == null || kYzSozluksuzBasliklar.contains(b.no)) continue;
          final sozluk = kYzSozluk.where((t) => t.baslikta(b.no)).toList();
          final gorulen = <String>{};
          for (final blok in yzAyristir(m.metin(en))) {
            if (blok.tur == YzBlokTuru.ozet || blok.tur == YzBlokTuru.paragraf) {
              yzTerimleriBul(blok.metin, en, gorulen, sozluk: sozluk);
            }
          }
          for (final k in gorulen) {
            (dart[k] ??= []).add(b.no);
          }
        }
        final satirlar = sozlukSayfasi!.metin(en).split('\n');
        final ek = RegExp(en ? r' · Appears in (.*)\.$' : r' · Geçtiği başlıklar: (.*)\.$');
        // Sözlük başlığı numarayla değil kısa adıyla anıyor (karar 56):
        // başlık adının iki noktadan önceki kısmı (sozluk_uret.kisa_adlar).
        final noAdla = {
          for (final b in kYzBasliklar) b.ad(en).split(':').first.trim(): b.no,
        };
        for (final t in kYzSozluk) {
          final satir = satirlar.firstWhere((s) => s.startsWith('**${t.ad(en)}** ('),
              orElse: () => '');
          expect(satir, isNotEmpty, reason: '${t.ad(en)} §29 sayfasında yok');
          expect(satir, contains(t.tanim(en)), reason: '${t.ad(en)}: tanım §29 ile aynı değil');
          expect(satir, contains(t.kaynak(en)), reason: '${t.ad(en)}: kaynak §29 ile aynı değil');
          final m = ek.firstMatch(satir);
          final sayfada = m == null
              ? <int>[]
              : [for (final x in m.group(1)!.split('; ')) noAdla[x] ?? -1];
          final beklenen = (dart[t.kimlik] ?? <int>[])..sort();
          expect(sayfada, beklenen,
              reason: '${t.kimlik} (${en ? 'en' : 'tr'}): Python ile Dart eşleştiricisi ayrıştı');
          expect(beklenen, isNotEmpty, reason: '${t.kimlik}: hiçbir başlıkta balon açmıyor');
        }
      }
    });

    test('adresin sonundaki noktalama ve kapanmamış parantez kırpılıyor', () {
      const m = '(liste sayfası: https://a.org/b?c=1).';
      final a = yzAdresler(m).single;
      expect(m.substring(a.$1, a.$2), 'https://a.org/b?c=1');
    });

    testWidgets('terime dokununca balon açılıyor; adrese dokununca adres veriliyor', (t) async {
      String? acilan;
      await t.pumpWidget(MaterialApp(
          home: Scaffold(body: Builder(builder: (context) {
        final etkilesim = YzEtkilesim(
          tanicilar: <GestureRecognizer>[],
          baglantiAc: (a) => acilan = a,
          terimAc: (terim, konum) => yzTerimBalonu(context, terim, konum, false),
        );
        const metin = 'makine öğrenmesi';
        return Column(children: [
          SelectableText.rich(yzSatirIci(metin, const TextStyle(fontSize: 18),
              etkilesim: etkilesim,
              isaretler: yzTerimleriBul(metin, false, <String>{}, sozluk: terimler))),
          SelectableText.rich(yzSatirIci('https://ornek.org/x', const TextStyle(fontSize: 18),
              etkilesim: etkilesim)),
        ]);
      }))));
      await t.tap(find.byType(SelectableText).first);
      await t.pumpAndSettle();
      expect(find.text('Tanım ML.'), findsOneWidget);
      expect(find.text('Sözlükte aç'), findsOneWidget);
      await t.tapAt(const Offset(5, 590)); // dışarı dokunuş balonu kapatıyor
      await t.pumpAndSettle();
      expect(find.text('Tanım ML.'), findsNothing);
      await t.tap(find.byType(SelectableText).last);
      await t.pump();
      expect(acilan, 'https://ornek.org/x');
    });
  });

  test('gömülü metin depodaki .md ile aynı (üretici koşmuş)', () {
    final klasor = Directory('content/yapay_zeka_dijital_tarim/bolumler');
    for (final b in kYzBasliklar.where((b) => b.yazildi)) {
      final on = '${b.no.toString().padLeft(2, '0')}-${b.slug}';
      final tr = File('${klasor.path}/$on.tr.md').readAsStringSync();
      final en = File('${klasor.path}/$on.en.md').readAsStringSync();
      expect(kYzMetinler[b.no]?.tr, tr, reason: '§${b.no} TR eski — dart_uret.py koşturulmalı');
      expect(kYzMetinler[b.no]?.en, en, reason: '§${b.no} EN eski — dart_uret.py koşturulmalı');
    }
    expect(kYzMetinler.length, kYzBasliklar.where((b) => b.yazildi).length);
  });

  test('öne çıkan başlık takvime bağlı dönüyor, yalnız yazılmıştan', () {
    final yazilan = kYzBasliklar.where((b) => b.yazildi).map((b) => b.no).toSet();
    final gorulen = <int>{};
    // Her gün sıradaki başlık: yazılmış N başlığın hepsi art arda N günde
    // bir kez dönmeli. (Önceki sürüm sabit on gün bekliyordu; yazılmış
    // başlık sayısı ona çıkınca test kendiliğinden yanlış alarm verdi.)
    for (var g = 0; g < yazilan.length; g++) {
      final b = yzOneCikan(DateTime(2026, 11, 1).add(Duration(days: g)));
      expect(b, isNotNull);
      expect(yazilan.contains(b!.no), isTrue);
      gorulen.add(b.no);
    }
    expect(gorulen, yazilan, reason: 'N günde yazılmış N başlığın hepsi dönmeli');
    expect(yzOneCikan(DateTime(2026, 11, 5))!.no, yzOneCikan(DateTime(2026, 11, 5, 23))!.no,
        reason: 'aynı gün aynı başlık');
  });

  for (final olcu in const [Size(360, 800), Size(1280, 900)]) {
    final ad = '${olcu.width.toInt()} piksel';

    testWidgets('merkez sayfa · $ad · taşmıyor', (t) async {
      t.view.physicalSize = olcu;
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      await t.pumpWidget(_sarmala(const YzMerkezEkrani()));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      expect(find.text(kYzAdTr), findsOneWidget);
      expect(find.widgetWithText(YzBaslikKarosu, "Türkiye'de durum"), findsOneWidget,
          reason: 'harita karosu (numarasız, karar 56)');
      expect(find.textContaining(RegExp(r'§\d')), findsNothing, reason: 'okura numara yok');
      expect(find.textContaining('Orman yangınlarıyla'), findsOneWidget, reason: 'haber akışı');
      // §1 yazıldıysa giriş paragrafı haritanın üstünde (karar 6, 56)
      if (kYzMetinler[1] != null) {
        expect(find.text('Durum tespitinin tamamı'), findsOneWidget);
        final giris = yzAyristir(kYzMetinler[1]!.tr)
            .firstWhere((b) => b.tur == YzBlokTuru.paragraf)
            .metin
            .replaceAll('**', '');
        expect(find.textContaining(giris.substring(0, 30), findRichText: true), findsOneWidget);
        expect(find.textContaining('Özet.', findRichText: true), findsNothing);
      }
      // teknoloji süzgeci (karar 57): seçilince kaç başlıkta geçtiği ve
      // karolarda geçtiği yer sayısı
      await t.ensureVisible(find.text('Dil modelleri'));
      await t.pumpAndSettle();
      await t.tap(find.text('Dil modelleri'));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      final dilSayisi = kYzBasliklar.where((b) => b.teknoloji.contains('dil')).length;
      expect(find.textContaining('Dil modelleri $dilSayisi başlıkta geçiyor'), findsOneWidget);
      expect(find.text('Dil modelleri: alanlar arası durum →'), findsOneWidget,
          reason: 'teknoloji sayfasına bağlantı');
      expect(find.textContaining('yerde geçiyor'), findsWidgets);
    });

    // Yazılmış her başlık (tablo, uzun satır, § göndermesi ne varsa) ve
    // yazılmamışlardan biri: yeni yazılan başlık kendiliğinden sınansın.
    for (final slug in _sinanacakBasliklar) {
      testWidgets('başlık sayfası · $slug · $ad · taşmıyor', (t) async {
        t.view.physicalSize = olcu;
        t.view.devicePixelRatio = 1;
        addTearDown(t.view.reset);
        await t.pumpWidget(_sarmala(YzBaslikEkrani(slug: slug)));
        await t.pumpAndSettle();
        expect(t.takeException(), isNull);
        final b = kYzBasliklar.firstWhere((x) => x.slug == slug);
        expect(find.text(b.tr), findsOneWidget);
        if (b.yazildi) {
          expect(find.textContaining('Kaynaklarından son okunduğu gün'), findsOneWidget);
        } else {
          expect(find.text('Bu başlık yazılıyor.'), findsOneWidget);
          expect(find.text('BU BAŞLIK NEYİ ANLATACAK'), findsOneWidget);
        }
      });
    }

    testWidgets('ana sayfa şeridi · $ad · taşmıyor', (t) async {
      t.view.physicalSize = olcu;
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      await t.pumpWidget(_sarmala(const Scaffold(body: SingleChildScrollView(child: YzSeridi(okuraAcik: true)))));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      expect(find.text(kYzAdTr), findsOneWidget);
      expect(find.textContaining('Şu an öne çıkan'), findsOneWidget);
    });
  }

  // İngilizce metinler daha uzun ("in progress", katman adları): dar
  // ekranda bir de İngilizce çizilsin.
  for (final sayfa in <String, Widget>{
    'merkez': const YzMerkezEkrani(),
    for (final slug in _sinanacakBasliklar)
      'başlık §${kYzBasliklar.firstWhere((b) => b.slug == slug).no}': YzBaslikEkrani(slug: slug),
    'şerit': const Scaffold(body: SingleChildScrollView(child: YzSeridi(okuraAcik: true))),
  }.entries) {
    testWidgets('İngilizce · ${sayfa.key} · 360 piksel · taşmıyor', (t) async {
      t.view.physicalSize = const Size(360, 800);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      await t.pumpWidget(_sarmala(sayfa.value, dil: 'en'));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
    });
  }

  testWidgets('okura kapalıyken şerit HİÇ çizilmiyor (yayin.json)', (t) async {
    expect(kYzOkuraAcik, isFalse,
        reason: 'bölüm 30 başlığın tamamı yazılınca açılır — kullanıcı kararı');
    await t.pumpWidget(_sarmala(const Scaffold(body: SingleChildScrollView(child: YzSeridi()))));
    await t.pumpAndSettle();
    expect(find.text(kYzAdTr), findsNothing);
    expect(find.byType(SizedBox), findsWidgets);
  });

  // §25'in dinamik kısmı (karar 38): onaylanan kayıtlar metnin altında;
  // liste boşsa (ya da veritabanı fonksiyonu yoksa) hiçbir şey çizilmiyor.
  for (final olcu in const [Size(360, 800), Size(1280, 900)]) {
    testWidgets('§25 sonradan eklenenler · ${olcu.width.toInt()} piksel', (t) async {
      t.view.physicalSize = olcu;
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      final dizin = [
        YzDizinKaydi(
          id: 'd1',
          ad: 'Örnek Tarım Teknolojileri',
          tur: 'girisim',
          eklendi: DateTime(2026, 11, 16),
          haberId: 'h9',
          haberBaslik: 'Örnek Tarım Teknolojileri yapay zekâlı sulama uygulamasını tanıttı',
          haberBaslikEn: 'Örnek Tarım Teknolojileri unveils AI irrigation app',
          haberTarihi: DateTime(2026, 11, 15),
        ),
        YzDizinKaydi(id: 'd2', ad: 'Haberi yayından kalkmış kuruluş', tur: 'diger',
            eklendi: DateTime(2026, 11, 14)),
      ];
      await t.pumpWidget(_sarmala(const YzBaslikEkrani(slug: 'turkiye-dizini'), dizin: dizin));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      expect(find.text('Dizine sonradan eklenenler'), findsOneWidget);
      expect(find.text('Örnek Tarım Teknolojileri'), findsOneWidget);
      expect(find.text('GİRİŞİM'), findsOneWidget, reason: 'Türkçe büyük harf');
      expect(find.textContaining('Haberde: Örnek Tarım'), findsOneWidget);
      expect(find.text('Haberi yayından kalkmış kuruluş'), findsOneWidget);
      expect(find.textContaining('Haberde:'), findsOneWidget,
          reason: 'yayında haberi olmayan kayıt bağlantı çizmez');

      await t.pumpWidget(_sarmala(const YzBaslikEkrani(slug: 'turkiye-dizini'),
          dil: 'en', dizin: dizin));
      await t.pumpAndSettle();
      expect(find.text('Later additions to the directory'), findsOneWidget);
      expect(find.text('START-UP'), findsOneWidget);
      expect(find.textContaining('In the news: Örnek Tarım Teknolojileri unveils'), findsOneWidget);

      // Yeni sağlayıcı kapsamı: aynı ProviderScope'un önbelleği taşınmasın.
      await t.pumpWidget(const SizedBox());
      await t.pumpWidget(_sarmala(const YzBaslikEkrani(slug: 'turkiye-dizini')));
      await t.pumpAndSettle();
      expect(find.text('Dizine sonradan eklenenler'), findsNothing, reason: 'boş liste çizilmez');
      await t.pumpWidget(const SizedBox());
      await t.pumpWidget(_sarmala(const YzBaslikEkrani(slug: 'riskler-ve-sinirlar'), dizin: dizin));
      await t.pumpAndSettle();
      expect(find.text('Dizine sonradan eklenenler'), findsNothing, reason: 'yalnız §25');
    });
  }

  // "Sözlükte aç" sözlüğe `go` ile gidiyor (webde adres değişsin) ve
  // `?geri=` ile geri oku balonun açıldığı başlığa bağlıyor.
  testWidgets('sözlükten geri: balonun açıldığı başlığa, yoksa merkeze', (t) async {
    t.view.physicalSize = const Size(1280, 900);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    Future<GoRouter> kur(String ilk) async {
      final r = GoRouter(initialLocation: ilk, routes: [
        GoRoute(path: yzPath, builder: (c, s) => const Scaffold(body: Text('MERKEZ'))),
        GoRoute(
            path: '$yzPath/:slug',
            builder: (c, s) => YzBaslikEkrani(slug: s.pathParameters['slug'] ?? '')),
      ]);
      await t.pumpWidget(ProviderScope(
        overrides: [
          yzBolumHaberleriProvider.overrideWith((ref, no) async => const <YzHaber>[]),
          yzDizinEklenenlerProvider.overrideWith((ref) async => const <YzDizinKaydi>[]),
        ],
        child: MaterialApp.router(routerConfig: r),
      ));
      await t.pumpAndSettle();
      return r;
    }

    var r = await kur('$yzPath/sozluk?geri=danismanlik-ve-dil-modelleri');
    await t.tap(find.byIcon(Icons.arrow_back_rounded));
    await t.pumpAndSettle();
    expect(r.routerDelegate.currentConfiguration.uri.path, '$yzPath/danismanlik-ve-dil-modelleri');

    await t.pumpWidget(const SizedBox());
    r = await kur('$yzPath/sozluk?geri=boyle-bir-baslik-yok');
    await t.tap(find.byIcon(Icons.arrow_back_rounded));
    await t.pumpAndSettle();
    expect(find.text('MERKEZ'), findsOneWidget, reason: 'geçersiz geri adresi merkeze döner');
  });

  group('teknoloji izi (karar 57)', () {
    test('Dart eşleştiricisi Python sayımıyla aynı; etiketler sayımdan çıkıyor', () {
      for (final b in kYzBasliklar) {
        final m = kYzMetinler[b.no];
        if (m == null || {29, 30}.contains(b.no)) continue;
        final beklenen = <String>[];
        for (final kod in kYzTeknolojiDesen.keys) {
          final py = kYzTeknolojiIzi[b.no]?[kod] ?? const [0, 0];
          final dart = [yzTeknolojiSay(m.tr, kod, false), yzTeknolojiSay(m.en, kod, true)];
          expect(dart, py, reason: '§${b.no} $kod: Dart ile Python eşleştiricisi ayrıştı');
          if (dart[0] >= 2 && dart[1] >= 2) beklenen.add(kod);
        }
        expect(b.teknoloji, beklenen, reason: '§${b.no}: etiket metinden çıkmıyor');
      }
      for (final e in kYzTeknolojiAna.entries) {
        for (final no in e.value) {
          expect(yzBaslik(no)!.teknoloji, contains(e.key),
              reason: '${e.key}: ana başlık §$no bu teknolojiyle etiketli değil');
        }
      }
      expect(yzTeknolojiGeciyor('Bir sohbet robotu yanıtladı.', 'robotik', false), isFalse,
          reason: 'sohbet robotu robotik değil');
      expect(yzTeknolojiGeciyor('Bir sohbet robotu yanıtladı.', 'dil', false), isTrue);
      expect(yzTeknolojiGeciyor('Ürünü uydu görüntüsünden ayırdı.', 'goruntu', false), isFalse,
          reason: 'uydu görüntüsü uzaktan algılama');
    });

    testWidgets('başlık sayfası ?teknoloji= ile geçtiği yerleri işaretliyor', (t) async {
      t.view.physicalSize = const Size(1280, 900);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      final r = GoRouter(
          initialLocation: '$yzPath/goruntu-isleme-ve-hedefli-ilaclama?teknoloji=goruntu',
          routes: [
            GoRoute(path: yzPath, builder: (c, s) => const Scaffold(body: Text('MERKEZ'))),
            GoRoute(
                path: '$yzPath/:slug',
                builder: (c, s) => YzBaslikEkrani(slug: s.pathParameters['slug'] ?? '')),
          ]);
      await t.pumpWidget(ProviderScope(
        overrides: [
          yzBolumHaberleriProvider.overrideWith((ref, no) async => const <YzHaber>[]),
          yzDizinEklenenlerProvider.overrideWith((ref) async => const <YzDizinKaydi>[]),
        ],
        child: MaterialApp.router(routerConfig: r),
      ));
      await t.pumpAndSettle();
      // Test dili İngilizce: sayı EN metninden.
      final sayi = kYzTeknolojiIzi[8]!['goruntu']![1];
      expect(sayi, greaterThan(0));
      expect(find.textContaining('comes up in $sayi places on this page'), findsOneWidget);
      await t.tap(find.text('Next ↓'));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      await t.ensureVisible(find.byTooltip('Remove marking'));
      await t.pumpAndSettle();
      await t.tap(find.byTooltip('Remove marking'));
      await t.pumpAndSettle();
      expect(r.routerDelegate.currentConfiguration.uri.queryParameters.containsKey('teknoloji'),
          isFalse);
      expect(find.textContaining('places on this page'), findsNothing);
      // Geçersiz kod sessizce yok sayılıyor.
      r.go('$yzPath/goruntu-isleme-ve-hedefli-ilaclama?teknoloji=yok');
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      expect(find.textContaining('places on this page'), findsNothing);
    });
  });

  group('teknoloji sayfaları ve kesişim notları (karar 57)', () {
    test('her teknolojinin sayfası ve her etiketli kesişimin notu var', () {
      for (final kod in kYzTeknoloji.keys) {
        final m = kYzTeknolojiMetinleri[kod];
        expect(m, isNotNull, reason: '$kod: teknoloji sayfası yok');
        for (final metin in [m!.tr, m.en]) {
          final b = yzAyristir(metin);
          expect(b.first.tur, YzBlokTuru.paragraf, reason: '$kod: metin doğrudan başlamıyor');
          expect(metin.contains(RegExp(r'§\d')), isFalse, reason: '$kod: § göndermesi');
        }
        final etiketli = {for (final b in kYzBasliklar) if (b.teknoloji.contains(kod)) b.no};
        expect((kYzKesisim[kod] ?? const {}).keys.toSet(), etiketli,
            reason: '$kod: notlar etiketli başlıklarla birebir değil');
      }
    });

    for (final olcu in const [Size(360, 800), Size(1280, 900)]) {
      for (final dil in const ['tr', 'en']) {
        testWidgets('teknoloji sayfaları · $dil · ${olcu.width.toInt()} piksel · taşmıyor',
            (t) async {
          t.view.physicalSize = olcu;
          t.view.devicePixelRatio = 1;
          addTearDown(t.view.reset);
          for (final kod in kYzTeknoloji.keys) {
            await t.pumpWidget(_sarmala(YzTeknolojiEkrani(kod: kod), dil: dil));
            await t.pumpAndSettle();
            expect(t.takeException(), isNull, reason: kod);
            expect(find.text(kYzTeknoloji[kod]![dil]!), findsOneWidget, reason: kod);
            final etiketli = kYzBasliklar.where((b) => b.teknoloji.contains(kod)).length;
            expect(find.byType(YzKesisimSatiri, skipOffstage: false), findsNWidgets(etiketli),
                reason: '$kod: geçtiği başlıklar');
            await t.pumpWidget(const SizedBox());
          }
        });
      }
    }

    testWidgets('bilinmeyen teknoloji: çökmüyor', (t) async {
      await t.pumpWidget(_sarmala(const YzTeknolojiEkrani(kod: 'yok')));
      await t.pumpAndSettle();
      expect(find.text('Böyle bir teknoloji yok.'), findsOneWidget);
    });
  });

  testWidgets('bilinmeyen adres: bulunamadı, çökmüyor', (t) async {
    await t.pumpWidget(_sarmala(const YzBaslikEkrani(slug: 'yok-boyle-bir-sey')));
    await t.pumpAndSettle();
    expect(find.text('Böyle bir başlık yok.'), findsOneWidget);
  });
}

/// Çizim testlerinin başlıkları: yazılmışların HEPSİ + yazılmamışlardan ilki
/// ("Bu başlık yazılıyor." dalı da sınansın; hepsi yazılınca o dal düşer).
final List<String> _sinanacakBasliklar = [
  ...kYzBasliklar.where((b) => b.yazildi).map((b) => b.slug),
  ...kYzBasliklar.where((b) => !b.yazildi).map((b) => b.slug).take(1),
];
