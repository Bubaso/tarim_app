import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../home/data/models/news_article.dart';
import '../../../home/providers/home_providers.dart';
import '../../../../core/utils/image_fallback_helper.dart';

class AdminHeroScreen extends ConsumerStatefulWidget {
  const AdminHeroScreen({super.key});

  @override
  ConsumerState<AdminHeroScreen> createState() => _AdminHeroScreenState();
}

class _AdminHeroScreenState extends ConsumerState<AdminHeroScreen> {
  List<NewsArticle> _heroArticles = [];
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final heroList = ref.watch(heroArticlesProvider);

    if (_heroArticles.isEmpty && !_isLoading) {
      _heroArticles = List.from(heroList);
    }

    // Boş liste ile YÜKLENİYOR ayrı şeyler. Eskiden ikisi de sonsuz dönen
    // göstergeye düşüyordu: hiç hero haber yoksa ekran hiç açılmıyordu.
    // [heroArticlesProvider] düz bir Provider, durumu kaynağından okuyoruz.
    final kaynak = ref.watch(latestArticlesProvider);
    if (heroList.isEmpty && !_isLoading) {
      if (kaynak.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.article_outlined, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 12),
              Text(
                'Hero alanına koyulacak haber yok.',
                style: GoogleFonts.inter(
                    fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Text(
                'Yayımlanmış ve görseli olan haber bulunduğunda burada listelenir.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hero Haber Yönetimi',
              style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Burada Anasayfa Hero (Manşet) alanındaki 12 haberi sıralayabilir ve değiştirebilirsiniz. Bir haberi kaldırmak için yerine yenisini seçmelisiniz.',
              style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            _buildSabitlemeOzeti(),
            const SizedBox(height: 12),
            _buildTurkiyeSabiti(),
            const SizedBox(height: 12),
            Expanded(
              child: _buildHeroList(),
            ),
          ],
        ),
      ),
    );
  }

  /// Sabitlenmiş haberlerin özeti.
  ///
  /// Sabitleme hero sırasını ELLE donduruyor (`hero_order <= 0`); kaç tane
  /// olduğu ekranda görünmüyordu ve yönetici listeyi tek tek gezmeden
  /// bilemiyordu. Hiç sabit yoksa bunu açıkça söylemek, sıralamanın
  /// kendiliğinden mi yoksa elle mi dizildiğini ayırt ettiriyor.
  Widget _buildSabitlemeOzeti() {
    final sabitler = _heroArticles
        .where((a) => a.heroOrder != null && a.heroOrder! <= 0)
        .toList();
    final bos = sabitler.isEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bos ? Colors.grey.shade100 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: bos ? Colors.grey.shade300 : Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(
            bos ? Icons.push_pin_outlined : Icons.push_pin,
            size: 18,
            color: bos ? Colors.grey.shade600 : Colors.orange.shade700,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              bos
                  ? 'Sabitleme yok — sıralama kendiliğinden diziliyor.'
                  : '${sabitler.length} haber sabitlenmiş: '
                      '${sabitler.map((a) => a.title).join(' · ')}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: bos ? Colors.grey.shade700 : Colors.orange.shade900,
                fontWeight: bos ? FontWeight.w400 : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// "Türkiye'den haberler" bölümünün 2. haberi.
  ///
  /// Manşetin ilk üç slotu yukarıdaki listeden sabitleniyor; dördüncü yayın
  /// kararı bu. Bölümün 1. sırası en taze habere ait kalıyor.
  Widget _buildTurkiyeSabiti() {
    final turkiye = ref.watch(turkeyNewsProvider);
    final sabit = turkiye.where((a) => a.turkiyePin == true).firstOrNull;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.push_pin_rounded, size: 18, color: Colors.blue.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Türkiye'den haberler · 2. haber",
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900)),
                const SizedBox(height: 2),
                Text(
                  sabit?.title ?? 'Seçilmedi — bölüm kendiliğinden diziliyor.',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                      fontSize: 13, color: Colors.blue.shade900),
                ),
              ],
            ),
          ),
          if (sabit != null)
            TextButton(
              onPressed: _isLoading ? null : () => _turkiyeSabitiSec(null),
              child: const Text('Kaldır'),
            ),
          TextButton(
            onPressed: _isLoading ? null : _turkiyeSabitiDialog,
            child: Text(sabit == null ? 'Seç' : 'Değiştir'),
          ),
        ],
      ),
    );
  }

  Future<void> _turkiyeSabitiDialog() async {
    final turkiye = ref.read(turkeyNewsProvider);
    final secilen = await showDialog<NewsArticle>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Türkiye'den haberler · 2. haberi seç",
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 560,
          height: 420,
          child: turkiye.isEmpty
              ? const Center(child: Text('Bölümde haber yok.'))
              : ListView.separated(
                  itemCount: turkiye.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) => ListTile(
                    dense: true,
                    title: Text(turkiye[i].title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(fontSize: 13)),
                    subtitle: Text('Sıra: ${i + 1}',
                        style: GoogleFonts.inter(fontSize: 11)),
                    onTap: () => Navigator.of(ctx).pop(turkiye[i]),
                  ),
                ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Vazgeç')),
        ],
      ),
    );
    if (secilen != null) await _turkiyeSabitiSec(secilen.id);
  }

  Future<void> _turkiyeSabitiSec(String? id) async {
    setState(() => _isLoading = true);
    final ok =
        await ref.read(homeRepositoryProvider).turkiyeSabitiAyarla(id);
    if (!mounted) return;
    setState(() => _isLoading = false);
    ref.invalidate(latestArticlesProvider);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok
          ? (id == null ? 'Sabit kaldırıldı.' : '2. haber ayarlandı.')
          : 'Sabitleme kaydedilemedi.'),
    ));
  }

  Widget _buildHeroList() {
    return ReorderableListView.builder(
      itemCount: _heroArticles.length,
      onReorder: _onReorder,
      itemBuilder: (context, index) {
        final article = _heroArticles[index];
        final isPinned = article.heroOrder != null && article.heroOrder! <= 0;
        // İlk ÜÇ slot elle sabitlenebiliyor (hero_order 0, -1, -2).
        // Dördüncü karar hero'da değil: "Türkiye'den haberler" bölümünün
        // 2. haberi ayrı bir denetim (articles.turkiye_pin).
        const sabitlenebilirSlot = 3;
        final canPin = index < sabitlenebilirSlot;
        
        return Card(
          key: ValueKey(article.id),
          elevation: isPinned ? 4 : 2,
          color: isPinned ? Colors.orange.shade50 : null,
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            leading: SizedBox(
              width: 60,
              height: 40,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: article.imageUrl != null
                    ? NewsArticleImage(imageUrl: article.imageUrl, fit: BoxFit.cover)
                    : Container(color: Colors.grey[300]),
              ),
            ),
            title: Text(
              article.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(isPinned
                ? 'Sabitlenmiş — ${(-article.heroOrder!) + 1}. sıra'
                : 'Sıra: ${index + 1}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isPinned)
                  TextButton.icon(
                    onPressed: () => _toggleHardPin(article, false, index),
                    icon: const Icon(Icons.push_pin, color: Colors.orange),
                    label: const Text('Kaldır', style: TextStyle(color: Colors.orange)),
                  )
                else if (canPin)
                  TextButton.icon(
                    onPressed: () => _toggleHardPin(article, true, index),
                    icon: const Icon(Icons.push_pin_outlined),
                    label: const Text('Bu sıraya sabitle'),
                  ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _replaceArticle(index),
                  icon: const Icon(Icons.swap_horiz_rounded),
                  label: const Text('Değiştir'),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.drag_handle_rounded, color: Colors.grey),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onReorder(int oldIndex, int newIndex) async {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _heroArticles.removeAt(oldIndex);
      _heroArticles.insert(newIndex, item);
      _isLoading = true;
    });

    final repository = ref.read(homeRepositoryProvider);
    final updates = <Map<String, dynamic>>[];
    for (int i = 0; i < _heroArticles.length; i++) {
      final article = _heroArticles[i];
      int newOrder = i + 1;
      
      // Eğer zaten sabitlenmişse ve kendi sırasında duruyorsa sabiti koru
      // Taşınmışsa sabiti boz (normal sıralama değeri alsın)
      if (article.heroOrder != null && article.heroOrder! <= 0) {
        int pinnedIndex = -article.heroOrder!;
        if (pinnedIndex == i) {
          newOrder = article.heroOrder!;
        }
      }

      updates.add({
        'id': article.id,
        'hero_order': newOrder,
      });
    }

    final success = await repository.batchUpdateHeroOrders(updates);
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sıralama güncellenemedi.')),
      );
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      // Refresh provider
      ref.invalidate(latestArticlesProvider);
    }
  }

  Future<void> _toggleHardPin(NewsArticle article, bool pin, int index) async {
    setState(() => _isLoading = true);
    final repository = ref.read(homeRepositoryProvider);
    
    // pin=true ise hero_order = -index (0, -1, -2), pin=false ise normal sıra = index + 1
    int order = pin ? -index : index + 1;
    // Dönüş DEĞERİ okunuyor: eskiden yok sayılıyordu ve yazma düşse bile
    // ekran sabitlenmiş gibi görünüyordu — yönetici kaydedilmemiş bir
    // sabitlemeyi kaydedilmiş sanıyordu (§25.2'nin aynı sınıf hatası).
    final yazildi = await repository.updateHeroStatus(article.id, true, order);
    if (!yazildi && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sabitleme kaydedilemedi.')),
      );
    }
    
    if (mounted) {
      setState(() => _isLoading = false);
      ref.invalidate(latestArticlesProvider);
    }
  }

  Future<void> _replaceArticle(int index) async {
    final oldArticle = _heroArticles[index];
    
    // Show a dialog to select a new article
    final NewsArticle? selectedArticle = await showDialog<NewsArticle>(
      context: context,
      builder: (context) => _ArticleSelectionDialog(currentHeroIds: _heroArticles.map((e) => e.id).toSet()),
    );

    if (selectedArticle != null && mounted) {
      setState(() {
        _isLoading = true;
      });

      final repository = ref.read(homeRepositoryProvider);
      
      // Remove old article from hero
      await repository.updateHeroStatus(oldArticle.id, false, null);
      
      // Add new article to hero at the same order
      await repository.updateHeroStatus(selectedArticle.id, true, index + 1);

      if (mounted) {
        setState(() {
          _isLoading = false;
          // Local update for immediate feedback
          _heroArticles[index] = selectedArticle;
        });
        ref.invalidate(latestArticlesProvider);
      }
    }
  }
}

class _ArticleSelectionDialog extends ConsumerStatefulWidget {
  final Set<String> currentHeroIds;

  const _ArticleSelectionDialog({required this.currentHeroIds});

  @override
  ConsumerState<_ArticleSelectionDialog> createState() => _ArticleSelectionDialogState();
}

class _ArticleSelectionDialogState extends ConsumerState<_ArticleSelectionDialog> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final articlesAsync = ref.watch(latestArticlesProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 600,
        height: 600,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Yeni Haber Seç',
              style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Haber başlığında ara...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: articlesAsync.when(
                data: (articles) {
                  final filtered = articles.where((a) {
                    if (a.status != 'published') return false;
                    if (widget.currentHeroIds.contains(a.id)) return false;
                    if (_searchQuery.isNotEmpty && !a.title.toLowerCase().contains(_searchQuery)) return false;
                    if (a.imageUrl == null || a.imageUrl!.isEmpty) return false;
                    return true;
                  }).toList();

                  return ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final article = filtered[index];
                      return ListTile(
                        leading: SizedBox(
                          width: 50,
                          height: 50,
                          child: NewsArticleImage(imageUrl: article.imageUrl, fit: BoxFit.cover),
                        ),
                        title: Text(article.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                        subtitle: Text(article.sourceName ?? 'Ajans'),
                        onTap: () => Navigator.of(context).pop(article),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Center(child: Text('Hata: $e')),
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('İptal'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
