import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../data/yz_iskelet.g.dart';
import '../data/yz_teknoloji.g.dart';
import 'yz_kaynak_karnesi.dart';
import 'yz_mobil.dart';
import 'yz_parcalar.dart';
import 'yz_tasarim.dart';

/// Teknoloji × başlık ısı haritası (karar 57, 58): her hücre bir teknolojinin
/// bir başlıkta kaç paragrafta (ya da tablo satırında) geçtiği. Sayılar
/// `teknoloji_izi.py`'nin sayımı (iskelette, Dart eşleştiricisiyle eşlik
/// testli). Hücreye dokununca başlık o teknolojinin geçtiği yerler işaretli,
/// sütun başlığına dokununca teknolojinin alanlar arası sayfası açılıyor.
///
/// Merkez sayfada haritanın ikinci görünümü var (kaynak karnesi): başlık
/// bloğundaki seçici ([YzIsiHaritasiBasligi]) "Kaynak niteliği"ni seçince
/// burada [YzKaynakMatrisi] çiziliyor. Varsayılan teknoloji.
class YzTeknolojiMatrisi extends StatefulWidget {
  const YzTeknolojiMatrisi({super.key});

  @override
  State<YzTeknolojiMatrisi> createState() => _YzTeknolojiMatrisiState();
}

class _YzTeknolojiMatrisiState extends State<YzTeknolojiMatrisi> {
  (int, String)? _uzerinde;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<YzIsiGorunumu>(
        valueListenable: yzIsiGorunumu(context),
        builder: (context, gorunum, _) =>
            gorunum == YzIsiGorunumu.kaynak ? const YzKaynakMatrisi() : _teknolojiHaritasi(context),
      );

  Widget _teknolojiHaritasi(BuildContext context) {
    final en = yzIsEn(context);
    final kodlar = kYzTeknoloji.keys.toList();
    final basliklar = kYzBasliklar.where((b) => kYzTeknolojiIzi.containsKey(b.no)).toList();
    int sayi(int no, String kod) => kYzTeknolojiIzi[no]?[kod]?[en ? 1 : 0] ?? 0;
    final enBuyuk = [
      for (final b in basliklar)
        for (final k in kodlar) sayi(b.no, k),
    ].fold<int>(1, (a, b) => a > b ? a : b);
    const hucre = 34.0;
    final yonlendirici = GoRouter.maybeOf(context);

    Widget sutunBasi(String kod) {
      final ad = kYzTeknoloji[kod]![en ? 'en' : 'tr']!;
      final sayfaVar = kYzTeknolojiMetinleri.containsKey(kod);
      return SizedBox(
        width: hucre + 4,
        height: 112,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: RotatedBox(
            quarterTurns: 3,
            child: InkWell(
              onTap: sayfaVar && yonlendirici != null ? () => context.push(yzTeknolojiPath(kod)) : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(ad,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: YzYazi.veri(
                        boy: 11.5,
                        renk: _uzerinde?.$2 == kod ? YzRenk.makine : YzRenk.soluk,
                        kalinlik: FontWeight.w600)),
              ),
            ),
          ),
        ),
      );
    }

    Widget hucreW(YzBaslik b, String kod, {double genislik = hucre}) {
      final n = sayi(b.no, kod);
      final etiketli = b.teknoloji.contains(kod);
      final oran = n / enBuyuk;
      final renk = n == 0
          ? YzRenk.yuzey
          : Color.lerp(YzRenk.makineAcik, YzRenk.makine, etiketli ? 0.25 + 0.75 * oran : 0.08)!;
      final ad = kYzTeknoloji[kod]![en ? 'en' : 'tr']!;
      final ipucu = n == 0
          ? '$ad · ${b.ad(en)}: ${en ? 'does not come up' : 'geçmiyor'}'
          : '$ad · ${b.ad(en)}: ${en ? '$n mentions' : '$n yerde geçiyor'}';
      return Tooltip(
        message: ipucu,
        waitDuration: const Duration(milliseconds: 250),
        child: MouseRegion(
          onEnter: (_) => setState(() => _uzerinde = (b.no, kod)),
          onExit: (_) => setState(() => _uzerinde = null),
          cursor: n > 0 ? SystemMouseCursors.click : SystemMouseCursors.basic,
          child: GestureDetector(
            onTap: n == 0 || yonlendirici == null
                ? null
                : () => context.push(Uri(
                      path: yzBaslikPath(b.slug),
                      queryParameters: {'teknoloji': kod},
                    ).toString()),
            child: Container(
              width: genislik,
              height: hucre - 6,
              margin: const EdgeInsets.all(2),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: renk,
                borderRadius: BorderRadius.circular(3),
                border: Border.all(
                  color: _uzerinde == (b.no, kod) ? YzRenk.murekkep : YzRenk.cizgi,
                  width: _uzerinde == (b.no, kod) ? 1.5 : 0.6,
                ),
              ),
              child: n == 0
                  ? null
                  : Text('$n',
                      style: YzYazi.veri(
                          boy: 11,
                          renk: etiketli && oran > 0.45 ? Colors.white : YzRenk.makine,
                          kalinlik: FontWeight.w600)),
            ),
          ),
        ),
      );
    }

    Widget dikey() => SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const SizedBox(width: 210),
            for (final k in kodlar) sutunBasi(k),
          ]),
          for (final b in basliklar)
            Row(children: [
              SizedBox(
                width: 210,
                child: InkWell(
                  onTap: yonlendirici == null ? null : () => context.push(yzBaslikPath(b.slug)),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Text(b.ad(en),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: YzYazi.govde(
                            boy: 13.5,
                            renk: _uzerinde?.$1 == b.no ? YzRenk.makine : YzRenk.murekkep)),
                  ),
                ),
              ),
              for (final k in kodlar) hucreW(b, k),
            ]),
        ],
      ),
    );

    // Masaüstünde yan yatık (kullanıcı, 19 Kas 2026: "ısı haritası dikeye
    // uzamasın yataya uzasın"): teknolojiler satırda, başlıklar sütunda.
    // Hücre genişliği sütun sayısına göre ekrana sığdırılıyor; dar
    // pencerede ve telefonda eski düzen (başlık satırda, yatay kaydırma).
    Widget yatay(double genislik) {
      const solEn = 214.0;
      final hucreEn = ((genislik - solEn) / basliklar.length - 4).clamp(22.0, hucre);

      Widget sutunBasi(YzBaslik b) => SizedBox(
            width: hucreEn + 4,
            height: 168,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: RotatedBox(
                quarterTurns: 3,
                child: InkWell(
                  onTap: yonlendirici == null ? null : () => context.push(yzBaslikPath(b.slug)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(b.ad(en),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: YzYazi.govde(
                            boy: 12.5,
                            renk: _uzerinde?.$1 == b.no ? YzRenk.makine : YzRenk.murekkep)),
                  ),
                ),
              ),
            ),
          );

      Widget satirBasi(String kod) {
        final ad = kYzTeknoloji[kod]![en ? 'en' : 'tr']!;
        final sayfaVar = kYzTeknolojiMetinleri.containsKey(kod);
        return SizedBox(
          width: solEn,
          child: InkWell(
            onTap: sayfaVar && yonlendirici != null ? () => context.push(yzTeknolojiPath(kod)) : null,
            child: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Text(ad,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: YzYazi.govde(
                      boy: 13.5,
                      renk: _uzerinde?.$2 == kod ? YzRenk.makine : YzRenk.murekkep)),
            ),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const SizedBox(width: solEn),
            for (final b in basliklar) sutunBasi(b),
          ]),
          for (final k in kodlar)
            Row(children: [
              satirBasi(k),
              for (final b in basliklar) hucreW(b, k, genislik: hucreEn),
            ]),
        ],
      );
    }

    return LayoutBuilder(builder: (context, kis) {
      final yataySigar = kis.maxWidth >= 214 + basliklar.length * 26.0;
      if (yataySigar) return yatay(kis.maxWidth);
      return dikey();
    });
  }
}

// ══ Kaynak niteliği görünümü (kaynak karnesi) ═════════════════════════════

/// Merkez sayfadaki ısı haritasının iki görünümü.
enum YzIsiGorunumu { teknoloji, kaynak }

const String _gorunumKimligi = 'yz-isi-haritasi-gorunumu';
final ValueNotifier<YzIsiGorunumu> _yedekGorunum = ValueNotifier(YzIsiGorunumu.teknoloji);

/// Seçili görünüm. Seçici başlık bloğunda ([YzIsiHaritasiBasligi]), harita
/// hemen altında ([YzTeknolojiMatrisi]): merkez sayfada kardeşler, ortak
/// ataları yok. Bildirim sayfanın PageStorage kovasında duruyor; ikisi aynı
/// nesneyi okuyor. Her yeni sayfada (yeni rota, yeni kova) görünüm teknoloji.
ValueNotifier<YzIsiGorunumu> yzIsiGorunumu(BuildContext context) {
  final kova = PageStorage.maybeOf(context);
  if (kova == null) return _yedekGorunum;
  final kayitli = kova.readState(context, identifier: _gorunumKimligi);
  if (kayitli is ValueNotifier<YzIsiGorunumu>) return kayitli;
  final yeni = ValueNotifier(YzIsiGorunumu.teknoloji);
  kova.writeState(context, yeni, identifier: _gorunumKimligi);
  return yeni;
}

/// Isı haritası bölümünün başlığı (merkez sayfa). Başlık ve yeşil vurgu
/// satırı merkez sayfadan, sahibin sözleriyle, aynen ([YzBolumBasligi]);
/// altında iki seçenekli seçici — "Teknoloji" | "Kaynak niteliği" — ve
/// seçili görünümün açıklaması. Teknoloji görünümünün açıklaması da merkez
/// sayfadan ([alt]).
class YzIsiHaritasiBasligi extends StatelessWidget {
  const YzIsiHaritasiBasligi(this.metin, {super.key, required this.vurgu, required this.alt});
  final String metin;
  final String vurgu;

  /// Teknoloji görünümünün açıklaması.
  final String alt;

  @override
  Widget build(BuildContext context) {
    final en = yzIsEn(context);
    final gorunum = yzIsiGorunumu(context);
    return ValueListenableBuilder<YzIsiGorunumu>(
      valueListenable: gorunum,
      builder: (context, secili, _) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            YzBolumBasligi(metin, vurgu: vurgu),
            _GorunumSecici(secili: secili, en: en, sec: (g) => gorunum.value = g),
            const SizedBox(height: 10),
            Text(
              secili == YzIsiGorunumu.teknoloji
                  ? alt
                  : (en
                      ? 'Each cell is the number of sources the blue figures in a heading rest on, by type of source: peer-reviewed study, institutional report, official source, vendor claim. Tap a cell to open the heading.'
                      : 'Her hücre, bir başlıktaki mavi rakamların dayandığı kaynak sayısı, kaynağın türüne göre: hakemli çalışma, kurumsal rapor, resmî kaynak, satıcı beyanı. Hücreye dokununca başlık açılır.'),
              key: ValueKey('yz-isi-aciklama-${secili.name}'),
              style: YzYazi.govde(boy: 15.5, renk: YzRenk.soluk),
            ),
          ],
        ),
      ),
    );
  }
}

/// İki seçenekli seçici: seçili olan çelik mavisi dolgulu, öteki beyaz.
/// Telefonda dokunma yüksekliği 44 px.
class _GorunumSecici extends StatelessWidget {
  const _GorunumSecici({required this.secili, required this.en, required this.sec});
  final YzIsiGorunumu secili;
  final bool en;
  final ValueChanged<YzIsiGorunumu> sec;

  @override
  Widget build(BuildContext context) {
    final yukseklik = yzTelefon(context) ? 44.0 : 36.0;
    final secenekler = [
      (YzIsiGorunumu.teknoloji, en ? 'Technology' : 'Teknoloji'),
      (YzIsiGorunumu.kaynak, en ? 'Source type' : 'Kaynak niteliği'),
    ];
    return Container(
      key: const ValueKey('yz-isi-secici'),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: YzRenk.yuzey,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: YzRenk.cizgi),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (g, ad) in secenekler)
            Flexible(
              child: Semantics(
                button: true,
                selected: g == secili,
                inMutuallyExclusiveGroup: true,
                child: Material(
                  color: g == secili ? YzRenk.makine : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  child: InkWell(
                    key: ValueKey('yz-isi-secenek-${g.name}'),
                    borderRadius: BorderRadius.circular(6),
                    onTap: () => sec(g),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: yukseklik),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        child: Center(
                          widthFactor: 1,
                          child: Text(
                            ad,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                              color: g == secili ? Colors.white : YzRenk.makine,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

String _karneSayfasi(int no) => 'b${no.toString().padLeft(2, '0')}';

/// Kontrast oranı (WCAG 2.x).
double yzKontrast(Color a, Color b) {
  final la = a.computeLuminance(), lb = b.computeLuminance();
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

/// Kaynak niteliği hücresi: (zemin, yazı). Zemin türün renginde, yoğunluk
/// sayıyla ([enBuyuk] bütün hücrelerin en büyüğü); sıfırsa beyaz. Yazı beyaz
/// ya da mürekkep, en az 4,5:1 (WCAG AA): ikisinin de tutmadığı orta tonda
/// zemin önce koyulaşıyor (sıra bozulmasın), beyaz hiç tutmuyorsa açılıyor.
(Color, Color) yzKaynakHucreRengi(int tur, int n, int enBuyuk) {
  if (n <= 0) return (YzRenk.yuzey, YzRenk.soluk);
  final renk = kYzKarneRenkleri[tur];
  final acik = Color.lerp(YzRenk.yuzey, renk, 0.12)!;
  Color zemin(double t) => Color.lerp(acik, renk, t.clamp(0.0, 1.0))!;
  final t0 = 0.25 + 0.75 * (n / math.max(1, enBuyuk)).clamp(0.0, 1.0);
  bool beyaz(double t) => yzKontrast(Colors.white, zemin(t)) >= 4.5;
  bool koyu(double t) => yzKontrast(YzRenk.murekkep, zemin(t)) >= 4.5;
  if (beyaz(t0)) return (zemin(t0), Colors.white);
  if (koyu(t0)) return (zemin(t0), YzRenk.murekkep);
  for (var t = t0; t <= 1.0; t += 0.02) {
    if (beyaz(t)) return (zemin(t), Colors.white);
  }
  for (var t = t0; t >= 0; t -= 0.02) {
    if (koyu(t)) return (zemin(t), YzRenk.murekkep);
  }
  return (zemin(0), YzRenk.murekkep);
}

/// Kaynak niteliği görünümü (kaynak karnesi): her hücre, bir başlıktaki mavi
/// rakamların dayandığı o türden kaynak sayısı. Renk türün rengi, yoğunluk
/// sayıyla. Masaüstünde türler satırda, başlıklar sütunda (teknoloji
/// görünümünün yatay düzeniyle aynı sütunlar ve döndürülmüş adlar); dar
/// pencerede ve telefonda başlıklar satırda, dört tür sütunda — yatay
/// kaydırma yok. Yalnız karnesi olan başlıklar. Hücreye ya da başlığın adına
/// dokununca başlık açılır.
class YzKaynakMatrisi extends StatefulWidget {
  const YzKaynakMatrisi({super.key});

  @override
  State<YzKaynakMatrisi> createState() => _YzKaynakMatrisiState();
}

class _YzKaynakMatrisiState extends State<YzKaynakMatrisi> {
  /// Fare altındaki hücre: (başlık no, tür).
  (int, int)? _uzerinde;

  static const double _hucre = 34;

  @override
  Widget build(BuildContext context) {
    final en = yzIsEn(context);
    final basliklar = [
      for (final b in kYzBasliklar)
        if (yzKarne(_karneSayfasi(b.no)) != null) b,
    ];
    int sayi(YzBaslik b, int tur) => yzKarne(_karneSayfasi(b.no))!.turler[tur];
    final enBuyuk = [
      for (final b in basliklar)
        for (var t = 0; t < kYzKarneTurSayisi; t++) sayi(b, t),
    ].fold<int>(1, math.max);
    final yonlendirici = GoRouter.maybeOf(context);
    VoidCallback? ac(YzBaslik b) =>
        yonlendirici == null ? null : () => context.push(yzBaslikPath(b.slug));

    Widget hucre(YzBaslik b, int tur, double genislik) {
      final n = sayi(b, tur);
      final (zemin, yazi) = yzKaynakHucreRengi(tur, n, enBuyuk);
      final ipucu = '§${b.no} ${b.ad(en)} · ${yzKarneTurAdi(tur, en, kucuk: true)}: $n';
      final uzerinde = _uzerinde == (b.no, tur);
      return Tooltip(
        message: ipucu,
        waitDuration: const Duration(milliseconds: 250),
        child: Semantics(
          button: yonlendirici != null,
          label: ipucu,
          excludeSemantics: true,
          child: MouseRegion(
            onEnter: (_) => setState(() => _uzerinde = (b.no, tur)),
            onExit: (_) => setState(() => _uzerinde = null),
            cursor: yonlendirici == null ? SystemMouseCursors.basic : SystemMouseCursors.click,
            child: GestureDetector(
              onTap: ac(b),
              child: Container(
                key: ValueKey('yz-kaynak-hucre-${b.no}-$tur'),
                width: genislik,
                height: _hucre - 6,
                margin: const EdgeInsets.all(2),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: zemin,
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(
                    color: uzerinde ? YzRenk.murekkep : YzRenk.cizgi,
                    width: uzerinde ? 1.5 : 0.6,
                  ),
                ),
                child: n == 0
                    ? null
                    : Text('$n', style: YzYazi.veri(boy: 11, renk: yazi, kalinlik: FontWeight.w600)),
              ),
            ),
          ),
        ),
      );
    }

    Widget baslikAdi(YzBaslik b, {required double boy, TextAlign hiza = TextAlign.start}) => InkWell(
          onTap: ac(b),
          child: Text(b.ad(en),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: hiza,
              style: YzYazi.govde(
                  boy: boy, renk: _uzerinde?.$1 == b.no ? YzRenk.makine : YzRenk.murekkep)),
        );

    // Masaüstü: teknoloji görünümünün yatay düzeni — türler satırda.
    Widget yatay(double genislik) {
      const solEn = 214.0;
      final hucreEn = ((genislik - solEn) / basliklar.length - 4).clamp(22.0, _hucre);
      return Column(
        key: const ValueKey('yz-kaynak-matrisi-yatay'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const SizedBox(width: solEn),
            for (final b in basliklar)
              SizedBox(
                width: hucreEn + 4,
                height: 168,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: RotatedBox(
                    quarterTurns: 3,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: baslikAdi(b, boy: 12.5),
                    ),
                  ),
                ),
              ),
          ]),
          for (var t = 0; t < kYzKarneTurSayisi; t++)
            Row(children: [
              SizedBox(
                width: solEn,
                child: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Text(yzKarneTurAdi(t, en),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: YzYazi.govde(
                          boy: 13.5, renk: _uzerinde?.$2 == t ? YzRenk.makine : YzRenk.murekkep)),
                ),
              ),
              for (final b in basliklar) hucre(b, t, hucreEn),
            ]),
        ],
      );
    }

    // Dar pencere ve telefon: başlıklar satırda, dört tür sütunda; etiket
    // sütunu kalan genişlik — yatay kaydırma yok.
    Widget dikey(double genislik) {
      const sutun = _hucre + 4;
      final etiketEn = (genislik - kYzKarneTurSayisi * sutun).clamp(80.0, 300.0);
      // Döndürülmüş tür adlarının satırı en uzun ad kadar (TR kısa, EN uzun).
      TextStyle turStili(int t) => YzYazi.veri(
          boy: 11.5, renk: _uzerinde?.$2 == t ? YzRenk.makine : YzRenk.soluk, kalinlik: FontWeight.w600);
      var enUzun = 0.0;
      for (var t = 0; t < kYzKarneTurSayisi; t++) {
        final olcu = TextPainter(
          text: TextSpan(text: yzKarneTurAdi(t, en), style: turStili(t)),
          textDirection: TextDirection.ltr,
          textScaler: MediaQuery.textScalerOf(context),
          maxLines: 1,
        )..layout();
        enUzun = math.max(enUzun, olcu.width);
        olcu.dispose();
      }
      final ustBoy = (enUzun + 12).clamp(60.0, 200.0);
      return Column(
        key: const ValueKey('yz-kaynak-matrisi-dikey'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            SizedBox(width: etiketEn),
            for (var t = 0; t < kYzKarneTurSayisi; t++)
              SizedBox(
                width: sutun,
                height: ustBoy,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: RotatedBox(
                    quarterTurns: 3,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(yzKarneTurAdi(t, en),
                          maxLines: 1, overflow: TextOverflow.ellipsis, style: turStili(t)),
                    ),
                  ),
                ),
              ),
          ]),
          for (final b in basliklar)
            Row(children: [
              SizedBox(
                width: etiketEn,
                child: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: baslikAdi(b, boy: 13.5, hiza: TextAlign.right),
                ),
              ),
              for (var t = 0; t < kYzKarneTurSayisi; t++) hucre(b, t, _hucre),
            ]),
        ],
      );
    }

    return LayoutBuilder(
      key: const ValueKey('yz-kaynak-matrisi'),
      builder: (context, kis) {
        final yataySigar = kis.maxWidth >= 214 + basliklar.length * 26.0;
        return yataySigar ? yatay(kis.maxWidth) : dikey(kis.maxWidth);
      },
    );
  }
}
