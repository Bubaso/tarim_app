import 'package:tarim_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../home/data/models/news_article.dart';
import '../../../home/providers/home_providers.dart';
import '../../../../core/utils/localization_helper.dart';

class AdminStatisticsScreen extends ConsumerWidget {
  const AdminStatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // We will watch the latestArticlesProvider to aggregate views.
    final latestArticlesAsync = ref.watch(latestArticlesProvider);
    final loc = AppLocalizations.of(context);

    return latestArticlesAsync.when(
      data: (articles) {
        if (articles.isEmpty) {
          return Center(child: Text(loc.translate('stats_no_data')));
        }

        // Aggregate total views
        final totalViews = articles.fold<int>(0, (sum, a) => sum + (a.viewCount));
        
        // Find top article
        final sorted = List<NewsArticle>.from(articles)..sort((a, b) => b.viewCount.compareTo(a.viewCount));
        final topArticle = sorted.first;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    loc.translate('stats_title'),
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: loc.translate('stats_total_views'),
                      value: totalViews.toString(),
                      icon: Icons.visibility_rounded,
                      color: Colors.blueAccent,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatCard(
                      title: loc.translate('stats_total_articles'),
                      value: articles.length.toString(),
                      icon: Icons.article_rounded,
                      color: Colors.green,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                loc.translate('stats_most_read'),
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkGreen : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? AppColors.wheat : AppColors.wheat),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      topArticle.title,
                      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.local_fire_department_rounded, color: Colors.orangeAccent, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${topArticle.viewCount} ${loc.translate('stats_reads')}',
                          style: GoogleFonts.robotoMono(color: Colors.orangeAccent, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              Text(
                'Onay Bekleyen Haberler (AI)',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _PendingArticlesSection(isDark: isDark),
              const SizedBox(height: 48),
              Text(
                'Haber Okuma Sıralaması (İlk 50)',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              _TopReadArticlesList(isDark: isDark, loc: loc),
              const SizedBox(height: 48),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('${loc.translate('error')} $e')),
    );
  }


}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkGreen : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.wheat : AppColors.wheat),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    color: isDark ? Colors.grey[400] : Colors.grey[700],
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: GoogleFonts.robotoMono(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingArticlesSection extends ConsumerWidget {
  final bool isDark;

  const _PendingArticlesSection({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(pendingArticlesProvider);

    return pendingAsync.when(
      data: (articles) {
        if (articles.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Text(
                'Şu an onay bekleyen haber yok.',
                style: GoogleFonts.inter(color: isDark ? Colors.grey[400] : Colors.grey[600]),
              ),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: articles.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final article = articles[index];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkGreen : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? AppColors.wheat : AppColors.wheat),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    article.summary ?? '',
                    style: GoogleFonts.inter(fontSize: 14, color: isDark ? Colors.grey[400] : Colors.grey[700]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () async {
                          await ref.read(homeRepositoryProvider).rejectArticle(article.id);
                          ref.invalidate(pendingArticlesProvider);
                          ref.invalidate(latestArticlesProvider);
                        },
                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                        label: Text('Reddet', style: GoogleFonts.inter(color: Colors.red, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () async {
                          await ref.read(homeRepositoryProvider).approveArticle(article.id);
                          ref.invalidate(pendingArticlesProvider);
                          ref.invalidate(latestArticlesProvider);
                        },
                        icon: const Icon(Icons.check, size: 20),
                        label: Text('Onayla', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(child: Padding(
        padding: EdgeInsets.all(24.0),
        child: CircularProgressIndicator(),
      )),
      error: (e, st) => Center(child: Text('Hata: $e')),
    );
  }


}

class _TopReadArticlesList extends ConsumerWidget {
  final bool isDark;
  final AppLocalizations loc;

  const _TopReadArticlesList({required this.isDark, required this.loc});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topArticlesAsync = ref.watch(adminTopReadArticlesProvider);

    return topArticlesAsync.when(
      data: (articles) {
        if (articles.isEmpty) {
          return Center(child: Text(loc.translate('stats_no_data')));
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: articles.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final article = articles[index];
            final rank = index + 1;
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkGreen : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? AppColors.wheat : AppColors.wheat),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: rank <= 3 ? Colors.orangeAccent.withOpacity(0.2) : (isDark ? Colors.grey[800] : Colors.grey[200]),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '#$rank',
                      style: GoogleFonts.robotoMono(
                        fontWeight: FontWeight.bold,
                        color: rank <= 3 ? Colors.orangeAccent : (isDark ? Colors.grey[400] : Colors.grey[700]),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          article.title,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.local_fire_department_rounded, color: Colors.orangeAccent, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              '${article.viewCount} okunma',
                              style: GoogleFonts.robotoMono(
                                color: Colors.orangeAccent,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(Icons.access_time_rounded, color: isDark ? Colors.grey[500] : Colors.grey[600], size: 14),
                            const SizedBox(width: 4),
                            Text(
                              '${article.createdAt.day}/${article.createdAt.month}/${article.createdAt.year}',
                              style: GoogleFonts.robotoMono(
                                color: isDark ? Colors.grey[500] : Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Hata: $e')),
    );
  }
}
