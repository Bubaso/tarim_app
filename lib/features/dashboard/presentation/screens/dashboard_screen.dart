import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/network/supabase_client.dart';
import '../../../../core/utils/responsive_breakpoints.dart';
import '../../../../main.dart';
import '../../../home/data/models/news_article.dart';
import '../../../home/data/models/ai_suggestion.dart';
import '../../../home/providers/home_providers.dart';
import '../../../../core/utils/image_fallback_helper.dart';

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
    _tabController = TabController(length: 3, vsync: this);
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

  Future<void> _submitArticle() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    final title = _titleController.text.trim();
    final summary = _summaryController.text.trim();
    final content = _contentController.text.trim();
    final location = _locationController.text.trim();

    // Map city to WKT geo_location POINT(longitude latitude)
    final geoLocation = _getGeoLocationFromCity(location);

    // Construct the article for Supabase insertion
    final article = NewsArticle(
      id: const Uuid().v4(),
      title: title,
      content: content,
      summary: summary,
      imageUrl: null, // Always null for backend designer agent visual flow
      createdAt: DateTime.now(),
      status: 'reviewing', // Enforced reviewing status
      categoryId: _selectedCategoryId,
      geoLocation: geoLocation,
    );

    // Call submit through repository
    final repository = ref.read(homeRepositoryProvider);
    final success = await repository.submitArticleByAuthor(article);

    setState(() {
      _isSubmitting = false;
    });

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Yazınız başarıyla incelemeye gönderildi, kapak görseli hazırlanıyor!'),
            backgroundColor: Colors.green,
          ),
        );
        // Clear form
        _titleController.clear();
        _summaryController.clear();
        _contentController.clear();
        _locationController.clear();
        setState(() {
          _selectedCategoryId = null;
          _showMobileForm = false;
        });
        
        // Refresh articles list and invalidate stream provider to pull new values
        ref.invalidate(latestArticlesProvider);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Makale gönderilirken veritabanı hatası oluştu.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _signOut() async {
    try {
      await ref.read(supabaseClientProvider).auth.signOut();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Başarıyla çıkış yapıldı.'),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Çıkış hatası: $e'),
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yazar Yönetim Paneli'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.hintColor,
          indicatorColor: theme.colorScheme.primary,
          tabs: const [
            Tab(
              icon: Icon(Icons.newspaper_rounded),
              text: 'Haberler',
            ),
            Tab(
              icon: Icon(Icons.category_rounded),
              text: 'Kategoriler',
            ),
            Tab(
              icon: Icon(Icons.psychology_rounded),
              text: 'Yayın Kurulu Önerileri',
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Çıkış Yap',
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
        ],
      ),
    );
  }

  // Tab 1: Articles and Submission Form
  Widget _buildArticlesAndFormTab(BuildContext context, ThemeData theme, dynamic user, bool isDesktop) {
    final articlesAsync = ref.watch(latestArticlesProvider);

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
                        'Listeye Dön',
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
                    label: const Text('Yeni Yazı Gönder'),
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

    return RefreshIndicator(
      onRefresh: () async => ref.refresh(assignmentsFutureProvider),
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Bana Atanan Görevler',
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
                          'Atanmış aktif bir göreviniz bulunmuyor.',
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
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: (status == 'completed' ? Colors.green : Colors.orange).withValues(alpha: 0.15),
                        child: Icon(
                          status == 'completed' ? Icons.check_circle_rounded : Icons.pending_rounded,
                          color: status == 'completed' ? Colors.green : Colors.orange,
                        ),
                      ),
                      title: Text(item['title']?.toString() ?? 'Konu'),
                      subtitle: Text(item['description']?.toString() ?? ''),
                      trailing: Text(
                        status.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: status == 'completed' ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.bold,
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
                child: Text('Görevler yüklenirken hata oluştu: $err', style: const TextStyle(color: Colors.red)),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Teklif Edilen Konular',
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
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              topic['category'] ?? '',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.secondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            'Yazıya Açık',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        topic['title'] ?? '',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        topic['description'] ?? '',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                      const SizedBox(height: 16),
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

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: theme.colorScheme.primary.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
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
                    'Yeni Makale İncelemesi Gönder',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Gönderilen yazılar onay sonrası haber portalında yayınlanır.',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
              ),
              const Divider(height: 24),
              
              // Turkish Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Makale Başlığı *',
                  hintText: 'Haberin Türkçe başlığını yazınız',
                  prefixIcon: Icon(Icons.title_rounded),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Başlık alanı boş bırakılamaz' : null,
              ),
              const SizedBox(height: 16),

              // Summary (Özet)
              TextFormField(
                controller: _summaryController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Özet (Summary) *',
                  hintText: 'Yazının kısa bir özetini giriniz (görsel üretimi için kullanılacaktır)',
                  prefixIcon: Icon(Icons.summarize_rounded),
                  alignLabelWithHint: true,
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Özet alanı boş bırakılamaz' : null,
              ),
              const SizedBox(height: 16),

              // Turkish Content
              TextFormField(
                controller: _contentController,
                maxLines: 8,
                decoration: const InputDecoration(
                  labelText: 'Makale Gövde Metni *',
                  hintText: 'Detaylı içeriği buraya girin (En az 50 karakter tavsiye edilir)',
                  prefixIcon: Icon(Icons.notes_rounded),
                  alignLabelWithHint: true,
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Gövde metni boş bırakılamaz' : null,
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
                    value: _selectedCategoryId,
                    decoration: const InputDecoration(
                      labelText: 'Kategori *',
                      prefixIcon: Icon(Icons.category_rounded),
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
                    validator: (val) => val == null || val.isEmpty ? 'Lütfen bir kategori seçiniz' : null,
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (err, stack) => DropdownButtonFormField<String>(
                  // ignore: deprecated_member_use
                  value: _selectedCategoryId,
                  decoration: const InputDecoration(
                    labelText: 'Kategori (Yerel Mod) *',
                    prefixIcon: Icon(Icons.category_rounded),
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
                  validator: (val) => val == null || val.isEmpty ? 'Lütfen bir kategori seçiniz' : null,
                ),
              ),
              const SizedBox(height: 16),

              // Location / City Name (e.g. Konya, Mersin)
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Lokasyon / Şehir *',
                  hintText: 'Örn: Konya, Mersin',
                  prefixIcon: Icon(Icons.location_on_rounded),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Lokasyon/Şehir boş bırakılamaz' : null,
              ),
              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submitArticle,
                icon: _isSubmitting 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.send_rounded),
                label: Text(_isSubmitting ? 'Gönderiliyor...' : 'İncelemeye Gönder'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Sub-widget: Left list showing all previous submissions
  Widget _buildMyArticlesList(BuildContext context, ThemeData theme, AsyncValue<List<NewsArticle>> articlesAsync) {
    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(latestArticlesProvider),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gönderilen Makalelerim',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Sistem genelindeki makaleleriniz ve güncel inceleme durumları listelenir.',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                ),
              ],
            ),
          ),
          Expanded(
            child: articlesAsync.when(
              data: (articles) {
                if (articles.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Text(
                        'Henüz hiç makale göndermediniz.',
                        style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: articles.length,
                  itemBuilder: (context, index) {
                    final article = articles[index];
                    final isReviewing = article.status == 'reviewing';
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 48,
                            height: 48,
                            color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                            child: NewsArticleImage(
                              imageUrl: article.imageUrl,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        title: Text(
                          article.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          article.createdAt.toLocal().toString().substring(0, 16),
                          style: theme.textTheme.bodySmall,
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: (isReviewing ? Colors.orange : Colors.green).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isReviewing ? 'İncelemede' : 'Yayında',
                            style: TextStyle(
                              color: isReviewing ? Colors.orange.shade800 : Colors.green.shade800,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
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
                  child: Text('Haber listesi yüklenemedi: $err', style: const TextStyle(color: Colors.red)),
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
                        'Bekleyen Öneri Bulunmuyor',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Analiz sistemi küresel tarım trendlerini ve krizleri analiz edip yeni makale önerileri ürettiğinde burada listelenecektir.',
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
                      'Öneriler yüklenirken bir hata oluştu',
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
                'Yayın Kurulu Önerileri',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => ref.refresh(pendingSuggestionsProvider),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Yenile'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Yayın Kurulu tarafından makro tarım trendleri doğrultusunda geliştirilen derin makale önerileri.',
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
                      const Expanded(
                        flex: 3,
                        child: Text(
                          'Önerilen Başlık',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Expanded(
                        flex: 4,
                        child: Text(
                          'Gerekçe',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Expanded(
                        flex: 3,
                        child: Text(
                          'Kaynak Haber',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(
                        width: 70,
                        child: Center(
                          child: Text(
                            'Kaynak',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 320,
                        child: Center(
                          child: Text(
                            'Karar / Aksiyonlar',
                            style: TextStyle(fontWeight: FontWeight.bold),
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
                                tooltip: 'Kaynağı Tarayıcıda Aç',
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
                                  onPressed: () => _updateStatus(suggestion.id, 'approved'),
                                  icon: const Icon(Icons.check_rounded, size: 16),
                                  label: const Text('Onayla & Üret'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green.shade600,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                                OutlinedButton.icon(
                                  onPressed: () => _updateStatus(suggestion.id, 'rejected'),
                                  icon: const Icon(Icons.close_rounded, size: 16),
                                  label: const Text('Reddet'),
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
                      tooltip: 'Orijinal Kaynak URL',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Öneri Gerekçesi:',
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
                          'Kaynak: ${suggestion.sourceArticleTitle}',
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
                        onPressed: () => _updateStatus(suggestion.id, 'approved'),
                        icon: const Icon(Icons.check_rounded, size: 16),
                        label: const Text('Onayla & Başlat'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
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
                        onPressed: () => _updateStatus(suggestion.id, 'rejected'),
                        icon: const Icon(Icons.close_rounded, size: 16),
                        label: const Text('Reddet'),
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
              content: Text('Bağlantı açılamadı: $urlString'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Geçersiz bağlantı adresi: $urlString'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _updateStatus(int? id, String status) async {
    if (id == null) return;

    final repository = ref.read(homeRepositoryProvider);
    final success = await repository.updateSuggestionStatus(id, status);

    if (mounted) {
      if (success) {
        ref.invalidate(pendingSuggestionsProvider);

        final isApproved = status == 'approved';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isApproved
                ? 'Tavsiye onaylandı, derin makale üretimi arka planda başlıyor!'
                : 'Tavsiye reddedildi.'),
            backgroundColor: isApproved ? Colors.green : Colors.grey.shade800,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Durum güncellenirken bir hata oluştu.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }
}
