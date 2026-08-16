import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_typography.dart';
import '../../data/models/dossier_chart.dart';
import '../../data/models/dossier_theme.dart';

/// Yedi grafik türünün çizicisi ve dağıtıcısı.
///
/// **Neden altısı CustomPainter değil:** çubuk, künye, çizelge ve kartlarda
/// çizilecek tek şey dikdörtgen ve metin. Bunları tuvale boyamak metin
/// seçilebilirliğini, ekran okuyucuyu ve sistem yazı boyu tercihini elden
/// çıkarırdı — karşılığında hiçbir şey kazandırmadan. Yalnızca [CizgiChart]
/// gerçekten yol çizmek zorunda; tek [CustomPainter] orada.
///
/// **Renk körlüğü şartı burada iki kez karşılanıyor.** Birincisi biçim: ikincil
/// seri taralı çubuk ve kesikli çizgi alıyor ([ChartRole] veriyor). İkincisi ve
/// daha sağlamı metin: her çubuğun, her dilimin, her noktanın rakamı yanında
/// yazılı. Ekrandaki tüm renk kaybolsa grafik yine okunur.
class DossierChartView extends StatelessWidget {
  const DossierChartView({
    super.key,
    required this.chart,
    required this.tema,
    required this.isEn,
  });

  final DossierChart chart;
  final DossierTheme tema;
  final bool isEn;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: tema.yuzey,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: tema.cizgi),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            chart.baslik.of(isEn),
            style: AppTypography.headlineCard(context, color: tema.murekkep),
          ),
          const SizedBox(height: 16),

          // `sealed` sınıf sayesinde bu switch tam kapsamlı: sekizinci bir tür
          // eklendiğinde burası derlenmez. Sessizce boş kutu çizme ihtimali yok.
          switch (chart) {
            IkiliCubukChart() => _IkiliCubuk(c: chart as IkiliCubukChart, tema: tema, isEn: isEn),
            SiralamaChart() => _Siralama(c: chart as SiralamaChart, tema: tema, isEn: isEn),
            CizgiChart() => _Cizgi(c: chart as CizgiChart, tema: tema, isEn: isEn),
            YiginChart() => _Yigin(c: chart as YiginChart, tema: tema, isEn: isEn),
            KunyeChart() => _Kunye(c: chart as KunyeChart, tema: tema, isEn: isEn),
            ZamanCizelgesiChart() =>
              _ZamanCizelgesi(c: chart as ZamanCizelgesiChart, tema: tema, isEn: isEn),
            KartlarChart() => _Kartlar(c: chart as KartlarChart, tema: tema, isEn: isEn),
          },

          if (chart.not != null) ...[
            const SizedBox(height: 16),
            Text(
              chart.not!.of(isEn),
              style: AppTypography.meta(context, color: tema.sessiz)
                  .copyWith(fontStyle: FontStyle.italic, height: 1.45),
            ),
          ],
          if (chart.kaynak != null) ...[
            const SizedBox(height: 12),
            Text(
              chart.kaynak!,
              style: AppTypography.meta(context, color: tema.sessiz)
                  .copyWith(fontSize: 11.5, letterSpacing: 0.4, height: 1.4),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Ortak parçalar ─────────────────────────────────────────────────────────

/// Bir rolün dolgusu: düz ya da taralı.
///
/// Tarama, turuncu ile yeşilin eş parlaklıkta olmasının panzehiri. Deuteranopi
/// altında iki çubuk aynı griye düşüyor; eğik tarama farkı korur.
class _Dolgu extends StatelessWidget {
  const _Dolgu({required this.rol, required this.tema, this.yukseklik = 16});

  final ChartRole rol;
  final DossierTheme tema;
  final double yukseklik;

  @override
  Widget build(BuildContext context) {
    final renk = rol.renk(tema);
    return SizedBox(
      height: yukseklik,
      child: rol.taramali
          ? CustomPaint(painter: _TaramaBoyaci(renk), child: const SizedBox.expand())
          : DecoratedBox(
              decoration: BoxDecoration(
                color: renk,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
    );
  }
}

class _TaramaBoyaci extends CustomPainter {
  _TaramaBoyaci(this.renk);

  final Color renk;

  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(2));
    canvas.save();
    canvas.clipRRect(r);

    // Zemin: aynı renk ama zayıf. Tarama tek başına bırakılsaydı çubuk
    // ötekinden ince görünür, uzunluk karşılaştırması bozulurdu.
    canvas.drawRect(Offset.zero & size, Paint()..color = renk.withValues(alpha: 0.28));

    final kalem = Paint()
      ..color = renk
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.square;
    const aralik = 6.0;
    for (var x = -size.height; x < size.width; x += aralik) {
      canvas.drawLine(Offset(x, size.height), Offset(x + size.height, 0), kalem);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_TaramaBoyaci eski) => eski.renk != renk;
}

/// Seri açıklaması — renk örneği + ad.
///
/// Örnek kutusu da [_Dolgu] kullanıyor: göstergedeki desen ile çubuktaki desen
/// aynı yerden geliyor, ayrışamazlar.
class _Gosterge extends StatelessWidget {
  const _Gosterge({required this.ogeler, required this.tema});

  final List<(ChartRole, String)> ogeler;
  final DossierTheme tema;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 18,
      runSpacing: 8,
      children: [
        for (final (rol, ad) in ogeler)
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: SizedBox(
                  width: 16,
                  child: _Dolgu(rol: rol, tema: tema, yukseklik: 10),
                ),
              ),
              const SizedBox(width: 7),
              // Flexible şart: seri adları içerikten geliyor ve her ülkede
              // değişiyor. "Hollanda tarımsal ihracatı" 360 px'te satırı
              // taşırıyordu. Wrap yatayda sınırlı genişlik verdiği için
              // Flexible burada metnin ikinci satıra dökülmesini sağlıyor.
              Flexible(
                child: Text(ad, style: AppTypography.meta(context, color: tema.sessiz)),
              ),
            ],
          ),
      ],
    );
  }
}

/// Rakam metni — her yerde aynı hizada dursun diye tek yerde.
TextStyle _rakamStili(BuildContext context, Color renk) =>
    AppTypography.meta(context, color: renk).copyWith(
      fontWeight: FontWeight.w700,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

// ─── 1. İkili çubuk ─────────────────────────────────────────────────────────

/// İki seriyi satır satır karşılaştırır.
///
/// Her satır KENDİ içinde oranlanıyor, satırlar birbiriyle değil. Sebep tarif
/// dosyasında yazılı: bir satır yüzde, öteki km² olabiliyor. Ortak eksene
/// koymak karşılaştırma değil çarpıtma olurdu.
class _IkiliCubuk extends StatelessWidget {
  const _IkiliCubuk({required this.c, required this.tema, required this.isEn});

  final IkiliCubukChart c;
  final DossierTheme tema;
  final bool isEn;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Gosterge(
          ogeler: [for (final s in c.seriler) (s.rol, s.ad.of(isEn))],
          tema: tema,
        ),
        const SizedBox(height: 18),
        for (final satir in c.satirlar) ...[
          _satir(context, satir),
          const SizedBox(height: 20),
        ],
      ],
    );
  }

  Widget _satir(BuildContext context, IkiliSatir satir) {
    final adet = math.min(satir.degerler.length, c.seriler.length);
    final enBuyuk = satir.degerler
        .take(adet)
        .fold<num>(0, (e, d) => d > e ? d : e)
        .clamp(1, double.infinity);

    final altBilgi = [
      if (satir.birim != null) satir.birim!.of(isEn),
      if (satir.yil != null) '${satir.yil}',
    ].join(' · ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                satir.etiket.of(isEn),
                style: AppTypography.meta(context, color: tema.murekkep)
                    .copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            if (satir.rozet != null) ...[
              const SizedBox(width: 10),
              // Oran rozeti hesaplanmıyor, yayında yazılıyor: hangi oranın
              // anlamlı olduğu bir editör kararı.
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  border: Border.all(color: tema.cizgiVurgu),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  satir.rozet!.of(isEn),
                  style: _rakamStili(context, tema.vurgu).copyWith(fontSize: 11.5),
                ),
              ),
            ],
          ],
        ),
        if (altBilgi.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              altBilgi,
              style: AppTypography.meta(context, color: tema.sessiz)
                  .copyWith(fontSize: 11.5),
            ),
          ),
        const SizedBox(height: 8),
        for (var i = 0; i < adet; i++) ...[
          _cubuk(
            context,
            rol: c.seriler[i].rol,
            ad: c.seriler[i].ad.of(isEn),
            oran: satir.degerler[i] / enBuyuk,
            metin: satir.bicim.bicimle(satir.degerler[i], isEn),
          ),
          if (i < adet - 1) const SizedBox(height: 7),
        ],
      ],
    );
  }

  Widget _cubuk(
    BuildContext context, {
    required ChartRole rol,
    required String ad,
    required num oran,
    required String metin,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(ad, style: AppTypography.meta(context, color: tema.sessiz)),
            ),
            // Rakam çubuğun ucunda değil sağ kenarda: uçta olsaydı kısa
            // çubukların rakamı solda, uzunlarınki sağda kalır ve rakamlar
            // birbiriyle karşılaştırılamazdı.
            Text(metin, style: _rakamStili(context, tema.murekkep)),
          ],
        ),
        const SizedBox(height: 4),
        // Sıfıra yakın değerler de görünsün: 1 piksellik bir çubuk "veri yok"
        // gibi okunur.
        FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: oran.toDouble().clamp(0.012, 1.0),
          child: _Dolgu(rol: rol, tema: tema, yukseklik: 14),
        ),
      ],
    );
  }
}

// ─── 2. Sıralama ────────────────────────────────────────────────────────────

class _Siralama extends StatelessWidget {
  const _Siralama({required this.c, required this.tema, required this.isEn});

  final SiralamaChart c;
  final DossierTheme tema;
  final bool isEn;

  @override
  Widget build(BuildContext context) {
    final enBuyuk = c.enBuyuk;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (c.birim != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Text(
              c.birim!.of(isEn),
              style: AppTypography.meta(context, color: tema.sessiz)
                  .copyWith(fontSize: 11.5, letterSpacing: 0.4),
            ),
          ),
        for (final satir in c.satirlar)
          Padding(
            padding: const EdgeInsets.only(bottom: 11),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        satir.etiket.of(isEn),
                        style: AppTypography.meta(
                          context,
                          // Vurgulanan satır mürekkep, bağlam satırları sessiz:
                          // sıralamada öne çıkan öğe metinde de öne çıkıyor.
                          color: satir.rol == ChartRole.sessiz
                              ? tema.sessiz
                              : tema.murekkep,
                        ).copyWith(
                          fontWeight: satir.rol == ChartRole.sessiz
                              ? FontWeight.w500
                              : FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      c.bicim.bicimle(satir.deger, isEn),
                      style: _rakamStili(
                        context,
                        satir.rol == ChartRole.sessiz ? tema.sessiz : tema.murekkep,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: (satir.deger / enBuyuk).toDouble().clamp(0.012, 1.0),
                  child: _Dolgu(rol: satir.rol, tema: tema, yukseklik: 12),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ─── 3. Çizgi ───────────────────────────────────────────────────────────────

/// Tek gerçek [CustomPainter]: yol çizmek gerekiyor.
class _Cizgi extends StatelessWidget {
  const _Cizgi({required this.c, required this.tema, required this.isEn});

  final CizgiChart c;
  final DossierTheme tema;
  final bool isEn;

  @override
  Widget build(BuildContext context) {
    final (yAlt, yUst) = c.yAralik;
    final (xAlt, xUst) = c.xAralik;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (c.seriler.length > 1 || c.birim != null) ...[
          _Gosterge(
            ogeler: [for (final s in c.seriler) (s.rol, s.ad.of(isEn))],
            tema: tema,
          ),
          const SizedBox(height: 6),
        ],
        if (c.birim != null)
          Text(
            c.birim!.of(isEn),
            style: AppTypography.meta(context, color: tema.sessiz)
                .copyWith(fontSize: 11.5, letterSpacing: 0.4),
          ),
        const SizedBox(height: 10),
        SizedBox(
          height: 220,
          child: CustomPaint(
            painter: _CizgiBoyaci(
              seriler: c.seriler,
              tema: tema,
              xAlt: xAlt,
              xUst: xUst,
              yAlt: yAlt,
              yUst: yUst,
              yEtiket: (v) => c.bicim.bicimle(v, isEn),
              eksenStili: AppTypography.meta(context, color: tema.sessiz)
                  .copyWith(fontSize: 11),
            ),
            child: const SizedBox.expand(),
          ),
        ),
      ],
    );
  }
}

class _CizgiBoyaci extends CustomPainter {
  _CizgiBoyaci({
    required this.seriler,
    required this.tema,
    required this.xAlt,
    required this.xUst,
    required this.yAlt,
    required this.yUst,
    required this.yEtiket,
    required this.eksenStili,
  });

  final List<CizgiSeri> seriler;
  final DossierTheme tema;
  final double xAlt, xUst, yAlt, yUst;
  final String Function(num) yEtiket;
  final TextStyle eksenStili;

  static const _solBosluk = 60.0;
  static const _altBosluk = 22.0;
  static const _ustBosluk = 8.0;

  @override
  void paint(Canvas canvas, Size size) {
    final alan = Rect.fromLTRB(
      _solBosluk,
      _ustBosluk,
      size.width,
      size.height - _altBosluk,
    );
    if (alan.width <= 0 || alan.height <= 0) return;

    // Eksen ve ızgara anlam taşıyor — ölçeği okuyan şey onlar. Bu yüzden
    // dekoratif `cizgi` (1,52:1) değil `cizgiVurgu` (3,48:1) kullanılıyor.
    // Ayrım tasarim.json'da açık bir uyarı olarak duruyor.
    final izgara = Paint()
      ..color = tema.cizgiVurgu
      ..strokeWidth = 0.6;

    for (var i = 0; i <= 2; i++) {
      final t = i / 2;
      final y = alan.bottom - alan.height * t;
      canvas.drawLine(Offset(alan.left, y), Offset(alan.right, y), izgara);
      _yaz(canvas, yEtiket(yAlt + (yUst - yAlt) * t),
          Offset(_solBosluk - 8, y), hizala: _Hiza.sagOrta);
    }

    _yaz(canvas, xAlt.round().toString(), Offset(alan.left, alan.bottom + 6),
        hizala: _Hiza.solUst);
    _yaz(canvas, xUst.round().toString(), Offset(alan.right, alan.bottom + 6),
        hizala: _Hiza.sagUst);

    for (final seri in seriler) {
      if (seri.noktalar.isEmpty) continue;

      Offset yerlestir(CizgiNokta n) => Offset(
            alan.left + alan.width * ((n.x - xAlt) / math.max(xUst - xAlt, 1e-9)),
            alan.bottom - alan.height * ((n.y - yAlt) / math.max(yUst - yAlt, 1e-9)),
          );

      final yol = Path();
      for (var i = 0; i < seri.noktalar.length; i++) {
        final p = yerlestir(seri.noktalar[i]);
        i == 0 ? yol.moveTo(p.dx, p.dy) : yol.lineTo(p.dx, p.dy);
      }

      final kalem = Paint()
        ..color = seri.rol.renk(tema)
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      final desen = seri.rol.cizgiDeseni;
      canvas.drawPath(desen == null ? yol : _kesikle(yol, desen), kalem);

      // Uç noktaların işareti: dolu/içi boş. Renk körlüğü şartının çizgideki
      // ikinci karşılığı — kesikli desen ince ekranlarda kaybolabiliyor.
      final ilk = yerlestir(seri.noktalar.first);
      final son = yerlestir(seri.noktalar.last);
      for (final p in [ilk, son]) {
        canvas.drawCircle(p, 3.6, Paint()..color = tema.yuzey);
        canvas.drawCircle(
          p,
          3.6,
          Paint()
            ..color = seri.rol.renk(tema)
            ..strokeWidth = 2
            ..style = seri.rol.iciDolu ? PaintingStyle.fill : PaintingStyle.stroke,
        );
      }
    }
  }

  /// Kesikli yol. Flutter'da hazır bir `dashPath` yok; ölçüm üzerinden
  /// parça parça çıkarılıyor.
  Path _kesikle(Path kaynak, List<double> desen) {
    final cikti = Path();
    for (final olcu in kaynak.computeMetrics()) {
      var mesafe = 0.0;
      var i = 0;
      while (mesafe < olcu.length) {
        final boy = desen[i % desen.length];
        if (i.isEven) {
          cikti.addPath(
            olcu.extractPath(mesafe, math.min(mesafe + boy, olcu.length)),
            Offset.zero,
          );
        }
        mesafe += boy;
        i++;
      }
    }
    return cikti;
  }

  void _yaz(Canvas canvas, String metin, Offset konum, {required _Hiza hizala}) {
    final tp = TextPainter(
      text: TextSpan(text: metin, style: eksenStili),
      textDirection: TextDirection.ltr,
    )..layout();
    final d = switch (hizala) {
      _Hiza.sagOrta => Offset(konum.dx - tp.width, konum.dy - tp.height / 2),
      _Hiza.solUst => konum,
      _Hiza.sagUst => Offset(konum.dx - tp.width, konum.dy),
    };
    tp.paint(canvas, d);
  }

  @override
  bool shouldRepaint(_CizgiBoyaci eski) =>
      eski.seriler != seriler || eski.tema != tema;
}

enum _Hiza { sagOrta, solUst, sagUst }

// ─── 4. Yığın ───────────────────────────────────────────────────────────────

class _Yigin extends StatelessWidget {
  const _Yigin({required this.c, required this.tema, required this.isEn});

  final YiginChart c;
  final DossierTheme tema;
  final bool isEn;

  @override
  Widget build(BuildContext context) {
    final ilk = c.cubuklar.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Gosterge(
          ogeler: [for (final d in ilk.dilimler) (d.rol, d.ad.of(isEn))],
          tema: tema,
        ),
        const SizedBox(height: 18),
        for (final cubuk in c.cubuklar) ...[
          Text(
            cubuk.etiket.of(isEn),
            style: AppTypography.meta(context, color: tema.murekkep)
                .copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          // Her çubuk KENDİ toplamına oranlanıyor. Grafiğin söylediği şey
          // "ciro 137,5 milyar, kazanç 49 milyar" değil; "yeniden ihracat
          // cironun %35,7'si ama kazancın yalnızca %11,6'sı". Ortak ölçek bu
          // karşılaştırmayı görünmez kılardı.
          Row(
            children: [
              for (final dilim in cubuk.dilimler)
                Expanded(
                  flex: math.max((dilim.deger / cubuk.toplam * 10000).round(), 1),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 2),
                    child: _Dolgu(rol: dilim.rol, tema: tema, yukseklik: 22),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 16,
            runSpacing: 4,
            children: [
              for (final dilim in cubuk.dilimler)
                Text(
                  '${dilim.ad.of(isEn)} · '
                  '${_yuzde(dilim.deger / cubuk.toplam, isEn)}',
                  style: _rakamStili(context, tema.sessiz).copyWith(fontSize: 11.5),
                ),
            ],
          ),
          const SizedBox(height: 18),
        ],
      ],
    );
  }

  /// Yüzde işareti Türkçede başa, İngilizcede sona.
  String _yuzde(num oran, bool isEn) {
    final s = (oran * 100).toStringAsFixed(1);
    return isEn ? '${s.replaceAll(',', '.')}%' : '%${s.replaceAll('.', ',')}';
  }
}

// ─── 5. Künye ───────────────────────────────────────────────────────────────

class _Kunye extends StatelessWidget {
  const _Kunye({required this.c, required this.tema, required this.isEn});

  final KunyeChart c;
  final DossierTheme tema;
  final bool isEn;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, kisit) {
        // Telefonda iki, tablette ve masaüstünde üç sütun. Sabit genişlik
        // yerine hesaplanıyor ki uzun etiketler taşmasın.
        final sutun = kisit.maxWidth < 380 ? 2 : 3;
        final genislik = (kisit.maxWidth - (sutun - 1) * 16) / sutun;

        return Wrap(
          spacing: 16,
          runSpacing: 20,
          children: [
            for (final kalem in c.kalemler)
              SizedBox(
                width: genislik,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      kalem.bicimli(isEn),
                      style: AppTypography.headlineCard(context, color: tema.vurgu)
                          .copyWith(
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      kalem.etiket.of(isEn),
                      style: AppTypography.meta(context, color: tema.murekkep)
                          .copyWith(fontSize: 12.5, height: 1.35),
                    ),
                    if (kalem.alt != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          kalem.alt!.of(isEn),
                          style: AppTypography.meta(context, color: tema.sessiz)
                              .copyWith(fontSize: 11.5),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

// ─── 6. Zaman çizelgesi ─────────────────────────────────────────────────────

class _ZamanCizelgesi extends StatelessWidget {
  const _ZamanCizelgesi({required this.c, required this.tema, required this.isEn});

  final ZamanCizelgesiChart c;
  final DossierTheme tema;
  final bool isEn;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < c.olaylar.length; i++)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 62,
                  child: Text(
                    c.olaylar[i].yilEtiketi(isEn),
                    style: _rakamStili(context, tema.vurgu),
                  ),
                ),
                // Dikey omurga: son olayda alt yarısı çizilmiyor, çizelge
                // boşluğa doğru uzamasın.
                _Omurga(
                  tema: tema,
                  ustVar: i > 0,
                  altVar: i < c.olaylar.length - 1,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: i == c.olaylar.length - 1 ? 0 : 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c.olaylar[i].baslik.of(isEn),
                          style: AppTypography.meta(context, color: tema.murekkep)
                              .copyWith(fontWeight: FontWeight.w700, height: 1.35),
                        ),
                        if (c.olaylar[i].aciklama != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: Text(
                              c.olaylar[i].aciklama!.of(isEn),
                              style: AppTypography.meta(context, color: tema.sessiz)
                                  .copyWith(fontSize: 12.5, height: 1.45),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Omurga extends StatelessWidget {
  const _Omurga({required this.tema, required this.ustVar, required this.altVar});

  final DossierTheme tema;
  final bool ustVar;
  final bool altVar;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 11,
      child: Column(
        children: [
          Expanded(
            flex: 0,
            child: SizedBox(
              height: 7,
              child: Center(
                child: Container(
                  width: 1,
                  color: ustVar ? tema.cizgiVurgu : Colors.transparent,
                ),
              ),
            ),
          ),
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: tema.vurgu, shape: BoxShape.circle),
          ),
          Expanded(
            child: Center(
              child: Container(
                width: 1,
                color: altVar ? tema.cizgiVurgu : Colors.transparent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── 7. Kartlar ─────────────────────────────────────────────────────────────

class _Kartlar extends StatelessWidget {
  const _Kartlar({required this.c, required this.tema, required this.isEn});

  final KartlarChart c;
  final DossierTheme tema;
  final bool isEn;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < c.kartlar.length; i++)
          Container(
            margin: EdgeInsets.only(bottom: i == c.kartlar.length - 1 ? 0 : 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              // Kart, grafiğin zemininin üstünde ikinci bir katman. Zemin
              // rengini kullanmak onu geri plana itiyor ve sınır çizgisiyle
              // birlikte kutu içinde kutu okunuyor.
              color: tema.zemin,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: tema.cizgi),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (c.kartlar[i].ust != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Text(
                      c.kartlar[i].ust!.of(isEn).toUpperCase(),
                      style: AppTypography.meta(context, color: tema.sessiz)
                          .copyWith(fontSize: 11, letterSpacing: 0.7),
                    ),
                  ),
                Text(
                  c.kartlar[i].baslik.of(isEn),
                  style: AppTypography.headlineCard(context, color: tema.murekkep)
                      .copyWith(fontSize: 16.5),
                ),
                const SizedBox(height: 8),
                Text(
                  c.kartlar[i].govde.of(isEn),
                  style: AppTypography.meta(context, color: tema.murekkep)
                      .copyWith(fontSize: 13, height: 1.55),
                ),
                if (c.kartlar[i].rakam != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.only(top: 11),
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: tema.cizgi)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          c.kartlar[i].rakam!.bicimli(isEn),
                          style: AppTypography.headlineCard(context, color: tema.vurgu)
                              .copyWith(
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Text(
                              c.kartlar[i].rakam!.etiket.of(isEn),
                              style: AppTypography.meta(context, color: tema.sessiz)
                                  .copyWith(fontSize: 12, height: 1.35),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}
