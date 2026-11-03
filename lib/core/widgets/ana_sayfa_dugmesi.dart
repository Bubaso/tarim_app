import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router/gezinti_derinligi.dart';

// ══════════════════════════════════════════════════════════════════════════
//  Ana sayfa düğmesi — geri tuşunun yanında, İKİNCİ basamaktan itibaren.
//
//  Neden eşik 2: ana sayfanın bir adım üstündeyken geri tuşu zaten ana
//  sayfaya götürüyor; orada ikinci bir düğme aynı işi iki kez sunmak olur.
//  İki adım ve ötesinde geri tuşu artık ana sayfaya GÖTÜRMÜYOR ve okurun
//  elinde başka yol kalmıyor — düğme tam orada gerekiyor.
//
//  Tasarım kuralı: eşiğin ALTINDA hiçbir şey değişmiyor. `leading` o zaman
//  ekranın kendi geri düğmesinin kendisi, `leadingWidth` da null (yani
//  Flutter'ın varsayılanı). Böylece bugün çalışan hiçbir ekranın yerleşimi
//  bir piksel oynamıyor.
// ══════════════════════════════════════════════════════════════════════════

/// Ana sayfa düğmesi bu sayfada görünmeli mi?
bool anaSayfaGorunurMu(BuildContext context) => gezintiDerinligi(context) >= 2;

/// `AppBar.leadingWidth` için.
///
/// Eşiğin altında **null** dönüyor — AppBar varsayılan 56 pikseli kullanıyor
/// ve başlık bugünkü yerinde kalıyor. Yalnızca düğme gerçekten çizildiğinde
/// genişliyor.
///
/// 100 piksel ölçülerek seçildi: iki `IconButton` 48'er piksel yer kaplıyor,
/// kalan 4 piksel soldaki kenar boşluğu. Daha geniş bir değer (eskiden 168
/// yazıyordu) dar ekranda başlığı sıkıştırıp taşma uyarısı üretiyordu.
double? anaSayfaLeadingGenisligi(BuildContext context) =>
    anaSayfaGorunurMu(context) ? 100 : null;

/// Ekranın kendi geri düğmesini alır, gerekiyorsa yanına ana sayfayı ekler.
///
/// Geri düğmesi DIŞARIDAN veriliyor, burada yeniden üretilmiyor: her ekranın
/// kendi ikonu, rengi ve boyutu var (`arrow_back_rounded`,
/// `arrow_back_ios_new_rounded`, dolgulu daire…). Tek tipe indirmek bu
/// ekranların görünümünü değiştirirdi — istenen şey bir düğme EKLEMEK.
Widget geriVeAnaSayfa(
  BuildContext context, {
  required Widget geri,
  required Color renk,
  double ikonBoyu = 21,
}) {
  if (!anaSayfaGorunurMu(context)) return geri;
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Flexible(child: geri),
      AnaSayfaIkonu(renk: renk, ikonBoyu: ikonBoyu),
    ],
  );
}

/// Düğmenin kendisi. Ayrı sınıf: haber detayı gibi `AppBar.leading`
/// kullanmayan, kendi satırını kuran ekranlar doğrudan bunu koyabiliyor.
class AnaSayfaIkonu extends StatelessWidget {
  final Color renk;
  final double ikonBoyu;

  /// Görünürlük denetimini ÇAĞIRAN yapıyorsa (kendi satırını kuran ekranlar
  /// koşulu dışarıda yazıyor) tekrar sınamaya gerek yok.
  final bool esigiSina;

  const AnaSayfaIkonu({
    super.key,
    required this.renk,
    this.ikonBoyu = 21,
    this.esigiSina = false,
  });

  @override
  Widget build(BuildContext context) {
    if (esigiSina && !anaSayfaGorunurMu(context)) return const SizedBox.shrink();
    return IconButton(
      // `go`, `push` DEĞİL: amaç yığının dibine dönmek. `push` olsaydı ana
      // sayfa yığının ÜSTÜNE binerdi ve geri tuşu okuru kaçtığı sayfaya
      // geri getirirdi.
      onPressed: () => GoRouter.of(context).go('/'),
      icon: Icon(Icons.home_rounded, size: ikonBoyu, color: renk),
      tooltip: 'Ana sayfa',
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
    );
  }
}

/// Kendi `leading`i olmayan, AppBar'ın otomatik geri düğmesini kullanan
/// ekranlar için hazır `leading`.
///
/// Eşiğin altında **null** dönüyor ve AppBar kendi otomatik düğmesini
/// çizmeye devam ediyor. Bu ayrıntı önemli: paylaşılan bir bağlantıyla
/// DOĞRUDAN açılan sayfada altta başka sayfa olmuyor ve Flutter geri
/// düğmesini kendiliğinden gizliyor. Koşulsuz bir `BackButton` koymak o
/// sayfaya hiçbir şey yapmayan bir ok çizerdi.
///
/// Eşiğin üstünde ise altta sayfa olduğu zaten kesin — derinlik 2 demek
/// yığında en az üç sayfa var demek.
Widget? anaSayfaliLeading(BuildContext context, {required Color renk}) {
  if (!anaSayfaGorunurMu(context)) return null;
  return geriVeAnaSayfa(
    context,
    geri: BackButton(color: renk),
    renk: renk,
  );
}
