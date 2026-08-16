import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/fade_page_route.dart';
import '../../../../core/utils/string_extensions.dart';
import '../../../../core/widgets/article_timestamp.dart';
import '../../../../core/widgets/section_container.dart';
import '../../data/models/news_article.dart';
import '../../providers/home_providers.dart';
import '../screens/article_detail_screen.dart';
import '../screens/kisa_kisa_screen.dart';

/// Ana sayfadaki 'Kısa Kısa' bloğu — kaynağı kısa olduğu için kısa yazılmış
/// haberler.
///
/// Sayfadaki diğer bütün bölümler kart ızgarası: büyük görsel, başlık, spot,
/// "devamını oku". İki paragraflık bir haberi o düzene koymak onu BAŞARISIZ
/// bir uzun haber gibi gösteriyor — kart yarısına kadar boş kalıyor, spot
/// gövdenin neredeyse tamamını tekrar ediyor. Burada biçim bilerek farklı:
/// görsel yok, spot yok, sadece manşet listesi. Ajans bülteni gibi görünsün
/// diye; çünkü gerçekten o.
///
/// Ölçüm: 25 beslemeden çekilen 90 ham girdinin 18'i (%20) kısa haber. Yani
/// blok günlerce boş kalacak bir kenar durum değil, günlük hacmin beşte biri.
class KisaKisaSection extends ConsumerWidget {
  final bool isDark;

  /// Bölümden sonraki boşluk. Emtia şeridindeki kuralın aynısı: boşluğu
  /// bölümün KENDİSİ yayıyor, yerleştiği liste değil. Kısa haber üretilmemiş
  /// bir günde (ya da 507 eski haberden ibaret bir veritabanında) geriye tek
  /// piksel kalmasın, sayfa eskisiyle birebir aynı görünsün diye.
  final double spacing;

  const KisaKisaSection({
    super.key,
    required this.isDark,
    required this.spacing,
  });

  /// Ana sayfada gösterilen en fazla haber sayısı.
  ///
  /// Altı satır bir ekranın yaklaşık yarısı. Daha fazlası bloğu ana sayfanın
  /// omurgası gibi gösterir; oysa bunlar günün ikincil haberleri.
  static const int _onizlemeSayisi = 6;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articles = ref.watch(briefArticlesProvider);
    if (articles.isEmpty) return const SizedBox.shrink();

    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final preview = articles.take(_onizlemeSayisi).toList();

    return Column(
      children: [
        SectionContainer(
          title: isEn ? 'In Brief' : 'Kısa Kısa',
          icon: Icons.bolt_rounded,
          isDark: isDark,
          // "Daha fazla" yalnızca gösterilmeyen haber varken anlamlı. Beş
          // haberlik bir listede tıklandığında aynı beş haberi gösteren bir
          // bağlantı, okuyucuya bir şey saklandığını düşündürüyor.
          onSeeAll: articles.length > _onizlemeSayisi
              ? () => pushScreen(context, const KisaKisaScreen())
              : null,
          child: _BriefList(articles: preview, isDark: isDark, isEn: isEn),
        ),
        SizedBox(height: spacing),
      ],
    );
  }
}

/// Manşet listesi — ana sayfada ve tam sayfada ortak.
class _BriefList extends StatelessWidget {
  final List<NewsArticle> articles;
  final bool isDark;
  final bool isEn;

  const _BriefList({
    required this.articles,
    required this.isDark,
    required this.isEn,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor =
        isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.10);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < articles.length; i++) ...[
          if (i > 0) Container(height: 1, color: borderColor),
          _BriefRow(article: articles[i], isDark: isDark, isEn: isEn),
        ],
      ],
    );
  }
}

/// Tek satır: zaman, manşet, kaynak. Görsel yok, spot yok.
class _BriefRow extends StatefulWidget {
  final NewsArticle article;
  final bool isDark;
  final bool isEn;

  const _BriefRow({
    required this.article,
    required this.isDark,
    required this.isEn,
  });

  @override
  State<_BriefRow> createState() => _BriefRowState();
}

class _BriefRowState extends State<_BriefRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final a = widget.article;
    final title = (widget.isEn && a.titleEn != null && a.titleEn!.isNotEmpty)
        ? a.titleEn!
        : a.title;

    final accent = AppColors.accentFor(isDark: widget.isDark);
    final textCol =
        widget.isDark ? const Color(0xFFE6EDF3) : AppColors.earthText;
    final subCol = widget.isDark ? Colors.white54 : Colors.black54;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => pushScreen(context, ArticleDetailScreen(article: a)),
        child: Container(
          color: _hover
              ? accent.withValues(alpha: widget.isDark ? 0.08 : 0.05)
              : Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sol kenardaki ince vurgu çizgisi. İkon yerine çizgi: altı satır
              // alt alta aynı ikonu tekrarlayınca liste süslü değil gürültülü
              // görünüyor.
              Container(
                width: 3,
                height: 34,
                margin: const EdgeInsets.only(right: 12, top: 2),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: _hover ? 0.9 : 0.35),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: textCol,
                        height: 1.3,
                        decoration: _hover
                            ? TextDecoration.underline
                            : TextDecoration.none,
                        decorationColor: accent,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        ArticleTimestamp(published: a.createdAt, color: subCol),
                        if (a.sourceName != null &&
                            a.sourceName!.isNotEmpty) ...[
                          Text(
                            '  ·  ',
                            style: GoogleFonts.robotoMono(
                              fontSize: AppTypography.minLabelSize,
                              color: subCol,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              a.sourceName!.toTurkishUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.robotoMono(
                                fontSize: AppTypography.minLabelSize,
                                fontWeight: FontWeight.w700,
                                color: subCol,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// [KisaKisaScreen] listeyi aynı satır biçimiyle çizsin diye dışarı açılıyor.
/// Ayrı bir satır widget'ı yazmak, ana sayfa ile tam sayfanın zamanla
/// birbirinden ayrılması demekti.
class BriefArticleList extends StatelessWidget {
  final List<NewsArticle> articles;
  final bool isDark;
  final bool isEn;

  const BriefArticleList({
    super.key,
    required this.articles,
    required this.isDark,
    required this.isEn,
  });

  @override
  Widget build(BuildContext context) =>
      _BriefList(articles: articles, isDark: isDark, isEn: isEn);
}
