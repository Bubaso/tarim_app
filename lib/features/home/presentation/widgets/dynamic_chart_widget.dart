import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:tarim_app/core/theme/app_colors.dart';

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

    return Container(
      padding: const EdgeInsets.all(24),
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
                  Text(title, style: GoogleFonts.libreFranklin(
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
          final value = _parseDouble(item['value']);
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
    return LayoutBuilder(builder: (ctx, bc) {
      // Responsive: 2 columns on narrow, more on wide
      final colCount = bc.maxWidth > 500 ? 3 : 2;
      final cardWidth = (bc.maxWidth - (colCount - 1) * 12) / colCount;

      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: data.asMap().entries.map((entry) {
          final i     = entry.key;
          final item  = entry.value;
          final value = _parseDouble(item['value']);
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
//  Data Table
// ══════════════════════════════════════════════════════════════════════════════
class _DataTable extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final Color text, subtle, accent, border;
  final bool isDark;
  const _DataTable({required this.data, required this.text, required this.subtle, required this.accent, required this.border, required this.isDark});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();

    // Extract headers from first row keys (excluding 'label')
    final firstRow = data.first;
    final headers = firstRow.keys.toList();

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Table(
        border: TableBorder(
          horizontalInside: BorderSide(color: border, width: 1),
        ),
        columnWidths: const {0: FlexColumnWidth(2)},
        children: [
          // Header row
          TableRow(
            decoration: BoxDecoration(color: accent.withValues(alpha: 0.1)),
            children: headers.map((h) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Text(h,
                style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: accent, letterSpacing: 0.5),
                overflow: TextOverflow.ellipsis,
              ),
            )).toList(),
          ),
          // Data rows
          ...data.asMap().entries.map((entry) {
            final isEven = entry.key % 2 == 0;
            final row = entry.value;
            return TableRow(
              decoration: BoxDecoration(
                color: isEven
                    ? (isDark ? Colors.white.withValues(alpha: 0.02) : Colors.black.withValues(alpha: 0.01))
                    : Colors.transparent,
              ),
              children: headers.map((h) {
                final val = row[h]?.toString() ?? '';
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Text(val,
                    style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: text),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }
}
