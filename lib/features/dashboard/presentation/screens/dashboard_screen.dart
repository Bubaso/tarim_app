import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/network/supabase_client.dart';
import '../../../../core/utils/responsive_breakpoints.dart';
import '../../../../core/utils/localization_helper.dart';
import '../../../home/data/models/news_article.dart';
import '../../../home/providers/home_providers.dart';
import '../../../../core/utils/image_fallback_helper.dart';
import '../../../../core/services/storage_service.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'admin_statistics_screen.dart';
import 'admin_yazarlar_screen.dart';
import 'admin_hero_screen.dart';
import '../../../../core/utils/string_extensions.dart';
import '../../../videos/presentation/screens/video_onay_ekrani.dart';
import 'onay_kuyrugu_ekrani.dart';
import 'hikaye_yonetimi_ekrani.dart';
import 'hat_ekrani.dart';

// Riverpod providers for categories and assignments
final categoriesFutureProvider = FutureProvider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(homeRepositoryProvider).fetchCategories();
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
  final HtmlEditorController _htmlController = HtmlEditorController();
  final _locationController = TextEditingController();

  String? _selectedCategoryId;
  String? _uploadedImageUrl;
  bool _isSubmitting = false;
  bool _showMobileForm = false; // Toggle to show form on mobile instead of list
  /// Panel araması (madde 16). Boşken normal liste, doluyken arama sonucu.
  ///
  /// ARŞİV DÜĞMESİ KALDIRILDI (madde 6): listeyi besleyen akış yalnız
  /// `status='published'` çekiyor, arşiv süzgeci ise `status=='draft'`
  /// arıyordu — kesişim her zaman boş kümeydi. Düğme hiçbir zaman bir şey
  /// göstermedi. Yerini arama aldı: asıl eksik olan oydu.
  final TextEditingController _aramaDenetleyici = TextEditingController();
  String _arama = '';
  bool _isBreaking = false; // Toggle to mark article as breaking news

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
    _tabController = TabController(length: 8, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _summaryController.dispose();
    _locationController.dispose();
    _aramaDenetleyici.dispose();
    super.dispose();
  }

  /// Dar ekran mı — telefon ve küçük tablet.
  ///
  /// `ResponsiveBreakpoints.isDesktopOrLarger` masaüstü/değil ayrımı yapıyor;
  /// burada istenen başka bir şey: kenar boşluğu, buton boyu ve satır
  /// düzeninin daraldığı eşik.
  static bool _dar(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  /// Sade sekme — ikon yok, yükseklik 46.
  ///
  /// İkonlar kaldırıldı: sekiz ikon hiçbir şeyi ayırt etmiyordu ve şeridi
  /// 72 pikselden 46'ya indirmenin tek yolu onlardı. Etiket zaten yazıyor.
  static Tab _sekme(String ad) => Tab(height: 46, text: ad);

  Future<void> _pickCoverImage() async {
    final StorageService storageService = StorageService();
    final url = await storageService.pickAndUploadImage();
    if (url != null) {
      setState(() {
        _uploadedImageUrl = url;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kapak görseli başarıyla yüklendi.')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kapak görseli seçilmedi veya yüklenemedi.')),
        );
      }
    }
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
            return entry.key[0].toTurkishUpperCase() + entry.key.substring(1);
          }
        }
      }
    }
    return '';
  }

/// Düzenleyiciyi TAM kayıtla açar.
///
/// Liste nesnesi kullanılamaz: liste sorgusu ağır sütunları taşımıyor
/// (`_listeSutunlari`, §20.1) ve `_submitArticle` kaydı `_editingArticle`
/// alanlarından yeniden kurup `toJson()` ile BÜTÜN satırı yazıyor. Eksik
/// nesneyle açılan bir düzenleyicide "Kaydet"e basmak, veritabanındaki dolu
/// metni boş metinle EZER — üretimde tam olarak böyle bir haber kayboldu
/// (§25.1).
///
/// Çekim başarısızsa düzenleyici AÇILMIYOR. Yarım veriyle açmak, kaydetme
/// anında sessiz veri kaybı demek.
  Future<void> _duzenlemeyeAc(NewsArticle article) async {
  NewsArticle? tam;
  try {
    tam = await ref.read(homeRepositoryProvider).fetchArticleById(article.id);
  } catch (_) {
    tam = null;
  }
  if (!mounted) return;
  if (tam == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Haber yüklenemedi — düzenleyici açılmadı. '
            'Eksik veriyle kaydetmek metni silerdi.'),
      ),
    );
    return;
  }
  final kayit = tam;
  setState(() {
    _editingArticle = kayit;
    _titleController.text = kayit.title;
    _summaryController.text = kayit.summary ?? '';
    _uploadedImageUrl = null;
    _locationController.text = _getCityFromGeoLocation(kayit.geoLocation);
    _selectedCategoryId = kayit.categoryId;
    _isBreaking = kayit.isBreaking ?? false;
    _showMobileForm = true;
  });
  // Düzenleyici kurulduktan SONRA dolduruluyor: aynı karede setText
  // çağrısı boş editöre yazıyor ve metin görünmüyor.
  Future.delayed(const Duration(milliseconds: 100), () {
    if (mounted) _htmlController.setText(kayit.content);
  });
  }

  Future<void> _submitArticle({bool isPublishing = false, bool isUnpublishing = false}) async {
    if (!isUnpublishing && !_formKey.currentState!.validate()) return;

    // YAYINDAN ÇEKME TEK ALAN YAZAR.
    //
    // Eskiden bu da formdan BÜTÜN satırı yeniden kurup updateArticle'a
    // veriyordu. Üç ayrı sakıncası vardı:
    //   1. 37 alanlık yazma, tek bir kolon için gereksiz risk (§25.1'de bir
    //      haberin metni tam olarak böyle silinmişti),
    //   2. içinde çeviri çağrısı var ve o ağa çıkıyor — yayından çekmek
    //      internet beklemek zorunda değil,
    //   3. formu doldurmayan alanlar (facts/figures/quotes gibi) null
    //      yazılıyordu.
    // Durum değiştirmek bir alan işidir; dönen satır da sayılıyor.
    if (isUnpublishing && _editingArticle != null) {
      await _haberiSil(_editingArticle!);
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final title = _titleController.text.trim();
    final summary = _summaryController.text.trim();
    final content = await _htmlController.getText();
    final location = _locationController.text.trim();

    // Map city to WKT geo_location POINT(longitude latitude)
    final geoLocation = _getGeoLocationFromCity(location);

    final isEditing = _editingArticle != null;
    final finalImageUrl = _uploadedImageUrl ?? _editingArticle?.imageUrl;

    // Construct the article for Supabase insertion/update
    final repository = ref.read(homeRepositoryProvider);
    
    // Auto-translate if English is missing or it's a new article and we have Turkish content
    String? titleEn = _editingArticle?.titleEn;
    String? summaryEn = _editingArticle?.summaryEn;
    String? contentEn = _editingArticle?.contentEn;
    
    if (titleEn == null || titleEn.isEmpty) {
      titleEn = await repository.translateTextToEnglish(title);
    }
    if (summaryEn == null || summaryEn.isEmpty) {
      summaryEn = await repository.translateTextToEnglish(summary);
    }
    if (contentEn == null || contentEn.isEmpty) {
      contentEn = await repository.translateTextToEnglish(content);
    }

    final article = NewsArticle(
      id: isEditing ? _editingArticle!.id : const Uuid().v4(),
      title: title,
      titleEn: titleEn,
      content: content,
      contentEn: contentEn,
      summary: summary,
      summaryEn: summaryEn,
      imageUrl: finalImageUrl,
      seoKeywords: _editingArticle?.seoKeywords,
      sourceName: _editingArticle?.sourceName,
      sourceUrl: _editingArticle?.sourceUrl,
      viewCount: _editingArticle?.viewCount ?? 0,
      createdAt: isEditing ? _editingArticle!.createdAt : DateTime.now(),
      status: isUnpublishing ? 'draft' : (isPublishing ? 'published' : (isEditing ? (_editingArticle!.status ?? 'reviewing') : 'reviewing')),
      categoryId: _selectedCategoryId,
      geoLocation: geoLocation,
      isBreaking: _isBreaking,
      contentType: _editingArticle?.contentType,
      topic: _editingArticle?.topic,
      region: _editingArticle?.region,
      heroScore: _editingArticle?.heroScore,
      isHero: _editingArticle?.isHero,
      heroOrder: _editingArticle?.heroOrder,
      spot: _editingArticle?.spot,
      spotEn: _editingArticle?.spotEn,
      keyTakeaways: _editingArticle?.keyTakeaways,
      keyTakeawaysEn: _editingArticle?.keyTakeawaysEn,
      expertInsight: _editingArticle?.expertInsight,
      expertInsightEn: _editingArticle?.expertInsightEn,
      // Form bu alanları doldurmuyor; taşınmazlarsa toJson() null yazıp
      // muhabirin doğrulama verisini SİLER (§25.1'in aynı tuzağı —
      // 1.233 haberde facts, 1.009'unda figures, 566'sında quotes dolu).
      facts: _editingArticle?.facts,
      figures: _editingArticle?.figures,
      quotes: _editingArticle?.quotes,
      turkiyePin: _editingArticle?.turkiyePin,
      chartData: _editingArticle?.chartData,
    );

    // Call submit through repository
    final errorMessage = isEditing 
        // formdanKaydet: satırın TAMAMINI değil, formun sahip olduğu
        // alanları yazıyor. updateArticle her kaydetmede sekiz sütunu
        // NULL'a eziyordu (fotoğraf künyesi, kaynak tarihi, görsel
        // türevleri, kısa haber etiketi). Ayrıntı repository'de.
        ? await repository.formdanKaydet(article)
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

  /// Haberi KALICI siler (madde 7, kullanıcı kararı 15 Kasım 2026).
  ///
  /// Eskiden burada `status='draft'` yazılıyordu ve ekran "Taslaklarda
  /// duruyor" diyordu. Taslak listesi diye bir yer yoktu: liste akışı yalnız
  /// yayındakileri çekiyor, arşiv düğmesi de hiç çalışmıyordu. Yani haber
  /// panelden tamamen kayboluyordu — mesaj da doğruyu söylemiyordu.
  ///
  /// Kullanıcı kararı: "yayından kalkan haber silinsin gitsin, bir daha
  /// gelmesine gerek yok." Silme tetikleyicisi adresi `rejected_sources`'a
  /// yazıyor, dolayısıyla hat aynı haberi bir daha getirmiyor.
  ///
  /// Geri dönüşü olmadığı için ONAY SORULUYOR.
  Future<void> _haberiSil(NewsArticle article) async {
    final onay = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Haberi kalıcı olarak sil'),
        content: Text(
          '"${article.title}"\n\n'
          'Bu haber yayından kalkacak ve VERİTABANINDAN SİLİNECEK. '
          'Geri alınamaz. Kaynak adresi red hafızasına yazılacağı için '
          'haber hattı aynı haberi bir daha getirmeyecek.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Vazgeç')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Kalıcı olarak sil',
                style: TextStyle(
                    color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (onay != true || !mounted) return;

    setState(() => _isSubmitting = true);
    final ok = await ref.read(homeRepositoryProvider).haberiReddet(
          id: article.id,
          title: article.title,
          sourceUrl: article.sourceUrl,
          sourceName: article.sourceName,
          lastStatus: article.status,
          gerekce: 'panelden silindi',
        );
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok
          ? 'Haber silindi. Hat bir daha getirmeyecek.'
          : 'Silinemedi: yetki yok ya da haber bulunamadı.'),
      backgroundColor: ok ? null : Colors.redAccent,
    ));
    if (ok) {
      ref.invalidate(latestArticlesProvider);
      setState(() => _editingArticle = null);
    }
  }

  void _cancelEdit() {
    setState(() {
      _titleController.clear();
      _summaryController.clear();
      _htmlController.clear();
      _locationController.clear();
      _uploadedImageUrl = null;
      _selectedCategoryId = null;
      _showMobileForm = false;
      _isBreaking = false;
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
        GoRouter.of(context).go('/');
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

    // ── PANEL ÇERÇEVESİ: TEK SATIR ───────────────────────────────────────
    //
    // Eskiden iki satır vardı: başlık çubuğu (56 px) ve altında ikonlu
    // sekme şeridi (72 px) — 128 piksel, hiçbiri iş görmüyordu. Ekranların
    // kendi başlıkları da üstüne binince çalışılacak alan ekranın dörtte
    // birine iniyordu (kullanıcı ölçümü).
    //
    // Üçü birden kaldırıldı:
    //   · Başlık çubuğu ile sekme şeridi TEK satırda birleşti.
    //   · Sekmelerden ikonlar çıktı — sekiz ikon hiçbir şey ayırt
    //     etmiyordu, etiketler zaten yazıyor.
    //   · "Yönetim Paneli" yazısı gitti: zaten paneldesin.
    //
    // 128 piksel → 46 piksel.
    final sekmeler = TabBar(
      controller: _tabController,
      // Kaydırılabilir: sekiz sekme eşit bölündüğünde 375 piksellik
      // telefonda sekme başına 47 piksel düşüyordu, hiçbir etiket
      // sığmıyordu.
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      labelColor: theme.colorScheme.primary,
      unselectedLabelColor: theme.hintColor,
      indicatorColor: theme.colorScheme.primary,
      labelPadding: const EdgeInsets.symmetric(horizontal: 14),
      labelStyle: const TextStyle(
          fontSize: 13.5, fontWeight: FontWeight.w700),
      unselectedLabelStyle: const TextStyle(fontSize: 13.5),
      tabs: [
        // HAT İLK SIRADA: günün ilk işi haber çekmek ve "bugün ne oldu"
        // sorusunu cevaplamak.
        _sekme(isEn ? 'Pipeline' : 'Hat'),
        _sekme(loc.translate('dash_tab_my_articles')),
        // Onay kuyruğunda bekleyen sayısı etiketin yanında. İkon
        // kalkınca rozet de oraya taşındı — sayı hangi sekmede olursan ol
        // görünmeli.
        Tab(
          height: 46,
          child: Consumer(
            builder: (context, ref, _) {
              final sayi = ref.watch(bekleyenSayisiProvider);
              final ad = isEn ? 'Review Queue' : 'Onay Kuyruğu';
              if (sayi == 0) return Text(ad);
              return Row(mainAxisSize: MainAxisSize.min, children: [
                Text(ad),
                const SizedBox(width: 7),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Text('$sayi',
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                ),
              ]);
            },
          ),
        ),
        _sekme(isEn ? 'Stories' : 'Hikâyeler'),
        _sekme(isEn ? 'Hero News' : 'Hero'),
        _sekme(isEn ? 'Video News' : 'Video'),
        _sekme(loc.translate('dash_tab_stats')),
        _sekme(isEn ? 'Columnists' : 'Yazarlar'),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        // Tek satır: sekmeler + çıkış. Başlık yok.
        toolbarHeight: 46,
        titleSpacing: 8,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Expanded(child: sekmeler),
            IconButton(
              icon: const Icon(Icons.logout_rounded, size: 20),
              tooltip: loc.translate('dash_logout'),
              visualDensity: VisualDensity.compact,
              onPressed: _signOut,
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const HatEkrani(),
          _buildArticlesAndFormTab(context, theme, user, isDesktop),
          const OnayKuyruguEkrani(),
          const HikayeYonetimiEkrani(),
          const AdminHeroScreen(),
          const VideoOnayEkrani(),
          const AdminStatisticsScreen(),
          const AdminYazarlarScreen(),
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


  Widget _buildBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade700),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 12, color: Colors.grey.shade800, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
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
              
              if (_editingArticle != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.analytics_rounded, color: theme.colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            'AI Haber Analiz Raporu',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      _buildInfoRow('Kaynak:', _editingArticle!.sourceName ?? 'Bilinmiyor'),
                      if (_editingArticle!.sourceUrl != null && _editingArticle!.sourceUrl!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                width: 110,
                                child: Text('Orijinal Link:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () => _launchUrl(_editingArticle!.sourceUrl!),
                                  child: Text(
                                    _editingArticle!.sourceUrl!,
                                    style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline, fontSize: 13),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      _buildInfoRow('Tarih:', _editingArticle!.createdAt.toLocal().toString().substring(0, 16)),
                      _buildInfoRow('İçerik Niteliği:', _editingArticle!.contentType ?? 'Haber'),
                      _buildInfoRow('Konu (Topic):', _editingArticle!.topic ?? 'Genel'),
                      _buildInfoRow('Bölge:', _editingArticle!.region ?? 'Türkiye/Dünya'),
                      if (_editingArticle!.heroScore != null)
                        _buildInfoRow('Manşet Değeri:', '${_editingArticle!.heroScore}/10'),
                      if (_editingArticle!.seoKeywords != null && _editingArticle!.seoKeywords!.isNotEmpty)
                        _buildInfoRow('SEO Etiketleri:', _editingArticle!.seoKeywords!.join(', ')),
                      const SizedBox(height: 8),
                      Text(
                        '* Haber yayına girmeden önce aşağıdaki formdan AI tarafından atanmış kategoriyi (örn: Tarım, Ekonomi vs.) ve diğer tüm alanları değiştirebilirsiniz.',
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
              ],
              
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

              // Cover Image Upload Button
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _uploadedImageUrl != null || _editingArticle?.imageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                _uploadedImageUrl ?? _editingArticle!.imageUrl!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Icon(Icons.image_outlined, color: theme.colorScheme.secondary),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kapak Görseli',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _uploadedImageUrl != null ? 'Yeni görsel yüklendi' : (_editingArticle?.imageUrl != null ? 'Mevcut görsel kullanılıyor' : 'Henüz görsel seçilmedi'),
                            style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: _pickCoverImage,
                      icon: const Icon(Icons.upload_rounded, size: 18),
                      label: const Text('Yükle'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Turkish Content with HtmlEditor
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                  borderRadius: BorderRadius.circular(16),
                ),
                clipBehavior: Clip.antiAlias,
                child: HtmlEditor(
                  controller: _htmlController,
                  htmlEditorOptions: HtmlEditorOptions(
                    hint: loc.translate('form_body_hint'),
                    initialText: _editingArticle?.content ?? '',
                  ),
                  otherOptions: OtherOptions(
                    // YÜKSEKLİK EKRANA GÖRE (madde 12). Sabit 400 piksel
                    // telefonda kullanılamıyordu: 812 piksellik ekranda
                    // klavye açılınca geriye ~350 piksel kalıyor, araç
                    // çubuğu da yer yiyor — yazı yazılan alan hiç
                    // görünmüyordu.
                    height: _dar(context)
                        ? (MediaQuery.of(context).size.height * 0.42)
                            .clamp(220.0, 360.0)
                        : 400,
                  ),
                  htmlToolbarOptions: HtmlToolbarOptions(
                    // Telefonda KAYDIRILABİLİR şerit: `nativeGrid` bütün
                    // düğme gruplarını aynı anda açıyor ve dar ekranda
                    // editörün kendisine yer bırakmıyor.
                    toolbarType: _dar(context)
                        ? ToolbarType.nativeScrollable
                        : ToolbarType.nativeGrid,
                    defaultToolbarButtons: [
                      const StyleButtons(),
                      const FontSettingButtons(fontSizeUnit: false),
                      const FontButtons(),
                      const ColorButtons(),
                      const ListButtons(),
                      const ParagraphButtons(),
                      const InsertButtons(audio: false, video: true, otherFile: false, table: true, hr: true),
                    ],
                  ),
                ),
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
              const SizedBox(height: 16),

              // Is Breaking News Switch
              SwitchListTile(
                title: const Text(
                  'Son Dakika Haberi',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                ),
                subtitle: const Text('Bu haber yayınlandığı anda tüm kullanıcılara acil bildirim gider.'),
                value: _isBreaking,
                activeColor: Colors.red,
                onChanged: (val) {
                  setState(() {
                    _isBreaking = val;
                  });
                },
                contentPadding: EdgeInsets.zero,
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
                    // Yayındaki haberin düğmesi SİLME; yayında olmayanınki
                    // YAYINLA. Kuyruktaki haberin silinmesi onay kuyruğundaki
                    // "Reddet" ile yapılıyor, aynı işi iki yerde sormuyoruz.
                    if (_editingArticle!.status == 'published')
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isSubmitting ? null : () => _submitArticle(isUnpublishing: true),
                          icon: const Icon(Icons.delete_forever_rounded),
                          label: const Text('Kalıcı Sil'),
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
    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(latestArticlesProvider),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            // Telefonda kenar boşluğu 24 çok yer yiyordu.
            padding: EdgeInsets.fromLTRB(
                _dar(context) ? 16 : 24, 20, _dar(context) ? 16 : 24, 12),
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
                  _arama.isEmpty
                      ? loc.translate('my_articles_desc')
                      : 'Arşivin tamamında aranıyor',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.hintColor),
                ),
                const SizedBox(height: 12),
                // ARAMA (madde 16). Liste akışı 500 satırla sınırlı, arşivde
                // 1.400'den fazla haber var: aranan haber listede olmayabilir
                // ve bu görünmez. Bu kutu veritabanında arıyor, durum
                // ayırmadan.
                TextField(
                  controller: _aramaDenetleyici,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Başlıkta ara…',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    suffixIcon: _arama.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.close_rounded, size: 20),
                            tooltip: 'Aramayı temizle',
                            onPressed: () {
                              _aramaDenetleyici.clear();
                              setState(() => _arama = '');
                            },
                          ),
                    isDense: true,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                  ),
                  onChanged: (v) => setState(() => _arama = v),
                ),
              ],
            ),
          ),
          Expanded(
            child: (_arama.trim().length >= 2
                    ? ref.watch(panelAramaProvider(_arama.trim()))
                    : articlesAsync)
                .when(
              data: (articles) {
                final filteredArticles = articles;

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
                        child: Column(
                          children: [
                            ListTile(
                              onTap: () => _duzenlemeyeAc(article),
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
                            if (isReviewing) ...[
                              const Divider(height: 1),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        if (article.sourceName != null)
                                          _buildBadge(Icons.business_rounded, article.sourceName!),
                                        if (article.topic != null)
                                          _buildBadge(Icons.topic_rounded, article.topic!),
                                        if (article.heroScore != null)
                                          _buildBadge(Icons.star_rounded, 'Skor: ${article.heroScore}/10'),
                                        if (article.contentType != null)
                                          _buildBadge(Icons.article_rounded, article.contentType!),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        // ÖLÜ YOL KALDIRILDI. Burada
                                        // `rejectArticle` (eski `delete()`)
                                        // çağrılıyor ve "Haber reddedildi ve
                                        // silindi" yazılıyordu. İki yanlış
                                        // vardı: politika DELETE vermediği
                                        // için silme sessizce düşüyordu, ve
                                        // red artık zaten SİLMİYOR (§29.1) —
                                        // durumu `rejected` yapıp arşivde
                                        // bırakıyor. Yani mesaj olmayan bir
                                        // şeyi anlatıyordu.
                                        TextButton.icon(
                                          onPressed: () async {
                                            final repo = ref.read(homeRepositoryProvider);
                                            final ok = await repo.haberiReddet(
                                              id: article.id,
                                              title: article.title,
                                              sourceUrl: article.sourceUrl,
                                              sourceName: article.sourceName,
                                              lastStatus: article.status,
                                            );
                                            if (!context.mounted) return;
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(ok
                                                    // MESAJ DOĞRUYU SÖYLÜYOR (15 Kasım 2026).
                                                    // Burada "arşivde duruyor, geri alınabilir"
                                                    // yazıyordu; red 11 Kasım'da satırı SİLMEYE
                                                    // çevrildi ve arşiv diye bir yer kalmadı.
                                                    // Olmayan bir geri dönüşü vaat ediyordu.
                                                    ? 'Haber silindi. Geri alınamaz; hat bir daha getirmeyecek.'
                                                    : 'Reddedilemedi: ${repo.sonYazmaHatasi ?? 'yetki yok ya da oturum düşmüş'}'),
                                                backgroundColor: ok ? null : Colors.redAccent,
                                              ),
                                            );
                                            if (ok) ref.invalidate(latestArticlesProvider);
                                          },
                                          icon: const Icon(Icons.block_rounded, color: Colors.red),
                                          label: const Text('Reddet', style: TextStyle(color: Colors.red)),
                                        ),
                                        const SizedBox(width: 8),
                                        ElevatedButton.icon(
                                          onPressed: () async {
                                            // Başarısızlık da SÖYLENİYOR.
                                            // Eskiden yalnızca başarı dalı
                                            // vardı: oturum düştüğünde hiçbir
                                            // şey olmuyor, moderatör düğmeye
                                            // bastığını sanıyordu.
                                            final repo = ref.read(homeRepositoryProvider);
                                            final ok = await repo.approveArticle(article.id);
                                            if (!context.mounted) return;
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(ok
                                                    ? 'Haber yayına alındı.'
                                                    : 'Yayına alınamadı: ${repo.sonYazmaHatasi ?? 'yetki yok ya da oturum düşmüş'}'),
                                                backgroundColor: ok ? null : Colors.redAccent,
                                              ),
                                            );
                                            if (ok) ref.invalidate(latestArticlesProvider);
                                          },
                                          icon: const Icon(Icons.check_circle_outline_rounded),
                                          label: const Text('Hızlı Onayla'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green.shade600,
                                            foregroundColor: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            if (article.status == 'published') ...[
                              const Divider(height: 1),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Acil: Son Dakika Olarak İşaretle',
                                      style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red),
                                    ),
                                    Switch(
                                      value: article.isBreaking ?? false,
                                      activeColor: Colors.red,
                                      onChanged: (val) async {
                                        final success = await ref.read(homeRepositoryProvider).setBreakingNews(article.id, val);
                                        if (success) {
                                          ref.invalidate(latestArticlesProvider);
                                          if (context.mounted && val) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Haber "Son Dakika" olarak işaretlendi. Bildirim kısa süre içinde gönderilecek.'),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        } else {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Hata: Son dakika durumu güncellenemedi.'), backgroundColor: Colors.redAccent),
                                            );
                                          }
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
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
}
