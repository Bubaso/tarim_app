import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/turkce_metin.dart';
import '../../home/data/models/news_article.dart';
import '../data/yz_atlas.g.dart';
import '../data/yz_deposu.dart';
import '../yz_providers.dart';

/// Türkiye Dijital Tarım Atlası — veri (atlas turu, 25 Kasım 2026).
///
/// Üç tür kayıt, hepsi kaynaklı:
///   * Dosyada — başlık metinlerinde ilin adı geçen cümle (`yz_atlas.g.dart`,
///     `_raw/atlas_uret.py` çıkarıyor);
///   * Türkiye dizininde — §25 tablosunun satırı (aynı dosya);
///   * Haberlerde — ÇALIŞMA ANINDA: bölümün okura açık etiketli haberleri,
///     başlığında ya da özetinde ilin adı geçenler.
///
/// ERTELİ pakette: yalnız atlas ekranı ve merkez kartı içe aktarıyor.

/// Atlasın taradığı haber sayısı üst sınırı (merkez sayfa 24 alıyor).
const int kYzAtlasHaberSiniri = 200;

/// Bölümün okura açık haberleri, en yeni önce. Okur RLS'i yalnız yayındaki
/// haberi ve aktif etiketi veriyor; depo hatayı yutuyor, 8 sn'de vazgeçiyor.
/// Yüklenirken ya da hata olunca "Haberlerde" sessizce boş: sayfa haberden
/// bağımsız çalışıyor.
final yzAtlasHaberleriProvider = FutureProvider<List<YzHaber>>(
    (ref) => ref.read(yzDeposuProvider).bolumHaberleri(limit: kYzAtlasHaberSiniri));

// ── İl adı ───────────────────────────────────────────────────────────────

/// Metinde geçen bir il: plaka ve ADIN metindeki yeri (ek dahil değil).
class YzAtlasEslesme {
  const YzAtlasEslesme(this.plaka, this.bas, this.son);
  final int plaka;
  final int bas;
  final int son;
}

// Python'daki `\w` (Unicode harf, rakam, alt çizgi): ad sözcük başında
// başlıyor ve sözcük sonunda (ekiyle) bitiyor.
const String _harf = r'[\p{L}\p{N}_]';
final Map<bool, RegExp> _desenler = {};

RegExp _desen(bool en) => _desenler.putIfAbsent(en, () {
      final adlar = (en ? kYzAtlasAdlarEn : kYzAtlasAdlarTr).keys.toList()
        ..sort((a, b) => b.length.compareTo(a.length));
      // Türkçe: kesmeyle ek ("Antalya'da") ya da kesmesiz -lı/-li/-lu/-lü
      // ("Antalyalı"; "-lık" değil: "Aydınlık" Aydın değil). İngilizce: "'s".
      final ek = en ? "(?:['’]s)?" : "(?:['’]$_harf+|l[ıiuü](?![kğ])$_harf*)?";
      return RegExp('(?<!$_harf)(${adlar.map(RegExp.escape).join('|')})$ek(?!$_harf)', unicode: true);
    });

/// Metinde geçen iller — `atlas_uret.py › il_bul`un eşi (eşlik testi
/// test/yz_atlas_test.dart'ta). Ad büyük harfle başlıyor ve harfi harfine
/// aranıyor: "ordu" ya da "duruyordu" Ordu değil. İl adıyla başlayan ama il
/// olmayan sözler (`kYzAtlasDislama`: "Van der Velde") sayılmıyor.
List<YzAtlasEslesme> yzAtlasIlleri(String metin, {bool en = false}) {
  final adlar = en ? kYzAtlasAdlarEn : kYzAtlasAdlarTr;
  return [
    for (final m in _desen(en).allMatches(metin))
      if (!kYzAtlasDislama.any((s) => metin.startsWith(s, m.start)))
        YzAtlasEslesme(adlar[m.group(1)]!, m.start, m.start + m.group(1)!.length),
  ];
}

/// Bir ilin adının metindeki yerleri (fosforlu kalem için).
List<(int, int)> yzAtlasIlAraliklari(String metin, int plaka, {bool en = false}) => [
      for (final e in yzAtlasIlleri(metin, en: en))
        if (e.plaka == plaka) (e.bas, e.son),
    ];

/// Verilen yazılışların metindeki ilk yerleri (dizin satırını ile bağlayan
/// kurum: "Selçuk", "İzmir").
List<(int, int)> yzAtlasVurguAraliklari(String metin, List<String> vurgular) => [
      for (final v in vurgular)
        if (v.isNotEmpty && metin.contains(v)) (metin.indexOf(v), metin.indexOf(v) + v.length),
    ];

/// Haberin geçtiği iller: yalnız Türkçe BAŞLIĞINDA ve ÖZETİNDE (summary).
/// Haber metninin tamamı taranmıyor: künyede ve gövdede geçen il, haberin
/// konusu olmayabilir.
Set<int> yzAtlasHaberIlleri(NewsArticle haber) => {
      for (final e in yzAtlasIlleri('${haber.title}\n${haber.summary ?? ''}')) e.plaka,
    };

// ── Kayıtlar ─────────────────────────────────────────────────────────────

/// Bir ilin kayıtları, okurun dilinde.
class YzAtlasIlKayitlari {
  YzAtlasIlKayitlari(this.il);
  final YzAtlasIl il;
  final List<YzAtlasDosyaKaydi> dosya = [];
  final List<YzAtlasDizinKaydi> dizin = [];
  final List<YzHaber> haber = [];

  int get sayi => dosya.length + dizin.length + haber.length;
}

YzAtlasIl? yzAtlasIl(int plaka) =>
    plaka >= 1 && plaka <= kYzAtlasIller.length ? kYzAtlasIller[plaka - 1] : null;

/// Plaka → kayıtlar; yalnız kaydı olan iller. İngilizcede İngilizce cümlesi
/// bulunamamış dosya kaydı yok.
Map<int, YzAtlasIlKayitlari> yzAtlasKayitlari({required bool en, List<YzHaber> haberler = const []}) {
  final m = <int, YzAtlasIlKayitlari>{};
  YzAtlasIlKayitlari al(int p) => m.putIfAbsent(p, () => YzAtlasIlKayitlari(yzAtlasIl(p)!));
  for (final r in kYzAtlasDosya) {
    if (en && r.en == null) continue;
    al(r.il).dosya.add(r);
  }
  for (final r in kYzAtlasDizin) {
    al(r.il).dizin.add(r);
  }
  for (final h in haberler) {
    for (final p in yzAtlasHaberIlleri(h.haber)) {
      al(p).haber.add(h);
    }
  }
  return m;
}

const String _alfabe = 'abcçdefgğhıijklmnoöprsştuüvyz';

/// Türkçe alfabe sırası (ç c'den, ı i'den önce): il listeleri için.
int yzAtlasAdSirasi(String a, String b) {
  final x = kucukHarf(a, false), y = kucukHarf(b, false);
  for (var i = 0; i < x.length && i < y.length; i++) {
    final p = _alfabe.indexOf(x[i]), q = _alfabe.indexOf(y[i]);
    final fark = (p < 0 ? 100 + x.codeUnitAt(i) : p) - (q < 0 ? 100 + y.codeUnitAt(i) : q);
    if (fark != 0) return fark;
  }
  return x.length - y.length;
}

/// Kaydı olan iller: en çok kaydı olan önce, eşitlikte alfabe sırası.
List<YzAtlasIlKayitlari> yzAtlasSirali(Map<int, YzAtlasIlKayitlari> kayitlar) =>
    kayitlar.values.toList()
      ..sort((a, b) => a.sayi != b.sayi ? b.sayi - a.sayi : yzAtlasAdSirasi(a.il.ad, b.il.ad));
