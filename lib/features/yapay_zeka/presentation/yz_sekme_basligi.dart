import '../data/yz_iskelet.g.dart';
import 'yz_yollar.dart';

/// Bölüm sayfasının sekmedeki adı — HAFİF dosya (ilk yükte; yalnız iskeleti
/// ve adresleri okur). Bölüm dışındaki adres için null: o sayfaların
/// başlığına dokunulmaz.
///
/// Yönlendirici düzeyinde çözülüyor, ekranlarda değil: ekranlar erteli
/// pakette ve paket inene kadar geçen sürede de sekme doğru adı taşımalı.
String? yzSekmeAdi(Uri adres, bool en) {
  if (!kYzOkuraAcik) return null;
  final yol = adres.path;
  final bolum = en ? kYzAdEn : kYzAdTr;
  if (yol == yzPath || yol == '$yzPath/') return bolum;
  if (!yol.startsWith('$yzPath/')) return null;
  final parca = yol.substring(yzPath.length + 1).split('/')
    ..removeWhere((p) => p.isEmpty);
  if (parca.length == 1 && '$yzPath/${parca[0]}' == yzAramaPath) {
    return en ? 'Search the section' : 'Bölümde ara';
  }
  if (parca.length == 1 && '$yzPath/${parca[0]}' == yzAtlasPath) {
    return en ? kYzAtlasAdEn : kYzAtlasAdTr;
  }
  if (parca.length == 2 && parca[0] == 'teknoloji') {
    return kYzTeknoloji[parca[1]]?[en ? 'en' : 'tr'] ?? bolum;
  }
  if (parca.length == 1) {
    for (final b in kYzBasliklar) {
      if (b.slug == parca[0]) return b.ad(en);
    }
    return bolum;
  }
  return null;
}
