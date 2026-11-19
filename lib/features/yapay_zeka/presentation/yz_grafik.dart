import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/utils/turkce_metin.dart';
import '../data/yz_grafik_veri.dart';
import 'yz_gorsel_mobil.dart';
import 'yz_mobil.dart';
import 'yz_tasarim.dart';

/// Bölüm grafiklerinin çizicisi (karar 58).
///
/// İlke: grafik metnin söylediğini görünür kılar, yeni bir şey söylemez.
/// Her değer kayıttan gelir (dogrula_bolumler.py kural 11); her kartta
/// başlık, ölçünün adı, kısa açıklama, kaynak satırı ve "tablo olarak gör"
/// var. Değerler grafiğin üstüne yazılı (okur değeri bulmak için fareyi
/// gezdirmek zorunda değil); bir kategoriye dokunmak ya da üstüne gelmek onu
/// öne çıkarıp ötekileri soldurur ve ayrıntısını kartın altına yazar.
///
/// Türler: yatay_cubuk, dikey_cubuk, cizgi, alan, dumbbell, aralik, pay,
/// waffle, egim, kpi, isi, zaman, kucuk (küçük çoklu).
///
/// Dizi rolleri (YzGrafikDizi.rol): 'ongoru' öngörü ya da hedef, açık tonla;
/// 'referans' çubuklarda ince dikey işaret; 'toplam' çizilmez, toplam etiketi
/// ya da kare sayısı olur; 'alt' bir kalemin alt kırılımı, girintili.

/// Dizilerin renkleri, sırayla. Bölümün paletiyle (çelik mavisi, bitki
/// yeşili, toprak sarısı) uyumlu; renk körlüğünde ilk üçü birbirinden ayrılıyor.
const List<Color> kYzGrafikRenkleri = [
  YzRenk.makine,
  YzRenk.bitki,
  YzRenk.bekleyen,
  Color(0xFF9A4C3D),
  Color(0xFF6C7A86),
];

bool _ozelRol(String rol) => rol == 'alt' || rol == 'ongoru';

/// Dizinin ana rengi: 'alt' ve 'ongoru' dizileri bir önceki sıradan dizinin
/// rengini alır (açık tonu [_renk]'te).
Color _temelRenk(YzGrafik g, String dizi) {
  var sira = -1;
  Color? son;
  for (final d in g.diziler) {
    if (d.rol == 'referans' || d.rol == 'toplam') {
      if (d.kod == dizi) return YzRenk.murekkep;
      continue;
    }
    if (!_ozelRol(d.rol)) {
      sira++;
      son = kYzGrafikRenkleri[sira % kYzGrafikRenkleri.length];
    }
    if (d.kod == dizi) return son ?? kYzGrafikRenkleri.first;
  }
  return kYzGrafikRenkleri.first;
}

Color _renk(YzGrafik g, String dizi) {
  final temel = _temelRenk(g, dizi);
  return _ozelRol(g.rol(dizi)) ? Color.lerp(temel, YzRenk.yuzey, 0.52)! : temel;
}

bool _hareketsiz(BuildContext c) => MediaQuery.maybeOf(c)?.disableAnimations ?? false;

String _yil(double v) => v.floor().toString();

/// Zaman çizelgesinde olayın tarihi: noktanın notu (ör. "23 Temmuz 1972"),
/// yoksa yılı.
String _tarih(YzGrafikNokta n, bool en) => n.ek(en).isNotEmpty ? n.ek(en) : _yil(n.deger);

String _uc(YzGrafikNokta n, bool en) =>
    n.uc.isEmpty ? '' : ' (${n.uc == 'alt' ? (en ? 'low' : 'alt') : (en ? 'high' : 'üst')})';

/// Değer ekseninin üst sınırı: elle verildiyse o; yüzdelerde 100 (orantı
/// bozulmasın); öbürlerinde en büyük değer.
double _ust(YzGrafik g) {
  if (g.ust != null) return g.ust!;
  final m = g.noktalar.where((n) => g.rol(n.dizi) != 'toplam').map((n) => n.deger).fold<double>(0, math.max);
  if (g.birimTr == '%' && m <= 100) return 100;
  return m <= 0 ? 1 : m;
}

class YzGrafikKarti extends StatefulWidget {
  const YzGrafikKarti({super.key, required this.grafik, required this.en});
  final YzGrafik grafik;
  final bool en;

  @override
  State<YzGrafikKarti> createState() => _YzGrafikKartiState();
}

const _lejantliTurler = {
  'yatay_cubuk', 'dikey_cubuk', 'cizgi', 'alan', 'dumbbell', 'aralik', 'zaman', 'kucuk',
};

class _YzGrafikKartiState extends State<YzGrafikKarti> {
  bool _tablo = false;
  String? _secili;

  void _sec(String? k) => setState(() => _secili = _secili == k ? null : k);

  @override
  Widget build(BuildContext context) {
    final g = widget.grafik;
    final en = widget.en;
    // Telefonda kaynak satırı mono değil sade küçük Outfit (mobil okuma turu,
    // karar 62); eksen rakamları ve büyük harfli etiketler mono kalıyor.
    final telefon = yzTelefon(context);
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
            'kucuk' => _Kucuk(g: g, en: en),
            _ => _Tablo(g: g, en: en),
          };
    final lejant = [
      for (final d in g.diziler)
        if (d.rol != 'toplam' && d.rol != 'referans') d,
    ];
    final ayrinti = _secili == null
        ? null
        : [
            for (final n in g.noktalar)
              if (n.kategori(en) == _secili)
                '${lejant.length > 1 ? '${g.diziAdi(n.dizi, en)}: ' : ''}'
                    '${g.tur == 'zaman' ? _tarih(n, en) : g.yaz(n, en)}${_uc(n, en)}'
                    '${n.ek(en).isNotEmpty && g.tur != 'zaman' ? ' · ${n.ek(en)}' : ''}',
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
            if (g.eksen(en).isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(g.eksen(en), style: YzYazi.veri(boy: 12, renk: YzRenk.soluk)),
            ],
            if (lejant.length > 1 && !_tablo && _lejantliTurler.contains(g.tur)) ...[
              const SizedBox(height: 10),
              _Lejant(g: g, en: en, diziler: lejant),
            ],
            const SizedBox(height: 14),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              // Telefonda ekranın %85'inden uzun grafik katlanıyor (madde 7):
              // ilk 420 piksel, alt kenar zemine soluyor, altında "Grafiğin
              // tamamını gör". Başlık, açıklama, kaynak ve "Tablo olarak gör"
              // katlamanın dışında; tablo görünümü katlanmıyor.
              child: KeyedSubtree(
                  key: ValueKey(_tablo),
                  child: telefon && !_tablo
                      ? YzGorselKatlanir(
                          en: en,
                          grafik: true,
                          zemin: YzRenk.yuzey,
                          esik: MediaQuery.sizeOf(context).height * 0.85,
                          child: govde,
                        )
                      : govde),
            ),
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
                  style: telefon ? yzKunyeYazisi() : YzYazi.veri(boy: 11.5, renk: YzRenk.soluk),
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
  const _Lejant({required this.g, required this.en, required this.diziler});
  final YzGrafik g;
  final bool en;
  final List<YzGrafikDizi> diziler;

  @override
  Widget build(BuildContext context) => Wrap(spacing: 14, runSpacing: 6, children: [
        for (final d in diziler)
          Row(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: _renk(g, d.kod),
                borderRadius: BorderRadius.circular(2),
                border: d.rol == 'ongoru' ? Border.all(color: _temelRenk(g, d.kod)) : null,
              ),
            ),
            const SizedBox(width: 6),
            Flexible(
                child: Text(d.ad(en),
                    style: yzTelefon(context)
                        ? yzKunyeYazisi(renk: YzRenk.murekkep, boy: 13)
                        : YzYazi.veri(boy: 12, renk: YzRenk.murekkep))),
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

/// Değer büyüdükçe dolan çubuk; hareket kapalıysa doğrudan son hâli.
/// [isaretler]: referans değerlerin çubuk boyundaki yeri (0..1), ince dikey
/// çizgiyle.
class _Cubuk extends StatelessWidget {
  const _Cubuk({
    required this.oran,
    required this.renk,
    this.yukseklik = 14,
    this.isaretler = const [],
    this.kenar,
  });
  final double oran;
  final Color renk;
  final double yukseklik;
  final List<double> isaretler;
  final Color? kenar;

  @override
  Widget build(BuildContext context) {
    final hedef = oran.clamp(0.0, 1.0).toDouble();
    Widget cubuk(double o) => FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: math.max(o, 0.004),
          child: Container(
            height: yukseklik,
            decoration: BoxDecoration(
              color: renk,
              borderRadius: BorderRadius.circular(3),
              border: kenar == null ? null : Border.all(color: kenar!, width: 1),
            ),
          ),
        );
    final iz = Container(
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
    if (isaretler.isEmpty) return iz;
    return LayoutBuilder(builder: (context, kis) {
      return Stack(clipBehavior: Clip.none, children: [
        iz,
        for (final r in isaretler)
          Positioned(
            left: (r.clamp(0.0, 1.0) * kis.maxWidth - 1).clamp(0.0, math.max(0.0, kis.maxWidth - 2)).toDouble(),
            top: -3,
            bottom: -3,
            width: 2,
            child: const ColoredBox(color: YzRenk.murekkep),
          ),
      ]);
    });
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
    final referanslar = [for (final n in g.noktalar) if (g.rol(n.dizi) == 'referans') n];
    final isaretler = [for (final r in referanslar) r.deger / ust];
    final ekli = g.noktalar.any((n) => n.ek(en).isNotEmpty);
    return LayoutBuilder(builder: (context, kis) {
      final dar = kis.maxWidth < 520;
      final degerGenisligi = ekli ? 104.0 : 82.0;
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        for (final k in g.kategoriler(en))
          Builder(builder: (context) {
            final ns = [for (final n in g.cizilenler) if (n.kategori(en) == k) n];
            final alt = ns.isNotEmpty && ns.every((n) => g.rol(n.dizi) == 'alt');
            final etiket = Padding(
              padding: EdgeInsets.only(left: alt ? 14 : 0, right: dar ? 0 : 12, bottom: dar ? 4 : 0),
              child: Text(k, style: YzYazi.govde(boy: alt ? 13 : 14, renk: alt ? YzRenk.soluk : YzRenk.murekkep)),
            );
            final cubuklar = Column(children: [
              for (final n in ns)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(children: [
                    Expanded(
                      child: _Cubuk(
                        oran: n.deger / ust,
                        renk: _renk(g, n.dizi),
                        yukseklik: alt ? 10 : 14,
                        isaretler: isaretler,
                        kenar: g.rol(n.dizi) == 'ongoru' ? _temelRenk(g, n.dizi) : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: degerGenisligi,
                      child: Text(
                        n.ek(en).isEmpty ? g.yaz(n, en) : '${g.yaz(n, en)} · ${n.ek(en)}',
                        style: YzYazi.veri(boy: 12.5, renk: YzRenk.murekkep, kalinlik: FontWeight.w600),
                      ),
                    ),
                  ]),
                ),
            ]);
            return _Secilebilir(
              kategori: k,
              secili: secili,
              sec: sec,
              child: Padding(
                padding: EdgeInsets.only(bottom: alt ? 6 : 10),
                child: dar
                    ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [etiket, cubuklar])
                    : Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                        SizedBox(width: kis.maxWidth * 0.34, child: etiket),
                        Expanded(child: cubuklar),
                      ]),
              ),
            );
          }),
        for (final r in referanslar)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(children: [
              Container(width: 2, height: 14, color: YzRenk.murekkep),
              const SizedBox(width: 8),
              Expanded(
                child: Text('${r.kategori(en)}: ${g.yaz(r, en)}',
                    style: yzTelefon(context)
                        ? yzKunyeYazisi()
                        : YzYazi.veri(boy: 12, renk: YzRenk.soluk)),
              ),
            ]),
          ),
      ]);
    });
  }
}

/// Dikey çubuklar: kategoriler yan yana, her kategoride diziler; değer
/// çubuğun üstünde. Öngörü dizileri açık tonla ve kenarlı.
class _DikeyCubuk extends StatelessWidget {
  const _DikeyCubuk({required this.g, required this.en, required this.secili, required this.sec});
  final YzGrafik g;
  final bool en;
  final String? secili;
  final ValueChanged<String?> sec;

  @override
  Widget build(BuildContext context) {
    final kat = g.kategoriler(en);
    final ust = _ust(g);
    const yukseklik = 170.0;
    return LayoutBuilder(builder: (context, kis) {
      final enCok = [for (final k in kat) g.cizilenler.where((n) => n.kategori(en) == k).length]
          .fold<int>(1, math.max);
      final grupGenisligi = kis.maxWidth / math.max(kat.length, 1);
      final cubukGenisligi = ((grupGenisligi - 16) / enCok - 4).clamp(10.0, 44.0).toDouble();
      return Column(children: [
        SizedBox(
          height: yukseklik + 22,
          child: Stack(children: [
            for (final f in const [0.0, 0.25, 0.5, 0.75, 1.0])
              Positioned(
                left: 0,
                right: 0,
                top: 22 + (1 - f) * yukseklik,
                child: Container(height: f == 0 ? 1 : 0.6, color: YzRenk.cizgi),
              ),
            Positioned.fill(
              child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                for (final k in kat)
                  Expanded(
                    child: _Secilebilir(
                      kategori: k,
                      secili: secili,
                      sec: sec,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          for (final n in g.cizilenler.where((n) => n.kategori(en) == k))
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 2),
                              child: SizedBox(
                                width: cubukGenisligi,
                                child: Column(mainAxisSize: MainAxisSize.min, children: [
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(g.yaz(n, en),
                                        style: YzYazi.veri(
                                            boy: 11.5, renk: _temelRenk(g, n.dizi), kalinlik: FontWeight.w700)),
                                  ),
                                  const SizedBox(height: 4),
                                  _DikeyDolum(
                                    yukseklik: math.max(2.0, (n.deger / ust).clamp(0.0, 1.0).toDouble() * yukseklik),
                                    renk: _renk(g, n.dizi),
                                    kenar: g.rol(n.dizi) == 'ongoru' ? _temelRenk(g, n.dizi) : null,
                                  ),
                                ]),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
              ]),
            ),
          ]),
        ),
        const SizedBox(height: 6),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          for (final k in kat)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Text(k,
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: YzYazi.veri(boy: 11, renk: YzRenk.soluk)),
              ),
            ),
        ]),
      ]);
    });
  }
}

class _DikeyDolum extends StatelessWidget {
  const _DikeyDolum({required this.yukseklik, required this.renk, this.kenar});
  final double yukseklik;
  final Color renk;
  final Color? kenar;

  @override
  Widget build(BuildContext context) {
    Widget kutu(double h) => Container(
          height: h,
          decoration: BoxDecoration(
            color: renk,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
            border: kenar == null ? null : Border.all(color: kenar!, width: 1),
          ),
        );
    if (_hareketsiz(context)) return kutu(yukseklik);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: yukseklik),
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutCubic,
      builder: (_, h, __) => kutu(h),
    );
  }
}

/// Çizgi (ve alan) grafiği: kategoriler yatay eksende eşit aralıkla, her dizi
/// bir çizgi; değerler noktaların üstünde. Öngörü dizisi kesikli.
class _Cizgi extends StatelessWidget {
  const _Cizgi({required this.g, required this.en, required this.alan});
  final YzGrafik g;
  final bool en;
  final bool alan;

  @override
  Widget build(BuildContext context) {
    final kat = g.kategoriler(en);
    final diziler = [
      for (final d in g.diziler)
        if (d.rol != 'toplam' && d.rol != 'referans') d,
    ];
    final enBuyuk = g.cizilenler.map((n) => n.deger).fold<double>(0, math.max);
    final ust = g.ust ?? (g.birimTr == '%' && enBuyuk <= 100 ? 100.0 : enBuyuk * 1.12);
    const h = 230.0, ustBosluk = 22.0, altBosluk = 34.0;
    return SizedBox(
      height: h,
      child: LayoutBuilder(builder: (context, kis) {
        final w = kis.maxWidth;
        final yan = math.min(56.0, w * 0.12);
        double x(int i) => kat.length == 1 ? w / 2 : yan + i * (w - 2 * yan) / (kat.length - 1);
        double y(double v) => ustBosluk + (1 - (v / ust).clamp(0.0, 1.0)) * (h - ustBosluk - altBosluk);
        final cizgiler = <_CizgiVerisi>[];
        final etiketler = <Widget>[];
        for (final d in diziler.isEmpty ? [const YzGrafikDizi('', '', '')] : diziler) {
          final noktalar = <Offset>[];
          for (var i = 0; i < kat.length; i++) {
            for (final n in g.cizilenler.where((n) => n.kategori(en) == kat[i] && (d.kod.isEmpty || n.dizi == d.kod))) {
              final o = Offset(x(i), y(n.deger));
              noktalar.add(o);
              etiketler.add(Positioned(
                left: (o.dx - 44).clamp(0.0, math.max(0.0, w - 88)).toDouble(),
                width: 88,
                top: o.dy - 20,
                child: Text(g.yaz(n, en),
                    textAlign: TextAlign.center,
                    style: YzYazi.veri(boy: 11.5, renk: _temelRenk(g, d.kod), kalinlik: FontWeight.w700)),
              ));
            }
          }
          cizgiler.add(_CizgiVerisi(noktalar, _temelRenk(g, d.kod), d.rol == 'ongoru'));
        }
        return Stack(clipBehavior: Clip.none, children: [
          CustomPaint(
            size: Size(w, h),
            painter: _CizgiCizeri(
              cizgiler: cizgiler,
              izgara: [for (final f in const [0.0, 0.25, 0.5, 0.75, 1.0]) y(ust * f)],
              alan: alan,
              taban: y(0),
            ),
          ),
          ...etiketler,
          for (var i = 0; i < kat.length; i++)
            Positioned(
              left: (x(i) - 60).clamp(0.0, math.max(0.0, w - 120)).toDouble(),
              width: 120,
              top: h - altBosluk + 8,
              child: Text(kat[i],
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: YzYazi.veri(boy: 11, renk: YzRenk.soluk)),
            ),
        ]);
      }),
    );
  }
}

class _CizgiVerisi {
  const _CizgiVerisi(this.noktalar, this.renk, this.kesikli);
  final List<Offset> noktalar;
  final Color renk;
  final bool kesikli;
}

class _CizgiCizeri extends CustomPainter {
  _CizgiCizeri({required this.cizgiler, required this.izgara, required this.alan, required this.taban});
  final List<_CizgiVerisi> cizgiler;
  final List<double> izgara;
  final bool alan;
  final double taban;

  @override
  void paint(Canvas canvas, Size size) {
    final ince = Paint()
      ..color = YzRenk.cizgi
      ..strokeWidth = 0.7;
    for (final y in izgara) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), ince);
    }
    for (final c in cizgiler) {
      if (c.noktalar.isEmpty) continue;
      if (alan && c.noktalar.length > 1) {
        final yol = Path()..moveTo(c.noktalar.first.dx, taban);
        for (final o in c.noktalar) {
          yol.lineTo(o.dx, o.dy);
        }
        yol
          ..lineTo(c.noktalar.last.dx, taban)
          ..close();
        canvas.drawPath(yol, Paint()..color = c.renk.withValues(alpha: 0.14));
      }
      final kalem = Paint()
        ..color = c.renk
        ..strokeWidth = 2.4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      for (var i = 0; i + 1 < c.noktalar.length; i++) {
        final a = c.noktalar[i], b = c.noktalar[i + 1];
        if (!c.kesikli) {
          canvas.drawLine(a, b, kalem);
          continue;
        }
        final d = b - a;
        final boy = d.distance;
        for (var s = 0.0; s < boy; s += 9) {
          final e = math.min(s + 5, boy);
          canvas.drawLine(a + d * (s / boy), a + d * (e / boy), kalem);
        }
      }
      for (final o in c.noktalar) {
        canvas.drawCircle(o, 4.2, Paint()..color = YzRenk.yuzey);
        canvas.drawCircle(
            o,
            4.2,
            Paint()
              ..color = c.renk
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2);
      }
    }
  }

  @override
  bool shouldRepaint(_CizgiCizeri old) => true;
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
    final ekli = g.noktalar.any((n) => n.ek(en).isNotEmpty);
    final etiketGenisligi = ekli ? 104.0 : 82.0;
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
                final ns = g.cizilenler.where((n) => n.kategori(en) == k).toList();
                if (ns.isEmpty) return const SizedBox.shrink();
                final xs = [for (final n in ns) _x(n.deger, ust, w) + 8];
                final sol = xs.reduce(math.min), sag = xs.reduce(math.max);
                // Yakın iki değerin etiketi üst üste binmesin: biri çizginin üstüne.
                final yakin = ns.length == 2 && (xs[0] - xs[1]).abs() < etiketGenisligi;
                final cizgi = yakin ? 31.0 : 13.0;
                return SizedBox(
                  height: yakin ? 58 : 42,
                  child: Stack(clipBehavior: Clip.none, children: [
                    Positioned(left: 8, right: 8, top: cizgi, child: Container(height: 1, color: YzRenk.cizgi)),
                    Positioned(
                      left: sol,
                      width: math.max(sag - sol, 1),
                      top: cizgi - 2,
                      child: Container(
                        height: 5,
                        decoration: BoxDecoration(
                            color: YzRenk.makine.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(3)),
                      ),
                    ),
                    for (var i = 0; i < ns.length; i++) ...[
                      Positioned(
                        left: xs[i] - 7,
                        top: cizgi - 6,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: _renk(g, ns[i].dizi),
                            shape: BoxShape.circle,
                            border: Border.all(color: YzRenk.yuzey, width: 2),
                          ),
                        ),
                      ),
                      Positioned(
                        left: (xs[i] - etiketGenisligi / 2)
                            .clamp(0.0, math.max(0.0, kis.maxWidth - etiketGenisligi))
                            .toDouble(),
                        width: etiketGenisligi,
                        top: yakin && i == 0 ? 2 : cizgi + 11,
                        child: Text(
                          ns[i].ek(en).isEmpty ? g.yaz(ns[i], en) : '${g.yaz(ns[i], en)} · ${ns[i].ek(en)}',
                          textAlign: TextAlign.center,
                          style: YzYazi.veri(boy: 11.5, renk: _temelRenk(g, ns[i].dizi), kalinlik: FontWeight.w700),
                        ),
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
                final ns = g.cizilenler.where((n) => n.kategori(en) == k).toList();
                final a = ns.where((n) => n.uc != 'ust').map((n) => n.deger).fold<double>(double.infinity, math.min);
                final u = ns.where((n) => n.uc != 'alt').map((n) => n.deger).fold<double>(0, math.max);
                final w = kis.maxWidth;
                final renk = _renk(g, ns.isEmpty ? '' : ns.first.dizi);
                final metin = a == u
                    ? g.yazDeger(a, en)
                    : (birim == '%'
                        ? (en ? '${yzSayi(a, en)}–${yzSayi(u, en)}%' : '%${yzSayi(a, en)}–${yzSayi(u, en)}')
                        : '${yzSayi(a, en)}–${g.yazDeger(u, en)}');
                final sag = _x(u, ust, w);
                final yaziSolda = sag > w - 96;
                return SizedBox(
                  height: 22,
                  child: Stack(children: [
                    Positioned.fill(
                      top: 7,
                      bottom: 7,
                      child: Container(
                          decoration: BoxDecoration(color: YzRenk.zemin, borderRadius: BorderRadius.circular(4))),
                    ),
                    Positioned(
                      left: _x(a, ust, w),
                      width: math.max(sag - _x(a, ust, w), 6),
                      top: 4,
                      bottom: 4,
                      child: Container(decoration: BoxDecoration(color: renk, borderRadius: BorderRadius.circular(7))),
                    ),
                    Positioned(
                      left: yaziSolda ? math.max(0.0, _x(a, ust, w) - 96) : sag + 6,
                      width: 90,
                      top: 2,
                      child: Text(metin,
                          textAlign: yaziSolda ? TextAlign.right : TextAlign.left,
                          style: YzYazi.veri(boy: 12, renk: YzRenk.murekkep, kalinlik: FontWeight.w700)),
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

/// Pay çubuğu: bir çubuk = bir kategori, parçaları dizi. Yüzdelerde çubuk
/// 100'e tamamlanır (kalan kısım etiketsiz, açık zeminle); 'toplam' dizisi
/// çubuğun altında toplam etiketi olur.
class _Pay extends StatelessWidget {
  const _Pay({required this.g, required this.en, required this.secili, required this.sec});
  final YzGrafik g;
  final bool en;
  final String? secili;
  final ValueChanged<String?> sec;

  @override
  Widget build(BuildContext context) {
    final yuzde = g.birimTr == '%';
    final kategoriler = g.kategoriler(en);
    final toplamlar = [for (final n in g.noktalar) if (g.rol(n.dizi) == 'toplam') n];
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      for (final k in kategoriler) ...[
        if (kategoriler.length > 1)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(k, style: YzYazi.govde(boy: 14, renk: YzRenk.murekkep)),
          ),
        _Secilebilir(
          kategori: k,
          secili: secili,
          sec: sec,
          child: LayoutBuilder(builder: (context, kis) {
            final ns = g.cizilenler.where((n) => n.kategori(en) == k).toList();
            final toplam = ns.fold<double>(0, (s, n) => s + n.deger);
            final payda = yuzde ? math.max(100.0, toplam) : (toplam <= 0 ? 1.0 : toplam);
            final kalan = yuzde ? payda - toplam : 0.0;
            return ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Row(children: [
                for (final n in ns)
                  Container(
                    width: math.max(kis.maxWidth * n.deger / payda, 2),
                    height: 34,
                    color: _renk(g, n.dizi),
                    alignment: Alignment.center,
                    child: kis.maxWidth * n.deger / payda > 64
                        ? Text(g.yaz(n, en),
                            maxLines: 1, style: YzYazi.veri(boy: 12, renk: Colors.white, kalinlik: FontWeight.w700))
                        : null,
                  ),
                if (kalan > 0.3) Expanded(child: Container(height: 34, color: YzRenk.zemin)),
              ]),
            );
          }),
        ),
        const SizedBox(height: 8),
        Wrap(spacing: 14, runSpacing: 4, children: [
          for (final n in g.cizilenler.where((n) => n.kategori(en) == k))
            Row(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 9, height: 9, color: _renk(g, n.dizi)),
              const SizedBox(width: 5),
              Flexible(
                // Telefonda dizi adı sade küçük Outfit, değer mono (karar 62).
                child: yzTelefon(context)
                    ? Text.rich(TextSpan(children: [
                        TextSpan(
                            text: '${g.diziAdi(n.dizi, en)} ',
                            style: yzKunyeYazisi(renk: YzRenk.murekkep, boy: 13)),
                        TextSpan(
                            text: g.yaz(n, en),
                            style: YzYazi.veri(boy: 12, renk: YzRenk.murekkep, kalinlik: FontWeight.w600)),
                      ]))
                    : Text('${g.diziAdi(n.dizi, en)} ${g.yaz(n, en)}',
                        style: YzYazi.veri(boy: 12, renk: YzRenk.murekkep, kalinlik: FontWeight.w600)),
              ),
            ]),
        ]),
        const SizedBox(height: 12),
      ],
      for (final t in toplamlar)
        Text('${t.kategori(en)}: ${g.yaz(t, en)}',
            style: YzYazi.veri(boy: 12.5, renk: YzRenk.murekkep, kalinlik: FontWeight.w700)),
    ]);
  }
}

/// Kare grafiği. İki biçim:
///  · yüzde: her nokta 10×10'luk bir ızgara, değeri kadar kare boyalı;
///  · sayı: 'toplam' dizisi kare sayısını verir (ör. 71 eylem), öbür
///    noktalar boyalı kareler (ör. tarımı anan 0 eylem). Panel varsa her
///    panel ayrı ızgara.
class _Waffle extends StatelessWidget {
  const _Waffle({required this.g, required this.en});
  final YzGrafik g;
  final bool en;

  @override
  Widget build(BuildContext context) {
    final toplamlar = [for (final n in g.noktalar) if (g.rol(n.dizi) == 'toplam') n];
    final panelli = g.noktalar.any((n) => n.panelTr.isNotEmpty);
    final paneller = <(String, List<YzGrafikNokta>, YzGrafikNokta?)>[];
    if (panelli) {
      final adlar = <String>[];
      for (final n in g.noktalar) {
        if (!adlar.contains(n.panel(en))) adlar.add(n.panel(en));
      }
      for (final a in adlar) {
        final t = toplamlar.where((n) => n.panel(en) == a);
        paneller.add((a, [for (final n in g.cizilenler) if (n.panel(en) == a) n], t.isEmpty ? null : t.first));
      }
    } else if (toplamlar.isNotEmpty) {
      paneller.add(('', g.cizilenler, toplamlar.first));
    } else {
      for (final n in g.cizilenler) {
        paneller.add(('', [n], null));
      }
    }
    return Wrap(spacing: 28, runSpacing: 20, children: [
      for (final p in paneller) _WafflePaneli(g: g, en: en, baslik: p.$1, boyali: p.$2, toplam: p.$3),
    ]);
  }
}

class _WafflePaneli extends StatelessWidget {
  const _WafflePaneli({
    required this.g,
    required this.en,
    required this.baslik,
    required this.boyali,
    required this.toplam,
  });
  final YzGrafik g;
  final bool en;
  final String baslik;
  final List<YzGrafikNokta> boyali;
  final YzGrafikNokta? toplam;

  @override
  Widget build(BuildContext context) {
    final kare = toplam == null ? 100 : toplam!.deger.round();
    final sutun = kare == 100 ? 10 : math.sqrt(kare * 2.2).ceil().clamp(5, 12);
    const boy = 11.0, ara = 2.5;
    final renkler = <Color>[
      for (final n in boyali)
        for (var i = 0; i < n.deger.round(); i++) _renk(g, n.dizi),
    ];
    final izgara = sutun * (boy + ara) - ara;
    return SizedBox(
      width: math.max(izgara, 150),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (baslik.isNotEmpty) ...[
          Text(baslik, style: YzYazi.govde(boy: 13.5, renk: YzRenk.murekkep).copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
        ],
        SizedBox(
          width: izgara,
          child: Wrap(spacing: ara, runSpacing: ara, children: [
            for (var i = 0; i < kare; i++)
              Container(
                width: boy,
                height: boy,
                decoration: BoxDecoration(
                  color: i < renkler.length ? renkler[i] : YzRenk.zemin,
                  borderRadius: BorderRadius.circular(1.5),
                  border: i < renkler.length ? null : Border.all(color: YzRenk.cizgi, width: 0.5),
                ),
              ),
          ]),
        ),
        const SizedBox(height: 8),
        for (final n in boyali) ...[
          Wrap(crossAxisAlignment: WrapCrossAlignment.end, spacing: 6, children: [
            Text(g.yaz(n, en), style: YzYazi.baslik(24, renk: _temelRenk(g, n.dizi))),
            if (toplam != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text('/ ${g.yaz(toplam!, en)}', style: YzYazi.veri(boy: 13, renk: YzRenk.soluk)),
              ),
          ]),
          Text(n.kategori(en), style: YzYazi.govde(boy: 13, renk: YzRenk.soluk)),
          const SizedBox(height: 4),
        ],
      ]),
    );
  }
}

/// Eğim grafiği: iki zaman noktası = iki dizi (soldaki ilk dizi); her
/// kategori bir çizgi, kendi rengiyle; adları altta.
class _Egim extends StatelessWidget {
  const _Egim({required this.g, required this.en, required this.secili, required this.sec});
  final YzGrafik g;
  final bool en;
  final String? secili;
  final ValueChanged<String?> sec;

  @override
  Widget build(BuildContext context) {
    final d = g.diziler;
    if (d.length < 2) return _Tablo(g: g, en: en);
    final kat = g.kategoriler(en);
    YzGrafikNokta? nokta(String k, String dz) {
      for (final n in g.noktalar) {
        if (n.kategori(en) == k && n.dizi == dz) return n;
      }
      return null;
    }

    final enBuyuk = g.noktalar.map((n) => n.deger).fold<double>(0, math.max);
    final ust = g.ust ?? (g.birimTr == '%' && enBuyuk <= 100 ? 100.0 : enBuyuk);
    Color renk(int i) => kYzGrafikRenkleri[i % kYzGrafikRenkleri.length];
    const h = 210.0;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      SizedBox(
        height: h,
        child: LayoutBuilder(builder: (context, kis) {
          final w = kis.maxWidth;
          final kenar = math.min(110.0, w * 0.26);
          double y(double v) => 26 + (1 - (v / ust).clamp(0.0, 1.0)) * (h - 44);
          // Yakın değerlerin etiketleri üst üste binmesin: aralarında en az 17 piksel.
          Map<int, double> ayir(String dz) {
            final ys = <int, double>{
              for (var i = 0; i < kat.length; i++)
                if (nokta(kat[i], dz) case final n?) i: y(n.deger),
            };
            final sira = ys.keys.toList()..sort((a, b) => ys[a]!.compareTo(ys[b]!));
            for (var k = 1; k < sira.length; k++) {
              if (ys[sira[k]]! - ys[sira[k - 1]]! < 17) ys[sira[k]] = ys[sira[k - 1]]! + 17;
            }
            return ys;
          }

          final solY = ayir(d[0].kod), sagY = ayir(d[1].kod);
          return Stack(clipBehavior: Clip.none, children: [
            CustomPaint(
              size: Size(w, h),
              painter: _EgimCizeri(
                cizgiler: [
                  for (var i = 0; i < kat.length; i++)
                    if (nokta(kat[i], d[0].kod) != null && nokta(kat[i], d[1].kod) != null)
                      (
                        y(nokta(kat[i], d[0].kod)!.deger),
                        y(nokta(kat[i], d[1].kod)!.deger),
                        secili == null || secili == kat[i] ? renk(i) : YzRenk.cizgi,
                      ),
                ],
                sol: kenar,
                sag: w - kenar,
              ),
            ),
            Positioned(
              left: 0,
              width: kenar - 6,
              top: 0,
              child: Text(d[0].ad(en), textAlign: TextAlign.right, style: YzYazi.ustEtiket()),
            ),
            Positioned(right: 0, width: kenar - 6, top: 0, child: Text(d[1].ad(en), style: YzYazi.ustEtiket())),
            for (var i = 0; i < kat.length; i++) ...[
              if (nokta(kat[i], d[0].kod) case final a?)
                Positioned(
                  left: 0,
                  width: kenar - 10,
                  top: solY[i]! - 9,
                  child: Text(g.yaz(a, en),
                      textAlign: TextAlign.right,
                      style: YzYazi.veri(boy: 12, renk: renk(i), kalinlik: FontWeight.w700)),
                ),
              if (nokta(kat[i], d[1].kod) case final b?)
                Positioned(
                  right: 0,
                  width: kenar - 10,
                  top: sagY[i]! - 9,
                  child: Text(g.yaz(b, en), style: YzYazi.veri(boy: 12, renk: renk(i), kalinlik: FontWeight.w700)),
                ),
            ],
          ]);
        }),
      ),
      const SizedBox(height: 8),
      Wrap(spacing: 16, runSpacing: 6, children: [
        for (var i = 0; i < kat.length; i++)
          _Secilebilir(
            kategori: kat[i],
            secili: secili,
            sec: sec,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 14, height: 3, color: renk(i)),
              const SizedBox(width: 6),
              // Lejant adı: telefonda sade küçük Outfit (karar 62).
              Flexible(
                  child: Text(kat[i],
                      style: yzTelefon(context)
                          ? yzKunyeYazisi(renk: YzRenk.murekkep, boy: 13)
                          : YzYazi.veri(boy: 12, renk: YzRenk.murekkep))),
            ]),
          ),
      ]),
    ]);
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
    canvas.drawLine(Offset(sol, 18), Offset(sol, size.height - 10), eksen);
    canvas.drawLine(Offset(sag, 18), Offset(sag, size.height - 10), eksen);
    for (final (a, b, renk) in cizgiler) {
      final p = Paint()
        ..color = renk
        ..strokeWidth = 2.6
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(sol, a), Offset(sag, b), p);
      canvas.drawCircle(Offset(sol, a), 4.5, Paint()..color = renk);
      canvas.drawCircle(Offset(sag, b), 4.5, Paint()..color = renk);
    }
  }

  @override
  bool shouldRepaint(_EgimCizeri old) => true;
}

class _Kpi extends StatelessWidget {
  const _Kpi({required this.g, required this.en});
  final YzGrafik g;
  final bool en;

  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: 12, runSpacing: 12, children: [
      for (final n in g.cizilenler)
        Container(
          constraints: const BoxConstraints(minWidth: 140, maxWidth: 230),
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          // Rakam kartı: dizinin renginde yumuşak zemin ve ince çerçeve,
          // yuvarlak köşe; sol şerit yok (kullanıcı, 18 Kas 2026).
          decoration: BoxDecoration(
            color: _temelRenk(g, n.dizi).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _temelRenk(g, n.dizi).withValues(alpha: 0.28)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(g.yaz(n, en), style: YzYazi.baslik(28, renk: _temelRenk(g, n.dizi))),
            const SizedBox(height: 4),
            Text(n.kategori(en), style: YzYazi.govde(boy: 13.5, renk: YzRenk.murekkep)),
            if (g.noktaBirimi(n, false) == '%') ...[
              const SizedBox(height: 8),
              _Cubuk(oran: n.deger / 100, renk: _temelRenk(g, n.dizi), yukseklik: 5),
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
                child: Text(s.ad(en), textAlign: TextAlign.center, style: YzYazi.veri(boy: 11, renk: YzRenk.soluk)),
              ),
          ]),
          for (final r in satirlar)
            TableRow(children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 200),
                child: Padding(
                  padding: const EdgeInsets.only(right: 10, top: 2, bottom: 2),
                  child: Text(r, style: YzYazi.govde(boy: 13.5, renk: YzRenk.murekkep)),
                ),
              ),
              for (final s in sutunlar)
                Builder(builder: (_) {
                  final n = g.noktalar.where((n) => n.kategori(en) == r && n.dizi == s.kod).toList();
                  final v = n.isEmpty ? null : n.first.deger;
                  final oran = v == null ? 0.0 : (v / ust).clamp(0.0, 1.0).toDouble();
                  return Container(
                    margin: const EdgeInsets.all(2),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                    color: v == null ? YzRenk.zemin : Color.lerp(YzRenk.makineAcik, YzRenk.makine, oran),
                    child: Text(v == null ? '—' : g.yaz(n.first, en),
                        textAlign: TextAlign.center,
                        style: YzYazi.veri(
                            boy: 12, renk: oran > 0.55 ? Colors.white : YzRenk.murekkep, kalinlik: FontWeight.w600)),
                  );
                }),
            ]),
        ],
      ),
    );
  }
}

/// Zaman çizelgesi: olaylar tarih sırasıyla. İki şerit varsa geniş ekranda
/// eksenin iki yanına (ör. solda dünya, sağda Türkiye); dar ekranda tek
/// sütun, şeridin rengi ve adıyla. Şirket beyanı olan olay içi boş işaretle.
class _Zaman extends StatelessWidget {
  const _Zaman({required this.g, required this.en});
  final YzGrafik g;
  final bool en;

  @override
  Widget build(BuildContext context) {
    final olaylar = [...g.cizilenler]..sort((a, b) => a.deger.compareTo(b.deger));
    final seritler = [
      for (final d in g.diziler)
        if (d.rol != 'toplam' && d.rol != 'referans') d,
    ];
    Widget isaret(YzGrafikNokta n) => Container(
          width: 11,
          height: 11,
          margin: const EdgeInsets.only(top: 4),
          decoration: BoxDecoration(
            color: n.satici ? YzRenk.yuzey : _temelRenk(g, n.dizi),
            shape: BoxShape.circle,
            border: Border.all(color: _temelRenk(g, n.dizi), width: 2),
          ),
        );
    Widget tarih(YzGrafikNokta n, {TextAlign hiza = TextAlign.left}) => Text(_tarih(n, en),
        textAlign: hiza, style: YzYazi.veri(boy: 12.5, renk: _temelRenk(g, n.dizi), kalinlik: FontWeight.w700));
    Widget olay(YzGrafikNokta n, {TextAlign hiza = TextAlign.left}) => Text(n.kategori(en),
        textAlign: hiza, style: YzYazi.govde(boy: 14.5, renk: YzRenk.murekkep).copyWith(height: 1.35));
    Widget eksen(int i) => Column(children: [
          isaret(olaylar[i]),
          if (i < olaylar.length - 1) Expanded(child: Container(width: 1.5, color: YzRenk.cizgi)),
        ]);

    return LayoutBuilder(builder: (context, kis) {
      if (seritler.length == 2 && kis.maxWidth >= 600) {
        return Column(children: [
          Row(children: [
            Expanded(
              child: Text(buyukHarf(seritler[0].ad(en), en),
                  textAlign: TextAlign.right, style: YzYazi.ustEtiket(renk: _temelRenk(g, seritler[0].kod))),
            ),
            const SizedBox(width: 40),
            Expanded(
              child: Text(buyukHarf(seritler[1].ad(en), en),
                  style: YzYazi.ustEtiket(renk: _temelRenk(g, seritler[1].kod))),
            ),
          ]),
          const SizedBox(height: 10),
          for (var i = 0; i < olaylar.length; i++)
            IntrinsicHeight(
              child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Expanded(
                  child: olaylar[i].dizi == seritler[0].kod
                      ? Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                            tarih(olaylar[i], hiza: TextAlign.right),
                            olay(olaylar[i], hiza: TextAlign.right),
                          ]),
                        )
                      : const SizedBox.shrink(),
                ),
                SizedBox(width: 40, child: eksen(i)),
                Expanded(
                  child: olaylar[i].dizi == seritler[1].kod
                      ? Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            tarih(olaylar[i]),
                            olay(olaylar[i]),
                          ]),
                        )
                      : const SizedBox.shrink(),
                ),
              ]),
            ),
        ]);
      }
      final tarihGenisligi = kis.maxWidth < 420 ? 84.0 : 112.0;
      return Column(children: [
        for (var i = 0; i < olaylar.length; i++)
          IntrinsicHeight(
            child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              SizedBox(
                width: tarihGenisligi,
                child: Padding(padding: const EdgeInsets.only(top: 1, right: 6), child: tarih(olaylar[i])),
              ),
              SizedBox(width: 20, child: eksen(i)),
              const SizedBox(width: 8),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    if (seritler.length > 1)
                      Text(buyukHarf(g.diziAdi(olaylar[i].dizi, en), en),
                          style: YzYazi.ustEtiket(renk: _temelRenk(g, olaylar[i].dizi))),
                    olay(olaylar[i]),
                  ]),
                ),
              ),
            ]),
          ),
      ]);
    });
  }
}

/// Küçük çoklu: her panel kendi ölçeğiyle küçük bir yatay çubuk grafiği
/// (ölçüler birbirine çevrilemediğinde aynı eksene konmaz).
class _Kucuk extends StatelessWidget {
  const _Kucuk({required this.g, required this.en});
  final YzGrafik g;
  final bool en;

  @override
  Widget build(BuildContext context) {
    final adlar = <String>[];
    for (final n in g.cizilenler) {
      if (!adlar.contains(n.panel(en))) adlar.add(n.panel(en));
    }
    return LayoutBuilder(builder: (context, kis) {
      final sutun = kis.maxWidth >= 560 ? 2 : 1;
      final w = (kis.maxWidth - (sutun - 1) * 24) / sutun;
      return Wrap(spacing: 24, runSpacing: 20, children: [
        for (final a in adlar)
          SizedBox(
            width: w,
            child: Builder(builder: (context) {
              final ns = [for (final n in g.cizilenler) if (n.panel(en) == a) n];
              final yuzde = ns.every((n) => g.noktaBirimi(n, false) == '%');
              final ust = yuzde ? 100.0 : math.max(ns.map((n) => n.deger).fold<double>(0, math.max), 1e-9);
              return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                if (a.isNotEmpty) ...[
                  Text(a, style: YzYazi.govde(boy: 13.5, renk: YzRenk.murekkep).copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Container(height: 1, color: YzRenk.cizgi),
                  const SizedBox(height: 8),
                ],
                for (final n in ns) ...[
                  Text(n.kategori(en), style: YzYazi.veri(boy: 12, renk: YzRenk.soluk)),
                  const SizedBox(height: 3),
                  Row(children: [
                    Expanded(
                      child: _Cubuk(
                        oran: n.deger / ust,
                        renk: _renk(g, n.dizi),
                        kenar: g.rol(n.dizi) == 'ongoru' ? _temelRenk(g, n.dizi) : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 128,
                      child: Text(g.yaz(n, en),
                          style: YzYazi.veri(boy: 12.5, renk: YzRenk.murekkep, kalinlik: FontWeight.w600)),
                    ),
                  ]),
                  const SizedBox(height: 8),
                ],
              ]);
            }),
          ),
      ]);
    });
  }
}

class _Tablo extends StatelessWidget {
  const _Tablo({required this.g, required this.en});
  final YzGrafik g;
  final bool en;

  @override
  Widget build(BuildContext context) {
    final cokDizi = g.diziler.where((d) => d.rol != 'toplam' && d.rol != 'referans').length > 1;
    String etiket(YzGrafikNokta n) {
      final dizi = g.diziAdi(n.dizi, en);
      final diziEki = cokDizi && g.tur != 'zaman' && !n.kategori(en).contains(dizi) ? ' · $dizi' : '';
      return '${n.panelTr.isNotEmpty ? '${n.panel(en)} · ' : ''}${n.kategori(en)}$diziEki${_uc(n, en)}';
    }

    return Table(
      columnWidths: const {0: FlexColumnWidth(3), 1: FlexColumnWidth(2)},
      border: const TableBorder(horizontalInside: BorderSide(color: YzRenk.cizgi)),
      children: [
        for (final n in g.noktalar)
          TableRow(children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(etiket(n), style: YzYazi.govde(boy: 14, renk: YzRenk.murekkep)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(
                g.tur == 'zaman'
                    ? _tarih(n, en)
                    : (n.ek(en).isEmpty ? g.yaz(n, en) : '${g.yaz(n, en)} · ${n.ek(en)}'),
                textAlign: TextAlign.right,
                style: YzYazi.veri(boy: 13, renk: YzRenk.murekkep, kalinlik: FontWeight.w600),
              ),
            ),
          ]),
      ],
    );
  }
}
