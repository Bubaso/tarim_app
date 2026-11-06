import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/turkce_metin.dart';
import '../../data/models/story_item.dart';

// ══════════════════════════════════════════════════════════════════════════
//  Grup sonu özet kartı — 6 Kasım 2026 denetimi, Ö3
// ──────────────────────────────────────────────────────────────────────────
//  Grup bitince okur sessizce bir sonraki gruba atlıyordu ve ne izlediğini
//  hatırlamıyordu. Özet kartı o anı bir karara çeviriyor: bütün rakamlar tek
//  ekranda, her satır kendi haberine açılıyor.
//
//  "Hepsini oku" diye tek bir düğme KONMADI. Grup bir konu, konunun tek bir
//  adresi yok: hikâye kategorileri (Piyasa, Hasat, Destekleme…) uygulamanın
//  kategori slug'larıyla eşleşmiyor — ortak tek ad "Hayvancılık". Uydurma
//  bir eşleme kurmaktansa satırların kendisini tıklanabilir yapmak hem
//  doğru hem daha kullanışlı: okur hangi haberi istediğini zaten biliyor.
// ══════════════════════════════════════════════════════════════════════════

class OzetKarti extends StatelessWidget {
  const OzetKarti({
    super.key,
    required this.grup,
    required this.isEn,
    required this.renk,
    required this.ac,
    required this.paylas,
  });

  final StoryGroup grup;
  final bool isEn;

  /// Konunun rengi — başlık şeridi ve rakamlar.
  final Color renk;

  final void Function(StoryItem) ac;
  final VoidCallback paylas;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          Row(
            children: [
              Container(width: 3, height: 20, color: renk),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  // Ham `toUpperCase()` DEĞİL (§39.5).
                  buyukHarf(grup.titleFor(isEn), isEn),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: renk,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            isEn ? 'In numbers' : 'Rakamlarla',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 30,
              height: 1.1,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 18),

          // Satırlar kaydırılabilir: beş slaytlık bir grupta liste küçük
          // ekranda taşabiliyor ve taşan satır dokunulamaz oluyor.
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final s in grup.items)
                    _OzetSatiri(
                      slayt: s,
                      isEn: isEn,
                      renk: renk,
                      onTap: () => ac(s),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 18),
          Row(
            children: [
              _Dugme(
                etiket: isEn ? 'Share card' : 'Kartı paylaş',
                ikon: Icons.ios_share,
                onTap: paylas,
              ),
              const SizedBox(width: 10),
              Text(
                isEn
                    ? 'Tap a line to read'
                    : 'Satıra dokunup haberi okuyun',
                style: GoogleFonts.inter(
                  color: Colors.white.withValues(alpha: 0.55),
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OzetSatiri extends StatelessWidget {
  const _OzetSatiri({
    required this.slayt,
    required this.isEn,
    required this.renk,
    required this.onTap,
  });

  final StoryItem slayt;
  final bool isEn;
  final Color renk;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rakam SOLDA ve sabit genişlikte: özetin işi sayıları yan yana
            // okutmak, dolayısıyla hepsi aynı hizada başlamalı.
            // Sabit genişlik + KÜÇÜLTEREK sığdırma. Kırpma yanlış olurdu:
            // "10 milyar TL" → "10 milya" diye kesiliyordu ve özetin bütün
            // işi o rakamı okutmak. Genişliği değişken bırakmak da olmaz —
            // rakamlar alt alta hizalı durmazsa özet tablo olmaktan çıkar.
            SizedBox(
              width: 104,
              child: Align(
                alignment: Alignment.centerLeft,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    slayt.bigStatValueFor(isEn),
                    maxLines: 1,
                    style: GoogleFonts.outfit(
                      color: renk,
                      fontSize: 21,
                      height: 1.15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                slayt.headlineFor(isEn),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 14.5,
                  height: 1.35,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.chevron_right_rounded,
                size: 18, color: Colors.white.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }
}

class _Dugme extends StatelessWidget {
  const _Dugme({required this.etiket, required this.ikon, required this.onTap});

  final String etiket;
  final IconData ikon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(ikon, size: 15, color: AppColors.creamBackground),
            const SizedBox(width: 8),
            Text(
              etiket,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
