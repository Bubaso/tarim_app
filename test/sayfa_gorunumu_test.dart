import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tarim_app/core/analitik/analitik.dart';
import 'package:tarim_app/core/analitik/sayfa_gorunumu.dart';
import 'package:tarim_app/features/yapay_zeka/data/yz_iskelet.g.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_sekme_basligi.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_yollar.dart';

/// Madde 23 (sekme başlığı + site içi page_view) ve madde 15 (belge dili).
class _Sahne {
  _Sahne([this.denetim = const Duration(milliseconds: 600)]);
  final Duration denetim;
  Uri? adres;
  final basliklar = <String>[];
  String? belge;
  final olaylar = <(String, Map<String, Object>)>[];
  final kareler = <VoidCallback>[];
  late final SayfaIzleyici iz = SayfaIzleyici(
    konum: () => adres,
    sekmeAdi: yzSekmeAdi,
    basligiYaz: (b) {
      basliklar.add(b);
      belge = b;
    },
    belgeBasligiOku: () => belge,
    gonder: (o, p) => olaylar.add((o, p)),
    kok: 'https://tarimportali.net',
    kareSonra: kareler.add,
    gecisSonrasiDenetim: denetim,
  );

  /// Adres değişir, dinleyici çalışır, kare çizilir.
  void git(String a) {
    adres = Uri.parse(a);
    iz.rotaDegisti();
    kareCiz();
  }

  void kareCiz() {
    final l = List.of(kareler);
    kareler.clear();
    for (final f in l) {
      f();
    }
  }

  List<Map<String, Object>> get sayfaGorunumleri =>
      [for (final (o, p) in olaylar) if (o == 'page_view') p];
}

void main() {
  group('olcumAdresi', () {
    test('ara, q, terim, geri atılır; bolum ve teknoloji kalır', () {
      expect(
        olcumAdresi(Uri.parse('$yzAramaPath?q=domates&ara=1&terim=x&geri=/a')).toString(),
        yzAramaPath,
      );
      expect(
        olcumAdresi(Uri.parse('$yzPath/sozluk?terim=NDVI&bolum=3&teknoloji=goruntu#x'))
            .toString(),
        '$yzPath/sozluk?bolum=3&teknoloji=goruntu',
      );
      expect(olcumAdresi(Uri.parse('/haber/12?utm_source=x')).toString(), '/haber/12');
      expect(olcumAdresi(Uri.parse('')).toString(), '/');
    });
  });

  group('page_view', () {
    test('ilk sayfa atlanır (gtag saydı), sonraki geçiş gider', () {
      final s = _Sahne();
      s.git('/');
      expect(s.sayfaGorunumleri, isEmpty);
      s.git('$yzPath/sulama-ve-su');
      expect(s.sayfaGorunumleri, hasLength(1));
      final p = s.sayfaGorunumleri.single;
      expect(p['page_location'], 'https://tarimportali.net$yzPath/sulama-ve-su');
      expect(p['page_referrer'], 'https://tarimportali.net/');
      expect(p['page_title'], 'Sulama ve su yönetimi | Tarım Portalı');
      s.iz.kapat();
    });

    test('aynı adres art arda gelirse elenir', () {
      final s = _Sahne();
      s.git('/');
      s.git('/haber/1');
      s.git('/haber/1');
      s.iz.rotaDegisti();
      s.kareCiz();
      expect(s.sayfaGorunumleri, hasLength(1));
      s.git('/');
      expect(s.sayfaGorunumleri, hasLength(2));
      expect(s.sayfaGorunumleri.last['page_referrer'], 'https://tarimportali.net/haber/1');
    });

    test('arama sözcüğü GA\'ya gitmez; yalnız q değişirse yeni olay yok', () {
      final s = _Sahne();
      s.git('/');
      s.git('$yzAramaPath?q=domates');
      s.git('$yzAramaPath?q=domates%20hastal%C4%B1k');
      expect(s.sayfaGorunumleri, hasLength(1));
      final p = s.sayfaGorunumleri.single;
      expect(p['page_location'], 'https://tarimportali.net$yzAramaPath');
      for (final v in p.values) {
        expect('$v', isNot(contains('domates')));
      }
      s.iz.kapat();
    });

    test('bir kare içinde birden çok bildirim tek olay', () {
      final s = _Sahne();
      s.git('/');
      s.adres = Uri.parse('/haber/1');
      s.iz.rotaDegisti();
      s.adres = Uri.parse('/haber/2');
      s.iz.rotaDegisti();
      s.kareCiz();
      expect(s.sayfaGorunumleri, hasLength(1));
      expect(s.sayfaGorunumleri.single['page_location'], 'https://tarimportali.net/haber/2');
    });

    test('bölüm dışı sayfada başlık, sayfanın kendi yazdığı', () {
      final s = _Sahne();
      s.git('/');
      s.adres = Uri.parse('/haber/7');
      s.iz.rotaDegisti();
      s.belge = 'Haberin başlığı'; // ekran kurulurken yazar
      s.kareCiz();
      expect(s.sayfaGorunumleri.single['page_title'], 'Haberin başlığı');
      expect(s.basliklar, isEmpty, reason: 'bölüm dışına dokunulmaz');
    });

    test('ilk sayfadan farklı adrese geçilince sayfaGecisiOldu', () {
      sayfaGecisiOldu = false;
      final s = _Sahne();
      s.adres = Uri.parse('/');
      s.iz.rotaDegisti();
      expect(sayfaGecisiOldu, isFalse);
      s.adres = Uri.parse(yzPath);
      s.iz.rotaDegisti(); // kare çizilmeden ÖNCE işaretli olmalı
      expect(sayfaGecisiOldu, isTrue);
      s.kareCiz();
      s.iz.kapat();
      sayfaGecisiOldu = false;
    });
  });

  group('sekme başlığı', () {
    test('bölüm sayfalarının adları (TR ve EN)', () {
      final b = kYzBasliklar.firstWhere((x) => x.slug == 'sozluk');
      expect(yzSekmeAdi(Uri.parse(yzPath), false), kYzAdTr);
      expect(yzSekmeAdi(Uri.parse(yzPath), true), kYzAdEn);
      expect(yzSekmeAdi(Uri.parse(yzBaslikPath('sozluk')), false), b.tr);
      expect(yzSekmeAdi(Uri.parse(yzBaslikPath('sozluk')), true), b.en);
      expect(yzSekmeAdi(Uri.parse(yzTeknolojiPath('goruntu')), false), 'Görüntü işleme');
      expect(yzSekmeAdi(Uri.parse(yzTeknolojiPath('goruntu')), true), 'Computer vision');
      expect(yzSekmeAdi(Uri.parse('$yzAramaPath?q=x'), false), 'Bölümde ara');
      expect(yzSekmeAdi(Uri.parse('$yzAramaPath?q=x'), true), 'Search the section');
      expect(yzSekmeAdi(Uri.parse('/haber/1'), false), isNull);
      expect(yzSekmeAdi(Uri.parse('/'), true), isNull);
      expect(yzSekmeAdi(Uri.parse('/yapay-zeka-dijital-tarimx'), false), isNull);
    });

    test('bölüme girince yazılır, çıkınca sitenin adına döner', () {
      final s = _Sahne();
      s.git('/');
      expect(s.basliklar, isEmpty);
      s.git(yzBaslikPath('sozluk'));
      expect(s.basliklar.last, 'Sözlük | Tarım Portalı');
      s.git(yzTeknolojiPath('dil'));
      expect(s.basliklar.last, 'Dil modelleri | Tarım Portalı');
      s.git('/');
      expect(s.basliklar.last, kSiteAdi);
      final adet = s.basliklar.length;
      s.git('/haber/3');
      expect(s.basliklar.length, adet, reason: 'bölüm dışında ikinci kez yazılmaz');
    });

    test('dil değişince başlık İngilizce yazılır', () {
      final s = _Sahne();
      s.git(yzBaslikPath('tarihce'));
      expect(s.basliklar.last, 'Kısa tarihçe | Tarım Portalı');
      s.iz.dilDegisti(true);
      expect(s.basliklar.last, 'A short history | Tarım Portalı');
      s.iz.kapat();
    });

    test('kapanan ekran başlığı ezerse geçişten sonra geri yazılır', () async {
      final s = _Sahne(const Duration(milliseconds: 20));
      s.git(yzBaslikPath('sozluk'));
      s.git('/haber/9');
      s.git(yzBaslikPath('sozluk')); // geri
      s.belge = 'Tarım Portalı - Tarımın Doğru Adresi'; // haber kapanırken
      await Future<void>.delayed(const Duration(milliseconds: 60));
      expect(s.belge, 'Sözlük | Tarım Portalı');
    });
  });

  group('yönlendiriciyle', () {
    testWidgets('gerçek GoRouter: sekme başlığı, page_view ve belge dili', (tester) async {
      final sistem = <String>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform,
          (call) async {
        if (call.method == 'SystemChrome.setApplicationSwitcherDescription') {
          sistem.add((call.arguments as Map)['label'] as String);
        }
        return null;
      });
      addTearDown(() => tester.binding.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null));

      final dil = ValueNotifier(const Locale('tr'));
      final diller = <String>[];
      final olaylar = <Map<String, Object>>[];
      final router = GoRouter(routes: [
        GoRoute(path: '/', builder: (_, __) => const Scaffold(body: Text('ana'))),
        GoRoute(path: yzPath, builder: (_, __) => const Scaffold(body: Text('merkez'))),
        GoRoute(path: '$yzPath/:slug', builder: (_, __) => const Scaffold(body: Text('başlık'))),
      ]);
      addTearDown(router.dispose);
      String? belge;
      final iz = SayfaIzleyici(
        konum: () => yonlendiriciAdresi(router),
        sekmeAdi: yzSekmeAdi,
        basligiYaz: (b) {
          belge = b;
          SystemChrome.setApplicationSwitcherDescription(
              ApplicationSwitcherDescription(label: b, primaryColor: 0xFF5C8A4A));
        },
        belgeBasligiOku: () => belge,
        gonder: (o, p) => olaylar.add(p),
      );
      router.routerDelegate.addListener(iz.rotaDegisti);
      sayfaIzleyici = iz;
      addTearDown(() => sayfaIzleyici = null);

      await tester.pumpWidget(ValueListenableBuilder<Locale>(
        valueListenable: dil,
        builder: (_, l, __) => MaterialApp.router(
          title: kSiteAdi,
          locale: l,
          supportedLocales: const [Locale('tr'), Locale('en')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          routerConfig: router,
          builder: (context, child) => BelgeDili(yaz: diller.add, child: child!),
        ),
      ));
      await tester.pumpAndSettle();
      expect(diller, ['tr']);
      expect(olaylar, isEmpty, reason: 'ilk sayfa');

      router.go(yzBaslikPath('sulama-ve-su'));
      await tester.pumpAndSettle();
      expect(sistem.last, 'Sulama ve su yönetimi | Tarım Portalı');
      expect(olaylar, hasLength(1));
      expect(olaylar.single['page_location'], '$yzPath/sulama-ve-su');

      // Dil değişir: MaterialApp'in Title'ı sekmeyi ezer, BelgeDili geri yazar.
      dil.value = const Locale('en');
      await tester.pumpAndSettle();
      expect(diller, ['tr', 'en']);
      expect(sistem.last, 'Irrigation and water | Tarım Portalı');
      expect(olaylar, hasLength(1), reason: 'dil değişimi sayfa görüntülemesi değil');

      router.go('/');
      await tester.pumpAndSettle();
      expect(sistem.last, kSiteAdi);
      expect(olaylar, hasLength(2));

      // `push` adres çubuğunu değiştirmiyor (go_router 14); itilen sayfa
      // yine de sayılmalı ve başlığını almalı.
      dil.value = const Locale('tr');
      await tester.pumpAndSettle();
      router.push(yzPath);
      await tester.pumpAndSettle();
      expect(sistem.last, '$kYzAdTr | Tarım Portalı');
      expect(olaylar, hasLength(3));
      expect(olaylar.last['page_location'], yzPath);
      router.push(yzBaslikPath('tarihce'));
      await tester.pumpAndSettle();
      expect(sistem.last, 'Kısa tarihçe | Tarım Portalı');
      expect(olaylar.last['page_location'], yzBaslikPath('tarihce'));
      expect(olaylar.last['page_referrer'], yzPath);
      router.pop();
      await tester.pumpAndSettle();
      expect(sistem.last, '$kYzAdTr | Tarım Portalı');
      expect(olaylar, hasLength(5));
      router.pop();
      await tester.pumpAndSettle();
      expect(sistem.last, kSiteAdi);
      expect(olaylar.last['page_location'], '/');

      await tester.pump(const Duration(seconds: 1));
      iz.kapat();
    });
  });
}
