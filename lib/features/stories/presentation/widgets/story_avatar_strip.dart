import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/image_fallback_helper.dart';
import '../screens/story_viewer_screen.dart';
import '../../providers/story_providers.dart';
import 'story_image.dart';

class StoryAvatarStrip extends ConsumerWidget {
  final bool isDark;
  final int maxItems;

  const StoryAvatarStrip({
    super.key,
    required this.isDark,
    this.maxItems = 7, // Mobil için varsayılan
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storiesAsync = ref.watch(storiesProvider);

    return storiesAsync.when(
      data: (stories) {
        final int displayCount = stories.length > maxItems ? maxItems : stories.length;
        
        // Minimum limit şimdilik kaldırıldı (Hata ayıklama için)

        return SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: displayCount,
            itemBuilder: (context, index) {
              final group = stories[index];
              final bool isEn = Localizations.localeOf(context).languageCode == 'en';
              final String displayTitle = isEn && group.titleEn.isNotEmpty ? group.titleEn : group.title;

          return Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    opaque: false,
                    pageBuilder: (context, animation, secondaryAnimation) {
                      return StoryViewerScreen(
                        storyGroups: stories,
                        initialGroupIndex: index,
                      );
                    },
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                  ),
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: group.isNew ? const LinearGradient(
                        colors: [Color(0xFFE94057), Color(0xFFF27121)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ) : null,
                      border: !group.isNew ? Border.all(color: isDark ? Colors.white24 : Colors.black12, width: 2) : null,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 2),
                      ),
                      child: ClipOval(
                        // 76 px'lik kutu - 3 px halka payı - 2 px zemin çerçevesi
                        child: StoryCircleImage(url: group.avatarUrl, size: 66, fill: true),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: 76,
                    child: Text(
                      displayTitle,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: group.isNew ? FontWeight.w600 : FontWeight.w500,
                        color: isDark ? Colors.white : AppColors.earthText,
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  },
      // Yükleme sırasında yüksekliği koruyoruz: strip sonradan "içeri düşünce"
      // anasayfa zıplıyor ve bu tek başına kaliteyi düşük gösteriyordu.
      loading: () => SizedBox(
        height: 110,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: 5,
          itemBuilder: (context, _) => const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ShimmerPlaceholder(
                  width: 76,
                  height: 76,
                  borderRadius: BorderRadius.all(Radius.circular(38)),
                ),
                SizedBox(height: 8),
                ShimmerPlaceholder(
                  width: 52,
                  height: 10,
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                ),
              ],
            ),
          ),
        ),
      ),
      // Hikayeler tamamen isteğe bağlı bir bölüm; hata durumunda kullanıcıya
      // kırmızı bir hata metni göstermek yerine sessizce gizliyoruz.
      error: (err, stack) => const SizedBox.shrink(),
    );
  }
}
