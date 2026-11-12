import 'package:flutter/material.dart';

import '../../data/tni_model.dart';
import '../../data/tni_veri.g.dart';
import '../tni_tasarim.dart';
import 'tni_parcalar.dart';

/// TAAHHÜT TAKİPÇİSİ — sayfanın omurgası.
///
/// Kullanıcının kararı: omurga bir taahhüt takipçisi olacak, öteki bölümler
/// onun çevresinde duracak. Takipçinin bütün anlamı tek bir ayrımda:
///
///   GERÇEKLEŞTİ            oldu ve çıktısı bir kaynakta var
///   ÇIKTISI YAYIMLANMADI   tarihi geçti, etkinlik yapıldı, ama sonuç
///                          belgesi / taahhüt metni / katılımcı listesi yok
///   BEKLİYOR               tarihi gelmedi
///
/// Ortadaki hâl olmasaydı takipçi bir reklam panosu olurdu: 10 Kasım
/// lansmanı yapıldığı için yeşil görünür, oysa o günden geriye yayımlanmış
/// tek bir taahhüt metni kalmadı. Durum ÜÇ KANALDA işaretleniyor — renk,
/// simge ve dolgu — çünkü bu ayrımı renge bırakmak kabul edilemez.
///
/// Durumlar canlı örtüden (`tni_ortu`) geliyor; bir halkanın çıktısı
/// yayımlandığında dağıtım beklemeden yeşile dönüyor.
class TniTakipci extends StatefulWidget {
  final TniSayfaVerisi veri;
  final bool karanlik;
  final bool isEn;

  const TniTakipci({
    super.key,
    required this.veri,
    required this.karanlik,
    required this.isEn,
  });

  @override
  State<TniTakipci> createState() => _TniTakipciDurumu();
}

class _TniTakipciDurumu extends State<TniTakipci> {
  int? _secili;

  @override
  void initState() {
    super.initState();
    _secili = _canliKenar();
  }

  /// Açılışta seçili halka: GERÇEKLEŞMEYEN İLK halka. Yani okurun gözü
  /// doğrudan işin durduğu yere gidiyor, en eski habere değil.
  int? _canliKenar() {
    final h = widget.veri.halkalar;
    for (var i = 0; i < h.length; i++) {
      if (h[i].durum != HalkaDurumu.gerceklesti) return i;
    }
    return h.isEmpty ? null : h.length - 1;
  }

  @override
  Widget build(BuildContext context) {
    final k = widget.karanlik;
    final isEn = widget.isEn;
    final halkalar = widget.veri.halkalar;
    if (halkalar.isEmpty) return const SizedBox.shrink();
    final kron = (tniVeri['kronoloji'] as Map).cast<String, dynamic>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TniBolumBasligi(
          no: '01',
          etiket: isEn ? 'THE PATH' : 'GİDİŞAT',
          baslik: isEn
              ? 'Where it came from, where it is going'
              : 'Nereden geldi, nereye gidiyor',
          giris: isEn
              ? 'The initiative is young: the idea was first presented in Bonn '
                  'in June 2026 and launched at COP31 in November. Below are '
                  'the six stops on that road, including the ones still ahead.'
              : 'Girişim yeni: fikir ilk kez Haziran 2026\'da Bonn\'da '
                  'sunuldu, Kasım\'da COP31\'de duyuruldu. Aşağıda o yolun '
                  'altı durağı var; henüz gelinmemiş olanlar da dahil.',
          vurgu: TniRenk.iklim(k),
          karanlik: k,
        ),
        const TniAra(boy: 26),
        _OzetSeridi(
          veri: widget.veri,
          karanlik: k,
          isEn: isEn,
          secili: _secili,
          sec: (i) => setState(() => _secili = _secili == i ? null : i),
        ),
        const TniAra(boy: 28),
        for (var i = 0; i < halkalar.length; i++)
          _HalkaSatiri(
            halka: halkalar[i],
            sonMu: i == halkalar.length - 1,
            acik: _secili == i,
            karanlik: k,
            isEn: isEn,
            bas: () => setState(() => _secili = _secili == i ? null : i),
          ),
        const TniAra(boy: 18),
        // Sarı halkanın ne demek olduğu okura söyleniyor — yoksa renk tek
        // başına "burada bir sorun var" demekten öteye geçmiyor.
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: tniOkumaTavani),
          child: Text(
            ((isEn ? kron['_kural_en'] : kron['_kural']) ?? '') as String,
            style: TniYazi.govde(
              punto: 12.5,
              renk: TniRenk.ikincil(k).withValues(alpha: 0.9),
              satir: 1.55,
            ),
          ),
        ),
        const TniAra(boy: 26),
        // COP31 Başkanlığının kendi cümlesi, yolun sonunda: takvimi tutan
        // taraf burası ve girişimi nasıl tarif ettiği bu bölüme ait.
        TniSoz(
          kod: 'varank_soylem',
          karanlik: k,
          isEn: isEn,
          vurgu: TniRenk.iklim(k),
        ),
      ],
    );
  }
}

/// Altı halkanın tek bakışta hâli. Bir ölçü aletinin göstergesi gibi:
/// segmentler, sayılar, hepsi dokunulabilir.
class _OzetSeridi extends StatelessWidget {
  final TniSayfaVerisi veri;
  final bool karanlik;
  final bool isEn;
  final int? secili;
  final void Function(int) sec;

  const _OzetSeridi({
    required this.veri,
    required this.karanlik,
    required this.isEn,
    required this.secili,
    required this.sec,
  });

  @override
  Widget build(BuildContext context) {
    final k = karanlik;
    final sayilar = [
      (
        veri.gerceklesen,
        isEn ? 'happened' : 'oldu',
        TniRenk.iklim(k),
      ),
      (
        veri.askida,
        isEn ? 'no outcome' : 'sonuç yok',
        TniRenk.askida(k),
      ),
      (
        veri.bekleyen,
        isEn ? 'expected' : 'bekleniyor',
        TniRenk.ikincil(k),
      ),
      (
        veri.acikBilinmeyen,
        isEn ? 'to come' : 'netleşmedi',
        TniRenk.askida(k),
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Segment çubuğu: her halka bir dilim, genişlikler eşit.
        LayoutBuilder(builder: (context, kis) {
          final n = veri.halkalar.length;
          final araToplam = 4.0 * (n - 1);
          final dilim = ((kis.maxWidth - araToplam) / n).clamp(8.0, 400.0);
          return Row(
            children: [
              for (var i = 0; i < n; i++) ...[
                if (i > 0) const SizedBox(width: 4),
                _Dilim(
                  halka: veri.halkalar[i],
                  genislik: dilim,
                  secili: secili == i,
                  karanlik: k,
                  isEn: isEn,
                  bas: () => sec(i),
                ),
              ],
            ],
          );
        }),
        const SizedBox(height: 16),
        Wrap(
          spacing: 22,
          runSpacing: 12,
          children: [
            for (final (deger, etiket, renk) in sayilar)
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '$deger',
                    style: TniYazi.olcu(
                      punto: 22,
                      renk: renk,
                      kalinlik: FontWeight.w700,
                      aralik: 0,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    etiket,
                    style: TniYazi.govde(
                      punto: 12.5,
                      renk: TniRenk.ikincil(k),
                      kalinlik: FontWeight.w500,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}

class _Dilim extends StatelessWidget {
  final TniHalka halka;
  final double genislik;
  final bool secili;
  final bool karanlik;
  final bool isEn;
  final VoidCallback bas;

  const _Dilim({
    required this.halka,
    required this.genislik,
    required this.secili,
    required this.karanlik,
    required this.isEn,
    required this.bas,
  });

  @override
  Widget build(BuildContext context) {
    final g = TniDurumGorunumu.of(halka.durum, karanlik);
    return Semantics(
      button: true,
      label: '${halka.baslik(isEn)} — ${g.etiket(isEn)}',
      child: InkWell(
        onTap: bas,
        borderRadius: BorderRadius.circular(2),
        child: SizedBox(
          width: genislik,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: secili ? 10 : 6,
                decoration: BoxDecoration(
                  color: g.dolu ? g.renk : g.renk.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(2),
                  border: g.kesikli
                      ? Border.all(color: g.renk, width: 1.4)
                      : null,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                halka.tarihHam.split('-').first,
                style: TniYazi.olcu(
                  punto: 10,
                  renk: secili
                      ? TniRenk.metin(karanlik)
                      : TniRenk.ikincil(karanlik).withValues(alpha: 0.75),
                  kalinlik: secili ? FontWeight.w700 : FontWeight.w500,
                  aralik: 0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.clip,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HalkaSatiri extends StatelessWidget {
  final TniHalka halka;
  final bool sonMu;
  final bool acik;
  final bool karanlik;
  final bool isEn;
  final VoidCallback bas;

  const _HalkaSatiri({
    required this.halka,
    required this.sonMu,
    required this.acik,
    required this.karanlik,
    required this.isEn,
    required this.bas,
  });

  @override
  Widget build(BuildContext context) {
    final k = karanlik;
    final g = TniDurumGorunumu.of(halka.durum, k);
    final buyuk = MediaQuery.sizeOf(context).width >= 700;
    final gun = halka.gunKaldi(DateTime.now());
    // Gün sayacı YALNIZCA tarihi güne kadar kesin olan halkalarda. "2030"
    // için gün saymak, belgenin vermediği bir kesinliği uydurmak olurdu.
    final sayacVar = halka.kabalik == TarihKabasi.gun && gun != null && gun > 0;

    return InkWell(
      onTap: bas,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Ray ve düğüm ────────────────────────────────────────────────
          SizedBox(
            width: 34,
            child: Column(
              children: [
                const SizedBox(height: 4),
                _Dugum(gorunum: g, acik: acik),
                if (!sonMu)
                  Container(
                    width: 1.5,
                    height: acik ? 150 : 46,
                    margin: const EdgeInsets.only(top: 4),
                    color: TniRenk.cizgi(k),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // ── Gövde ───────────────────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: sonMu ? 0 : 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 10,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        tniTarihYaz(halka.tarihHam, isEn),
                        style: TniYazi.olcu(
                          punto: 12,
                          renk: TniRenk.metin(k),
                          kalinlik: FontWeight.w600,
                          aralik: 0.3,
                        ),
                      ),
                      TniEtiket(g.etiket(isEn), renk: g.renk, simge: g.simge),
                      if (sayacVar)
                        Text(
                          isEn ? 'in $gun days' : '$gun gün sonra',
                          style: TniYazi.olcu(
                            punto: 11,
                            renk: TniRenk.ikincil(k),
                            aralik: 0.2,
                          ),
                        ),
                      if (halka.ortudenGeldi)
                        TniEtiket(
                          isEn ? 'LIVE' : 'CANLI',
                          renk: TniRenk.su(k),
                          cerceveli: false,
                          simge: Icons.bolt_rounded,
                        ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  Text(
                    halka.baslik(isEn),
                    style: TniYazi.gosterge(
                      punto: buyuk ? 19 : 17,
                      renk: TniRenk.metin(k),
                      kalinlik: FontWeight.w600,
                      satir: 1.25,
                      aralik: -0.2,
                    ),
                  ),
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 220),
                    firstCurve: Curves.easeOut,
                    secondCurve: Curves.easeOut,
                    sizeCurve: Curves.easeInOut,
                    crossFadeState: acik
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    firstChild: const SizedBox(width: double.infinity, height: 0),
                    secondChild: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: ConstrainedBox(
                        constraints:
                            const BoxConstraints(maxWidth: tniOkumaTavani),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              halka.metin(isEn),
                              style: TniYazi.govde(
                                punto: 15,
                                renk: TniRenk.ikincil(k),
                                satir: 1.6,
                              ),
                            ),
                            if (halka.durumNotu != null) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: g.renk.withValues(alpha: 0.08),
                                  border: Border(
                                    left: BorderSide(color: g.renk, width: 2),
                                  ),
                                ),
                                child: Text(
                                  halka.durumNotu!,
                                  style: TniYazi.govde(
                                    punto: 13,
                                    renk: TniRenk.metin(k),
                                    satir: 1.55,
                                  ),
                                ),
                              ),
                            ],
                            if ((halka.kaynak ?? '').isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Text(
                                '${isEn ? "Source" : "Kaynak"}: ${halka.kaynak}',
                                style: TniYazi.olcu(
                                  punto: 11,
                                  renk: TniRenk.ikincil(k)
                                      .withValues(alpha: 0.85),
                                  aralik: 0.2,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 2, left: 8),
            child: Icon(
              acik ? Icons.remove_rounded : Icons.add_rounded,
              size: 17,
              color: TniRenk.ikincil(k).withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

/// Halkanın düğümü. Dolgu durumun ÜÇÜNCÜ işareti:
/// dolu = oldu · çizgili çember = çıktısı yok · boş = bekliyor
class _Dugum extends StatelessWidget {
  final TniDurumGorunumu gorunum;
  final bool acik;

  const _Dugum({required this.gorunum, required this.acik});

  @override
  Widget build(BuildContext context) {
    final boy = acik ? 26.0 : 22.0;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: boy,
      height: boy,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: gorunum.dolu
            ? gorunum.renk
            : gorunum.renk.withValues(alpha: 0.12),
        border: Border.all(
          color: gorunum.renk,
          width: gorunum.kesikli ? 2.2 : 1.4,
        ),
      ),
      child: Center(
        child: Icon(
          gorunum.simge,
          size: boy * 0.58,
          color: gorunum.dolu ? const Color(0xFF04171A) : gorunum.renk,
        ),
      ),
    );
  }
}
