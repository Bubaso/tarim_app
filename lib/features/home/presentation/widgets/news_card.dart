// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/models/news_article.dart';
import '../../../../core/utils/image_fallback_helper.dart';
import '../../../../core/utils/responsive_breakpoints.dart';

class NewsCard extends StatelessWidget {
  final NewsArticle article;

  const NewsCard({
    super.key,
    required this.article,
  });

  Future<void> _launchSourceUrl(BuildContext context, String? urlString) async {
    if (urlString == null || urlString.trim().isEmpty) return;
    final uri = Uri.tryParse(urlString.trim());
    if (uri != null) {
      try {
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          throw 'Could not launch';
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                Localizations.localeOf(context).languageCode == 'en'
                    ? 'Could not open link: $urlString'
                    : 'Bağlantı açılamadı: $urlString',
              ),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    }
  }

  void _showFullArticle(
    BuildContext parentContext,
    String title,
    String summary,
    String content,
    String date,
    String? source,
    ThemeData theme,
    bool isEn,
  ) {
    final isDark = theme.brightness == Brightness.dark;
    showDialog(
      context: parentContext,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: Container(
          color: isDark ? const Color(0xFF0C1015) : const Color(0xFFFAF5EF),
          constraints: const BoxConstraints(maxWidth: 750, maxHeight: 850),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header image with shimmer fallback
              Stack(
                children: [
                  NewsArticleImage(
                    imageUrl: article.imageUrl,
                    height: ResponsiveBreakpoints.isMobile(dialogContext) ? 180 : 300,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: CircleAvatar(
                      backgroundColor: Colors.black.withValues(alpha: 0.6),
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.of(dialogContext).pop(),
                      ),
                    ),
                  ),
                ],
              ),
              
              // Article Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date and Source Header Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (source != null && source.isNotEmpty)
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${isEn ? 'SOURCE' : 'KAYNAK'}: ${source.toUpperCase()}',
                                  style: GoogleFonts.inter(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 10,
                                    letterSpacing: 0.8,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ),
                          Text(
                            date,
                            style: GoogleFonts.robotoMono(
                              color: theme.hintColor,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      // Title
                      Text(
                        title,
                        style: theme.textTheme.headlineLarge?.copyWith(
                          color: isDark ? const Color(0xFFECEFF1) : const Color(0xFF1E3F20),
                          fontFamily: GoogleFonts.playfairDisplay().fontFamily,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Summary box as a beautiful editorial pull-quote
                      if (summary.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.only(left: 18, top: 8, bottom: 8, right: 12),
                          decoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(
                                color: theme.colorScheme.secondary,
                                width: 4.5,
                              ),
                            ),
                          ),
                          child: Text(
                            summary,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark ? const Color(0xFFB0BEC5) : const Color(0xFF5D4037),
                              fontStyle: FontStyle.italic,
                              height: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                      
                      const Divider(height: 1),
                      const SizedBox(height: 20),

                      // Full Body text (serif for ultimate reading experience)
                      Text(
                        content,
                        style: GoogleFonts.lora(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: isDark ? const Color(0xFFCFD8DC) : const Color(0xFF2C2C2A),
                          height: 1.75,
                        ),
                      ),

                      if (article.sourceName != null && article.sourceName!.isNotEmpty &&
                          article.sourceUrl != null && article.sourceUrl!.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        InkWell(
                          onTap: () => _launchSourceUrl(dialogContext, article.sourceUrl),
                          borderRadius: BorderRadius.circular(4),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: theme.colorScheme.primary.withValues(alpha: 0.15),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              '📰 ${article.sourceName} üzerinden oku ↗',
                              style: GoogleFonts.inter(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ],
                      
                      // Keywords
                      if (article.seoKeywords != null && article.seoKeywords!.isNotEmpty) ...[
                        const SizedBox(height: 32),
                        const Divider(),
                        const SizedBox(height: 16),
                        Text(
                          isEn ? 'TAGS' : 'ETİKETLER',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                            color: theme.hintColor,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: article.seoKeywords!.map((keyword) {
                            return Chip(
                              label: Text('#$keyword'),
                              backgroundColor: isDark ? const Color(0xFF1E2631) : const Color(0xFFEBE3D5),
                              labelStyle: GoogleFonts.inter(
                                color: theme.colorScheme.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                              side: BorderSide.none,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            );
                          }).toList(),
                        ),
                      ],
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final isDark = theme.brightness == Brightness.dark;

    final displayTitle = (isEn && article.titleEn != null && article.titleEn!.isNotEmpty)
        ? article.titleEn!
        : article.title;

    final displayContent = (isEn && article.contentEn != null && article.contentEn!.isNotEmpty)
        ? article.contentEn!
        : article.content;

    final displaySummary = (isEn && article.summaryEn != null && article.summaryEn!.isNotEmpty)
        ? article.summaryEn!
        : (article.summary ?? '');

    final sourceLabel = isEn ? 'SOURCE' : 'KAYNAK';
    final hasSource = article.sourceName != null && article.sourceName!.isNotEmpty;

    final formattedDate = DateFormat.yMMMd(isEn ? 'en_US' : 'tr_TR').add_Hm().format(article.createdAt);

    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showFullArticle(
          context,
          displayTitle,
          displaySummary,
          displayContent,
          formattedDate,
          article.sourceName,
          theme,
          isEn,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section with 16:9 Aspect Ratio
            AspectRatio(
              aspectRatio: 16 / 9,
              child: NewsArticleImage(
                imageUrl: article.imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Container(
              color: isDark ? const Color(0xFF121820) : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Source Tag and Date
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (hasSource)
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              '$sourceLabel: ${article.sourceName!.toUpperCase()}',
                              style: GoogleFonts.inter(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w800,
                                fontSize: 9,
                                letterSpacing: 0.5,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        )
                      else
                        const SizedBox.shrink(),
                      const SizedBox(width: 8),
                      Text(
                        formattedDate.toUpperCase(),
                        style: GoogleFonts.robotoMono(
                          color: theme.hintColor,
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Newspaper style title
                  Text(
                    displayTitle,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontFamily: GoogleFonts.playfairDisplay().fontFamily,
                      fontSize: 18,
                      height: 1.25,
                      color: isDark ? const Color(0xFFECEFF1) : const Color(0xFF1E3F20),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Summary (if available) - editorial gray
                  if (displaySummary.isNotEmpty)
                    Text(
                      displaySummary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        color: theme.hintColor,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),

                  // Minimalist legal source line
                  if (article.sourceName != null && article.sourceName!.isNotEmpty &&
                      article.sourceUrl != null && article.sourceUrl!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => _launchSourceUrl(context, article.sourceUrl),
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                        child: Text(
                          '📰 ${article.sourceName} üzerinden oku ↗',
                          style: GoogleFonts.inter(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
