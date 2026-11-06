import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/konu_renkleri.dart';
import '../../data/models/story_item.dart';
import '../providers_kopru.dart';
import '../screens/story_viewer_screen.dart';
import 'story_image.dart';

// ══════════════════════════════════════════════════════════════════════════
//  Haber sayfasından hikâyeye kapı — 6 Kasım 2026 denetimi, T9
// ──────────────────────────────────────────────────────────────────────────
//  Hikâyelere girilen tek kapı ana sayfanın üst şeridiydi. Kategori
//  sayfasından ya da paylaşılan bir bağlantıdan gelen okur hikâyelerin
//  varlığından hiç haberdar olmuyordu.
//
//  KONU EŞLEMESİ YAPILMIYOR. Hikâye kategorileri (Piyasa, Hasat…) haber
//  konularıyla (Bitkisel Üretim, Ekonomi…) örtüşmüyor; ortak tek ad
//  "Hayvancılık". Bunun yerine okunan haberin KENDİSİ aranıyor: bu haberden
//  üretilmiş bir slayt varsa kart çiziliyor, yoksa hiç çizilmiyor.
//  Yaklaşık bir eşleme kurup okuru alakasız bir gruba göndermektense
//  hiç göstermemek doğru.
// ══════════════════════════════════════════════════════════════════════════

class HaberHikayeKarti extends ConsumerWidget {
  const HaberHikayeKarti({
    super.key,
    required this.articleId,
    required this.isDark,
  });

  final String articleId;
  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final gruplar = ref.watch(storiesProvider).maybeWhen(
          data: (g) => g,
          orElse: () => const <StoryGroup>[],
        );
    if (gruplar.isEmpty) return const SizedBox.shrink();

    // Haberin slaytını taşıyan grup ve o slaytın sırası.
    int grupNo = -1;
    int slaytNo = 0;
    for (var g = 0; g < gruplar.length; g++) {
      final i = gruplar[g].items.indexWhere((s) => s.articleId == articleId);
      if (i >= 0) {
        grupNo = g;
        slaytNo = i;
        break;
      }
    }
    if (grupNo < 0) return const SizedBox.shrink();

    final grup = gruplar[grupNo];
    final slayt = grup.items[slaytNo];
    final renk = konuRengi(grup.title, isDark);

    return InkWell(
      onTap: () => Navigator.of(context).push(
        PageRouteBuilder(
          opaque: false,
          pageBuilder: (_, __, ___) => StoryViewerScreen(
            storyGroups: gruplar,
            initialGroupIndex: grupNo,
            // Okur bu haberi okudu; hikâyeyi onun slaytından açmak
            // "zaten bildiğin şeyi bir daha izle" demek olurdu.
            // Grubun BAŞINDAN açılıyor.
          ),
          transitionsBuilder: (_, a, __, child) =>
              FadeTransition(opacity: a, child: child),
        ),
      ),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: renk.withValues(alpha: 0.45), width: 1.5),
          color: renk.withValues(alpha: isDark ? 0.10 : 0.06),
        ),
        child: Row(
          children: [
            // Baloncuğun kendisi: okur bunu ana sayfada görmüş olabilir,
            // aynı görsel iki yeri birbirine bağlıyor.
            SizedBox(
              width: 54,
              height: 54,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: StoryThumbImage(
                  url: grup.avatarUrl,
                  size: 54,
                  fill: true,
                  onizleme: grup.avatarOnizleme,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isEn ? 'IN STORIES' : 'HİKÂYELERDE',
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: renk,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isEn
                        ? '${grup.titleFor(true)} · ${grup.items.length} cards'
                        : '${grup.titleFor(false)} · ${grup.items.length} kart',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF1C2B3A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    // Okurun ne göreceğini somutlaştıran tek satır: grubun
                    // en vurucu rakamı.
                    '${slayt.bigStatValueFor(isEn)} · '
                    '${slayt.statLabelFor(isEn)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.play_circle_outline_rounded, color: renk, size: 26),
          ],
        ),
      ),
    );
  }
}
