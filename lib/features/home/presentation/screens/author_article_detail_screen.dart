// ignore_for_file: deprecated_member_use
import 'package:tarim_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/home_providers.dart';
import '../widgets/ai_columnists.dart';
import '../widgets/news_card.dart';
import '../../../../core/utils/string_extensions.dart';

class AuthorArticleDetailScreen extends ConsumerWidget {
  final AiColumnist columnist;

  const AuthorArticleDetailScreen({
    super.key,
    required this.columnist,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final width = MediaQuery.of(context).size.width;

    final bg = isDark ? AppColors.darkGreen : AppColors.creamBackground;
    final onBg = isDark ? AppColors.creamBackground : AppColors.earthText;
    // Gövde renginin aynısı olursa "soluk" olmaz; açık temada opaklığı kısıyoruz.
    final subtle = isDark
        ? AppColors.wheat
        : AppColors.earthText.withValues(alpha: 0.70);
    final accent = AppColors.primaryGreen;
    final headerBg = isDark ? const Color(0xFF161B22) : const Color(0xFFF9F7F1);

    final articlesAsyncValue = ref.watch(latestArticlesProvider);
    final isMobile = width < 768;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: CustomScrollView(
              slivers: [
                // ─── Modern App Bar & Yazar Kimliği ──────────────────────────────────
                SliverAppBar(
                  backgroundColor: headerBg,
                  elevation: 0,
                  pinned: true,
                  expandedHeight: isMobile ? 320 : 400,
                  iconTheme: IconThemeData(color: onBg),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      color: headerBg,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [accent.withOpacity(0.8), accent.withOpacity(0.2)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: ClipOval(
                              child: Container(
                                width: isMobile ? 120 : 160,
                                height: isMobile ? 120 : 160,
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.wheat : const Color(0xFFEBEAE6),
                                ),
                                child: Image.network(
                                  columnist.avatarUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Center(
                                    child: Text(
                                      columnist.name[0],
                                      style: GoogleFonts.playfairDisplay(
                                        fontSize: isMobile ? 48 : 64,
                                        fontWeight: FontWeight.bold,
                                        color: subtle,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            columnist.name,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: isMobile ? 32 : 44,
                              fontWeight: FontWeight.w900,
                              color: onBg,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: accent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: accent.withOpacity(0.3)),
                            ),
                            child: Text(
                              (isEn ? columnist.titleEn : columnist.titleTr).toTurkishUpperCase(),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: isMobile ? 12 : 14,
                                fontWeight: FontWeight.w700,
                                color: accent,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ─── Arşiv Listesi / Grid (Responsive) ──────────────────────────────
                SliverPadding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16 : 32,
                    vertical: 40,
                  ),
                  sliver: articlesAsyncValue.when(
                    data: (allArticles) {
                      final authorArticles = allArticles
                          .where((a) => a.sourceName?.trim() == columnist.name)
                          .toList();

                      if (authorArticles.isEmpty) {
                        return SliverToBoxAdapter(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(40.0),
                              child: Column(
                                children: [
                                  Icon(Icons.article_outlined, size: 64, color: subtle.withOpacity(0.5)),
                                  const SizedBox(height: 16),
                                  Text(
                                    isEn ? 'No articles published yet.' : 'Henüz yayımlanmış yazısı bulunmuyor.',
                                    style: GoogleFonts.inter(
                                      color: subtle,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      // Modern, responsive grid design
                      return SliverGrid(
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 450, // This ensures it breaks to multiple columns on desktop
                          mainAxisSpacing: 32,
                          crossAxisSpacing: 32,
                          mainAxisExtent: 440, // Fixed height to prevent overflow with NewsCard
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return NewsCard(
                              article: authorArticles[index],
                            );
                          },
                          childCount: authorArticles.length,
                        ),
                      );
                    },
                    loading: () => const SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(40.0),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ),
                    error: (e, st) => SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40.0),
                          child: Text(
                            '${isEn ? "Error loading archive" : "Arşiv yüklenirken hata oluştu"}: $e',
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Bottom Padding
                const SliverToBoxAdapter(child: SizedBox(height: 60)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
