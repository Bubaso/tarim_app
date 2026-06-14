// ignore_for_file: deprecated_member_use
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

// ─── Renk sistemi (Bloomberg Dark Terminal) ───────────────────────────────
const Color _kBg        = Color(0xFF070A0E); // saf terminal siyahı
const Color _kSurface   = Color(0xFF0F141C); // kart yüzeyi
const Color _kBorder    = Color(0xFF1E2631); // ince kenarlık
const Color _kGrid      = Color(0xFF111820); // grafik grid çizgisi
const Color _kUp        = Color(0xFF00FF00); // neon yeşil — artış
const Color _kDown      = Color(0xFFFF0000); // elektrik kırmızısı — düşüş
const Color _kNeutral   = Color(0xFF546E7A); // nötr gri-mavi
const Color _kLabel     = Color(0xFF90A4AE); // ikincil etiketler
const Color _kLive      = Color(0xFF00FF00); // LIVE nokta

// ─── Veri modeli ──────────────────────────────────────────────────────────
class _Commodity {
  final String nameEn;
  final String nameTr;
  final String code;
  final String exchange;
  final String price;
  final String unit;
  final String changeText;
  final double changePercentage;
  final List<FlSpot> spots;   // 7 günlük mock veri
  final double minY;
  final double maxY;

  const _Commodity({
    required this.nameEn,
    required this.nameTr,
    required this.code,
    required this.exchange,
    required this.price,
    required this.unit,
    required this.changeText,
    required this.changePercentage,
    required this.spots,
    required this.minY,
    required this.maxY,
  });
}

// ─── Mock veri — 7 günlük gerçekçi koordinatlar ──────────────────────────
const _commodities = [
  _Commodity(
    nameEn:           'London Sugar No.5',
    nameTr:           'Londra Şeker No.5',
    code:             'LSUG5',
    exchange:         'ICE EUROPE',
    price:            '540.20',
    unit:             r'$/Ton',
    changeText:       '+0.85%',
    changePercentage:  0.85,
    spots: [
      FlSpot(0, 532.0), FlSpot(1, 528.5), FlSpot(2, 535.8),
      FlSpot(3, 531.2), FlSpot(4, 537.4), FlSpot(5, 534.9),
      FlSpot(6, 540.2),
    ],
    minY: 524.0,
    maxY: 545.0,
  ),
  _Commodity(
    nameEn:           'New York Sugar No.11',
    nameTr:           'New York Şeker No.11',
    code:             'SUG11',
    exchange:         'ICE US',
    price:            '14.24',
    unit:             '¢/Lb',
    changeText:       '-1.22%',
    changePercentage: -1.22,
    spots: [
      FlSpot(0, 14.52), FlSpot(1, 14.63), FlSpot(2, 14.41),
      FlSpot(3, 14.58), FlSpot(4, 14.38), FlSpot(5, 14.31),
      FlSpot(6, 14.24),
    ],
    minY: 14.10,
    maxY: 14.75,
  ),
  _Commodity(
    nameEn:           'Diesel (Istanbul)',
    nameTr:           'Mazot / Motorin (İstanbul)',
    code:             'DSL.TR',
    exchange:         'EPİAŞ',
    price:            '66.33',
    unit:             'TL/Lt',
    changeText:       '-0.05%',
    changePercentage: -0.05,
    spots: [
      FlSpot(0, 66.52), FlSpot(1, 66.44), FlSpot(2, 66.60),
      FlSpot(3, 66.40), FlSpot(4, 66.50), FlSpot(5, 66.37),
      FlSpot(6, 66.33),
    ],
    minY: 66.10,
    maxY: 66.75,
  ),
  _Commodity(
    nameEn:           'Wheat (CBOT)',
    nameTr:           'Buğday (CBOT Vadeli)',
    code:             'ZW1',
    exchange:         'CME / CBOT',
    price:            '5.85',
    unit:             r'$/Bu',
    changeText:       '-0.38%',
    changePercentage: -0.38,
    spots: [
      FlSpot(0, 5.93), FlSpot(1, 5.91), FlSpot(2, 5.96),
      FlSpot(3, 5.89), FlSpot(4, 5.92), FlSpot(5, 5.87),
      FlSpot(6, 5.85),
    ],
    minY: 5.78,
    maxY: 6.00,
  ),
];

// ═══════════════════════════════════════════════════════════════════════════
//  FinancialTerminalScreen
// ═══════════════════════════════════════════════════════════════════════════

class FinancialTerminalScreen extends StatelessWidget {
  const FinancialTerminalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isEn   = Localizations.localeOf(context).languageCode == 'en';
    final width  = MediaQuery.of(context).size.width;
    final isWide = width >= 900;

    return Theme(
      // Bu sayfa her zaman tam dark — sistem temasından bağımsız
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: _kBg,
      ),
      child: Scaffold(
        backgroundColor: _kBg,
        appBar: _buildAppBar(context, isEn),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? 32 : 16,
              vertical: 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Terminal başlığı ────────────────────────────────────
                _TerminalHeader(isEn: isEn),
                const SizedBox(height: 20),

                // ── Özet şerit (4 emtia mini-stat) ─────────────────────
                _SummaryStrip(isEn: isEn),
                const SizedBox(height: 24),

                // ── Grafik kartları ─────────────────────────────────────
                // Masaüstünde 2 sütun, mobilde tek sütun
                // Her kart içinde AspectRatio(16/9) grafik alanı var.
                isWide
                    ? _TwoColumnGrid(isEn: isEn)
                    : _SingleColumnList(isEn: isEn),

                const SizedBox(height: 32),

                // ── Alt bilgi ───────────────────────────────────────────
                _Footer(isEn: isEn),
              ],
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, bool isEn) {
    return AppBar(
      backgroundColor: _kSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: const Border(
        bottom: BorderSide(color: _kBorder, width: 1),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            size: 18, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _LiveDot(),
          const SizedBox(width: 8),
          Text(
            isEn ? 'MARKET TERMINAL' : 'FİNANS TERMİNALİ',
            style: GoogleFonts.robotoMono(
              fontWeight: FontWeight.w700,
              color: Colors.white,
              fontSize: 14,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Center(
            child: _ClockWidget(),
          ),
        ),
      ],
    );
  }
}

// ─── Canlı saat (her saniye güncellenir) ─────────────────────────────────

class _ClockWidget extends StatefulWidget {
  @override
  State<_ClockWidget> createState() => _ClockWidgetState();
}

class _ClockWidgetState extends State<_ClockWidget> {
  late Timer _timer;
  late String _time;

  @override
  void initState() {
    super.initState();
    _time = _fmt();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _time = _fmt());
    });
  }

  String _fmt() => DateFormat('HH:mm:ss').format(DateTime.now());

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _time,
      style: GoogleFonts.robotoMono(
        color: _kLabel,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.0,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  Terminal Başlığı
// ═══════════════════════════════════════════════════════════════════════════

class _TerminalHeader extends StatelessWidget {
  final bool isEn;

  const _TerminalHeader({required this.isEn});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Üst çizgi — 2px
        Container(height: 2, color: const Color(0xFF00E676)),
        const SizedBox(height: 12),

        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEn
                        ? 'GLOBAL COMMODITY & AGRI EXCHANGE'
                        : 'KÜRESEL EMTİA & TARIM BORSASI',
                    style: GoogleFonts.robotoMono(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isEn
                        ? 'Real-time agricultural commodities feed'
                        : 'Tarım emtia fiyatları — anlık veri akışı',
                    style: GoogleFonts.robotoMono(
                      color: _kLabel,
                      fontSize: 11,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            // "MOCK DATA" uyarı etiketi
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF546E7A)),
                color: const Color(0xFF0F141C),
              ),
              child: Text(
                isEn ? 'DEMO DATA' : 'DEMO VERİ',
                style: GoogleFonts.robotoMono(
                  color: _kLabel,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),
        Container(height: 1, color: _kBorder),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  Özet Şerit — 4 emtia mini-stat yatayda
// ═══════════════════════════════════════════════════════════════════════════

class _SummaryStrip extends StatelessWidget {
  final bool isEn;

  const _SummaryStrip({required this.isEn});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _commodities.asMap().entries.map((entry) {
          final i = entry.key;
          final c = entry.value;
          return Padding(
            padding: EdgeInsets.only(right: i < _commodities.length - 1 ? 12 : 0),
            child: _MiniStatCard(commodity: c, isEn: isEn),
          );
        }).toList(),
      ),
    );
  }
}

class _MiniStatCard extends StatefulWidget {
  final _Commodity commodity;
  final bool isEn;

  const _MiniStatCard({required this.commodity, required this.isEn});

  @override
  State<_MiniStatCard> createState() => _MiniStatCardState();
}

class _MiniStatCardState extends State<_MiniStatCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isUp = widget.commodity.changePercentage >= 0;
    final clr  = isUp ? _kUp : _kDown;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 160,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: _hovered ? const Color(0xFF161E2A) : _kSurface,
          border: Border.all(
            color: _hovered ? clr.withValues(alpha: 0.5) : _kBorder,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.commodity.code,
              style: GoogleFonts.robotoMono(
                color: _kLabel,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${widget.commodity.price} ${widget.commodity.unit}',
              style: GoogleFonts.robotoMono(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 3),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isUp ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  color: clr,
                  size: 14,
                ),
                Text(
                  widget.commodity.changeText,
                  style: GoogleFonts.robotoMono(
                    color: clr,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  Masaüstü: 2 sütunlu grid
// ═══════════════════════════════════════════════════════════════════════════

class _TwoColumnGrid extends StatelessWidget {
  final bool isEn;

  const _TwoColumnGrid({required this.isEn});

  @override
  Widget build(BuildContext context) {
    // Her kart tam genişlikte, oran 16:9.
    // 2 sütun için kartları çiftler halinde Row'a diziyoruz.
    final rows = <Widget>[];
    for (int i = 0; i < _commodities.length; i += 2) {
      final left  = _commodities[i];
      final right = (i + 1 < _commodities.length) ? _commodities[i + 1] : null;
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _CommodityCard(commodity: left, isEn: isEn)),
            if (right != null) ...[
              const SizedBox(width: 16),
              Expanded(child: _CommodityCard(commodity: right, isEn: isEn)),
            ],
          ],
        ),
      );
      if (i + 2 < _commodities.length) rows.add(const SizedBox(height: 16));
    }
    return Column(children: rows);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  Mobil: tek sütun liste
// ═══════════════════════════════════════════════════════════════════════════

class _SingleColumnList extends StatelessWidget {
  final bool isEn;

  const _SingleColumnList({required this.isEn});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _commodities.asMap().entries.map((entry) {
        final i = entry.key;
        final c = entry.value;
        return Padding(
          padding: EdgeInsets.only(bottom: i < _commodities.length - 1 ? 16 : 0),
          child: _CommodityCard(commodity: c, isEn: isEn),
        );
      }).toList(),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  Emtia Grafik Kartı
//
//  Yapı:
//  ┌─────────────────────────────────────┐
//  │ [Header: İsim | Kod | LIVE●]        │
//  ├─────────────────────────────────────┤
//  │ [Fiyat | Değişim | Borsa]           │  ← sabit yükseklik
//  ├─────────────────────────────────────┤
//  │ [AspectRatio(16/9) → LineChart]     │  ← KRİTİK 16:9 grafik
//  └─────────────────────────────────────┘
// ═══════════════════════════════════════════════════════════════════════════

class _CommodityCard extends StatefulWidget {
  final _Commodity commodity;
  final bool isEn;

  const _CommodityCard({required this.commodity, required this.isEn});

  @override
  State<_CommodityCard> createState() => _CommodityCardState();
}

class _CommodityCardState extends State<_CommodityCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isUp  = widget.commodity.changePercentage >= 0;
    final clr   = isUp ? _kUp : _kDown;
    final name  = widget.isEn ? widget.commodity.nameEn : widget.commodity.nameTr;
    final arrow = isUp ? '▲' : '▼';

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: _hovered ? 1.015 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: _hovered ? const Color(0xFF131B26) : _kSurface,
              border: Border.all(
                color: _hovered ? clr.withValues(alpha: 0.35) : _kBorder,
                width: 1.0,
              ),
              boxShadow: _hovered
                  ? [
                      BoxShadow(
                        color: clr.withValues(alpha: 0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Kart başlığı ──────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name.toUpperCase(),
                              style: GoogleFonts.robotoMono(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${widget.commodity.code}  ·  ${widget.commodity.exchange}',
                              style: GoogleFonts.robotoMono(
                                color: _kLabel,
                                fontSize: 9,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // LIVE rozet
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const _LiveDot(),
                          const SizedBox(width: 5),
                          Text(
                            'LIVE',
                            style: GoogleFonts.robotoMono(
                              color: _kLive,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Yatay çizgi
                Container(height: 1, color: _kBorder),

                // ── Fiyat satırı ──────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '${widget.commodity.price} ${widget.commodity.unit}',
                        style: GoogleFonts.robotoMono(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: clr.withValues(alpha: 0.1),
                          border: Border.all(color: clr.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          '$arrow  ${widget.commodity.changeText}',
                          style: GoogleFonts.robotoMono(
                            color: clr,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Yatay çizgi
                Container(height: 1, color: _kGrid),

                // ── Grafik alanı (Expanded) ──────────────────────────────
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
                    child: _TrendChart(
                      commodity: widget.commodity,
                      isUp: isUp,
                      color: clr,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  Trend Çizgi Grafiği (fl_chart)
// ═══════════════════════════════════════════════════════════════════════════

class _TrendChart extends StatelessWidget {
  final _Commodity commodity;
  final bool isUp;
  final Color color;

  const _TrendChart({
    required this.commodity,
    required this.isUp,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    // Y ekseni etiket formatı — kısa sayı
    String fmtY(double v) {
      if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}k';
      if (v >= 100)  return v.toStringAsFixed(1);
      return v.toStringAsFixed(2);
    }

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: 6,
        minY: commodity.minY,
        maxY: commodity.maxY,

        // Grid — sadece yatay, ince ve karanlık
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (commodity.maxY - commodity.minY) / 4,
          getDrawingHorizontalLine: (_) => FlLine(
            color: _kGrid,
            strokeWidth: 1,
            dashArray: [4, 4],
          ),
        ),

        // Kenarlık yok
        borderData: FlBorderData(show: false),

        // Eksen etiketleri: sadece sol, mini Roboto Mono
        titlesData: FlTitlesData(
          topTitles:    AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:  AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (val, meta) {
                const days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
                final idx  = val.toInt();
                if (idx < 0 || idx >= days.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    days[idx],
                    style: GoogleFonts.robotoMono(
                      color: _kLabel,
                      fontSize: 8,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 44,
              interval: (commodity.maxY - commodity.minY) / 4,
              getTitlesWidget: (val, meta) {
                return Text(
                  fmtY(val),
                  style: GoogleFonts.robotoMono(
                    color: _kLabel,
                    fontSize: 8,
                  ),
                  textAlign: TextAlign.right,
                );
              },
            ),
          ),
        ),

        // Tooltip — nokta üzerine gelince değer göster
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => const Color(0xFF1A2332),
            tooltipBorder: BorderSide(color: color.withValues(alpha: 0.5)),
            getTooltipItems: (spots) => spots.map((s) {
              return LineTooltipItem(
                fmtY(s.y),
                GoogleFonts.robotoMono(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              );
            }).toList(),
          ),
          getTouchedSpotIndicator: (barData, indices) => indices.map((i) {
            return TouchedSpotIndicatorData(
              FlLine(color: color.withValues(alpha: 0.5), strokeWidth: 1),
              FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                  radius: 4,
                  color: color,
                  strokeWidth: 0,
                ),
              ),
            );
          }).toList(),
        ),

        // Grafik çizgisi
        lineBarsData: [
          LineChartBarData(
            spots: commodity.spots,
            isCurved: true,
            curveSmoothness: 0.35,
            color: color,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              // Sadece son nokta görünsün
              checkToShowDot: (spot, barData) =>
                  spot.x == barData.spots.last.x,
              getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                radius: 3.5,
                color: color,
                strokeWidth: 1.5,
                strokeColor: Colors.white,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  color.withValues(alpha: 0.20),
                  color.withValues(alpha: 0.00),
                ],
              ),
            ),
          ),
        ],
      ),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  Yanıp sönen LIVE noktası
// ═══════════════════════════════════════════════════════════════════════════

class _LiveDot extends StatefulWidget {
  const _LiveDot();

  @override
  State<_LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<_LiveDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _ctrl,
      child: Container(
        width: 7,
        height: 7,
        decoration: const BoxDecoration(
          color: _kLive,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Color(0x6600FF00),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  Alt Bilgi
// ═══════════════════════════════════════════════════════════════════════════

class _Footer extends StatelessWidget {
  final bool isEn;

  const _Footer({required this.isEn});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(height: 1, color: _kBorder),
        const SizedBox(height: 12),
        Text(
          isEn
              ? '* Prices are simulated demo data for UI preview only. '
                'Live integration is pending real-time API connection.'
              : '* Fiyatlar yalnızca arayüz önizlemesi için simüle edilmiş demo '
                'verilerdir. Canlı entegrasyon, gerçek zamanlı API bağlantısı '
                'kurulduğunda aktif olacaktır.',
          style: GoogleFonts.robotoMono(
            color: _kNeutral,
            fontSize: 9,
            height: 1.6,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}
