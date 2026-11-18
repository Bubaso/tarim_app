import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/yz_kisaltmalar.g.dart';
import 'yz_tasarim.dart';

/// Kısaltma balonu (karar 60).
///
/// Okur her başlığa doğrudan gelebiliyor; az bilinen bir kısaltma (TAGEM,
/// ÇKS, CIMMYT…) bir sayfada ilk geçtiği yerde açılmıyorsa orada noktalı
/// alt çizgiyle işaretleniyor, dokununca açılımı çıkıyor. Kısaltma o yerde
/// zaten açılmışsa — "Tarım Sigortaları Havuzu (TARSİM)" ya da
/// "TAGEM (…)" — işaret yok. Kalın ve italik parçaların içi sayılmıyor.
/// Açılımlar `_raw/kisaltmalar.json`dan; doğrulayıcının kural 13'ü açılımsız
/// yeni bir kısaltmayı yakalıyor.

/// Kısaltmanın metindeki işareti ([bas, son) ham metinde).
class YzKisaltmaIsareti {
  const YzKisaltmaIsareti(this.bas, this.son, this.kisaltma);
  final int bas;
  final int son;
  final String kisaltma;
}

/// Büyük harfli sözcük: kelime sınırında, en az iki harf (rakam ve kısa çizgi
/// ortada olabilir: "COVID-19", "İMECE-2"). Python'daki karşılığı
/// dogrula_bolumler.py `KISALTMA_DESENI`.
final RegExp yzKisaltmaDeseni = RegExp(
    r'(?<![\p{L}\p{N}_])([A-ZÇĞİÖŞÜ][A-ZÇĞİÖŞÜ0-9-]*[A-ZÇĞİÖŞÜ0-9])(?![\p{L}\p{N}_])',
    unicode: true);
final RegExp _bicim = RegExp(r'\*\*(.+?)\*\*|\*(.+?)\*');
final RegExp _harf = RegExp(r'[A-ZÇĞİÖŞÜ]');
final RegExp _sonraAcilim = RegExp(r'^ \((?![^)]*\d)[^)]{6,}\)');

/// Kısaltma o geçişte açılmış mı: "(TAGEM)" ya da "TAGEM (uzun ad)".
bool yzKisaltmaAcilmis(String metin, int bas, int son) {
  final once = bas > 0 &&
      metin[bas - 1] == '(' &&
      son < metin.length &&
      (metin[son] == ')' || metin[son] == '-');
  return once || _sonraAcilim.hasMatch(metin.substring(son));
}

/// Bloktaki kısaltma işaretleri. [gorulen] sayfanın blokları boyunca
/// taşınır: bir kısaltma sayfada yalnız ilk geçtiği yerde sınanır. [dolu]:
/// başka bir işaretin (sözlük terimi, adres) kapladığı aralıklar.
List<YzKisaltmaIsareti> yzKisaltmalariBul(String metin, Set<String> gorulen,
    {List<(int, int)> dolu = const []}) {
  final bicimli = [for (final m in _bicim.allMatches(metin)) (m.start, m.end)];
  final cikti = <YzKisaltmaIsareti>[];
  for (final m in yzKisaltmaDeseni.allMatches(metin)) {
    final k = m.group(1)!;
    if (_harf.allMatches(k).length < 2) continue;
    if (gorulen.contains(k)) continue;
    if (bicimli.any((b) => m.start >= b.$1 && m.start < b.$2)) continue;
    gorulen.add(k);
    if (!kYzKisaltmalar.containsKey(k)) continue;
    if (dolu.any((d) => m.start < d.$2 && m.end > d.$1)) continue;
    if (yzKisaltmaAcilmis(metin, m.start, m.end)) continue;
    cikti.add(YzKisaltmaIsareti(m.start, m.end, k));
  }
  return cikti;
}

/// Dokunulan yerin altında (ekranın alt kısmındaysa üstünde) açılan küçük
/// kart; dışarı dokununca ya da Esc ile kapanıyor.
Future<void> yzKisaltmaBalonu(BuildContext context, String kisaltma, Offset konum, bool en) {
  final k = kYzKisaltmalar[kisaltma];
  if (k == null) return Future.value();
  return showDialog<void>(
    context: context,
    barrierColor: Colors.transparent,
    barrierDismissible: true,
    barrierLabel: en ? 'Close' : 'Kapat',
    useSafeArea: false,
    builder: (ctx) {
      final ekran = MediaQuery.sizeOf(ctx);
      final genislik = math.min(320.0, ekran.width - 24);
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
            label: kisaltma,
            child: Material(
              color: YzRenk.yuzey,
              elevation: 6,
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                decoration: BoxDecoration(
                  border: Border.all(color: YzRenk.cizgi),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(kisaltma, style: YzYazi.veri(boy: 13, renk: YzRenk.makine, kalinlik: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Text(k.acilim(en), style: YzYazi.govde(boy: 15.5).copyWith(height: 1.45)),
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
