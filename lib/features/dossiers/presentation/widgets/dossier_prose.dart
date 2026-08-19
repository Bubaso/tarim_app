import 'package:flutter/material.dart';

import '../../../../core/theme/app_typography.dart';
import '../../data/models/dossier_theme.dart';

/// Dosya gövdesini oluklayan Markdown **alt kümesi**.
///
/// Neden hazır bir paket değil: 13 bölümün tamamı sayıldığında gövdelerde
/// yalnızca dört yapı var — paragraf, `**kalın**`, `*italik*` ve boru işaretli
/// tablo. Liste yok, alıntı yok, bağlantı yok, kod yok, alt başlık yok.
/// `flutter_markdown` bakımdan düştü; ayrıca tabloları bu dosyanın koyu
/// paletiyle boyamak için yine baştan yazmak gerekirdi.
///
/// **Bilerek desteklenmeyen:** numaralı liste. Metinde satır kaydırması
/// yüzünden `1979. Yani bu bir zirve resmi değil…` gibi başlayan paragraflar
/// var; `^\d+\.` desenini liste sayan bir ayrıştırıcı bu cümleyi madde yapardı.
class DossierProse extends StatelessWidget {
  const DossierProse({
    super.key,
    required this.govde,
    required this.tema,
    this.olcek = 1.0,
  });

  final String govde;
  final DossierTheme tema;

  /// Kullanıcının yazı boyu tercihi. Yalnızca okunan metne uygulanır.
  final double olcek;

  @override
  Widget build(BuildContext context) {
    final bloklar = dossierBloklariniAyristir(govde);

    // İlk gerçek paragrafın indeksi: tablo veya ayırıcıyla başlayan
    // bölümlerde deck stili uygulanmaz.
    int? ilkParagrafIndeksi;
    for (var i = 0; i < bloklar.length; i++) {
      if (bloklar[i] is DosParagraf) {
        ilkParagrafIndeksi = i;
        break;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var idx = 0; idx < bloklar.length; idx++)
          Padding(
            // Öneri 2: Nefes boşlukları artırıldı. Paragraflar arası 18→24,
            // tablo altı 24→32.
            padding: EdgeInsets.only(
              bottom: bloklar[idx] is DosTablo ? 32 : 24,
            ),
            child: switch (bloklar[idx]) {
              // Öneri 3: ilk paragraf — deck stili. Okuyucuya bölüm özeti
              // sinyali verir; gözün giriş cümlesiyle ilişki kurması kolaylaşır.
              DosParagraf(:final metin) when idx == ilkParagrafIndeksi =>
                _IlkParagraf(metin: metin, tema: tema, olcek: olcek),
              DosParagraf(:final metin) => Text.rich(
                  TextSpan(
                    children: satirIciSpanlar(
                      metin,
                      AppTypography.body(
                        context,
                        color: tema.murekkep,
                        scale: olcek,
                      ),
                    ),
                  ),
                ),
              DosTablo() => _Tablo(
                  blok: bloklar[idx] as DosTablo,
                  tema: tema,
                  olcek: olcek,
                ),
              DosAyirici() => Center(
                  child: Container(
                    width: 64,
                    height: 1,
                    color: tema.cizgi,
                  ),
                ),
            },
          ),
      ],
    );
  }
}

/// İlk paragraf — bölümün giriş cümlesi.
///
/// Gövde metninden biraz büyük, hafif bold: "bu paragraf özetin kendisi,
/// devamı ayrıntı" sinyali verir. Yazı tipografisi değişmiyor, yalnızca
/// ağırlık ve boy farklı.
class _IlkParagraf extends StatelessWidget {
  const _IlkParagraf({
    required this.metin,
    required this.tema,
    required this.olcek,
  });

  final String metin;
  final DossierTheme tema;
  final double olcek;

  @override
  Widget build(BuildContext context) {
    final taban = AppTypography.body(context, color: tema.murekkep, scale: olcek);
    // Deck stili: 1 punto büyük, hafif artan satır yüksekliği.
    final deckStil = taban.copyWith(
      fontSize: (taban.fontSize ?? 17) + 1.0,
      height: 1.80,
      fontWeight: FontWeight.w500,
    );
    return Text.rich(
      TextSpan(children: satirIciSpanlar(metin, deckStil)),
    );
  }
}

// ─── Blok modeli ────────────────────────────────────────────────────────────

sealed class DossierBlok {
  const DossierBlok();
}

class DosParagraf extends DossierBlok {
  const DosParagraf(this.metin);
  final String metin;
}

class DosTablo extends DossierBlok {
  const DosTablo({required this.baslik, required this.satirlar});

  final List<String> baslik;
  final List<List<String>> satirlar;

  /// Bir sütun tamamen sayısalsa sağa yaslanır.
  ///
  /// Rakam sütununu sola yaslamak karşılaştırmayı zorlaştırır: basamaklar alt
  /// alta gelmez. Tespit harf aramasıyla yapılıyor — `%64,3` ve `~%88` sayısal,
  /// `3,9 milyar $` değil.
  bool sayisalMi(int sutun) {
    var dolu = false;
    for (final satir in satirlar) {
      if (sutun >= satir.length) continue;
      final h = satir[sutun].replaceAll('*', '').trim();
      if (h.isEmpty) continue;
      dolu = true;
      if (!_sayisal.hasMatch(h)) return false;
    }
    return dolu;
  }

  static final _sayisal = RegExp(r'^[^\p{L}]*\d[^\p{L}]*$', unicode: true);
}

class DosAyirici extends DossierBlok {
  const DosAyirici();
}

// ─── Ayrıştırıcı ────────────────────────────────────────────────────────────

/// Gövdeyi boş satırlarla bloklara böler.
///
/// Paragraf içindeki satır sonları **birleştirilir**: kaynak metin 80 sütuna
/// kaydırılmış ve `*italik*` işaretleri satır sonunu aşıyor. Satırlar tek tek
/// ayrıştırılsaydı bu vurgular bölünürdü.
List<DossierBlok> dossierBloklariniAyristir(String govde) {
  final bloklar = <DossierBlok>[];
  final paragraf = <String>[];
  final tablo = <String>[];

  void paragrafiKapat() {
    if (paragraf.isEmpty) return;
    bloklar.add(DosParagraf(paragraf.join(' ')));
    paragraf.clear();
  }

  void tabloyuKapat() {
    if (tablo.isEmpty) return;
    final ayrilmis = tablo.map(_hucreler).toList();
    // İkinci satır `|---|---|` ise gerçek tablo; değilse boru işareti metnin
    // içinde geçiyor demektir, paragraf olarak bırakılır.
    if (ayrilmis.length >= 2 && _ayiriciSatir(tablo[1])) {
      bloklar.add(DosTablo(
        baslik: ayrilmis.first,
        satirlar: ayrilmis.sublist(2),
      ));
    } else {
      bloklar.add(DosParagraf(tablo.join(' ')));
    }
    tablo.clear();
  }

  for (final ham in govde.split('\n')) {
    final satir = ham.trim();

    if (satir.isEmpty) {
      tabloyuKapat();
      paragrafiKapat();
      continue;
    }

    if (satir.startsWith('|')) {
      paragrafiKapat();
      tablo.add(satir);
      continue;
    }

    tabloyuKapat();

    if (RegExp(r'^(-{3,}|_{3,}|\*{3,})$').hasMatch(satir)) {
      paragrafiKapat();
      bloklar.add(const DosAyirici());
      continue;
    }

    paragraf.add(satir);
  }

  tabloyuKapat();
  paragrafiKapat();
  return bloklar;
}

bool _ayiriciSatir(String satir) =>
    RegExp(r'^\|[\s:|-]+\|$').hasMatch(satir.trim());

List<String> _hucreler(String satir) {
  var s = satir.trim();
  if (s.startsWith('|')) s = s.substring(1);
  if (s.endsWith('|')) s = s.substring(0, s.length - 1);
  return s.split('|').map((h) => h.trim()).toList();
}

/// `**kalın**` ve `*italik*` işaretlerini çözer.
///
/// Kalın metin renk almıyor, yalnızca ağırlık alıyor. Gövdede 96 kalın vurgu
/// var; hepsini sodyum turuncusuna boyamak sayfayı bağırtırdı. Turuncu,
/// rakamların ve bölüm numaralarının rengi olarak ayrılmış durumda.
List<InlineSpan> satirIciSpanlar(String metin, TextStyle taban) {
  final spanlar = <InlineSpan>[];
  final tampon = StringBuffer();
  var kalin = false;
  var italik = false;

  void bosalt() {
    if (tampon.isEmpty) return;
    spanlar.add(TextSpan(
      text: tampon.toString(),
      style: taban.copyWith(
        fontWeight: kalin ? FontWeight.w700 : null,
        fontStyle: italik ? FontStyle.italic : null,
      ),
    ));
    tampon.clear();
  }

  var i = 0;
  while (i < metin.length) {
    if (metin.startsWith('**', i)) {
      bosalt();
      kalin = !kalin;
      i += 2;
    } else if (metin[i] == '*') {
      bosalt();
      italik = !italik;
      i += 1;
    } else {
      tampon.write(metin[i]);
      i += 1;
    }
  }
  bosalt();

  return spanlar.isEmpty ? [TextSpan(text: '', style: taban)] : spanlar;
}

// ─── Tablo ──────────────────────────────────────────────────────────────────

class _Tablo extends StatelessWidget {
  const _Tablo({required this.blok, required this.tema, required this.olcek});

  final DosTablo blok;
  final DossierTheme tema;
  final double olcek;

  @override
  Widget build(BuildContext context) {
    final sutun = blok.baslik.length;
    final sagaYasli = [
      for (var i = 0; i < sutun; i++) blok.sayisalMi(i),
    ];

    // İlk sütun etiket, diğerleri değer. En uzun hücre 21 karakter; esnek
    // genişlikle telefonda da yatay kaydırma gerekmiyor.
    final genislikler = <int, TableColumnWidth>{
      for (var i = 0; i < sutun; i++)
        i: FlexColumnWidth(i == 0 ? 1.5 : 1.0),
    };

    final govdeStil = AppTypography.body(
      context,
      color: tema.murekkep,
      scale: olcek * 0.92,
    );

    // Öneri 4: Zebra zemin rengi. Çift/tek satırlar hafif renk farkıyla
    // ayrılır — gözün yatay takibi kolaylaşır. Fark bilinçli olarak çok hafif
    // (tema.yuzey ile çok yakın): arka plan sıfırdan farklı, ama dikkat çekmez.
    final zebraRenk = tema.cizgi.withValues(alpha: 0.25);

    return Container(
      decoration: BoxDecoration(
        color: tema.yuzey,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: tema.cizgi),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Table(
        columnWidths: genislikler,
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          TableRow(
            decoration: BoxDecoration(
              border: Border(
                // Başlık ile veriyi ayıran çizgi anlam taşıyor; dekoratif
                // `cizgi` (1,52:1) burada kullanılamaz.
                bottom: BorderSide(color: tema.cizgiVurgu),
              ),
            ),
            children: [
              for (var i = 0; i < sutun; i++)
                _hucre(
                  child: Text(
                    blok.baslik[i].replaceAll('*', '').toUpperCase(),
                    textAlign: sagaYasli[i] ? TextAlign.right : TextAlign.left,
                    style: AppTypography.meta(context, color: tema.sessiz)
                        .copyWith(letterSpacing: 0.6),
                  ),
                ),
            ],
          ),
          for (var s = 0; s < blok.satirlar.length; s++)
            TableRow(
              decoration: BoxDecoration(
                // Zebra: çift satırlar zemin, tek satırlar hafif zebraRenk.
                color: s.isOdd ? zebraRenk : null,
                border: s == blok.satirlar.length - 1
                    ? null
                    : Border(bottom: BorderSide(color: tema.cizgi)),
              ),
              children: [
                for (var i = 0; i < sutun; i++)
                  _hucre(
                    child: Text.rich(
                      TextSpan(
                        children: satirIciSpanlar(
                          i < blok.satirlar[s].length
                              ? blok.satirlar[s][i]
                              : '',
                          govdeStil,
                        ),
                      ),
                      textAlign:
                          sagaYasli[i] ? TextAlign.right : TextAlign.left,
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _hucre({required Widget child}) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
        child: child,
      );
}
