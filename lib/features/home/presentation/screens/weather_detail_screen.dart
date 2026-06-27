// ignore_for_file: deprecated_member_use
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../../data/models/weather_info.dart';
import '../../providers/home_providers.dart';

// ══════════════════════════════════════════════════════════════════════════════
//  WeatherDetailScreen  —  Zirai İklim ve Uyarı Merkezi
//  Apple Weather aesthetic · Dynamic gradient · 16:9 forecast block
//  Agricultural metrics: wind · humidity · frost warning · soil temperature
// ══════════════════════════════════════════════════════════════════════════════
class WeatherDetailScreen extends ConsumerWidget {
  final WeatherInfo weather;

  const WeatherDetailScreen({super.key, required this.weather});

  // ── Dynamic gradient by iconCode ──────────────────────────────────────────
  static LinearGradient _gradient(String iconCode) {
    if (iconCode.endsWith('n')) {
      // Night  → deep navy → near-black
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: [0.0, 0.5, 1.0],
        colors: [Color(0xFF0A0D1A), Color(0xFF0D1B3E), Color(0xFF050810)],
      );
    }
    switch (iconCode.substring(0, 2)) {
      case '01': // Clear sunny
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.55, 1.0],
          colors: [Color(0xFF0F3460), Color(0xFF1565C0), Color(0xFF42A5F5)],
        );
      case '09':
      case '10':
      case '11': // Rain / Storm
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.5, 1.0],
          colors: [Color(0xFF0D1117), Color(0xFF1A2332), Color(0xFF0D1520)],
        );
      case '13': // Snow
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.5, 1.0],
          colors: [Color(0xFF1A1F3C), Color(0xFF2C3E6B), Color(0xFF3A4A7A)],
        );
      default: // Cloudy
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.5, 1.0],
          colors: [Color(0xFF1A2236), Color(0xFF2E3D56), Color(0xFF1A2A40)],
        );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final weatherAsync = ref.watch(weatherProvider);

    return weatherAsync.when(
      data: (weatherData) => _buildContent(context, ref, weatherData, isEn),
      loading: () => _buildLoadingState(context, isEn),
      error: (err, _) => _buildErrorState(context, err.toString(), isEn),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, WeatherInfo weatherData, bool isEn) {
    final windSpeed    = weatherData.windSpeed;
    final humidity     = weatherData.relativeHumidity.toInt();
    final soilTemp     = weatherData.soilTemperature;
    final hasFrostRisk = weatherData.temperature <= 4.0;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFF0A0D1A),
      appBar: _buildAppBar(context, isEn),
      body: Container(
        decoration: BoxDecoration(gradient: _gradient(weatherData.iconCode)),
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
                    _HeroTemperature(weather: weatherData, isEn: isEn),
                    const SizedBox(height: 32),

                    // 2. ── 16:9 Main Forecast Card ─────────────────────────
                    _ForecastCard(weather: weatherData, isEn: isEn),
                    const SizedBox(height: 20),

                    // 3. ── Historical Climate Comparison Card ──────────────
                    _HistoricalComparisonCard(weather: weatherData, isEn: isEn),
                    const SizedBox(height: 20),

                    // 4. ── Agricultural Metrics Grid ──────────────────────
                    _MetricsGrid(
                      isEn:          isEn,
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
                      _AlertBanner(message: weatherData.agriculturalWarning),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context, bool isEn) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0D1A),
      appBar: _buildAppBar(context, isEn),
      body: const Center(
        child: CircularProgressIndicator(color: Colors.white70),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message, bool isEn) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0D1A),
      appBar: _buildAppBar(context, isEn),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
              const SizedBox(height: 16),
              Text(
                isEn ? 'Failed to fetch weather data.' : 'Hava durumu bilgisi alınamadı.',
                style: GoogleFonts.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: GoogleFonts.inter(color: Colors.white54, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, bool isEn) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70, size: 18),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        isEn ? 'CLIMATE & AGRI WARNING CENTER' : 'ZİRAİ İKLİM VE UYARI MERKEZİ',
        style: GoogleFonts.inter(
          color: Colors.white54,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
      centerTitle: true,
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  _HeroTemperature  —  Huge thin weight temperature + city + description
// ══════════════════════════════════════════════════════════════════════════════
class _HeroTemperature extends ConsumerWidget {
  final WeatherInfo weather;
  final bool isEn;

  const _HeroTemperature({required this.weather, required this.isEn});

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
    return Column(
      children: [
        // Weather emoji
        Text(
          _weatherIcon(weather.iconCode),
          style: const TextStyle(fontSize: 56),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),

        // Giant temperature — Apple Weather style ultra-thin
        Text(
          '${weather.temperature.toStringAsFixed(0)}°',
          style: GoogleFonts.inter(
            fontSize: 104,
            fontWeight: FontWeight.w100,
            color: Colors.white,
            height: 1.0,
          ),
          textAlign: TextAlign.center,
        ),

        // City name & Dropdown selection
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => _showLocationSearchSheet(context, ref),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on, color: Colors.white70, size: 16),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      weather.city.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.keyboard_arrow_down, color: Colors.white54, size: 16),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Description
        Text(
          weather.description.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.white54,
            letterSpacing: 1.0,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),

        // Status pill
        _StatusPill(hasWarning: weather.hasWarning, isEn: isEn),
      ],
    );
  }
}

// Minimal inline status pill
class _StatusPill extends StatelessWidget {
  final bool hasWarning;
  final bool isEn;

  const _StatusPill({required this.hasWarning, required this.isEn});

  @override
  Widget build(BuildContext context) {
    final color = hasWarning ? const Color(0xFFFF9500) : const Color(0xFF30D158);
    final label = hasWarning
        ? (isEn ? '⚠ AGRICULTURAL WARNING ACTIVE' : '⚠ ZİRAİ UYARI AKTİF')
        : (isEn ? '✓ CONDITIONS NORMAL' : '✓ KOŞULLAR NORMAL');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          color: color,
          fontSize: 9,
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

  const _ForecastCard({required this.weather, required this.isEn});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12), width: 1),
        ),
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
                      const Icon(Icons.thermostat_outlined, color: Colors.white54, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        isEn ? 'AGRICULTURAL WEATHER FORECAST' : 'ZİRAİ HAVA DURUMU TAHMİNİ',
                        style: GoogleFonts.inter(
                          color: Colors.white54,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const Spacer(),
                      // Live dot
                      _PulseDot(),
                      const SizedBox(width: 5),
                      Text(
                        isEn ? 'LIVE' : 'CANLI',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF30D158),
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    height: 1,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),

                  // Main warning / info text  — fills remaining space
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          weather.agriculturalWarning.isNotEmpty
                              ? weather.agriculturalWarning
                              : (isEn
                                  ? 'No active extreme weather warnings.\nSpraying, irrigation and field operations can proceed on standard schedule.'
                                  : 'Aktif zirai uyarı bulunmamaktadır.\nİlaçlama, sulama ve tarla operasyonları olağan programda sürdürülebilir.'),
                          style: GoogleFonts.inter(
                            color: weather.hasWarning
                                ? const Color(0xFFFF9500)
                                : Colors.white.withValues(alpha: 0.75),
                            fontSize: 13,
                            height: 1.6,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // ── Mini 7-day forecast bar chart ────────────────────────
                  const SizedBox(height: 8),
                  _MiniBarChart(isEn: isEn, weather: weather),
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
          color: const Color(0xFF30D158),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: const Color(0xFF30D158).withValues(alpha: 0.6), blurRadius: 4),
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

  const _MiniBarChart({required this.isEn, required this.weather});

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
            case 1: return 'PTS';
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
                    color: Colors.white70,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${item.minTemp.toStringAsFixed(0)}°',
                  style: GoogleFonts.inter(
                    color: Colors.white30,
                    fontSize: 7,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _weatherIcon(item.weatherCode),
                  style: const TextStyle(fontSize: 10),
                ),
                const SizedBox(height: 3),
                Container(
                  height: 24 * frac,
                  constraints: const BoxConstraints(minHeight: 3, maxHeight: 24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  days[i],
                  style: GoogleFonts.inter(
                    color: Colors.white38,
                    fontSize: 7,
                    fontWeight: FontWeight.w700,
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

  const _HistoricalComparisonCard({required this.weather, required this.isEn});

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

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.history, color: Colors.white54, size: 14),
              const SizedBox(width: 6),
              Text(
                isEn ? 'HISTORICAL CLIMATE COMPARISON (LAST YEAR)' : 'GEÇMİŞ YIL İKLİM KARŞILAŞTIRMASI (GEÇEN YIL)',
                style: GoogleFonts.inter(
                  color: Colors.white54,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
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
                      Text(
                        isEn ? 'MAX TEMPERATURE' : 'MAKSİMUM SICAKLIK',
                        style: GoogleFonts.inter(fontSize: 8, color: Colors.white38, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${todayMax.toStringAsFixed(1)}°C vs ${hist.lastYearMaxTemp.toStringAsFixed(1)}°C',
                        style: GoogleFonts.inter(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isEn 
                            ? '$signMax${tempDiffMax.toStringAsFixed(1)}°C difference'
                            : 'Fark: $signMax${tempDiffMax.toStringAsFixed(1)}°C',
                        style: GoogleFonts.inter(
                          fontSize: 9, 
                          color: tempDiffMax > 0 ? const Color(0xFFFF9500) : const Color(0xFF64D2FF),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                VerticalDivider(color: Colors.white.withValues(alpha: 0.08), width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEn ? 'MIN TEMPERATURE' : 'MİNİMUM SICAKLIK',
                        style: GoogleFonts.inter(fontSize: 8, color: Colors.white38, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${todayMin.toStringAsFixed(1)}°C vs ${hist.lastYearMinTemp.toStringAsFixed(1)}°C',
                        style: GoogleFonts.inter(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isEn 
                            ? '$signMin${tempDiffMin.toStringAsFixed(1)}°C difference'
                            : 'Fark: $signMin${tempDiffMin.toStringAsFixed(1)}°C',
                        style: GoogleFonts.inter(
                          fontSize: 9, 
                          color: tempDiffMin > 0 ? const Color(0xFFFF453A) : const Color(0xFF32D74B),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                VerticalDivider(color: Colors.white.withValues(alpha: 0.08), width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEn ? 'EVAPORATION (ET0)' : 'BUHARLAŞMA MİKTARI',
                        style: GoogleFonts.inter(fontSize: 8, color: Colors.white38, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${weather.evapotranspiration.toStringAsFixed(1)} mm vs ${hist.lastYearEt0.toStringAsFixed(1)} mm',
                        style: GoogleFonts.inter(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isEn
                            ? '${(weather.evapotranspiration - hist.lastYearEt0) > 0 ? "+" : ""}${(weather.evapotranspiration - hist.lastYearEt0).toStringAsFixed(1)} mm diff'
                            : 'Fark: ${(weather.evapotranspiration - hist.lastYearEt0) > 0 ? "+" : ""}${(weather.evapotranspiration - hist.lastYearEt0).toStringAsFixed(1)} mm',
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          color: (weather.evapotranspiration - hist.lastYearEt0) > 0 ? const Color(0xFFFF9500) : const Color(0xFF32D74B),
                          fontWeight: FontWeight.bold,
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
  final double windSpeed;
  final int humidity;
  final double soilTemp;
  final bool hasFrostRisk;
  final double temperature;
  final double soilMoisture;
  final double et0;

  const _MetricsGrid({
    required this.isEn,
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
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 700;

    // Wind recommendation
    final windRec = windSpeed < 20
        ? (isEn ? 'Ideal for spraying' : 'İlaçlama için uygun')
        : (isEn ? 'Avoid spraying' : 'İlaçlamadan kaçının');

    // Humidity risk
    final humRisk = humidity > 80
        ? (isEn ? 'High disease risk' : 'Yüksek hastalık riski')
        : humidity > 60
            ? (isEn ? 'Moderate risk' : 'Orta risk')
            : (isEn ? 'Low disease risk' : 'Düşük hastalık riski');

    // Frost data
    final frostLabel = hasFrostRisk
        ? (isEn ? 'FROST WARNING!' : 'DON RİSKİ!')
        : (isEn ? 'SAFE' : 'GÜVENLİ');
    final frostDesc = hasFrostRisk
        ? (isEn ? 'Protect vulnerable crops tonight' : 'Hassas bitkileri koruma altına alın')
        : (isEn ? 'No frost risk detected' : 'Don tehlikesi tespit edilmedi');
    final frostColor = hasFrostRisk ? const Color(0xFFFF453A) : const Color(0xFF30D158);

    // Soil recommendation
    final soilRec = soilTemp >= 10
        ? (isEn ? 'Suitable for seeding' : 'Tohum ekimine uygun')
        : (isEn ? 'Too cold for seeding' : 'Ekim için çok soğuk');

    // Soil moisture recommendation
    final soilMoistureRec = soilMoisture < 0.12
        ? (isEn ? 'Dry - Irrigation needed' : 'Kuru - Sulama gerekli')
        : soilMoisture < 0.25
            ? (isEn ? 'Adequate soil moisture' : 'Toprak nemi yeterli')
            : (isEn ? 'Wet - Stop irrigation' : 'Yaş - Sulamayı durdurun');

    // Evapotranspiration recommendation
    final et0Rec = et0 > 6.0
        ? (isEn ? 'High transpiration loss' : 'Yüksek su kaybı riski')
        : et0 > 3.0
            ? (isEn ? 'Moderate water loss' : 'Orta derece su kaybı')
            : (isEn ? 'Low water loss' : 'Düşük su kaybı');

    final cards = [
      _MetricCard(
        icon: Icons.air,
        title: isEn ? 'WIND SPEED' : 'RÜZGAR HIZI',
        value: '${windSpeed.toStringAsFixed(0)} km/h',
        subtitle: windRec,
        accentColor: const Color(0xFF64D2FF),
      ),
      _MetricCard(
        icon: Icons.water_drop_outlined,
        title: isEn ? 'HUMIDITY' : 'NEM ORANI',
        value: '%$humidity',
        subtitle: humRisk,
        accentColor: const Color(0xFF5AC8FA),
      ),
      _MetricCard(
        icon: Icons.ac_unit,
        title: isEn ? 'FROST RISK' : 'DON RİSKİ',
        value: frostLabel,
        subtitle: frostDesc,
        accentColor: frostColor,
        isAlert: hasFrostRisk,
      ),
      _MetricCard(
        icon: Icons.grass,
        title: isEn ? 'SOIL TEMP' : 'TOPRAK SICAKLIĞI',
        value: '${soilTemp.toStringAsFixed(1)}°C',
        subtitle: soilRec,
        accentColor: const Color(0xFF32D74B),
      ),
      _MetricCard(
        icon: Icons.opacity,
        title: isEn ? 'SOIL MOISTURE' : 'TOPRAK NEMİ',
        value: '${(soilMoisture * 100).toStringAsFixed(1)}%',
        subtitle: soilMoistureRec,
        accentColor: const Color(0xFF007AFF),
      ),
      _MetricCard(
        icon: Icons.wb_sunny_outlined,
        title: isEn ? 'EVAPORATION (ET0)' : 'BUHARLAŞMA (ET0)',
        value: '${et0.toStringAsFixed(1)} mm/gün',
        subtitle: et0Rec,
        accentColor: const Color(0xFFFF9500),
      ),
    ];

    if (isDesktop) {
      return Column(
        children: [
          Row(
            children: cards
                .sublist(0, 3)
                .map((c) => Expanded(child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: AspectRatio(aspectRatio: 16 / 9, child: c),
                    )))
                .toList(),
          ),
          const SizedBox(height: 8),
          Row(
            children: cards
                .sublist(3, 6)
                .map((c) => Expanded(child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: AspectRatio(aspectRatio: 16 / 9, child: c),
                    )))
                .toList(),
          ),
        ],
      );
    }

    // Mobile: 3 rows of 2 columns each (responsive, balanced)
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: AspectRatio(aspectRatio: 16 / 9, child: cards[0])),
            const SizedBox(width: 12),
            Expanded(child: AspectRatio(aspectRatio: 16 / 9, child: cards[1])),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: AspectRatio(aspectRatio: 16 / 9, child: cards[2])),
            const SizedBox(width: 12),
            Expanded(child: AspectRatio(aspectRatio: 16 / 9, child: cards[3])),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: AspectRatio(aspectRatio: 16 / 9, child: cards[4])),
            const SizedBox(width: 12),
            Expanded(child: AspectRatio(aspectRatio: 16 / 9, child: cards[5])),
          ],
        ),
      ],
    );
  }
}

// Single glassmorphic metric card — with hover scale
class _MetricCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final Color accentColor;
  final bool isAlert;

  const _MetricCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.accentColor,
    this.isAlert = false,
  });

  @override
  State<_MetricCard> createState() => _MetricCardState();
}

class _MetricCardState extends State<_MetricCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: _hovered ? 1.03 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: _hovered
                ? Colors.white.withValues(alpha: 0.10)
                : Colors.white.withValues(alpha: 0.05),
            border: Border(
              top: BorderSide(
                color: widget.isAlert
                    ? widget.accentColor.withValues(alpha: _hovered ? 0.9 : 0.6)
                    : Colors.white.withValues(alpha: _hovered ? 0.25 : 0.1),
                width: widget.isAlert ? 2 : 1,
              ),
              left: BorderSide(
                color: Colors.white.withValues(alpha: _hovered ? 0.14 : 0.08),
                width: 1,
              ),
              right: BorderSide(
                color: Colors.white.withValues(alpha: _hovered ? 0.14 : 0.08),
                width: 1,
              ),
              bottom: BorderSide(
                color: Colors.white.withValues(alpha: _hovered ? 0.14 : 0.08),
                width: 1,
              ),
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
                        color: Colors.white38,
                        fontSize: 7,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    widget.icon,
                    color: widget.accentColor.withValues(alpha: _hovered ? 1.0 : 0.7),
                    size: 12,
                  ),
                ],
              ),

              // Value
              Text(
                widget.value,
                style: GoogleFonts.inter(
                  color: widget.accentColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),

              // Subtitle
              Text(
                widget.subtitle,
                style: GoogleFonts.inter(
                  color: Colors.white54,
                  fontSize: 7.5,
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

  const _AlertBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFF9500).withValues(alpha: 0.12),
        border: Border.all(
          color: const Color(0xFFFF9500).withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, color: Color(0xFFFF9500), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.inter(
                color: const Color(0xFFFF9500),
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
void _showLocationSearchSheet(BuildContext context, WidgetRef ref) {
  final isEn = Localizations.localeOf(context).languageCode == 'en';
  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF0F121D),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    isScrollControlled: true,
    builder: (context) {
      return _LocationSearchWidget(isEn: isEn);
    },
  );
}

class _LocationSearchWidget extends ConsumerStatefulWidget {
  final bool isEn;
  const _LocationSearchWidget({required this.isEn});

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
                style: GoogleFonts.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white70),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: widget.isEn ? 'Search city or district...' : 'İl veya ilçe ara...',
              hintStyle: const TextStyle(color: Colors.white38),
              prefixIcon: const Icon(Icons.search, color: Colors.white54),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.05),
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
                ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.gps_fixed, size: 16),
            label: Text(widget.isEn ? 'Use GPS (My Fields)' : 'GPS Kullan (Tarlamın Konumu)'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF30D158).withValues(alpha: 0.15),
              foregroundColor: const Color(0xFF30D158),
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: const Color(0xFF30D158).withValues(alpha: 0.3)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Quick selections or search results
          Text(
            _searchResults.isNotEmpty 
                ? (widget.isEn ? 'Search Results' : 'Arama Sonuçları')
                : (widget.isEn ? 'Major Agricultural Hubs' : 'Önemli Tarım Merkezleri'),
            style: GoogleFonts.inter(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
          const SizedBox(height: 8),
          if (_searching)
            const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: Colors.white54)))
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
                    title: Text(item['label'] as String, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.white30),
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
                        color: Colors.white.withValues(alpha: 0.05),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item['name'] as String,
                        style: GoogleFonts.inter(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600),
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
