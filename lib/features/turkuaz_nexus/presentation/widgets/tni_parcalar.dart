import 'package:flutter/material.dart';

import '../../data/tni_veri.g.dart';
import '../tni_tasarim.dart';

/// Sayfanın her bölümünde tekrar eden parçalar. Burada durmalarının sebebi
/// süs değil tutarlılık: bir bölümde 13 punto, ötekinde 14 punto etiket
/// kullanmak sayfayı derlenmiş gösterir.

/// Küçük, eşit genişlikli, aralıklı etiket. Sayfanın "ölçü aleti" sesi.
class TniEtiket extends StatelessWidget {
  final String metin;
  final Color renk;
  final bool cerceveli;
  final IconData? simge;

  const TniEtiket(
    this.metin, {
    super.key,
    required this.renk,
    this.cerceveli = true,
    this.simge,
  });

  @override
  Widget build(BuildContext context) {
    final govde = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (simge != null) ...[
          Icon(simge, size: 11, color: renk),
          const SizedBox(width: 5),
        ],
        Flexible(
          child: Text(
            metin,
            style: TniYazi.olcu(
              punto: 10.5,
              renk: renk,
              kalinlik: FontWeight.w700,
              aralik: 1.1,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
    if (!cerceveli) return govde;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: renk.withValues(alpha: 0.5), width: 1),
        borderRadius: BorderRadius.circular(3),
      ),
      child: govde,
    );
  }
}

/// Bölüm başlığı. Üstte numara ve kısa etiket, altta başlık ve giriş cümlesi.
///
/// Numaralar BURADA bir şey söylüyor: sayfa bir sıra, bir anlatı. Dosyaların
/// bölüm başlıklarında numara yok çünkü orada sıra okumayı belirlemiyor.
class TniBolumBasligi extends StatelessWidget {
  final String no;
  final String etiket;
  final String baslik;
  final String? giris;
  final Color vurgu;
  final bool karanlik;

  const TniBolumBasligi({
    super.key,
    required this.no,
    required this.etiket,
    required this.baslik,
    required this.vurgu,
    required this.karanlik,
    this.giris,
  });

  @override
  Widget build(BuildContext context) {
    final genislik = MediaQuery.sizeOf(context).width;
    final buyuk = genislik >= 700;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              no,
              style: TniYazi.olcu(
                punto: 12,
                renk: vurgu,
                kalinlik: FontWeight.w700,
                aralik: 1.4,
              ),
            ),
            const SizedBox(width: 10),
            Container(width: 26, height: 1, color: vurgu.withValues(alpha: 0.55)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                etiket,
                style: TniYazi.olcu(
                  punto: 10.5,
                  renk: TniRenk.ikincil(karanlik),
                  kalinlik: FontWeight.w600,
                  aralik: 1.5,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          baslik,
          style: TniYazi.gosterge(
            punto: buyuk ? 34 : 26,
            renk: TniRenk.metin(karanlik),
            kalinlik: FontWeight.w700,
            satir: 1.12,
            aralik: -0.6,
          ),
        ),
        if (giris != null && giris!.trim().isNotEmpty) ...[
          const SizedBox(height: 14),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: tniOkumaTavani),
            child: Text(
              giris!,
              style: TniYazi.govde(
                punto: buyuk ? 16.5 : 15.5,
                renk: TniRenk.ikincil(karanlik),
                satir: 1.62,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Yüzey kartı. Tek bir yerde tanımlı ki köşe yarıçapı ve kenarlık sayfanın
/// her yerinde aynı olsun.
class TniKart extends StatelessWidget {
  final Widget child;
  final bool karanlik;
  final Color? kenarRengi;
  final EdgeInsetsGeometry dolgu;
  final bool kesikKenar;

  const TniKart({
    super.key,
    required this.child,
    required this.karanlik,
    this.kenarRengi,
    this.dolgu = const EdgeInsets.all(18),
    this.kesikKenar = false,
  });

  @override
  Widget build(BuildContext context) {
    final kenar = kenarRengi ?? TniRenk.cizgi(karanlik);

    // KESİK KENAR GERÇEKTEN ÇİZİLİYOR.
    //
    // Bu alan ilk yazımda tanımlıydı ama `build` onu hiç OKUMUYORDU: kesik
    // kenar isteyen çağrı sessizce düz kenar alıyordu. Tasarım künyesinin
    // kendi kuralı ("durumun üç ayrı işareti var: renk, simge ve dolgu")
    // bu yüzden yarım kalıyordu — renk körlüğünde ve gri baskıda üçüncü
    // kanal yoktu. Okunmayan bir alana değer yazmak, sonraki turda
    // "açık kalem kesik çerçeveli" diye yanlış bir cümle yazdırırdı.
    if (kesikKenar) {
      return CustomPaint(
        painter: _KesikKenarBoyaci(renk: kenar, yaricap: 6),
        child: Container(
          padding: dolgu,
          decoration: BoxDecoration(
            color: TniRenk.yuzey(karanlik),
            borderRadius: BorderRadius.circular(6),
          ),
          child: child,
        ),
      );
    }

    return Container(
      padding: dolgu,
      decoration: BoxDecoration(
        color: TniRenk.yuzey(karanlik),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: kenar, width: 1),
      ),
      child: child,
    );
  }
}

/// Kesik çerçeve. Ek paket yok; yol `computeMetrics` ile elle parçalanıyor.
///
/// Çizgi ve boşluk uzunlukları eşit DEĞİL (5/4): eşit olduğunda kenar
/// uzaktan düz çizgiye yakın görünüyor ve ayrımın kendisi kayboluyor.
class _KesikKenarBoyaci extends CustomPainter {
  final Color renk;
  final double yaricap;

  const _KesikKenarBoyaci({required this.renk, required this.yaricap});

  @override
  void paint(Canvas canvas, Size size) {
    final yol = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Offset.zero & size,
        Radius.circular(yaricap),
      ));
    final kalem = Paint()
      ..color = renk
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (final parca in yol.computeMetrics()) {
      var t = 0.0;
      while (t < parca.length) {
        final son = (t + 5).clamp(0.0, parca.length);
        canvas.drawPath(parca.extractPath(t, son), kalem);
        t = son + 4;
      }
    }
  }

  @override
  bool shouldRepaint(_KesikKenarBoyaci eski) =>
      eski.renk != renk || eski.yaricap != yaricap;
}

/// `sesler` kaydından bir alıntı. Kod verilir, kayıt gömülü katmandan gelir.
///
/// Alıntının altında KİM, HANGİ GÖREVLE, NEREDE ve NE ZAMAN söylediği durur.
/// Kaynaksız alıntı bu sayfaya giremiyor; `_ozgun_dil` alanı çevirinin bizim
/// olduğunu da söylüyor.
class TniSoz extends StatelessWidget {
  final String kod;
  final bool karanlik;
  final bool isEn;
  final Color vurgu;

  const TniSoz({
    super.key,
    required this.kod,
    required this.karanlik,
    required this.isEn,
    required this.vurgu,
  });

  static Map<String, dynamic>? bul(String kod) {
    for (final k in (tniVeri['sesler'] as Map)['kayitlar'] as List) {
      final m = (k as Map).cast<String, dynamic>();
      if (m['kod'] == kod) return m;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final s = bul(kod);
    if (s == null) return const SizedBox.shrink();
    final buyuk = MediaQuery.sizeOf(context).width >= 700;
    final gorev = (isEn ? s['gorev_en'] : s['gorev_tr']) as String? ?? '';
    final yer = (isEn ? s['yer_en'] : s['yer_tr']) as String? ?? '';
    final tarih = s['tarih'] as String? ?? '';
    // Kişinin baş harfi. Fotoğrafımız yok ve bulmaya çalışmak da doğru
    // değil — konuşanların çoğu kamu görevlisi ve resmî fotoğraflarının
    // lisansı belirsiz. Harf, yüzün yerini tutmuyor; sözün bir KİŞİYE ait
    // olduğunu söylüyor, o kadar.
    final ad = (s['kisi'] as String? ?? '').trim();
    final harf = ad.isEmpty ? '·' : ad.characters.first;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: tniOkumaTavani),
      child: Container(
        decoration: BoxDecoration(
          color: TniRenk.yuzey(karanlik),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(2),
            bottomLeft: Radius.circular(2),
            topRight: Radius.circular(10),
            bottomRight: Radius.circular(10),
          ),
          border: Border(left: BorderSide(color: vurgu, width: 4)),
        ),
        padding: EdgeInsets.fromLTRB(
            buyuk ? 26 : 18, buyuk ? 24 : 20, buyuk ? 26 : 18, buyuk ? 20 : 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sözün kendisi, arkasında soluk bir tırnak. Tırnak METNİN
            // ARKASINDA duruyor, önünde değil: süs okunurluğun önüne
            // geçmemeli.
            Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: -6,
                  top: buyuk ? -34 : -26,
                  child: Text(
                    '“',
                    style: TniYazi.gosterge(
                      punto: buyuk ? 86 : 66,
                      renk: vurgu.withValues(alpha: 0.16),
                      kalinlik: FontWeight.w800,
                      satir: 1,
                    ),
                  ),
                ),
                Text(
                  (isEn ? s['soz_en'] : s['soz_tr']) as String,
                  style: TniYazi.gosterge(
                    punto: buyuk ? 23 : 19,
                    renk: TniRenk.metin(karanlik),
                    kalinlik: FontWeight.w500,
                    satir: 1.44,
                    aralik: -0.3,
                  ),
                ),
              ],
            ),
            SizedBox(height: buyuk ? 20 : 16),
            Container(
              height: 1,
              color: TniRenk.cizgi(karanlik),
              margin: const EdgeInsets.only(bottom: 14),
            ),
            // Künye: harf · ad · görev, altında yer ve tarih.
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: vurgu.withValues(alpha: 0.14),
                    border: Border.all(color: vurgu.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    harf,
                    style: TniYazi.gosterge(
                      punto: 15,
                      renk: vurgu,
                      kalinlik: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ad,
                        style: TniYazi.gosterge(
                          punto: 14.5,
                          renk: TniRenk.metin(karanlik),
                          kalinlik: FontWeight.w700,
                          satir: 1.25,
                        ),
                      ),
                      if (gorev.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          gorev,
                          style: TniYazi.govde(
                            punto: 12.5,
                            renk: TniRenk.ikincil(karanlik),
                            satir: 1.35,
                          ),
                        ),
                      ],
                      const SizedBox(height: 5),
                      Text(
                        [yer, tniTarihYaz(tarih, isEn)]
                            .where((x) => x.isNotEmpty)
                            .join('  ·  '),
                        style: TniYazi.olcu(
                          punto: 10.5,
                          renk:
                              TniRenk.ikincil(karanlik).withValues(alpha: 0.75),
                          aralik: 0.5,
                        ),
                      ),
                    ],
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

/// Bölümler arası ayırıcı. İnce çizgi değil, bir nefes.
class TniAra extends StatelessWidget {
  final double boy;
  const TniAra({super.key, this.boy = 56});

  @override
  Widget build(BuildContext context) => SizedBox(height: boy);
}
