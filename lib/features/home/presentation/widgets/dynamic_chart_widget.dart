import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';

// ══════════════════════════════════════════════════════════════════════════════
//  DynamicChartWidget — Tableau-grade editorial data visualization
//  Supports: bar · horizontal_bar · line · pie · donut · stat · cards · table
// ══════════════════════════════════════════════════════════════════════════════
double _parseDouble(dynamic val) {
  if (val == null) return 0.0;
  if (val is num) return val.toDouble();
  final str = val.toString().replaceAll(RegExp(r'[^0-9.\-]'), '');
  return double.tryParse(str) ?? 0.0;
}

String _formatValue(dynamic val) {
  if (val is String && double.tryParse(val.replaceAll(',', '.')) == null) return val; // Pure text
  final d = _parseDouble(val);
  return d % 1 == 0 ? d.toInt().toString() : d.toStringAsFixed(1);
}

class DynamicChartWidget extends StatelessWidget {
  final Map<String, dynamic> chartData;
  final bool isDark;
  final Color accent;

  const DynamicChartWidget({
    super.key,
    required this.chartData,
    required this.isDark,
    required this.accent,
  });

  // ── Palette ───────────────────────────────────────────────────────────────
  List<Color> get _palette => [
    accent,
    const Color(0xFF00BFA5),
    const Color(0xFFFF8F00),
    const Color(0xFF5C6BC0),
    const Color(0xFFEC407A),
    const Color(0xFF26A69A),
    const Color(0xFFAB47BC),
  ];

  Color get _surface => isDark ? const Color(0xFF141B24) : Colors.white;
  Color get _border  => isDark ? const Color(0xFF232F3E) : const Color(0xFFE8EDF2);
  Color get _text    => isDark ? const Color(0xFFE8EAED) : const Color(0xFF1C2B3A);
  Color get _subtle  => isDark ? const Color(0xFF7A8CA0) : const Color(0xFF8A9BB0);
  Color get _grid    => isDark ? const Color(0x18FFFFFF) : const Color(0x12000000);

  @override
  Widget build(BuildContext context) {
    final type     = chartData['type'] as String? ?? 'bar';
    final title    = chartData['title'] as String?;
    final subtitle = chartData['subtitle'] as String?;
    final unit     = chartData['unit'] as String? ?? '';
    final rawData  = chartData['data'] as List<dynamic>?;

    if (rawData == null || rawData.isEmpty) return const SizedBox.shrink();
    final data = rawData.cast<Map<String, dynamic>>();

    Widget body;
    switch (type) {
      case 'pie':
        body = _DonutChart(data: data, palette: _palette, text: _text, subtle: _subtle, unit: unit, isDonut: false);
        break;
      case 'donut':
        body = _DonutChart(data: data, palette: _palette, text: _text, subtle: _subtle, unit: unit, isDonut: true);
        break;
      case 'line':
        body = _LineChart(data: data, accent: accent, text: _text, subtle: _subtle, grid: _grid, isDark: isDark, unit: unit);
        break;
      case 'horizontal_bar':
        body = _HorizontalBar(data: data, palette: _palette, text: _text, subtle: _subtle, unit: unit, isDark: isDark);
        break;
      case 'stat':
      case 'cards':
        body = _StatCards(data: data, palette: _palette, text: _text, surface: _surface, unit: unit, border: _border);
        break;
      case 'table':
        body = _DataTable(data: data, text: _text, subtle: _subtle, accent: accent, border: _border, isDark: isDark);
        break;
      default:
        body = _GradientBar(data: data, accent: accent, text: _text, subtle: _subtle, isDark: isDark, unit: unit);
    }

    // Dar ekranda 24'er piksellik iç boşluk, 360 px'lik bir telefonda içeriğe
    // kalan yerin altıda birini yiyor. Tablo tam da orada sıkışıyor.
    final darMi = MediaQuery.of(context).size.width < 600;

    return Container(
      padding: EdgeInsets.all(darMi ? 16 : 24),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.06), blurRadius: 24, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────────
          if (title != null && title.isNotEmpty) ...[
            Row(children: [
              Container(
                width: 3, height: 18,
                decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(width: 10),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.playfairDisplay(
                    fontSize: 14, fontWeight: FontWeight.w800, color: _text, height: 1.3,
                  )),
                  if (subtitle != null && subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(subtitle, style: GoogleFonts.inter(fontSize: 11, color: _subtle, height: 1.4)),
                  ],
                ],
              )),
            ]),
            const SizedBox(height: 20),
          ],

          // ── Chart body ──────────────────────────────────────────────────
          body,

          // ── Watermark ───────────────────────────────────────────────────
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: Text('TARIM PORTALI', style: GoogleFonts.inter(
              fontSize: 8, color: _subtle.withValues(alpha: 0.5),
              letterSpacing: 1.8, fontWeight: FontWeight.w600,
            )),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  Gradient Bar (default)
// ══════════════════════════════════════════════════════════════════════════════
class _GradientBar extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final Color accent, text, subtle;
  final bool isDark;
  final String unit;
  const _GradientBar({required this.data, required this.accent, required this.text, required this.subtle, required this.isDark, required this.unit});

  @override
  Widget build(BuildContext context) {
    final values = data.map((e) => _parseDouble(e['value'])).toList();
    final maxVal = values.isNotEmpty ? values.reduce((a, b) => a > b ? a : b) : 0.0;

    return Column(
      children: data.asMap().entries.map((entry) {
        final item  = entry.value;
        final value = _parseDouble(item['value']);
        final label = item['label'] as String? ?? '';
        final change = item['change'] as String?;
        final pct   = maxVal > 0 ? value / maxVal : 0.0;
        final isMax = value == maxVal && value > 0;
        final formatted = _formatValue(item['value']);

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(label,
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: text),
                overflow: TextOverflow.ellipsis,
              )),
              const SizedBox(width: 12),
              Text('$formatted$unit',
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w900,
                  color: isMax ? accent : text),
              ),
              if (change != null && change.isNotEmpty) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: (change.startsWith('+') ? Colors.green : Colors.red).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(change,
                    style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800,
                      color: change.startsWith('+') ? const Color(0xFF2E7D32) : const Color(0xFFC62828)),
                  ),
                ),
              ],
            ]),
            const SizedBox(height: 8),
            LayoutBuilder(builder: (ctx, bc) => Stack(children: [
              Container(height: 6, width: bc.maxWidth,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0x10000000),
                  borderRadius: BorderRadius.circular(3),
                )),
              AnimatedContainer(
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                height: 6,
                width: bc.maxWidth * pct,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    isMax ? accent : accent.withValues(alpha: 0.6),
                    isMax ? accent : accent.withValues(alpha: 0.85),
                  ]),
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: isMax ? [BoxShadow(color: accent.withValues(alpha: 0.4), blurRadius: 6)] : [],
                ),
              ),
            ])),
          ]),
        );
      }).toList(),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  Horizontal Bar
// ══════════════════════════════════════════════════════════════════════════════
class _HorizontalBar extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final List<Color> palette;
  final Color text, subtle;
  final bool isDark;
  final String unit;
  const _HorizontalBar({required this.data, required this.palette, required this.text, required this.subtle, required this.isDark, required this.unit});

  @override
  Widget build(BuildContext context) {
    final values = data.map((e) => _parseDouble(e['value'])).toList();
    final maxVal = values.isNotEmpty ? values.reduce((a, b) => a > b ? a : b) : 0.0;

    return Column(
      children: data.asMap().entries.map((entry) {
        final i     = entry.key;
        final item  = entry.value;
        final value = _parseDouble(item['value']);
        final label = item['label'] as String? ?? '';
        final pct   = maxVal > 0 ? value / maxVal : 0.0;
        final color = palette[i % palette.length];
        final formatted = _formatValue(item['value']);

        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Row(children: [
            SizedBox(
              width: 100,
              child: Text(label,
                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: text),
                maxLines: 2, overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: LayoutBuilder(builder: (ctx, bc) => Stack(children: [
              Container(height: 32, width: bc.maxWidth,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                )),
              Container(height: 32, width: bc.maxWidth * pct,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [color.withValues(alpha: 0.75), color]),
                  borderRadius: BorderRadius.circular(6),
                )),
              Positioned.fill(child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Align(
                  alignment: pct > 0.45 ? Alignment.centerRight : Alignment.centerLeft,
                  child: Text('$formatted$unit',
                    style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900,
                      color: pct > 0.45 ? Colors.white : color),
                  ),
                ),
              )),
            ]))),
          ]),
        );
      }).toList(),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  Line Chart
// ══════════════════════════════════════════════════════════════════════════════
class _LineChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final Color accent, text, subtle, grid;
  final bool isDark;
  final String unit;
  const _LineChart({required this.data, required this.accent, required this.text, required this.subtle, required this.grid, required this.isDark, required this.unit});

  @override
  Widget build(BuildContext context) {
    final spots  = data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), _parseDouble(e.value['value']))).toList();
    final values = data.map((e) => _parseDouble(e['value'])).toList();
    final maxY   = values.isNotEmpty ? values.reduce((a, b) => a > b ? a : b) * 1.18 : 100.0;
    final minY   = values.isNotEmpty ? values.reduce((a, b) => a < b ? a : b) * 0.82 : 0.0;

    return AspectRatio(
      aspectRatio: 1.75,
      child: LineChart(LineChartData(
        minY: minY, maxY: maxY,
        lineBarsData: [LineChartBarData(
          spots: spots,
          isCurved: true,
          curveSmoothness: 0.4,
          color: accent,
          barWidth: 2.5,
          isStrokeCapRound: true,
          dotData: FlDotData(show: true, getDotPainter: (s, _, __, ___) => FlDotCirclePainter(
            radius: 4.5, color: accent,
            strokeWidth: 2, strokeColor: isDark ? const Color(0xFF141B24) : Colors.white,
          )),
          belowBarData: BarAreaData(show: true, gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [accent.withValues(alpha: 0.22), accent.withValues(alpha: 0.0)],
          )),
        )],
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(sideTitles: SideTitles(
            showTitles: true, reservedSize: 30,
            getTitlesWidget: (v, _) {
              final i = v.toInt();
              if (i >= 0 && i < data.length) {
                return Padding(padding: const EdgeInsets.only(top: 8),
                  child: Text(data[i]['label'] as String? ?? '',
                    style: GoogleFonts.inter(fontSize: 9, color: subtle, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          )),
          leftTitles: AxisTitles(sideTitles: SideTitles(
            showTitles: true, reservedSize: 44,
            getTitlesWidget: (v, _) => Text(
              v % 1 == 0 ? v.toInt().toString() : v.toStringAsFixed(1),
              style: GoogleFonts.inter(fontSize: 9, color: subtle),
            ),
          )),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true, drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(color: grid, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (spots) => spots.map((s) => LineTooltipItem(
            '${s.y % 1 == 0 ? s.y.toInt() : s.y.toStringAsFixed(1)}$unit',
            GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white),
          )).toList(),
        )),
      )),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  Donut / Pie Chart
// ══════════════════════════════════════════════════════════════════════════════
class _DonutChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final List<Color> palette;
  final Color text, subtle;
  final String unit;
  final bool isDonut;
  const _DonutChart({required this.data, required this.palette, required this.text, required this.subtle, required this.unit, required this.isDonut});

  @override
  Widget build(BuildContext context) {
    final total = data.fold<double>(0, (s, e) => s + _parseDouble(e['value']));

    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Expanded(flex: 5, child: AspectRatio(
        aspectRatio: 1,
        child: PieChart(PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: isDonut ? 52 : 0,
          sections: data.asMap().entries.map((entry) {
            final i     = entry.key;
            final item  = entry.value;
            final value = _parseDouble(item['value']);
            final pct   = total > 0 ? (value / total * 100).toStringAsFixed(1) : '0';
            return PieChartSectionData(
              color: palette[i % palette.length],
              value: value,
              title: '$pct%',
              radius: 62,
              titleStyle: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white, shadows: [const Shadow(color: Colors.black45, blurRadius: 4)]),
            );
          }).toList(),
        )),
      )),
      const SizedBox(width: 20),
      Expanded(flex: 4, child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: data.asMap().entries.map((entry) {
          final i     = entry.key;
          final item  = entry.value;
          final label = item['label'] as String? ?? '';
          final formatted = _formatValue(item['value']);
          final color = palette[i % palette.length];

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(children: [
              Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 8),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: text), overflow: TextOverflow.ellipsis, maxLines: 2),
                Text('$formatted$unit', style: GoogleFonts.inter(fontSize: 10, color: subtle)),
              ])),
            ]),
          );
        }).toList(),
      )),
    ]);
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  Stat Cards (KPI boxes)
// ══════════════════════════════════════════════════════════════════════════════
class _StatCards extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final List<Color> palette;
  final Color text, surface, border;
  final String unit;
  const _StatCards({required this.data, required this.palette, required this.text, required this.surface, required this.border, required this.unit});

  @override
  Widget build(BuildContext context) {
    // Tek rakam kendi düzenine gidiyor. Izgara bir rakamı da üçte bir
    // genişlikte çiziyordu: haberin TEK görsel öğesi, sol üst köşede küçük bir
    // rozet olarak duruyor, sağındaki üçte iki boş kalıyordu. Ölçümde yeni
    // hattan çıkan 16 haberin 1'i bu duruma düşüyor — nadir ama düştüğünde
    // öğe hiç konmamış gibi görünüyor.
    if (data.length == 1) {
      return _TekRakam(
        item: data.first,
        color: palette.first,
        text: text,
        surface: surface,
        unit: unit,
      );
    }

    return LayoutBuilder(builder: (ctx, bc) {
      // Sütun sayısı veri sayısını AŞAMAZ. Aşarsa iki rakam üç sütunluk
      // ızgarada duruyor ve son sütunun boşluğu "bir veri eksik" izlenimi
      // veriyordu.
      final colCount = data.length < (bc.maxWidth > 500 ? 3 : 2)
          ? data.length
          : (bc.maxWidth > 500 ? 3 : 2);
      final cardWidth = (bc.maxWidth - (colCount - 1) * 12) / colCount;

      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: data.asMap().entries.map((entry) {
          final i     = entry.key;
          final item  = entry.value;
          final label = item['label'] as String? ?? '';
          final change = item['change'] as String?;
          final icon   = item['icon'] as String?;
          final color  = palette[i % palette.length];
          final formatted = _formatValue(item['value']);
          final isPositive = change != null && change.startsWith('+');
          final isNegative = change != null && change.startsWith('-');

          return Container(
            width: cardWidth,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withValues(alpha: 0.25), width: 1.5),
              boxShadow: [BoxShadow(color: color.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, 4))],
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Expanded(child: Text(label,
                  style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: color, letterSpacing: 0.3),
                  maxLines: 2, overflow: TextOverflow.ellipsis,
                )),
                if (icon != null) Text(icon, style: const TextStyle(fontSize: 16)),
              ]),
              const SizedBox(height: 10),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text('$formatted$unit',
                  style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w900, color: text, height: 1.0),
                ),
              ),
              if (change != null && change.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: (isPositive ? Colors.green : isNegative ? Colors.red : Colors.grey).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(isPositive ? Icons.trending_up : isNegative ? Icons.trending_down : Icons.remove,
                      size: 12,
                      color: isPositive ? const Color(0xFF2E7D32) : isNegative ? const Color(0xFFC62828) : Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(change,
                      style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800,
                        color: isPositive ? const Color(0xFF2E7D32) : isNegative ? const Color(0xFFC62828) : Colors.grey),
                    ),
                  ]),
                ),
              ],
            ]),
          );
        }).toList(),
      );
    });
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  Tek rakam — gazetedeki "büyük sayı" kutusu
// ══════════════════════════════════════════════════════════════════════════════

/// Haberin tek sayısal bulgusunu tam genişlikte gösterir.
///
/// Neden ayrı bir düzen: kart ızgarası bir rakamı da üçte bir genişlikte
/// çiziyor. Üç rakam varken bu doğru — kartlar birbirini dengeliyor. Tek rakam
/// varken yanlış: okuyucu sayfada büyük boş bir alan ve köşede küçük bir kutu
/// görüyor, sayının önemli olduğunu değil bir şeyin eksik kaldığını düşünüyor.
/// Gazetenin bu duruma çözümü sayıyı büyütmek: rakam kutunun içinde değil,
/// kutunun kendisi oluyor.
class _TekRakam extends StatelessWidget {
  final Map<String, dynamic> item;
  final Color color;
  final Color text;
  final Color surface;
  final String unit;

  const _TekRakam({
    required this.item,
    required this.color,
    required this.text,
    required this.surface,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final label = item['label'] as String? ?? '';
    final change = item['change'] as String?;
    final formatted = _formatValue(item['value']);
    final isPositive = change != null && change.startsWith('+');
    final isNegative = change != null && change.startsWith('-');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(14),
        // Sol kenardaki kalın şerit gazetedeki "kesme kutusu" işareti: gövde
        // metnini okurken sayfanın bu bölümünün ayrı bir şey olduğunu
        // söylüyor. Izgarada bu iş kartların çokluğuyla zaten yapılıyordu.
        border: Border(
          left: BorderSide(color: color, width: 4),
          top: BorderSide(color: color.withValues(alpha: 0.20)),
          right: BorderSide(color: color.withValues(alpha: 0.20)),
          bottom: BorderSide(color: color.withValues(alpha: 0.20)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 10),
          // Rakam ve birim ayrı: aynı puntoda yazıldığında "16500TL/ton" tek
          // bir simge yığınına dönüşüyor, göz sayıyı ayrıştıramıyor.
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  formatted,
                  style: GoogleFonts.inter(
                    fontSize: 52,
                    fontWeight: FontWeight.w900,
                    color: text,
                    height: 1.0,
                    letterSpacing: -1.5,
                  ),
                ),
                if (unit.trim().isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Text(
                    unit.trim(),
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: text.withValues(alpha: 0.65),
                      height: 1.0,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (change != null && change.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isPositive
                      ? Icons.trending_up
                      : isNegative
                          ? Icons.trending_down
                          : Icons.remove,
                  size: 16,
                  color: isPositive
                      ? const Color(0xFF2E7D32)
                      : isNegative
                          ? const Color(0xFFC62828)
                          : Colors.grey,
                ),
                const SizedBox(width: 6),
                Text(
                  change,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: isPositive
                        ? const Color(0xFF2E7D32)
                        : isNegative
                            ? const Color(0xFFC62828)
                            : Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  Data Table
// ══════════════════════════════════════════════════════════════════════════════
class _DataTable extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final Color text, subtle, accent, border;
  final bool isDark;
  const _DataTable({required this.data, required this.text, required this.subtle, required this.accent, required this.border, required this.isDark});

  /// Bir sütunun başlık ve hücrelerindeki en uzun metnin karakter sayısı.
  int _enUzun(String baslik) {
    var uzunluk = baslik.length;
    for (final satir in data) {
      final hucre = satir[baslik]?.toString() ?? '';
      if (hucre.length > uzunluk) uzunluk = hucre.length;
    }
    return uzunluk;
  }

  /// Sütun genişlikleri İÇERİKTEN hesaplanıyor.
  ///
  /// Eskiden sabit `{0: FlexColumnWidth(2)}` vardı: ilk sütun, ne yazdığına
  /// bakılmaksızın diğerlerinin iki katı. Bu tablolarda sütun sırası
  /// Değer | Dönem | Ölçüm ve en kısa içerik ilk sütunda ("1 %"), en uzunu
  /// sonda ("Kışlık ürün verim tahmini üst düşüş oranı"). Yani genişliğin
  /// yarısı boş duran bir sütuna gidiyor, açıklama dörtte bire sıkışıp
  /// kırpılıyordu.
  ///
  /// Uçlar kırpılıyor: dört harflik bir sütun da okunacak kadar yer almalı
  /// (alt sınır), tek bir uzun hücre de tabloyu yutmamalı (üst sınır).
  Map<int, TableColumnWidth> _genislikler(List<String> basliklar) {
    return {
      for (var i = 0; i < basliklar.length; i++)
        i: FlexColumnWidth(_enUzun(basliklar[i]).clamp(8, 34).toDouble()),
    };
  }

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();

    final basliklar = data.first.keys.toList();
    if (basliklar.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, kutu) {
        final genislik = kutu.maxWidth;

        // Dar ekranda üç sütunu yan yana sıkıştırmak metni kesmiyor ama
        // okunmaz hale getiriyor: 90 px'lik bir sütunda "Kışlık ürün verim
        // tahmini üst düşüş oranı" yedi satıra iniyor ve tablo bir duvara
        // dönüyor. Sütun başına düşen yer bu eşiğin altındaysa satırlar
        // tablo yerine blok olarak diziliyor.
        // Eşik 120: 11 punto Inter'de bir sütuna 24 px iç boşluktan sonra
        // ~16 karakter kalıyor. Altına inince "564.188.810" gibi bölünemeyen
        // bir hücre satıra sığmıyor ve sayı ortadan ikiye ayrılıyor.
        final sutunBasina = genislik / basliklar.length;
        if (genislik.isFinite && sutunBasina < 120) {
          return _Yigin(
            data: data,
            basliklar: basliklar,
            aciklamaIndeksi: _aciklamaIndeksi(basliklar),
            text: text,
            subtle: subtle,
            accent: accent,
            border: border,
          );
        }

        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Table(
            border: TableBorder(
              horizontalInside: BorderSide(color: border, width: 1),
            ),
            columnWidths: _genislikler(basliklar),
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              TableRow(
                decoration: BoxDecoration(color: accent.withValues(alpha: 0.1)),
                children: basliklar.map((h) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Text(h,
                    style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: accent, letterSpacing: 0.5),
                  ),
                )).toList(),
              ),
              ...data.asMap().entries.map((entry) {
                final ciftMi = entry.key % 2 == 0;
                final satir = entry.value;
                return TableRow(
                  decoration: BoxDecoration(
                    color: ciftMi
                        ? (isDark ? Colors.white.withValues(alpha: 0.02) : Colors.black.withValues(alpha: 0.01))
                        : Colors.transparent,
                  ),
                  children: basliklar.map((h) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      // Kırpma YOK. Eskiden `TextOverflow.ellipsis` vardı ve
                      // dar sütuna sığmayan tek bir uzun sözcük hücreyi taşırıp
                      // dıştaki ClipRRect tarafından kesiliyordu: en sağdaki
                      // sütun yarım görünüyordu. Sarmak, kesmekten iyidir.
                      child: Text(satir[h]?.toString() ?? '',
                        style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: text, height: 1.35),
                      ),
                    );
                  }).toList(),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  /// Satırın ne anlattığını söyleyen sütun: içeriği en uzun olan.
  ///
  /// Sıra sabit değil — bu tablolarda açıklama sonda ("Ölçüm") ama başka bir
  /// tabloda başta olabilir. Konum yerine içerik uzunluğuna bakmak, sütun
  /// adlarına bağımlı kalmadan doğru sonucu veriyor.
  int _aciklamaIndeksi(List<String> basliklar) {
    var enIyi = 0;
    var enIyiUzunluk = -1;
    for (var i = 0; i < basliklar.length; i++) {
      final u = _enUzun(basliklar[i]);
      if (u > enIyiUzunluk) {
        enIyi = i;
        enIyiUzunluk = u;
      }
    }
    return enIyi;
  }
}

/// Dar ekranda tablonun yerini alan blok düzeni.
///
/// Her satır bir blok: üstte satırın ne anlattığı, altında diğer sütunlar
/// başlıklarıyla birlikte. Hiçbir bilgi düşmüyor — başlıklar da duruyor —
/// ama üç sütunu 90'ar piksele sıkıştırmak zorunda kalmıyoruz.
class _Yigin extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final List<String> basliklar;
  final int aciklamaIndeksi;
  final Color text, subtle, accent, border;

  const _Yigin({
    required this.data,
    required this.basliklar,
    required this.aciklamaIndeksi,
    required this.text,
    required this.subtle,
    required this.accent,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    final aciklamaBasligi = basliklar[aciklamaIndeksi];
    final digerleri = [
      for (var i = 0; i < basliklar.length; i++)
        if (i != aciklamaIndeksi) basliklar[i],
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < data.length; i++) ...[
          if (i > 0)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, thickness: 1, color: border),
            ),
          _YiginSatiri(
            aciklama: data[i][aciklamaBasligi]?.toString() ?? '',
            digerleri: {
              for (final h in digerleri) h: data[i][h]?.toString() ?? '',
            },
            text: text,
            subtle: subtle,
            accent: accent,
          ),
        ],
      ],
    );
  }
}

class _YiginSatiri extends StatelessWidget {
  final String aciklama;
  final Map<String, String> digerleri;
  final Color text, subtle, accent;

  const _YiginSatiri({
    required this.aciklama,
    required this.digerleri,
    required this.text,
    required this.subtle,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (aciklama.isNotEmpty)
          Text(
            aciklama,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: text,
              height: 1.35,
            ),
          ),
        if (digerleri.isNotEmpty) ...[
          const SizedBox(height: 8),
          // Wrap: iki değer yan yana sığmazsa alt alta geçiyor. Row olsaydı
          // uzun bir dönem metni ("1 Ocak-31 Temmuz 2026") taşardı.
          Wrap(
            spacing: 20,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.start,
            children: [
              for (final giris in digerleri.entries)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      giris.key.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: subtle,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      giris.value,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: accent,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ],
    );
  }
}
