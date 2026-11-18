import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/turkce_metin.dart';
import '../data/yz_sozluk.g.dart';
import 'yz_balon_kabugu.dart';
import 'yz_okuma.dart';
import 'yz_parcalar.dart';
import 'yz_tasarim.dart';

/// Sözlük terimlerinin metin içi balonu (karar 14) ve metindeki adresler.
///
/// Bir terim bir sayfada YALNIZ İLK GEÇTİĞİ YERDE işaretlenir: okuru her
/// "yapay zekâ"da bir altı çizili kelimeyle yormamak için. Kalın ve italik
/// parçaların (ölçülmüş sayılar, kapanış cümlesi) ve adreslerin içi
/// işaretlenmez.

/// Metinde işaretlenen bir aralık (ham metindeki konum, [bas, son)).
class YzIsaret {
  const YzIsaret(this.bas, this.son, this.terim);
  final int bas;
  final int son;
  final YzTerim terim;
}

/// Terim balonunun açılmadığı başlıklar: sözlüğün kendisi ve kaynakça
/// (sozluk_uret.py'deki `SOZLUKSUZ` ile aynı).
const Set<int> kYzSozluksuzBasliklar = {29, 30};

final RegExp _harfVeRakam = RegExp(r'[\p{L}\p{N}]', unicode: true);
final RegExp _bicim = RegExp(r'\*\*(.+?)\*\*|\*(.+?)\*');
final RegExp _tirnak = RegExp(r'"[^"]*"|“[^”]*”');

/// Metindeki adres. Sondaki noktalama ve kapanmamış parantez adrese dahil
/// değil: "(liste sayfası: https://a.b/c)." içinden "https://a.b/c" çıkar.
final RegExp yzAdresDeseni = RegExp(r'https?://[^\s<>"]+');

String yzAdresiKirp(String a) {
  var s = a;
  while (s.isNotEmpty) {
    final son = s[s.length - 1];
    if ('.,;:!?'.contains(son)) {
      s = s.substring(0, s.length - 1);
    } else if (son == ')' && '('.allMatches(s).length < ')'.allMatches(s).length) {
      s = s.substring(0, s.length - 1);
    } else {
      break;
    }
  }
  return s;
}

/// Metindeki adreslerin [bas, son) aralıkları (kalın ve italik dışında).
List<(int, int)> yzAdresler(String metin) {
  final bicimli = [for (final m in _bicim.allMatches(metin)) (m.start, m.end)];
  final cikti = <(int, int)>[];
  for (final m in yzAdresDeseni.allMatches(metin)) {
    final son = m.start + yzAdresiKirp(m.group(0)!).length;
    if (bicimli.any((b) => m.start < b.$2 && son > b.$1)) continue;
    cikti.add((m.start, son));
  }
  return cikti;
}

int _enUzunDesen(YzTerim t, bool en) =>
    t.desen(en).fold(0, (a, d) => math.max(a, d.length));

bool _harfMi(String metin, int i) =>
    i >= 0 && i < metin.length && _harfVeRakam.hasMatch(metin[i]);

/// Uzunluğu koruyan küçültme (sozluk_uret.py'deki `kucult` ile aynı).
/// İngilizce metinde de "İMECE" gibi özel adlar var: İ önce i'ye iner, yoksa
/// `toLowerCase()` onu iki karaktere açar ve konumlar kayar.
String _kucult(String s, bool en) =>
    en ? s.replaceAll('İ', 'i').toLowerCase() : kucukHarf(s, false);

/// Önceki anlamlı karakter cümle sonu mu (ya da blok başı): "**Özet.** Yapay"
/// ve "(§7). Makine" cümle başı; "Türkiye Yapay Zekâ Eylem Planı" değil.
/// sozluk_uret.py'deki `_cumle_basi` ile aynı.
bool _cumleBasi(String metin, int i) {
  var k = i - 1;
  while (k >= 0 && (metin[k].trim().isEmpty || '*"”’)'.contains(metin[k]))) {
    k--;
  }
  return k < 0 || '.!?'.contains(metin[k]);
}

bool _ortusur(List<(int, int)> araliklar, int b, int s) =>
    araliklar.any((y) => b < y.$2 && s > y.$1);

/// [metin]de, [gorulen]de olmayan her terimin ilk geçişi. Bulunan terim
/// [gorulen]e eklenir; sayfa boyunca aynı küme taşınır.
///
/// Küçük harfli desen kelime başında aranır ve kelimenin sonuna kadar uzanır
/// ("makine öğrenmesiyle" bütünüyle işaretlenir). `=` ile başlayan desen
/// büyük-küçük harfe duyarlı ve tam kelimedir; kesme işaretinden sonraki ek
/// kelimenin parçası sayılmaz ("İHA'ya").
///
/// Terimler uzun desenliden kısaya taranır ve her terimin BÜTÜN geçişleri
/// sonrakilere gölge olur: "iklim akıllı tarım"ın içindeki "akıllı tarım",
/// "sohbet robotu"nun içindeki "robot" ayrıca işaretlenmez — iklim terimi o
/// sayfada önceden işaretlenmiş olsa bile. Tırnak içi (birebir alıntı)
/// işaretlenmez; cümle ortasında büyük harfle başlayan geçiş bir özel adın
/// parçasıdır ("UCI Machine Learning Repository") ve sayılmaz.
///
/// sozluk_uret.py'deki `terimleri_bul` bunun birebir karşılığı; §29'daki
/// "Geçtiği başlıklar" onunla yazılıyor (test/yz_bolum_test.dart sınıyor).
List<YzIsaret> yzTerimleriBul(String metin, bool en, Set<String> gorulen,
    {List<YzTerim> sozluk = kYzSozluk}) {
  if (sozluk.isEmpty || metin.isEmpty) return const [];
  final kucuk = _kucult(metin, en);
  if (kucuk.length != metin.length) return const [];
  final yasak = <(int, int)>[
    for (final m in _bicim.allMatches(metin)) (m.start, m.end),
    for (final m in _tirnak.allMatches(metin)) (m.start, m.end),
    ...yzAdresler(metin),
  ];
  final isaretler = <YzIsaret>[];
  final golge = <(int, int)>[];

  // Uzun desen önce: "büyük dil modeli" "dil modeli"nden önce yakalansın.
  // Eşit uzunlukta sözlük sırası: List.sort kararlı değil, sozluk_uret.py
  // ise bu sırayla "Geçtiği başlıklar"ı yazıyor.
  final sira = {for (var k = 0; k < sozluk.length; k++) sozluk[k].kimlik: k};
  final sirali = [...sozluk]
    ..sort((a, b) {
      final f = _enUzunDesen(b, en).compareTo(_enUzunDesen(a, en));
      return f != 0 ? f : sira[a.kimlik]!.compareTo(sira[b.kimlik]!);
    });
  for (final t in sirali) {
    final goruldu = gorulen.contains(t.kimlik);
    YzIsaret? bulunan;
    final yeni = <(int, int)>[];
    for (final d in t.desen(en)) {
      final tam = d.startsWith('=');
      final aranan = tam ? d.substring(1) : d;
      final kaynak = tam ? metin : kucuk;
      if (aranan.isEmpty) continue;
      var i = kaynak.indexOf(aranan);
      while (i >= 0) {
        var j = i + aranan.length;
        if (!_harfMi(kaynak, i - 1) && (!tam || !_harfMi(kaynak, j))) {
          if (!tam) {
            while (_harfMi(kaynak, j)) {
              j++;
            }
          }
          final ad = !tam && metin[i] != kucuk[i] && !_cumleBasi(metin, i);
          if (!ad && !_ortusur(yasak, i, j)) {
            if (!goruldu && bulunan == null && !_ortusur(golge, i, j)) {
              bulunan = YzIsaret(i, j, t);
            }
            yeni.add((i, j));
          }
        }
        i = kaynak.indexOf(aranan, i + 1);
      }
    }
    if (bulunan != null) {
      isaretler.add(bulunan);
      gorulen.add(t.kimlik);
    }
    golge.addAll(yeni);
  }
  isaretler.sort((a, b) => a.bas.compareTo(b.bas));
  return isaretler;
}

/// Satır içi çizimde dokunulabilir parçaların bağlamı. Tanıyıcılar burada
/// toplanıyor; çizen bileşen kendini atarken hepsini bırakıyor.
class YzEtkilesim {
  YzEtkilesim(
      {required this.tanicilar,
      required this.baglantiAc,
      required this.terimAc,
      this.rakamVar,
      this.rakamAc,
      this.kisaltmaAc});
  final List<GestureRecognizer> tanicilar;
  final void Function(String adres) baglantiAc;
  final void Function(YzTerim terim, Offset konum) terimAc;

  /// Rakamdan kaynağa (karar 58): kalın rakamın bağlı bir kaynağı var mı ve
  /// dokununca balonu açan.
  final bool Function(String kalin)? rakamVar;
  final void Function(String kalin, Offset konum)? rakamAc;

  /// Kısaltma balonu (karar 60).
  final void Function(String kisaltma, Offset konum)? kisaltmaAc;
}

/// Terimin balonu: dokunulan yerin altında (ekranın alt kısmındaysa üstünde)
/// açılan küçük kart. Dışarı dokununca ya da Esc ile kapanıyor. Telefonda
/// aynı içerik alttan açılan sayfada (yz_balon_kabugu.dart).
/// [geri]: balonun açıldığı başlığın adresi. "Sözlükte aç" sözlüğe `go` ile
/// gidiyor — webde adres çubuğu da değişsin, tarayıcının geri tuşu başlığa
/// dönsün — ve `?geri=` ile sözlük sayfasının geri okunu o başlığa bağlıyor.
/// Sözlük `?terim=` ile o terimin üstünde, işaretli açılıyor; başlığın
/// kaydırma konumu saklanıyor, okur dönünce kaldığı paragraftan devam ediyor
/// (karar 60).
Future<void> yzTerimBalonu(BuildContext context, YzTerim terim, Offset konum, bool en,
    {String? geri}) {
  final yonlendirici = GoRouter.maybeOf(context);
  return yzBalonAc(
    context,
    konum: konum,
    en: en,
    etiket: terim.ad(en),
    genislik: 340,
    ustteOrani: 0.62,
    dolgu: const EdgeInsets.fromLTRB(16, 14, 16, 6),
    icerik: (ctx, telefon) {
      void sozluguAc() {
        // Okur dönünce başlık kaldığı yerden açılsın (karar 60).
        final konum = Scrollable.maybeOf(context)?.position.pixels;
        if (geri != null && konum != null) YzOkumaKonumu.kaydet(geri, konum);
        Navigator.of(ctx).pop();
        yonlendirici?.go(Uri(
          path: yzBaslikPath('sozluk'),
          queryParameters: {'terim': terim.kimlik, if (geri != null) 'geri': geri},
        ).toString());
      }

      final eylem = en ? 'Open the glossary' : 'Sözlükte aç';
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(terim.ad(en), style: YzYazi.baslik(telefon ? 18 : 17)),
          SizedBox(height: telefon ? 8 : 6),
          Text(terim.tanim(en),
              style: YzYazi.govde(boy: telefon ? 16.5 : 15.5).copyWith(height: 1.45)),
          SizedBox(height: telefon ? 10 : 8),
          Text(terim.kaynak(en),
              style: YzYazi.veri(boy: telefon ? 12 : 11.5, renk: YzRenk.soluk)),
          if (telefon) ...[
            const SizedBox(height: 14),
            YzBalonEylemi(yazi: eylem, onPressed: sozluguAc),
          ] else
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(onPressed: sozluguAc, child: Text(eylem)),
            ),
        ],
      );
    },
  );
}
