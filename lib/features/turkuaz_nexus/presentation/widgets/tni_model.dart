import 'package:flutter/material.dart';

import '../../data/tni_veri.g.dart';
import '../tni_tasarim.dart';
import 'tni_gorsel.dart';
import 'tni_parcalar.dart';

/// TÜRKİYE'NİN MODELİ.
///
/// Dikkat: bu bölüm bir DEĞERLENDİRME değil, belgenin kendi tarifi. Giriş
/// cümlesi "Belgeye göre…" diye başlıyor ve bu kasıtlı — modelin kapsamlı
/// olduğu iddiası FAO belgesinin iddiası, bizim ölçümümüz değil. Dört unsur
/// da belgenin kendi listesi.
///
/// Hedef coğrafya üç bölge: MENA, Sahra altı Afrika, Orta Asya. Belge
/// yönetişim boşluğunun "yarı kurak ve su stresi altındaki" bu bölgelerde en
/// keskin olduğunu söylüyor. Orta Asya karesi burada duruyor: kaynak künyesi
/// Amu Derya'nın akışının, aşağı havzada açılan sulama kanalları yüzünden bir
/// yüzyıl içinde düştüğünü kaydediyor — yani suyun ve tarımın ayrı ayrı
/// karara bağlanmasının ne demek olduğunu.
class TniModel extends StatefulWidget {
  final bool karanlik;
  final bool isEn;

  const TniModel({super.key, required this.karanlik, required this.isEn});

  @override
  State<TniModel> createState() => _TniModelDurumu();
}

class _TniModelDurumu extends State<TniModel> {
  int _unsur = 0;

  @override
  Widget build(BuildContext context) {
    final k = widget.karanlik;
    final isEn = widget.isEn;
    final m = (tniVeri['turkiye_modeli'] as Map).cast<String, dynamic>();
    final unsurlar = (m['unsurlar'] as List)
        .map((e) => (e as Map).cast<String, dynamic>())
        .toList();
    final cografya = (m['hedef_cografya'] as List)
        .map((e) => (e as Map).cast<String, dynamic>())
        .toList();
    final genislik = MediaQuery.sizeOf(context).width;
    final buyuk = genislik >= 900;

    final sol = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < unsurlar.length; i++)
          _UnsurSatiri(
            no: i + 1,
            metin: (isEn ? unsurlar[i]['en'] : unsurlar[i]['tr']) as String,
            secili: _unsur == i,
            karanlik: k,
            bas: () => setState(() => _unsur = i),
          ),
        const SizedBox(height: 22),
        Text(
          isEn ? 'WHERE IT IS MEANT TO APPLY' : 'NEREDE UYGULANMASI ÖNGÖRÜLÜYOR',
          style: TniYazi.olcu(
            punto: 10.5,
            renk: TniRenk.ikincil(k),
            kalinlik: FontWeight.w700,
            aralik: 1.4,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final c in cografya)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                decoration: BoxDecoration(
                  color: TniRenk.su(k).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(
                    color: TniRenk.su(k).withValues(alpha: 0.45),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      c['kod'] as String,
                      style: TniYazi.olcu(
                        punto: 10,
                        renk: TniRenk.su(k),
                        kalinlik: FontWeight.w700,
                        aralik: 0.8,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      (isEn ? c['en'] : c['tr']) as String,
                      style: TniYazi.govde(
                        punto: 13,
                        renk: TniRenk.metin(k),
                        kalinlik: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );

    final sag = TniGorsel(kod: 'cografya', karanlik: k, isEn: isEn);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TniBolumBasligi(
          no: '04',
          etiket: isEn ? 'THE REFERENCE' : 'REFERANS',
          baslik: isEn ? "Türkiye's model" : "Türkiye'nin modeli",
          giris: (isEn ? m['giris_en'] : m['giris_tr']) as String,
          vurgu: TniRenk.tarim(k),
          karanlik: k,
        ),
        const TniAra(boy: 24),
        TniGorsel(kod: 'model', karanlik: k, isEn: isEn, enBoyUstu: 2.1),
        const TniAra(boy: 28),
        if (buyuk)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 6, child: sol),
              const SizedBox(width: 32),
              Expanded(flex: 5, child: sag),
            ],
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [sol, const TniAra(boy: 24), sag],
          ),
      ],
    );
  }
}

class _UnsurSatiri extends StatelessWidget {
  final int no;
  final String metin;
  final bool secili;
  final bool karanlik;
  final VoidCallback bas;

  const _UnsurSatiri({
    required this.no,
    required this.metin,
    required this.secili,
    required this.karanlik,
    required this.bas,
  });

  @override
  Widget build(BuildContext context) {
    final k = karanlik;
    final vurgu = TniRenk.tarim(k);
    return InkWell(
      onTap: bas,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: TniRenk.cizgi(k)),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 26,
              child: Text(
                no.toString().padLeft(2, '0'),
                style: TniYazi.olcu(
                  punto: 12,
                  renk: secili ? vurgu : TniRenk.ikincil(k).withValues(alpha: 0.7),
                  kalinlik: FontWeight.w700,
                  aralik: 0.4,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                metin,
                style: TniYazi.govde(
                  punto: 15.5,
                  renk: secili
                      ? TniRenk.metin(k)
                      : TniRenk.ikincil(k),
                  kalinlik: secili ? FontWeight.w600 : FontWeight.w400,
                  satir: 1.45,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ÜÇ SÜTUN — girişimin kendi uygulama planı.
///
/// Birinci sütunun TARİHİ YOK ve bu sayfada görünüyor. Belge ikinci sütun için
/// "Starting in 2027", üçüncüsü için "By 2030" diyor; birincisi için hiçbir
/// tarih vermiyor. Üçüne de bir tarih uydurmak takipçiyi işe yaramaz hâle
/// getirirdi.
class TniSutunlar extends StatelessWidget {
  final bool karanlik;
  final bool isEn;

  const TniSutunlar({super.key, required this.karanlik, required this.isEn});

  @override
  Widget build(BuildContext context) {
    final k = karanlik;
    final sutunlar = (tniVeri['sutunlar'] as List)
        .map((e) => (e as Map).cast<String, dynamic>())
        .toList();
    final genislik = MediaQuery.sizeOf(context).width;
    final sutun = genislik >= 1000 ? 3 : 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TniBolumBasligi(
          no: '05',
          etiket: isEn ? 'THE PLAN' : 'PLAN',
          baslik: isEn ? 'Three pillars' : 'Üç sütun',
          giris: isEn
              ? 'How the initiative says it will work. Two of the three '
                  'pillars have a date; the first does not — the founding '
                  'document gives it none.'
              : 'Girişim nasıl işleyeceğini böyle anlatıyor. Üç sütunun '
                  'ikisinin tarihi var, birincisinin yok — kurucu belge ona '
                  'bir tarih vermiyor.',
          vurgu: TniRenk.iklim(k),
          karanlik: k,
        ),
        const TniAra(boy: 24),
        LayoutBuilder(builder: (context, kis) {
          const ara = 14.0;
          final kartG = sutun == 1
              ? kis.maxWidth
              : (kis.maxWidth - ara * (sutun - 1)) / sutun;
          return Wrap(
            spacing: ara,
            runSpacing: ara,
            children: [
              for (final s in sutunlar)
                SizedBox(
                  width: kartG,
                  child: _SutunKarti(s: s, karanlik: k, isEn: isEn),
                ),
            ],
          );
        }),
        const TniAra(boy: 26),
        TniSoz(
          kod: 'bagci_mesaj',
          karanlik: k,
          isEn: isEn,
          vurgu: TniRenk.iklim(k),
        ),
      ],
    );
  }
}

class _SutunKarti extends StatelessWidget {
  final Map<String, dynamic> s;
  final bool karanlik;
  final bool isEn;

  const _SutunKarti({
    required this.s,
    required this.karanlik,
    required this.isEn,
  });

  @override
  Widget build(BuildContext context) {
    final k = karanlik;
    final tarih = s['tarih'];
    final tarihsiz = tarih == null;
    final vurgu = tarihsiz ? TniRenk.askida(k) : TniRenk.iklim(k);
    return TniKart(
      karanlik: k,
      kenarRengi: tarihsiz ? vurgu.withValues(alpha: 0.35) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '0${s['no']}',
                style: TniYazi.olcu(
                  punto: 13,
                  renk: vurgu,
                  kalinlik: FontWeight.w700,
                  aralik: 0.6,
                ),
              ),
              const Spacer(),
              if (tarihsiz)
                TniEtiket(
                  isEn ? 'NO DATE GIVEN' : 'TARİH VERİLMEMİŞ',
                  renk: vurgu,
                  simge: Icons.help_outline_rounded,
                )
              else
                Text(
                  isEn
                      ? (s['no'] == 2 ? 'from $tarih' : 'by $tarih')
                      : (s['no'] == 2 ? '$tarih\'den itibaren' : '$tarih\'a kadar'),
                  style: TniYazi.olcu(
                    punto: 11.5,
                    renk: vurgu,
                    kalinlik: FontWeight.w600,
                    aralik: 0.3,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            (isEn ? s['ad_en'] : s['ad_tr']) as String,
            style: TniYazi.gosterge(
              punto: 18,
              renk: TniRenk.metin(k),
              kalinlik: FontWeight.w600,
              satir: 1.25,
              aralik: -0.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            (isEn ? s['ne_en'] : s['ne_tr']) as String,
            style: TniYazi.govde(
              punto: 14.5,
              renk: TniRenk.ikincil(k),
              satir: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}
