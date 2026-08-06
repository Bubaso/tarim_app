// ignore_for_file: deprecated_member_use
import 'package:tarim_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/home_providers.dart';
import '../widgets/ai_columnists.dart';

import '../widgets/news_card.dart';

// ─── Renk sabitleri ───────────────────────────────────────────────────────
const Color _kAccent      = AppColors.primaryGreen;
const Color _kBgLight     = AppColors.creamBackground;
const Color _kBgDark      = AppColors.darkGreen;

class AuthorArticleDetailScreen extends ConsumerWidget {
  final AiColumnist columnist;

  const AuthorArticleDetailScreen({
    super.key,
    required this.columnist,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme  = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isEn = Localizations.localeOf(context).languageCode == 'en';

    final bg     = isDark ? _kBgDark  : _kBgLight;
    final onBg   = isDark ? AppColors.creamBackground : AppColors.earthText;
    final subtle = isDark ? AppColors.wheat : AppColors.earthText;
    final accent = isDark ? _kAccent : _kAccent;
    final headerBg = isDark ? const Color(0xFF161B22) : const Color(0xFFF9F7F1);

    final articlesAsyncValue = ref.watch(latestArticlesProvider);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: headerBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: onBg,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          isEn ? 'Author Archive' : 'Yazar Arşivi',
          style: GoogleFonts.inter(
            color: onBg,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ─── Yazar Kimliği ───────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Container(
                color: headerBg,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
                child: Column(
                  children: [
                    ClipOval(
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.wheat : const Color(0xFFEBEAE6),
                          border: Border.all(
                            color: accent.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Image.network(
                          columnist.avatarUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            alignment: Alignment.center,
                            child: Text(
                              columnist.name[0],
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: subtle,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      columnist.name,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: onBg,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: accent.withOpacity(0.3)),
                      ),
                      child: Text(
                        (isEn ? columnist.titleEn : columnist.titleTr).toUpperCase(),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.robotoMono(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: accent,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // ─── Arşiv Listesi ────────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
              sliver: articlesAsyncValue.when(
                data: (allArticles) {
                  final authorArticles = allArticles.where((a) => a.sourceName?.trim() == columnist.name).toList();
                  
                  if (authorArticles.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40.0),
                          child: Text(
                            isEn ? 'No articles published yet.' : 'Henüz yayımlanmış yazısı bulunmuyor.',
                            style: GoogleFonts.inter(
                              color: subtle,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 24.0),
                          child: NewsCard(
                            article: authorArticles[index],
                          ),
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
          ],
        ),
      ),
    );
  }
}
