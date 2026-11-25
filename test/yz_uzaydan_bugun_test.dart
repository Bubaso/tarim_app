import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tarim_app/features/yapay_zeka/data/yz_iskelet.g.dart';
import 'package:tarim_app/features/yapay_zeka/data/yz_metinler.g.dart';
import 'package:tarim_app/features/yapay_zeka/data/yz_teknoloji.g.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_gorsel.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_metin_gorunumu.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_okuma.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_okuma_olcer.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_uzaydan_bugun.dart';

// ══════════════════════════════════════════════════════════════════════════
//  "Uzaydan bugün" — §19'daki canlı uydu penceresi ([[canli:uzaydan-bugun]])
// ──────────────────────────────────────────────────────────────────────────
//  Ağ YOK: döşemeleri sahte bir GIBS veriyor (adresi kaydediyor, 200 / 404 /
//  500 ya da bekletme). Tarih hesabı, 404'te bir gün geri adım, döşeme ve
//  Worldview adresleri, hata → blok gizli, kaydırıcı, hareket azaltma,
//  telefon ve masaüstünde taşma, yönergenin iki dilde aynı yerde olması,
//  arama ve okuma süresinin yönergeyi saymaması.
// ══════════════════════════════════════════════════════════════════════════

late ui.Image _resim;

class _SahteDoseme extends ImageProvider<_SahteDoseme> {
  _SahteDoseme(this.yukle);
  final Future<ImageInfo> Function() yukle;

  @override
  Future<_SahteDoseme> obtainKey(ImageConfiguration configuration) => SynchronousFuture(this);

  @override
  ImageStreamCompleter loadImage(_SahteDoseme key, ImageDecoderCallback decode) =>
      OneFrameImageStreamCompleter(yukle());
}

/// Sahte GIBS: her isteği kaydeder; [durum] adrese göre HTTP kodu.
class _Gibs {
  final istekler = <Uri>[];
  int Function(Uri adres) durum = (_) => 200;

  /// Açıksa döşemeler bekletiliyor ([bekleyen]le elle tamamlanır).
  bool beklet = false;
  final bekleyen = <(Uri, Completer<ImageInfo>)>[];

  ImageProvider saglayici(Uri adres) {
    istekler.add(adres);
    if (beklet) {
      final c = Completer<ImageInfo>();
      bekleyen.add((adres, c));
      return _SahteDoseme(() => c.future);
    }
    final s = durum(adres);
    return _SahteDoseme(() => s == 200
        ? SynchronousFuture(ImageInfo(image: _resim.clone()))
        : Future<ImageInfo>.error(NetworkImageLoadException(statusCode: s, uri: adres)));
  }

  void hepsiniTamamla() {
    for (final (_, c) in bekleyen) {
      if (!c.isCompleted) c.complete(ImageInfo(image: _resim.clone()));
    }
    bekleyen.clear();
  }

  List<String> get ndviGunleri => [
        for (final u in istekler)
          if (u.path.contains(kYzNdviKatmani)) u.pathSegments[u.pathSegments.indexOf('default') + 1],
      ];
}

/// Sabit "şimdi": 25 Kasım 2026, 19.30 UTC → aday 24 Kasım.
DateTime _simdi() => DateTime.utc(2026, 11, 25, 19, 30);

Widget _uygulama(Widget cocuk, {String dil = 'tr', double yan = 0, bool hareketsiz = false, double yazi = 1}) =>
    MaterialApp(
      locale: Locale(dil),
      supportedLocales: const [Locale('tr'), Locale('en')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: Builder(
        builder: (c) => MediaQuery(
          data: MediaQuery.of(c).copyWith(disableAnimations: hareketsiz, textScaler: TextScaler.linear(yazi)),
          child: Scaffold(
            body: SingleChildScrollView(
              child: Padding(padding: EdgeInsets.symmetric(horizontal: yan), child: cocuk),
            ),
          ),
        ),
      ),
    );

/// Makale sütunu: telefonda ekran − 2 × 16, masaüstünde 696 px (760 − 2 × 32).
Widget _sutunda(Widget w, Size ekran) =>
    ekran.width < 640 ? w : Center(child: SizedBox(width: 696, child: w));

Future<void> _boyut(WidgetTester t, Size s) async {
  t.view.physicalSize = s;
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
}

YzUzaydanBugun _pencere(_Gibs g, {bool en = false}) =>
    YzUzaydanBugun(en: en, dosemeSaglayici: g.saglayici, simdi: _simdi);

String _tarih(WidgetTester t) => t.widget<Text>(find.byKey(const ValueKey('yz-uzaydan-tarih'))).data!;

bool _hazir(WidgetTester t) {
  final o = find.ancestor(of: find.byKey(const ValueKey('yz-uzaydan-tarih')), matching: find.byType(Opacity));
  return t.widget<Opacity>(o.first).opacity == 1;
}

double _haritaSaydamligi(WidgetTester t) => t
    .widget<AnimatedOpacity>(
        find.ancestor(of: find.byKey(const ValueKey('yz-uzaydan-harita')), matching: find.byType(AnimatedOpacity)))
    .opacity;

const String _yonerge = '[[canli:uzaydan-bugun]]';

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  setUpAll(() async {
    _resim = await createTestImage(width: 4, height: 4);
  });

  group('tarih hesabı', () {
    test('GIBS tarihi YYYY-MM-DD; en son aday dünün UTC günü (yerel saat değil)', () {
      expect(yzGibsTarih(DateTime.utc(2026, 3, 5)), '2026-03-05');
      expect(yzEnSonAday(DateTime.utc(2026, 11, 25, 19, 30)), DateTime.utc(2026, 11, 24));
      expect(yzEnSonAday(DateTime.utc(2026, 11, 25, 0, 1)), DateTime.utc(2026, 11, 24));
      // İstanbul'da 25 Kasım 00.30 = UTC 24 Kasım 21.30 → aday 23 Kasım.
      expect(yzEnSonAday(DateTime.parse('2026-11-25T00:30:00+03:00')), DateTime.utc(2026, 11, 23));
      // Yıl ve ay dönümü.
      expect(yzEnSonAday(DateTime.utc(2027, 1, 1, 8)), DateTime.utc(2026, 12, 31));
      expect(yzEnSonAday(DateTime.utc(2028, 3, 1, 8)), DateTime.utc(2028, 2, 29));
    });

    test('404 geri adımı: hedeften başlayıp yedi gün, ay ve yıl dönümünde doğru', () {
      final g = yzDenenecekGunler(DateTime.utc(2026, 11, 24));
      expect(g.length, kYzDenemeGunu);
      expect(g.first, DateTime.utc(2026, 11, 24));
      expect(g[1], DateTime.utc(2026, 11, 23));
      expect(g.last, DateTime.utc(2026, 11, 18));
      expect(yzDenenecekGunler(DateTime.utc(2026, 3, 2)).take(4).map(yzGibsTarih),
          ['2026-03-02', '2026-03-01', '2026-02-28', '2026-02-27']);
      expect(yzDenenecekGunler(DateTime.utc(2028, 3, 1)).take(3).map(yzGibsTarih),
          ['2028-03-01', '2028-02-29', '2028-02-28'], reason: 'artık yıl');
      expect(yzDenenecekGunler(DateTime.utc(2027, 1, 2)).take(3).map(yzGibsTarih),
          ['2027-01-02', '2027-01-01', '2026-12-31']);
      // Arşivdeki boş gün (2026-02-09): bir gün geri 2026-02-08.
      expect(yzDenenecekGunler(DateTime.utc(2026, 2, 9))[1], DateTime.utc(2026, 2, 8));
    });

    test('duraklar: son 12 ay, aylık 13 durak, eskiden yeniye; ayın son günü ve artık gün', () {
      final d = yzDuraklar(DateTime.utc(2026, 11, 24));
      expect(d.length, kYzAySayisi + 1);
      expect(d.first, DateTime.utc(2025, 11, 24), reason: 'ilki bir yıl önce, aynı gün');
      expect(d.last, DateTime.utc(2026, 11, 24));
      expect(d[6], DateTime.utc(2026, 5, 24));
      for (var i = 1; i < d.length; i++) {
        expect(d[i].isAfter(d[i - 1]), isTrue);
      }
      // Yıl dönümü: Ocak'tan geriye bir önceki yılın Aralık'ı.
      expect(yzDuraklar(DateTime.utc(2026, 1, 15)).take(2), [DateTime.utc(2025, 1, 15), DateTime.utc(2025, 2, 15)]);
      expect(yzAyGeri(DateTime.utc(2026, 1, 15), 1), DateTime.utc(2025, 12, 15));
      // 31 Mart → 28 Şubat; artık yılda 29 Şubat.
      expect(yzAyGeri(DateTime.utc(2026, 3, 31), 1), DateTime.utc(2026, 2, 28));
      expect(yzAyGeri(DateTime.utc(2028, 3, 31), 1), DateTime.utc(2028, 2, 29));
      expect(yzAyGeri(DateTime.utc(2028, 2, 29), 12), DateTime.utc(2027, 2, 28));
      expect(yzAyGeri(DateTime.utc(2026, 12, 31), 2), DateTime.utc(2026, 10, 31));
      expect(yzDuraklar(DateTime.utc(2026, 5, 31)).map((x) => x.day).toSet(), {28, 30, 31});
    });
  });

  group('döşeme ve Worldview adresleri', () {
    test('Türkiye kesiti z6\'da x 36-40, y 23-25 (15 döşeme); uç noktalar kesitte', () {
      final k = kYzTurkiyeKesiti;
      expect(k.z, 6);
      expect((k.ilkSutun, k.sonSutun, k.ilkSatir, k.sonSatir), (36, 40, 23, 25));
      expect(k.dosemeler.length, 15);
      expect(k.dosemeler.first, (23, 36));
      expect(k.dosemeler.last, (25, 40));
      expect(k.orta, (24, 38), reason: 'yoklanan döşeme İç Anadolu');
      expect(k.oran, closeTo(2.24, 0.01));
      // Gökçeada (batı), Iğdır (doğu), Sinop (kuzey), Hatay (güney) kesitin içinde.
      for (final (boylam, enlem) in [(25.67, 40.2), (44.82, 39.9), (35.1, 42.1), (36.15, 35.82)]) {
        final x = yzMercatorX(boylam, 6), y = yzMercatorY(enlem, 6);
        expect(x > k.sol && x < k.sag && y > k.ust && y < k.alt, isTrue, reason: '($boylam, $enlem)');
      }
    });

    test('adres kalıbı: katman / default / tarih / matris / z / y / x', () {
      expect(yzNdviDosemesi(DateTime.utc(2026, 11, 24), 6, 24, 38).toString(),
          'https://gibs.earthdata.nasa.gov/wmts/epsg3857/best/MODIS_Terra_NDVI_8Day/default/2026-11-24/GoogleMapsCompatible_Level9/6/24/38.png');
      expect(yzSinirDosemesi(6, 23, 36).toString(),
          'https://gibs.earthdata.nasa.gov/wmts/epsg3857/best/Reference_Features/default/GoogleMapsCompatible_Level9/6/23/36.png');
      expect(yzWorldviewAdresi(DateTime.utc(2026, 11, 24)).toString(),
          'https://worldview.earthdata.nasa.gov/?v=25,35.5,45.5,42.6'
          '&l=Coastlines_15m,DoS_International_Boundaries,MODIS_Terra_NDVI_8Day&t=2026-11-24-T00%3A00%3A00Z');
    });

    testWidgets('açılışta: 15 kıyı-sınır, 1 yoklama, 15 NDVI döşemesi; hepsi GIBS\'ten, dünün tarihiyle', (t) async {
      final g = _Gibs();
      await _boyut(t, const Size(1280, 900));
      await t.pumpWidget(_uygulama(_sutunda(_pencere(g), const Size(1280, 900))));
      await t.pump();
      await t.pump();
      expect(g.istekler.length, 31);
      expect(g.istekler.every((u) => u.host == 'gibs.earthdata.nasa.gov' && u.scheme == 'https'), isTrue);
      final kiyi = g.istekler.where((u) => u.path.contains('/Reference_Features/')).toList();
      expect(kiyi.map((u) => u.pathSegments.skip(u.pathSegments.length - 3).join('/')).toSet(),
          {for (final (y, x) in kYzTurkiyeKesiti.dosemeler) '6/$y/$x.png'});
      expect(g.ndviGunleri.toSet(), {'2026-11-24'});
      expect(g.istekler[15].toString(), endsWith('/6/24/38.png'), reason: 'önce ortadaki döşeme yoklanıyor');
      expect(_hazir(t), isTrue);
      expect(_tarih(t), '24 Kasım 2026');
      expect(find.text('MODIS (Terra) bitki örtüsü endeksi (NDVI), 8 günlük kayan bileşik, 24 Kasım 2026'),
          findsOneWidget);
      expect(find.text('NASA EOSDIS GIBS · Kıyı ve sınırlar: © OpenStreetMap katkıcıları, Natural Earth'),
          findsOneWidget);
      expect(find.text("NASA Worldview'da aç"), findsOneWidget);
      expect(t.takeException(), isNull);
    });
  });

  group('404: bir gün geri', () {
    testWidgets('yayımlanmamış günler yalnız yoklanıyor; ilk yayımlanmış gün gösteriliyor', (t) async {
      final g = _Gibs()
        ..durum = (u) => u.path.contains('/2026-11-24/') || u.path.contains('/2026-11-23/') ? 404 : 200;
      await t.pumpWidget(_uygulama(_pencere(g)));
      for (var i = 0; i < 6; i++) {
        await t.pump();
      }
      expect(g.ndviGunleri.where((x) => x == '2026-11-24').length, 1, reason: 'yalnız yoklama');
      expect(g.ndviGunleri.where((x) => x == '2026-11-23').length, 1);
      expect(g.ndviGunleri.where((x) => x == '2026-11-22').length, 16, reason: 'yoklama + 15 döşeme');
      expect(_tarih(t), '22 Kasım 2026');
      expect(find.textContaining('8 günlük kayan bileşik, 22 Kasım 2026'), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    testWidgets('bir döşemesi 404 olan gün de atlanıyor', (t) async {
      final g = _Gibs()..durum = (u) => u.path.contains('/2026-11-24/') && u.path.endsWith('/6/25/40.png') ? 404 : 200;
      await t.pumpWidget(_uygulama(_pencere(g)));
      for (var i = 0; i < 6; i++) {
        await t.pump();
      }
      expect(_tarih(t), '23 Kasım 2026');
    });

    testWidgets('yedi gün üst üste 404: blok hiç çizilmiyor', (t) async {
      final g = _Gibs()..durum = (u) => u.path.contains(kYzNdviKatmani) ? 404 : 200;
      await t.pumpWidget(_uygulama(_pencere(g)));
      for (var i = 0; i < 12; i++) {
        await t.pump();
      }
      expect(g.ndviGunleri.length, kYzDenemeGunu, reason: 'her gün için tek yoklama');
      expect(find.byType(Slider), findsNothing);
      expect(find.textContaining('MODIS'), findsNothing);
      expect(t.getSize(find.byType(YzUzaydanBugun)), Size.zero);
      expect(t.takeException(), isNull);
    });
  });

  group('hata: blok gizli', () {
    for (final (ad, durum) in <(String, int Function(Uri))>[
      ('NDVI 500', (u) => u.path.contains(kYzNdviKatmani) ? 500 : 200),
      ('kıyı-sınır 503', (u) => u.path.contains(kYzSinirKatmani) ? 503 : 200),
      ('ağ yok (0)', (u) => 0),
    ]) {
      testWidgets('$ad → hiçbir şey çizilmiyor, istisna yok', (t) async {
        final g = _Gibs()..durum = durum;
        await t.pumpWidget(_uygulama(_pencere(g)));
        for (var i = 0; i < 6; i++) {
          await t.pump();
        }
        expect(t.getSize(find.byType(YzUzaydanBugun)), Size.zero);
        expect(find.byType(Slider), findsNothing);
        expect(t.takeException(), isNull);
      });
    }

    testWidgets('gerçek NetworkImage (testte HttpClient 400 döner) → gizli; eski sayfa testleri kırılmıyor', (t) async {
      await t.pumpWidget(_uygulama(const YzUzaydanBugun(en: false, simdi: _simdi)));
      for (var i = 0; i < 10; i++) {
        await t.pump();
      }
      expect(t.getSize(find.byType(YzUzaydanBugun)), Size.zero);
      expect(t.takeException(), isNull);
    });

    testWidgets('yüklenirken: aynı boyda yer tutucu; denetimler görünmez ve dokunulmaz', (t) async {
      final g = _Gibs()..beklet = true;
      await _boyut(t, const Size(1280, 900));
      await t.pumpWidget(_uygulama(_sutunda(_pencere(g), const Size(1280, 900))));
      await t.pump();
      final yuklenirken = t.getSize(find.byType(YzUzaydanBugun));
      expect(yuklenirken.height, greaterThan(300));
      expect(_hazir(t), isFalse);
      expect(find.byType(IgnorePointer).evaluate().any((e) => (e.widget as IgnorePointer).ignoring), isTrue);
      // Kıyı-sınır döşemeleri gelsin, sonra yoklama ve NDVI.
      for (var i = 0; i < 3; i++) {
        g.hepsiniTamamla();
        await t.pump();
        await t.pump();
      }
      expect(_hazir(t), isTrue);
      expect(t.getSize(find.byType(YzUzaydanBugun)).height, closeTo(yuklenirken.height, 1),
          reason: 'yüklenince yerleşim kaymıyor');
    });

    testWidgets('yükleme sürerken sayfa kapanırsa istisna yok; geç gelen döşeme bırakılıyor', (t) async {
      final g = _Gibs()..beklet = true;
      await t.pumpWidget(_uygulama(_pencere(g)));
      await t.pump();
      await t.pumpWidget(const SizedBox());
      g.hepsiniTamamla();
      await t.pump();
      expect(t.takeException(), isNull);
    });

    testWidgets('sonradan seçilen tarih yüklenemezse kaydırıcı gösterilen tarihe dönüyor', (t) async {
      final g = _Gibs();
      await t.pumpWidget(_uygulama(_pencere(g)));
      await t.pump();
      await t.pump();
      g.durum = (u) => u.path.contains('/2025-11-24/') ? 500 : 200;
      final s = find.byType(Slider);
      await t.tapAt(t.getTopLeft(s) + Offset(11, t.getSize(s).height / 2));
      await t.pump();
      await t.pump();
      await t.pump();
      expect(find.byType(Slider), findsOneWidget, reason: 'blok yerinde');
      expect(t.widget<Slider>(s).value, kYzAySayisi.toDouble());
      expect(_tarih(t), '24 Kasım 2026');
      expect(_haritaSaydamligi(t), 1);
      expect(t.takeException(), isNull);
    });
  });

  group('kaydırıcı', () {
    testWidgets('13 durak; ilk durağa dokununca tarih anında, harita yüklenince künye', (t) async {
      final g = _Gibs();
      await t.pumpWidget(_uygulama(_pencere(g)));
      await t.pump();
      await t.pump();
      final s = find.byType(Slider);
      expect(t.widget<Slider>(s).divisions, kYzAySayisi);
      expect(t.widget<Slider>(s).value, kYzAySayisi.toDouble(), reason: 'varsayılan en son gün');
      expect(find.text('Kasım 2025'), findsOneWidget);
      expect(find.text('Kasım 2026'), findsOneWidget);
      g.beklet = true;
      await t.tapAt(t.getTopLeft(s) + Offset(11, t.getSize(s).height / 2));
      await t.pump();
      expect(_tarih(t), '24 Kasım 2025', reason: 'etiket hemen');
      expect(find.textContaining('kayan bileşik, 24 Kasım 2026'), findsOneWidget, reason: 'künye haritanın tarihi');
      expect(_haritaSaydamligi(t), lessThan(1), reason: 'yüklenirken harita soluk');
      for (var i = 0; i < 3; i++) {
        g.hepsiniTamamla();
        await t.pump();
        await t.pump();
      }
      expect(find.textContaining('kayan bileşik, 24 Kasım 2025'), findsOneWidget);
      expect(_haritaSaydamligi(t), 1);
      expect(g.ndviGunleri.toSet(), {'2026-11-24', '2025-11-24'});
    });

    testWidgets('sürüklerken döşeme istenmiyor; 300 ms durunca isteniyor', (t) async {
      final g = _Gibs();
      await t.pumpWidget(_uygulama(_pencere(g)));
      await t.pump();
      await t.pump();
      final s = find.byType(Slider);
      final adim = (t.getSize(s).width - 20) / kYzAySayisi;
      final once = g.istekler.length;
      // Kaydırıcının kendi yan payı 10 px: başparmak sağ uçta, payın içinde.
      final el = await t.startGesture(t.getTopRight(s) + Offset(-12, t.getSize(s).height / 2));
      for (var i = 1; i <= 4; i++) {
        await el.moveBy(Offset(-adim, 0));
        await t.pump(const Duration(milliseconds: 100));
      }
      expect(_tarih(t), '24 Temmuz 2026');
      expect(g.istekler.length, once, reason: 'sürüklerken istek yok');
      await t.pump(const Duration(milliseconds: 300));
      expect(g.ndviGunleri.last, '2026-07-24', reason: '300 ms durunca');
      await el.up();
      await t.pump();
      await t.pump();
      expect(find.textContaining('kayan bileşik, 24 Temmuz 2026'), findsOneWidget);
      expect(g.ndviGunleri.where((x) => x == '2026-07-24').length, 16, reason: 'bırakınca ikinci kez istenmiyor');
    });

    testWidgets('ekran okuyucu: kaydırıcının adı ve değeri tarih', (t) async {
      final g = _Gibs();
      final tutamak = t.ensureSemantics();
      await t.pumpWidget(_uygulama(_pencere(g, en: true), dil: 'en'));
      await t.pump();
      await t.pump();
      final d = t.getSemantics(find.byType(Slider)).getSemanticsData();
      expect(d.label, 'Date of the map');
      expect(d.value, '24 November 2026');
      expect(d.decreasedValue, '24 October 2026', reason: 'klavye ve ekran okuyucu bir adım: bir ay');
      tutamak.dispose();
    });
  });

  group('hareket azaltma', () {
    for (final hareketsiz in [false, true]) {
      testWidgets('tarih yüklenirken haritanın solması ${hareketsiz ? 'anında (geçiş yok)' : '180 ms'}', (t) async {
        final g = _Gibs();
        await t.pumpWidget(_uygulama(_pencere(g), hareketsiz: hareketsiz));
        await t.pump();
        await t.pump();
        g.beklet = true;
        final s = find.byType(Slider);
        await t.tapAt(t.getTopLeft(s) + Offset(11, t.getSize(s).height / 2));
        await t.pump();
        final a = t.widget<AnimatedOpacity>(find.ancestor(
            of: find.byKey(const ValueKey('yz-uzaydan-harita')), matching: find.byType(AnimatedOpacity)));
        expect(a.duration, hareketsiz ? Duration.zero : const Duration(milliseconds: 180));
        g.hepsiniTamamla();
        await t.pump();
      });
    }
  });

  group('yerleşim: taşma yok', () {
    for (final ekran in const [Size(375, 812), Size(1280, 900), Size(1440, 900)]) {
      for (final dil in ['tr', 'en']) {
        testWidgets('${ekran.width.toInt()}×${ekran.height.toInt()} · $dil', (t) async {
          final g = _Gibs();
          await _boyut(t, ekran);
          final telefon = ekran.width < 640;
          await t.pumpWidget(_uygulama(_sutunda(_pencere(g, en: dil == 'en'), ekran), dil: dil, yan: telefon ? 16 : 0));
          await t.pump();
          await t.pump();
          expect(t.takeException(), isNull);
          expect(_hazir(t), isTrue);
          final harita = t.getSize(find.byKey(const ValueKey('yz-uzaydan-harita')));
          // Telefonda harita kenardan kenara; masaüstünde sütun genişliğinde.
          expect(harita.width, telefon ? ekran.width : 696);
          expect(harita.width / harita.height, closeTo(kYzTurkiyeKesiti.oran, 0.01));
          final blok = t.getRect(find.byType(YzUzaydanBugun));
          expect(blok.right, lessThanOrEqualTo(ekran.width));
        });
      }
    }

    testWidgets('telefonda büyük yazıyla (×1,4) da taşma yok; lejant etiketleri çakışmıyor', (t) async {
      final g = _Gibs();
      await _boyut(t, const Size(375, 812));
      await t.pumpWidget(_uygulama(_pencere(g), yan: 16, yazi: 1.4));
      await t.pump();
      await t.pump();
      expect(t.takeException(), isNull);
    });

    test('lejant: uçlar kenarda, etiketler çakışmıyor; dar yerde önce 0,3 düşüyor', () {
      double olc(String m) => m.length * 8.0;
      final genis = yzLejantYerleri(600, false, olc);
      expect(genis.map((e) => e.$2), ['0,0', '0,2', '0,3', '0,4', '0,6', '0,8', '1,0']);
      expect(genis.first.$1, 0);
      expect(genis.last.$1 + olc('1,0'), closeTo(600, 0.001));
      final dar = yzLejantYerleri(160, true, olc);
      expect(dar.map((e) => e.$2), containsAllInOrder(['0.0', '1.0']));
      expect(dar.map((e) => e.$2), isNot(contains('0.3')));
      for (var i = 1; i < dar.length; i++) {
        expect(dar[i].$1, greaterThanOrEqualTo(dar[i - 1].$1 + olc(dar[i - 1].$2)));
      }
      expect(kYzNdviLejanti.length, 140, reason: 'GIBS MODIS_NDVI lejantı: 140 girdi');
      expect(kYzNdviLejanti.first, 0xFFF1ECEC);
      expect(kYzNdviLejanti.last, 0xFF001801);
    });
  });

  group('yönerge', () {
    test('canli blok türü; metin değil (sözlük, kısaltma, arama görmüyor); tanınmayan kimlik çizilmiyor', () {
      final b = yzAyristir('# 19 · B\n\nBir.\n\n$_yonerge\n\nİki.\n');
      expect(b.map((x) => x.tur), [YzBlokTuru.paragraf, YzBlokTuru.canli, YzBlokTuru.paragraf]);
      expect(b[1].metin, 'uzaydan-bugun');
      expect(b[1].parcalar, isEmpty);
      expect(yzCanliPencere('yok-boyle', en: false), isA<SizedBox>());
      expect(yzCanliPencere('uzaydan-bugun', en: true), isA<YzUzaydanBugun>());
    });

    test('§19\'da iki dilde aynı yerde: ilke görselinin hemen ardında; başka sayfada yok', () {
      final m = kYzMetinler[19]!;
      int yeri(String md) {
        final b = yzAyristir(md);
        final i = b.indexWhere((x) => x.tur == YzBlokTuru.canli);
        expect(b.where((x) => x.tur == YzBlokTuru.canli).length, 1);
        expect(b[i - 1].tur, YzBlokTuru.gorsel);
        expect(b[i - 1].metin, 'b19-uydunun-bitki-ortusunu-olcme-ilkesi');
        return i;
      }

      expect(yeri(m.tr), yeri(m.en));
      for (final x in kYzMetinler.values) {
        if (x.no == 19) continue;
        expect('${x.tr}${x.en}', isNot(contains('[[canli:')), reason: '§${x.no}');
      }
      for (final e in kYzTeknolojiMetinleri.entries) {
        expect('${e.value.tr}${e.value.en}', isNot(contains('[[canli:')), reason: 'teknoloji sayfasına konmaz: ${e.key}');
      }
    });

    test('Dart\'taki pencere kümesi doğrulayıcının CANLI_PENCERELER kümesiyle aynı', () {
      final py = File('content/yapay_zeka_dijital_tarim/_raw/dogrula_bolumler.py').readAsStringSync();
      final m = RegExp(r'^CANLI_PENCERELER = \{([^}]*)\}', multiLine: true).firstMatch(py)!;
      final kume = {for (final x in RegExp(r'"([a-z0-9-]+)"').allMatches(m.group(1)!)) x.group(1)!};
      expect(kume, kYzCanliPencereler);
    });

    test('okuma süresi, okuma izi ve arama yönergeyi saymıyor', () {
      for (final en in [false, true]) {
        final md = kYzMetinler[19]!.metin(en);
        final yalin = md.replaceAll('$_yonerge\n\n', '');
        expect(yalin, isNot(contains('[[canli:')));
        expect(yzKelimeSayisi(md), yzKelimeSayisi(yalin));
        expect(kYzKelimeSayilari[19]![en ? 1 : 0], yzKelimeSayisi(md), reason: 'üretilen sayı (dart_uret.py)');
        expect(YzMetinHaritasi.kur(md, en).toplam, yzKelimeSayisi(md));
        for (final sorgu in ['uzaydan', 'canli', 'bugun', 'uydu']) {
          final k = yzAramaKelimeleri(sorgu, en);
          expect(yzAramaSay(md, k, en), yzAramaSay(yalin, k, en), reason: '$sorgu ($en)');
        }
        expect(yzAramaSay(md, yzAramaKelimeleri('uzaydan', en), en), 0);
      }
    });

    for (final dil in ['tr', 'en']) {
      testWidgets('§19 çiziminde pencere görsel kartının hemen altında, blok başına bir çocuk · $dil', (t) async {
        final g = _Gibs();
        YzUzaydanBugun.saglayici = g.saglayici;
        YzUzaydanBugun.saat = _simdi;
        addTearDown(() {
          YzUzaydanBugun.saglayici = (u) => NetworkImage(u.toString());
          YzUzaydanBugun.saat = DateTime.now;
        });
        await _boyut(t, const Size(1280, 900));
        final md = kYzMetinler[19]!.metin(dil == 'en');
        await t.pumpWidget(_uygulama(
            _sutunda(YzMetinGorunumu(metin: md, en: dil == 'en', bolumNo: 19), const Size(1280, 900)),
            dil: dil));
        await t.pump();
        await t.pump();
        expect(find.byType(YzUzaydanBugun), findsOneWidget);
        final kolon = t.widget<Column>(find
            .descendant(of: find.byType(YzMetinGorunumu), matching: find.byType(Column))
            .first);
        expect(kolon.children.length, yzAyristir(md).length);
        final ilke = find.byWidgetPredicate(
            (w) => w is YzGorselKarti && w.gorsel.kimlik == 'b19-uydunun-bitki-ortusunu-olcme-ilkesi');
        expect(ilke, findsOneWidget);
        final arasi = t.getRect(find.byType(YzUzaydanBugun)).top - t.getRect(ilke).bottom;
        expect(arasi, inInclusiveRange(0, 1), reason: 'hemen ardında');
        expect(t.takeException(), isNull);
      });
    }
  });
}
