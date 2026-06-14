// ignore_for_file: deprecated_member_use
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/weather_info.dart';

// ══════════════════════════════════════════════════════════════════════════════
//  WeatherDetailScreen  —  Zirai İklim ve Uyarı Merkezi
//  Apple Weather aesthetic · Dynamic gradient · 16:9 forecast block
//  Agricultural metrics: wind · humidity · frost warning · soil temperature
// ══════════════════════════════════════════════════════════════════════════════
class WeatherDetailScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final isEn = Localizations.localeOf(context).languageCode == 'en';

    // ── Agricultural computations ─────────────────────────────────────────
    const windSpeed    = 14.0;   // km/h — mock
    const humidity     = 62;     // %   — mock
    final soilTemp     = (weather.temperature - 2.5).clamp(1.0, 35.0);
    final hasFrostRisk = weather.temperature <= 4.0;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFF0A0D1A),
      appBar: _buildAppBar(context, isEn),
      body: Container(
        decoration: BoxDecoration(gradient: _gradient(weather.iconCode)),
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
                    _HeroTemperature(weather: weather, isEn: isEn),
                    const SizedBox(height: 32),

                    // 2. ── 16:9 Main Forecast Card ─────────────────────────
                    _ForecastCard(weather: weather, isEn: isEn),
                    const SizedBox(height: 20),

                    // 3. ── Agricultural Metrics Grid ──────────────────────
                    _MetricsGrid(
                      isEn:          isEn,
                      windSpeed:     windSpeed,
                      humidity:      humidity,
                      soilTemp:      soilTemp,
                      hasFrostRisk:  hasFrostRisk,
                      temperature:   weather.temperature,
                    ),
                    const SizedBox(height: 20),

                    // 4. ── Agricultural Alert Banner ───────────────────────
                    if (weather.hasWarning)
                      _AlertBanner(message: weather.agriculturalWarning),
                  ],
                ),
              ),
            ),
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
class _HeroTemperature extends StatelessWidget {
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
  Widget build(BuildContext context) {
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

        // City name
        Text(
          weather.city.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 2.0,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),

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

                  // ── Mini 7-day bar chart ─────────────────────────────────
                  const SizedBox(height: 8),
                  _MiniBarChart(isEn: isEn, baseTemp: weather.temperature),
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

// Mini 7-day temperature bar chart
class _MiniBarChart extends StatelessWidget {
  final bool isEn;
  final double baseTemp;

  const _MiniBarChart({required this.isEn, required this.baseTemp});

  @override
  Widget build(BuildContext context) {
    // Generate plausible 7-day temp variations around baseTemp
    final math.Random rng = math.Random(42);
    final days = isEn
        ? ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN']
        : ['PTSİ', 'SAL', 'ÇAR', 'PER', 'CUM', 'CMT', 'PZR'];
    final temps = List.generate(7, (i) {
      final delta = (rng.nextDouble() - 0.5) * 8;
      return (baseTemp + delta).clamp(-10.0, 45.0);
    });
    final maxT = temps.reduce(math.max);
    final minT = temps.reduce(math.min);
    final range = (maxT - minT).clamp(1.0, 100.0);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(7, (i) {
        final frac = ((temps[i] - minT) / range).clamp(0.05, 1.0);
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '${temps[i].toStringAsFixed(0)}°',
                  style: GoogleFonts.inter(
                    color: Colors.white54,
                    fontSize: 7,
                    fontWeight: FontWeight.w600,
                  ),
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
//  _MetricsGrid  —  2×2 agricultural metric glassmorphic cards (16:9 each)
// ══════════════════════════════════════════════════════════════════════════════
class _MetricsGrid extends StatelessWidget {
  final bool isEn;
  final double windSpeed;
  final int humidity;
  final double soilTemp;
  final bool hasFrostRisk;
  final double temperature;

  const _MetricsGrid({
    required this.isEn,
    required this.windSpeed,
    required this.humidity,
    required this.soilTemp,
    required this.hasFrostRisk,
    required this.temperature,
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
    ];

    if (isDesktop) {
      return Row(
        children: cards
            .map((c) => Expanded(child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: AspectRatio(aspectRatio: 16 / 9, child: c),
                )))
            .toList(),
      );
    }

    // Mobile: 2×2 grid using Column + Row (avoids shrinkWrap GridView issues)
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
                  Text(
                    widget.title,
                    style: GoogleFonts.inter(
                      color: Colors.white38,
                      fontSize: 7,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
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
                  fontSize: 15,
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
