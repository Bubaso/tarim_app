import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tarim_app/features/yapay_zeka/data/yz_makbuz.g.dart';
import 'package:tarim_app/features/yapay_zeka/data/yz_rakam_kaynaklari.g.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_balon_kabugu.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_gorsel_tam_ekran.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_kaynak_balonu.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_makbuz.dart';

// ══════════════════════════════════════════════════════════════════════════
//  Rakamın makbuzu (25 Kasım 2026): kaynak balonunda "Kaynağında gör · s. N"
//  (kesitli kaynak) ve "Kaynakta aç · s. N" (hakemli); tam ekran kesit.
//  Örnekler veriden seçiliyor: kesit eklenip çıktıkça sınama kırılmasın.
// ══════════════════════════════════════════════════════════════════════════

class _Ornek {
  const _Ornek(this.sayfa, this.kalin, this.kaynak, this.makbuz);
  final String sayfa;
  final String kalin;
  final String kaynak;
  final YzMakbuz? makbuz;

  String get kunye => kYzKaynakKunye[sayfa]![kaynak]![0];
  String get bag => kYzKaynakKunye[sayfa]![kaynak]![1];
}

/// Tek kaynaklı bir kalın rakam: [kosul] o kaynağın makbuzu (yoksa null) ve
/// bağlantısıyla.
_Ornek _ornek(bool en, bool Function(YzMakbuz? m, String bag) kosul) {
  final dil = en ? 'en' : 'tr';
  for (final sd in kYzRakamKaynak.entries) {
    if (!sd.key.endsWith(':$dil')) continue;
    final sayfa = sd.key.substring(0, sd.key.length - dil.length - 1);
    for (final k in sd.value.entries) {
      if (k.value.length != 1) continue;
      final kaynak = k.value.single[0];
      final m = yzMakbuz(sayfa, en, k.key, kaynak);
      if (kosul(m, kYzKaynakKunye[sayfa]![kaynak]![1])) return _Ornek(sayfa, k.key, kaynak, m);
    }
  }
  throw StateError('örnek yok');
}

_Ornek _kesitli(bool en) => _ornek(en, (m, bag) => m?.kesit != null && m!.adres.isNotEmpty && bag.isNotEmpty);
_Ornek _hakemli(bool en) => _ornek(en, (m, bag) => m != null && m.kesit == null && bag.isNotEmpty);
_Ornek _makbuzsuz(bool en) => _ornek(en, (m, bag) => m == null && bag.isNotEmpty);

const _yerellik = [
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

Widget _uygulama(Widget Function(BuildContext c) govde, {String dil = 'tr'}) => MaterialApp(
      locale: Locale(dil),
      supportedLocales: const [Locale('tr'), Locale('en')],
      localizationsDelegates: _yerellik,
      home: Scaffold(body: Builder(builder: govde)),
    );

Widget _balonDugmesi(_Ornek o, bool en, Offset konum) => _uygulama(
    (c) => Center(
          child: TextButton(
            onPressed: () => yzKaynakBalonu(c, o.sayfa, o.kalin, konum, en),
            child: const Text('AÇ'),
          ),
        ),
    dil: en ? 'en' : 'tr');

void _boy(WidgetTester t, Size s) {
  t.view.physicalSize = s;
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
}

Future<void> _ac(WidgetTester t) async {
  await t.tap(find.text('AÇ'));
  await t.pumpAndSettle();
  expect(t.takeException(), isNull);
}

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  group('veri', () {
    test('sıra haritası geçerli; her makbuz bir mavi rakamın kaynağına bağlı', () {
      expect(kYzMakbuzlar, isNotEmpty);
      for (final sd in kYzMakbuzSirasi.entries) {
        for (final k in sd.value.entries) {
          final adaylar = kYzRakamKaynak[sd.key]![k.key]!.map((a) => a[0]).toList();
          for (final e in k.value.entries) {
            expect(adaylar, contains(e.key), reason: '${sd.key} ${k.key}');
            expect(e.value, inInclusiveRange(0, kYzMakbuzlar.length - 1));
          }
        }
      }
    });

    test('kesit dosyaları yerinde; boyları ve adresleri tutarlı', () {
      var kesitli = 0, kesitsiz = 0;
      for (final m in kYzMakbuzlar) {
        expect(m.sayfa, greaterThan(0));
        if (m.kesit != null) {
          kesitli++;
          expect(m.kesit, matches(RegExp(r'^/yz/makbuz/[A-Za-z0-9_.-]+-s\d+-[0-9a-f]{10}\.webp$')));
          expect(m.kesit, contains('-s${m.sayfa}-'));
          expect(File('web${m.kesit}').existsSync(), isTrue, reason: m.kesit);
          expect(m.genislik, greaterThan(0));
          expect(m.yukseklik, greaterThan(0));
        } else {
          kesitsiz++;
          expect(m.genislik, 0);
        }
        if (m.adres.contains('#page=')) expect(m.adres, endsWith('#page=${m.sayfa}'));
      }
      expect(kesitli, greaterThan(100));
      expect(kesitsiz, greaterThan(0), reason: 'hakemli kaynakta yalnız sayfa');
    });
  });

  group('balon', () {
    for (final en in [false, true]) {
      final dil = en ? 'EN' : 'TR';
      testWidgets('$dil telefon: kesitli kaynakta "Kaynağında gör"; görüntüleyici alt sayfanın üstünde', (t) async {
        _boy(t, const Size(375, 812));
        final o = _kesitli(en);
        final m = o.makbuz!;
        await t.pumpWidget(_balonDugmesi(o, en, const Offset(180, 300)));
        await _ac(t);
        final gor = en ? 'See it in the source · p. ${m.sayfa}' : 'Kaynağında gör · s. ${m.sayfa}';
        final eylem = find.widgetWithText(YzBalonEylemi, gor);
        expect(eylem, findsOneWidget);
        expect(t.getSize(eylem), const Size(375 - 40, 48));
        // Kaynak bağlantısı da yerinde (kesitli kaynakta değişmiyor).
        expect(find.widgetWithText(YzBalonEylemi, en ? 'Open the source ↗' : 'Kaynağı aç ↗'), findsOneWidget);
        await t.tap(eylem);
        await t.pumpAndSettle();
        expect(t.takeException(), isNull);
        expect(find.byType(YzMakbuzGorunumu), findsOneWidget);
        expect(find.text(o.kunye), findsWidgets);
        expect(find.text(en ? 'p. ${m.sayfa}' : 's. ${m.sayfa}'), findsOneWidget);
        expect(find.text(en ? 'Open the full document ↗' : 'Belgenin tamamını aç ↗'), findsOneWidget);
        await t.tap(find.byTooltip(en ? 'Close' : 'Kapat'));
        await t.pumpAndSettle();
        expect(find.byType(YzMakbuzGorunumu), findsNothing);
        expect(find.byType(BottomSheet), findsOneWidget, reason: 'okur balona dönüyor');
      });

      testWidgets('$dil masaüstü: kesitli kaynakta bağlantı; Esc görüntüleyiciyi kapatıyor', (t) async {
        _boy(t, const Size(1280, 900));
        final o = _kesitli(en);
        final m = o.makbuz!;
        await t.pumpWidget(_balonDugmesi(o, en, const Offset(400, 300)));
        await _ac(t);
        expect(find.byType(BottomSheet), findsNothing);
        final gor = en ? 'See it in the source · p. ${m.sayfa}' : 'Kaynağında gör · s. ${m.sayfa}';
        await t.tap(find.widgetWithText(TextButton, gor));
        await t.pumpAndSettle();
        expect(t.takeException(), isNull);
        expect(find.byType(YzMakbuzGorunumu), findsOneWidget);
        final zemin = t.widget<Material>(
            find.descendant(of: find.byType(YzMakbuzGorunumu), matching: find.byType(Material)).first);
        expect(zemin.color, kYzTamEkranZemin);
        await t.sendKeyEvent(LogicalKeyboardKey.escape);
        await t.pumpAndSettle();
        expect(find.byType(YzMakbuzGorunumu), findsNothing);
        expect(find.text(gor), findsOneWidget, reason: 'balon açık kalıyor');
      });

      testWidgets('$dil hakemli kaynakta "Kaynakta aç · s. N", kesit yok', (t) async {
        _boy(t, const Size(375, 812));
        final o = _hakemli(en);
        final m = o.makbuz!;
        await t.pumpWidget(_balonDugmesi(o, en, const Offset(180, 300)));
        await _ac(t);
        expect(
            find.widgetWithText(YzBalonEylemi,
                en ? 'Open in the source · p. ${m.sayfa} ↗' : 'Kaynakta aç · s. ${m.sayfa} ↗'),
            findsOneWidget);
        expect(find.text(en ? 'Open the source ↗' : 'Kaynağı aç ↗'), findsNothing);
        expect(find.textContaining(en ? 'See it in the source' : 'Kaynağında gör'), findsNothing);
      });

      testWidgets('$dil makbuzu olmayan kaynakta balon değişmiyor', (t) async {
        _boy(t, const Size(1280, 900));
        final o = _makbuzsuz(en);
        await t.pumpWidget(_balonDugmesi(o, en, const Offset(400, 300)));
        await _ac(t);
        expect(find.text(en ? 'Open the source ↗' : 'Kaynağı aç ↗'), findsOneWidget);
        expect(find.textContaining(en ? 'See it in the source' : 'Kaynağında gör'), findsNothing);
        expect(find.textContaining(en ? 'Open in the source' : 'Kaynakta aç'), findsNothing);
      });
    }
  });

  group('görüntüleyici: taşma yok', () {
    final kesitli = kYzMakbuzlar.where((m) => m.kesit != null).toList();
    // En geniş, en uzun ve en dar kesit; uzun bir künyeyle.
    final ornekler = <YzMakbuz>{
      kesitli.reduce((a, b) => a.genislik >= b.genislik ? a : b),
      kesitli.reduce((a, b) => a.yukseklik / a.genislik >= b.yukseklik / b.genislik ? a : b),
      kesitli.reduce((a, b) => a.genislik <= b.genislik ? a : b),
    };
    final uzunKunye = kYzKaynakKunye.values
        .expand((x) => x.values)
        .map((x) => x[0])
        .reduce((a, b) => a.length >= b.length ? a : b);
    for (final boy in const [Size(375, 812), Size(1280, 900), Size(1440, 900)]) {
      for (final en in [false, true]) {
        testWidgets('${boy.width.toInt()}×${boy.height.toInt()} ${en ? 'EN' : 'TR'}', (t) async {
          _boy(t, boy);
          for (final m in ornekler) {
            await t.pumpWidget(_uygulama((c) => YzMakbuzGorunumu(makbuz: m, kunye: uzunKunye, en: en),
                dil: en ? 'en' : 'tr'));
            await t.pumpAndSettle();
            expect(t.takeException(), isNull, reason: m.kesit);
            final kapat = find.byTooltip(en ? 'Close' : 'Kapat');
            expect(t.getSize(kapat), const Size(48, 48));
            final kesit = find.bySemanticsLabel(RegExp(en ? r'^Excerpt from the source' : r'^Kaynaktan kesit'));
            expect(kesit, findsOneWidget);
            final r = t.getRect(kesit);
            expect(r.left, greaterThanOrEqualTo(0));
            expect(r.right, lessThanOrEqualTo(boy.width));
            expect(r.width / r.height, closeTo(m.genislik / m.yukseklik, 0.02), reason: 'oran korunuyor');
            expect(r.width, lessThanOrEqualTo(m.genislik / 1.5 + 0.5), reason: 'doğal boyundan iri değil');
            final kunye = t.widget<Text>(find.text(uzunKunye));
            expect(kunye.maxLines, 3);
          }
        });
      }
    }
  });
}
