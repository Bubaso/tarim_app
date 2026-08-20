import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/image_fallback_helper.dart';
import '../../data/models/story_item.dart';
import '../../data/story_constants.dart';
import '../screens/story_viewer_screen.dart';
import '../../providers/story_providers.dart';
import 'story_image.dart';

/// Anasayfadaki hikaye şeridi.
///
/// Baloncuklar daire değil "squircle": daire bir kişi/hesap metaforudur, oysa
/// buradaki görsel bir haber fotoğrafı. Dairesel kırpma yatay bir basın
/// fotoğrafının büyük kısmını atıyor ve okuyucu neye baktığını anlamıyordu.
///
/// Halka artık anlam taşıyor:
///   • kırmızı-turuncu  → izlenmemiş son dakika
///   • yeşil-buğday     → izlenmemiş
///   • ince gri çerçeve → izlenmiş
class StoryAvatarStrip extends ConsumerStatefulWidget {
  final bool isDark;
  final int maxItems;

  const StoryAvatarStrip({
    super.key,
    required this.isDark,
    this.maxItems = 7, // Mobil için varsayılan
  });

  @override
  ConsumerState<StoryAvatarStrip> createState() => _StoryAvatarStripState();
}

class _StoryAvatarStripState extends ConsumerState<StoryAvatarStrip>
    with WidgetsBindingObserver {
  /// Şeridin toplam yüksekliği — yükleme iskeleti de aynı yüksekliği tutar,
  /// yoksa liste sonradan "içeri düşünce" anasayfa zıplıyor.
  static const double _stripHeight = 110;
  static const double _bubbleSize = 76;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Uygulama saatlerce açık kalabiliyor; öne geldiğinde süresi dolmuş
    // hikayeleri düşürmek ve yenilerini almak için listeyi tazeliyoruz.
    if (state == AppLifecycleState.resumed) {
      refreshStoriesIfStale(ref);
    }
  }

  @override
  Widget build(BuildContext context) {
    final storiesAsync = ref.watch(storiesProvider);

    return storiesAsync.when(
      data: (stories) {
        // Tek başına duran bir iki baloncuk "sistem çalışmıyor" izlenimi
        // veriyor; eşiğin altında şeridi hiç çizmiyoruz.
        if (stories.length < StoryRules.minGroupsToShow) {
          return const SizedBox.shrink();
        }

        // Görüntüleyiciye şeritte GÖRÜNEN liste gidiyor. Eskiden şerit 7,
        // görüntüleyici 10 hikaye biliyordu; kaydıran okuyucu şeritte hiç
        // görmediği hikayelere düşüyordu.
        final visible = stories.take(widget.maxItems).toList();

        return SizedBox(
          height: _stripHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: visible.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: _StoryBubble(
                  group: visible[index],
                  isDark: widget.isDark,
                  size: _bubbleSize,
                  onTap: () => _openViewer(visible, index),
                ),
              );
            },
          ),
        );
      },
      loading: () => const _StripSkeleton(
        height: _stripHeight,
        bubbleSize: _bubbleSize,
      ),
      // Hikayeler tamamen isteğe bağlı bir bölüm; hata durumunda okuyucuya
      // kırmızı bir hata metni göstermek yerine sessizce gizliyoruz.
      error: (err, stack) => const SizedBox.shrink(),
    );
  }

  void _openViewer(List<StoryGroup> groups, int index) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) {
          return StoryViewerScreen(
            storyGroups: groups,
            initialGroupIndex: index,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }
}

// ── Tek baloncuk ──────────────────────────────────────────────────────────────

class _StoryBubble extends StatelessWidget {
  const _StoryBubble({
    required this.group,
    required this.isDark,
    required this.size,
    required this.onTap,
  });

  final StoryGroup group;
  final bool isDark;
  final double size;
  final VoidCallback onTap;

  /// Squircle yarıçapları: dıştan içe 3 px halka payı + 2 px zemin çerçevesi
  /// kadar küçülüyorlar ki köşeler iç içe düzgün otursun.
  static const double _outerRadius = 24;
  static const double _innerRadius = 21;
  static const double _imageRadius = 19;

  @override
  Widget build(BuildContext context) {
    final bool isEn = Localizations.localeOf(context).languageCode == 'en';
    final String displayTitle = group.titleFor(isEn);
    final bool unseen = !group.isSeen;

    final Gradient? ring = !unseen
        ? null
        : group.isBreaking
            ? const LinearGradient(
                colors: [Color(0xFFE94057), Color(0xFFF27121)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [AppColors.primaryGreen, AppColors.wheat],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              );

    return GestureDetector(
      onTap: onTap,
      child: Semantics(
        button: true,
        label: displayTitle,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: size,
              height: size,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(_outerRadius),
                gradient: ring,
                border: unseen
                    ? null
                    : Border.all(
                        color: isDark ? Colors.white24 : Colors.black12,
                        width: 2,
                      ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(_innerRadius),
                  border: Border.all(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(_imageRadius),
                  child: StoryThumbImage(
                    url: group.avatarUrl,
                    size: size,
                    fill: true,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: size,
              child: Text(
                displayTitle,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: unseen ? FontWeight.w600 : FontWeight.w500,
                  color: unseen
                      ? (isDark ? Colors.white : AppColors.earthText)
                      : (isDark ? Colors.white54 : Colors.black45),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Yükleme iskeleti ──────────────────────────────────────────────────────────

class _StripSkeleton extends StatelessWidget {
  const _StripSkeleton({required this.height, required this.bubbleSize});

  final double height;
  final double bubbleSize;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 5,
        itemBuilder: (context, _) => Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ShimmerPlaceholder(
                width: bubbleSize,
                height: bubbleSize,
                borderRadius: BorderRadius.circular(24),
              ),
              const SizedBox(height: 8),
              ShimmerPlaceholder(
                width: 52,
                height: 10,
                borderRadius: BorderRadius.circular(5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
