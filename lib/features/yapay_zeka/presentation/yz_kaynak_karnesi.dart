import 'dart:math' as math;

import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show OverflowBoxFit;
import 'package:google_fonts/google_fonts.dart';

import '../../../core/utils/turkce_metin.dart' show buyukHarf;
import '../data/yz_kaynak_karnesi.g.dart';
import 'yz_mobil.dart';
import 'yz_tasarim.dart';

/// Kaynak karnesi (sahibin onayı, 25 Kasım 2026): bir sayfanın mavi
/// rakamlarının hangi tür kaynağa dayandığı. Yorum yok, hesap var: sayılar
/// `_raw/rakam_kaynaklari.py › karne`'den üretiliyor
/// (`yz_kaynak_karnesi.g.dart`); `dogrula_bolumler.py` kural 18 karneyi
/// kayıtlardan yeniden hesaplıyor.
///
///   · Masaüstü ve tablet: künyenin hemen altında tek satır — ince yığılmış
///     çubuk ve "Rakamlar 23 kaynağa dayanıyor: 12 hakemli çalışma · …".
///   · Telefon (< 640 px): kısa künyenin altında küçük çubuk, "23 kaynak" ve
///     bilgi simgesi; dokununca alttan açılan sayfada tam döküm ve dört
///     türün tanımı. Üst bölüm 5 px uzuyor (sınır ~24 px, karar 62).
///   · Karnesi olmayan sayfada (sözlük, kaynakça) hiçbir şey çizilmiyor.
///
/// Renk tek başına anlam taşımıyor: masaüstü satırında ve alt sayfada türün
/// adı yazılı. Sayılar bilerek türün renginde DEĞİL: bu bölümde mavi rakam
/// "dokununca kaynağı açılır" demek. Dosya yalnız erteli ekranlardan içe
/// aktarılıyor (yz_makale.dart, yz_matris.dart): ilk yüke girmez.

/// Resmî kaynağın rengi: koyu gri-mavi, grafik paletindeki gri-mavinin
/// (0xFF6C7A86, yz_grafik.dart) koyusu. Zemin üstünde 4,98:1, beyaz üstünde
/// 5,46:1 — metinde de WCAG AA.
const Color kYzKarneResmi = Color(0xFF5B6B7D);

/// Türlerin renkleri, sabit sırayla: hakemli çalışma, kurumsal rapor, resmî
/// kaynak, satıcı ya da proje beyanı (çubuk dilimi, ısı haritası hücresi,
/// renk örneği).
/// Hepsi zemin ve beyaz üstünde en az 3:1 (WCAG 1.4.11).
const List<Color> kYzKarneRenkleri = [YzRenk.bitki, YzRenk.makine, kYzKarneResmi, YzRenk.bekleyen];

/// Tür sayısı; sıra [kYzKarneRenkleri] ve [YzKarne.turler] ile aynı.
const int kYzKarneTurSayisi = 4;

/// Mavi rakamın ardında kaynağının türünü gösteren küçük renk noktası
/// (mizansen turu, 28 Kasım 2026). Rakamın kendisi mavi kalıyor ("dokununca
/// kaynağı açılır"); nokta karne satırındaki aynı renkle türü söylüyor.
const bool kYzRakamNoktasi = true;

/// Rakamın ardındaki nokta(lar): kaynakları iki türdense iki nokta. Satır
/// içi yer tutucu: seçime ve kopyalanan metne girmiyor.
InlineSpan yzTurNoktalari(List<int> turler, double boy) {
  final cap = (boy * 0.3).clamp(4.5, 6.5).toDouble();
  return WidgetSpan(
    alignment: PlaceholderAlignment.middle,
    child: ExcludeSemantics(
      child: Padding(
        // Rakamın sağ üstünde, üs gibi: satırın ortasından biraz yukarıda.
        padding: EdgeInsets.only(left: boy * 0.1, right: 1, bottom: boy * 0.42),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          for (final (i, t) in turler.take(2).indexed)
            Container(
              width: cap,
              height: cap,
              margin: EdgeInsets.only(left: i == 0 ? 0 : 1.5),
              decoration: BoxDecoration(color: kYzKarneRenkleri[t], shape: BoxShape.circle),
            ),
        ]),
      ),
    ),
  );
}

/// Karne satırındaki ve balondaki tür adının önündeki renk örneği.
Widget yzTurOrnegi(int tur, {double cap = 7}) => Container(
      width: cap,
      height: cap,
      decoration: BoxDecoration(color: kYzKarneRenkleri[tur], shape: BoxShape.circle),
    );

// Sayıyla birlikte: [TR, EN tekil, EN çoğul]. Türkçede sayıdan sonra ad tekil.
const List<List<String>> _sayiliAd = [
  ['hakemli çalışma', 'peer-reviewed', 'peer-reviewed'],
  ['kurumsal rapor', 'institutional report', 'institutional reports'],
  ['resmî kaynak', 'official source', 'official sources'],
  ['satıcı beyanı', 'vendor claim', 'vendor claims'],
  // Beşinci ad yalnız cümlede: proje beyanı satıcı beyanıyla aynı küme ve
  // renkte, adıyla ayrı yazılıyor (metin bu rakamlara "proje beyanı" diyor).
  ['proje beyanı', 'project claim', 'project claims'],
];

// Türün adı: [TR, EN].
const List<List<String>> _ad = [
  ['Hakemli çalışma', 'Peer-reviewed study'],
  ['Kurumsal rapor', 'Institutional report'],
  ['Resmî kaynak', 'Official source'],
  ['Satıcı ya da proje beyanı', 'Vendor or project claim'],
];

// Cümle içindeki adı (ısı haritasının ipucu): [TR, EN].
const List<List<String>> _kucukAd = [
  ['hakemli çalışma', 'peer-reviewed study'],
  ['kurumsal rapor', 'institutional report'],
  ['resmî kaynak', 'official source'],
  ['satıcı ya da proje beyanı', 'vendor or project claim'],
];

// Türün bir cümlelik tanımı — arayüz metni, olgu değil: [TR, EN].
const List<List<String>> _tanim = [
  [
    'Hakemli bir dergide ya da bildiri kitabında yayımlanmış çalışma.',
    'A study published in a peer-reviewed journal or conference proceedings.',
  ],
  [
    'Bir kurumun kendi yayını ya da sayfası: uluslararası kuruluş, kamu kurumu, üniversite, araştırma kuruluşu ya da sektör örgütü.',
    'An organisation’s own publication or page: an international body, public agency, university, research institute or sector organisation.',
  ],
  [
    'Devletin ya da hükümetler arası bir kuruluşun resmî belgesi ya da sayfası: mevzuat, plan, resmî istatistik, sicil kaydı.',
    'An official document or page of a state or an intergovernmental body: legislation, plans, official statistics, registers.',
  ],
  [
    'Ürünü satan şirketin ya da projeyi yürütenin kendi duyurusu, bülteni, broşürü ya da raporu: kendi beyanı.',
    'A company’s or a project’s own announcement, bulletin, brochure or report: its own claim.',
  ],
];

/// Sayfanın karnesi ("bNN" ya da "tek_<kod>"); karnesi yoksa ya da hiçbir
/// kaynağın türü bilinmiyorsa null — o sayfada hiçbir şey çizilmez.
YzKarne? yzKarne(String? sayfa) {
  final k = sayfa == null ? null : kYzKaynakKarnesi[sayfa];
  return k == null || k.toplam == 0 ? null : k;
}

/// Türün adı: "Resmî kaynak" / "Official source"; [kucuk] cümle içinde.
String yzKarneTurAdi(int tur, bool en, {bool kucuk = false}) =>
    (kucuk ? _kucukAd : _ad)[tur][en ? 1 : 0];

/// Türün bir cümlelik tanımı (alt sayfa).
String yzKarneTanimi(int tur, bool en) => _tanim[tur][en ? 1 : 0];

String _bas(int n, bool en) =>
    en ? 'Figures rest on $n ${n == 1 ? 'source' : 'sources'}' : 'Rakamlar $n kaynağa dayanıyor';

String _sayili(int tur, int n, bool en) =>
    '$n ${en ? _sayiliAd[tur][n == 1 ? 1 : 2] : _sayiliAd[tur][0]}';

/// Masaüstü satırı: "Rakamlar 23 kaynağa dayanıyor: 12 hakemli çalışma ·
/// 6 kurumsal rapor · 4 resmî kaynak · 1 satıcı beyanı". Sıfır olan tür
/// yazılmaz; sıra sabit.
String yzKarneCumlesi(YzKarne k, bool en) =>
    '${_bas(k.toplam, en)}: ${_ayrinti(k, en).join(' · ')}';

List<String> _ayrinti(YzKarne k, bool en) {
  // Üç tür sırayla; dördüncü kümede satıcı ve proje beyanı adlarıyla ayrı.
  final sayilar = [k.hakemli, k.kurumsal, k.resmi, k.satici, k.proje];
  return [
    for (var i = 0; i < sayilar.length; i++)
      if (sayilar[i] > 0) _sayili(i, sayilar[i], en),
  ];
}

const String _bitisik = ' ';

/// Ekrandaki biçim: her tür ("12 hakemli çalışma") bölünmez, nokta öncekine
/// yapışık — satır "·" ile başlamaz. [satirli]: ayrıntı iki noktadan sonra
/// ikinci satırda (cümle tek satıra sığmayınca).
String _gorunenCumle(YzKarne k, bool en, {required bool satirli}) {
  final ayrinti = [for (final p in _ayrinti(k, en)) p.replaceAll(' ', _bitisik)].join('$_bitisik· ');
  return '${_bas(k.toplam, en)}:${satirli ? '\n' : ' '}$ayrinti';
}

/// Masaüstü satırının renkli biçimi (mizansen turu, 28 Kasım 2026): her
/// türün adı rakamın ardındaki noktayla aynı renkte — noktanın lejantı.
/// Yazı [_gorunenCumle] ile birebir aynı; genişlik değişmiyor (satır 653
/// px sınırında). Beyan kümesinin hardalı metinde koyusuyla (4,5:1 üstü).
TextSpan _renkliCumle(YzKarne k, bool en, {required bool satirli}) {
  final sayilar = [k.hakemli, k.kurumsal, k.resmi, k.satici, k.proje];
  const dort = [0, 1, 2, 3, 3];
  final parcalar = [
    for (var i = 0; i < sayilar.length; i++)
      if (sayilar[i] > 0) (dort[i], sayilar[i], _sayili(i, sayilar[i], en)),
  ];
  Color renk(int tur) => tur == 3 ? YzRenk.bekleyenMetin : kYzKarneRenkleri[tur];
  return TextSpan(children: [
    TextSpan(text: '${_bas(k.toplam, en)}:${satirli ? '\n' : ' '}'),
    for (final (j, (tur, n, metin)) in parcalar.indexed) ...[
      if (j > 0) const TextSpan(text: '$_bitisik· '),
      // "12 hakemli çalışma": sayı soluk, türün adı renkli.
      TextSpan(text: '$n$_bitisik'),
      TextSpan(
        text: metin.substring('$n '.length).replaceAll(' ', _bitisik),
        style: TextStyle(color: renk(tur)),
      ),
    ],
  ]);
}

/// Telefondaki kısa biçim: "23 kaynak" / "23 sources".
String yzKarneKisa(YzKarne k, bool en) =>
    en ? '${k.toplam} ${k.toplam == 1 ? 'source' : 'sources'}' : '${k.toplam} kaynak';

/// İnce yatay yığılmış çubuk: dört tür sabit sırayla, sayıyla orantılı.
/// Dilimler arasında ince boşluk (yan yana iki mavi birbirine karışmasın),
/// uçlar yuvarlak; sıfır olmayan her dilim en az 3 px. Anlamı yanındaki
/// yazı taşıyor: ekran okuyucuya kapalı.
class YzKarneCubugu extends StatelessWidget {
  const YzKarneCubugu({super.key, required this.karne, this.genislik = 140, this.yukseklik = 6});
  final YzKarne karne;
  final double genislik;
  final double yukseklik;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
        child: SizedBox(
          width: genislik,
          height: yukseklik,
          child: CustomPaint(painter: _CubukBoyasi(karne.turler)),
        ),
      );
}

class _CubukBoyasi extends CustomPainter {
  _CubukBoyasi(this.turler);
  final List<int> turler;

  static const double _bosluk = 1.5;
  static const double _enAz = 3;

  @override
  void paint(Canvas canvas, Size size) {
    final dolu = [for (var i = 0; i < turler.length; i++) if (turler[i] > 0) i];
    if (dolu.isEmpty || size.isEmpty) return;
    final toplam = turler.fold<int>(0, (a, b) => a + b);
    final kalan = math.max(0.0, size.width - _bosluk * (dolu.length - 1) - _enAz * dolu.length);
    canvas.save();
    canvas.clipRRect(RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(size.height / 2)));
    var x = 0.0;
    for (final i in dolu) {
      final w = _enAz + kalan * turler[i] / toplam;
      canvas.drawRect(Rect.fromLTWH(x, 0, w, size.height), Paint()..color = kYzKarneRenkleri[i]);
      x += w + _bosluk;
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CubukBoyasi eski) => !listEquals(eski.turler, turler);
}

/// Masaüstü ve tablet: künyenin hemen altında tek satır, çubuk ve cümle.
///
/// Başlık bloğu metin sütunu genişliğinde (610 px). Üç türlü cümle çubukla
/// oraya sığmıyor (ölçü: 13 px Newsreader'da en uzunu 483 px + 150): satır
/// [sagPay] kadar sağa taşabiliyor — görsel ve tablonun da kullandığı,
/// sütunun sağındaki pay (760 px sütun). Dört türün de geçtiği cümle
/// (§3, §27, robotik) oraya da sığmıyor: o zaman ayrıntı iki noktadan sonra
/// ikinci satırda; hiçbir genişlikte taşmaz.
class YzKarneSatiri extends StatelessWidget {
  const YzKarneSatiri({super.key, required this.karne, required this.en, this.sagPay = 0});
  final YzKarne karne;
  final bool en;
  final double sagPay;

  static const double _boy = 13;
  static const double _satir = 1.4;
  static const double _cubuk = 6;
  static const double _cubukGenisligi = 140;
  static const double _ara = 10;

  @override
  Widget build(BuildContext context) {
    // Ölçü Text'in kullanacağı stille (varsayılan stil birleşmiş hâliyle).
    // Harf aralığı açıkça 0: temanın 0,25'i üç türlü en uzun cümleyi (§1)
    // çubukla birlikte 653 pikselin 1,3 px ötesine itiyordu.
    final stil = DefaultTextStyle.of(context).style.merge(
        YzYazi.govde(boy: _boy, renk: YzRenk.soluk).copyWith(height: _satir, letterSpacing: 0));
    final olcek = MediaQuery.textScalerOf(context);
    // Çubuk ilk satırın ortasında (cümle ikinci satıra inerse de).
    final satirYuksekligi = olcek.scale(_boy) * _satir;
    return Semantics(
      container: true,
      label: yzKarneCumlesi(karne, en),
      excludeSemantics: true,
      child: LayoutBuilder(
        key: const ValueKey('yz-karne-satiri'),
        builder: (context, kis) {
          final azami = kis.maxWidth + math.max(0.0, sagPay);
          final tek = _gorunenCumle(karne, en, satirli: false);
          final olcu = TextPainter(
            text: TextSpan(text: tek, style: stil),
            textDirection: Directionality.of(context),
            textScaler: olcek,
            maxLines: 1,
          )..layout();
          final sigar = _cubukGenisligi + _ara + olcu.width <= azami;
          olcu.dispose();
          return OverflowBox(
            alignment: Alignment.topLeft,
            minWidth: 0,
            maxWidth: azami,
            fit: OverflowBoxFit.deferToChild,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: math.max(0.0, (satirYuksekligi - _cubuk) / 2)),
                  child: YzKarneCubugu(karne: karne, genislik: _cubukGenisligi, yukseklik: _cubuk),
                ),
                const SizedBox(width: _ara),
                Flexible(
                  child: Text.rich(_renkliCumle(karne, en, satirli: !sigar), style: stil),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Telefondaki satırın yazısı: kısa künyeyle aynı (Outfit 13, soluk); satır
/// aralığı dar, satır künyenin hemen altına otursun.
TextStyle _sade() =>
    GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w500, color: YzRenk.soluk, height: 1.15);

/// Telefon: kısa künyenin altında tek satır — küçük çubuk, "23 kaynak" ve
/// bilgi simgesi. Satırın tamamı, altındaki payla birlikte (21 px, tam
/// genişlik) dokunma alanı; dokununca alttan açılan sayfada döküm.
class YzKarneMobilSatiri extends StatelessWidget {
  const YzKarneMobilSatiri({super.key, required this.karne, required this.en});
  final YzKarne karne;
  final bool en;

  /// Satırın yüksekliği ve altındaki pay. Başlık bloğunun telefondaki alt
  /// boşluğu (16 px) karne varken bu payla yer değiştiriyor: üst bölüm
  /// 15 + 6 − 16 = 5 px uzuyor (sınır ~24 px; "metin ilk ekranın üçte
  /// birinde" sınaması, karar 62, en dar başlıkta 7,7 px pay bırakıyor).
  static const double satirYuksekligi = 15;
  static const double altPay = 6;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: yzKarneCumlesi(karne, en),
      hint: en ? 'Opens the breakdown by type of source' : 'Kaynak türlerinin dökümünü açar',
      excludeSemantics: true,
      child: InkWell(
        key: const ValueKey('yz-karne-mobil'),
        onTap: () => yzKarneAltSayfasi(context, karne: karne, en: en),
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.only(bottom: altPay),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: satirYuksekligi),
            child: Row(children: [
              YzKarneCubugu(karne: karne, genislik: 44, yukseklik: 5),
              const SizedBox(width: 8),
              Flexible(
                child: Text(yzKarneKisa(karne, en),
                    maxLines: 1, overflow: TextOverflow.ellipsis, style: _sade()),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.info_outline_rounded, size: 15, color: YzRenk.soluk),
            ]),
          ),
        ),
      ),
    );
  }
}

/// Alttan açılan sayfa (yzAltSayfa): toplam, büyük çubuk, dört türün sayısı
/// ve bir cümlelik tanımı (sıfır olan tür de yazılı), sayımın tanımı.
Future<void> yzKarneAltSayfasi(BuildContext context, {required YzKarne karne, required bool en}) =>
    yzAltSayfa<void>(context, builder: (c) => YzKarneDokumu(karne: karne, en: en));

class YzKarneDokumu extends StatelessWidget {
  const YzKarneDokumu({super.key, required this.karne, required this.en});
  final YzKarne karne;
  final bool en;

  @override
  Widget build(BuildContext context) {
    final turler = karne.turler;
    return ListView(
      key: const ValueKey('yz-karne-dokumu'),
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      children: [
        Text(buyukHarf(en ? 'Source breakdown' : 'Kaynak karnesi', en), style: YzYazi.ustEtiket()),
        const SizedBox(height: 8),
        Semantics(header: true, child: Text(_bas(karne.toplam, en), style: YzYazi.baslik(20))),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, kis) => Align(
            alignment: Alignment.centerLeft,
            child: YzKarneCubugu(karne: karne, genislik: kis.maxWidth, yukseklik: 8),
          ),
        ),
        const SizedBox(height: 10),
        for (var i = 0; i < kYzKarneTurSayisi; i++) _TurSatiri(tur: i, sayi: turler[i], en: en),
        const Divider(color: YzRenk.cizgi, height: 24),
        Text(
          en
              ? 'Counted: the distinct sources behind the blue figures on this page; a source behind several figures counts once.'
              : 'Sayılan: bu sayfadaki mavi rakamların dayandığı farklı kaynaklar; birden çok rakamı destekleyen kaynak bir kez sayılır.',
          style: YzYazi.govde(boy: 14, renk: YzRenk.soluk).copyWith(height: 1.45),
        ),
      ],
    );
  }
}

class _TurSatiri extends StatelessWidget {
  const _TurSatiri({required this.tur, required this.sayi, required this.en});
  final int tur;
  final int sayi;
  final bool en;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: kYzKarneRenkleri[tur],
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(child: Text(yzKarneTurAdi(tur, en), style: YzYazi.baslik(16))),
                  const SizedBox(width: 12),
                  Text('$sayi',
                      style: YzYazi.veri(
                          boy: 15,
                          renk: sayi == 0 ? YzRenk.soluk : YzRenk.murekkep,
                          kalinlik: FontWeight.w600)),
                ]),
                const SizedBox(height: 3),
                Text(yzKarneTanimi(tur, en),
                    style: YzYazi.govde(boy: 14.5, renk: YzRenk.soluk).copyWith(height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
