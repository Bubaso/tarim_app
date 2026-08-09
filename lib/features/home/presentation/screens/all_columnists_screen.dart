import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/fade_page_route.dart';
import '../widgets/ai_columnists.dart';
import 'author_article_detail_screen.dart';

class AllColumnistsScreen extends StatelessWidget {
  const AllColumnistsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final title = isEn ? 'Our Columnists' : 'Tüm Yazarlarımız';
    final subtitle = isEn 
        ? 'Expert opinions and deep analyses from the leading voices in agriculture and economics.' 
        : 'Tarım ve ekonomi dünyasının önde gelen isimlerinden uzman görüşleri ve derin analizler.';

    final bgColor = isDark ? const Color(0xFF0F1419) : const Color(0xFFF4F2EC);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? AppColors.wheat : AppColors.earthText),
          onPressed: () => popScreen(context),
        ),
        title: Text(
          isEn ? 'COLUMNISTS' : 'YAZARLAR',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w800,
            fontSize: 12,
            letterSpacing: 2.0,
            color: isDark ? AppColors.primaryGreen : AppColors.primaryGreen,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ─── Header ──────────────────────────────────────────────────
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    color: isDark ? AppColors.creamBackground : AppColors.earthText,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: 60,
                  height: 4,
                  color: AppColors.primaryGreen,
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      height: 1.6,
                      color: isDark ? AppColors.wheat.withOpacity(0.8) : const Color(0xFF555555),
                    ),
                  ),
                ),
                const SizedBox(height: 56),

                // ─── Grid of Columnists ─────────────────────────────────────
                LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    // Responsive columns
                    int columns = 1;
                    if (width > 900) {
                      columns = 3;
                    } else if (width > 600) {
                      columns = 2;
                    }

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: 24,
                        mainAxisSpacing: 32,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: aiColumnists.length,
                      itemBuilder: (context, index) {
                        return _PremiumColumnistCard(
                          columnist: aiColumnists[index],
                          isDark: isDark,
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 64),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PremiumColumnistCard extends StatefulWidget {
  final AiColumnist columnist;
  final bool isDark;

  const _PremiumColumnistCard({required this.columnist, required this.isDark});

  @override
  State<_PremiumColumnistCard> createState() => _PremiumColumnistCardState();
}

class _PremiumColumnistCardState extends State<_PremiumColumnistCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final col = widget.columnist;
    final isDark = widget.isDark;

    final cardBg = isDark ? const Color(0xFF161B22) : Colors.white;
    final borderColor = isDark ? AppColors.wheat.withOpacity(0.1) : const Color(0xFFEAE3CD);
    final nameColor = isDark ? AppColors.primaryGreen : const Color(0xFF1B3B36);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          pushScreen(context, AuthorArticleDetailScreen(columnist: col));
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0, _hovered ? -8 : 0, 0),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _hovered ? AppColors.primaryGreen.withOpacity(0.5) : borderColor,
              width: 1,
            ),
            boxShadow: [
              if (_hovered)
                BoxShadow(
                  color: isDark ? Colors.black.withOpacity(0.5) : Colors.black.withOpacity(0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                )
              else
                BoxShadow(
                  color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Avatar Section with Background Pattern
              Expanded(
                flex: 3,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Subtle background gradient/pattern
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            isDark ? const Color(0xFF1C242C) : const Color(0xFFF7F5F0),
                            isDark ? const Color(0xFF10151A) : const Color(0xFFEBEAE6),
                          ],
                        ),
                      ),
                    ),
                    // Large Quote Mark Watermark
                    Positioned(
                      top: -10,
                      right: -5,
                      child: Text(
                        '"',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 120,
                          height: 1,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03),
                        ),
                      ),
                    ),
                    // Avatar Image
                    Center(
                      child: AnimatedScale(
                        scale: _hovered ? 1.05 : 1.0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.primaryGreen, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              )
                            ],
                            image: DecorationImage(
                              image: NetworkImage(col.avatarUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Info Section
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        col.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: nameColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        Localizations.localeOf(context).languageCode == 'en' ? col.titleEn : col.titleTr,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          height: 1.4,
                          fontWeight: FontWeight.w400,
                          color: isDark ? AppColors.wheat.withOpacity(0.7) : const Color(0xFF777777),
                        ),
                      ),
                      const Spacer(),
                      AnimatedOpacity(
                        opacity: _hovered ? 1.0 : 0.6,
                        duration: const Duration(milliseconds: 200),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              Localizations.localeOf(context).languageCode == 'en' 
                                ? 'View Profile' 
                                : 'Profili İncele',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryGreen,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.primaryGreen),
                          ],
                        ),
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
}
