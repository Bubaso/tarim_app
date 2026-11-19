import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/yz_cekmeler.g.dart';
import 'yz_metin_gorunumu.dart';
import 'yz_sozluk_esle.dart';
import 'yz_tasarim.dart';

/// Öne çıkan cümle (pull quote, madde 6).
///
/// Metinde zaten geçen bir cümle, sayfanın ortasında büyük puntoyla bir kez
/// daha: göz gezdiren okura bir giriş noktası, uzun bölüme bir nefes. Yeni
/// metin yok; cümle `_raw/cekmeler.json`da, yeri metindeki
/// `[[cekme:<kimlik>]]` satırı (kurallar: dogrula_bolumler.py kural 16).
///
/// Çizim: Newsreader Regular; telefonda 23 px, masaüstünde 28 px, satır
/// yüksekliği 1,3; yazı boyuyla en çok ×1,15 büyür. Üstte kısa, ince bir
/// YATAY çizgi; üstte ve altta 48 px boşluk. Sol dikey çizgi, kutu, zemin,
/// tırnak, atıf ve etiket yok (kalıcı kural: paragrafın soluna dikey çizgi
/// yasak). Masaüstünde en çok [kYzCekmeGenisligi], metin sütununun içinde.
///
/// Rakamlar metindeki gibi: çelik mavisi ve dokununca kaynağın balonu
/// (bölümün satır içi çizicisi, [yzSatirIci]). Sözlük ve kısaltma işaretleri
/// alıntıda yok — paragrafın kendisinde var.
///
/// Ekran okuyucu cümleyi iki kez okumasın, sayfa seçiminde iki kez
/// kopyalanmasın: [ExcludeSemantics] ve [SelectionContainer.disabled].
/// Arama, okuma süresi, basılı sürüm ve ölçüm bu bloğu görmez (hepsi
/// paragrafları okuyor; `YzBlok.parcalar` burada boş).

/// Masaüstünde alıntının en geniş hâli.
const double kYzCekmeGenisligi = 560;

/// Üstteki ve alttaki boşluk.
const double kYzCekmeBoslugu = 48;

/// Yazı boyunun alıntıya etkisi en çok bu kadar.
const double kYzCekmeEnBuyukOlcek = 1.15;

/// Alıntının punto boyu: telefonda 23, masaüstünde 28 px; okurun yazı boyu
/// en çok ×1,15 yansıyor (satır sınırı bu etkin ölçekle sınanıyor).
double yzCekmeBoyu({required bool telefon, double olcek = 1.0}) =>
    (telefon ? 23.0 : 28.0) * math.min(olcek, kYzCekmeEnBuyukOlcek);

TextStyle yzCekmeStili({required bool telefon, double olcek = 1.0}) =>
    YzYazi.govde(boy: yzCekmeBoyu(telefon: telefon, olcek: olcek)).copyWith(height: 1.3);

/// [kimlik]in cümlesi, sayfanın paragraflarından birinde harfi harfine
/// geçiyorsa; yoksa null (kayıt ile metin ayrışmışsa hiçbir şey çizilmez).
String? yzCekmeCumlesi(String kimlik, List<YzBlok> bloklar, bool en) {
  final c = kYzCekmeler[kimlik]?.cumle(en);
  if (c == null || c.isEmpty) return null;
  for (final b in bloklar) {
    if (b.tur == YzBlokTuru.paragraf && b.metin.contains(c)) return c;
  }
  return null;
}

/// [kimlik]in öne çıkan cümlesi. [bloklar] sayfanın blokları (cümle
/// onlarda aranıyor), [genislik] metin sütunu, [oncekiAralik] önceki
/// paragrafın alt boşluğu (üstteki boşluk toplamda [kYzCekmeBoslugu]).
/// [etkilesim]in tanıyıcıları çizicinin listesine ekleniyor; çizici onları
/// metin değişince bırakıyor (çağıran önbellekli çizimden çağırmalı).
Widget yzCekme(String kimlik, List<YzBlok> bloklar,
    {required bool en,
    required bool telefon,
    required double genislik,
    double olcek = 1.0,
    YzEtkilesim? etkilesim,
    double oncekiAralik = 0}) {
  final cumle = yzCekmeCumlesi(kimlik, bloklar, en);
  if (cumle == null) return const SizedBox.shrink();
  final stil = yzCekmeStili(telefon: telefon, olcek: olcek);
  return Center(
    key: ValueKey('yz-cekme-$kimlik'),
    child: SizedBox(
      width: math.min(genislik, kYzCekmeGenisligi),
      child: Padding(
        padding: EdgeInsets.only(
            top: math.max(0, kYzCekmeBoslugu - oncekiAralik), bottom: kYzCekmeBoslugu),
        child: ExcludeSemantics(
          child: SelectionContainer.disabled(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Kısa, ince yatay çizgi (dikey çizgi değil).
                Container(width: 44, height: 2, color: YzRenk.bitki),
                const SizedBox(height: 18),
                Text.rich(yzSatirIci(cumle, stil, etkilesim: etkilesim)),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
