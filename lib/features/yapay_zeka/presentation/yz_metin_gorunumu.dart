import 'package:flutter/material.dart';

import '../../../core/utils/turkce_metin.dart';

import 'yz_tasarim.dart';

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
TextSpan yzSatirIci(String metin, TextStyle taban) {
  final parcalar = <InlineSpan>[];
  final desen = RegExp(r'\*\*(.+?)\*\*|\*(.+?)\*');
  var son = 0;
  for (final m in desen.allMatches(metin)) {
    if (m.start > son) {
      parcalar.add(TextSpan(text: metin.substring(son, m.start)));
    }
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
  if (son < metin.length) parcalar.add(TextSpan(text: metin.substring(son)));
  return TextSpan(style: taban, children: parcalar);
}

class YzMetinGorunumu extends StatelessWidget {
  const YzMetinGorunumu({super.key, required this.metin, required this.en});
  final String metin;

  /// Tablo başlıkları büyük harfle yazılıyor; Türkçede `i` → `İ` olmalı
  /// (`buyukHarf`), ham `toUpperCase()` "ŞIRKET", "ÜNIVERSITE" üretiyor.
  final bool en;

  @override
  Widget build(BuildContext context) {
    final bloklar = yzAyristir(metin);
    return LayoutBuilder(builder: (context, kis) {
      final dar = kis.maxWidth < 560;
      final govde = YzYazi.govde(boy: dar ? 17.5 : 18.5);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final b in bloklar)
            switch (b.tur) {
              YzBlokTuru.ozet => Padding(
                  padding: const EdgeInsets.only(bottom: 28),
                  child: Container(
                    padding: EdgeInsets.fromLTRB(dar ? 16 : 22, 18, dar ? 16 : 22, 18),
                    decoration: BoxDecoration(
                      color: YzRenk.bitkiAcik,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: YzRenk.bitki.withValues(alpha: 0.22)),
                    ),
                    child: SelectableText.rich(
                        yzSatirIci(b.metin, govde.copyWith(height: 1.55))),
                  ),
                ),
              YzBlokTuru.altBaslik => Padding(
                  padding: const EdgeInsets.only(top: 22, bottom: 12),
                  child: Semantics(
                    header: true,
                    child: Text(b.metin, style: YzYazi.baslik(dar ? 21 : 24)),
                  ),
                ),
              YzBlokTuru.paragraf => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: SelectableText.rich(yzSatirIci(b.metin, govde)),
                ),
              YzBlokTuru.tablo => Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 22),
                  child: dar ? _KartTablo(b.satirlar, en) : _GenisTablo(b.satirlar, en),
                ),
            },
        ],
      );
    });
  }
}

/// Geniş ekran: gerçek tablo. Başlık satırı künye yazısıyla, satırlar
/// saç çizgisiyle ayrılıyor.
class _GenisTablo extends StatelessWidget {
  const _GenisTablo(this.satirlar, this.en);
  final List<List<String>> satirlar;
  final bool en;

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
          for (final s in govde)
            TableRow(children: [
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
  const _KartTablo(this.satirlar, this.en);
  final List<List<String>> satirlar;
  final bool en;

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
        for (final s in satirlar.skip(1))
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
            decoration: BoxDecoration(
              color: YzRenk.yuzey,
              border: Border.all(color: YzRenk.cizgi),
              borderRadius: BorderRadius.circular(4),
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
