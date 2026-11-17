import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/utils/turkce_metin.dart';
import '../data/yz_iskelet.g.dart';
import '../data/yz_sozluk.g.dart';

import 'yz_sozluk_esle.dart';
import 'yz_tasarim.dart';
import 'yz_teknoloji_izi.dart';

/// Bölüm metinlerinin çizicisi.
///
/// Dosya dizisinin çizicisi (`dossier_prose.dart`) yalnız paragraf, kalın,
/// italik ve tablo tanıyor; bu bölümün metinleri ayrıca `##` alt başlık ve
/// `>` özet bloğu kullanıyor (Tur 1 günlüğü, §5). Markdown'ın tamamı değil,
/// DAR BİR KESİT — metinlerin kullandığı kadarı ve fazlası değil:
///
///   `# N · Başlık`   atlanır (sayfa başlığı kendisi kuruyor)
///   `> …`            özet bloğu (ardışık satırlar tek blok)
///   `## …`           alt başlık
///   `| … |`          tablo (ikinci satır `|---|` ayıracı)
///   boş satır        paragraf sınırı
///   `**…**` `*…*`    kalın, italik
///
/// Tanınmayan biçim (liste, bağlantı) DÜZ METİN olarak çizilir — sessizce
/// yutulmaz. Metin dogrula_bolumler.py'den geçerek buraya geliyor.
enum YzBlokTuru { ozet, altBaslik, paragraf, tablo }

class YzBlok {
  const YzBlok(this.tur, {this.metin = '', this.satirlar = const []});
  final YzBlokTuru tur;
  final String metin;

  /// Tablo: ilk satır başlık, gerisi gövde. Ayıraç satırı yok.
  final List<List<String>> satirlar;
}

List<String> _hucreler(String satir) {
  var s = satir.trim();
  if (s.startsWith('|')) s = s.substring(1);
  if (s.endsWith('|')) s = s.substring(0, s.length - 1);
  return s.split('|').map((h) => h.trim()).toList();
}

bool _ayiracMi(String satir) =>
    RegExp(r'^\|?\s*:?-{3,}:?\s*(\|\s*:?-{3,}:?\s*)*\|?\s*$').hasMatch(satir.trim());

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
    } else if (t.startsWith('## ')) {
      paragrafiKapat();
      bloklar.add(YzBlok(YzBlokTuru.altBaslik, metin: t.substring(3).trim()));
      i++;
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

/// Satır içi biçim: `**kalın**`, `*italik*`. Rakam taşıyan kalın parça
/// "makinenin sesiyle" — eşit genişlikli, çelik mavisi — çiziliyor: metindeki
/// ölçülmüş sayılar böyle yazılıyor (bkz. §8, §23).
///
/// [etkilesim] verilirse düz metindeki adresler bağlantı (§30 kaynakça) ve
/// [isaretler]deki sözlük terimleri balon açan parça olur (karar 14).
TextSpan yzSatirIci(String metin, TextStyle taban,
    {YzEtkilesim? etkilesim, List<YzIsaret> isaretler = const []}) {
  final parcalar = <InlineSpan>[];
  final desen = RegExp(r'\*\*(.+?)\*\*|\*(.+?)\*');

  // Dokunulabilir aralıklar (ikisi de kalın/italik parçaların dışında).
  final etkin = <(int, int, Object)>[
    if (etkilesim != null) ...[
      for (final a in yzAdresler(metin)) (a.$1, a.$2, metin.substring(a.$1, a.$2)),
      for (final i in isaretler) (i.bas, i.son, i),
    ],
  ]..sort((a, b) => a.$1.compareTo(b.$1));

  void duz(int bas, int bitis) {
    var k = bas;
    for (final e in etkin) {
      if (e.$1 < k || e.$2 > bitis) continue;
      if (e.$1 > k) parcalar.add(TextSpan(text: metin.substring(k, e.$1)));
      final parca = metin.substring(e.$1, e.$2);
      final yuk = e.$3;
      if (yuk is YzIsaret) {
        final r = TapGestureRecognizer()
          ..onTapUp = (d) => etkilesim!.terimAc(yuk.terim, d.globalPosition);
        etkilesim!.tanicilar.add(r);
        parcalar.add(TextSpan(
          text: parca,
          recognizer: r,
          mouseCursor: SystemMouseCursors.click,
          style: const TextStyle(
            decoration: TextDecoration.underline,
            decorationStyle: TextDecorationStyle.dotted,
            decorationColor: YzRenk.makine,
            decorationThickness: 1.6,
          ),
        ));
      } else {
        final r = TapGestureRecognizer()..onTap = () => etkilesim!.baglantiAc(parca);
        etkilesim!.tanicilar.add(r);
        parcalar.add(TextSpan(
          text: parca,
          recognizer: r,
          mouseCursor: SystemMouseCursors.click,
          style: TextStyle(
            color: YzRenk.makine,
            decoration: TextDecoration.underline,
            decorationColor: YzRenk.makine.withValues(alpha: 0.5),
          ),
        ));
      }
      k = e.$2;
    }
    if (bitis > k) parcalar.add(TextSpan(text: metin.substring(k, bitis)));
  }

  var son = 0;
  for (final m in desen.allMatches(metin)) {
    if (m.start > son) duz(son, m.start);
    if (m.group(1) != null) {
      final ic = m.group(1)!;
      final rakamli = RegExp(r'\d').hasMatch(ic);
      parcalar.add(TextSpan(
        text: ic,
        style: rakamli
            ? YzYazi.veri(
                boy: (taban.fontSize ?? 18) * 0.86,
                renk: YzRenk.makine,
                kalinlik: FontWeight.w600,
              )
            : const TextStyle(fontWeight: FontWeight.w700),
      ));
    } else {
      parcalar.add(TextSpan(
          text: m.group(2), style: const TextStyle(fontStyle: FontStyle.italic)));
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

class YzMetinGorunumu extends StatefulWidget {
  const YzMetinGorunumu(
      {super.key,
      required this.metin,
      required this.en,
      this.sozluk = true,
      this.bolumNo,
      this.vurgu,
      this.vurguDenetcisi});
  final String metin;

  /// Merkez sayfada seçilen teknoloji (karar 57): geçtiği paragraflar ve
  /// tablo satırları işaretleniyor. Yoksa hiçbir şey işaretlenmiyor.
  final String? vurgu;
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

  @override
  State<YzMetinGorunumu> createState() => _YzMetinGorunumuState();
}

/// Dokunma tanıyıcıları her çizimde yeniden kurulmuyor: metin, dil ya da
/// ekran sınıfı (dar/geniş) değişmedikçe aynı bloklar kullanılıyor; tanıyıcılar
/// yalnız metin değişince ve bileşen kapanınca bırakılıyor — bir dokunuş
/// sürerken bırakılan tanıyıcı hata verirdi.
class _YzMetinGorunumuState extends State<YzMetinGorunumu> {
  final _tanicilar = <GestureRecognizer>[];
  final _onbellek = <bool, List<Widget>>{};
  late List<YzBlok> _bloklar;
  late List<List<YzIsaret>> _isaretler;
  // Karar 57: seçili teknolojinin geçtiği paragraflar ve tablo satırları.
  late List<bool> _vurguluParagraf;
  late List<Set<int>> _vurguluSatir;
  late List<GlobalKey?> _anahtar;

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
        eski.vurgu != widget.vurgu) {
      _birak();
      _hazirla();
    } else if (eski.vurguDenetcisi != widget.vurguDenetcisi) {
      widget.vurguDenetcisi?._kur([for (final a in _anahtar) if (a != null) a]);
    }
  }

  void _hazirla() {
    _bloklar = yzAyristir(widget.metin);
    // Bir terim sayfada bir kez: bloklar sırayla, aynı küme taşınarak.
    final gorulen = <String>{};
    final no = widget.bolumNo;
    final sozluk = no == null ? kYzSozluk : kYzSozluk.where((t) => t.baslikta(no)).toList();
    _isaretler = [
      for (final b in _bloklar)
        widget.sozluk && (b.tur == YzBlokTuru.ozet || b.tur == YzBlokTuru.paragraf)
            ? yzTerimleriBul(b.metin, widget.en, gorulen, sozluk: sozluk)
            : const <YzIsaret>[],
    ];
    final kod = yzTeknolojiVar(widget.vurgu) ? widget.vurgu! : null;
    _vurguluParagraf = [
      for (final b in _bloklar)
        kod != null &&
            (b.tur == YzBlokTuru.paragraf || b.tur == YzBlokTuru.ozet) &&
            yzTeknolojiGeciyor(b.metin, kod, widget.en),
    ];
    _vurguluSatir = [
      for (final b in _bloklar)
        kod != null && b.tur == YzBlokTuru.tablo
            ? {
                for (var r = 0; r < b.satirlar.length; r++)
                  if (yzTeknolojiGeciyor(yzTabloSatiri(b.satirlar[r]), kod, widget.en)) r,
              }
            : <int>{},
    ];
    _anahtar = [
      for (var i = 0; i < _bloklar.length; i++)
        _vurguluParagraf[i] || _vurguluSatir[i].isNotEmpty ? GlobalKey() : null,
    ];
    widget.vurguDenetcisi?._kur([for (final a in _anahtar) if (a != null) a]);
  }

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
      );

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, kis) {
      final dar = kis.maxWidth < 560;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _onbellek.putIfAbsent(dar, () => _ciz(dar)),
      );
    });
  }

  List<Widget> _ciz(bool dar) {
    final govde = YzYazi.govde(boy: dar ? 17.5 : 18.5);
    final etkilesim = _etkilesim;
    final en = widget.en;
    return [
      for (var i = 0; i < _bloklar.length; i++)
        switch (_bloklar[i].tur) {
          YzBlokTuru.ozet => Padding(
              padding: const EdgeInsets.only(bottom: 28),
              child: Container(
                padding: EdgeInsets.fromLTRB(dar ? 16 : 22, 18, dar ? 16 : 22, 18),
                decoration: BoxDecoration(
                  color: YzRenk.bitkiAcik,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: YzRenk.bitki.withValues(alpha: 0.22)),
                ),
                child: SelectableText.rich(yzSatirIci(
                    _bloklar[i].metin, govde.copyWith(height: 1.55),
                    etkilesim: etkilesim, isaretler: _isaretler[i])),
              ),
            ),
          YzBlokTuru.altBaslik => Padding(
              padding: const EdgeInsets.only(top: 22, bottom: 12),
              child: Semantics(
                header: true,
                child: Text(_bloklar[i].metin, style: YzYazi.baslik(dar ? 21 : 24)),
              ),
            ),
          YzBlokTuru.paragraf => _vurguluParagraf[i]
              ? Container(
                  key: _anahtar[i],
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
                  decoration: const BoxDecoration(
                    color: YzRenk.makineAcik,
                    border: Border(left: BorderSide(color: YzRenk.makine, width: 3)),
                  ),
                  child: SelectableText.rich(yzSatirIci(_bloklar[i].metin, govde,
                      etkilesim: etkilesim, isaretler: _isaretler[i])),
                )
              : Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: SelectableText.rich(yzSatirIci(_bloklar[i].metin, govde,
                      etkilesim: etkilesim, isaretler: _isaretler[i])),
                ),
          YzBlokTuru.tablo => Padding(
              key: _anahtar[i],
              padding: const EdgeInsets.only(top: 4, bottom: 22),
              child: dar
                  ? _KartTablo(_bloklar[i].satirlar, en, vurgulu: _vurguluSatir[i])
                  : _GenisTablo(_bloklar[i].satirlar, en, vurgulu: _vurguluSatir[i]),
            ),
        },
    ];
  }
}

/// Geniş ekran: gerçek tablo. Başlık satırı künye yazısıyla, satırlar
/// saç çizgisiyle ayrılıyor.
class _GenisTablo extends StatelessWidget {
  const _GenisTablo(this.satirlar, this.en, {this.vurgulu = const {}});
  final List<List<String>> satirlar;
  final bool en;

  /// Seçili teknolojinin geçtiği satırlar (satirlar içindeki sıra; 0 başlık).
  final Set<int> vurgulu;

  @override
  Widget build(BuildContext context) {
    if (satirlar.isEmpty) return const SizedBox.shrink();
    final baslik = satirlar.first;
    final govde = satirlar.skip(1).toList();
    final hucre = YzYazi.govde(boy: 15.5).copyWith(height: 1.45);
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
  const _KartTablo(this.satirlar, this.en, {this.vurgulu = const {}});
  final List<List<String>> satirlar;
  final bool en;
  final Set<int> vurgulu;

  @override
  Widget build(BuildContext context) {
    if (satirlar.isEmpty) return const SizedBox.shrink();
    final baslik = satirlar.first;
    final hucre = YzYazi.govde(boy: 15.5).copyWith(height: 1.45);
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
              border: vurgulu.contains(r + 1)
                  ? const Border(
                      left: BorderSide(color: YzRenk.makine, width: 3),
                      top: BorderSide(color: YzRenk.cizgi),
                      right: BorderSide(color: YzRenk.cizgi),
                      bottom: BorderSide(color: YzRenk.cizgi))
                  : Border.all(color: YzRenk.cizgi),
              borderRadius: vurgulu.contains(r + 1) ? null : BorderRadius.circular(4),
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
                        SelectableText.rich(
                            yzSatirIci(i < s.length ? s[i] : '', hucre)),
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
