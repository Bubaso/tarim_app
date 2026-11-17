import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/turkce_metin.dart';
import '../data/yz_sozluk.g.dart';
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

final RegExp _harfVeRakam = RegExp(r'[\p{L}\p{N}]', unicode: true);
final RegExp _bicim = RegExp(r'\*\*(.+?)\*\*|\*(.+?)\*');

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

/// [metin]de, [gorulen]de olmayan her terimin ilk geçişi. Bulunan terim
/// [gorulen]e eklenir; sayfa boyunca aynı küme taşınır.
///
/// Küçük harfli desen kelime başında aranır ve kelimenin sonuna kadar uzanır
/// ("makine öğrenmesiyle" bütünüyle işaretlenir). `=` ile başlayan desen
/// büyük-küçük harfe duyarlı ve tam kelimedir; kesme işaretinden sonraki ek
/// kelimenin parçası sayılmaz ("İHA'ya").
List<YzIsaret> yzTerimleriBul(String metin, bool en, Set<String> gorulen,
    {List<YzTerim> sozluk = kYzSozluk}) {
  if (sozluk.isEmpty || metin.isEmpty) return const [];
  final kucuk = kucukHarf(metin, en);
  if (kucuk.length != metin.length) return const [];
  final yasak = <(int, int)>[
    for (final m in _bicim.allMatches(metin)) (m.start, m.end),
    ...yzAdresler(metin),
  ];
  final isaretler = <YzIsaret>[];
  bool cakisir(int b, int s) =>
      yasak.any((y) => b < y.$2 && s > y.$1) ||
      isaretler.any((x) => b < x.son && s > x.bas);

  // Uzun desen önce: "büyük dil modeli" "dil modeli"nden önce yakalansın.
  final sirali = [...sozluk]
    ..sort((a, b) => _enUzunDesen(b, en).compareTo(_enUzunDesen(a, en)));
  for (final t in sirali) {
    if (gorulen.contains(t.kimlik)) continue;
    bulundu:
    for (final d in t.desen(en)) {
      final tam = d.startsWith('=');
      final aranan = tam ? d.substring(1) : d;
      final kaynak = tam ? metin : kucuk;
      if (aranan.isEmpty) continue;
      var i = kaynak.indexOf(aranan);
      while (i >= 0) {
        var j = i + aranan.length;
        final solSinir = !_harfMi(kaynak, i - 1);
        final sagSinir = !tam || !_harfMi(kaynak, j);
        if (solSinir && sagSinir) {
          if (!tam) {
            while (_harfMi(kaynak, j)) {
              j++;
            }
          }
          if (!cakisir(i, j)) {
            isaretler.add(YzIsaret(i, j, t));
            gorulen.add(t.kimlik);
            break bulundu;
          }
        }
        i = kaynak.indexOf(aranan, i + 1);
      }
    }
  }
  isaretler.sort((a, b) => a.bas.compareTo(b.bas));
  return isaretler;
}

/// Satır içi çizimde dokunulabilir parçaların bağlamı. Tanıyıcılar burada
/// toplanıyor; çizen bileşen kendini atarken hepsini bırakıyor.
class YzEtkilesim {
  YzEtkilesim({required this.tanicilar, required this.baglantiAc, required this.terimAc});
  final List<GestureRecognizer> tanicilar;
  final void Function(String adres) baglantiAc;
  final void Function(YzTerim terim, Offset konum) terimAc;
}

/// Terimin balonu: dokunulan yerin altında (ekranın alt kısmındaysa üstünde)
/// açılan küçük kart. Dışarı dokununca ya da Esc ile kapanıyor.
Future<void> yzTerimBalonu(BuildContext context, YzTerim terim, Offset konum, bool en) {
  final yonlendirici = GoRouter.maybeOf(context);
  return showDialog<void>(
    context: context,
    barrierColor: Colors.transparent,
    barrierDismissible: true,
    barrierLabel: en ? 'Close' : 'Kapat',
    useSafeArea: false,
    builder: (ctx) {
      final ekran = MediaQuery.sizeOf(ctx);
      final genislik = math.min(340.0, ekran.width - 24);
      final sol = (konum.dx - genislik / 2)
          .clamp(12.0, math.max(12.0, ekran.width - genislik - 12))
          .toDouble();
      final ustte = konum.dy > ekran.height * 0.62;
      return Stack(children: [
        Positioned(
          left: sol,
          width: genislik,
          top: ustte ? null : konum.dy + 16,
          bottom: ustte ? ekran.height - konum.dy + 16 : null,
          child: Semantics(
            container: true,
            label: terim.ad(en),
            child: Material(
              color: YzRenk.yuzey,
              elevation: 6,
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                decoration: BoxDecoration(
                  border: Border.all(color: YzRenk.cizgi),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(terim.ad(en), style: YzYazi.baslik(17)),
                    const SizedBox(height: 6),
                    Text(terim.tanim(en),
                        style: YzYazi.govde(boy: 15.5).copyWith(height: 1.45)),
                    const SizedBox(height: 8),
                    Text(terim.kaynak(en), style: YzYazi.veri(boy: 11.5, renk: YzRenk.soluk)),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          yonlendirici?.push(yzBaslikPath('sozluk'));
                        },
                        child: Text(en ? 'Open the glossary' : 'Sözlükte aç'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ]);
    },
  );
}
