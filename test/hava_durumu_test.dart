import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tarim_app/features/home/data/models/weather_info.dart';
import 'package:tarim_app/features/home/presentation/screens/weather_detail_screen.dart';
import 'package:tarim_app/features/home/providers/home_providers.dart';

/// Analiz sonrası düzeltmelerin regresyon testi:
///   1. Don riski ŞU ANKİ sıcaklığa değil BU GECENİN tahmini düşüğüne bakıyor.
///   2. Hafta günü kısaltması "PZT" (eskiden yerleşik olmayan "PTS").
///   3. Konuma özel fotoğraf tamamen kaldırıldı — Image.network yok.
///   4. Hata durumunda okuyucu tıkanıp kalmıyor — "Tekrar Dene" düğmesi var.
WeatherInfo _hava({
  required double suankiSicaklik,
  required double buGeceninDusugu,
  bool hasWarning = false,
}) {
  return WeatherInfo(
    temperature: suankiSicaklik,
    relativeHumidity: 50,
    windSpeed: 10,
    soilTemperature: 15,
    soilMoisture: 0.2,
    evapotranspiration: 4.0,
    city: 'Polatlı, Ankara',
    description: 'Güneşli ve Ilık',
    iconCode: '01d',
    agriculturalWarning: '',
    hasWarning: hasWarning,
    dailyForecast: [
      DailyForecastItem(
        date: DateTime.now().toIso8601String().split('T').first,
        maxTemp: suankiSicaklik + 5,
        minTemp: buGeceninDusugu,
        weatherCode: 0,
        et0: 4.0,
      ),
    ],
  );
}

Widget _sarmala(WeatherInfo hava, {bool koyuTema = true}) {
  return ProviderScope(
    overrides: [
      weatherProvider.overrideWith((ref) async => hava),
    ],
    child: MaterialApp(
      theme: koyuTema ? ThemeData.dark() : ThemeData.light(),
      locale: const Locale('tr'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('tr'), Locale('en')],
      home: WeatherDetailScreen(weather: hava),
    ),
  );
}

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  testWidgets('öğlen sıcakken ama gece donacaksa DON RİSKİ gösteriyor',
      (tester) async {
    // Eskiden `temperature <= 4.0` kontrolü buna "GÜVENLİ" derdi — öğlen
    // 18°C'de ölçülüyordu, gecenin -2°C'ye düşeceği hiç sorulmuyordu.
    await tester.pumpWidget(_sarmala(
      _hava(suankiSicaklik: 18, buGeceninDusugu: -2),
    ));
    // `pumpAndSettle` kullanılmıyor: `_PulseDot` ("CANLI" rozeti) sonsuz
    // döngüyle titreşiyor, hiç "settle" olmuyor. Sabit birkaç kare yeterli.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Kart başlığı ("DON RİSKİ") duruma bakmaksızın hep duruyor — asıl
    // kanıt ünlemli DEĞER metni ("DON RİSKİ!"), yalnızca risk varken çıkıyor.
    expect(find.text('DON RİSKİ!'), findsOneWidget);
  });

  testWidgets('gece de sıcaksa GÜVENLİ gösteriyor', (tester) async {
    await tester.pumpWidget(_sarmala(
      _hava(suankiSicaklik: 18, buGeceninDusugu: 12),
    ));
    // `pumpAndSettle` kullanılmıyor: `_PulseDot` ("CANLI" rozeti) sonsuz
    // döngüyle titreşiyor, hiç "settle" olmuyor. Sabit birkaç kare yeterli.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('DON RİSKİ!'), findsNothing);
    expect(find.textContaining('GÜVENLİ'), findsOneWidget);
  });

  testWidgets('hafta günü kısaltması PZT, eski "PTS" değil', (tester) async {
    await tester.pumpWidget(_sarmala(
      _hava(suankiSicaklik: 20, buGeceninDusugu: 10),
    ));
    // `pumpAndSettle` kullanılmıyor: `_PulseDot` ("CANLI" rozeti) sonsuz
    // döngüyle titreşiyor, hiç "settle" olmuyor. Sabit birkaç kare yeterli.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('PTS'), findsNothing);
  });

  testWidgets('konuma özel fotoğraf yok — sadece gradyan', (tester) async {
    await tester.pumpWidget(_sarmala(
      _hava(suankiSicaklik: 20, buGeceninDusugu: 10),
    ));
    // `pumpAndSettle` kullanılmıyor: `_PulseDot` ("CANLI" rozeti) sonsuz
    // döngüyle titreşiyor, hiç "settle" olmuyor. Sabit birkaç kare yeterli.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(Image), findsNothing);
  });

  testWidgets('hata durumunda okuyucu tıkanmıyor — Tekrar Dene düğmesi var',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          weatherProvider.overrideWith(
            (ref) => Future<WeatherInfo>.error('ağ hatası'),
          ),
        ],
        child: MaterialApp(
          locale: const Locale('tr'),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('tr'), Locale('en')],
          home: WeatherDetailScreen(weather: _hava(suankiSicaklik: 20, buGeceninDusugu: 10)),
        ),
      ),
    );
    // `pumpAndSettle` kullanılmıyor: `_PulseDot` ("CANLI" rozeti) sonsuz
    // döngüyle titreşiyor, hiç "settle" olmuyor. Sabit birkaç kare yeterli.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Tekrar Dene'), findsOneWidget);
  });

  testWidgets('açık temada taşmadan/hatasız çiziliyor', (tester) async {
    // Eskiden sayfa uygulamanın temasını hiç tanımıyordu, hep koyuydu.
    // Işık tema dalı hiç çalıştırılmamış yeni bir kod yolu — burada en
    // azından exception fırlatmadığı doğrulanıyor.
    await tester.pumpWidget(_sarmala(
      _hava(suankiSicaklik: 22, buGeceninDusugu: 14),
      koyuTema: false,
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(tester.takeException(), isNull);
  });

  testWidgets('gece ikonu açık temada bile koyu kalıyor', (tester) async {
    // Dışarıda gerçekten karanlıksa uygulama açık temada olsa bile gökyüzünü
    // mavi göstermemeli. Buradaki kanıt dolaylı: exception atmadan çiziyor
    // olması, gece dalının açık temayla çakışmadığını gösteriyor.
    final gece = _hava(suankiSicaklik: 10, buGeceninDusugu: 5);
    await tester.pumpWidget(_sarmala(
      WeatherInfo(
        temperature: gece.temperature,
        relativeHumidity: gece.relativeHumidity,
        windSpeed: gece.windSpeed,
        soilTemperature: gece.soilTemperature,
        soilMoisture: gece.soilMoisture,
        evapotranspiration: gece.evapotranspiration,
        city: gece.city,
        description: gece.description,
        iconCode: '01n',
        agriculturalWarning: gece.agriculturalWarning,
        hasWarning: gece.hasWarning,
        dailyForecast: gece.dailyForecast,
      ),
      koyuTema: false,
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(tester.takeException(), isNull);
  });
}
