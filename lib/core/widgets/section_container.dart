import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';
import '../utils/responsive_breakpoints.dart';

/// Ana sayfadaki her bölümün ortak başlığı: ince ayırıcı, ikon, başlık ve
/// isteğe bağlı "daha fazla" bağlantısı.
///
/// `home_screen.dart` içinde özel bir sınıftı; emtia şeridi ana sayfa
/// dosyasının dışında yaşadığı için buraya taşındı. Görünüm bire bir aynı —
/// taşıma sırasında hiçbir ölçü değiştirilmedi.
/// Bölümün sayfadaki ağırlığı.
///
/// 6 Kasım 2026 anasayfa denetimi (A8/Ö8): on beş bölümün hepsi aynı
/// kalıpta açılıyordu — ikon, büyük harf başlık, üstünde çizgi, sağda
/// "Daha fazla". Kalıbın kendisi iyi ama on beş kez tekrarlanınca
/// hiyerarşi taşımayı bırakıyor; okur hangi bölümün ana, hangisinin
/// yardımcı olduğunu ayırt edemiyordu. Tipografi zaten vardı.
enum BolumKademesi {
  /// Sayfanın omurgası: Türkiye, Dünya, Bilim, Sektörler.
  ana,

  /// Yardımcı şeritler: Gözden Kaçanlar, Video, Dosya, Kısa Kısa, Emtia.
  /// Çizgi yok, bir kademe sakin başlık.
  yardimci,
}

class SectionContainer extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final bool isDark;
  final VoidCallback? onSeeAll;

  /// Varsayılan [BolumKademesi.ana]: hiçbir çağrı yeri değişmesin diye.
  /// Yardımcı olanlar tek tek işaretleniyor.
  final BolumKademesi kademe;

  // Bilerek `iconColor` parametresi yok: her bölüm kendi rengini seçebildiği
  // sürece palet dağılıyor. Vurgu rengi tek yerden gelir.
  const SectionContainer({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
    required this.isDark,
    this.onSeeAll,
    this.kademe = BolumKademesi.ana,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = AppColors.accentFor(isDark: isDark);
    final headerColor = isDark ? AppColors.creamBackground : AppColors.earthText;
    final dividerColor = isDark ? AppColors.creamBackground : AppColors.earthText;
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < ResponsiveBreakpoints.mobileMax;
    // Dar ekranda başlık + "Daha fazla" aynı satıra sığmayınca başlık
    // kırpılıyordu ("TÜRKİYE'DEN HABER…"). [contentWide] altında başlık iki
    // satıra sarabilir; "Daha fazla" düğmesi (metniyle) satırın sağında kalır.
    final isNarrow = width < ResponsiveBreakpoints.contentWide;
    final anaMi = kademe == BolumKademesi.ana;

    final header = Row(
      // İki satırlık bir başlığın yanında düğme üst satıra hizalansın.
      crossAxisAlignment:
          isNarrow ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(top: isNarrow ? 1 : 0),
          child: Icon(icon,
              color: iconColor,
              size: anaMi ? (isMobile ? 20 : 24) : (isMobile ? 17 : 19)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            // Bölüm başlığı gövde metninden (17 px) küçük olamaz. Geniş ekranda
            // tek satır yeterli; dar ekranda iki satıra sarmak kırpmaktan iyi.
            style: GoogleFonts.outfit(
              // Yardımcı bölüm bir kademe sakin ama gövde metninin
              // (17 px) ALTINA inmiyor — bölüm başlığı hiçbir zaman
              // gövdeden küçük olamaz.
              fontSize: anaMi ? (isMobile ? 17 : 20) : 17,
              fontWeight: anaMi ? FontWeight.w900 : FontWeight.w700,
              letterSpacing: anaMi ? 0.4 : 0.9,
              color: anaMi ? headerColor : headerColor.withValues(alpha: 0.82),
              height: 1.2,
            ),
            maxLines: isNarrow ? 2 : 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // "Daha fazla" düğmesi metniyle kalır — dar ekranda bile yalnızca oka
        // düşürülmez (kullanıcı kararı).
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryGreen,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isEn ? 'See All' : 'Daha fazla',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward_rounded, size: 16),
              ],
            ),
          ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sayfada tekrar eden bir ayırıcı; 3 px'te her bölüm bir
              // "basamak" gibi görünüyordu. Gazete kuralı: saç teli inceliğinde
              // çizgi ayırır, kalın çizgi böler.
              // Çizgi YALNIZCA ana bölümlerde: on beş bölümün hepsinde
              // olunca ayırmayı bırakıp arka plan dokusuna dönüşüyordu.
              if (anaMi) ...[
                Container(
                    height: 1, width: double.infinity, color: dividerColor),
                const SizedBox(height: 16),
              ],
              header,
            ],
          ),
        ),
        SizedBox(height: anaMi ? 16 : 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: child,
        ),
      ],
    );
  }
}
