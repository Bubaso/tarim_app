import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dark_mode.dart';
import '../../../../core/utils/fade_page_route.dart';
import '../../../home/data/models/news_article.dart';
import '../../../home/presentation/screens/article_detail_screen.dart';
import '../../../home/providers/home_providers.dart';

// ══════════════════════════════════════════════════════════════════════════
//  Reddedilenler — "geri alınabilir" vaadinin karşılığı
// ──────────────────────────────────────────────────────────────────────────
//  Red artık SİLMİYOR (§29.1): durumu `rejected` yapıp haberi arşivde
//  bırakıyor ve `reddiGeriAl` onu kuyruğa döndürebiliyor. Ama o metodun tek
//  çağrı yeri sekiz saniyelik bir bildirim çubuğuydu. Çubuk kapandıktan
//  sonra reddedilmiş habere ulaşan hiçbir yüzey yoktu.
//
//  Yani vaat teknik olarak doğru, pratikte sekiz saniyelikti. Yanlışlıkla
//  reddedilen bir haber, kaydı duruyor olmasına rağmen geri getirilemiyordu.
//
//  Ekran bilerek sade: liste, sebep, tarih ve tek bir düğme. Buraya süzme,
//  toplu işlem ya da düzenleme koymak yanlış olurdu — burası bir çalışma
//  alanı değil, bir geri dönüş kapısı.
// ══════════════════════════════════════════════════════════════════════════

final reddedilenlerProvider = StreamProvider<List<NewsArticle>>((ref) {
  return ref.watch(homeRepositoryProvider).reddedilenleriIzle();
});

class ReddedilenlerEkrani extends ConsumerStatefulWidget {
  const ReddedilenlerEkrani({super.key});

  @override
  ConsumerState<ReddedilenlerEkrani> createState() => _ReddedilenlerState();
}

class _ReddedilenlerState extends ConsumerState<ReddedilenlerEkrani> {
  String? _islemdeki;

  Future<void> _geriAl(NewsArticle a) async {
    setState(() => _islemdeki = a.id);
    final repo = ref.read(homeRepositoryProvider);
    final ok = await repo.reddiGeriAl(a.id);
    if (!mounted) return;
    setState(() => _islemdeki = null);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok
            ? 'Haber onay kuyruğuna döndü.'
            : 'Geri alınamadı: ${repo.sonYazmaHatasi ?? 'yetki yok ya da oturum düşmüş'}'),
        backgroundColor: ok ? null : Colors.redAccent,
      ),
    );
    if (ok) {
      ref.invalidate(reddedilenlerProvider);
      ref.invalidate(pendingArticlesProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = appIsDark;
    final metin = isDark ? AppColors.creamBackground : AppColors.earthText;
    final soluk = metin.withValues(alpha: 0.62);

    return ref.watch(reddedilenlerProvider).when(
          loading: () => const Center(child: CircularProgressIndicator()),
          // Hata YUTULMUYOR. Kuyrukta bu hatanın yutulması moderatöre
          // sonsuz dönen bir çark gösteriyordu; aynı tuzağa düşmemek için
          // burada baştan açık bir hata dalı ve yeniden dene düğmesi var.
          error: (e, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cloud_off_rounded, size: 40, color: soluk),
                  const SizedBox(height: 12),
                  Text(
                    'Reddedilenler yüklenemedi.',
                    style: GoogleFonts.outfit(
                        fontSize: 16, fontWeight: FontWeight.w700, color: metin),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$e',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(fontSize: 12.5, color: soluk),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => ref.invalidate(reddedilenlerProvider),
                    child: const Text('Yeniden dene'),
                  ),
                ],
              ),
            ),
          ),
          data: (liste) {
            if (liste.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.inbox_rounded, size: 40, color: soluk),
                      const SizedBox(height: 12),
                      Text(
                        'Reddedilmiş haber yok.',
                        style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: metin),
                      ),
                    ],
                  ),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async => ref.invalidate(reddedilenlerProvider),
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: liste.length + 1,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  if (i == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        '${liste.length} reddedilmiş haber · en son reddedilen üstte',
                        style: GoogleFonts.inter(fontSize: 13, color: soluk),
                      ),
                    );
                  }
                  return _Kart(
                    article: liste[i - 1],
                    isDark: isDark,
                    islemde: _islemdeki == liste[i - 1].id,
                    geriAl: () => _geriAl(liste[i - 1]),
                  );
                },
              ),
            );
          },
        );
  }
}

class _Kart extends StatelessWidget {
  const _Kart({
    required this.article,
    required this.isDark,
    required this.islemde,
    required this.geriAl,
  });

  final NewsArticle article;
  final bool isDark;
  final bool islemde;
  final VoidCallback geriAl;

  String _ne(DateTime? t) {
    if (t == null) return 'tarih yok';
    final f = DateTime.now().difference(t);
    if (f.inMinutes < 60) return '${f.inMinutes} dk önce';
    if (f.inHours < 24) return '${f.inHours} saat önce';
    return '${f.inDays} gün önce';
  }

  @override
  Widget build(BuildContext context) {
    final metin = isDark ? AppColors.creamBackground : AppColors.earthText;
    final soluk = metin.withValues(alpha: 0.62);
    final gerekce = (article.rejectionReason ?? '').trim();

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkGreen : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: isDark ? AppColors.wheat.withValues(alpha: 0.3) : const Color(0xFFE5E5E5)),
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            article.title,
            style: GoogleFonts.outfit(
                fontSize: 15.5, fontWeight: FontWeight.w700, color: metin),
          ),
          const SizedBox(height: 5),
          Wrap(
            spacing: 10,
            runSpacing: 3,
            children: [
              if ((article.sourceName ?? '').trim().isNotEmpty)
                Text(article.sourceName!,
                    style: GoogleFonts.inter(fontSize: 12, color: soluk)),
              Text('Reddedildi: ${_ne(article.rejectedAt)}',
                  style: GoogleFonts.inter(fontSize: 12, color: soluk)),
            ],
          ),
          // Gerekçe VARSA gösteriliyor: toplu red gerekçe sormuyor, yani
          // kayıtların çoğunda boş. Boş bir "Gerekçe: —" satırı kartı
          // uzatmaktan başka iş yapmazdı.
          if (gerekce.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(gerekce,
                style: GoogleFonts.inter(
                    fontSize: 13, color: metin.withValues(alpha: 0.8))),
          ],
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () =>
                    pushScreen(context, ArticleDetailScreen(article: article)),
                icon: const Icon(Icons.visibility_outlined, size: 18),
                label: const Text('Önizle'),
              ),
              const SizedBox(width: 6),
              FilledButton.icon(
                onPressed: islemde ? null : geriAl,
                icon: const Icon(Icons.undo_rounded, size: 18),
                label: Text(islemde ? 'Alınıyor…' : 'Kuyruğa geri al'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
