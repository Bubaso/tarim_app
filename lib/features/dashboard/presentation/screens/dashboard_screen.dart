import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/network/supabase_client.dart';
import '../../../../core/utils/responsive_breakpoints.dart';
import '../../../../core/utils/localization_helper.dart';
import '../../../../main.dart';
import '../../../home/data/models/news_article.dart';
import '../../../home/data/models/ai_suggestion.dart';
import '../../../home/providers/home_providers.dart';
import '../../../../core/utils/image_fallback_helper.dart';
import 'admin_statistics_screen.dart';

// Riverpod providers for categories and assignments
final categoriesFutureProvider = FutureProvider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(homeRepositoryProvider).fetchCategories();
});

final assignmentsFutureProvider = FutureProvider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(homeRepositoryProvider).fetchArticleAssignments();
});

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _titleController = TextEditingController();
  final _summaryController = TextEditingController();
  final _contentController = TextEditingController();
  final _locationController = TextEditingController();

  String? _selectedCategoryId;
  bool _isSubmitting = false;
  bool _showMobileForm = false; // Toggle to show form on mobile instead of list
  bool _showArchived = false; // Toggle to view unpublished/archived articles
  final Set<int> _generatingSuggestionIds = {}; // Track generating suggestions

  NewsArticle? _editingArticle;

  // Default fallback categories if DB has none (matching DB UUIDs)
  final List<Map<String, String>> _fallbackCategories = [
    {'id': '9f6723f9-4375-45b7-8cd9-12db2b8acb5d', 'name': 'Tarım'},
    {'id': '96d751bc-1125-448d-80b4-945522fa4646', 'name': 'Hayvancılık'},
    {'id': 'dc9c0ffc-b462-4495-88db-ee4ffb5c8412', 'name': 'Ekonomi'},
    {'id': '4753361f-3bbd-4118-9a46-ecccd5cf8367', 'name': 'Teknoloji'},
  ];

  // Coordinates mapping for Turkey cities [longitude, latitude]
  static const Map<String, List<double>> _turkeyCitiesGeo = {
    'adana': [35.3308, 36.9939],
    'adiyaman': [38.2786, 37.7648],
    'afyonkarahisar': [30.5387, 38.7569],
    'agri': [43.0519, 39.7225],
    'amasya': [35.8336, 40.6499],
    'ankara': [32.8597, 39.9334],
    'antalya': [30.7133, 36.8969],
    'artvin': [41.8208, 41.1828],
    'aydin': [27.8568, 37.8444],
    'balikesir': [27.8841, 39.6484],
    'bilecik': [29.9799, 40.1419],
    'bingol': [40.4939, 38.8847],
    'bitlis': [42.1095, 38.4006],
    'bolu': [31.6082, 40.7358],
    'burdur': [30.2908, 37.7203],
    'bursa': [29.0660, 40.1826],
    'canakkale': [26.4086, 40.1553],
    'cankiri': [33.6153, 40.6013],
    'corum': [34.9537, 40.5506],
    'denizli': [29.0864, 37.7760],
    'diyarbakir': [40.2306, 37.9144],
    'edirne': [26.5592, 41.6772],
    'elazig': [39.2269, 38.6810],
    'erzincan': [39.4902, 39.7500],
    'erzurum': [41.2679, 39.9043],
    'eskisehir': [30.5206, 39.7767],
    'gaziantep': [37.3833, 37.0662],
    'giresun': [38.3895, 40.9128],
    'gumushane': [39.4814, 40.4600],
    'hakkari': [43.7408, 37.5833],
    'hatay': [36.1667, 36.2000],
    'isparta': [30.5560, 37.7648],
    'mersin': [34.6415, 36.8121],
    'istanbul': [28.9784, 41.0082],
    'izmir': [27.1428, 38.4237],
    'kars': [43.0875, 40.6019],
    'kastamonu': [33.7753, 41.3887],
    'kayseri': [35.4826, 38.7205],
    'kirklareli': [27.2244, 41.7351],
    'kirsehir': [34.1639, 39.1425],
    'kocaeli': [29.8815, 40.8533],
    'konya': [32.4847, 37.8714],
    'kutahya': [29.9858, 39.4242],
    'malatya': [38.3167, 38.3553],
    'manisa': [27.4264, 38.6191],
    'kahramanmaras': [36.9547, 37.5085],
    'mardin': [40.7339, 37.3212],
    'mugla': [28.3667, 37.2181],
    'mus': [41.4911, 38.7432],
    'nevsehir': [34.7142, 38.6244],
    'nigde': [34.6858, 37.9697],
    'ordu': [37.8797, 40.9862],
    'rize': [40.5178, 41.0201],
    'sakarya': [30.4034, 40.7569],
    'samsun': [36.3300, 41.2867],
    'siirt': [41.9420, 37.9333],
    'sinop': [35.1628, 42.0268],
    'sivas': [37.0150, 39.7478],
    'tekirdag': [27.5110, 40.9780],
    'tokat': [36.5544, 40.3167],
    'trabzon': [39.7168, 41.0027],
    'tunceli': [39.5473, 39.1075],
    'sanliurfa': [38.7969, 37.1591],
    'usak': [29.4059, 38.6823],
    'van': [43.3833, 38.5000],
    'yozgat': [34.8147, 39.8181],
    'zonguldak': [31.7908, 41.4564],
    'aksaray': [34.0253, 38.3687],
    'bayburt': [40.2280, 40.2552],
    'karaman': [33.2150, 37.1759],
    'kirikkale': [33.5089, 39.8468],
    'batman': [41.1293, 37.8812],
    'sirnak': [42.4918, 37.5164],
    'bartin': [32.3338, 41.6344],
    'ardahan': [42.7022, 41.1105],
    'igdir': [44.0436, 39.9200],
    'yalova': [29.2802, 40.6549],
    'karabuk': [32.6277, 41.1956],
    'kilis': [37.1150, 36.7161],
    'osmaniye': [36.2467, 37.0742],
    'duzce': [31.1625, 40.8438]
  };

  // Proposed topics fallback for Tab 2
  final List<Map<String, String>> _proposedTopics = [
    {
      'title': 'Akıllı Sulama Sistemleri ve Su Tasarrufu',
      'description': 'IoT destekli nem sensörleri ile tarımda su verimliliğini artıran yeni teknolojilerin incelenmesi.',
      'category': 'Tarım Teknolojileri',
    },
    {
      'title': 'Gökçeada Organik Zeytinyağı Üretim Raporu',
      'description': 'Gökçeada zeytin üreticilerinin organik tarım sertifikasyon süreçleri ve ihracat potansiyeli.',
      'category': 'Bahçe Bitkileri',
    },
    {
      'title': 'Yem Fiyatlarındaki Değişimlerin Süt Üreticilerine Etkisi',
      'description': 'Son 6 aydaki yem maliyetleri ve süt kooperatiflerinin güncel süt taban fiyatı analizleri.',
      'category': 'Hayvancılık',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _summaryController.dispose();
    _contentController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  // Map city name to a WKT representation POINT(longitude latitude) for PostGIS
  String _getGeoLocationFromCity(String city) {
    final cleanCity = city
        .toLowerCase()
        .replaceAll('ı', 'i')
        .replaceAll('ğ', 'g')
        .replaceAll('ü', 'u')
        .replaceAll('ş', 's')
        .replaceAll('ö', 'o')
        .replaceAll('ç', 'c')
        .trim();

    final coords = _turkeyCitiesGeo[cleanCity];
    if (coords != null) {
      return 'POINT(${coords[0]} ${coords[1]})';
    }
    
    // Default coordinates: Ankara
    return 'POINT(32.8597 39.9334)';
  }

  String _getCityFromGeoLocation(String? geo) {
    if (geo == null || geo.isEmpty) return '';
    final match = RegExp(r'POINT\(([^ ]+) ([^ ]+)\)').firstMatch(geo);
    if (match != null) {
      final lon = double.tryParse(match.group(1)!);
      final lat = double.tryParse(match.group(2)!);
      if (lon != null && lat != null) {
        for (final entry in _turkeyCitiesGeo.entries) {
          if ((entry.value[0] - lon).abs() < 0.01 && (entry.value[1] - lat).abs() < 0.01) {
            return entry.key[0].toUpperCase() + entry.key.substring(1);
          }
        }
      }
    }
    return '';
  }

  Future<void> _submitArticle({bool isPublishing = false, bool isUnpublishing = false}) async {
    if (!isUnpublishing && !_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    final title = _titleController.text.trim();
    final summary = _summaryController.text.trim();
    final content = _contentController.text.trim();
    final location = _locationController.text.trim();

    // Map city to WKT geo_location POINT(longitude latitude)
    final geoLocation = _getGeoLocationFromCity(location);

    final isEditing = _editingArticle != null;

    // Construct the article for Supabase insertion/update
    final article = NewsArticle(
      id: isEditing ? _editingArticle!.id : const Uuid().v4(),
      title: title,
      titleEn: _editingArticle?.titleEn,
      content: content,
      contentEn: _editingArticle?.contentEn,
      summary: summary,
      summaryEn: _editingArticle?.summaryEn,
      imageUrl: _editingArticle?.imageUrl,
      seoKeywords: _editingArticle?.seoKeywords,
      sourceName: _editingArticle?.sourceName,
      sourceUrl: _editingArticle?.sourceUrl,
      viewCount: _editingArticle?.viewCount ?? 0,
      createdAt: isEditing ? _editingArticle!.createdAt : DateTime.now(),
      status: isUnpublishing ? 'draft' : (isPublishing ? 'published' : (isEditing ? (_editingArticle!.status ?? 'reviewing') : 'reviewing')),
      categoryId: _selectedCategoryId,
      geoLocation: geoLocation,
    );

    // Call submit through repository
    final repository = ref.read(homeRepositoryProvider);
    final errorMessage = isEditing 
        ? await repository.updateArticle(article)
        : (await repository.submitArticleByAuthor(article) ? null : 'Failed to insert');

    setState(() {
      _isSubmitting = false;
    });

    if (mounted) {
      if (errorMessage == null) {
        final loc = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
            content: Text(isEditing ? 'Makale başarıyla güncellendi!' : loc.translate('form_success')),
            backgroundColor: Colors.green,
          ),
        );
        _cancelEdit();
        
        // Refresh articles list and invalidate stream provider to pull new values
        ref.invalidate(latestArticlesProvider);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
            content: Text('Hata: $errorMessage'),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _cancelEdit() {
    _titleController.clear();
    _summaryController.clear();
    _contentController.clear();
    _locationController.clear();
    setState(() {
      _selectedCategoryId = null;
      _showMobileForm = false;
      _editingArticle = null;
    });
  }

  Future<void> _signOut() async {
    try {
      await ref.read(supabaseClientProvider).auth.signOut();
      if (mounted) {
        final loc = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
            content: Text(loc.translate('dash_logout_success')),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MyApp()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        final loc = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${loc.translate('error')} $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider);
    final isDesktop = ResponsiveBreakpoints.isDesktopOrLarger(context);
    final loc = AppLocalizations.of(context);
    final isEn = Localizations.localeOf(context).languageCode == 'en';

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('dash_title')),
        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.hintColor,
          indicatorColor: theme.colorScheme.primary,
          tabs: [
            Tab(
              icon: const Icon(Icons.newspaper_rounded),
              text: loc.translate('dash_tab_my_articles'),
            ),
            Tab(
              icon: const Icon(Icons.category_rounded),
              text: isEn ? 'Categories' : 'Kategoriler',
            ),
            Tab(
              icon: const Icon(Icons.psychology_rounded),
              text: loc.translate('dash_tab_ai_suggestions'),
            ),
            Tab(
              icon: const Icon(Icons.bar_chart_rounded),
              text: loc.translate('dash_tab_stats'),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: loc.translate('dash_logout'),
            onPressed: _signOut,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildArticlesAndFormTab(context, theme, user, isDesktop),
          _buildAssignmentsTab(context, theme),
          _buildAiSuggestionsTab(context, theme),
          const AdminStatisticsScreen(),
        ],
      ),
    );
  }

  // Tab 1: Articles and Submission Form
  Widget _buildArticlesAndFormTab(BuildContext context, ThemeData theme, dynamic user, bool isDesktop) {
    final articlesAsync = ref.watch(latestArticlesProvider);
    final loc = AppLocalizations.of(context);

    if (isDesktop) {
      // Side-by-side split layout on desktop
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left side: My articles list
          Expanded(
            flex: 3,
            child: _buildMyArticlesList(context, theme, articlesAsync),
          ),
          const VerticalDivider(width: 1),
          // Right side: New article submission form
          Expanded(
            flex: 4,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _buildSubmissionForm(context, theme),
            ),
          ),
        ],
      );
    } else {
      // Mobile & Tablet: Toggle between list and form
      return _showMobileForm
          ? SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded),
                        onPressed: () {
                          setState(() {
                            _showMobileForm = false;
                          });
                        },
                      ),
                      Text(
                        loc.translate('dash_tab_my_articles'), // Listeye Dön doesn't exist, I'll use my_articles or we can just use "Back to List" if I add it. Actually, I can just use isEn.
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildSubmissionForm(context, theme),
                ],
              ),
            )
          : Stack(
              children: [
                _buildMyArticlesList(context, theme, articlesAsync),
                Positioned(
                  bottom: 24,
                  right: 24,
                  child: FloatingActionButton.extended(
                    onPressed: () {
                      setState(() {
                        _showMobileForm = true;
                      });
                    },
                    icon: const Icon(Icons.add_circle_outline_rounded),
                    label: Text(loc.translate('dash_tab_write')),
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            );
    }
  }

  // Tab 2: Assignments and Proposed Topics
  Widget _buildAssignmentsTab(BuildContext context, ThemeData theme) {
    final assignmentsAsync = ref.watch(assignmentsFutureProvider);
    final loc = AppLocalizations.of(context);
    final isEn = loc.locale.languageCode == 'en';

    return RefreshIndicator(
      onRefresh: () async => ref.refresh(assignmentsFutureProvider),
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            loc.locale.languageCode == 'en' ? 'My Assignments' : 'Bana Atanan Görevler',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          assignmentsAsync.when(
            data: (assignments) {
              if (assignments.isEmpty) {
                return Card(
                  elevation: 0,
                  color: theme.colorScheme.surface,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.assignment_turned_in_rounded,
                          size: 48,
                          color: theme.colorScheme.primary.withValues(alpha: 0.6),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          isEn ? 'You have no active assignments.' : 'Atanmış aktif bir göreviniz bulunmuyor.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.hintColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: assignments.length,
                itemBuilder: (context, index) {
                  final item = assignments[index];
                  final status = item['status']?.toString() ?? 'pending';
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 24,
                          backgroundColor: (status == 'completed' ? Colors.green : Colors.orange).withValues(alpha: 0.15),
                          child: Icon(
                            status == 'completed' ? Icons.check_circle_rounded : Icons.pending_rounded,
                            color: status == 'completed' ? Colors.green : Colors.orange,
                            size: 24,
                          ),
                        ),
                        title: Text(
                          item['title']?.toString() ?? 'Konu',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            item['description']?.toString() ?? '',
                            style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                          ),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: status == 'completed' ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            status.toUpperCase(),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: status == 'completed' ? Colors.green.shade700 : Colors.orange.shade700,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (err, stack) => Card(
              color: Colors.redAccent.withValues(alpha: 0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('${loc.translate('error')} $err', style: const TextStyle(color: Colors.red)),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            isEn ? 'Proposed Topics' : 'Teklif Edilen Konular',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _proposedTopics.length,
            itemBuilder: (context, index) {
              final topic = _proposedTopics[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.15),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.category_rounded, size: 14, color: theme.colorScheme.secondary),
                                const SizedBox(width: 6),
                                Text(
                                  topic['category'] ?? '',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.secondary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle_outline_rounded, size: 14, color: theme.colorScheme.primary),
                                const SizedBox(width: 6),
                                Text(
                                  isEn ? 'Open for Writing' : 'Yazıya Açık',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        topic['title'] ?? '',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        topic['description'] ?? '',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.hintColor,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerRight,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            setState(() {
                              _titleController.text = topic['title'] ?? '';
                              _summaryController.text = topic['description'] ?? '';
                              _contentController.text = 'Bu konu hakkında araştırma ve editoryal yazım devam etmektedir...';
                              _locationController.text = 'Konya';
                              
                              final categoryStr = topic['category'] ?? '';
                              if (categoryStr.contains('Teknoloji')) {
                                _selectedCategoryId = '4753361f-3bbd-4118-9a46-ecccd5cf8367'; // Teknoloji
                              } else if (categoryStr.contains('Hayvancılık')) {
                                _selectedCategoryId = '96d751bc-1125-448d-80b4-945522fa4646'; // Hayvancılık
                              } else if (categoryStr.contains('Ekonomi')) {
                                _selectedCategoryId = 'dc9c0ffc-b462-4495-88db-ee4ffb5c8412'; // Ekonomi
                              } else {
                                _selectedCategoryId = '9f6723f9-4375-45b7-8cd9-12db2b8acb5d'; // Tarım
                              }
                            });
                            
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('"${topic['title']}" konusu Yazı Gönder formuna başarıyla aktarıldı!'),
                                backgroundColor: theme.colorScheme.primary,
                              ),
                            );

                            // Switch to Tab 1 (Index 0)
                            _tabController.animateTo(0);
                          },
                          icon: const Icon(Icons.edit_note_rounded),
                          label: const Text('Görevi Al & Yaz'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Sub-widget: Submission Form
  Widget _buildSubmissionForm(BuildContext context, ThemeData theme) {
    final categoriesAsyncValue = ref.watch(categoriesFutureProvider);
    final loc = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.edit_document,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    loc.translate('write_article_title'),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                loc.translate('write_article_desc'),
                style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
              ),
              const Divider(height: 24),
              
              // Turkish Title
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: loc.translate('form_title'),
                  hintText: loc.translate('form_title_hint'),
                  prefixIcon: const Icon(Icons.title_rounded),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? loc.translate('form_err_title') : null,
              ),
              const SizedBox(height: 16),

              // Summary (Özet)
              TextFormField(
                controller: _summaryController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: loc.translate('form_summary'),
                  hintText: loc.translate('form_summary_hint'),
                  prefixIcon: const Icon(Icons.summarize_rounded),
                  alignLabelWithHint: true,
                ),
                validator: (val) => val == null || val.trim().isEmpty ? loc.translate('form_err_summary') : null,
              ),
              const SizedBox(height: 16),

              // Turkish Content
              TextFormField(
                controller: _contentController,
                maxLines: 12,
                decoration: InputDecoration(
                  labelText: loc.translate('form_body'),
                  hintText: loc.translate('form_body_hint'),
                  alignLabelWithHint: true,
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                  ),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? loc.translate('form_err_body') : null,
              ),
              const SizedBox(height: 16),

              // Category dropdown loaded from DB or fallbacks
              categoriesAsyncValue.when(
                data: (categories) {
                  final list = categories.isEmpty 
                      ? _fallbackCategories 
                      : categories.map((e) => {'id': e['id'].toString(), 'name': e['name'].toString()}).toList();
                  
                  return DropdownButtonFormField<String>(
                    // ignore: deprecated_member_use
                    value: list.any((c) => c['id'] == _selectedCategoryId) ? _selectedCategoryId : null,
                    decoration: InputDecoration(
                      labelText: '${loc.translate('form_category')} *',
                      prefixIcon: const Icon(Icons.category_rounded),
                    ),
                    items: list.map((cat) {
                      return DropdownMenuItem<String>(
                        value: cat['id'],
                        child: Text(cat['name'] ?? ''),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedCategoryId = val;
                      });
                    },
                    validator: (val) => val == null || val.isEmpty ? loc.translate('form_err_category') : null,
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (err, stack) => DropdownButtonFormField<String>(
                  // ignore: deprecated_member_use
                  value: _fallbackCategories.any((c) => c['id'] == _selectedCategoryId) ? _selectedCategoryId : null,
                  decoration: InputDecoration(
                    labelText: '${loc.translate('form_category')} (Yerel) *',
                    prefixIcon: const Icon(Icons.category_rounded),
                  ),
                  items: _fallbackCategories.map((cat) {
                    return DropdownMenuItem<String>(
                      value: cat['id'],
                      child: Text(cat['name'] ?? ''),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedCategoryId = val;
                    });
                  },
                  validator: (val) => val == null || val.isEmpty ? loc.translate('form_err_category') : null,
                ),
              ),
              const SizedBox(height: 16),

              // Location / City Name (e.g. Konya, Mersin)
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: loc.translate('form_location'),
                  hintText: loc.translate('form_location_hint'),
                  prefixIcon: const Icon(Icons.location_on_rounded),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? loc.translate('form_err_location') : null,
              ),
              const SizedBox(height: 24),

              // Submit and Cancel Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isSubmitting ? null : () => _submitArticle(isPublishing: false),
                      icon: _isSubmitting 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Icon(_editingArticle != null ? Icons.save_rounded : Icons.send_rounded),
                      label: Text(_isSubmitting 
                          ? loc.translate('form_submitting') 
                          : (_editingArticle != null ? 'Güncelle' : loc.translate('form_submit'))),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  if (_editingArticle != null) ...[
                    const SizedBox(width: 12),
                    if (_editingArticle!.status == 'published')
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isSubmitting ? null : () => _submitArticle(isUnpublishing: true),
                          icon: const Icon(Icons.archive_rounded),
                          label: const Text('Yayından Çek'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isSubmitting ? null : () => _submitArticle(isPublishing: true),
                          icon: const Icon(Icons.public_rounded),
                          label: const Text('Yayınla'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isSubmitting ? null : _cancelEdit,
                        icon: const Icon(Icons.cancel_rounded),
                        label: const Text('İptal'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Sub-widget: Left list showing all previous submissions
  Widget _buildMyArticlesList(BuildContext context, ThemeData theme, AsyncValue<List<NewsArticle>> articlesAsync) {
    final loc = AppLocalizations.of(context);
    final isEn = loc.locale.languageCode == 'en';
    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(latestArticlesProvider),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.translate('dash_tab_my_articles'),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _showArchived ? 'Yayından çekilmiş yazılar' : loc.translate('my_articles_desc'),
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _showArchived = !_showArchived;
                    });
                  },
                  icon: Icon(_showArchived ? Icons.article_rounded : Icons.archive_rounded, size: 20),
                  label: Text(_showArchived ? 'Aktif Yazılar' : 'Arşiv', style: const TextStyle(fontWeight: FontWeight.bold)),
                  style: TextButton.styleFrom(
                    foregroundColor: _showArchived ? theme.colorScheme.primary : Colors.red.shade600,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: articlesAsync.when(
              data: (articles) {
                final filteredArticles = articles.where((a) => _showArchived ? a.status == 'draft' : a.status != 'draft').toList();

                if (filteredArticles.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Text(
                        loc.translate('my_articles_empty'),
                        style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredArticles.length,
                  itemBuilder: (context, index) {
                    final article = filteredArticles[index];
                    final isReviewing = article.status == 'reviewing';
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          onTap: () {
                            setState(() {
                              _editingArticle = article;
                              _titleController.text = article.title;
                              _summaryController.text = article.summary ?? '';
                              _contentController.text = article.content ?? '';
                              _locationController.text = _getCityFromGeoLocation(article.geoLocation);
                              _selectedCategoryId = article.categoryId;
                              _showMobileForm = true; // Show form automatically on mobile
                            });
                          },
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              width: 56,
                              height: 56,
                              color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                              child: NewsArticleImage(
                                imageUrl: article.imageUrl,
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          title: Text(
                            article.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: Row(
                              children: [
                                Icon(Icons.schedule_rounded, size: 14, color: theme.hintColor),
                                const SizedBox(width: 4),
                                Text(
                                  article.createdAt.toLocal().toString().substring(0, 16),
                                  style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                                ),
                              ],
                            ),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: article.status == 'archived' 
                                  ? Colors.red.withValues(alpha: 0.1) 
                                  : (isReviewing ? Colors.orange : Colors.green).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: article.status == 'archived'
                                    ? Colors.red.withValues(alpha: 0.3)
                                    : (isReviewing ? Colors.orange : Colors.green).withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              article.status == 'archived' 
                                  ? 'YAYINDAN ÇEKİLDİ' 
                                  : (isReviewing ? loc.translate('status_reviewing') : loc.translate('status_published')),
                              style: TextStyle(
                                color: article.status == 'archived'
                                    ? Colors.red.shade800
                                    : (isReviewing ? Colors.orange.shade800 : Colors.green.shade800),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('${loc.translate('error')} $err', style: const TextStyle(color: Colors.red)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Tab 3: AI Suggestion Room (AI Tavsiye Odası)
  Widget _buildAiSuggestionsTab(BuildContext context, ThemeData theme) {
    final suggestionsAsync = ref.watch(pendingSuggestionsProvider);
    final isDesktop = ResponsiveBreakpoints.isDesktopOrLarger(context);
    final loc = AppLocalizations.of(context);

    return RefreshIndicator(
      onRefresh: () async => ref.refresh(pendingSuggestionsProvider),
      child: suggestionsAsync.when(
        data: (suggestions) {
          if (suggestions.isEmpty) {
            return Center(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.psychology_alt_rounded,
                          size: 64,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        loc.translate('sug_empty'),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        loc.translate('sug_empty_desc'),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.hintColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          if (isDesktop) {
            return _buildDesktopTable(context, theme, suggestions);
          } else {
            return _buildMobileList(context, theme, suggestions);
          }
        },
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: CircularProgressIndicator(),
          ),
        ),
        error: (err, stack) => Center(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Card(
              color: Colors.redAccent.withValues(alpha: 0.1),
              margin: const EdgeInsets.all(24),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline_rounded, color: Colors.red, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      loc.translate('sug_err'),
                      style: theme.textTheme.titleMedium?.copyWith(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(err.toString(), style: theme.textTheme.bodySmall, textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopTable(BuildContext context, ThemeData theme, List<AiSuggestion> suggestions) {
    final loc = AppLocalizations.of(context);
    final isEn = loc.locale.languageCode == 'en';
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.psychology_rounded, color: theme.colorScheme.primary, size: 28),
              const SizedBox(width: 12),
              Text(
                loc.translate('dash_tab_suggestions'),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => ref.refresh(pendingSuggestionsProvider),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(loc.translate('sug_refresh')),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            loc.translate('sug_desc'),
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
          ),
          const SizedBox(height: 20),
          Card(
            clipBehavior: Clip.antiAlias,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: theme.colorScheme.outlineVariant,
                width: 1,
              ),
            ),
            child: Column(
              children: [
                // Table Header
                Container(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          loc.translate('sug_col_title'),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Text(
                          loc.translate('sug_col_reason'),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          loc.translate('sug_col_source'),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(
                        width: 70,
                        child: Center(
                          child: Text(
                            isEn ? 'Link' : 'Kaynak',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 320,
                        child: Center(
                          child: Text(
                            loc.translate('sug_col_actions'),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // Table Rows
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: suggestions.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final suggestion = suggestions[index];
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              suggestion.suggestedTitle,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 16.0),
                              child: Text(
                                suggestion.suggestionReason,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              suggestion.sourceArticleTitle,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.hintColor,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 70,
                            child: Center(
                              child: IconButton(
                                icon: const Icon(Icons.open_in_new_rounded),
                                color: theme.colorScheme.primary,
                                tooltip: isEn ? 'Open Source in Browser' : 'Kaynağı Tarayıcıda Aç',
                                onPressed: () => _launchUrl(suggestion.sourceUrl),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 320,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: _generatingSuggestionIds.contains(suggestion.id) 
                                    ? null 
                                    : () => _updateStatus(suggestion, 'approved'),
                                  icon: _generatingSuggestionIds.contains(suggestion.id)
                                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                    : const Icon(Icons.auto_awesome, size: 16),
                                  label: Text(
                                    _generatingSuggestionIds.contains(suggestion.id)
                                      ? (isEn ? 'Generating...' : 'Yazım Aşamasında...')
                                      : (isEn ? 'Approve & Generate' : 'Onayla & Üret AI')
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.indigo.shade600,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor: Colors.indigo.shade300,
                                    disabledForegroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                                OutlinedButton.icon(
                                  onPressed: () => _updateStatus(suggestion, 'rejected'),
                                  icon: const Icon(Icons.close_rounded, size: 16),
                                  label: Text(isEn ? 'Reject' : 'Reddet'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.grey.shade700,
                                    side: BorderSide(color: Colors.grey.shade400),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileList(BuildContext context, ThemeData theme, List<AiSuggestion> suggestions) {
    final loc = AppLocalizations.of(context);
    final isEn = loc.locale.languageCode == 'en';
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = suggestions[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        suggestion.suggestedTitle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.open_in_new_rounded),
                      color: theme.colorScheme.secondary,
                      onPressed: () => _launchUrl(suggestion.sourceUrl),
                      tooltip: isEn ? 'Original Source URL' : 'Orijinal Kaynak URL',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  isEn ? 'Suggestion Reason:' : 'Öneri Gerekçesi:',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  suggestion.suggestionReason,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.newspaper_rounded, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${loc.translate('sug_col_source')}: ${suggestion.sourceArticleTitle}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.hintColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _generatingSuggestionIds.contains(suggestion.id) 
                          ? null 
                          : () => _updateStatus(suggestion, 'approved'),
                        icon: _generatingSuggestionIds.contains(suggestion.id)
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.auto_awesome, size: 16),
                        label: Text(
                          _generatingSuggestionIds.contains(suggestion.id)
                            ? (isEn ? 'Generating...' : 'Yazım Aşamasında...')
                            : (isEn ? 'Approve & Start AI' : 'Onayla & Başlat AI')
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo.shade600,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.indigo.shade300,
                          disabledForegroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _updateStatus(suggestion, 'rejected'),
                        icon: const Icon(Icons.close_rounded, size: 16),
                        label: Text(isEn ? 'Reject' : 'Reddet'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey.shade700,
                          side: BorderSide(color: Colors.grey.shade400),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final loc = AppLocalizations.of(context);
    final isEn = loc.locale.languageCode == 'en';
    final uri = Uri.tryParse(urlString);
    if (uri != null) {
      try {
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          throw 'Could not launch';
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isEn ? 'Could not open link: $urlString' : 'Bağlantı açılamadı: $urlString'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEn ? 'Invalid link address: $urlString' : 'Geçersiz bağlantı adresi: $urlString'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _updateStatus(AiSuggestion suggestion, String status) async {
    final loc = AppLocalizations.of(context);
    final isEn = loc.locale.languageCode == 'en';
    if (suggestion.id == null) return;

    if (status == 'approved') {
      setState(() => _generatingSuggestionIds.add(suggestion.id!));
    }

    final repository = ref.read(homeRepositoryProvider);
    final success = await repository.updateSuggestionStatus(suggestion, status);

    if (mounted) {
      if (status == 'approved') {
        setState(() => _generatingSuggestionIds.remove(suggestion.id!));
      }

      if (success) {
        ref.invalidate(pendingSuggestionsProvider);
        if (status == 'approved') {
          ref.invalidate(latestArticlesProvider);
          // Jump back to the "Makale Editörü" tab so user can see the generated draft
          _tabController.animateTo(0);
        }

        final isApproved = status == 'approved';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isApproved
                ? (isEn ? 'AI successfully wrote the analysis. Ready for approval in editor.' : 'Yapay zeka analiz yazısını tamamladı. Editör onayına hazır.')
                : (isEn ? 'Suggestion rejected.' : 'Tavsiye reddedildi.')),
            backgroundColor: isApproved ? Colors.green : Colors.grey.shade800,
            duration: const Duration(seconds: 4),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEn ? 'An error occurred while generating article.' : 'Yapay zeka analiz yazarken bir hata oluştu.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }
}
