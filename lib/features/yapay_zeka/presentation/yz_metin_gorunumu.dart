import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/utils/turkce_metin.dart';
import '../data/yz_iskelet.g.dart';
import '../data/yz_sozluk.g.dart';

import '../data/yz_grafikler.g.dart';
import 'yz_cekme.dart';
import 'yz_gorsel.dart';
import 'yz_kaynak_balonu.dart';
import 'yz_kisaltma.dart';
import 'yz_mobil.dart';
import 'yz_grafik.dart';
import 'yz_okuma.dart';
import 'yz_sozluk_esle.dart';
import 'yz_tasarim.dart';
import 'yz_teknoloji_izi.dart';

/// Bölüm metinlerinin çizicisi.
///
/// Dosya dizisinin çizicisi (`dossier_prose.dart`) yalnız paragraf, kalın,
/// italik ve tablo tanıyor; bu bölümün metinleri ayrıca `##` alt başlık,
/// `>` özet bloğu (Tur 1 günlüğü, §5) ve madde listesi (karar 60) kullanıyor.
/// Markdown'ın tamamı değil, DAR BİR KESİT — metinlerin kullandığı kadarı ve
/// fazlası değil:
///
///   `# N · Başlık`   atlanır (sayfa başlığı kendisi kuruyor)
///   `> …`            özet bloğu (ardışık satırlar tek blok)
///   `## …`           alt başlık
///   `- …`            madde listesi (ardışık satırlar tek liste, her satır bir madde)
///   `| … |`          tablo (ikinci satır `|---|` ayıracı)
///   boş satır        paragraf sınırı
///   `**…**` `*…*`    kalın, italik
///
/// Tanınmayan biçim (bağlantı) DÜZ METİN olarak çizilir — sessizce
/// yutulmaz. Metin dogrula_bolumler.py'den geçerek buraya geliyor.
/// `grafik` ve `gorsel`: `[[grafik:<kimlik>]]` / `[[gorsel:<kimlik>]]` yönerge
/// satırı (karar 58); metin değil, terim ve teknoloji aranmaz.
/// `cekme`: `[[cekme:<kimlik>]]`, öne çıkan cümle (madde 6); metnin tekrarı,
/// arama, okuma süresi ve sözlük görmez. Tanınmayan `[[ad:kimlik]]` satırı
/// blok sayılmaz, metin olarak da çizilmez.
enum YzBlokTuru { ozet, altBaslik, paragraf, tablo, grafik, gorsel, liste, cekme }

class YzBlok {
  const YzBlok(this.tur, {this.metin = '', this.satirlar = const [], this.ogeler = const []});
  final YzBlokTuru tur;
  final String metin;

  /// Tablo: ilk satır başlık, gerisi gövde. Ayıraç satırı yok.
  final List<List<String>> satirlar;

  /// Liste: maddeler, sırasıyla ("- " olmadan).
  final List<String> ogeler;

  /// Bloğun okunan metin parçaları: paragraf ve özet tek parça, liste her
  /// madde ayrı (sözlük, kısaltma ve aramanın gördüğü birimler).
  List<String> get parcalar => switch (tur) {
        YzBlokTuru.liste => ogeler,
        YzBlokTuru.paragraf || YzBlokTuru.ozet => [metin],
        _ => const [],
      };
}

/// Listenin teknoloji eşleştiricisinin gördüğü metni: Python satırları
/// ("- a", "- b") boşlukla birleştirip tek blok sayıyor (teknoloji_izi.py).
String yzListeMetni(List<String> ogeler) => [for (final o in ogeler) '- $o'].join(' ');

List<String> _hucreler(String satir) {
  var s = satir.trim();
  if (s.startsWith('|')) s = s.substring(1);
  if (s.endsWith('|')) s = s.substring(0, s.length - 1);
  return s.split('|').map((h) => h.trim()).toList();
}

bool _ayiracMi(String satir) =>
    RegExp(r'^\|?\s*:?-{3,}:?\s*(\|\s*:?-{3,}:?\s*)*\|?\s*$').hasMatch(satir.trim());

final RegExp _yonerge = RegExp(r'^\[\[(grafik|gorsel|cekme):([a-z0-9-]+)\]\]$');
final RegExp _herYonerge = RegExp(r'^\[\[[a-z]+:[a-z0-9-]+\]\]$');

/// Metni bloklara ayırır. Testler doğrudan bunu sınıyor.
List<YzBlok> yzAyristir(String md) {
  final bloklar = <YzBlok>[];
  final satirlar = md.replaceAll('\r\n', '\n').split('\n');
  var i = 0;
  final paragraf = <String>[];

  void paragrafiKapat() {
    if (paragraf.isNotEmpty) {
      bloklar.add(YzBlok(YzBlokTuru.paragraf, metin: paragraf.join(' ')));
      paragraf.clear();
    }
  }

  while (i < satirlar.length) {
    final s = satirlar[i];
    final t = s.trim();
    if (t.isEmpty) {
      paragrafiKapat();
      i++;
    } else if (t.startsWith('# ')) {
      paragrafiKapat();
      i++; // sayfa başlığı
    } else if (_yonerge.hasMatch(t)) {
      paragrafiKapat();
      final m = _yonerge.firstMatch(t)!;
      bloklar.add(YzBlok(YzBlokTuru.values.byName(m.group(1)!), metin: m.group(2)!));
      i++;
    } else if (_herYonerge.hasMatch(t)) {
      paragrafiKapat();
      i++; // tanınmayan yönerge: blok değil
    } else if (t.startsWith('## ')) {
      paragrafiKapat();
      bloklar.add(YzBlok(YzBlokTuru.altBaslik, metin: t.substring(3).trim()));
      i++;
    } else if (t.startsWith('- ')) {
      paragrafiKapat();
      final ogeler = <String>[];
      while (i < satirlar.length && satirlar[i].trim().startsWith('- ')) {
        ogeler.add(satirlar[i].trim().substring(2).trim());
        i++;
      }
      bloklar.add(YzBlok(YzBlokTuru.liste, ogeler: ogeler));
    } else if (t.startsWith('>')) {
      paragrafiKapat();
      final parca = <String>[];
      while (i < satirlar.length && satirlar[i].trim().startsWith('>')) {
        parca.add(satirlar[i].trim().replaceFirst(RegExp(r'^>\s?'), ''));
        i++;
      }
      bloklar.add(YzBlok(YzBlokTuru.ozet, metin: parca.join(' ').trim()));
    } else if (t.startsWith('|')) {
      paragrafiKapat();
      final tablo = <List<String>>[];
      while (i < satirlar.length && satirlar[i].trim().startsWith('|')) {
        if (!_ayiracMi(satirlar[i])) tablo.add(_hucreler(satirlar[i]));
        i++;
      }
      bloklar.add(YzBlok(YzBlokTuru.tablo, satirlar: tablo));
    } else {
      paragraf.add(t);
      i++;
    }
  }
  paragrafiKapat();
  return bloklar;
}

// ── Bölünmez boşluk (karar 60) ───────────────────────────────────────────
// Rakam ile birimi ya da büyüklüğü satır sonunda ayrılmasın: "1,2 milyar"
// "1,2 / milyar" diye bölünmüyor. Yalnız çizimde; eşleştiriciler ham metni
// görüyor (uzunluk aynı, konumlar kaymıyor).

final RegExp _kalinRakam = RegExp(r'\*\*([^*]*\d[^*]*)\*\*');
final RegExp _birim = RegExp(
    r'^ (milyon|milyar|trilyon|bin|ton|tonluk|kg|kilogram|gram|hektar|dekar|dönüm|akre|km|kilometre|metre|cm|mm|litre|lira|TL|dolar|avro|euro|sterlin|rupi|yuan|derece|puan|kat|yıl|gün|ay|saat|dakika|saniye|million|billion|trillion|thousand|tonnes|tons|kilograms|hectares|ha|acres|kilometres|metres|meters|litres|dollars|euros|pounds|rupees|degrees|points|times|years|days|months|hours|minutes|seconds|per cent|percent)(?![\p{L}])',
    unicode: true);

String yzBolunmez(String metin) {
  if (!metin.contains('**')) return metin;
  final b = metin.split('');
  for (final m in _kalinRakam.allMatches(metin)) {
    for (var i = m.start; i < m.end; i++) {
      if (b[i] == ' ') b[i] = ' ';
    }
    if (_birim.hasMatch(metin.substring(m.end))) b[m.end] = ' ';
  }
  return b.join();
}

/// Arama sonucunun metin içi vurgusu (karar 60): sarı fosforlu kalem.
const Color kYzAramaRengi = Color(0xFFFFE9A8);
const Color _aramaZemini = kYzAramaRengi;

/// Seçili teknolojinin geçtiği kelimeler (karar 60): mavi fosforlu kalem.
/// Paragraf kutusu ve paragrafın solunda çizgi yok (kullanıcı, 18 Kas 2026).
const Color kYzKalemRengi = Color(0xFFCFE0F7);

/// Satır içi biçim: `**kalın**`, `*italik*`. Rakam taşıyan kalın parça
/// çelik mavisiyle çiziliyor (gövde yazı tipinin kendi rakamı, tam boy;
/// karar 60): metindeki ölçülmüş sayılar böyle ayırt ediliyor.
///
/// [etkilesim] verilirse düz metindeki adresler bağlantı (§30 kaynakça),
/// [isaretler]deki sözlük terimleri (karar 14) ve [kisaltmalar] balon açan
/// parça olur (karar 60). [arama]: arama kelimelerinin geçtiği aralıklar,
/// sarı zeminle; [kalem]: seçili teknolojinin geçtiği kelimeler, mavi
/// zeminle (ikisi çakışırsa arama önde).
TextSpan yzSatirIci(String metin, TextStyle taban,
    {YzEtkilesim? etkilesim,
    List<YzIsaret> isaretler = const [],
    List<YzKisaltmaIsareti> kisaltmalar = const [],
    List<(int, int)> arama = const [],
    List<(int, int)> kalem = const []}) {
  final gorunen = yzBolunmez(metin);
  final parcalar = <InlineSpan>[];
  final desen = RegExp(r'\*\*(.+?)\*\*|\*(.+?)\*');

  // [a, b) aralığını arama vurgusunun sınırlarından bölerek ekle.
  void ekle(int a, int b, {TextStyle? stil, GestureRecognizer? r, MouseCursor? imlec}) {
    if (b <= a) return;
    final kesimler = <int>{a, b};
    for (final x in [...arama, ...kalem]) {
      if (x.$1 > a && x.$1 < b) kesimler.add(x.$1);
      if (x.$2 > a && x.$2 < b) kesimler.add(x.$2);
    }
    final sirali = kesimler.toList()..sort();
    for (var i = 0; i + 1 < sirali.length; i++) {
      final s = sirali[i], e = sirali[i + 1];
      final zemin = arama.any((x) => x.$1 <= s && e <= x.$2)
          ? _aramaZemini
          : (kalem.any((x) => x.$1 <= s && e <= x.$2) ? kYzKalemRengi : null);
      var st = stil;
      if (zemin != null) {
        st = (st ?? const TextStyle()).copyWith(backgroundColor: zemin);
      }
      parcalar.add(TextSpan(text: gorunen.substring(s, e), style: st, recognizer: r, mouseCursor: imlec));
    }
  }

  // Dokunulabilir aralıklar (hepsi kalın/italik parçaların dışında).
  final etkin = <(int, int, Object)>[
    if (etkilesim != null) ...[
      for (final a in yzAdresler(metin)) (a.$1, a.$2, metin.substring(a.$1, a.$2)),
      for (final i in isaretler) (i.bas, i.son, i),
      for (final k in kisaltmalar) (k.bas, k.son, k),
    ],
  ]..sort((a, b) => a.$1.compareTo(b.$1));

  void duz(int bas, int bitis) {
    var k = bas;
    for (final e in etkin) {
      if (e.$1 < k || e.$2 > bitis) continue;
      if (e.$1 > k) ekle(k, e.$1);
      final parca = metin.substring(e.$1, e.$2);
      final yuk = e.$3;
      if (yuk is YzIsaret) {
        final r = TapGestureRecognizer()
          ..onTapUp = (d) => etkilesim!.terimAc(yuk.terim, d.globalPosition);
        etkilesim!.tanicilar.add(r);
        ekle(e.$1, e.$2,
            r: r,
            imlec: SystemMouseCursors.click,
            stil: const TextStyle(
              decoration: TextDecoration.underline,
              decorationStyle: TextDecorationStyle.dotted,
              decorationColor: YzRenk.makine,
              decorationThickness: 1.6,
            ));
      } else if (yuk is YzKisaltmaIsareti) {
        final r = TapGestureRecognizer()
          ..onTapUp = (d) => etkilesim!.kisaltmaAc?.call(yuk.kisaltma, d.globalPosition);
        etkilesim!.tanicilar.add(r);
        ekle(e.$1, e.$2,
            r: r,
            imlec: SystemMouseCursors.click,
            stil: TextStyle(
              decoration: TextDecoration.underline,
              decorationStyle: TextDecorationStyle.dotted,
              decorationColor: YzRenk.makine.withValues(alpha: 0.6),
              decorationThickness: 1.4,
            ));
      } else {
        final r = TapGestureRecognizer()..onTap = () => etkilesim!.baglantiAc(parca);
        etkilesim!.tanicilar.add(r);
        ekle(e.$1, e.$2,
            r: r,
            imlec: SystemMouseCursors.click,
            stil: TextStyle(
              color: YzRenk.makine,
              decoration: TextDecoration.underline,
              decorationColor: YzRenk.makine.withValues(alpha: 0.5),
            ));
      }
      k = e.$2;
    }
    if (bitis > k) ekle(k, bitis);
  }

  var son = 0;
  for (final m in desen.allMatches(metin)) {
    if (m.start > son) duz(son, m.start);
    if (m.group(1) != null) {
      final ic = m.group(1)!;
      final rakamli = RegExp(r'\d').hasMatch(ic);
      // Karar 58: kaynağı bağlı rakam dokunulabilir. Noktalı alt çizgi
      // kalktı (karar 60): renk ve yazı tipi dokunulabildiğini söylüyor,
      // fareyle üstüne gelince el imleci; okura bir kez ipucu.
      final kaynakli = rakamli && etkilesim != null && (etkilesim.rakamVar?.call(ic) ?? false);
      TapGestureRecognizer? r;
      if (kaynakli) {
        r = TapGestureRecognizer()..onTapUp = (d) => etkilesim.rakamAc?.call(ic, d.globalPosition);
        etkilesim.tanicilar.add(r);
      }
      ekle(m.start + 2, m.end - 2,
          r: r,
          imlec: kaynakli ? SystemMouseCursors.click : null,
          // Rakam gövde yazı tipinin kendi rakamıyla, tam boy, çelik mavisi
          // (karar 60, kullanıcının seçimi B): eşit genişlikli ayrı yazı tipi
          // yoğun paragraflarda cümlenin ritmini bölüyordu.
          stil: rakamli
              ? const TextStyle(
                  color: YzRenk.makine,
                  fontFeatures: [FontFeature.liningFigures()],
                )
              : const TextStyle(fontWeight: FontWeight.w700));
    } else {
      ekle(m.start + 1, m.end - 1, stil: const TextStyle(fontStyle: FontStyle.italic));
    }
    son = m.end;
  }
  if (son < metin.length) duz(son, metin.length);
  return TextSpan(style: taban, children: parcalar);
}

/// Başlık sayfasındaki "sonraki işaretli yer" düğmesinin eli: çizici
/// işaretlediği her bloğa bir anahtar veriyor, düğme sırayla onlara kaydırıyor.
class YzVurguDenetcisi {
  final List<GlobalKey> _anahtarlar = [];
  int _sira = -1;

  /// İçindekiler: alt başlıkların anahtarları, metindeki sırayla.
  final List<GlobalKey> _basliklar = [];

  /// Alt başlıkların anahtarları (yan içindekiler hangi bölümde olunduğunu
  /// bunlardan okuyor).
  List<GlobalKey> get basliklar => List.unmodifiable(_basliklar);

  void _basliklariKur(List<GlobalKey> a) {
    _basliklar
      ..clear()
      ..addAll(a);
  }

  /// Bütün blokların anahtarları, `yzAyristir` sırasıyla (madde 17): okuma
  /// izi metindeki konumu DOSYADAKİ bloklardan ölçüyor. Grafik ve görselde
  /// null. Telefonda bölünen paragrafta anahtar bütün parçaları sarmalı.
  final List<GlobalKey?> _bloklar = [];
  List<GlobalKey?> get blokAnahtarlari => List.unmodifiable(_bloklar);

  void _bloklariKur(List<GlobalKey?> a) {
    _bloklar
      ..clear()
      ..addAll(a);
  }

  /// [i]. alt başlığa kaydırır (içindekilerden).
  void basligaGit(int i) {
    if (i < 0 || i >= _basliklar.length) return;
    final c = _basliklar[i].currentContext;
    if (c != null) {
      Scrollable.ensureVisible(c, duration: const Duration(milliseconds: 350), alignment: 0.04);
    }
  }

  int get sayi => _anahtarlar.length;

  void _kur(List<GlobalKey> anahtarlar) {
    _anahtarlar
      ..clear()
      ..addAll(anahtarlar);
    _sira = -1;
  }

  /// Bir sonraki işaretli bloğa kaydırır (sondan sonra başa döner).
  void sonraki() {
    if (_anahtarlar.isEmpty) return;
    for (var deneme = 0; deneme < _anahtarlar.length; deneme++) {
      _sira = (_sira + 1) % _anahtarlar.length;
      final c = _anahtarlar[_sira].currentContext;
      if (c != null) {
        Scrollable.ensureVisible(c,
            duration: const Duration(milliseconds: 350), alignment: 0.12);
        return;
      }
    }
  }
}

/// Metin sütununun en geniş hâli (karar 60): satır ~70-75 harf. Grafik,
/// görsel ve tablo sayfanın tam genişliğini kullanıyor.
const double kYzMetinGenisligi = 610;

/// Bir metinde arama kelimelerinin geçtiği blok sayısı (paragraf, liste,
/// alt başlık, tablo satırı) — sayfanın "N yerde geçiyor" şeridi.
int yzAramaSay(String md, List<String> kelimeler, bool en) {
  if (kelimeler.isEmpty) return 0;
  var n = 0;
  for (final b in yzAyristir(md)) {
    switch (b.tur) {
      case YzBlokTuru.paragraf || YzBlokTuru.ozet || YzBlokTuru.altBaslik:
        if (yzAramaGeciyor(b.metin, kelimeler, en)) n++;
      case YzBlokTuru.liste:
        if (b.ogeler.any((o) => yzAramaGeciyor(o, kelimeler, en))) n++;
      case YzBlokTuru.tablo:
        for (final s in b.satirlar.skip(1)) {
          if (yzAramaGeciyor(s.join(' '), kelimeler, en)) n++;
        }
      default:
        break;
    }
  }
  return n;
}

class YzMetinGorunumu extends StatefulWidget {
  const YzMetinGorunumu(
      {super.key,
      required this.metin,
      required this.en,
      this.sozluk = true,
      this.bolumNo,
      this.vurgu,
      this.arama,
      this.odakTerim,
      this.vurguDenetcisi,
      this.kaynakSayfasi,
      this.olcek = 1.0,
      this.giris = true,
      this.bolumBaglantisi});
  final String metin;

  /// Alt başlığın paylaşılabilir adresi (karar 60): verilirse başlığın
  /// yanında küçük bir bağlantı düğmesi; dokununca adres panoya kopyalanır.
  final void Function(String altBaslik)? bolumBaglantisi;

  /// Rakamdan kaynağa (karar 58): "bNN" ya da "tek_<kod>"; verilirse kalın
  /// rakamlar dokunulabilir ve kaynağın balonunu açıyor.
  final String? kaynakSayfasi;

  /// Merkez sayfada seçilen teknoloji (karar 57): geçtiği paragraflar ve
  /// tablo satırları işaretleniyor. Yoksa hiçbir şey işaretlenmiyor.
  final String? vurgu;

  /// Bölüm içi arama (karar 60): kelimelerin geçtiği bloklar işaretli,
  /// kelimeler sarı zeminle.
  final String? arama;

  /// Sözlük sayfasında terim (karar 60): balondan "Sözlükte aç" ile
  /// gelindiyse o terimin paragrafı işaretli.
  final String? odakTerim;
  final YzVurguDenetcisi? vurguDenetcisi;

  /// Tablo başlıkları büyük harfle yazılıyor; Türkçede `i` → `İ` olmalı
  /// (`buyukHarf`), ham `toUpperCase()` "ŞIRKET", "ÜNIVERSITE" üretiyor.
  /// Sözlük terimleri de dile göre aranıyor.
  final bool en;

  /// Sözlük terimleri ilk geçtikleri yerde balonla açılsın mı (karar 14).
  /// Sözlük sayfasının kendisinde kapalı.
  final bool sozluk;

  /// Başlığın numarası: terim başka başlıkta başka anlamda geçiyorsa
  /// (`YzTerim.yalniz`, `haric`) balon yalnız doğru başlıkta açılır.
  final int? bolumNo;

  /// Okurun seçtiği yazı boyu (karar 60): gövde, liste, alt başlık, tablo.
  final double olcek;

  /// İlk paragraf giriş paragrafı olarak bir punto büyük (karar 60: özet
  /// katmanı ayrı kutu olmadan, karar 56a).
  final bool giris;

  @override
  State<YzMetinGorunumu> createState() => _YzMetinGorunumuState();
}

/// Dokunma tanıyıcıları her çizimde yeniden kurulmuyor: metin, dil ya da
/// ekran sınıfı (dar/geniş) değişmedikçe aynı bloklar kullanılıyor; tanıyıcılar
/// yalnız metin değişince ve bileşen kapanınca bırakılıyor — bir dokunuş
/// sürerken bırakılan tanıyıcı hata verirdi.
class _YzMetinGorunumuState extends State<YzMetinGorunumu> {
  final _tanicilar = <GestureRecognizer>[];
  final _onbellek = <String, List<Widget>>{};
  late List<YzBlok> _bloklar;

  /// Blok → parça (paragraf tek, liste madde madde) → işaretler.
  late List<List<List<YzIsaret>>> _isaretler;
  late List<List<List<YzKisaltmaIsareti>>> _kisaltmalar;
  late List<List<List<(int, int)>>> _arama;

  /// Seçili teknolojinin geçtiği kelimeler (blok → parça → aralıklar).
  late List<List<List<(int, int)>>> _kalem;

  /// Sözlükte açılan terimin bloğu (yumuşak zeminli kutu, çizgisiz).
  late List<bool> _odakBlok;
  // Karar 57 ve 60: işaretli (teknoloji, arama ya da sözlük terimi) bloklar
  // ve tablo satırları.
  late List<bool> _isaretliBlok;
  late List<Set<int>> _isaretliSatir;
  late List<GlobalKey?> _anahtar;
  late List<GlobalKey?> _baslikAnahtari;
  late int _ilkParagraf;

  @override
  void initState() {
    super.initState();
    _hazirla();
  }

  @override
  void didUpdateWidget(covariant YzMetinGorunumu eski) {
    super.didUpdateWidget(eski);
    if (eski.metin != widget.metin ||
        eski.en != widget.en ||
        eski.sozluk != widget.sozluk ||
        eski.bolumNo != widget.bolumNo ||
        eski.vurgu != widget.vurgu ||
        eski.arama != widget.arama ||
        eski.odakTerim != widget.odakTerim ||
        eski.kaynakSayfasi != widget.kaynakSayfasi) {
      _birak();
      _hazirla();
    } else if (eski.olcek != widget.olcek || eski.giris != widget.giris) {
      _onbellek.clear();
    } else if (eski.vurguDenetcisi != widget.vurguDenetcisi) {
      widget.vurguDenetcisi?._kur(_isaretliAnahtarlar);
      widget.vurguDenetcisi?._basliklariKur([for (final a in _baslikAnahtari) if (a != null) a]);
      widget.vurguDenetcisi?._bloklariKur(_anahtar);
    }
  }

  void _hazirla() {
    final en = widget.en;
    _bloklar = yzAyristir(widget.metin);
    // Bir terim ve bir kısaltma sayfada bir kez: bloklar sırayla, aynı küme
    // taşınarak.
    final gorulen = <String>{};
    final gorulenKisaltma = <String>{};
    final no = widget.bolumNo;
    final sozluk = no == null ? kYzSozluk : kYzSozluk.where((t) => t.baslikta(no)).toList();
    final kelimeler = widget.arama == null ? const <String>[] : yzAramaKelimeleri(widget.arama!, en);
    final kod = yzTeknolojiVar(widget.vurgu) ? widget.vurgu! : null;
    _isaretler = [];
    _kisaltmalar = [];
    _arama = [];
    _kalem = [];
    for (final b in _bloklar) {
      final ti = <List<YzIsaret>>[];
      final ki = <List<YzKisaltmaIsareti>>[];
      final ar = <List<(int, int)>>[];
      final ka = <List<(int, int)>>[];
      for (final p in b.parcalar) {
        // Temel terim (yapay zekâ, sensör…) yalnız Kavramlar'da balonlu; eşleşme
        // yine yapılıyor ki gölgesi ve "bir kez" kuralı değişmesin.
        final terimler = widget.sozluk
            ? [
                for (final i in yzTerimleriBul(p, en, gorulen, sozluk: sozluk))
                  if (i.terim.balonda(no)) i,
              ]
            : const <YzIsaret>[];
        ti.add(terimler);
        ki.add(widget.sozluk
            ? yzKisaltmalariBul(p, gorulenKisaltma, dolu: [
                for (final i in terimler) (i.bas, i.son),
                ...yzAdresler(p),
              ])
            : const []);
        ar.add(yzAramaAraliklari(p, kelimeler, en));
        ka.add(kod == null ? const [] : yzTeknolojiAraliklari(p, kod, en));
      }
      _isaretler.add(ti);
      _kisaltmalar.add(ki);
      _arama.add(ar);
      _kalem.add(ka);
    }
    final odak = widget.odakTerim == null
        ? null
        : kYzSozluk.where((t) => t.kimlik == widget.odakTerim).firstOrNull;
    bool isaretli(String metin) =>
        (kod != null && yzTeknolojiGeciyor(metin, kod, en)) ||
        (kelimeler.isNotEmpty && yzAramaGeciyor(metin, kelimeler, en));
    _isaretliBlok = [
      for (final b in _bloklar)
        switch (b.tur) {
          YzBlokTuru.paragraf || YzBlokTuru.ozet =>
            isaretli(b.metin) || (odak != null && b.metin.startsWith('**${odak.ad(en)}** (')),
          YzBlokTuru.liste => (kod != null && yzTeknolojiGeciyor(yzListeMetni(b.ogeler), kod, en)) ||
              (kelimeler.isNotEmpty && b.ogeler.any((o) => yzAramaGeciyor(o, kelimeler, en))),
          YzBlokTuru.altBaslik => kelimeler.isNotEmpty && yzAramaGeciyor(b.metin, kelimeler, en),
          _ => false,
        },
    ];
    _odakBlok = [
      for (final b in _bloklar)
        odak != null &&
            (b.tur == YzBlokTuru.paragraf || b.tur == YzBlokTuru.ozet) &&
            b.metin.startsWith('**${odak.ad(en)}** ('),
    ];
    _isaretliSatir = [
      for (final b in _bloklar)
        b.tur == YzBlokTuru.tablo && (kod != null || kelimeler.isNotEmpty)
            ? {
                for (var r = 0; r < b.satirlar.length; r++)
                  if ((kod != null && yzTeknolojiGeciyor(yzTabloSatiri(b.satirlar[r]), kod, en)) ||
                      (r > 0 && kelimeler.isNotEmpty && yzAramaGeciyor(b.satirlar[r].join(' '), kelimeler, en)))
                    r,
              }
            : <int>{},
    ];
    // Her metin bloğunun anahtarı var (okuma izi, madde 17); "sonraki
    // işaretli yer" yalnız işaretlileri geziyor.
    _anahtar = [
      for (var i = 0; i < _bloklar.length; i++)
        _bloklar[i].tur == YzBlokTuru.grafik || _bloklar[i].tur == YzBlokTuru.gorsel ? null : GlobalKey(),
    ];
    widget.vurguDenetcisi?._kur(_isaretliAnahtarlar);
    widget.vurguDenetcisi?._bloklariKur(_anahtar);
    _baslikAnahtari = [
      for (var i = 0; i < _bloklar.length; i++)
        _bloklar[i].tur == YzBlokTuru.altBaslik ? (_anahtar[i] ?? GlobalKey()) : null,
    ];
    widget.vurguDenetcisi?._basliklariKur([for (final a in _baslikAnahtari) if (a != null) a]);
    _ilkParagraf = widget.giris && _bloklar.isNotEmpty && _bloklar.first.tur == YzBlokTuru.paragraf ? 0 : -1;
  }

  List<GlobalKey> get _isaretliAnahtarlar => [
        for (var i = 0; i < _anahtar.length; i++)
          if (_isaretliBlok[i] || _isaretliSatir[i].isNotEmpty) _anahtar[i]!,
      ];

  void _birak() {
    for (final t in _tanicilar) {
      t.dispose();
    }
    _tanicilar.clear();
    _onbellek.clear();
  }

  @override
  void dispose() {
    _birak();
    super.dispose();
  }

  static String? _baslikAdresi(int? no) {
    if (no == null) return null;
    for (final b in kYzBasliklar) {
      if (b.no == no) return b.slug;
    }
    return null;
  }

  YzEtkilesim get _etkilesim => YzEtkilesim(
        tanicilar: _tanicilar,
        baglantiAc: (a) {
          final uri = Uri.tryParse(a);
          if (uri != null) launchUrl(uri, mode: LaunchMode.externalApplication);
        },
        terimAc: (t, konum) => yzTerimBalonu(context, t, konum, widget.en,
            geri: _baslikAdresi(widget.bolumNo)),
        rakamVar: widget.kaynakSayfasi == null
            ? null
            : (k) => yzRakamKaynagiVar(widget.kaynakSayfasi!, k, widget.en),
        rakamAc: widget.kaynakSayfasi == null
            ? null
            : (k, konum) => yzKaynakBalonu(context, widget.kaynakSayfasi!, k, konum, widget.en),
        kisaltmaAc: (k, konum) => yzKisaltmaBalonu(context, k, konum, widget.en),
      );

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, kis) {
      final dar = kis.maxWidth < 560;
      // Telefon kararları (mobil okuma turu, karar 62) ekranın genişliğiyle
      // (< 640, yzTelefon); `dar` metin sütununun genişliğiyle (< 560) ve
      // yalnız punto ile tablo düzenini seçiyor.
      final telefon = yzTelefon(context);
      final metinW = math.min(kis.maxWidth, kYzMetinGenisligi);
      final anahtar = '$dar|$telefon|${widget.olcek}|${metinW.round()}';
      if (!_onbellek.containsKey(anahtar)) {
        _onbellek
          ..clear()
          ..[anahtar] = _ciz(dar, metinW, telefon: telefon);
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _onbellek[anahtar]!,
      );
    });
  }

  /// Metin bloğu sütunun ortasında, [metinW] genişliğinde (grafik ve görsel
  /// tam genişlikte).
  Widget _sutun(double metinW, Widget cocuk, {Key? key}) =>
      Center(key: key, child: SizedBox(width: metinW, child: cocuk));

  /// Sözlükte açılan terimin girdisi: yumuşak zeminli, yuvarlak köşeli kutu;
  /// kenar ve sol çizgi yok (karar 60).
  Widget _odakKutusu(Widget cocuk) => Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
        decoration: BoxDecoration(
          color: YzRenk.bitkiAcik,
          borderRadius: BorderRadius.circular(8),
        ),
        child: cocuk,
      );

  /// Tablo hücresinde fosforlu kalem: teknoloji ve arama kelimeleri.
  List<(int, int)> _hucreKalemi(String hucre) {
    final kod = yzTeknolojiVar(widget.vurgu) ? widget.vurgu! : null;
    return kod == null ? const [] : yzTeknolojiAraliklari(hucre, kod, widget.en);
  }

  List<(int, int)> _hucreAramasi(String hucre) => widget.arama == null
      ? const []
      : yzAramaAraliklari(hucre, yzAramaKelimeleri(widget.arama!, widget.en), widget.en);

  List<Widget> _ciz(bool dar, double metinW, {bool telefon = false}) {
    final o = widget.olcek;
    final govde = YzYazi.govde(boy: (dar ? 17.5 : 18.5) * o);
    final giris = YzYazi.govde(boy: (dar ? 19.5 : 21) * o).copyWith(height: 1.55);
    final etkilesim = _etkilesim;
    final en = widget.en;
    final cikti = <Widget>[];
    for (var i = 0; i < _bloklar.length; i++) {
      final b = _bloklar[i];
      switch (b.tur) {
        case YzBlokTuru.ozet:
          cikti.add(_sutun(
              metinW,
              Padding(
                padding: const EdgeInsets.only(bottom: 28),
                child: Container(
                  padding: EdgeInsets.fromLTRB(dar ? 16 : 22, 18, dar ? 16 : 22, 18),
                  decoration: BoxDecoration(
                    color: YzRenk.bitkiAcik,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: YzRenk.bitki.withValues(alpha: 0.22)),
                  ),
                  child: SelectableText.rich(yzSatirIci(b.metin, govde.copyWith(height: 1.55),
                      etkilesim: etkilesim,
                      isaretler: _isaretler[i][0],
                      kisaltmalar: _kisaltmalar[i][0],
                      arama: _arama[i][0],
                      kalem: _kalem[i][0])),
                ),
              ),
              key: _anahtar[i]));
        case YzBlokTuru.altBaslik:
          final stil = YzYazi.baslik((dar ? 21 : 24) * (1 + (o - 1) * 0.6));
          final ar = widget.arama == null
              ? const <(int, int)>[]
              : yzAramaAraliklari(b.metin, yzAramaKelimeleri(widget.arama!, en), en);
          final baslikMetni = Semantics(
            header: true,
            child: ar.isEmpty
                ? Text(b.metin, style: stil)
                : Text.rich(yzSatirIci(b.metin, stil, arama: ar)),
          );
          cikti.add(_sutun(
              metinW,
              Padding(
                // Telefonda alt başlığın üstü daha açık, altı daha sıkı:
                // başlık önceki bölümden ayrılıp kendi paragrafına bağlanıyor.
                padding: telefon
                    ? const EdgeInsets.only(top: 44, bottom: 10)
                    : const EdgeInsets.only(top: 34, bottom: 12),
                child: widget.bolumBaglantisi == null
                    ? baslikMetni
                    : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Expanded(child: baslikMetni),
                        IconButton(
                          tooltip: en ? 'Copy link to this section' : 'Bu bölümün bağlantısını kopyala',
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(Icons.link_rounded, size: 18, color: YzRenk.soluk),
                          onPressed: () => widget.bolumBaglantisi!(b.metin),
                        ),
                      ]),
              ),
              key: _baslikAnahtari[i]));
        case YzBlokTuru.paragraf:
          final stil = i == _ilkParagraf ? giris : govde;
          final metin = SelectableText.rich(yzSatirIci(b.metin, stil,
              etkilesim: etkilesim,
              isaretler: _isaretler[i][0],
              kisaltmalar: _kisaltmalar[i][0],
              arama: _arama[i][0],
              kalem: _kalem[i][0]));
          cikti.add(_sutun(
              metinW,
              Padding(
                padding: EdgeInsets.only(bottom: i == _ilkParagraf ? 26 : 22),
                child: _odakBlok[i] ? _odakKutusu(metin) : metin,
              ),
              key: _anahtar[i]));
        case YzBlokTuru.liste:
          final liste = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var j = 0; j < b.ogeler.length; j++)
                Padding(
                  padding: EdgeInsets.only(bottom: j == b.ogeler.length - 1 ? 0 : 9),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 22,
                        // Align: SizedBox'ın sıkı genişliği kareyi çubuğa
                        // çevirmesin (6 × 6 kalsın).
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            // Madde işareti ilk satırın ortasında.
                            padding: EdgeInsets.only(
                                left: 2, top: (govde.fontSize! * govde.height!) / 2 - 3),
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: YzRenk.bitki.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(1),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: SelectableText.rich(yzSatirIci(b.ogeler[j], govde,
                            etkilesim: etkilesim,
                            isaretler: _isaretler[i][j],
                            kisaltmalar: _kisaltmalar[i][j],
                            arama: _arama[i][j],
                            kalem: _kalem[i][j])),
                      ),
                    ],
                  ),
                ),
            ],
          );
          cikti.add(_sutun(
              metinW,
              Padding(
                padding: const EdgeInsets.only(top: 2, bottom: 22),
                child: liste,
              ),
              key: _anahtar[i]));
        case YzBlokTuru.grafik:
          final g = kYzGrafikler[b.metin];
          cikti.add(g == null ? const SizedBox.shrink() : YzGrafikKarti(grafik: g, en: en));
        case YzBlokTuru.gorsel:
          final g = kYzGorseller[b.metin];
          cikti.add(g == null ? const SizedBox.shrink() : YzGorselKarti(gorsel: g, en: en));
        case YzBlokTuru.cekme:
          cikti.add(yzCekme(b.metin, _bloklar,
              en: en, telefon: telefon, olcek: o, genislik: metinW, etkilesim: etkilesim, oncekiAralik: 22));
        case YzBlokTuru.tablo:
          cikti.add(Padding(
            key: _anahtar[i],
            padding: const EdgeInsets.only(top: 4, bottom: 22),
            child: dar
                ? _KartTablo(b.satirlar, en,
                    vurgulu: _isaretliSatir[i], olcek: o, kalem: _hucreKalemi, arama: _hucreAramasi)
                : _GenisTablo(b.satirlar, en,
                    vurgulu: _isaretliSatir[i], olcek: o, kalem: _hucreKalemi, arama: _hucreAramasi),
          ));
      }
    }
    return cikti;
  }
}

class _GenisTablo extends StatelessWidget {
  const _GenisTablo(this.satirlar, this.en,
      {this.vurgulu = const {}, this.olcek = 1.0, this.kalem, this.arama});
  final List<List<String>> satirlar;
  final bool en;
  final double olcek;

  /// Hücredeki teknoloji ve arama kelimeleri (fosforlu kalem, karar 60).
  final List<(int, int)> Function(String)? kalem;
  final List<(int, int)> Function(String)? arama;

  /// Seçili teknolojinin geçtiği satırlar (satirlar içindeki sıra; 0 başlık).
  final Set<int> vurgulu;

  @override
  Widget build(BuildContext context) {
    if (satirlar.isEmpty) return const SizedBox.shrink();
    final baslik = satirlar.first;
    final govde = satirlar.skip(1).toList();
    final hucre = YzYazi.govde(boy: 15.5 * olcek).copyWith(height: 1.45);
    return Container(
      decoration: BoxDecoration(
        color: YzRenk.yuzey,
        border: Border.all(color: YzRenk.cizgi),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.top,
        border: const TableBorder(
          horizontalInside: BorderSide(color: YzRenk.cizgi),
        ),
        children: [
          TableRow(
            decoration: const BoxDecoration(color: YzRenk.makineAcik),
            children: [
              for (final h in baslik)
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                  child: Text(buyukHarf(h, en), style: YzYazi.ustEtiket(renk: YzRenk.makine)),
                ),
            ],
          ),
          for (final (r, s) in govde.indexed)
            TableRow(
                decoration: vurgulu.contains(r + 1)
                    ? const BoxDecoration(color: YzRenk.makineAcik)
                    : null,
                children: [
              for (var i = 0; i < baslik.length; i++)
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 11, 14, 11),
                  child: SelectableText.rich(yzSatirIci(
                    i < s.length ? s[i] : '',
                    i == 0 && baslik.first.isEmpty
                        ? hucre.copyWith(fontWeight: FontWeight.w600)
                        : hucre,
                    kalem: kalem?.call(i < s.length ? s[i] : '') ?? const [],
                    arama: arama?.call(i < s.length ? s[i] : '') ?? const [],
                  )),
                ),
            ]),
        ],
      ),
    );
  }
}

/// Dar ekran: her satır bir kart, sütun adı hücrenin üstünde. Telefonda
/// yatay kaydırılan bir tablo okunmuyor; satırı dikey okumak doğal.
class _KartTablo extends StatelessWidget {
  const _KartTablo(this.satirlar, this.en,
      {this.vurgulu = const {}, this.olcek = 1.0, this.kalem, this.arama});
  final List<List<String>> satirlar;
  final bool en;
  final double olcek;
  final List<(int, int)> Function(String)? kalem;
  final List<(int, int)> Function(String)? arama;
  final Set<int> vurgulu;

  @override
  Widget build(BuildContext context) {
    if (satirlar.isEmpty) return const SizedBox.shrink();
    final baslik = satirlar.first;
    final hucre = YzYazi.govde(boy: 15.5 * olcek).copyWith(height: 1.45);
    // İlk sütunun başlığı boşsa ilk hücre kartın adı (ör. §23'teki tablo).
    final adSutunu = baslik.isNotEmpty && baslik.first.isEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (r, s) in satirlar.skip(1).indexed)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
            decoration: BoxDecoration(
              color: vurgulu.contains(r + 1) ? YzRenk.makineAcik : YzRenk.yuzey,
              // İşaretli satır: yumuşak zemin, ince mavi çerçeve; sol çizgi yok
              // (karar 60).
              border: Border.all(
                  color: vurgulu.contains(r + 1)
                      ? YzRenk.makine.withValues(alpha: 0.45)
                      : YzRenk.cizgi),
              borderRadius: BorderRadius.circular(vurgulu.contains(r + 1) ? 6 : 4),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (adSutunu && s.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(s.first, style: YzYazi.baslik(16)),
                  ),
                for (var i = adSutunu ? 1 : 0; i < baslik.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (baslik[i].isNotEmpty)
                          Text(buyukHarf(baslik[i], en),
                              style: YzYazi.ustEtiket(renk: YzRenk.makine)),
                        const SizedBox(height: 2),
                        SelectableText.rich(yzSatirIci(i < s.length ? s[i] : '', hucre,
                            kalem: kalem?.call(i < s.length ? s[i] : '') ?? const [],
                            arama: arama?.call(i < s.length ? s[i] : '') ?? const [])),
                      ],
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
