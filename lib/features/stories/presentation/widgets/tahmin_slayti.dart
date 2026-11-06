import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/story_item.dart';

// ══════════════════════════════════════════════════════════════════════════
//  Tahmin slaytı — 6 Kasım 2026 denetimi, Ö5
// ──────────────────────────────────────────────────────────────────────────
//  Rakam hemen gösterilmiyor: okura soruluyor, üç şıktan birini seçiyor ve
//  cevap öyle açılıyor. Hikâye biçimini pasif izlemeden aktif katılıma
//  çeviriyor ve veri gazeteciliğinin en iyi ürettiği duyguyu kullanıyor:
//  "bu kadar olduğunu bilmiyordum."
//
//  CEVAP AÇILDIKTAN SONRA kart normal haline dönüyor — soru bir perde,
//  içerik değil.
// ══════════════════════════════════════════════════════════════════════════

class TahminSlayti extends StatelessWidget {
  const TahminSlayti({
    super.key,
    required this.slayt,
    required this.isEn,
    required this.renk,
    required this.sec,
  });

  final StoryItem slayt;
  final bool isEn;
  final Color renk;

  /// Seçilen şıkkın sırası.
  final void Function(int) sec;

  @override
  Widget build(BuildContext context) {
    final sikler = slayt.tahminSecenekFor(isEn);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          isEn ? 'GUESS' : 'TAHMİN EDİN',
          style: GoogleFonts.inter(
            color: renk,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          slayt.tahminSoruFor(isEn),
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 25,
            height: 1.22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 20),
        for (var i = 0; i < sikler.length; i++) ...[
          _Sik(etiket: sikler[i], onTap: () => sec(i)),
          if (i < sikler.length - 1) const SizedBox(height: 10),
        ],
        const SizedBox(height: 14),
        Text(
          isEn
              ? 'Pick one to reveal the answer'
              : 'Birini seçin, cevap açılsın',
          style: GoogleFonts.inter(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 12.5,
          ),
        ),
      ],
    );
  }
}

class _Sik extends StatelessWidget {
  const _Sik({required this.etiket, required this.onTap});

  final String etiket;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.38),
          border: Border.all(color: Colors.white.withValues(alpha: 0.45)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          etiket,
          style: GoogleFonts.outfit(
            color: AppColors.wheat,
            fontSize: 21,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

/// Cevap açıldıktan sonra rakamın altında beliren tek satır.
class TahminSonucu extends StatelessWidget {
  const TahminSonucu({
    super.key,
    required this.dogruBildi,
    required this.toplam,
    required this.dogru,
    required this.isEn,
  });

  final bool dogruBildi;
  final int toplam;
  final int dogru;
  final bool isEn;

  /// Yüzdenin gösterilmesi için gereken en az cevap sayısı.
  ///
  /// Üç kişinin ikisi bildiğinde "%67 bildi" yazmak sayıyı olduğundan
  /// anlamlı gösterir. Eşiğin altında yalnız doğru/yanlış söyleniyor.
  static const int _esik = 20;

  @override
  Widget build(BuildContext context) {
    final renk = dogruBildi
        ? const Color(0xFF8FD694)
        : const Color(0xFFE8A07A);
    final bas = dogruBildi
        ? (isEn ? 'Correct' : 'Doğru bildiniz')
        : (isEn ? 'Not quite' : 'Yaklaştınız');

    String kuyruk = '';
    if (toplam >= _esik) {
      final yuzde = (dogru * 100 / toplam).round();
      kuyruk = isEn
          ? ' · $yuzde% of readers guessed right'
          // Kesme işareti KAÇIRILIYOR: Türkçede ek ayracı olarak gerekli
          // ama Dart tek tırnaklı dizgeyi orada kapatıyor.
          : ' · okurların %$yuzde\'i bildi';
    }

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        '$bas$kuyruk',
        style: GoogleFonts.inter(
          color: renk,
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
