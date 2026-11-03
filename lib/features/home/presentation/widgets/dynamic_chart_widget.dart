import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../core/utils/sayi_yazimi.dart';
import '../../../../core/utils/turkce_metin.dart';

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

/// Birim + dil ikilisini çizicilere birlikte taşıyan taşıyıcı.
///
/// **Neden bir nesne.** Eskiden çizicilere yalnızca `String unit` iniyor ve
/// her biri `'$formatted$unit'` diye birleştiriyordu: binlik ayıraç yok,
/// araya boşluk yok — `45000TL/ton`. Rakamı doğru yazmak için hem birimi hem
/// dili bilmek gerekiyor (`%45` ile `45%` farkı dile bağlı), bu yüzden ikisi
/// tek alanda dolaşıyor. Alan adı `unit` BIRAKILDI: altı çizicinin
/// kurucusunda ve çağrı yerlerinde tek satır değişmesin diye.
class _Birim {
  final String birim;
  final bool isEn;
  const _Birim(this.birim, this.isEn);

  /// Rakam + birim: `45.000 TL/ton`, `%45`.
  String yaz(dynamic ham) => birimliYaz(ham, birim, isEn);

  /// Birimsiz rakam — birimin ayrı çizildiği yerlerde (eksen, büyük rakam).
  String sade(dynamic ham) => degerYaz(ham, isEn);

  /// Pasta diliminin payı. Yüzde işareti Türkçede önde.
  String yuzde(num pay) => isEn ? '${sayiYaz(pay, true)}%' : '%${sayiYaz(pay, false)}';
}

/// Tablonun sütun başlıkları — BÜTÜN satırların birleşimi.
///
/// Eskiden `data.first.keys` okunuyordu: ilk satırda olmayan bir sütun hiç
/// çizilmiyor, taşıdığı bütün hücreler sessizce düşüyordu. Veri bir dil
/// modelinden geldiği için satırların aynı anahtar kümesini taşıdığı garanti
/// değil. Bugünkü 417 tablonun hiçbirinde fark yok — yani bu yama bir hatayı
/// değil, hata vermeden veri yutan bir yolu kapatıyor.
///
/// Sıra ilk görülme sırası: `Map` zaten ekleme sırasını koruyor, `Set` de
/// (LinkedHashSet) koruyor. Alfabetik sıralamak sütunları karıştırırdı.
List<String> sutunlariTopla(List<Map<String, dynamic>> data) {
  final s = <String>{};
  for (final satir in data) {
    s.addAll(satir.keys);
  }
  return s.toList();
}

class DynamicChartWidget extends StatelessWidget {
  final Map<String, dynamic> chartData;
  final bool isDark;
  final Color accent;

  /// Rakam yazımı ve büyük harf dönüşümü için ŞART — ikisi de dile bağlı.
  final bool isEn;

  /// Okurun yazı boyutu tercihi. Gövde metni bu çarpanla büyüyordu, grafik
  /// büyümüyordu: yazıyı 1,5 katına çıkaran okur için tablo hücresi 11
  /// puntoda kalıyordu. En çok büyütmeye ihtiyaç duyulan öğe en çok direnen
  /// öğeydi.
  final double olcek;

  /// Altlık boşsa kullanılacak kaynak/dönem künyesi. 1039 grafiğin 348'inde
  /// `subtitle` boş; bunların 316'sında aynı haberin `figures` dizisi kaynağı
  /// zaten taşıyor. Rakam yayınlayıp kaynağını yazmamak en pahalı eksik.
  final String? kunye;

  const DynamicChartWidget({
    super.key,
    required this.chartData,
    required this.isDark,
    required this.accent,
    required this.isEn,
    this.olcek = 1.0,
    this.kunye,
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
    final hamAlt   = (chartData['subtitle'] as String?)?.trim();
    // Altlık boşsa künyeye düşülüyor; künye de yoksa satır hiç çizilmiyor.
    final subtitle = (hamAlt != null && hamAlt.isNotEmpty) ? hamAlt : kunye?.trim();
    final unit     = _Birim(chartData['unit'] as String? ?? '', isEn);
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
        body = _DataTable(data: data, text: _text, subtle: _subtle, accent: accent, border: _border, isDark: isDark, isEn: isEn, olcek: olcek);
        break;
      default:
        body = _GradientBar(data: data, accent: accent, text: _text, subtle: _subtle, isDark: isDark, unit: unit);
    }

    // Dar ekranda 24'er piksellik iç boşluk, 360 px'lik bir telefonda içeriğe
    // kalan yerin altıda birini yiyor. Tablo tam da orada sıkışıyor.
    final mq = MediaQuery.of(context);
    final darMi = mq.size.width < 600;

    // Grafiğin düz metin karşılığı. CanvasKit bütün yazıyı tuvale boyuyor:
    // ekran okuyucu için erişilebilirlik ağacında bir karşılık YOKSA 417
    // tablonun bütün hücreleri ve 265 büyük rakam hiç okunmuyor.
    final okunur = _duzMetin(type, title, subtle_: subtitle, data: data, birim: unit);

    return Semantics(
      label: okunur,
      // Alt öğeler tek bir etikete TOPLANIYOR: aksi halde okuyucu önce bu
      // özeti, ardından aynı sayıları tek tek bir daha okuyor.
      excludeSemantics: true,
      child: MediaQuery(
        // Ölçek burada veriliyor, her `fontSize`a tek tek çarpan eklenmiyor:
        // bu dosyada 30'dan fazla `fontSize` var ve biri atlandığında hata
        // vermeden eski boyutta kalıyordu.
        data: mq.copyWith(textScaler: TextScaler.linear(olcek)),
        child: _govde(darMi: darMi, title: title, subtitle: subtitle, body: body),
      ),
    );
  }

  /// Grafiğin düz metin karşılığı — hem `Semantics` hem de ileride paylaşım
  /// için tek yerden üretiliyor.
  String _duzMetin(
    String type, String? title, {
    required String? subtle_,
    required List<Map<String, dynamic>> data,
    required _Birim birim,
  }) {
    final p = <String>[];
    final b = title?.trim() ?? '';
    if (b.isNotEmpty) p.add(b);
    final a = subtle_?.trim() ?? '';
    if (a.isNotEmpty) p.add(a);

    if (type == 'table') {
      final basliklar = sutunlariTopla(data);
      for (final satir in data) {
        p.add(basliklar
            .map((h) => '$h: ${satir[h]?.toString() ?? ''}')
            .join(', '));
      }
    } else {
      for (final item in data) {
        final etiket = (item['label'] ?? '').toString().trim();
        final deger = birim.yaz(item['value']);
        final degisim = (item['change'] ?? '').toString().trim();
        final satir = etiket.isEmpty ? deger : '$etiket: $deger';
        p.add(degisim.isEmpty ? satir : '$satir ($degisim)');
      }
    }
    return p.join('. ');
  }

  Widget _govde({
    required bool darMi,
    required String? title,
    required String? subtitle,
    required Widget body,
  }) {
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
                  Text(title, style: GoogleFonts.outfit(
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
  final _Birim unit;
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

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(label,
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: text),
                overflow: TextOverflow.ellipsis,
              )),
              const SizedBox(width: 12),
              Text(unit.yaz(item['value']),
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
  final _Birim unit;
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
                  child: Text(unit.yaz(item['value']),
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
  final _Birim unit;
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
              unit.sade(v),
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
            unit.yaz(s.y),
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
  final _Birim unit;
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
            final pct   = total > 0 ? value / total * 100 : 0.0;
            return PieChartSectionData(
              color: palette[i % palette.length],
              value: value,
              title: unit.yuzde(pct),
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
          final color = palette[i % palette.length];

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(children: [
              Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 8),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: text), overflow: TextOverflow.ellipsis, maxLines: 2),
                Text(unit.yaz(item['value']), style: GoogleFonts.inter(fontSize: 10, color: subtle)),
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
  final _Birim unit;
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
                child: Text(unit.yaz(item['value']),
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
  final _Birim unit;

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
    final formatted = unit.sade(item['value']);
    final isPositive = change != null && change.startsWith('+');
    final isNegative = change != null && change.startsWith('-');

    // Şerit kenarlığın PARÇASI DEĞİL, ayrı bir katman.
    //
    // Eskiden dört kenarı tek `Border`da toplanıyor ve soluna kalın renkli
    // bir `BorderSide` konuyordu — `borderRadius` ile birlikte. Flutter bunu
    // çizemiyor: yuvarlatılmış köşe yalnızca TEK RENKLİ kenarlıkta
    // destekleniyor, karışık renkte `paint()` assert atıyor. Yayın derlemesi
    // assert'leri attığı için canlıda hata görünmüyordu; görünen şey köşe
    // yuvarlamasının sessizce düşmesiydi. Bu yüzden kenarlık tek renge
    // indirildi, şerit `Positioned` olarak üstüne bindirildi — "kesme kutusu"
    // görüntüsü aynı kalıyor.
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: surface,
          border: Border.all(color: color.withValues(alpha: 0.20)),
        ),
        child: Stack(
          children: [
            // top/bottom birlikte verilince şerit kartın boyuna UZUYOR;
            // yüksekliği önceden bilmeye gerek kalmıyor.
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(width: 4, color: color),
            ),
            _icerik(label, formatted, change, isPositive, isNegative),
          ],
        ),
      ),
    );
  }

  Widget _icerik(String label, String formatted, String? change,
      bool isPositive, bool isNegative) {
    return Container(
      width: double.infinity,
      // Sol boşluk 4 px şerit kadar fazla: metin şeridin üstüne binmiyor.
      padding: const EdgeInsets.fromLTRB(24, 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            // Ham `toUpperCase()` DEĞİL: "Hibe" → "HIBE" oluyordu (§39.5).
            buyukHarf(label, unit.isEn),
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
                if (unit.birim.trim().isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Text(
                    unit.birim.trim(),
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
  final bool isEn;
  final double olcek;
  const _DataTable({required this.data, required this.text, required this.subtle, required this.accent, required this.border, required this.isDark, required this.isEn, required this.olcek});

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

    final basliklar = sutunlariTopla(data);
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
        // Eşik yazı ölçeğiyle BÜYÜYOR: okur yazıyı 1,5 katına çıkardığında
        // hücreye sığan karakter sayısı üçte bir azalıyor, yani yan yana
        // dizmenin sınırı yukarı kayıyor. Sabit 120 kalsaydı büyük puntoda
        // tablo yine duvara dönerdi — bu kez daha da erken.
        final sutunBasina = genislik / basliklar.length;
        if (genislik.isFinite && sutunBasina < 120 * olcek) {
          return _Yigin(
            data: data,
            basliklar: basliklar,
            aciklamaIndeksi: _aciklamaIndeksi(basliklar),
            text: text,
            subtle: subtle,
            accent: accent,
            border: border,
            isEn: isEn,
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
  final bool isEn;

  const _Yigin({
    required this.data,
    required this.basliklar,
    required this.aciklamaIndeksi,
    required this.text,
    required this.subtle,
    required this.accent,
    required this.border,
    required this.isEn,
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
            isEn: isEn,
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
  final bool isEn;

  const _YiginSatiri({
    required this.aciklama,
    required this.digerleri,
    required this.text,
    required this.subtle,
    required this.accent,
    required this.isEn,
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
                      // Sütun başlığı Türkçe: ham `toUpperCase()` "Birim"i
                      // "BIRIM" yazıyordu.
                      buyukHarf(giris.key, isEn),
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

/// Grafiğin altına yazılacak kaynak/dönem künyesi — `figures` dizisinden.
///
/// **Neden gerekli.** 1039 grafiğin 348'inde `chart_data.subtitle` boş; yani
/// her üç grafikten biri altında tek satır kaynak olmadan rakam yayınlıyor.
/// Aynı haberlerin 316'sında `figures` dizisi kaynağı ZATEN taşıyor — veri
/// elde, yalnızca çizilmiyordu.
///
/// Çizim anında üretiliyor, veritabanına yazılmıyor: 316 satırı güncellemek
/// geri alınamaz bir iş, bu yedek ise yarın gelen haberde de kendiliğinden
/// çalışıyor. Hat ileride `subtitle`ı doğrudan yazmaya başlarsa bu yol hiç
/// devreye girmez — dolu altlık her zaman önce geliyor.
///
/// Kaynak adları TEKİLLEŞTİRİLİYOR: beş rakamın beşi de TÜİK'ten geliyorsa
/// "TÜİK, TÜİK, TÜİK, TÜİK, TÜİK" yazmanın anlamı yok.
String? grafikKunyesi(List<dynamic>? figures, bool isEn) {
  if (figures == null || figures.isEmpty) return null;

  final kaynaklar = <String>{};
  final donemler = <String>{};
  for (final ham in figures) {
    if (ham is! Map) continue;
    final k = (ham['source'] ?? '').toString().trim();
    final d = (ham['period'] ?? '').toString().trim();
    if (k.isNotEmpty) kaynaklar.add(k);
    if (d.isNotEmpty) donemler.add(d);
  }
  if (kaynaklar.isEmpty && donemler.isEmpty) return null;

  final parcalar = <String>[];
  if (kaynaklar.isNotEmpty) {
    parcalar.add('${isEn ? 'Source' : 'Kaynak'}: ${kaynaklar.join(', ')}');
  }
  // Dönem yalnızca TEK ise yazılıyor. İki ayrı dönemden rakam taşıyan bir
  // grafikte "Dönem: 2024, 2025" okuru hangi rakamın hangi yıla ait olduğu
  // konusunda yanıltıyor; grafiğin kendi etiketleri bunu zaten söylüyor.
  if (donemler.length == 1) {
    parcalar.add('${isEn ? 'Period' : 'Dönem'}: ${donemler.first}');
  }
  return parcalar.join(' · ');
}
