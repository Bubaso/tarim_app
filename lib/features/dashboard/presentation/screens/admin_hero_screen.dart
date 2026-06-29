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

    if (heroList.isEmpty && !_isLoading) {
       return const Center(child: CircularProgressIndicator());
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
            const SizedBox(height: 16),
            Expanded(
              child: _buildHeroList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroList() {
    return ReorderableListView.builder(
      itemCount: _heroArticles.length,
      onReorder: _onReorder,
      itemBuilder: (context, index) {
        final article = _heroArticles[index];
        return Card(
          key: ValueKey(article.id),
          elevation: 2,
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
            subtitle: Text('Sıra: ${index + 1}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
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
      updates.add({
        'id': _heroArticles[i].id,
        'hero_order': i + 1,
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
