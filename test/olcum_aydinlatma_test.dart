import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:tarim_app/features/legal/data/legal_documents.dart';
import 'package:tarim_app/features/legal/presentation/screens/legal_page_screen.dart';

/// Madde 25 (3): gizlilik ve çerez metni ölçümü dürüstçe anlatıyor.
void main() {
  String metin(String slug, {bool en = false}) =>
      legalDocs[slug]!.blocks.map((b) => b.text(en)).join(' ');

  group('ölçüm aydınlatması', () {
    test('ölçülenler ve gönderilmeyenler yazıyor', () {
      final g = metin('gizlilik');
      expect(g, contains('Google Analytics'));
      expect(g, contains('görüntülenen sayfalar'));
      expect(g, contains('dörtte bir'));
      expect(g, contains('cihaz türü'));
      expect(g, contains('yazı boyu'));
      expect(g, contains('arama kutusuna yazdığınız sözcükler'));
      expect(g, contains('alt başlıkların adları gönderilmez'));
      expect(g, contains('Kaldığınız yer'));
      expect(g, contains('kendi tarayıcınızda'));
      // Eski, artık doğru olmayan cümleler kalmadı.
      expect(g, isNot(contains('sunucularımıza gönderilmez')));
      expect(g, isNot(contains('kişiye bağlanmaz')));
    });

    test('çerez politikası ölçüm çerezlerini adlarıyla anıyor', () {
      final c = metin('cerezler');
      expect(c, contains('_ga'));
      expect(c, contains('Google Analytics'));
      expect(c, isNot(contains('izleme çerezi kullanılmıyor')));
      expect(metin('cerezler', en: true), contains('Measurement Cookies'));
    });

    test('doğrulanmamış süre yazılmıyor', () {
      for (final slug in ['gizlilik', 'cerezler']) {
        for (final en in [false, true]) {
          expect(metin(slug, en: en), isNot(contains('400')), reason: slug);
          expect(metin(slug, en: en), isNot(contains('14 ay')), reason: slug);
          expect(metin(slug, en: en), isNot(contains('14 months')), reason: slug);
        }
      }
    });
  });

  group('sayfa taşmıyor', () {
    setUpAll(() async {
      GoogleFonts.config.allowRuntimeFetching = false;
      await initializeDateFormatting('tr_TR');
      await initializeDateFormatting('en_US');
    });

    for (final boyut in const [Size(375, 812), Size(1280, 900)]) {
      for (final slug in ['gizlilik', 'cerezler']) {
        for (final dil in const [Locale('tr'), Locale('en')]) {
          testWidgets('$slug ${dil.languageCode} ${boyut.width.toInt()}', (tester) async {
            tester.view.physicalSize = boyut;
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.reset);
            await tester.pumpWidget(MaterialApp(
              locale: dil,
              supportedLocales: const [Locale('tr'), Locale('en')],
              localizationsDelegates: GlobalMaterialLocalizations.delegates,
              home: LegalPageScreen(doc: legalDocs[slug]!),
            ));
            await tester.pump(const Duration(milliseconds: 500));
            final hatalar = <Object>[];
            Object? h;
            while ((h = tester.takeException()) != null) {
              hatalar.add(h!);
            }
            expect(hatalar.where((e) => '$e'.contains('overflowed')), isEmpty);
            // Sonuna kadar kaydır: bütün bloklar çizilsin.
            final kaydirilabilir = find.byType(Scrollable).first;
            await tester.drag(kaydirilabilir, const Offset(0, -20000));
            await tester.pump(const Duration(milliseconds: 500));
            while ((h = tester.takeException()) != null) {
              hatalar.add(h!);
            }
            expect(hatalar.where((e) => '$e'.contains('overflowed')), isEmpty);
          });
        }
      }
    }
  });
}
