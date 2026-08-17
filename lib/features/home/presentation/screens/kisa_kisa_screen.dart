import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/fade_page_route.dart';
import '../../data/models/news_article.dart';
import '../../providers/home_providers.dart';
import '../widgets/kisa_kisa_section.dart';

/// 'Kısa Kısa' — kısa haberlerin günlük bülteni.
///
/// Neden ayrı bir sayfa var: kısa haberlerin her biri tek başına ince bir
/// sayfa (iki paragraf, görselsiz). Arama motoru için ince sayfa yığını sitenin
/// tamamının değerlendirmesini aşağı çekiyor. İki seçenek vardı — bu haberleri
/// dizinden çıkarmak (`noindex`) ya da tek bir toplu sayfada birleştirmek.
/// İkincisi seçildi: haber okuyucu için de değerli, sadece tek başına bir
/// sayfayı hak edecek kadar değil. Günlük bülten bunu düzeltiyor: haber
/// erişilebilir kalıyor, dizinde ise ince sayfalar yerine dolu bir sayfa var.
class KisaKisaScreen extends ConsumerWidget {
  const KisaKisaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final articles = ref.watch(briefArticlesProvider);
    final durum = ref.watch(latestArticlesProvider);

    final accent = AppColors.accentFor(isDark: isDark);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkGreen : AppColors.creamBackground,
      appBar: AppBar(
        backgroundColor:
            isDark ? const Color(0xFF080B0E) : const Color(0xFFF3F2ED),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 1.0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: isDark ? Colors.white : Colors.black87,
          ),
          onPressed: () => popScreen(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bolt_rounded, size: 20, color: accent),
            const SizedBox(width: 8),
            Text(
              isEn ? 'IN BRIEF' : 'KISA KISA',
              style: GoogleFonts.playfairDisplay(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: isDark ? AppColors.creamBackground : AppColors.earthText,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
      body: durum.isLoading && articles.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _Icerik(articles: articles, isDark: isDark, isEn: isEn),
    );
  }
}

class _Icerik extends ConsumerWidget {
  final List<NewsArticle> articles;
  final bool isDark;
  final bool isEn;

  const _Icerik({
    required this.articles,
    required this.isDark,
    required this.isEn,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (articles.isEmpty) return _BosDurum(isDark: isDark, isEn: isEn);

    final gunler = _gunlereBol(articles);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(latestArticlesProvider),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _Basluk(
              isDark: isDark,
              isEn: isEn,
              adet: articles.length,
              gunSayisi: gunler.length,
            ),
          ),
          for (final gun in gunler)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _GunBasligi(
                      gun: gun.tarih,
                      adet: gun.haberler.length,
                      isDark: isDark,
                      isEn: isEn,
                    ),
                    const SizedBox(height: 4),
                    BriefArticleList(
                      articles: gun.haberler,
                      isDark: isDark,
                      isEn: isEn,
                    ),
                  ],
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 48)),
        ],
      ),
    );
  }
}

// ─── Gün öbekleri ───────────────────────────────────────────────────────────

class _Gun {
  const _Gun(this.tarih, this.haberler);
  final DateTime tarih;
  final List<NewsArticle> haberler;
}

/// Haberleri yerel takvim gününe göre öbekler.
///
/// Sıralama korunuyor: [briefArticlesProvider] listeyi yeniden eskiye veriyor,
/// bu yüzden ilk görülen gün en yeni gün. Ayrıca sıralamaya gerek yok.
///
/// Gün sınırı UTC'de değil YEREL saatte hesaplanıyor. Aksi hâlde akşam 22:00'de
/// yayımlanan bir haber okuyucuya "yarın" tarihiyle görünüyordu.
List<_Gun> _gunlereBol(List<NewsArticle> articles) {
  final gunler = <_Gun>[];
  for (final a in articles) {
    final yerel = a.createdAt.toLocal();
    final gun = DateTime(yerel.year, yerel.month, yerel.day);
    if (gunler.isNotEmpty && gunler.last.tarih == gun) {
      gunler.last.haberler.add(a);
    } else {
      gunler.add(_Gun(gun, [a]));
    }
  }
  return gunler;
}

class _GunBasligi extends StatelessWidget {
  final DateTime gun;
  final int adet;
  final bool isDark;
  final bool isEn;

  const _GunBasligi({
    required this.gun,
    required this.adet,
    required this.isDark,
    required this.isEn,
  });

  String _etiket() {
    final simdi = DateTime.now();
    final bugun = DateTime(simdi.year, simdi.month, simdi.day);
    final fark = bugun.difference(gun).inDays;
    if (fark == 0) return isEn ? 'Today' : 'Bugün';
    if (fark == 1) return isEn ? 'Yesterday' : 'Dün';
    final locale = isEn ? 'en_US' : 'tr_TR';
    if (gun.year == simdi.year) {
      return DateFormat('d MMMM EEEE', locale).format(gun);
    }
    return DateFormat('d MMMM y', locale).format(gun);
  }

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.accentFor(isDark: isDark);
    final subCol = isDark ? Colors.white54 : Colors.black54;

    return Row(
      children: [
        Text(
          _etiket().toUpperCase(),
          style: GoogleFonts.robotoMono(
            fontSize: AppTypography.minLabelSize,
            fontWeight: FontWeight.w900,
            color: accent,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: Container(height: 1, color: subCol.withValues(alpha: 0.3))),
        const SizedBox(width: 10),
        Text(
          '$adet',
          style: GoogleFonts.robotoMono(
            fontSize: AppTypography.minLabelSize,
            fontWeight: FontWeight.w700,
            color: subCol,
          ),
        ),
      ],
    );
  }
}

// ─── Sayfa başlığı ──────────────────────────────────────────────────────────

class _Basluk extends StatelessWidget {
  final bool isDark;
  final bool isEn;
  final int adet;
  final int gunSayisi;

  const _Basluk({
    required this.isDark,
    required this.isEn,
    required this.adet,
    required this.gunSayisi,
  });

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.accentFor(isDark: isDark);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : Colors.black.withValues(alpha: 0.02),
        border: Border(
          bottom: BorderSide(color: accent.withValues(alpha: 0.3), width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEn ? 'In Brief' : 'Kısa Kısa',
            style: GoogleFonts.playfairDisplay(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: isDark ? AppColors.creamBackground : AppColors.earthText,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isEn
                ? '$adet items · $gunSayisi days'
                : '$adet haber · $gunSayisi gün',
            style: GoogleFonts.robotoMono(
              fontSize: AppTypography.minLabelSize,
              fontWeight: FontWeight.w700,
              color: accent,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Boş durum ──────────────────────────────────────────────────────────────

class _BosDurum extends StatelessWidget {
  final bool isDark;
  final bool isEn;

  const _BosDurum({required this.isDark, required this.isEn});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bolt_outlined,
              size: 56,
              color: isDark ? Colors.white24 : Colors.black26,
            ),
            const SizedBox(height: 20),
            Text(
              isEn
                  ? 'No short items yet.\nThey appear here as sources publish them.'
                  : 'Henüz kısa haber yok.\nKaynaklar yayımladıkça burada görünecek.',
              style: GoogleFonts.inter(
                fontSize: 15,
                color: isDark ? Colors.white54 : Colors.black45,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
