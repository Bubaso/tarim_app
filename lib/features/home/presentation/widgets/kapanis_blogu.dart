import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/fade_page_route.dart';
import '../../../stories/presentation/screens/hikaye_arsivi_ekrani.dart';
import 'portal_footer.dart';

// ══════════════════════════════════════════════════════════════════════════
//  Kapanış bloğu — sayfanın bir sonu olsun
// ──────────────────────────────────────────────────────────────────────────
//  6 Kasım 2026 anasayfa denetimi (A10): sekiz ekranlık kaydırmanın
//  sonunda son bölüm bitiyor ve doğrudan altbilgi geliyordu. Okura "bitti"
//  diyen, onu bir sonraki eyleme yönlendiren hiçbir şey yoktu.
//
//  İki şey taşıyor ve ikisi de sayfanın SONUNA ait:
//
//    · Hikâye arşivi — "dün ne oldu" sorusunun cevabı. Şeridin sonundaki
//      arşiv baloncuğu küçük ve kolay kaçırılıyor; burada tam genişlikte.
//    · Haftalık bülten — altbilgiden BURAYA taşındı, kopyalanmadı. Sekiz
//      ekran kaydırmış okur, daveti görmeye en açık okur.
//
//  Kullanıcı kararı (6 Kasım 2026): blokta günlük özet rakamları YOK,
//  yalnızca bu ikisi.
// ══════════════════════════════════════════════════════════════════════════

class KapanisBlogu extends StatelessWidget {
  const KapanisBlogu({super.key, required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final metin = isDark ? AppColors.creamBackground : AppColors.earthText;
    final cizgi = isDark ? Colors.white12 : Colors.black12;
    final genis = MediaQuery.of(context).size.width >= 900;

    final arsiv = _ArsivKarti(isDark: isDark, isEn: isEn);
    final bulten = HaftalikBultenKaydi(isDark: isDark);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 1, color: cizgi),
          const SizedBox(height: 28),
          Text(
            isEn ? 'That is today' : 'Günün sonu',
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: metin,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isEn
                ? 'New stories arrive every morning at 07:45.'
                : 'Yeni haberler her sabah 07.45’te geliyor.',
            style: GoogleFonts.inter(
              fontSize: 14.5,
              color: metin.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 22),
          // Geniş ekranda yan yana, dar ekranda alt alta. İkisi de tam
          // genişlik isterse masaüstünde blok gereksiz uzuyordu.
          if (genis)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: arsiv),
                const SizedBox(width: 24),
                Expanded(child: bulten),
              ],
            )
          else ...[
            arsiv,
            const SizedBox(height: 24),
            bulten,
          ],
        ],
      ),
    );
  }
}

class _ArsivKarti extends StatelessWidget {
  const _ArsivKarti({required this.isDark, required this.isEn});

  final bool isDark;
  final bool isEn;

  @override
  Widget build(BuildContext context) {
    final metin = isDark ? AppColors.creamBackground : AppColors.earthText;
    final vurgu = AppColors.accentFor(isDark: isDark);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => pushScreen(context, const HikayeArsiviEkrani()),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isDark ? Colors.white24 : Colors.black.withValues(alpha: 0.14)),
        ),
        child: Row(
          children: [
            Icon(Icons.history_rounded, size: 22, color: vurgu),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isEn ? 'Story archive' : 'Hikâye arşivi',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: metin,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    isEn
                        ? 'Past days, day by day.'
                        : 'Geçmiş günler, gün gün.',
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      color: metin.withValues(alpha: 0.68),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                size: 20, color: metin.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }
}
