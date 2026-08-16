import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tarim_app/core/router/app_router.dart';
import 'package:tarim_app/features/dossiers/data/models/country_dossier.dart';
import 'package:tarim_app/features/dossiers/presentation/screens/country_dossier_screen.dart';
import 'package:tarim_app/features/dossiers/presentation/screens/dossier_index_screen.dart';
import 'package:tarim_app/features/dossiers/providers/dossier_providers.dart';

import 'support/dossier_fixture.dart';

Widget _sarmala(
  List<DossierSummary> liste, {
  required bool isEn,
}) {
  return _iskelet(
    isEn: isEn,
    override: dossierIndexProvider.overrideWith((ref) async => liste),
  );
}

/// Hata dönen istek — boş listeyle AYNI metni vermemeli.
Widget _sarmalaHatali({required bool isEn}) {
  return _iskelet(
    isEn: isEn,
    override: dossierIndexProvider.overrideWith(
      (ref) async => throw StateError('ağ yok'),
    ),
  );
}

/// Hiç tamamlanmayan istek.
Widget _sarmalaBekleyen() {
  return _iskelet(
    isEn: false,
    override: dossierIndexProvider
        .overrideWith((ref) => Completer<List<DossierSummary>>().future),
  );
}

/// Her kurulum taze bir [ProviderScope] alıyor.
///
/// Anahtar olmasaydı aynı test içinde ikinci kez `pumpWidget` çağırmak
/// kapsamı yerinde günceller ve önceden çözülmüş sağlayıcı eski değerini
/// korurdu — "boş liste ile hata aynı metni vermiyor" gibi iki hâli yan yana
/// koyan testler sessizce ilk hâli ölçerdi.
int _kapsamSayaci = 0;

Widget _iskelet({required bool isEn, required Override override}) {
  return ProviderScope(
    key: ValueKey('kapsam-${_kapsamSayaci++}'),
    overrides: [override],
    child: MaterialApp(
      locale: Locale(isEn ? 'en' : 'tr'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('tr'), Locale('en')],
      home: const DossierIndexScreen(),
    ),
  );
}

Future<void> _coz(WidgetTester tester) async {
  await tester.pump();
  await tester.pump();
}

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  final ozet = DossierFixture.hollanda().summary;

  group('rota adresleri', () {
    // Adres, dosyanın yirmi sekiz gün boyunca paylaşılacak kimliği. Burada
    // kırılırsa paylaşılmış her bağlantı ana sayfaya düşer.
    test('ülke dosyası /ulke/<slug> adresine bağlanıyor', () {
      final rota = routeFor(const CountryDossierScreen(slug: 'hollanda'));
      expect(rota?.path, '/ulke/hollanda');
      expect(countryPath('hollanda'), '/ulke/hollanda');
    });

    test('arşiv /ulkeler adresine bağlanıyor', () {
      expect(routeFor(const DossierIndexScreen())?.path, '/ulkeler');
      expect(dossierIndexPath, '/ulkeler');
    });

    test('adresler ASCII — yüzde kodlaması üretmiyor', () {
      // '/ülke/' yazan bir adres mesajlaşma uygulamalarında
      // '/%C3%BClke/' oluyor ve okunmuyor.
      expect(Uri.encodeFull(countryPath('hollanda')), countryPath('hollanda'));
      expect(Uri.encodeFull(dossierIndexPath), dossierIndexPath);
    });
  });

  group('is_active çözümlemesi', () {
    // Arşiv görünümü bu alanı taşıyor, aktif dosya görünümü taşımıyor. İki
    // görünüm aynı modele akıyor; eksik alanın sessizce `true` olması bütün
    // arşivi "şimdi" diye işaretlerdi.
    test('alan yoksa false', () {
      expect(DossierSummary.fromJson(const {'slug': 'x'}).isActive, isFalse);
    });

    test('yalnızca gerçek true işaretliyor', () {
      for (final ham in [true, 'true']) {
        expect(
          DossierSummary.fromJson({'slug': 'x', 'is_active': ham}).isActive,
          ham == true,
          reason: 'is_active=$ham yanlış çözüldü',
        );
      }
      expect(
        DossierSummary.fromJson(const {'slug': 'x', 'is_active': false})
            .isActive,
        isFalse,
      );
    });
  });

  group('arşiv boşken', () {
    testWidgets('boş liste ile hata AYNI metni vermiyor', (tester) async {
      // Şeritte ikisini birleştirmek doğruydu (davranış "hiç çizme"), burada
      // değil: okur bu sayfaya bilerek geldi.
      await tester.pumpWidget(_sarmala(const [], isEn: false));
      await _coz(tester);
      expect(find.text('Henüz yayımlanmış bir dosya yok.'), findsOneWidget);

      await tester.pumpWidget(_sarmalaHatali(isEn: false));
      await _coz(tester);
      expect(find.text('Arşiv yüklenemedi.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('yüklenirken sayfa ayakta kalıyor', (tester) async {
      await tester.pumpWidget(_sarmalaBekleyen());
      await _coz(tester);

      // Başlık çubuğu bekleme sırasında da duruyor: geri düğmesi olmayan bir
      // yükleme ekranı, yavaş bağlantıda okuru sayfada kilitler.
      expect(find.text('Ülke dosyaları'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  for (final genislik in [360.0, 768.0, 1200.0]) {
    for (final isEn in [false, true]) {
      testWidgets(
          'arşiv ${genislik.toInt()}px ${isEn ? 'en' : 'tr'} '
          'taşmadan çiziliyor', (tester) async {
        tester.view.physicalSize = Size(genislik, 1400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(_sarmala([ozet], isEn: isEn));
        await _coz(tester);

        expect(tester.takeException(), isNull);
        expect(find.text(ozet.name(isEn)), findsOneWidget);
        expect(find.text(ozet.thesis(isEn)), findsOneWidget);
      });
    }
  }

  testWidgets('yayındaki dosya kelimeyle işaretleniyor', (tester) async {
    // Renk tek başına taşımıyor: rozet aynı zamanda kelime. Renkle işaretlemek
    // renk körlüğünde kaybolurdu — dizinin Faz 3'ten beri geçerli kuralı.
    tester.view.physicalSize = const Size(500, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_sarmala([_aktif(ozet, true)], isEn: false));
    await _coz(tester);
    expect(find.text('ŞİMDİ'), findsOneWidget);

    await tester.pumpWidget(_sarmala([_aktif(ozet, false)], isEn: false));
    await _coz(tester);
    expect(find.text('ŞİMDİ'), findsNothing);

    await tester.pumpWidget(_sarmala([_aktif(ozet, true)], isEn: true));
    await _coz(tester);
    expect(find.text('NOW'), findsOneWidget);
  });

  testWidgets('her kart tek dokunma hedefi', (tester) async {
    tester.view.physicalSize = const Size(500, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _sarmala([ozet, _aktif(ozet, true)], isEn: false),
    );
    await _coz(tester);

    // Bulucu listeye daraltılıyor: AppBar'ın geri düğmesi de bir InkWell ve
    // sayılsaydı test kart sayısını değil düğme sayısını ölçerdi.
    expect(
      find.descendant(
        of: find.byType(SingleChildScrollView),
        matching: find.byType(InkWell),
      ),
      findsNWidgets(2),
    );
  });

  testWidgets('İngilizce arşivde Türkçe metin kalmıyor', (tester) async {
    tester.view.physicalSize = const Size(500, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_sarmala([ozet], isEn: true));
    await _coz(tester);

    expect(find.text('Country dossiers'), findsOneWidget);
    expect(find.text('1 dossier in the archive'), findsOneWidget);
    expect(find.textContaining('bölüm'), findsNothing);
    expect(find.textContaining('Arşivde'), findsNothing);
  });

  testWidgets('sayım tekil/çoğul ayrımı yapıyor', (tester) async {
    tester.view.physicalSize = const Size(500, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_sarmala([ozet, _aktif(ozet, true)], isEn: true));
    await _coz(tester);

    expect(find.text('2 dossiers in the archive'), findsOneWidget);
  });
}

/// [ozet]'in yayın işareti değiştirilmiş kopyası.
DossierSummary _aktif(DossierSummary ozet, bool aktif) {
  return DossierSummary(
    slug: ozet.slug,
    nameTr: ozet.nameTr,
    nameEn: ozet.nameEn,
    iso3: ozet.iso3,
    edition: ozet.edition,
    thesisTr: ozet.thesisTr,
    thesisEn: ozet.thesisEn,
    theme: ozet.theme,
    coverUrl: ozet.coverUrl,
    daysRemaining: ozet.daysRemaining,
    sectionCount: ozet.sectionCount,
    isActive: aktif,
  );
}
