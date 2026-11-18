import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tarim_app/features/yapay_zeka/data/yz_deposu.dart';
import 'package:tarim_app/features/yapay_zeka/data/yz_grafikler.g.dart';
import 'package:tarim_app/features/yapay_zeka/data/yz_iskelet.g.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_baslik_ekrani.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_gorsel.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_merkez_ekrani.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_parcalar.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_tasarim.dart';
import 'package:tarim_app/features/yapay_zeka/yz_providers.dart';

// ══════════════════════════════════════════════════════════════════════════
//  Kullanıcı istekleri (18 Kasım 2026, canlıda görüldükten sonra):
//  1. seçili teknolojinin "alanlar arası durum" kartı yumuşak (koyu dolgu yok)
//  2. görselin uzun künyesi ve kaynağı okur isterse açılıyor
//  3. merkez sayfanın girişinde "Her rakamın niteliği…" cümlesi yok
//  4. telefonda merkez sayfada "Bölümde ara" kutusu yok
// ══════════════════════════════════════════════════════════════════════════

Widget _uygulama(Widget cocuk, {String dil = 'tr'}) => ProviderScope(
      overrides: [
        yzBolumHaberleriProvider.overrideWith((ref, no) async => const <YzHaber>[]),
        yzDizinEklenenlerProvider.overrideWith((ref) async => const <YzDizinKaydi>[]),
      ],
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

void _boyut(WidgetTester t, Size s) {
  t.view.physicalSize = s;
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
}

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('1 · teknoloji sayfası kartı koyu dolgulu değil, yazısı beyaz değil', (t) async {
    _boyut(t, const Size(1280, 900));
    await t.pumpWidget(_uygulama(const YzMerkezEkrani()));
    await t.pumpAndSettle();
    final ad = kYzTeknoloji['goruntu']!['tr']!;
    final cip = find.text(ad).first;
    await t.ensureVisible(cip);
    await t.tap(cip);
    await t.pumpAndSettle();
    final kart = find.text('$ad: alanlar arası durum');
    expect(kart, findsOneWidget);
    final malzeme = t.widget<Material>(find.ancestor(of: kart, matching: find.byType(Material)).first);
    expect(malzeme.color, isNot(YzRenk.makine), reason: 'koyu çelik mavisi dolgu "çok kaba" bulundu');
    expect(t.widget<Text>(kart).style?.color, isNot(Colors.white));
  });

  group('2 · uzun görsel altyazısı', () {
    final uzun = kYzGorseller.values.firstWhere((g) => g.kunye(false).length > 300);
    final kisa = kYzGorseller.values.firstWhere((g) => g.kunye(false).length < 60,
        orElse: () => kYzGorseller.values.reduce((a, b) => a.kunye(false).length < b.kunye(false).length ? a : b));

    for (final boy in const [Size(375, 812), Size(1280, 900)]) {
      testWidgets('kapalı gelir, açılır, kapanır · ${boy.width.toInt()} px', (t) async {
        _boyut(t, boy);
        // Makalenin metin sütunu: telefonda ekran − 32, masaüstünde 610 px.
        final w = boy.width < 640 ? boy.width - 32 : 610.0;
        await t.pumpWidget(_uygulama(Scaffold(
            body: SingleChildScrollView(
                child: Center(child: SizedBox(width: w, child: YzGorselKarti(gorsel: uzun, en: false)))))));
        await t.pump();
        final kunye = find.text(uzun.kunye(false));
        expect(t.widget<Text>(kunye).maxLines, 2);
        expect(find.text('Devamını oku'), findsOneWidget);
        await t.tap(find.text('Devamını oku'));
        await t.pump();
        expect(t.widget<Text>(kunye).maxLines, isNull, reason: 'açıkken tamamı');
        expect(find.text('Daha az göster'), findsOneWidget);
        await t.tap(find.text('Daha az göster'));
        await t.pump();
        expect(t.widget<Text>(kunye).maxLines, 2);
      });
    }

    testWidgets('sığan altyazıda düğme yok', (t) async {
      _boyut(t, const Size(1280, 900));
      await t.pumpWidget(_uygulama(Scaffold(
          body: SingleChildScrollView(child: YzGorselKarti(gorsel: kisa, en: false)))));
      await t.pump();
      if (kisa.kunye(false).length < 60 && kisa.kaynak(false).length < 60) {
        expect(find.text('Devamını oku'), findsNothing);
      }
    });
  });

  test('3 · merkez sayfa girişinde kaldırılan cümle yok (TR ve EN)', () {
    final s = File('lib/features/yapay_zeka/presentation/yz_merkez_ekrani.dart').readAsStringSync();
    expect(s, isNot(contains('satıcı beyanı, satıcı beyanı olarak')));
    expect(s, isNot(contains('a vendor claim is labelled as a vendor claim')));
    expect(s, contains('bir başvuru dosyası.'));
  });

  group('4 · merkez sayfada arama kutusu', () {
    testWidgets('telefonda yok', (t) async {
      _boyut(t, const Size(375, 812));
      await t.pumpWidget(_uygulama(const YzMerkezEkrani()));
      await t.pumpAndSettle();
      expect(find.byType(YzAramaKutusu), findsNothing);
      expect(find.byIcon(Icons.search_rounded), findsOneWidget, reason: 'arama üst şeritte duruyor');
    });

    testWidgets('masaüstünde duruyor', (t) async {
      _boyut(t, const Size(1280, 900));
      await t.pumpWidget(_uygulama(const YzMerkezEkrani()));
      await t.pumpAndSettle();
      expect(find.byType(YzAramaKutusu), findsOneWidget);
    });
  });

  // Kullanıcı (18 Kas 2026): "punto büyütüp küçültme ikonu çalışmıyor".
  // Merkez sayfada ve aramada düğme vardı ama yazı ölçeği dinlemiyordu.
  group('yazı boyu düğmesi her sayfada çalışıyor', () {
    double? cizilen(WidgetTester t, String parca) {
      for (final e in find.byType(EditableText).evaluate()) {
        final w = e.widget as EditableText;
        if (w.controller.text.contains(parca)) return (w.textScaler ?? TextScaler.noScaling).scale(w.style.fontSize!);
      }
      for (final e in find.byWidgetPredicate((w) => w is RichText && w.text.toPlainText().contains(parca)).evaluate()) {
        final r = e.widget as RichText;
        final boy = r.text.style?.fontSize ??
            (r.text as TextSpan).children!.whereType<TextSpan>().first.style!.fontSize!;
        return r.textScaler.scale(boy);
      }
      return null;
    }

    for (final (ad, ekran, parca) in [
      ('başlık', const YzBaslikEkrani(slug: 'toprak-ve-arazi') as Widget, 'Toprağı her metrede'),
      ('merkez', const YzMerkezEkrani() as Widget, 'Yapay zekâ ve dijital teknolojiler'),
    ]) {
      testWidgets('A+ iki kez: yazı %125 · $ad', (t) async {
        _boyut(t, const Size(1280, 900));
        await t.pumpWidget(_uygulama(ekran));
        await t.pumpAndSettle();
        final once = cizilen(t, parca)!;
        await t.tap(find.byIcon(Icons.format_size_rounded));
        await t.pumpAndSettle();
        await t.tap(find.byTooltip('Büyüt'));
        await t.pumpAndSettle();
        await t.tap(find.byTooltip('Büyüt'));
        await t.pumpAndSettle();
        expect(cizilen(t, parca), closeTo(once * 1.25, 0.01));
      });
    }

    for (final boy in const [Size(375, 812), Size(1280, 900)]) {
      testWidgets('merkez sayfa en büyük yazıda taşmıyor · ${boy.width.toInt()} px', (t) async {
        _boyut(t, boy);
        SharedPreferences.setMockInitialValues({'yz_yazi_olcegi': 1.4});
        await t.pumpWidget(_uygulama(const YzMerkezEkrani()));
        await t.pumpAndSettle();
        expect(t.takeException(), isNull);
      });
    }
  });

  test('ısı haritası başlığı ve vurgu cümlesi; güncelleme bölümü yok', () {
    final s = File('lib/features/yapay_zeka/presentation/yz_merkez_ekrani.dart').readAsStringSync();
    expect(s, contains("'Teknoloji ve Alan Isı Haritası'"));
    expect(s, contains("'Tarımda Yapay Zeka kullanımının nabzını buradan takip edin.'"));
    expect(s, contains("'Her hücre, bir teknolojinin bir başlıkta geçtiği yer sayısı."));
    expect(s, isNot(contains("'Bu dosya nasıl güncel tutuluyor'")));
    expect(s, isNot(contains('editör ajanı')));
  });
}
