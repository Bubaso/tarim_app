import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tarim_app/core/theme/app_colors.dart';

import '../../../../core/utils/localization_helper.dart';
import '../../../../core/utils/responsive_breakpoints.dart';
import '../../data/models/news_article.dart';
import '../../providers/font_scale_provider.dart';
import '../../providers/home_providers.dart';
import '../widgets/font_size_control_bar.dart';
import 'category_articles_screen.dart' show KategoriHeroKarti, KategoriIzgarasi;

/// COP31'in tam listesi — bölümdeki "Tümü" ve şeritteki COP31 düğmesi.
///
/// DÜZEN kategori sayfalarıyla AYNI: büyük bir açılış kartı, ardından
/// [KategoriIzgarasi]'nın büyüklü küçüklü dönüşümlü düzeni. O widget'lar
/// `category_articles_screen.dart`'tan paylaşıma açıldı; kopyalanmadı ki
/// kategori sayfalarının düzeni değişince burası da değişsin.
///
/// NEDEN KATEGORİ EKRANININ KENDİSİ DEĞİL
/// İlk sürüm [CategoryArticlesScreen]'i yeniden kullanıyordu. Önizlemede o
/// ekranda COP31 ile ilgisi olmayan haberler göründü: köşe yazıları, aylık
/// gıda denetimi bültenleri, Kırşehir'de balık tezgahı denetimi. Veritabanı
/// tarafı temizdi — o başlıkların hiçbiri `cop31` işaretli değildi — ve
/// ekranın kodunda onları getirecek bir yol da bulunamadı. Açıklanamayan bir
/// karışma, süreli bir bölüm için taşınacak risk değil.
///
/// Bu ekran DÜZENİ ödünç alıyor, VERİYİ almıyor: hiçbir sorgu yapmıyor, tek
/// kaynağı [ozelBolumAkisiProvider] ve o sağlayıcının sorgusu
/// `ozel_bolum = 'cop31' AND status = 'published'`. Sayfalama, kategori
/// çözümü, "daha fazla yükle" yok — yani listeye dışarıdan haber sızacak bir
/// kapı yok.
class Cop31ListeEkrani extends ConsumerWidget {
  /// Ekran açılırken elde olan liste; akış gelene kadar ilk kare bununla
  /// çiziliyor, böylece boş ekran görünmüyor.
  final List<NewsArticle> tohum;

  const Cop31ListeEkrani({super.key, required this.tohum});

  static const _vurguAcik = Color(0xFF0E5C52);
  static const _vurguKoyu = Color(0xFF57C9B0);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider);
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fontScale = ref.watch(fontScaleProvider);
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < ResponsiveBreakpoints.contentWide;

    final vurgu = isDark ? _vurguKoyu : _vurguAcik;
    final metin = isDark ? AppColors.creamBackground : AppColors.earthText;
    final zemin = isDark ? AppColors.darkGreen : const Color(0xFFF4F4F4);
    final ayirac = isDark ? Colors.white12 : Colors.black12;
    final baslik = isEn ? 'COP31 CLIMATE SUMMIT' : 'COP31 İKLİM ZİRVESİ';

    final liste = ref.watch(ozelBolumAkisiProvider).valueOrNull ?? tohum;

    // Izgara satırları `slivers` listesinin DIŞINDA kuruluyor: viewport
    // yalnızca sliver kabul ediyor ve bu hata derlemede değil, çalışma anında
    // çıkardı (kategori ekranındaki notun aynısı).
    final izgaraSatirlari = liste.length > 1
        ? KategoriIzgarasi(
            articles: liste.sublist(1),
            isDark: isDark,
            isMobile: isMobile,
            fontScale: fontScale,
          ).satirlar()
        : const <Widget>[];

    return Scaffold(
      backgroundColor: zemin,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: isDark ? const Color(0xFF0A0D10) : Colors.white,
            elevation: 0,
            pinned: true,
            centerTitle: false,
            iconTheme: IconThemeData(color: metin),
            title: Text(
              // Zaten büyük harfle yazılı: Türkçede `toUpperCase()` 'i' → 'I'
              // üretip "IKLIM" çıkarıyor.
              baslik,
              style: GoogleFonts.inter(
                color: metin,
                fontWeight: FontWeight.w900,
                fontSize: 17,
                letterSpacing: 1.6,
              ),
            ),
            actions: [
              FontSizeControlBar(isDark: isDark),
              const SizedBox(width: 12),
            ],
          ),
          if (liste.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Text(
                  isEn ? 'No summit news yet.' : 'Zirveden haber yok.',
                  style: GoogleFonts.inter(color: metin, fontSize: 16),
                ),
              ),
            )
          else ...[
            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 0 : 24,
                        vertical: isMobile ? 0 : 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                              isMobile ? 16 : 0, isMobile ? 18 : 0,
                              isMobile ? 16 : 0, 16),
                          child: _Kunye(
                              vurgu: vurgu,
                              metin: metin,
                              adet: liste.length,
                              isEn: isEn),
                        ),
                        KategoriHeroKarti(
                          article: liste.first,
                          categoryName: baslik,
                          isDark: isDark,
                          isMobile: isMobile,
                          fontScale: fontScale,
                        ),
                        if (liste.length > 1)
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                                isMobile ? 16 : 0, 56, isMobile ? 16 : 0, 48),
                            child: Row(
                              children: [
                                Container(width: 24, height: 2, color: vurgu),
                                const SizedBox(width: 16),
                                Text(
                                  isEn ? 'MORE FROM COP31' : 'ZİRVEDEN DİĞER HABERLER',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 2.4,
                                    color: metin,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                    child: Container(height: 1, color: ayirac)),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Izgara TEMBEL: ekranda görünmeyen kartlar kurulmuyor.
            if (izgaraSatirlari.isNotEmpty)
              SliverList.builder(
                itemCount: izgaraSatirlari.length,
                itemBuilder: (context, i) => Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 16 : 24),
                      child: izgaraSatirlari[i],
                    ),
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 48)),
          ],
        ],
      ),
    );
  }
}

/// Zirvenin künyesi: ad, yer, tarih ve haber sayısı.
class _Kunye extends StatelessWidget {
  final Color vurgu;
  final Color metin;
  final int adet;
  final bool isEn;

  const _Kunye(
      {required this.vurgu,
      required this.metin,
      required this.adet,
      required this.isEn});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'COP31',
          style: GoogleFonts.outfit(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            height: 1,
            letterSpacing: -0.5,
            color: vurgu,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            isEn ? 'ANTALYA · 9–20 Nov 2026' : 'ANTALYA · 9–20 Kasım 2026',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: metin.withValues(alpha: 0.65),
            ),
          ),
        ),
        Text(
          isEn ? '$adet stories' : '$adet haber',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: vurgu,
          ),
        ),
      ],
    );
  }
}
