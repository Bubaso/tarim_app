import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tarim_app/features/yapay_zeka/data/yz_deposu.dart';
import 'package:tarim_app/features/yapay_zeka/data/yz_iskelet.g.dart';
import 'package:tarim_app/features/yapay_zeka/data/yz_kaynak_karnesi.g.dart';
import 'package:tarim_app/features/yapay_zeka/data/yz_rakam_kaynaklari.g.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_atlas_veri.dart' show yzAtlasHaberleriProvider;
import 'package:tarim_app/features/yapay_zeka/presentation/yz_baslik_ekrani.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_kaynak_balonu.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_kesit.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_merkez_ekrani.dart';
import 'package:tarim_app/features/yapay_zeka/presentation/yz_parcalar.dart'
    show YzBaslikKarosu, YzHarita, YzKaroBicimi, YzTeknolojiCipi;
import 'package:tarim_app/features/yapay_zeka/presentation/yz_metin_gorunumu.dart' show YzMetinGorunumu, yzSatirIci;
import 'package:tarim_app/features/yapay_zeka/presentation/yz_sozluk_esle.dart' show YzEtkilesim;
import 'package:tarim_app/features/yapay_zeka/yz_providers.dart';

// ══════════════════════════════════════════════════════════════════════════
//  Mizansen turu (kullanıcı, 28 Kasım 2026) — metne dokunmadan anlaşılırlık
// ──────────────────────────────────────────────────────────────────────────
//  Merkez: teknoloji çipleri kendi bandında; grupların düzeni (Çerçeve büyük,
//  takvim oklu sıra, Eleştirel bakış ayrı ton, başvuru kısa satır); telefonda
//  her grup yana kaydırılan sıra. Okuma sayfası: ortak iskeletin kesit
//  simgeleri, Türkiye kesiti beyaz bantta, mavi rakamın ardında kaynağının
//  türünü gösteren nokta, metnin üstünde ipucu ve içindekiler kutusu yok.
// ══════════════════════════════════════════════════════════════════════════

List<Override> get _sahte => [
      yzBolumHaberleriProvider.overrideWith((ref, no) async => const <YzHaber>[]),
      yzDizinEklenenlerProvider.overrideWith((ref) async => const <YzDizinKaydi>[]),
      yzAtlasHaberleriProvider.overrideWith((ref) async => const <YzHaber>[]),
    ];

Widget _uygulama(Widget cocuk) => ProviderScope(
      overrides: _sahte,
      child: MaterialApp(
        locale: const Locale('tr'),
        supportedLocales: const [Locale('tr'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: cocuk,
      ),
    );

void _boyut(WidgetTester t, double g, double y) {
  t.view.physicalSize = Size(g, y);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
}

void _ipucuGoruldu() => SharedPreferences.setMockInitialValues({'yz_ipucu_goruldu': true});

YzKaroBicimi _bicim(WidgetTester t, String ad) =>
    t.widget<YzBaslikKarosu>(find.widgetWithText(YzBaslikKarosu, ad)).bicim;

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('kesit türü', () {
    test('ortak iskeletin dört kesiti, birebir başlık adıyla', () {
      expect(yzKesitTuru('Ne yapıyor'), YzKesitTuru.ne);
      expect(yzKesitTuru('Saha denemeleri ne diyor'), YzKesitTuru.saha);
      expect(yzKesitTuru('Where AI stands'), YzKesitTuru.yz);
      expect(yzKesitTuru('Türkiye'), YzKesitTuru.turkiye);
      // Başlık ADI ya da ülke kesiti değil.
      expect(yzKesitTuru("Türkiye'de durum"), isNull);
      expect(yzKesitTuru('Çin: devlet planı ve makine ölçeği'), isNull);
    });
  });

  group('rakamın kaynak türü', () {
    test('her rakamın türü kayıttaki kaynaklardan, 0-3', () {
      var sayi = 0;
      for (final e in kYzRakamKaynak.entries) {
        final sayfa = e.key.split(':').first;
        final en = e.key.endsWith(':en');
        for (final kalin in e.value.keys) {
          final turler = yzRakamTurleri(sayfa, kalin, en);
          expect(turler.every((x) => x >= 0 && x <= 3), isTrue);
          expect(turler.toSet().length, turler.length, reason: 'tekrarsız');
          if (turler.isNotEmpty) sayi++;
        }
      }
      expect(sayi, greaterThan(1000), reason: 'rakamların çoğunun türü biliniyor');
      expect(kYzKaynakTuru.length, kYzKaynakKarnesi.length);
    });
  });

  group('rakamın ardındaki nokta', () {
    test('kelimenin sonunda: Türkçe ek rakamdan ayrılmıyor', () {
      final et = YzEtkilesim(
        tanicilar: [],
        baglantiAc: (_) {},
        terimAc: (_, __) {},
        rakamVar: (_) => true,
        rakamTuru: (_) => const [0],
      );
      String duz(String md) => yzSatirIci(md, const TextStyle(fontSize: 18), etkilesim: et).toPlainText();
      final a = duz("tatlı suyun **%72**'sini kullanıyor");
      expect(a.indexOf('\uFFFC'), a.indexOf("'sini") + "'sini".length);
      // Rakam birimine bölünmez boşlukla bağlı: nokta grubun sonunda, satır
      // rakamla birimin arasında kırılmıyor.
      final b = duz('**1,2** milyar hektar, **%38** tasarruf.');
      expect(b.indexOf('\uFFFC'), b.indexOf('milyar') + 'milyar'.length);
      expect(b.lastIndexOf('\uFFFC'), b.indexOf('%38') + 3);
      // Öne çıkan cümlede nokta yok.
      expect(yzSatirIci('**%38**', const TextStyle(), etkilesim: et, turNoktasi: false).toPlainText(), '%38');
    });
  });

  group('merkez · masaüstü 1280', () {
    testWidgets('teknoloji bandı, grup biçimleri, takvimde oklar', (t) async {
      _boyut(t, 1280, 900);
      await t.pumpWidget(_uygulama(const YzMerkezEkrani()));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      final bant = find.byKey(const ValueKey('yz-teknoloji-bandi'));
      expect(bant, findsOneWidget);
      expect(find.descendant(of: bant, matching: find.byType(YzTeknolojiCipi)), findsNWidgets(9));
      expect(find.descendant(of: bant, matching: find.textContaining('Bir teknoloji seçin')), findsOneWidget);
      expect(find.text('Topraktan pazara, tarım yılının sırasıyla.'), findsOneWidget);

      expect(_bicim(t, 'Bugün nerede duruyoruz'), YzKaroBicimi.buyuk);
      expect(_bicim(t, 'Toprak ve arazi'), YzKaroBicimi.olagan);
      expect(_bicim(t, 'Riskler ve sınırlar'), YzKaroBicimi.elestiri);
      expect(_bicim(t, 'Kaynakça'), YzKaroBicimi.kompakt);
      // Kaynakça ve sözlükte okuma süresi yok.
      final kaynakca = find.widgetWithText(YzBaslikKarosu, 'Kaynakça');
      expect(find.descendant(of: kaynakca, matching: find.textContaining('dk okuma')), findsNothing);

      // Takvimin sekiz başlığı arasında yedi ok.
      // Satırın sonundaki ok da (sıra alt satırda sürüyor): 4 + 3.
      expect(find.descendant(of: find.byType(YzHarita), matching: find.byIcon(Icons.arrow_forward_rounded)),
          findsNWidgets(7));
      // Aynı satırdaki karolar eşit boyda.
      final toprak = t.getRect(find.widgetWithText(YzBaslikKarosu, 'Toprak ve arazi'));
      final sulama = t.getRect(find.widgetWithText(YzBaslikKarosu, 'Sulama ve su yönetimi'));
      expect(toprak.top, sulama.top);
      expect(toprak.height, sulama.height);
    });

    testWidgets('çipin üstüne gelmek seçimi önizliyor, seçmiyor', (t) async {
      _boyut(t, 1280, 900);
      await t.pumpWidget(_uygulama(const YzMerkezEkrani()));
      await t.pumpAndSettle();
      final cip = find.widgetWithText(YzTeknolojiCipi, 'Dil modelleri');
      final fare = await t.createGesture(kind: PointerDeviceKind.mouse);
      addTearDown(fare.removePointer);
      await fare.addPointer(location: Offset.zero);
      await fare.moveTo(t.getCenter(cip));
      await t.pumpAndSettle();
      final sonuk = find.byWidgetPredicate((w) => w is YzBaslikKarosu && w.sonuk);
      expect(sonuk, findsWidgets, reason: 'önizleme');
      expect(t.widget<YzTeknolojiCipi>(cip).secili, isFalse);
      await fare.moveTo(Offset.zero);
      await t.pumpAndSettle();
      expect(sonuk, findsNothing, reason: 'fare çıkınca önizleme kalkıyor');
    });
  });

  group('merkez · ara genişlikler taşmıyor', () {
    for (final g in const [640.0, 700.0, 800.0, 900.0, 1000.0, 1100.0, 1280.0, 1600.0]) {
      testWidgets('${g.toInt()} piksel', (t) async {
        _boyut(t, g, 900);
        await t.pumpWidget(_uygulama(const YzMerkezEkrani()));
        await t.pumpAndSettle();
        expect(t.takeException(), isNull);
        expect(find.byType(YzBaslikKarosu), findsNWidgets(kYzBasliklar.length));
      });
    }
  });

  group('okuma sayfası · ara genişlikler taşmıyor', () {
    for (final g in const [375.0, 700.0, 900.0, 1280.0]) {
      testWidgets('sulama-ve-su · ${g.toInt()} piksel', (t) async {
        _boyut(t, g, 900);
        await t.pumpWidget(_uygulama(const YzBaslikEkrani(slug: 'sulama-ve-su')));
        await t.pumpAndSettle();
        expect(t.takeException(), isNull);
      });
    }
  });

  group('merkez · telefon 375', () {
    testWidgets('her grup yana kaydırılan sıra; başvuru alt alta', (t) async {
      _boyut(t, 375, 812);
      await t.pumpWidget(_uygulama(const YzMerkezEkrani()));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      expect(find.byType(YzBaslikKarosu), findsNWidgets(kYzBasliklar.length));
      Finder yatay(String ad) => find.ancestor(
            of: find.widgetWithText(YzBaslikKarosu, ad),
            matching: find.byWidgetPredicate((w) => w is SingleChildScrollView && w.scrollDirection == Axis.horizontal),
          );
      expect(yatay('Toprak ve arazi'), findsOneWidget);
      expect(yatay('Hayvancılık'), findsOneWidget);
      expect(yatay('Kaynakça'), findsNothing);
      // Telefonda karoda özet yok.
      final b = kYzBasliklar.firstWhere((x) => x.slug == 'toprak-ve-arazi');
      expect(find.text(b.ozet(false)), findsNothing);
    });
  });

  group('okuma sayfası', () {
    testWidgets('kesit simgeleri, Türkiye bandı, rakamın ardında nokta · 1280', (t) async {
      _boyut(t, 1280, 900);
      _ipucuGoruldu();
      await t.pumpWidget(_uygulama(const YzBaslikEkrani(slug: 'sulama-ve-su')));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      // Metinde her kesit başlığının simgesi var (içindekiler rayında da).
      expect(find.byType(YzKesitSimgesi), findsWidgets);
      final turkiye = find.byWidgetPredicate((w) => w is YzKesitSimgesi && w.tur == YzKesitTuru.turkiye);
      expect(turkiye, findsWidgets);
      // Türkiye kesiti beyaz, yuvarlak köşeli bantta.
      final bant = find.byWidgetPredicate((w) =>
          w is Container &&
          w.decoration is BoxDecoration &&
          (w.decoration as BoxDecoration).color == const Color(0xFFFFFFFF) &&
          (w.decoration as BoxDecoration).borderRadius == const BorderRadius.vertical(top: Radius.circular(12)));
      expect(find.descendant(of: bant, matching: turkiye), findsOneWidget, reason: 'bandın ilk parçası Türkiye başlığı');
      // Rakamın ardında tür noktası (yuvarlak, karne renginde).
      final nokta = find.descendant(
        of: find.byType(YzMetinGorunumu),
        matching: find.byWidgetPredicate((w) =>
            w is Container && w.decoration is BoxDecoration && (w.decoration as BoxDecoration).shape == BoxShape.circle),
      );
      expect(nokta, findsWidgets);
    });

    testWidgets('ipucu metnin üstünde değil, altta yüzüyor; ilk rakam yanıp sönüyor · 1280', (t) async {
      _boyut(t, 1280, 900);
      await t.pumpWidget(_uygulama(const YzBaslikEkrani(slug: 'sulama-ve-su')));
      await t.pump();
      // Gecikme içinde kart görünmüyor.
      await t.pump(const Duration(milliseconds: 300));
      final anladim = find.text('Anladım');
      expect(anladim, findsOneWidget);
      // Kaydırılan içerikte değil.
      expect(find.descendant(of: find.byType(SingleChildScrollView).first, matching: anladim), findsNothing);
      await t.pumpAndSettle();
      await t.tap(anladim);
      await t.pumpAndSettle();
      expect(anladim, findsNothing);
    });
  });
}
