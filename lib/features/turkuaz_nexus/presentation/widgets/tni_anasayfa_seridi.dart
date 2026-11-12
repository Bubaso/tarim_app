import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/utils/image_fallback_helper.dart';
import '../../data/tni_veri.g.dart';
import '../tni_tasarim.dart';
import 'tni_gorsel.dart';
import 'tni_parcalar.dart';

/// Anasayfadaki Turkuaz Bağlantısallık Girişimi şeridi.
///
/// KART DEĞİL ŞERİT. Önce anasayfanın öteki kartları gibi bir kutuydu ve açık
/// modda sayfanın kremine karışıyordu: kendi zemini (#F0F5F4) ile anasayfanın
/// kremi (#F6F1E7) birbirine fazla yakın. Şerit bunu kökünden çözüyor —
/// fotoğraf zemin oluyor, kutu koyuluyor ve iki temada da sayfanın geri
/// kalanından ayrışıyor.
///
/// ALÇAK VE GENİŞ. Haber akışının ortasında duruyor; yüksek bir blok okuma
/// sırasını kesip "reklam" gibi görünürdü. Genişlik iki yana dayanıyor,
/// yükseklik üç satırı zor geçiyor.
///
/// FOTOĞRAF GİRİŞİMİN İŞİ DEĞİL. Girişimin henüz hiçbir projesi yok; baraj
/// karesi onun yaptığı bir şeyi değil, konuştuğu şeyin ölçeğini gösteriyor.
/// Şeritte bunu yazacak yer olmadığı için karenin künyesi sağ alta konuyor:
/// adı ve çekeni görünen bir fotoğraf, "bu onların işi" diye okunmaz. Sayfanın
/// içinde aynı karenin altında bu ayrım cümleyle de yazılı.
class TniAnasayfaSeridi extends StatelessWidget {
  /// `isDark` ALINMIYOR — bilerek. Şerit her iki temada da koyu: zemini bir
  /// fotoğraf ve onun üstündeki perde. Açık moda uyan bir sürüm yapmak, önceki
  /// kartın çözülen sorununa geri dönmek olurdu (krem zeminde krem kutu).
  /// Parametre yazılsaydı okunmayan bir alan olurdu; kalanlar onu okunuyor
  /// sanırdı.

  /// Şeritten SONRAKİ boşluk — anasayfanın öteki bölümleriyle aynı kural:
  /// boşluk bölümün kendi içinde durur.
  final double spacing;

  const TniAnasayfaSeridi({super.key, this.spacing = 0});

  @override
  Widget build(BuildContext context) {
    final kimlik = (tniVeri['kimlik'] as Map).cast<String, dynamic>();
    final kapak = TniGorsel.kare('kapak');
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final genislik = MediaQuery.sizeOf(context).width;
    final dar = genislik < 600;
    final orta = !dar && genislik < 900;

    // Yükseklik üç kademe. Alçak kalıyor: şerit akışı bölmeden kendini
    // göstermeli.
    final boy = dar ? 124.0 : (orta ? 140.0 : 156.0);
    final onde = (isEn ? kimlik['ad_en'] : kimlik['ad_tr']) as String;

    return Padding(
      padding: EdgeInsets.only(bottom: spacing),
      child: InkWell(
        onTap: () => context.push(turkuazPath),
        child: SizedBox(
          height: boy,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ── Zemin: fotoğraf ───────────────────────────────────────────
              if (kapak != null)
                NewsArticleImage(
                  imageUrl: TniGorsel.adres(kapak['dosya'] as String),
                  fit: BoxFit.cover,
                  isHighQuality: false,
                  semanticLabel:
                      (isEn ? kapak['alt_en'] : kapak['alt_tr']) as String,
                )
              else
                const ColoredBox(color: TniRenk.geceZemin),

              // ── Perde ─────────────────────────────────────────────────────
              // Yatay geçiş: metnin durduğu sol taraf neredeyse opak, sağ
              // taraf açık. Düz bir karartma fotoğrafı da metni de
              // bulandırıyordu; böyle hem yazı okunuyor hem kare görünüyor.
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      TniRenk.geceZemin.withValues(alpha: 0.96),
                      TniRenk.geceZemin.withValues(alpha: 0.88),
                      TniRenk.geceZemin.withValues(alpha: 0.34),
                    ],
                    stops: const [0, 0.48, 1],
                  ),
                ),
              ),

              // ── Sol kenarda turkuaz ince çizgi ────────────────────────────
              // Şeridin sayfadaki öteki bloklardan ilk bakışta ayrıldığı yer.
              const Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: 4,
                  child: ColoredBox(color: TniRenk.geceIklim),
                ),
              ),

              // ── Yazı ──────────────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.fromLTRB(dar ? 18 : 28, 14, dar ? 14 : 24, 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Tek etiket. "ÖNERİLEN" rozeti kaldırıldı
                          // (kullanıcı, 12 Kasım 2026): şeridin işi girişimi
                          // tanıtmak, aşamasını rozetle duyurmak değil.
                          TniEtiket(
                            isEn ? 'INITIATIVE' : 'GİRİŞİM',
                            renk: TniRenk.geceIklim,
                            cerceveli: false,
                          ),
                          SizedBox(height: dar ? 6 : 8),
                          Text(
                            onde,
                            maxLines: dar ? 2 : 1,
                            overflow: TextOverflow.ellipsis,
                            style: TniYazi.gosterge(
                              punto: dar ? 18 : (orta ? 22 : 26),
                              renk: TniRenk.geceMetin,
                              kalinlik: FontWeight.w800,
                              satir: 1.1,
                              aralik: -0.3,
                            ),
                          ),
                          SizedBox(height: dar ? 4 : 6),
                          Text(
                            isEn
                                ? 'What Türkiye proposed at COP31, and what is '
                                    'expected to come of it'
                                : 'Türkiye\'nin COP31\'de ortaya koyduğu '
                                    'girişim ve ondan beklenenler',
                            maxLines: dar ? 2 : 1,
                            overflow: TextOverflow.ellipsis,
                            style: TniYazi.govde(
                              punto: dar ? 12 : 13.5,
                              renk: TniRenk.geceIkincil,
                              satir: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.arrow_forward_rounded,
                        size: dar ? 18 : 22, color: TniRenk.geceIklim),
                  ],
                ),
              ),

              // ── Karenin künyesi ───────────────────────────────────────────
              if (kapak != null)
                Positioned(
                  right: dar ? 10 : 16,
                  bottom: 8,
                  child: Text(
                    isEn
                        ? 'Atatürk Dam · ${kapak['atif']}'
                        : 'Atatürk Barajı · ${kapak['atif']}',
                    style: TniYazi.olcu(
                      punto: 8.5,
                      renk: TniRenk.geceMetin.withValues(alpha: 0.62),
                      kalinlik: FontWeight.w500,
                      aralik: 0.3,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
