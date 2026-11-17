import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../data/yz_grafik_veri.dart';
import 'yz_tasarim.dart';

/// Bölüm grafiklerinin çizicisi (karar 58).
///
/// İlke: grafik metnin söylediğini görünür kılar, yeni bir şey söylemez.
/// Her değer kayıttan gelir (dogrula_bolumler.py kural 11); her kartta
/// başlık, kısa açıklama, kaynak satırı ve "tablo olarak gör" var. Değerler
/// grafiğin üstüne yazılı (okur değeri bulmak için fareyi gezdirmek zorunda
/// değil); bir kategoriye dokunmak ya da üstüne gelmek onu öne çıkarıp
/// ötekileri soldurur ve ayrıntısını kartın altına yazar.
///
/// Türler: yatay_cubuk, dikey_cubuk, cizgi, alan, dumbbell, aralik, pay,
/// waffle, egim, kpi, isi, zaman.

/// Dizilerin renkleri, sırayla. Bölümün paletiyle (çelik mavisi, bitki
/// yeşili, toprak sarısı) uyumlu; renk körlüğünde ilk üçü birbirinden ayrılıyor.
const List<Color> kYzGrafikRenkleri = [
  YzRenk.makine,
  YzRenk.bitki,
  YzRenk.bekleyen,
  Color(0xFF9A4C3D),
  Color(0xFF6C7A86),
];

Color _renk(YzGrafik g, String dizi) {
  final i = g.diziler.indexWhere((d) => d.kod == dizi);
  return kYzGrafikRenkleri[(i < 0 ? 0 : i) % kYzGrafikRenkleri.length];
}

bool _hareketsiz(BuildContext c) => MediaQuery.maybeOf(c)?.disableAnimations ?? false;

String _yil(double v) => v.round().toString();

class YzGrafikKarti extends StatefulWidget {
  const YzGrafikKarti({super.key, required this.grafik, required this.en});
  final YzGrafik grafik;
  final bool en;

  @override
  State<YzGrafikKarti> createState() => _YzGrafikKartiState();
}

class _YzGrafikKartiState extends State<YzGrafikKarti> {
  bool _tablo = false;
  String? _secili;

  void _sec(String? k) => setState(() => _secili = _secili == k ? null : k);

  @override
  Widget build(BuildContext context) {
    final g = widget.grafik;
    final en = widget.en;
    final govde = _tablo
        ? _Tablo(g: g, en: en)
        : switch (g.tur) {
            'yatay_cubuk' => _YatayCubuk(g: g, en: en, secili: _secili, sec: _sec),
            'dikey_cubuk' => _DikeyCubuk(g: g, en: en, secili: _secili, sec: _sec),
            'cizgi' || 'alan' => _Cizgi(g: g, en: en, alan: g.tur == 'alan'),
            'dumbbell' => _Dumbbell(g: g, en: en, secili: _secili, sec: _sec),
            'aralik' => _Aralik(g: g, en: en, secili: _secili, sec: _sec),
            'pay' => _Pay(g: g, en: en, secili: _secili, sec: _sec),
            'waffle' => _Waffle(g: g, en: en),
            'egim' => _Egim(g: g, en: en, secili: _secili, sec: _sec),
            'kpi' => _Kpi(g: g, en: en),
            'isi' => _Isi(g: g, en: en),
            'zaman' => _Zaman(g: g, en: en),
            _ => _Tablo(g: g, en: en),
          };
    final ayrinti = _secili == null
        ? null
        : [
            for (final n in g.noktalar)
              if (n.kategori(en) == _secili)
                '${g.diziler.length > 1 ? '${g.diziAdi(n.dizi, en)}: ' : ''}'
                    '${g.tur == 'zaman' ? _yil(n.deger) : yzDeger(n.deger, g.birim(en), en)}'
                    '${n.uc.isNotEmpty ? ' (${n.uc == 'alt' ? (en ? 'low' : 'alt') : (en ? 'high' : 'üst')})' : ''}',
          ].join(' · ');
    return Semantics(
      container: true,
      label: '${g.baslik(en)}. ${g.aciklama(en)}',
      child: Container(
        margin: const EdgeInsets.only(top: 6, bottom: 24),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
        decoration: BoxDecoration(
          color: YzRenk.yuzey,
          border: Border.all(color: YzRenk.cizgi),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(g.baslik(en), style: YzYazi.baslik(17).copyWith(height: 1.3)),
            if (g.diziler.length > 1 && !_tablo && g.tur != 'isi') ...[
              const SizedBox(height: 8),
              _Lejant(g: g, en: en),
            ],
            const SizedBox(height: 14),
            AnimatedSwitcher(duration: const Duration(milliseconds: 200), child: KeyedSubtree(
              key: ValueKey(_tablo), child: govde)),
            if (ayrinti != null && !_tablo) ...[
              const SizedBox(height: 8),
              Text('$_secili — $ayrinti',
                  style: YzYazi.veri(boy: 12.5, renk: YzRenk.makine, kalinlik: FontWeight.w600)),
            ],
            const SizedBox(height: 10),
            Text(g.aciklama(en), style: YzYazi.govde(boy: 14.5, renk: YzRenk.soluk)),
            const SizedBox(height: 6),
            Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Expanded(
                child: Text(
                  g.satici
                      ? '${g.kaynak(en)} · ${en ? "includes the company's own statement" : 'şirketin kendi beyanı da var'}'
                      : g.kaynak(en),
                  style: YzYazi.veri(boy: 11.5, renk: YzRenk.soluk),
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _tablo = !_tablo),
                child: Text(
                  _tablo ? (en ? 'Show chart' : 'Grafik olarak gör') : (en ? 'Show table' : 'Tablo olarak gör'),
                  style: YzYazi.veri(boy: 12, renk: YzRenk.makine, kalinlik: FontWeight.w600),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

class _Lejant extends StatelessWidget {
  const _Lejant({required this.g, required this.en});
  final YzGrafik g;
  final bool en;

  @override
  Widget build(BuildContext context) => Wrap(spacing: 14, runSpacing: 6, children: [
        for (final d in g.diziler)
          Row(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 10, height: 10, decoration: BoxDecoration(
                color: _renk(g, d.kod), borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 6),
            Text(d.ad(en), style: YzYazi.veri(boy: 12, renk: YzRenk.murekkep)),
          ]),
      ]);
}

/// Kategori satırı: üstüne gelince ya da dokununca seçiliyor, öbürleri soluyor.
class _Secilebilir extends StatelessWidget {
  const _Secilebilir({required this.kategori, required this.secili, required this.sec, required this.child});
  final String kategori;
  final String? secili;
  final ValueChanged<String?> sec;
  final Widget child;

  @override
  Widget build(BuildContext context) => MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => sec(kategori),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 160),
            opacity: secili == null || secili == kategori ? 1 : 0.38,
            child: child,
          ),
        ),
      );
}

/// Değer ekseninin üst sınırı: yüzdelerde 100 (orantı bozulmasın), öbürlerinde
/// en büyük değer.
double _ust(YzGrafik g) {
  final m = g.noktalar.map((n) => n.deger).fold<double>(0, math.max);
  if (g.birimTr == '%' && m <= 100) return 100;
  return m <= 0 ? 1 : m;
}

/// Değer büyüdükçe dolan çubuk; hareket kapalıysa doğrudan son hâli.
class _Cubuk extends StatelessWidget {
  const _Cubuk({required this.oran, required this.renk, this.yukseklik = 14});
  final double oran;
  final Color renk;
  final double yukseklik;

  @override
  Widget build(BuildContext context) {
    final hedef = oran.clamp(0.0, 1.0);
    Widget cubuk(double o) => FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: math.max(o, 0.004),
          child: Container(
            height: yukseklik,
            decoration: BoxDecoration(color: renk, borderRadius: BorderRadius.circular(3)),
          ),
        );
    return Container(
      height: yukseklik,
      decoration: BoxDecoration(color: YzRenk.zemin, borderRadius: BorderRadius.circular(3)),
      child: _hareketsiz(context)
          ? cubuk(hedef)
          : TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: hedef),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              builder: (_, o, __) => cubuk(o),
            ),
    );
  }
}

class _YatayCubuk extends StatelessWidget {
  const _YatayCubuk({required this.g, required this.en, required this.secili, required this.sec});
  final YzGrafik g;
  final bool en;
  final String? secili;
  final ValueChanged<String?> sec;

  @override
  Widget build(BuildContext context) {
    final ust = _ust(g);
    final birim = g.birim(en);
    return LayoutBuilder(builder: (context, kis) {
      final dar = kis.maxWidth < 520;
      return Column(children: [
        for (final k in g.kategoriler(en))
          _Secilebilir(
            kategori: k,
            secili: secili,
            sec: sec,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Flex(
                direction: dar ? Axis.vertical : Axis.horizontal,
                crossAxisAlignment: dar ? CrossAxisAlignment.stretch : CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: dar ? null : kis.maxWidth * 0.34,
                    child: Padding(
                      padding: EdgeInsets.only(right: dar ? 0 : 12, bottom: dar ? 4 : 0),
                      child: Text(k, style: YzYazi.govde(boy: 14, renk: YzRenk.murekkep)),
                    ),
                  ),
                  if (dar)
                    _cubuklar(k, ust, birim)
                  else
                    Expanded(child: _cubuklar(k, ust, birim)),
                ],
              ),
            ),
          ),
      ]);
    });
  }

  Widget _cubuklar(String k, double ust, String birim) => Column(children: [
        for (final n in g.noktalar.where((n) => n.kategori(en) == k))
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(children: [
              Expanded(child: _Cubuk(oran: n.deger / ust, renk: _renk(g, n.dizi))),
              const SizedBox(width: 8),
              SizedBox(
                width: 78,
                child: Text(yzDeger(n.deger, birim, en),
                    style: YzYazi.veri(boy: 12.5, renk: YzRenk.murekkep, kalinlik: FontWeight.w600)),
              ),
            ]),
          ),
      ]);
}

class _DikeyCubuk extends StatelessWidget {
  const _DikeyCubuk({required this.g, required this.en, required this.secili, required this.sec});
  final YzGrafik g;
  final bool en;
  final String? secili;
  final ValueChanged<String?> sec;

  @override
  Widget build(BuildContext context) {
    final kat = g.kategoriler(en);
    final diziler = g.diziler.isEmpty ? [const YzGrafikDizi('', '', '')] : g.diziler;
    final ust = _ust(g);
    final birim = g.birim(en);
    return SizedBox(
      height: 240,
      child: BarChart(
        BarChartData(
          maxY: ust * 1.12,
          alignment: BarChartAlignment.spaceAround,
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: ust / 4,
            getDrawingHorizontalLine: (_) => const FlLine(color: YzRenk.cizgi, strokeWidth: 0.7),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 34,
                getTitlesWidget: (v, meta) {
                  final i = v.toInt();
                  if (i < 0 || i >= kat.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(kat[i],
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: YzYazi.veri(boy: 11, renk: YzRenk.soluk)),
                  );
                },
              ),
            ),
          ),
          barTouchData: BarTouchData(
            touchCallback: (e, r) {
              if (e is FlTapUpEvent && r?.spot != null) sec(kat[r!.spot!.touchedBarGroupIndex]);
            },
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => YzRenk.murekkep,
              getTooltipItem: (grup, gi, cubuk, ci) => BarTooltipItem(
                '${kat[grup.x]}\n${yzDeger(cubuk.toY, birim, en)}',
                YzYazi.veri(boy: 12, renk: Colors.white, kalinlik: FontWeight.w600),
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < kat.length; i++)
              BarChartGroupData(
                x: i,
                barsSpace: 4,
                barRods: [
                  for (final d in diziler)
                    for (final n in g.noktalar.where((n) => n.kategori(en) == kat[i] && (d.kod.isEmpty || n.dizi == d.kod)))
                      BarChartRodData(
                        toY: n.deger,
                        width: math.min(28, 160 / (kat.length * diziler.length)),
                        color: _renk(g, n.dizi).withValues(
                            alpha: secili == null || secili == kat[i] ? 1 : 0.35),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                      ),
                ],
              ),
          ],
        ),
        duration: _hareketsiz(context) ? Duration.zero : const Duration(milliseconds: 400),
      ),
    );
  }
}

class _Cizgi extends StatelessWidget {
  const _Cizgi({required this.g, required this.en, required this.alan});
  final YzGrafik g;
  final bool en;
  final bool alan;

  @override
  Widget build(BuildContext context) {
    final kat = g.kategoriler(en);
    final diziler = g.diziler.isEmpty ? [const YzGrafikDizi('', '', '')] : g.diziler;
    final birim = g.birim(en);
    final enBuyuk = g.noktalar.map((n) => n.deger).fold<double>(0, math.max);
    final enKucuk = g.noktalar.map((n) => n.deger).fold<double>(enBuyuk, math.min);
    final alt = alan || enKucuk >= 0 && enKucuk < enBuyuk * 0.35 ? 0.0 : enKucuk * 0.9;
    final adim = math.max(1, (kat.length / 6).ceil());
    return SizedBox(
      height: 240,
      child: LineChart(
        LineChartData(
          minY: alt,
          maxY: enBuyuk * 1.12,
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => const FlLine(color: YzRenk.cizgi, strokeWidth: 0.7),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 52,
                getTitlesWidget: (v, meta) => Text(yzDeger(double.parse(v.toStringAsFixed(2)), birim == '%' ? '%' : '', en),
                    style: YzYazi.veri(boy: 10.5, renk: YzRenk.soluk)),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                reservedSize: 26,
                getTitlesWidget: (v, meta) {
                  final i = v.toInt();
                  if (i < 0 || i >= kat.length || i % adim != 0 && i != kat.length - 1) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(kat[i], style: YzYazi.veri(boy: 11, renk: YzRenk.soluk)),
                  );
                },
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => YzRenk.murekkep,
              getTooltipItems: (noktalar) => [
                for (final s in noktalar)
                  LineTooltipItem(
                    '${kat[s.x.toInt()]}: ${yzDeger(s.y, birim, en)}',
                    YzYazi.veri(boy: 12, renk: Colors.white, kalinlik: FontWeight.w600),
                  ),
              ],
            ),
          ),
          lineBarsData: [
            for (final d in diziler)
              LineChartBarData(
                spots: [
                  for (var i = 0; i < kat.length; i++)
                    for (final n in g.noktalar.where((n) => n.kategori(en) == kat[i] && (d.kod.isEmpty || n.dizi == d.kod)))
                      FlSpot(i.toDouble(), n.deger),
                ],
                isCurved: true,
                preventCurveOverShooting: true,
                curveSmoothness: 0.22,
                color: _renk(g, d.kod),
                barWidth: 2.4,
                dotData: FlDotData(
                  show: kat.length <= 14,
                  getDotPainter: (s, p, b, i) => FlDotCirclePainter(
                      radius: 3.2, color: YzRenk.yuzey, strokeWidth: 2, strokeColor: _renk(g, d.kod)),
                ),
                belowBarData: BarAreaData(
                  show: alan,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [_renk(g, d.kod).withValues(alpha: 0.28), _renk(g, d.kod).withValues(alpha: 0.02)],
                  ),
                ),
              ),
          ],
        ),
        duration: _hareketsiz(context) ? Duration.zero : const Duration(milliseconds: 400),
      ),
    );
  }
}

/// Konuma göre bir değerin yatay yeri (0..genişlik).
double _x(double v, double ust, double w) => (v / ust).clamp(0.0, 1.0) * w;

class _Dumbbell extends StatelessWidget {
  const _Dumbbell({required this.g, required this.en, required this.secili, required this.sec});
  final YzGrafik g;
  final bool en;
  final String? secili;
  final ValueChanged<String?> sec;

  @override
  Widget build(BuildContext context) {
    final ust = _ust(g);
    final birim = g.birim(en);
    return Column(children: [
      for (final k in g.kategoriler(en))
        _Secilebilir(
          kategori: k,
          secili: secili,
          sec: sec,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(k, style: YzYazi.govde(boy: 14, renk: YzRenk.murekkep)),
              const SizedBox(height: 4),
              LayoutBuilder(builder: (context, kis) {
                final w = kis.maxWidth - 16;
                final ns = g.noktalar.where((n) => n.kategori(en) == k).toList();
                if (ns.isEmpty) return const SizedBox.shrink();
                final xs = [for (final n in ns) _x(n.deger, ust, w) + 8];
                final sol = xs.reduce(math.min), sag = xs.reduce(math.max);
                return SizedBox(
                  height: 40,
                  child: Stack(clipBehavior: Clip.none, children: [
                    Positioned(left: 8, right: 8, top: 13, child: Container(height: 1, color: YzRenk.cizgi)),
                    Positioned(left: sol, width: math.max(sag - sol, 1), top: 11,
                        child: Container(height: 5, decoration: BoxDecoration(
                            color: YzRenk.makine.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(3)))),
                    for (var i = 0; i < ns.length; i++) ...[
                      Positioned(
                        left: xs[i] - 7,
                        top: 7,
                        child: Container(width: 14, height: 14, decoration: BoxDecoration(
                            color: _renk(g, ns[i].dizi), shape: BoxShape.circle,
                            border: Border.all(color: YzRenk.yuzey, width: 2))),
                      ),
                      Positioned(
                        left: (xs[i] - 40).clamp(0.0, math.max(0.0, kis.maxWidth - 80)),
                        width: 80,
                        top: 24,
                        child: Text(yzDeger(ns[i].deger, birim, en),
                            textAlign: TextAlign.center,
                            style: YzYazi.veri(boy: 11.5, renk: _renk(g, ns[i].dizi), kalinlik: FontWeight.w700)),
                      ),
                    ],
                  ]),
                );
              }),
            ]),
          ),
        ),
    ]);
  }
}

class _Aralik extends StatelessWidget {
  const _Aralik({required this.g, required this.en, required this.secili, required this.sec});
  final YzGrafik g;
  final bool en;
  final String? secili;
  final ValueChanged<String?> sec;

  @override
  Widget build(BuildContext context) {
    final ust = _ust(g);
    final birim = g.birim(en);
    return Column(children: [
      for (final k in g.kategoriler(en))
        _Secilebilir(
          kategori: k,
          secili: secili,
          sec: sec,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(k, style: YzYazi.govde(boy: 14, renk: YzRenk.murekkep)),
              const SizedBox(height: 4),
              LayoutBuilder(builder: (context, kis) {
                final ns = g.noktalar.where((n) => n.kategori(en) == k).toList();
                final a = ns.where((n) => n.uc != 'ust').map((n) => n.deger).fold<double>(double.infinity, math.min);
                final u = ns.where((n) => n.uc != 'alt').map((n) => n.deger).fold<double>(0, math.max);
                final w = kis.maxWidth;
                final renk = _renk(g, ns.isEmpty ? '' : ns.first.dizi);
                final metin = a == u
                    ? yzDeger(a, birim, en)
                    : (birim == '%'
                        ? (en ? '${yzSayi(a, en)}–${yzSayi(u, en)}%' : '%${yzSayi(a, en)}–${yzSayi(u, en)}')
                        : '${yzSayi(a, en)}–${yzDeger(u, birim, en)}');
                return SizedBox(
                  height: 22,
                  child: Stack(children: [
                    Positioned.fill(top: 7, bottom: 7, child: Container(decoration: BoxDecoration(
                        color: YzRenk.zemin, borderRadius: BorderRadius.circular(4)))),
                    Positioned(
                      left: _x(a, ust, w),
                      width: math.max(_x(u, ust, w) - _x(a, ust, w), 6),
                      top: 4,
                      bottom: 4,
                      child: Container(decoration: BoxDecoration(color: renk, borderRadius: BorderRadius.circular(7))),
                    ),
                    Positioned(
                      left: math.min(_x(u, ust, w) + 6, math.max(0, w - 90)),
                      top: 2,
                      child: Text(metin, style: YzYazi.veri(boy: 12, renk: YzRenk.murekkep, kalinlik: FontWeight.w700)),
                    ),
                  ]),
                );
              }),
            ]),
          ),
        ),
    ]);
  }
}

class _Pay extends StatelessWidget {
  const _Pay({required this.g, required this.en, required this.secili, required this.sec});
  final YzGrafik g;
  final bool en;
  final String? secili;
  final ValueChanged<String?> sec;

  @override
  Widget build(BuildContext context) {
    final birim = g.birim(en);
    // Bir pay çubuğu = bir kategori (ör. "Türkiye"), parçaları dizi.
    return Column(children: [
      for (final k in g.kategoriler(en)) ...[
        if (g.kategoriler(en).length > 1)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(k, style: YzYazi.govde(boy: 14, renk: YzRenk.murekkep)),
          ),
        LayoutBuilder(builder: (context, kis) {
          final ns = g.noktalar.where((n) => n.kategori(en) == k).toList();
          final toplam = ns.fold<double>(0, (s, n) => s + n.deger);
          return ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Row(children: [
              for (final n in ns)
                _Secilebilir(
                  kategori: k,
                  secili: secili,
                  sec: sec,
                  child: Container(
                    width: math.max(kis.maxWidth * n.deger / (toplam <= 0 ? 1 : toplam), 2),
                    height: 34,
                    color: _renk(g, n.dizi),
                    alignment: Alignment.center,
                    child: kis.maxWidth * n.deger / (toplam <= 0 ? 1 : toplam) > 64
                        ? Text(yzDeger(n.deger, birim, en),
                            style: YzYazi.veri(boy: 12, renk: Colors.white, kalinlik: FontWeight.w700))
                        : null,
                  ),
                ),
            ]),
          );
        }),
        const SizedBox(height: 8),
        Wrap(spacing: 14, runSpacing: 4, children: [
          for (final n in g.noktalar.where((n) => n.kategori(en) == k))
            Text('${g.diziAdi(n.dizi, en)} ${yzDeger(n.deger, birim, en)}',
                style: YzYazi.veri(boy: 12, renk: _renk(g, n.dizi), kalinlik: FontWeight.w600)),
        ]),
        const SizedBox(height: 10),
      ],
    ]);
  }
}

class _Waffle extends StatelessWidget {
  const _Waffle({required this.g, required this.en});
  final YzGrafik g;
  final bool en;

  @override
  Widget build(BuildContext context) {
    final birim = g.birim(en);
    return Wrap(spacing: 28, runSpacing: 18, children: [
      for (final n in g.noktalar)
        SizedBox(
          width: 150,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            GridView.count(
              crossAxisCount: 10,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 2.5,
              crossAxisSpacing: 2.5,
              children: [
                for (var i = 0; i < 100; i++)
                  Container(decoration: BoxDecoration(
                      color: i < n.deger.round() ? _renk(g, n.dizi) : YzRenk.zemin,
                      borderRadius: BorderRadius.circular(1.5))),
              ],
            ),
            const SizedBox(height: 8),
            Text(yzDeger(n.deger, birim, en), style: YzYazi.baslik(22, renk: _renk(g, n.dizi))),
            Text(n.kategori(en), style: YzYazi.govde(boy: 13, renk: YzRenk.soluk)),
          ]),
        ),
    ]);
  }
}

class _Egim extends StatelessWidget {
  const _Egim({required this.g, required this.en, required this.secili, required this.sec});
  final YzGrafik g;
  final bool en;
  final String? secili;
  final ValueChanged<String?> sec;

  @override
  Widget build(BuildContext context) {
    // İki zaman noktası = iki dizi (soldaki ilk dizi); her kategori bir çizgi.
    final d = g.diziler;
    if (d.length < 2) return _Tablo(g: g, en: en);
    final kat = g.kategoriler(en);
    final birim = g.birim(en);
    double deger(String k, String dz) =>
        g.noktalar.firstWhere((n) => n.kategori(en) == k && n.dizi == dz,
            orElse: () => const YzGrafikNokta('', '', '', 0)).deger;
    final tum = g.noktalar.map((n) => n.deger);
    final ust = tum.fold<double>(0, math.max), alt = tum.fold<double>(ust, math.min);
    return SizedBox(
      height: 220,
      child: LayoutBuilder(builder: (context, kis) {
        final w = kis.maxWidth, h = 220.0;
        final kenar = math.min(130.0, w * 0.3);
        double y(double v) => ust == alt ? h / 2 : 18 + (1 - (v - alt) / (ust - alt)) * (h - 36);
        return Stack(children: [
          CustomPaint(
            size: Size(w, h),
            painter: _EgimCizeri(
              cizgiler: [
                for (final k in kat)
                  (y(deger(k, d[0].kod)), y(deger(k, d[1].kod)),
                      secili == null || secili == k ? YzRenk.makine : YzRenk.cizgi),
              ],
              sol: kenar,
              sag: w - kenar,
            ),
          ),
          Positioned(left: kenar - 20, top: 0, child: Text(d[0].ad(en), style: YzYazi.ustEtiket())),
          Positioned(right: kenar - 20, top: 0, child: Text(d[1].ad(en), style: YzYazi.ustEtiket())),
          for (final k in kat) ...[
            Positioned(
              left: 0,
              width: kenar - 8,
              top: y(deger(k, d[0].kod)) - 9,
              child: GestureDetector(
                onTap: () => sec(k),
                child: Text('$k ${yzDeger(deger(k, d[0].kod), birim, en)}',
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: YzYazi.veri(boy: 11.5, renk: YzRenk.murekkep)),
              ),
            ),
            Positioned(
              right: 0,
              width: kenar - 8,
              top: y(deger(k, d[1].kod)) - 9,
              child: GestureDetector(
                onTap: () => sec(k),
                child: Text(yzDeger(deger(k, d[1].kod), birim, en),
                    style: YzYazi.veri(boy: 11.5, renk: YzRenk.makine, kalinlik: FontWeight.w700)),
              ),
            ),
          ],
        ]);
      }),
    );
  }
}

class _EgimCizeri extends CustomPainter {
  _EgimCizeri({required this.cizgiler, required this.sol, required this.sag});
  final List<(double, double, Color)> cizgiler;
  final double sol, sag;

  @override
  void paint(Canvas canvas, Size size) {
    final eksen = Paint()
      ..color = YzRenk.cizgi
      ..strokeWidth = 1;
    canvas.drawLine(Offset(sol, 14), Offset(sol, size.height - 10), eksen);
    canvas.drawLine(Offset(sag, 14), Offset(sag, size.height - 10), eksen);
    for (final (a, b, renk) in cizgiler) {
      final p = Paint()
        ..color = renk
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(sol, a), Offset(sag, b), p);
      canvas.drawCircle(Offset(sol, a), 4, Paint()..color = renk);
      canvas.drawCircle(Offset(sag, b), 4, Paint()..color = renk);
    }
  }

  @override
  bool shouldRepaint(covariant _EgimCizeri o) => o.cizgiler != cizgiler || o.sol != sol || o.sag != sag;
}

class _Kpi extends StatelessWidget {
  const _Kpi({required this.g, required this.en});
  final YzGrafik g;
  final bool en;

  @override
  Widget build(BuildContext context) {
    final birim = g.birim(en);
    return Wrap(spacing: 12, runSpacing: 12, children: [
      for (final n in g.noktalar)
        Container(
          constraints: const BoxConstraints(minWidth: 140, maxWidth: 220),
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            color: _renk(g, n.dizi).withValues(alpha: 0.08),
            border: Border(left: BorderSide(color: _renk(g, n.dizi), width: 3)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(yzDeger(n.deger, birim, en), style: YzYazi.baslik(28, renk: _renk(g, n.dizi))),
            const SizedBox(height: 4),
            Text(n.kategori(en), style: YzYazi.govde(boy: 13.5, renk: YzRenk.murekkep)),
            if (birim == '%') ...[
              const SizedBox(height: 8),
              _Cubuk(oran: n.deger / 100, renk: _renk(g, n.dizi), yukseklik: 5),
            ],
          ]),
        ),
    ]);
  }
}

class _Isi extends StatelessWidget {
  const _Isi({required this.g, required this.en});
  final YzGrafik g;
  final bool en;

  @override
  Widget build(BuildContext context) {
    final satirlar = g.kategoriler(en);
    final sutunlar = g.diziler;
    final ust = _ust(g);
    final birim = g.birim(en);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        defaultColumnWidth: const IntrinsicColumnWidth(),
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          TableRow(children: [
            const SizedBox.shrink(),
            for (final s in sutunlar)
              Padding(
                padding: const EdgeInsets.fromLTRB(6, 0, 6, 6),
                child: Text(s.ad(en), style: YzYazi.veri(boy: 11, renk: YzRenk.soluk)),
              ),
          ]),
          for (final r in satirlar)
            TableRow(children: [
              Padding(
                padding: const EdgeInsets.only(right: 10, top: 2, bottom: 2),
                child: Text(r, style: YzYazi.govde(boy: 13.5, renk: YzRenk.murekkep)),
              ),
              for (final s in sutunlar)
                Builder(builder: (_) {
                  final n = g.noktalar.where((n) => n.kategori(en) == r && n.dizi == s.kod).toList();
                  final v = n.isEmpty ? null : n.first.deger;
                  final oran = v == null ? 0.0 : (v / ust).clamp(0.0, 1.0);
                  return Container(
                    margin: const EdgeInsets.all(2),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    color: v == null ? YzRenk.zemin : Color.lerp(YzRenk.makineAcik, YzRenk.makine, oran),
                    child: Text(v == null ? '—' : yzDeger(v, birim, en),
                        textAlign: TextAlign.center,
                        style: YzYazi.veri(boy: 12, renk: oran > 0.55 ? Colors.white : YzRenk.murekkep,
                            kalinlik: FontWeight.w600)),
                  );
                }),
            ]),
        ],
      ),
    );
  }
}

class _Zaman extends StatelessWidget {
  const _Zaman({required this.g, required this.en});
  final YzGrafik g;
  final bool en;

  @override
  Widget build(BuildContext context) {
    final olaylar = [...g.noktalar]..sort((a, b) => a.deger.compareTo(b.deger));
    return Column(children: [
      for (var i = 0; i < olaylar.length; i++)
        IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            SizedBox(
              width: 54,
              child: Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Text(_yil(olaylar[i].deger),
                    style: YzYazi.veri(boy: 13, renk: _renk(g, olaylar[i].dizi), kalinlik: FontWeight.w700)),
              ),
            ),
            SizedBox(
              width: 18,
              child: Column(children: [
                Container(width: 10, height: 10, margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(color: _renk(g, olaylar[i].dizi), shape: BoxShape.circle)),
                if (i < olaylar.length - 1)
                  Expanded(child: Container(width: 1.5, color: YzRenk.cizgi)),
              ]),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Text(olaylar[i].kategori(en), style: YzYazi.govde(boy: 14.5, renk: YzRenk.murekkep)),
              ),
            ),
          ]),
        ),
    ]);
  }
}

class _Tablo extends StatelessWidget {
  const _Tablo({required this.g, required this.en});
  final YzGrafik g;
  final bool en;

  @override
  Widget build(BuildContext context) {
    final birim = g.birim(en);
    final cokDizi = g.diziler.length > 1;
    return Table(
      columnWidths: const {0: FlexColumnWidth(3), 1: FlexColumnWidth(2)},
      border: const TableBorder(horizontalInside: BorderSide(color: YzRenk.cizgi)),
      children: [
        for (final n in g.noktalar)
          TableRow(children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(
                '${n.kategori(en)}${cokDizi ? ' · ${g.diziAdi(n.dizi, en)}' : ''}'
                '${n.uc.isNotEmpty ? ' (${n.uc == 'alt' ? (en ? 'low' : 'alt') : (en ? 'high' : 'üst')})' : ''}',
                style: YzYazi.govde(boy: 14, renk: YzRenk.murekkep),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(g.tur == 'zaman' ? _yil(n.deger) : yzDeger(n.deger, birim, en),
                  textAlign: TextAlign.right,
                  style: YzYazi.veri(boy: 13, renk: YzRenk.murekkep, kalinlik: FontWeight.w600)),
            ),
          ]),
      ],
    );
  }
}
