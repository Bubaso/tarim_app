import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dark_mode.dart';
import '../../../../core/theme/konu_renkleri.dart';
import '../../../../core/utils/fade_page_route.dart';
import '../../../../core/widgets/ana_sayfa_dugmesi.dart';
import '../../data/models/story_item.dart';
import '../../providers/story_providers.dart';
import '../widgets/story_image.dart';
import 'story_viewer_screen.dart';

// ══════════════════════════════════════════════════════════════════════════
//  Hikâye arşivi — "dün ne oldu" (6 Kasım 2026 denetimi, Ö10)
// ──────────────────────────────────────────────────────────────────────────
//  Hikâyeler 24-30 saat sonra şeritten düşüyor ama satırlar veritabanında
//  duruyor. Hafta sonu siteye giren okur hafta içini hiç göremiyordu.
//
//  GÜN gün diziliyor, konu konu değil: okurun sorusu "Piyasa'da ne oldu"
//  değil "salı günü ne oldu". Konu sıralaması günün içinde.
// ══════════════════════════════════════════════════════════════════════════

class HikayeArsiviEkrani extends ConsumerWidget {
  const HikayeArsiviEkrani({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = appIsDark;
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final arsiv = ref.watch(storyArsiviProvider);

    final zemin = isDark ? AppColors.darkGreen : AppColors.creamBackground;
    final murekkep = isDark ? AppColors.creamBackground : AppColors.earthText;

    return Scaffold(
      backgroundColor: zemin,
      appBar: AppBar(
        backgroundColor: zemin,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: murekkep),
        leadingWidth: anaSayfaLeadingGenisligi(context),
        leading: anaSayfaliLeading(context, renk: murekkep),
        title: Text(
          isEn ? 'Story Archive' : 'Hikâye Arşivi',
          style: GoogleFonts.outfit(
            color: murekkep,
            fontWeight: FontWeight.w800,
            fontSize: 19,
          ),
        ),
      ),
      body: arsiv.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isEn ? 'Archive could not be loaded.' : 'Arşiv yüklenemedi.',
                  style: GoogleFonts.inter(color: murekkep, fontSize: 16),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => ref.invalidate(storyArsiviProvider),
                  child: Text(isEn ? 'Try again' : 'Yeniden dene'),
                ),
              ],
            ),
          ),
        ),
        data: (gunler) {
          if (gunler.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  isEn
                      ? 'No stories from the past week yet.'
                      : 'Son bir haftadan arşivlenmiş hikâye yok.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                      color: murekkep.withValues(alpha: 0.7), fontSize: 15),
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 48),
            itemCount: gunler.length,
            itemBuilder: (context, i) => _GunBolumu(
              gun: gunler[i],
              isDark: isDark,
              isEn: isEn,
              murekkep: murekkep,
            ),
          );
        },
      ),
    );
  }
}

class _GunBolumu extends StatelessWidget {
  const _GunBolumu({
    required this.gun,
    required this.isDark,
    required this.isEn,
    required this.murekkep,
  });

  final StoryArsivGunu gun;
  final bool isDark;
  final bool isEn;
  final Color murekkep;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                _gunAdi(gun.gun, isEn),
                style: GoogleFonts.outfit(
                  color: murekkep,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                isEn
                    ? '${gun.kartSayisi} cards'
                    : '${gun.kartSayisi} kart',
                style: GoogleFonts.inter(
                  color: murekkep.withValues(alpha: 0.55),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 118,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: gun.gruplar.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, i) => _ArsivBaloncugu(
              grup: gun.gruplar[i],
              isDark: isDark,
              isEn: isEn,
              murekkep: murekkep,
              onTap: () => Navigator.of(context).push(
                PageRouteBuilder(
                  opaque: false,
                  pageBuilder: (_, __, ___) => StoryViewerScreen(
                    storyGroups: gun.gruplar,
                    initialGroupIndex: i,
                  ),
                  transitionsBuilder: (_, a, __, child) =>
                      FadeTransition(opacity: a, child: child),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// "Dün", "Salı", "28 Ekim" — yakın günlerde ad, uzaklarda tarih.
  ///
  /// Okur "salı" diye düşünüyor ama iki hafta önceki salıyı kastetmiyor;
  /// gün adı ancak son bir hafta içinde anlam taşıyor ve arşiv zaten
  /// yedi günle sınırlı.
  String _gunAdi(DateTime g, bool isEn) {
    final bugun = DateTime.now();
    final fark = DateTime(bugun.year, bugun.month, bugun.day)
        .difference(g)
        .inDays;
    if (fark == 1) return isEn ? 'Yesterday' : 'Dün';

    const trGun = [
      'Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'
    ];
    const enGun = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday',
      'Sunday'
    ];
    if (fark <= 6) {
      return isEn ? enGun[g.weekday - 1] : trGun[g.weekday - 1];
    }

    const trAy = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];
    const enAy = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return isEn
        ? '${enAy[g.month - 1]} ${g.day}'
        : '${g.day} ${trAy[g.month - 1]}';
  }
}

class _ArsivBaloncugu extends StatelessWidget {
  const _ArsivBaloncugu({
    required this.grup,
    required this.isDark,
    required this.isEn,
    required this.murekkep,
    required this.onTap,
  });

  final StoryGroup grup;
  final bool isDark;
  final bool isEn;
  final Color murekkep;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final renk = konuRengi(grup.title, isDark);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 76,
            height: 76,
            padding: const EdgeInsets.all(2.5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              // Arşivde halka DOLU değil çizgi: bu kartlar izlenmiş sayılıyor
              // ve şeritteki "yeni" vurgusunu taşımamalı.
              border: Border.all(color: renk.withValues(alpha: 0.6), width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: StoryThumbImage(
                url: grup.avatarUrl,
                size: 76,
                fill: true,
                onizleme: grup.avatarOnizleme,
              ),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 76,
            child: Text(
              grup.titleFor(isEn),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: murekkep.withValues(alpha: 0.85),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Arşivi açar. Şeridin sonundaki sabit baloncuk buradan çağırıyor.
void hikayeArsiviniAc(BuildContext context) {
  pushScreen(context, const HikayeArsiviEkrani());
}
