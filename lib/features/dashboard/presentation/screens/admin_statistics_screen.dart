import 'package:tarim_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:tarim_app/core/theme/app_dark_mode.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../home/data/models/news_article.dart';
import '../../../home/providers/home_providers.dart';
import '../widgets/inceleme_karti.dart';
import '../../../../core/utils/localization_helper.dart';

class AdminStatisticsScreen extends ConsumerWidget {
  const AdminStatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = appIsDark;
    
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
                    style: GoogleFonts.outfit(
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
                          style: GoogleFonts.inter(color: Colors.orangeAccent, fontWeight: FontWeight.bold),
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
            style: GoogleFonts.inter(
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

class _PendingArticlesSection extends ConsumerStatefulWidget {
  final bool isDark;

  const _PendingArticlesSection({required this.isDark});

  @override
  ConsumerState<_PendingArticlesSection> createState() =>
      _PendingArticlesSectionState();
}

// ══════════════════════════════════════════════════════════════════════════════
//  Onay kuyruğu
// ──────────────────────────────────────────────────────────────────────────────
//  Üç davranış:
//
//  1. RED KAYDEDİLİR. Eski "Reddet" kaydı doğrudan siliyordu; aynı kaynak
//     ertesi gün aynı haberi getirince moderatör onu ilk kez görüyormuş gibi
//     tekrar eliyordu. Artık `rejected_sources`'a yazılıyor (bkz.
//     HomeRepository.haberiReddet) ve `source_scorecard` karnesini besliyor.
//
//  2. TOPLU RED. Kuyruk bazen tek bir bozuk kaynaktan gelen onlarca haberle
//     doluyor; tek tek elemek işin kendisinden uzun sürüyordu.
//
//  3. TAM HABER. Özet iki satır; "bu haber gerçekten yayına girmeli mi"
//     kararı çoğu zaman özetle verilemiyor. Gövdeyi reddetmeden önce
//     okuyabilmek gerekiyor.
// ══════════════════════════════════════════════════════════════════════════════

class _PendingArticlesSectionState
    extends ConsumerState<_PendingArticlesSection> {
  final Set<String> _secili = <String>{};
  String? _acikInceleme;
  bool _islemde = false;

  bool get isDark => widget.isDark;

  @override
  Widget build(BuildContext context) {
    final pendingAsync = ref.watch(pendingArticlesProvider);

    return pendingAsync.when(
      data: (articles) {
        if (articles.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Text(
                'Şu an onay bekleyen haber yok.',
                style: GoogleFonts.inter(
                    color: isDark ? Colors.grey[400] : Colors.grey[600]),
              ),
            ),
          );
        }

        // Kuyruk değiştiyse artık var olmayan seçimleri düşür; yoksa "3 seçili"
        // deyip 1 haber reddedilirdi.
        _secili.removeWhere((id) => !articles.any((a) => a.id == id));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _topluCubuk(articles),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: articles.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) =>
                  _kart(context, articles[index]),
            ),
          ],
        );
      },
      loading: () => const Center(
          child: Padding(
        padding: EdgeInsets.all(24.0),
        child: CircularProgressIndicator(),
      )),
      error: (e, st) => Center(child: Text('Hata: $e')),
    );
  }

  Widget _topluCubuk(List<NewsArticle> articles) {
    final hepsiSecili =
        articles.isNotEmpty && _secili.length == articles.length;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Checkbox(
            value: hepsiSecili,
            tristate: false,
            onChanged: _islemde
                ? null
                : (v) => setState(() {
                      _secili.clear();
                      if (v == true) {
                        _secili.addAll(articles.map((a) => a.id));
                      }
                    }),
          ),
          Text(
            _secili.isEmpty
                ? 'Tümünü seç'
                : '${_secili.length} haber seçili',
            style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey[300] : Colors.grey[800]),
          ),
          const Spacer(),
          if (_secili.isNotEmpty)
            TextButton.icon(
              onPressed:
                  _islemde ? null : () => _topluReddet(articles),
              icon: const Icon(Icons.playlist_remove_rounded,
                  color: Colors.red, size: 20),
              label: Text('Toplu red',
                  style: GoogleFonts.inter(
                      color: Colors.red, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }

  Widget _kart(BuildContext context, NewsArticle article) {
    final secili = _secili.contains(article.id);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkGreen : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: secili ? Colors.red.shade300 : AppColors.wheat),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: secili,
                onChanged: _islemde
                    ? null
                    : (v) => setState(() {
                          if (v == true) {
                            _secili.add(article.id);
                          } else {
                            _secili.remove(article.id);
                          }
                        }),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black),
                    ),
                    if ((article.sourceName ?? '').isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        article.sourceName!,
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            color: isDark
                                ? Colors.grey[500]
                                : Colors.grey[600]),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            article.summary ?? '',
            style: GoogleFonts.inter(
                fontSize: 14,
                color: isDark ? Colors.grey[400] : Colors.grey[700]),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 8,
            runSpacing: 8,
            children: [
              TextButton.icon(
                onPressed: () => setState(() {
                  if (_acikInceleme == article.id) {
                    _acikInceleme = null;
                  } else {
                    _acikInceleme = article.id;
                  }
                }),
                icon: Icon(
                    _acikInceleme == article.id
                        ? Icons.expand_less_rounded
                        : Icons.fact_check_outlined,
                    size: 20),
                label: Text(
                    _acikInceleme == article.id ? 'İncelemeyi kapat' : 'İncele',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              ),
              TextButton.icon(
                onPressed: () => _tamHaberiGoster(context, article),
                icon: const Icon(Icons.article_outlined, size: 20),
                label: Text('Tam haber',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              ),
              TextButton.icon(
                onPressed: _islemde ? null : () => _tekReddet(article),
                icon: const Icon(Icons.delete_outline,
                    color: Colors.red, size: 20),
                label: Text('Haberi reddet',
                    style: GoogleFonts.inter(
                        color: Colors.red, fontWeight: FontWeight.bold)),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _islemde
                    ? null
                    : () async {
                        await ref
                            .read(homeRepositoryProvider)
                            .approveArticle(article.id);
                        _tazele();
                      },
                icon: const Icon(Icons.check, size: 20),
                label: Text('Onayla',
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          if (_acikInceleme == article.id) ...[
            const SizedBox(height: 14),
            IncelemeKarti(
              article: article,
              isDark: isDark,
              onDegisti: _tazele,
            ),
          ],
        ],
      ),
    );
  }

  /// Gövdeyi okunur hâle getirip gösterir. Hat HTML yazıyor; etiketleri
  /// olduğu gibi göstermek kararı kolaylaştırmaz, o yüzden sadeleştiriliyor.
  void _tamHaberiGoster(BuildContext context, NewsArticle article) {
    final govde = article.content
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</p>', caseSensitive: false), '\n\n')
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(article.title,
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 640,
          child: SingleChildScrollView(
            child: Text(
              govde.isEmpty ? 'Bu haberin gövdesi boş.' : govde,
              style: GoogleFonts.inter(fontSize: 14, height: 1.6),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  Future<void> _tekReddet(NewsArticle article) async {
    setState(() => _islemde = true);
    final ok = await ref.read(homeRepositoryProvider).haberiReddet(
          id: article.id,
          title: article.title,
          sourceUrl: article.sourceUrl,
          sourceName: article.sourceName,
          lastStatus: article.status,
        );
    _secili.remove(article.id);
    if (ok) {
      // Red artık SİLMİYOR, durumu değiştiriyor (§29.1) — o yüzden geri
      // alınabilir ve bunu söylemek gerekiyor. Yanlış basılan bir düğme
      // eskiden geri getirilemeyecek bir kaydı yok ediyordu.
      _bildirGeriAlinabilir(
          'Haber reddedildi. Arşivde duruyor, geri alınabilir.', article.id);
    } else {
      _bildir('Reddetme başarısız — yetki yok ya da kayıt yazılamadı.');
    }
    _tazele();
  }

  Future<void> _topluReddet(List<NewsArticle> articles) async {
    final hedef =
        articles.where((a) => _secili.contains(a.id)).toList(growable: false);
    if (hedef.isEmpty) return;

    final onay = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Toplu red',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Text(
          '${hedef.length} haber reddedilecek. Reddedilen adresler '
          'kaydedilir, aynı haber tekrar kuyruğa düşmez.',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Vazgeç')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Reddet',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (onay != true) return;

    setState(() => _islemde = true);
    final sayi = await ref.read(homeRepositoryProvider).topluReddet(
          hedef
              .map((a) => <String, String?>{
                    'id': a.id,
                    'title': a.title,
                    'source_url': a.sourceUrl,
                    'source_name': a.sourceName,
                    'last_status': a.status,
                  })
              .toList(),
        );
    _secili.clear();
    // Gerçekleşen sayıyı söylüyoruz, istenen sayıyı değil.
    _bildir(sayi == hedef.length
        ? '$sayi haber reddedildi. Arşivde duruyor, geri alınabilir.'
        : '$sayi / ${hedef.length} haber reddedildi; kalanlar kuyrukta.');
    _tazele();
  }

  /// Reddi geri almayı teklif eden bildirim.
  ///
  /// `articles_forget_rejection_status` tetikleyicisi adresi red hafızasından
  /// da düşürüyor; yoksa haber kuyruğa döner ama hat onu bir daha getirmez.
  void _bildirGeriAlinabilir(String mesaj, String id) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(mesaj),
      duration: const Duration(seconds: 8),
      action: SnackBarAction(
        label: 'Geri al',
        onPressed: () async {
          final ok = await ref.read(homeRepositoryProvider).reddiGeriAl(id);
          _bildir(ok ? 'Red geri alındı.' : 'Geri alınamadı.');
          _tazele();
        },
      ),
    ));
  }

  void _bildir(String mesaj) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mesaj)));
  }

  void _tazele() {
    if (!mounted) return;
    setState(() => _islemde = false);
    ref.invalidate(pendingArticlesProvider);
    ref.invalidate(latestArticlesProvider);
    ref.invalidate(kaynakKarnesiProvider);
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
                      style: GoogleFonts.inter(
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
                              style: GoogleFonts.inter(
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
                              style: GoogleFonts.inter(
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
