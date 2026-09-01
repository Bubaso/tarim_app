import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/localization_helper.dart';
import '../../../../core/utils/responsive_breakpoints.dart';
import '../../../../core/widgets/section_container.dart';
import '../../data/models/video_haberi.dart';
import '../../providers/video_providers.dart';

/// Anasayfadaki video haber şeridi.
///
/// Kartlar YALNIZCA küçük görsel gösteriyor, gömülü oynatıcı taşımıyor.
/// Sebebi ölçülebilir: anasayfaya altı YouTube iframe'i koymak, sayfanın her
/// açılışında YouTube'un betiğini altı kez yükletir ve açılışı gözle görülür
/// biçimde ağırlaştırır. Dokunulan video kaynağında açılıyor; uygulama içi
/// oynatma ayrı bir adım.
class VideoSerit extends ConsumerWidget {
  final bool isDark;

  /// Bölümden sonraki boşluk. Bölümün KENDİSİ yayıyor: onaylı video yokken
  /// geriye tek piksel kalmasın, sayfa eskisiyle birebir aynı görünsün.
  final double spacing;

  const VideoSerit({super.key, required this.isDark, required this.spacing});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider);
    final videolar = ref.watch(yayindakiVideolarProvider).valueOrNull ?? const [];

    // Yükleme iskeleti ya da hata kutusu YOK. Bu bölüm anasayfanın ana işi
    // değil; boş bir kutu manşetten dikkat çalar.
    if (videolar.isEmpty) return const SizedBox.shrink();

    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final genislik = MediaQuery.of(context).size.width;
    final dar = genislik < ResponsiveBreakpoints.mobileMax;

    final kartGenisligi = dar ? 244.0 : 288.0;
    final seritYuksekligi = dar ? 214.0 : 240.0;

    return Column(
      children: [
        SectionContainer(
          title: isEn ? 'VIDEO NEWS' : 'VİDEO HABERLER',
          icon: Icons.play_circle_outline_rounded,
          isDark: isDark,
          child: SizedBox(
            height: seritYuksekligi,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              clipBehavior: Clip.none,
              itemCount: videolar.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, i) => SizedBox(
                width: kartGenisligi,
                child: _VideoKarti(
                  video: videolar[i],
                  isDark: isDark,
                  isEn: isEn,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: spacing),
      ],
    );
  }
}

class _VideoKarti extends StatelessWidget {
  final VideoHaberi video;
  final bool isDark;
  final bool isEn;

  const _VideoKarti({required this.video, required this.isDark, required this.isEn});

  @override
  Widget build(BuildContext context) {
    final baslikRengi = isDark ? AppColors.creamBackground : AppColors.earthText;
    final soluk = baslikRengi.withValues(alpha: 0.62);
    final kenar = isDark ? AppColors.wheat : const Color(0xFFE5E5E5);

    return Material(
      color: isDark ? AppColors.darkGreen : Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => launchUrl(
          Uri.parse(video.url),
          mode: LaunchMode.externalApplication,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kenar),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: video.gorsel,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(
                        color: baslikRengi.withValues(alpha: 0.08),
                        child: Icon(Icons.videocam_off_rounded, color: soluk),
                      ),
                    ),
                    // Oynat rozeti: kartın videoya götürdüğünü RENKLE değil
                    // BİÇİMLE söylüyor.
                    Center(
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.play_arrow_rounded,
                            color: Colors.white, size: 28),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          video.baslik,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.libreFranklin(
                            fontSize: 13,
                            height: 1.3,
                            fontWeight: FontWeight.w700,
                            color: baslikRengi,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Kaynak künyesi kartın zorunlu parçası. Gömülü video
                      // kaynağını göstermiyorsa, atıfsız görselden farkı yok.
                      Row(
                        children: [
                          Icon(Icons.open_in_new_rounded, size: 11, color: soluk),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _kunye(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(fontSize: 10.5, color: soluk),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _kunye() {
    final tarih = video.yayimTarihi;
    if (tarih == null) return video.kanalAdi;
    final gun = DateFormat('d MMM yyyy', isEn ? 'en_US' : 'tr_TR').format(tarih);
    return '${video.kanalAdi} · $gun';
  }
}
