import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:tarim_app/core/theme/app_colors.dart';

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

  @override
  Widget build(BuildContext context) {
    final type = chartData['type'] as String?;
    final title = chartData['title'] as String?;
    final subtitle = chartData['subtitle'] as String?;
    final unit = chartData['unit'] as String? ?? '';
    final rawData = chartData['data'] as List<dynamic>?;

    if (type == null || rawData == null || rawData.isEmpty) return const SizedBox.shrink();

    final data = rawData.map((e) => e as Map<String, dynamic>).toList();
    final textColor = isDark ? AppColors.creamBackground : AppColors.earthText;
    final surfaceColor = isDark ? const Color(0xFF1A212A) : Colors.white;
    final borderColor = isDark ? const Color(0xFF2C394B) : const Color(0xFFEEEEEE);
    final subtleColor = isDark ? Colors.white38 : Colors.black38;

    final palette = [
      accent,
      const Color(0xFF4CAF50),
      const Color(0xFFFF9800),
      const Color(0xFF2196F3),
      const Color(0xFFE91E63),
      const Color(0xFF9C27B0),
      const Color(0xFF00BCD4),
    ];

    Widget chartWidget;

    switch (type) {
      case 'pie':
      case 'donut':
        chartWidget = _buildDonutChart(data, palette, textColor, subtleColor, unit, type == 'donut');
        break;
      case 'line':
        chartWidget = _buildLineChart(data, accent, textColor, subtleColor, isDark, unit);
        break;
      case 'horizontal_bar':
        chartWidget = _buildHorizontalBarChart(data, palette, textColor, subtleColor, unit);
        break;
      case 'stat':
      case 'cards':
        chartWidget = _buildStatCards(data, palette, textColor, surfaceColor, unit);
        break;
      default:
        chartWidget = _buildGradientBarChart(data, accent, textColor, subtleColor, isDark, unit);
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(width: 4, height: 20, decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 10),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null && title.isNotEmpty)
                  Text(title, style: GoogleFonts.libreFranklin(fontSize: 15, fontWeight: FontWeight.w800, color: textColor, height: 1.3)),
                if (subtitle != null && subtitle.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(subtitle, style: GoogleFonts.inter(fontSize: 11, color: subtleColor)),
                ],
              ],
            )),
          ]),
          const SizedBox(height: 24),
          chartWidget,
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text('TARIM PORTALI VERİ', style: GoogleFonts.inter(fontSize: 9, color: subtleColor, letterSpacing: 1.2)),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientBarChart(List<Map<String, dynamic>> data, Color accent,
      Color textColor, Color subtleColor, bool isDark, String unit) {
    final values = data.map((e) => (e['value'] as num).toDouble()).toList();
    final maxVal = values.reduce((a, b) => a > b ? a : b);

    return Column(
      children: data.asMap().entries.map((entry) {
        final item = entry.value;
        final value = (item['value'] as num).toDouble();
        final label = item['label'] as String;
        final pct = maxVal > 0 ? value / maxVal : 0.0;
        final isHighest = value == maxVal;

        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(child: Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: textColor), overflow: TextOverflow.ellipsis)),
              const SizedBox(width: 8),
              Text('${value % 1 == 0 ? value.toInt() : value.toStringAsFixed(1)}$unit',
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w900, color: isHighest ? accent : textColor)),
            ]),
            const SizedBox(height: 6),
            LayoutBuilder(builder: (ctx, bc) {
              return Stack(children: [
                Container(height: 8, width: bc.maxWidth, decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : const Color(0x14000000),
                  borderRadius: BorderRadius.circular(4),
                )),
                Container(
                  height: 8,
                  width: bc.maxWidth * pct,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [accent.withValues(alpha: 0.6), accent]),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ]);
            }),
          ]),
        );
      }).toList(),
    );
  }

  Widget _buildDonutChart(List<Map<String, dynamic>> data, List<Color> palette,
      Color textColor, Color subtleColor, String unit, bool isDonut) {
    final total = data.fold<double>(0, (s, e) => s + (e['value'] as num).toDouble());

    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Expanded(
        flex: 5,
        child: AspectRatio(
          aspectRatio: 1,
          child: PieChart(PieChartData(
            sectionsSpace: 3,
            centerSpaceRadius: isDonut ? 50 : 0,
            sections: data.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;
              final value = (item['value'] as num).toDouble();
              final pct = total > 0 ? (value / total * 100).toStringAsFixed(1) : '0';
              return PieChartSectionData(
                color: palette[i % palette.length],
                value: value,
                title: '$pct%',
                radius: 64,
                titleStyle: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white),
              );
            }).toList(),
          )),
        ),
      ),
      const SizedBox(width: 20),
      Expanded(
        flex: 4,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: data.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            final value = (item['value'] as num).toDouble();
            final label = item['label'] as String;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(children: [
                Container(width: 12, height: 12, decoration: BoxDecoration(color: palette[i % palette.length], borderRadius: BorderRadius.circular(3))),
                const SizedBox(width: 8),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: textColor), overflow: TextOverflow.ellipsis),
                  Text('${value % 1 == 0 ? value.toInt() : value.toStringAsFixed(1)}$unit',
                      style: GoogleFonts.inter(fontSize: 10, color: subtleColor)),
                ])),
              ]),
            );
          }).toList(),
        ),
      ),
    ]);
  }

  Widget _buildLineChart(List<Map<String, dynamic>> data, Color accent,
      Color textColor, Color subtleColor, bool isDark, String unit) {
    final spots = data.asMap().entries
        .map((e) => FlSpot(e.key.toDouble(), (e.value['value'] as num).toDouble()))
        .toList();
    final values = data.map((e) => (e['value'] as num).toDouble()).toList();
    final maxY = values.reduce((a, b) => a > b ? a : b) * 1.15;
    final minY = values.reduce((a, b) => a < b ? a : b) * 0.85;

    return AspectRatio(
      aspectRatio: 1.7,
      child: LineChart(LineChartData(
        minY: minY,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.35,
            color: accent,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                radius: 5,
                color: accent,
                strokeWidth: 2.5,
                strokeColor: isDark ? const Color(0xFF1A212A) : Colors.white,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [accent.withValues(alpha: 0.25), accent.withValues(alpha: 0.0)],
              ),
            ),
          ),
        ],
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 28,
            getTitlesWidget: (value, _) {
              final i = value.toInt();
              if (i >= 0 && i < data.length) {
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(data[i]['label'] as String,
                      style: GoogleFonts.inter(fontSize: 9, color: subtleColor, fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis),
                );
              }
              return const SizedBox.shrink();
            },
          )),
          leftTitles: AxisTitles(sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, _) => Text(
              '${value % 1 == 0 ? value.toInt() : value.toStringAsFixed(1)}',
              style: GoogleFonts.inter(fontSize: 9, color: subtleColor),
            ),
          )),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(color: isDark ? const Color(0x14FFFFFF) : const Color(0x14000000), strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (spots) => spots.map((s) => LineTooltipItem(
              '${s.y % 1 == 0 ? s.y.toInt() : s.y.toStringAsFixed(1)}$unit',
              GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
            )).toList(),
          ),
        ),
      )),
    );
  }

  Widget _buildHorizontalBarChart(List<Map<String, dynamic>> data, List<Color> palette,
      Color textColor, Color subtleColor, String unit) {
    final maxVal = data.map((e) => (e['value'] as num).toDouble()).reduce((a, b) => a > b ? a : b);

    return Column(
      children: data.asMap().entries.map((entry) {
        final i = entry.key;
        final item = entry.value;
        final value = (item['value'] as num).toDouble();
        final label = item['label'] as String;
        final pct = maxVal > 0 ? value / maxVal : 0.0;
        final color = palette[i % palette.length];

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(children: [
            SizedBox(
              width: 90,
              child: Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: textColor), overflow: TextOverflow.ellipsis, maxLines: 2),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: LayoutBuilder(builder: (ctx, bc) => Stack(children: [
                Container(height: 28, decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(4))),
                Container(height: 28, width: bc.maxWidth * pct, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
                Positioned.fill(child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Align(
                    alignment: pct > 0.4 ? Alignment.centerRight : Alignment.centerLeft,
                    child: Text('${value % 1 == 0 ? value.toInt() : value.toStringAsFixed(1)}$unit',
                        style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900,
                            color: pct > 0.4 ? Colors.white : color)),
                  ),
                )),
              ])),
            ),
          ]),
        );
      }).toList(),
    );
  }

  Widget _buildStatCards(List<Map<String, dynamic>> data, List<Color> palette,
      Color textColor, Color surfaceColor, String unit) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: data.asMap().entries.map((entry) {
        final i = entry.key;
        final item = entry.value;
        final value = (item['value'] as num).toDouble();
        final label = item['label'] as String;
        final change = item['change'] as String?;
        final color = palette[i % palette.length];

        return Container(
          width: 140,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.25), width: 1.5),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: color, letterSpacing: 0.5), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            Text('${value % 1 == 0 ? value.toInt() : value.toStringAsFixed(1)}$unit',
                style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w900, color: textColor)),
            if (change != null && change.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(change, style: GoogleFonts.inter(fontSize: 10, color: change.startsWith('+') ? Colors.green : Colors.red, fontWeight: FontWeight.w700)),
            ],
          ]),
        );
      }).toList(),
    );
  }
}
