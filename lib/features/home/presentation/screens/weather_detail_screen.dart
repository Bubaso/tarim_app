// ignore_for_file: deprecated_member_use
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:tarim_app/core/utils/hover.dart';
import 'package:tarim_app/core/theme/app_dark_mode.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../../data/models/weather_info.dart';
import '../../providers/home_providers.dart';
import '../../../../core/utils/string_extensions.dart';
import '../../../../core/utils/fade_page_route.dart';
import '../../../../core/utils/responsive_breakpoints.dart';

// ══════════════════════════════════════════════════════════════════════════════
//  WeatherDetailScreen  —  Zirai İklim ve Uyarı Merkezi
//
//  Bilerek uygulamanın geri kalanıyla AYNI paleti kullanmıyor. Ana sayfa
//  toprak/krem tonlarında, editoryal bir gazete kimliği taşıyor; hava durumu
//  ise anlık, atmosferik bir "gösterge paneli". Okuyucunun "başka bir alana
//  girdiğini" hissetmesi kasıtlı — tıpkı bir gazetenin hava durumu sayfasının
//  geri kalanından farklı basılması gibi. Ayrım burada duruyor.
//
//  Ama sınırsız değil: eskiden altı farklı metrik kartı altı farklı Apple
//  iOS sistem rengini rastgele taşıyordu (renk hiçbir şey İFADE ETMİYORDU).
//  Şimdi modülün KENDİ üç renkli anlamlı dili var — bkz. _WeatherTheme:
//  iyi (yeşil) / dikkat (kehribar) / tehlike (kırmızı, YALNIZCA don gibi
//  gerçekten şiddetli durumlar için — ana uygulamanın "kırmızı tek anlam
//  taşır" ilkesiyle aynı disiplin, farklı bir palet üzerinden).
//
//  Tema: uygulamanın açık/koyu ayarını artık TANIYOR (`isDark`), ama kendi
//  atmosferik gradyanıyla yanıtlıyor — kirece/toprağa dönmüyor. Gece
//  (iconCode 'n' ile bitiyorsa) uygulamanın temasından bağımsız hep koyu:
//  dışarıda gerçekten karanlıksa açık temada bile gökyüzünü mavi göstermek
//  yanlış olurdu.
// ══════════════════════════════════════════════════════════════════════════════

/// 'HH:MM', başına sıfır ekleyerek — saat bileşenlerinin kaynağı ortak.
String _saat(DateTime t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

/// Sayfadaki tüm yüzeylerin ortak köşe yarıçapı. Eskiden hero 32px yuvarlak,
/// altındaki üç kart tamamen köşeliydi (0px) — sayfa kendi içinde bile iki
/// ayrı "köşe dili" taşıyordu. Tek bir orta değerde birleştirildi: uygulamanın
/// 12px kart standardından biraz daha yuvarlak (modülün kendi kimliği), eski
/// 32px'ten çok daha ölçülü.
const double _kRadius = 16.0;

/// Modülün anlamlı üç rengi. Metrik kartlarının HER BİRİ artık kendi
/// tavsiye mantığına göre bu üçünden birini seçiyor — renk artık dekor değil,
/// bilgi taşıyor. `tehlike` yalnızca don riski gibi gerçekten şiddetli tek
/// bir durum için ayrılmış; her yere dağıtılırsa anlamını kaybeder.
enum _Seviye { iyi, dikkat, tehlike }

class _WeatherTheme {
  final bool isDark;
  final bool isNight;

  const _WeatherTheme({required this.isDark, required this.isNight});

  /// Gece dışarıda gerçekten karanlık — uygulama açık temada olsa bile
  /// gökyüzünü mavi göstermek yanlış olur. Metin/yüzey kararları bu yüzden
  /// `isDark` değil `_koyuGorunum`e bakıyor.
  bool get _koyuGorunum => isDark || isNight;

  Color get textPrimary => _koyuGorunum ? Colors.white : const Color(0xFF102030);
  Color get textSecondary => textPrimary.withValues(alpha: _koyuGorunum ? 0.72 : 0.62);
  Color get textTertiary => textPrimary.withValues(alpha: _koyuGorunum ? 0.5 : 0.45);

  Color get surfaceFill => _koyuGorunum
      ? Colors.white.withValues(alpha: 0.06)
      : Colors.white.withValues(alpha: 0.55);
  Color get surfaceFillHover => _koyuGorunum
      ? Colors.white.withValues(alpha: 0.10)
      : Colors.white.withValues(alpha: 0.75);
  Color get surfaceBorder => _koyuGorunum
      ? Colors.white.withValues(alpha: 0.12)
      : const Color(0xFF102030).withValues(alpha: 0.10);
  Color get divider => _koyuGorunum
      ? Colors.white.withValues(alpha: 0.08)
      : const Color(0xFF102030).withValues(alpha: 0.08);

  static const Color iyi = Color(0xFF2FB866);
  static const Color dikkat = Color(0xFFE8912A);
  static const Color tehlike = Color(0xFFE84C3D);

  Color renk(_Seviye s) => switch (s) {
        _Seviye.iyi => iyi,
        _Seviye.dikkat => dikkat,
        _Seviye.tehlike => tehlike,
      };

  /// Gökyüzü gradyanı — hava koduna VE temaya göre. Gece her zaman koyu.
  LinearGradient gradient(String iconCode) {
    if (iconCode.endsWith('n')) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: [0.0, 0.5, 1.0],
        colors: [Color(0xFF0A0D1A), Color(0xFF0D1B3E), Color(0xFF050810)],
      );
    }

    if (!isDark) {
      // Açık tema: gündüz gökyüzü — kirece/toprağa dönmüyor, kendi atmosferik
      // kimliğini koruyor ama parlak/okunur.
      switch (iconCode.substring(0, 2)) {
        case '01':
          return const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF8EC5F7), Color(0xFFBFE0FB), Color(0xFFEAF6FF)],
          );
        case '09':
        case '10':
        case '11':
          return const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF8CA0B3), Color(0xFFAFC0CE), Color(0xFFD9E2E8)],
          );
        case '13':
          return const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFBFD6E8), Color(0xFFDCEAF5), Color(0xFFF3F8FC)],
          );
        default:
          return const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFA9B7C4), Color(0xFFC7D2DA), Color(0xFFE7ECEF)],
          );
      }
    }

    switch (iconCode.substring(0, 2)) {
      case '01':
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.55, 1.0],
          colors: [Color(0xFF0F3460), Color(0xFF1565C0), Color(0xFF42A5F5)],
        );
      case '09':
      case '10':
      case '11':
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.5, 1.0],
          colors: [Color(0xFF0D1117), Color(0xFF1A2332), Color(0xFF0D1520)],
        );
      case '13':
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.5, 1.0],
          colors: [Color(0xFF1A1F3C), Color(0xFF2C3E6B), Color(0xFF3A4A7A)],
        );
      default:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.5, 1.0],
          colors: [Color(0xFF1A2236), Color(0xFF2E3D56), Color(0xFF1A2A40)],
        );
    }
  }

  Color get scaffoldBg => _koyuGorunum ? const Color(0xFF0A0D1A) : const Color(0xFFEAF3FB);
}

class WeatherDetailScreen extends ConsumerWidget {
  final WeatherInfo weather;

  const WeatherDetailScreen({super.key, required this.weather});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final isDark = appIsDark;
    final weatherAsync = ref.watch(weatherProvider);

    return weatherAsync.when(
      data: (weatherData) => _buildContent(context, ref, weatherData, isEn, isDark),
      loading: () => _buildLoadingState(context, isEn, isDark),
      error: (err, _) => _buildErrorState(context, ref, err.toString(), isEn, isDark),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    WeatherInfo weatherData,
    bool isEn,
    bool isDark,
  ) {
    final theme = _WeatherTheme(isDark: isDark, isNight: weatherData.iconCode.endsWith('n'));
    final windSpeed    = weatherData.windSpeed;
    final humidity     = weatherData.relativeHumidity.toInt();
    final soilTemp     = weatherData.soilTemperature;
    // ŞU ANKİ sıcaklık değil BU GECENİN tahmini düşüğü — kart "GÜVENLİ"
    // yazıp geceyi kaçırmasın diye (bkz. home_repository.dart'taki aynı not).
    final tonightMin = weatherData.dailyForecast.isNotEmpty
        ? weatherData.dailyForecast.first.minTemp
        : weatherData.temperature;
    final hasFrostRisk = tonightMin <= 4.0;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: theme.scaffoldBg,
      appBar: _buildAppBar(context, isEn, theme),
      body: Container(
        decoration: BoxDecoration(gradient: theme.gradient(weatherData.iconCode)),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),

                    // 1. ── Hero temperature display ────────────────────────
                    _HeroTemperature(weather: weatherData, isEn: isEn, theme: theme),
                    const SizedBox(height: 32),

                    // 2. ── 16:9 Main Forecast Card ─────────────────────────
                    _ForecastCard(weather: weatherData, isEn: isEn, theme: theme),
                    const SizedBox(height: 20),

                    // 3. ── Historical Climate Comparison Card ──────────────
                    _HistoricalComparisonCard(weather: weatherData, isEn: isEn, theme: theme),
                    const SizedBox(height: 20),

                    // 4. ── Agricultural Metrics Grid ──────────────────────
                    _MetricsGrid(
                      isEn:          isEn,
                      theme:         theme,
                      windSpeed:     windSpeed,
                      humidity:      humidity,
                      soilTemp:      soilTemp,
                      hasFrostRisk:  hasFrostRisk,
                      temperature:   weatherData.temperature,
                      soilMoisture:  weatherData.soilMoisture,
                      et0:           weatherData.evapotranspiration,
                    ),
                    const SizedBox(height: 20),

                    // 5. ── Agricultural Alert Banner ───────────────────────
                    if (weatherData.hasWarning)
                      _AlertBanner(message: weatherData.agriculturalWarning, theme: theme),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context, bool isEn, bool isDark) {
    final theme = _WeatherTheme(isDark: isDark, isNight: false);
    return Scaffold(
      backgroundColor: theme.scaffoldBg,
      appBar: _buildAppBar(context, isEn, theme),
      body: Center(
        child: CircularProgressIndicator(color: theme.textSecondary),
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    WidgetRef ref,
    String message,
    bool isEn,
    bool isDark,
  ) {
    final theme = _WeatherTheme(isDark: isDark, isNight: false);
    return Scaffold(
      backgroundColor: theme.scaffoldBg,
      appBar: _buildAppBar(context, isEn, theme),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: _WeatherTheme.tehlike, size: 48),
              const SizedBox(height: 16),
              Text(
                isEn ? 'Failed to fetch weather data.' : 'Hava durumu bilgisi alınamadı.',
                style: GoogleFonts.inter(color: theme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: GoogleFonts.inter(color: theme.textTertiary, fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              // Eskiden burada çıkış yoktu: hata sessizce sahte veriyle
              // örtülüyordu (bkz. home_repository.dart). Artık gerçek bir
              // hata ekranı var ama tek başına bırakılmıyor — sağlayıcı
              // hata durumunda kendiliğinden yeniden denemiyor, okuyucunun
              // geri çıkıp tekrar girmesi de işe yaramaz. Buton gerekiyor.
              OutlinedButton.icon(
                onPressed: () => ref.invalidate(weatherProvider),
                icon: Icon(Icons.refresh, size: 16, color: theme.textPrimary),
                label: Text(
                  isEn ? 'Try Again' : 'Tekrar Dene',
                  style: GoogleFonts.inter(color: theme.textPrimary, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: theme.surfaceBorder),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_kRadius)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, bool isEn, _WeatherTheme theme) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new, color: theme.textPrimary, size: 18),
        onPressed: () => popScreen(context),
      ),
      title: Text(
        isEn ? 'CLIMATE & AGRI WARNING CENTER' : 'ZİRAİ İKLİM VE UYARI MERKEZİ',
        // Sayfanın kendi kimliği: uygulamanın bölüm başlıklarında kullandığı
        // Playfair Display burada da — modül farklı bir palet taşısa da
        // "Tarım Portalı"nın editoryal sesiyle bağı kopmuyor.
        style: GoogleFonts.playfairDisplay(
          color: theme.textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
        ),
      ),
      centerTitle: true,
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  _HeroTemperature  —  Huge thin weight temperature + city + description
// ══════════════════════════════════════════════════════════════════════════════
//
// Eskiden burada konuma göre Unsplash'ten çekilen bir arka plan fotoğrafı
// vardı. Kaldırıldı: `ApiConstants.unsplashApiKey` canlı derlemede hiç
// ayarlanmıyor (`deploy.sh` --dart-define geçmiyor), yani her kullanıcı her
// şehirde AYNI sabit stok fotoğrafı görüyordu — konuma özel görünen ama
// aslında öyle olmayan bir özellik. Fotoğrafsız hâli (aşağıdaki gradyan) tek
// başına yeterince şık; yarım kalan bir özellik bırakmaktansa kaldırıldı.
class _HeroTemperature extends ConsumerWidget {
  final WeatherInfo weather;
  final bool isEn;
  final _WeatherTheme theme;

  const _HeroTemperature({required this.weather, required this.isEn, required this.theme});

  String _weatherIcon(String code) {
    if (code.endsWith('n')) return '🌙';
    switch (code.substring(0, 2)) {
      case '01': return '☀️';
      case '02': return '🌤️';
      case '03':
      case '04': return '☁️';
      case '09':
      case '10': return '🌧️';
      case '11': return '⛈️';
      case '13': return '❄️';
      case '50': return '🌫️';
      default:   return '⛅';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      // Bu container tüm üst alanı kaplar.
      constraints: const BoxConstraints(minHeight: 350),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(_kRadius),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: theme.isDark || theme.isNight
                      ? [Colors.white.withValues(alpha: 0.06), Colors.black.withValues(alpha: 0.18)]
                      : [Colors.white.withValues(alpha: 0.35), Colors.white.withValues(alpha: 0.05)],
                ),
              ),
            ),
          ),

          // İçerikler
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Weather emoji
                Text(
                  _weatherIcon(weather.iconCode),
                  style: const TextStyle(fontSize: 56),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),

                // Giant temperature — sayının kendisi uygulamanın rakamlar
                // için ayırdığı yazı tipiyle (Roboto Mono); Apple Weather'ı
                // taklit eden ince Inter yerine.
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${weather.temperature.toStringAsFixed(0)}°',
                    style: GoogleFonts.inter(
                      fontSize: 100,
                      fontWeight: FontWeight.w300,
                      color: theme.textPrimary,
                      height: 1.0,
                      shadows: theme.isDark || theme.isNight
                          ? [const Shadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, 4))]
                          : null,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                // City name & Dropdown selection
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => _showLocationSearchSheet(context, ref, theme),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: theme.surfaceFill,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: theme.surfaceBorder),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.location_on, color: theme.textPrimary, size: 16),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              weather.city.toTurkishUpperCase(),
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: theme.textPrimary,
                                letterSpacing: 1.5,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(Icons.keyboard_arrow_down, color: theme.textPrimary, size: 16),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Description — modülün başlık ailesi (Playfair Display),
                // sayfanın geri kalanındaki "AGRICULTURAL WEATHER FORECAST"
                // gibi etiketlerle aynı ses.
                Text(
                  weather.description.toTurkishUpperCase(),
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: theme.textPrimary,
                    letterSpacing: 0.6,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Status pill
                _StatusPill(hasWarning: weather.hasWarning, isEn: isEn, theme: theme),
                const SizedBox(height: 8),

                // Son güncelleme + kaynak — "CANLI" rozetinin boş bir
                // iddia olmaması için. Bkz. weather_info.dart: fetchedAt.
                Text(
                  isEn
                      ? 'Updated ${_saat(weather.fetchedAt)} · Open-Meteo'
                      : 'Güncelleme: ${_saat(weather.fetchedAt)} · Open-Meteo',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: theme.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Minimal inline status pill
class _StatusPill extends StatelessWidget {
  final bool hasWarning;
  final bool isEn;
  final _WeatherTheme theme;

  const _StatusPill({required this.hasWarning, required this.isEn, required this.theme});

  @override
  Widget build(BuildContext context) {
    final color = hasWarning ? _WeatherTheme.dikkat : _WeatherTheme.iyi;
    final label = hasWarning
        ? (isEn ? '⚠ AGRICULTURAL WARNING ACTIVE' : '⚠ ZİRAİ UYARI AKTİF')
        : (isEn ? '✓ CONDITIONS NORMAL' : '✓ KOŞULLAR NORMAL');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  _ForecastCard  —  Main 16:9 AspectRatio forecast visual block
// ══════════════════════════════════════════════════════════════════════════════
class _ForecastCard extends StatelessWidget {
  final WeatherInfo weather;
  final bool isEn;
  final _WeatherTheme theme;

  const _ForecastCard({required this.weather, required this.isEn, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.surfaceFill,
        borderRadius: BorderRadius.circular(_kRadius),
        border: Border.all(color: theme.surfaceBorder, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_kRadius),
        child: Stack(
          children: [
            // Subtle diagonal shimmer
            Positioned.fill(child: _GlassShimmer()),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row
                    Row(
                      children: [
                        Icon(Icons.thermostat_outlined, color: theme.textPrimary, size: 14),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            isEn ? 'AGRICULTURAL WEATHER FORECAST' : 'ZİRAİ HAVA DURUMU TAHMİNİ',
                            style: GoogleFonts.playfairDisplay(
                              color: theme.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.4,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Spacer(),
                        // Live dot
                        const _PulseDot(),
                        const SizedBox(width: 5),
                        Text(
                          isEn ? 'LIVE' : 'CANLI',
                          style: GoogleFonts.inter(
                            color: _WeatherTheme.iyi,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      height: 1,
                      color: theme.divider,
                    ),

                    // Main warning / info text
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        weather.agriculturalWarning.isNotEmpty
                            ? weather.agriculturalWarning
                            : (isEn
                                ? 'No active extreme weather warnings.\nSpraying, irrigation and field operations can proceed on standard schedule.'
                                : 'Aktif zirai uyarı bulunmamaktadır.\nİlaçlama, sulama ve tarla operasyonları olağan programda sürdürülebilir.'),
                        style: GoogleFonts.inter(
                          color: weather.hasWarning ? _WeatherTheme.dikkat : theme.textPrimary,
                          fontSize: 14,
                          height: 1.6,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    // ── Mini 7-day forecast bar chart ────────────────────────
                    const SizedBox(height: 8),
                    _MiniBarChart(isEn: isEn, weather: weather, theme: theme),
                  ],
                ),
              ),
            ],
          ),
        ),
    );
  }
}

// Glass shimmer overlay (purely decorative)
class _GlassShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _ShimmerPainter());
  }
}

class _ShimmerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.03),
          Colors.white.withValues(alpha: 0.0),
          Colors.white.withValues(alpha: 0.03),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Animated pulsing dot
class _PulseDot extends StatefulWidget {
  const _PulseDot();

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          color: _WeatherTheme.iyi,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: _WeatherTheme.iyi.withValues(alpha: 0.6), blurRadius: 4),
          ],
        ),
      ),
    );
  }
}

// Mini 7-day temperature bar chart (Reacts to real dailyForecast data)
class _MiniBarChart extends StatelessWidget {
  final bool isEn;
  final WeatherInfo weather;
  final _WeatherTheme theme;

  const _MiniBarChart({required this.isEn, required this.weather, required this.theme});

  String _weatherIcon(int code) {
    if (code >= 51 && code <= 67) return '🌧️';
    if (code >= 71 && code <= 77) return '❄️';
    if (code >= 80 && code <= 82) return '🌧️';
    if (code == 0) return '☀️';
    if (code == 1 || code == 2) return '🌤️';
    return '☁️';
  }

  @override
  Widget build(BuildContext context) {
    final forecast = weather.dailyForecast;
    if (forecast.isEmpty) return const SizedBox.shrink();

    // Map times to weekdays
    final List<String> days = forecast.map((item) {
      try {
        final parsed = DateTime.parse(item.date);
        final weekday = parsed.weekday;
        if (isEn) {
          switch (weekday) {
            case 1: return 'MON';
            case 2: return 'TUE';
            case 3: return 'WED';
            case 4: return 'THU';
            case 5: return 'FRI';
            case 6: return 'SAT';
            default: return 'SUN';
          }
        } else {
          switch (weekday) {
            // Yerleşik Türkçe kısaltma "PZT" — eskiden "PTS" yazıyordu,
            // takvimlerdeki hiçbir yerde geçmeyen bir kısaltma.
            case 1: return 'PZT';
            case 2: return 'SAL';
            case 3: return 'ÇAR';
            case 4: return 'PER';
            case 5: return 'CUM';
            case 6: return 'CMT';
            default: return 'PZR';
          }
        }
      } catch (_) {
        return '';
      }
    }).toList();

    final maxTemps = forecast.map((item) => item.maxTemp).toList();
    final overallMax = maxTemps.reduce(math.max);
    final minTemps = forecast.map((item) => item.minTemp).toList();
    final overallMin = minTemps.reduce(math.min);
    final range = (overallMax - overallMin).clamp(1.0, 100.0);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(forecast.length, (i) {
        final item = forecast[i];
        final frac = ((item.maxTemp - overallMin) / range).clamp(0.05, 1.0);
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '${item.maxTemp.toStringAsFixed(0)}°',
                  style: GoogleFonts.inter(
                    color: theme.textPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${item.minTemp.toStringAsFixed(0)}°',
                  style: GoogleFonts.inter(
                    color: theme.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _weatherIcon(item.weatherCode),
                  style: const TextStyle(fontSize: 10),
                ),
                // Yağış miktarı (mm) — ikon tek başına "yağmurlu" der ama
                // 0,2 mm mi 40 mm mi olduğunu söylemez; sulama kararı için
                // rakam gerekiyor. Kuru günlerde satır boş bırakılıyor (yer
                // yine de ayrılıyor, sütunlar dikeyde kaymasın diye).
                Text(
                  item.precipitation > 0.1
                      ? '${item.precipitation.toStringAsFixed(1)}mm'
                      : '',
                  style: GoogleFonts.inter(
                    color: theme.isDark || theme.isNight ? const Color(0xFF7FD8FF) : const Color(0xFF0E76A8),
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Container(
                  height: 24 * frac,
                  constraints: const BoxConstraints(minHeight: 3, maxHeight: 24),
                  decoration: BoxDecoration(
                    color: theme.textPrimary.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  days[i],
                  style: GoogleFonts.inter(
                    color: theme.textPrimary,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  _HistoricalComparisonCard  —  Year-Over-Year Climate Anomaly Tracker
// ══════════════════════════════════════════════════════════════════════════════
class _HistoricalComparisonCard extends StatelessWidget {
  final WeatherInfo weather;
  final bool isEn;
  final _WeatherTheme theme;

  const _HistoricalComparisonCard({required this.weather, required this.isEn, required this.theme});

  @override
  Widget build(BuildContext context) {
    final hist = weather.historicalInfo;
    if (hist == null) return const SizedBox.shrink();

    final todayMax = weather.dailyForecast.isNotEmpty ? weather.dailyForecast.first.maxTemp : weather.temperature;
    final todayMin = weather.dailyForecast.isNotEmpty ? weather.dailyForecast.first.minTemp : weather.temperature;

    final tempDiffMax = todayMax - hist.lastYearMaxTemp;
    final tempDiffMin = todayMin - hist.lastYearMinTemp;

    final signMax = tempDiffMax > 0 ? '+' : '';
    final signMin = tempDiffMin > 0 ? '+' : '';

    final labelStyle = GoogleFonts.inter(fontSize: 10, color: theme.textSecondary, fontWeight: FontWeight.w800);
    final valueStyle = GoogleFonts.inter(fontSize: 14, color: theme.textPrimary, fontWeight: FontWeight.w700);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.surfaceFill,
        borderRadius: BorderRadius.circular(_kRadius),
        border: Border.all(color: theme.surfaceBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.history, color: theme.textPrimary, size: 14),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  isEn ? 'HISTORICAL CLIMATE COMPARISON (LAST YEAR)' : 'GEÇMİŞ YIL İKLİM KARŞILAŞTIRMASI (GEÇEN YIL)',
                  style: GoogleFonts.playfairDisplay(
                    color: theme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(isEn ? 'MAX TEMPERATURE' : 'MAKSİMUM SICAKLIK', style: labelStyle, maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${todayMax.toStringAsFixed(0)}°C vs ${hist.lastYearMaxTemp.toStringAsFixed(1)}°C',
                          style: valueStyle,
                        ),
                      ),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          isEn
                              ? '$signMax${tempDiffMax.toStringAsFixed(1)}°C difference'
                              : 'Fark: $signMax${tempDiffMax.toStringAsFixed(1)}°C',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: tempDiffMax > 0 ? _WeatherTheme.dikkat : theme.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                VerticalDivider(color: theme.divider, width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(isEn ? 'MIN TEMPERATURE' : 'MİNİMUM SICAKLIK', style: labelStyle, maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${todayMin.toStringAsFixed(0)}°C vs ${hist.lastYearMinTemp.toStringAsFixed(1)}°C',
                          style: valueStyle,
                        ),
                      ),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          isEn
                              ? '$signMin${tempDiffMin.toStringAsFixed(1)}°C difference'
                              : 'Fark: $signMin${tempDiffMin.toStringAsFixed(1)}°C',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: tempDiffMin > 0 ? _WeatherTheme.tehlike : _WeatherTheme.iyi,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                VerticalDivider(color: theme.divider, width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(isEn ? 'EVAPORATION' : 'BUHARLAŞMA', style: labelStyle, maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${weather.evapotranspiration.toStringAsFixed(1)} vs ${hist.lastYearEt0.toStringAsFixed(1)}',
                          style: valueStyle,
                        ),
                      ),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          isEn
                              ? '${(weather.evapotranspiration - hist.lastYearEt0) > 0 ? "+" : ""}${(weather.evapotranspiration - hist.lastYearEt0).toStringAsFixed(1)} mm diff'
                              : 'Fark: ${(weather.evapotranspiration - hist.lastYearEt0) > 0 ? "+" : ""}${(weather.evapotranspiration - hist.lastYearEt0).toStringAsFixed(1)}',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: (weather.evapotranspiration - hist.lastYearEt0) > 0
                                ? _WeatherTheme.dikkat
                                : _WeatherTheme.iyi,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  _MetricsGrid  —  3×2 agricultural metric glassmorphic cards (16:9 each)
// ══════════════════════════════════════════════════════════════════════════════
class _MetricsGrid extends StatelessWidget {
  final bool isEn;
  final _WeatherTheme theme;
  final double windSpeed;
  final int humidity;
  final double soilTemp;
  final bool hasFrostRisk;
  final double temperature;
  final double soilMoisture;
  final double et0;

  const _MetricsGrid({
    required this.isEn,
    required this.theme,
    required this.windSpeed,
    required this.humidity,
    required this.soilTemp,
    required this.hasFrostRisk,
    required this.temperature,
    required this.soilMoisture,
    required this.et0,
  });

  @override
  Widget build(BuildContext context) {
    // Uygulamanın kendi tanımlı eşiği kullanılıyor — eskiden burada sabit
    // `700` vardı, uygulamanın tablet/masaüstü ayrımıyla (1100) örtüşmüyordu:
    // aynı genişlikte bu sayfa "masaüstü" derken geri kalanı hâlâ "tablet"
    // diyordu.
    final isDesktop = ResponsiveBreakpoints.isDesktopOrLarger(context);

    // Wind recommendation
    final windIyi = windSpeed < 20;
    final windRec = windIyi
        ? (isEn ? 'Ideal for spraying' : 'İlaçlama için uygun')
        : (isEn ? 'Avoid spraying' : 'İlaçlamadan kaçının');

    // Humidity risk — "risk" sözü metinde geçtiği andan itibaren renk de
    // dikkat çekiyor; yalnızca gerçekten düşük risk yeşile düşüyor.
    final humDikkat = humidity > 60;
    final humRisk = humidity > 80
        ? (isEn ? 'High disease risk' : 'Yüksek hastalık riski')
        : humidity > 60
            ? (isEn ? 'Moderate risk' : 'Orta risk')
            : (isEn ? 'Low disease risk' : 'Düşük hastalık riski');

    // Frost data — modülün TEK "tehlike" (kırmızı) durumu. Kırmızı başka
    // hiçbir kartta kullanılmıyor ki buradaki anlamını korusun.
    final frostLabel = hasFrostRisk
        ? (isEn ? 'FROST WARNING!' : 'DON RİSKİ!')
        : (isEn ? 'SAFE' : 'GÜVENLİ');
    final frostDesc = hasFrostRisk
        ? (isEn ? 'Protect vulnerable crops tonight' : 'Hassas bitkileri koruma altına alın')
        : (isEn ? 'No frost risk detected' : 'Don tehlikesi tespit edilmedi');

    // Soil recommendation
    final soilIyi = soilTemp >= 10;
    final soilRec = soilIyi
        ? (isEn ? 'Suitable for seeding' : 'Tohum ekimine uygun')
        : (isEn ? 'Too cold for seeding' : 'Ekim için çok soğuk');

    // Soil moisture recommendation — iki uçta da (kuru/ıslak) dikkat.
    final soilMoistureIyi = soilMoisture >= 0.12 && soilMoisture < 0.25;
    final soilMoistureRec = soilMoisture < 0.12
        ? (isEn ? 'Dry - Irrigation needed' : 'Kuru - Sulama gerekli')
        : soilMoisture < 0.25
            ? (isEn ? 'Adequate soil moisture' : 'Toprak nemi yeterli')
            : (isEn ? 'Wet - Stop irrigation' : 'Yaş - Sulamayı durdurun');

    // Evapotranspiration recommendation
    final et0Iyi = et0 <= 6.0;
    final et0Rec = et0 > 6.0
        ? (isEn ? 'High transpiration loss' : 'Yüksek su kaybı riski')
        : et0 > 3.0
            ? (isEn ? 'Moderate water loss' : 'Orta derece su kaybı')
            : (isEn ? 'Low water loss' : 'Düşük su kaybı');

    final cards = [
      _MetricCard(
        theme: theme,
        icon: Icons.air,
        title: isEn ? 'WIND SPEED' : 'RÜZGAR HIZI',
        value: '${windSpeed.toStringAsFixed(0)} km/h',
        subtitle: windRec,
        seviye: windIyi ? _Seviye.iyi : _Seviye.dikkat,
      ),
      _MetricCard(
        theme: theme,
        icon: Icons.water_drop_outlined,
        title: isEn ? 'HUMIDITY' : 'NEM ORANI',
        value: '%$humidity',
        subtitle: humRisk,
        seviye: humDikkat ? _Seviye.dikkat : _Seviye.iyi,
      ),
      _MetricCard(
        theme: theme,
        icon: Icons.ac_unit,
        title: isEn ? 'FROST RISK' : 'DON RİSKİ',
        value: frostLabel,
        subtitle: frostDesc,
        seviye: hasFrostRisk ? _Seviye.tehlike : _Seviye.iyi,
        isAlert: hasFrostRisk,
      ),
      _MetricCard(
        theme: theme,
        icon: Icons.grass,
        title: isEn ? 'SOIL TEMP' : 'TOPRAK SICAKLIĞI',
        value: '${soilTemp.toStringAsFixed(1)}°C',
        subtitle: soilRec,
        seviye: soilIyi ? _Seviye.iyi : _Seviye.dikkat,
      ),
      _MetricCard(
        theme: theme,
        icon: Icons.opacity,
        title: isEn ? 'SOIL MOISTURE' : 'TOPRAK NEMİ',
        value: '${(soilMoisture * 100).toStringAsFixed(1)}%',
        subtitle: soilMoistureRec,
        seviye: soilMoistureIyi ? _Seviye.iyi : _Seviye.dikkat,
      ),
      _MetricCard(
        theme: theme,
        icon: Icons.wb_sunny_outlined,
        title: isEn ? 'EVAPORATION (ET0)' : 'BUHARLAŞMA (ET0)',
        value: '${et0.toStringAsFixed(1)} mm/gün',
        subtitle: et0Rec,
        seviye: et0Iyi ? _Seviye.iyi : _Seviye.dikkat,
      ),
    ];

    if (isDesktop) {
      return Column(
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: cards
                  .sublist(0, 3)
                  .map((c) => Expanded(child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: c,
                      )))
                  .toList(),
            ),
          ),
          const SizedBox(height: 8),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: cards
                  .sublist(3, 6)
                  .map((c) => Expanded(child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: c,
                      )))
                  .toList(),
            ),
          ),
        ],
      );
    }

    // Mobil/tablet: 3 satır × 2 sütun (responsive, dengeli)
    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: cards[0]),
              const SizedBox(width: 12),
              Expanded(child: cards[1]),
            ],
          ),
        ),
        const SizedBox(height: 12),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: cards[2]),
              const SizedBox(width: 12),
              Expanded(child: cards[3]),
            ],
          ),
        ),
        const SizedBox(height: 12),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: cards[4]),
              const SizedBox(width: 12),
              Expanded(child: cards[5]),
            ],
          ),
        ),
      ],
    );
  }
}

// Single glassmorphic metric card — with hover scale
class _MetricCard extends StatefulWidget {
  final _WeatherTheme theme;
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final _Seviye seviye;
  final bool isAlert;

  const _MetricCard({
    required this.theme,
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.seviye,
    this.isAlert = false,
  });

  @override
  State<_MetricCard> createState() => _MetricCardState();
}

class _MetricCardState extends State<_MetricCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final accent = theme.renk(widget.seviye);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) { if (hoverPointerLikely) setState(() => _hovered = true); },
      onExit:  (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: _hovered ? 1.03 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: _hovered ? theme.surfaceFillHover : theme.surfaceFill,
            borderRadius: BorderRadius.circular(_kRadius),
            // Border.all — tek renk ZORUNLU: Flutter, yarıçaplı bir kenarlıkta
            // kenarların farklı renk taşımasına izin vermiyor ("A borderRadius
            // can only be given on borders with uniform colors" — üretimde
            // testle yakalandı). Eskiden yalnızca üst kenar vurgu rengindeydi;
            // şimdi uyarı durumunda TÜM kenarlık vurgu rengine dönüyor —
            // tek başına daha güçlü bir işaret, köşe yarıçabıyla da uyumlu.
            border: Border.all(
              color: widget.isAlert
                  ? accent.withValues(alpha: _hovered ? 0.9 : 0.6)
                  : theme.surfaceBorder,
              width: widget.isAlert ? 2 : 1,
            ),
          ),
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Title + icon row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: GoogleFonts.inter(
                        color: theme.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    widget.icon,
                    color: accent.withValues(alpha: _hovered ? 1.0 : 0.85),
                    size: 13,
                  ),
                ],
              ),

              // Value
              Text(
                widget.value,
                style: GoogleFonts.inter(
                  color: accent,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
              ),

              // Subtitle
              Text(
                widget.subtitle,
                style: GoogleFonts.inter(
                  color: theme.textPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  _AlertBanner  —  Full-width warning banner (only shown if hasWarning=true)
// ══════════════════════════════════════════════════════════════════════════════
class _AlertBanner extends StatelessWidget {
  final String message;
  final _WeatherTheme theme;

  const _AlertBanner({required this.message, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _WeatherTheme.dikkat.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(_kRadius),
        border: Border.all(color: _WeatherTheme.dikkat.withValues(alpha: 0.5), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, color: _WeatherTheme.dikkat, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.inter(
                color: _WeatherTheme.dikkat,
                fontSize: 12,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  Location Search Bottom Sheet Helper
// ══════════════════════════════════════════════════════════════════════════════
void _showLocationSearchSheet(BuildContext context, WidgetRef ref, _WeatherTheme theme) {
  final isEn = Localizations.localeOf(context).languageCode == 'en';
  showModalBottomSheet(
    context: context,
    backgroundColor: theme.isDark ? const Color(0xFF0F121D) : const Color(0xFFF4F9FC),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(_kRadius)),
    ),
    isScrollControlled: true,
    builder: (context) {
      return _LocationSearchWidget(isEn: isEn, theme: theme);
    },
  );
}

class _LocationSearchWidget extends ConsumerStatefulWidget {
  final bool isEn;
  final _WeatherTheme theme;
  const _LocationSearchWidget({required this.isEn, required this.theme});

  @override
  ConsumerState<_LocationSearchWidget> createState() => _LocationSearchWidgetState();
}

class _LocationSearchWidgetState extends ConsumerState<_LocationSearchWidget> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _searching = false;
  bool _gpsLocating = false;

  // Predefined major agricultural locations in Turkey
  final List<Map<String, dynamic>> _quickLocations = [
    {'name': 'Polatlı, Ankara', 'lat': 39.58, 'lon': 32.14},
    {'name': 'Konya Ovası', 'lat': 37.87, 'lon': 32.48},
    {'name': 'Çukurova, Adana', 'lat': 36.99, 'lon': 35.32},
    {'name': 'Söke, Aydın', 'lat': 37.75, 'lon': 27.40},
    {'name': 'Kadirli, Osmaniye', 'lat': 37.37, 'lon': 36.10},
    {'name': 'Karacabey, Bursa', 'lat': 40.21, 'lon': 28.36},
    {'name': 'Bafra, Samsun', 'lat': 41.56, 'lon': 35.90},
    {'name': 'Antalya', 'lat': 36.88, 'lon': 30.70},
  ];

  Future<void> _performSearch(String text) async {
    if (text.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _searching = false;
      });
      return;
    }
    setState(() => _searching = true);
    try {
      final response = await http.get(
        Uri.parse('https://geocoding-api.open-meteo.com/v1/search?name=${Uri.encodeComponent(text)}&count=5&language=${widget.isEn ? "en" : "tr"}&format=json'),
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List?;
        if (results != null) {
          final mapped = results.map((item) {
            final name = item['name']?.toString() ?? '';
            final admin1 = item['admin1']?.toString() ?? '';
            final country = item['country']?.toString() ?? '';
            String label = name;
            if (admin1.isNotEmpty && admin1 != name) label = '$label, $admin1';
            if (country.isNotEmpty) label = '$label ($country)';

            return {
              'label': label,
              'latitude': (item['latitude'] as num?)?.toDouble() ?? 0.0,
              'longitude': (item['longitude'] as num?)?.toDouble() ?? 0.0,
            };
          }).toList();
          setState(() {
            _searchResults = mapped;
            _searching = false;
          });
          return;
        }
      }
    } catch (_) {}
    setState(() {
      _searchResults = [];
      _searching = false;
    });
  }

  Future<void> _requestGPS() async {
    setState(() => _gpsLocating = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.isEn ? 'Location permission denied.' : 'Konum izni reddedildi.'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
        setState(() => _gpsLocating = false);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      String name = widget.isEn ? 'GPS Location' : 'GPS Konumu';
      try {
        final res = await http.get(
          Uri.parse('https://nominatim.openstreetmap.org/reverse?lat=${position.latitude}&lon=${position.longitude}&format=json&accept-language=${widget.isEn ? "en" : "tr"}'),
          headers: {'User-Agent': 'tarim_app_agent'},
        ).timeout(const Duration(seconds: 3));
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          final address = data['address'];
          if (address != null) {
            name = address['suburb'] ?? address['town'] ?? address['district'] ?? address['city'] ?? address['province'] ?? name;
            final prov = address['province'] ?? address['state'] ?? '';
            if (prov.isNotEmpty && !name.contains(prov)) {
              name = '$name, $prov';
            }
          }
        }
      } catch (_) {}

      ref.read(activeLocationProvider.notifier).update(LocationData(
        name: name,
        latitude: position.latitude,
        longitude: position.longitude,
      ));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isEn ? 'Failed to fetch GPS coordinates.' : 'GPS koordinatları alınamadı.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      setState(() => _gpsLocating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final textColor = theme.textPrimary;
    final subtleColor = theme.textTertiary;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 20,
        left: 20,
        right: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.isEn ? 'Select Location' : 'Konum Seçin',
                style: GoogleFonts.inter(color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: Icon(Icons.close, color: subtleColor),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              hintText: widget.isEn ? 'Search city or district...' : 'İl veya ilçe ara...',
              hintStyle: TextStyle(color: subtleColor),
              prefixIcon: Icon(Icons.search, color: subtleColor),
              filled: true,
              fillColor: theme.surfaceFill,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: (text) => _performSearch(text),
          ),
          const SizedBox(height: 16),
          // GPS trigger button
          ElevatedButton.icon(
            onPressed: _gpsLocating ? null : _requestGPS,
            icon: _gpsLocating
                ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: _WeatherTheme.iyi))
                : const Icon(Icons.gps_fixed, size: 16),
            label: Text(widget.isEn ? 'Use GPS (My Fields)' : 'GPS Kullan (Tarlamın Konumu)'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _WeatherTheme.iyi.withValues(alpha: 0.15),
              foregroundColor: _WeatherTheme.iyi,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: _WeatherTheme.iyi.withValues(alpha: 0.3)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Quick selections or search results
          Text(
            _searchResults.isNotEmpty
                ? (widget.isEn ? 'Search Results' : 'Arama Sonuçları')
                : (widget.isEn ? 'Major Agricultural Hubs' : 'Önemli Tarım Merkezleri'),
            style: GoogleFonts.inter(color: subtleColor, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
          const SizedBox(height: 8),
          if (_searching)
            Center(child: Padding(padding: const EdgeInsets.all(20), child: CircularProgressIndicator(color: subtleColor)))
          else if (_searchResults.isNotEmpty)
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 220),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _searchResults.length,
                itemBuilder: (context, i) {
                  final item = _searchResults[i];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(item['label'] as String, style: TextStyle(color: theme.textSecondary, fontSize: 13)),
                    trailing: Icon(Icons.arrow_forward_ios, size: 12, color: subtleColor),
                    onTap: () {
                      ref.read(activeLocationProvider.notifier).update(LocationData(
                        name: item['label'] as String,
                        latitude: item['latitude'] as double,
                        longitude: item['longitude'] as double,
                      ));
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            )
          else
            // Predefined Quick selection Wrap
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _quickLocations.map((item) {
                  return InkWell(
                    onTap: () {
                      ref.read(activeLocationProvider.notifier).update(LocationData(
                        name: item['name'] as String,
                        latitude: item['lat'] as double,
                        longitude: item['lon'] as double,
                      ));
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: theme.surfaceFill,
                        border: Border.all(color: theme.surfaceBorder),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item['name'] as String,
                        style: GoogleFonts.inter(color: theme.textSecondary, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
