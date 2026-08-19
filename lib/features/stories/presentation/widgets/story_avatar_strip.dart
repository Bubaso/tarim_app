import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/story_item.dart';
import '../screens/story_viewer_screen.dart';
import '../../providers/story_providers.dart';

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
                    width: 72,
                    height: 72,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: group.isNew
                          ? const LinearGradient(
                              colors: [AppColors.wheat, AppColors.primaryGreen],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      border: !group.isNew
                          ? Border.all(color: Colors.grey.withOpacity(0.3), width: 1.5)
                          : null,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: isDark ? AppColors.darkGreen : AppColors.creamBackground, width: 2),
                      ),
                      child: ClipOval(
                        child: Image.network(
                          group.avatarUrl,
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.high,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: AppColors.wheat,
                            child: const Icon(Icons.broken_image, size: 20, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: 76,
                    child: Text(
                      group.title,
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
      loading: () => const SizedBox.shrink(),
      error: (err, stack) => SizedBox(height: 110, child: Center(child: Text('Hata: $err', style: const TextStyle(color: Colors.red)))),
    );
  }
}
