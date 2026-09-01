import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tarim_app/features/videos/data/models/video_haberi.dart';
import 'package:tarim_app/features/videos/presentation/widgets/video_serit.dart';
import 'package:tarim_app/features/videos/providers/video_providers.dart';

/// Toplayıcının Bakanlık kanalından gerçekten getirdiği iki video.
final _videolar = [
  VideoHaberi(
    id: 1,
    videoId: 'abc12345678',
    url: 'https://www.youtube.com/watch?v=abc12345678',
    baslik: 'Büyükbaş Hayvan Güvenli Elektronik Küpe Takma Programı',
    kanalAdi: 'T.C. TARIM VE ORMAN BAKANLIĞI',
    kanalUrl: 'https://www.youtube.com/channel/UCq0ojLlKO4ssS5cQd5E9yZg',
    yayimTarihi: DateTime.utc(2026, 8, 7),
  ),
  VideoHaberi(
    id: 2,
    videoId: 'def12345678',
    url: 'https://www.youtube.com/watch?v=def12345678',
    baslik: 'Tarla Bitkileri Merkez Araştırma Enstitüsü Müdürlüğümüz',
    kanalAdi: 'TAGEM',
    yayimTarihi: DateTime.utc(2025, 10, 14),
  ),
];

Widget _sarmala(List<VideoHaberi> videolar, {double genislik = 390}) {
  return ProviderScope(
    overrides: [
      yayindakiVideolarProvider.overrideWith((ref) async => videolar),
    ],
    child: MaterialApp(
      locale: const Locale('tr'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('tr'), Locale('en')],
      home: MediaQuery(
        data: MediaQueryData(size: Size(genislik, 900)),
        child: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                VideoSerit(isDark: false, spacing: 28),
                // Künyenin yerini tutuyor: bölüm kaybolduğunda geriye boşluk
                // kalıp kalmadığı ancak altında bir şey varken ölçülebilir.
                const SizedBox(key: ValueKey('kunye'), height: 10),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

Finder _iceren(String parca) => find.byWidgetPredicate(
      (w) => w is Text && (w.data ?? '').contains(parca),
    );

Future<void> _coz(WidgetTester tester) async {
  await tester.pump();
  await tester.pump();
}

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  testWidgets('onaylı video yokken tek piksel bile bırakmıyor', (tester) async {
    // Bölümün en önemli davranışı bu. Onay kuyruğu boş bir günde anasayfanın,
    // künyeden önce açıklanamayan bir boşluğu olmamalı.
    await tester.pumpWidget(_sarmala(const []));
    await _coz(tester);

    expect(find.byType(VideoSerit), findsOneWidget);
    expect(_iceren('VİDEO HABERLER'), findsNothing);
    expect(tester.getSize(find.byType(VideoSerit)).height, 0);
  });

  testWidgets('kartta başlık ve KAYNAK KÜNYESİ birlikte duruyor', (tester) async {
    // Künye pazarlık dışı: kaynağını göstermeyen gömülü video, dosya
    // dizisindeki atıfsız görselin karşılığı olurdu.
    await tester.pumpWidget(_sarmala(_videolar));
    await _coz(tester);

    expect(_iceren('VİDEO HABERLER'), findsOneWidget);
    expect(_iceren('Büyükbaş Hayvan Güvenli'), findsOneWidget);
    expect(_iceren('T.C. TARIM VE ORMAN BAKANLIĞI'), findsOneWidget);
    expect(_iceren('TAGEM'), findsOneWidget);
    expect(_iceren('7 Ağu 2026'), findsOneWidget);
  });

  testWidgets('küçük görsel adresi video kimliğinden türetiliyor', (tester) async {
    // Akış bazen küçük görsel vermiyor; kart o zaman boş kalmamalı.
    const v = VideoHaberi(
      id: 3,
      videoId: 'xyz12345678',
      url: 'https://www.youtube.com/watch?v=xyz12345678',
      baslik: 'Görselsiz video',
      kanalAdi: 'TMO',
    );
    expect(v.gorsel, 'https://i.ytimg.com/vi/xyz12345678/hqdefault.jpg');
  });

  group('taşma', () {
    for (final genislik in [360.0, 768.0, 1200.0]) {
      testWidgets('${genislik.toInt()} px', (tester) async {
        tester.view.physicalSize = Size(genislik, 1000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(_sarmala(_videolar, genislik: genislik));
        await _coz(tester);

        expect(tester.takeException(), isNull);
      });
    }
  });
}
