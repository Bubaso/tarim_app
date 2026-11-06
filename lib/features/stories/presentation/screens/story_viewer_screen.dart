// ignore_for_file: deprecated_member_use
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/story_item.dart';
import '../../data/story_analytics.dart';
import '../../data/story_constants.dart';
import '../../providers/story_providers.dart';
import '../widgets/story_image.dart';
import '../../../../core/theme/konu_renkleri.dart';
import '../../../../core/utils/turkce_metin.dart';

class StoryViewerScreen extends ConsumerStatefulWidget {
  final List<StoryGroup> storyGroups;
  final int initialGroupIndex;

  const StoryViewerScreen({
    super.key,
    required this.storyGroups,
    this.initialGroupIndex = 0,
  });

  @override
  ConsumerState<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends ConsumerState<StoryViewerScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late PageController _pageController;
  late int _currentGroupIndex;
  int _currentItemIndex = 0;

  late AnimationController _animController;

  /// Okuyucu parmağını basılı tuttuğu için mi durduk? Uygulama arka plandan
  /// döndüğünde yanlışlıkla devam ettirmemek için ayrı tutuyoruz.
  bool _heldDown = false;

  /// Arka plan görselinin hikaye boyunca kapanan yakınlaştırma payı.
  /// 0 yapılırsa hareket tamamen kalkar, kare sabit kalır.
  ///
  /// 0,05'ten indirildi. Bu pay bedava değil: dikey türev 1080 px genişliğinde
  /// ve iPhone 12 gibi 1170 px'lik bir ekranda zaten 1,08 kat büyütülüyor.
  /// Üstüne %5 binince toplam 1,14 kata çıkıyordu ve hikayenin ilk saniyeleri
  /// gözle görülür biçimde yumuşak açılıyordu. %2'de hareket hâlâ seçiliyor,
  /// büyütme payı 1,10 katta kalıyor.
  static const double _kenBurnsZoom = 0.02;

  static const String _productionOrigin = 'https://tarim-app-2026.web.app';

  StoryGroup get _currentGroup => widget.storyGroups[_currentGroupIndex];
  StoryItem get _currentItem => _currentGroup.items[_currentItemIndex];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _currentGroupIndex = widget.initialGroupIndex;
    _pageController = PageController(initialPage: _currentGroupIndex);

    _animController = AnimationController(
      vsync: this,
      duration: StoryRules.maxSlideDuration,
    );
    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _nextStory(auto: true);
      }
    });

    StoryAnalytics.opened(
      groupKey: _currentGroup.key,
      groupCount: widget.storyGroups.length,
    );
    _startStory();
    WidgetsBinding.instance.addPostFrameCallback((_) => _precacheNeighbours());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Sayaç arka planda da işlemeye devam ediyordu: telefonu cebine koyup
    // dönen okuyucu hikayeleri izlemeden atlamış oluyordu.
    if (state == AppLifecycleState.resumed) {
      if (!_heldDown && mounted) _animController.forward();
    } else {
      _animController.stop();
    }
  }

  /// Birazdan gösterilecek görselleri önden indirir.
  ///
  /// İKİ YÖNE bakıyor ve sıra önemli:
  ///
  /// 1. **Açık grubun kalan slaytları.** Eskiden yalnızca komşu grupların
  ///    İLK slaytı indiriliyordu; grup içinde ikinci, üçüncü slayta geçen
  ///    okur her seferinde sıfırdan bekliyordu. Oysa grup içi geçiş,
  ///    gruplar arası geçişten çok daha sık (6 Kasım 2026 denetimi).
  /// 2. **Komşu grupların ilk slaytı**, sağa/sola kaydırma için.
  ///
  /// Açık grup önce geliyor çünkü okurun bir sonraki hamlesi büyük
  /// ihtimalle o: hikâye kendiliğinden ilerliyor, kaydırmak için
  /// müdahale gerekiyor.
  void _precacheNeighbours() {
    if (!mounted) return;

    void al(StoryItem item) {
      precacheImage(
        storyBackgroundProvider(
          context,
          imageUrl: item.imageUrl,
          portraitUrl: item.portraitUrl,
        ),
        context,
      );
    }

    final acik = _currentGroup.items;
    for (var i = _currentItemIndex + 1; i < acik.length; i++) {
      al(acik[i]);
    }

    for (final int offset in const [1, -1, 2]) {
      final int i = _currentGroupIndex + offset;
      if (i < 0 || i >= widget.storyGroups.length) continue;
      final group = widget.storyGroups[i];
      if (group.items.isEmpty) continue;
      al(group.items.first);
    }
  }

  /// Slaytı başlatır: süreyi metin uzunluğundan hesaplar, izlendi defterine
  /// işler ve sayacı sıfırdan başlatır.
  void _startStory() {
    final item = _currentItem;
    // Grup içinde ilerledikçe ön yükleme yeniden hesaplanıyor; aksi hâlde
    // yalnızca açılışta bir kez çalışır ve uzun gruplarda sonu beklemede
    // kalırdı.
    WidgetsBinding.instance.addPostFrameCallback((_) => _precacheNeighbours());
    // Süre kaynak (Türkçe) metnin uzunluğundan hesaplanıyor; çeviriler benzer
    // uzunlukta ve bu sayede `Localizations` bağlamına ihtiyaç kalmıyor.
    _animController.duration =
        storySlideDuration(item.headline, item.statLabel);
    _animController.stop();
    _animController.reset();
    _animController.forward();
    ref.read(storySeenProvider.notifier).markSeen([item.id]);
  }

  void _nextStory({bool auto = false}) {
    final group = _currentGroup;
    if (_currentItemIndex < group.items.length - 1) {
      setState(() => _currentItemIndex++);
      _startStory();
      return;
    }

    if (auto) {
      StoryAnalytics.completed(
        groupKey: group.key,
        itemCount: group.items.length,
      );
    }

    if (_currentGroupIndex < widget.storyGroups.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  void _previousStory() {
    if (_currentItemIndex > 0) {
      setState(() => _currentItemIndex--);
      _startStory();
      return;
    }
    if (_currentGroupIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentGroupIndex = index;
      _currentItemIndex = 0;
    });
    _startStory();
    _precacheNeighbours();
  }

  void _onTapDown(TapDownDetails details) {
    _animController.stop();
  }

  void _onTapUp(TapUpDetails details) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double dx = details.globalPosition.dx;
    if (dx < screenWidth / 3) {
      _previousStory();
    } else {
      _nextStory();
    }
  }

  /// Paylaşılan adres: dosya hikâyesinde dosyanın kendisi, haberde haber.
  String _shareUrl(StoryItem item) {
    final origin = kIsWeb ? Uri.base.origin : _productionOrigin;
    return '$origin${_hedef(item)}';
  }

  /// Slaytın gideceği uygulama içi adres.
  ///
  /// Hedef satırda yazılıysa o kullanılıyor; yazılı değilse eski davranış
  /// sürüyor ve haberin adresine gidiliyor. Kod hedefi yorumlamıyor — böylece
  /// yarın emtia veya hafta dosyası hikâyesi eklendiğinde burası değişmiyor.
  String _hedef(StoryItem item) =>
      item.dosyaHikayesi ? item.hedefYol : articlePath(item.articleId);

  /// Habere geçerken hikayeyi kapatıyoruz: eskiden ekran arkada açık kalıyor
  /// ve sayaç haberi okurken de işlemeye devam ediyordu.
  void _openArticle(StoryGroup group, StoryItem item) {
    StoryAnalytics.articleOpened(
      groupKey: group.key,
      articleId: item.articleId,
      slideIndex: _currentItemIndex,
    );
    final router = GoRouter.of(context);
    Navigator.of(context).pop();
    router.push(_hedef(item));
  }

  Future<void> _share(StoryGroup group, StoryItem item, bool isEn) async {
    _animController.stop();
    StoryAnalytics.shared(groupKey: group.key, articleId: item.articleId);

    final box = context.findRenderObject() as RenderBox?;
    final text = '${item.headlineFor(isEn)}\n'
        '${item.bigStatValueFor(isEn)} · ${item.statLabelFor(isEn)}\n\n'
        '${_shareUrl(item)}';
    try {
      await Share.share(
        text,
        sharePositionOrigin:
            box != null ? box.localToGlobal(Offset.zero) & box.size : null,
      );
    } catch (_) {
      // Paylaşım sayfası açılamazsa hikaye akmaya devam etsin.
    }
    if (mounted && !_heldDown) _animController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Dismissible(
        key: const Key('story_dismiss'),
        direction: DismissDirection.down,
        onDismissed: (_) => Navigator.of(context).pop(),
        child: GestureDetector(
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onLongPressStart: (_) {
            _heldDown = true;
            _animController.stop();
          },
          onLongPressEnd: (_) {
            _heldDown = false;
            _animController.forward();
          },
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: widget.storyGroups.length,
            itemBuilder: (context, index) {
              final group = widget.storyGroups[index];
              final isCurrentGroup = index == _currentGroupIndex;
              final itemIndex = isCurrentGroup ? _currentItemIndex : 0;
              final item = group.items[itemIndex];

              final bool isEn =
                  Localizations.localeOf(context).languageCode == 'en';

              return Stack(
                fit: StackFit.expand,
                children: [
                  // Arka plan Görseli (Tam Ekran)
                  // Görsel, cihazın piksel yoğunluğuna göre boyutlandırılmış
                  // olarak Supabase dönüştürme uç noktasından gelir; ayrıntı
                  // için bkz. widgets/story_image.dart
                  AnimatedBuilder(
                    animation: _animController,
                    builder: (context, child) {
                      // Çok hafif bir "Ken Burns": kare 1.02'den 1.00'e iner,
                      // yani hikaye net kareyle biter.
                      final double t = isCurrentGroup
                          ? Curves.easeOutSine.transform(_animController.value)
                          : 0.0;
                      return Transform.scale(
                        scale: 1.0 + _kenBurnsZoom * (1 - t),
                        child: child,
                      );
                    },
                    child: StoryBackgroundImage(
                      imageUrl: item.imageUrl,
                      portraitUrl: item.portraitUrl,
                      onizleme: item.onizleme,
                    ),
                  ),

                  // Koyu Karartma (metin okunabilirliği için degrade perde)
                  // Ara duraklar bilinçli olarak sık: 3 duraklı bir degrade koyu
                  // fotoğraflarda 8-bit ekranlarda görünür bantlanma yapıyordu.
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.72),
                          Colors.black.withOpacity(0.38),
                          Colors.black.withOpacity(0.12),
                          Colors.transparent,
                          Colors.black.withOpacity(0.30),
                          Colors.black.withOpacity(0.68),
                          Colors.black.withOpacity(0.92),
                        ],
                        stops: const [0.0, 0.10, 0.22, 0.40, 0.62, 0.82, 1.0],
                      ),
                    ),
                  ),

                  // İçerik (Veri Gösterimi)
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Spacer(),

                          // Üst Başlık (Kategori) — T7.
                          //
                          // Üç şey değişti. (1) Zemin konunun rengi, sabit
                          // yeşil değil: çip artık hangi bölümde olduğunu
                          // söylüyor. (2) Punto 12'den 13'e, mürekkep koyu:
                          // parlak ton üzerinde beyaz yazı okunmuyordu.
                          // (3) Beliriş animasyonu KALDIRILDI — çip okurun
                          // nerede olduğunu söyleyen tek işaret ve ilk
                          // saniyede görünmez olması tam da en çok
                          // gerektiği anda yok olması demekti.
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: konuCipRengi(group.title),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              // Ham `toUpperCase()` DEĞİL (§39.5).
                              buyukHarf(item.superTitleFor(isEn), isEn),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                color: konuCipMurekkebi,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),

                          // Büyük İstatistik Değeri
                          AnimatedBuilder(
                            animation: _animController,
                            builder: (context, child) {
                              final val = Curves.elasticOut.transform(
                                  (_animController.value * 2).clamp(0.0, 1.0));
                              return Transform.scale(
                                scale: 0.5 + (0.5 * val),
                                alignment: Alignment.centerLeft,
                                child: Opacity(
                                  opacity: val.clamp(0.0, 1.0),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      item.bigStatValueFor(isEn),
                                      style: GoogleFonts.outfit(
                                        color: AppColors.wheat,
                                        fontSize: 72,
                                        height: 1.0,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 8),

                          // İstatistik Açıklaması
                          Text(
                            item.statLabelFor(isEn),
                            style: GoogleFonts.inter(
                              color: AppColors.wheat,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Ana Başlık
                          Text(
                            item.headlineFor(isEn),
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 28,
                              height: 1.2,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Habere Git Butonu
                          GestureDetector(
                            onTap: () => _openArticle(group, item),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.5),
                                    width: 1),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      item.dosyaHikayesi
                                          ? (isEn
                                              ? 'Open Dossier'
                                              : 'Dosyayı Aç')
                                          : (isEn
                                              ? 'Read Article'
                                              : 'Haberi Oku'),
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.arrow_forward_ios,
                                        color: Colors.white, size: 14),
                                  ],
                                ),
                              ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),

                  // Header (Progress bars + Profile)
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 10.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Ö8 — TEK SLAYTLIK grupta çubuk çizilmiyor.
                          // Aktif hikâyelerin çoğu tek slayt taşıyor ve
                          // ekranın tepesinde tek parça, hiç bölünmeyen bir
                          // çubuk "burada bir şey eksik" izlenimi veriyordu.
                          // Süreyi avatarın çevresindeki halka söylüyor.
                          if (group.items.length > 1)
                            Row(
                              children: List.generate(
                                group.items.length,
                                (i) => Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 2.0),
                                    child: _buildProgressBar(
                                      isCurrentGroup: isCurrentGroup,
                                      itemIndex: i,
                                      currentIndex: itemIndex,
                                      slayt: group.items[i],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          SizedBox(height: group.items.length > 1 ? 12 : 4),
                          Row(
                            children: [
                              // Tek slaytta süre halkası avatarın çevresinde:
                              // bilgi kaybolmuyor, ekranın tepesi sessizleşiyor.
                              _AvatarHalkasi(
                                avatarUrl: group.avatarUrl,
                                onizleme: group.avatarOnizleme,
                                renk: konuCipRengi(group.title),
                                ilerleme: group.items.length > 1
                                    ? null
                                    : (isCurrentGroup ? _animController : null),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  group.titleFor(isEn),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.ios_share,
                                    color: Colors.white, size: 20),
                                tooltip: isEn ? 'Share' : 'Paylaş',
                                onPressed: () => _share(group, item, isEn),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close,
                                    color: Colors.white),
                                tooltip: isEn ? 'Close' : 'Kapat',
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  /// Ö6 — segment BİLGİ TAŞIYOR.
  ///
  /// Eskiden çubuklar yalnızca "kaç slayt kaldı" diyordu. Artık dolan kısım
  /// o slaytın konu rengiyle boyanıyor ve son dakika slaytının segmenti
  /// altında ince bir kırmızı çizgi taşıyor: okur grubu açmadan hangi
  /// slaytın acil olduğunu görüyor.
  Widget _buildProgressBar({
    required bool isCurrentGroup,
    required int itemIndex,
    required int currentIndex,
    required StoryItem slayt,
  }) {
    final Color dolu = konuCipRengi(_currentGroup.title);

    Widget govde;
    if (!isCurrentGroup || itemIndex > currentIndex) {
      govde = _bar(Colors.white.withOpacity(0.28));
    } else if (itemIndex < currentIndex) {
      govde = _bar(dolu);
    } else {
      govde = AnimatedBuilder(
        animation: _animController,
        builder: (context, child) {
          return Stack(
            children: [
              _bar(Colors.white.withOpacity(0.28)),
              FractionallySizedBox(
                widthFactor: _animController.value,
                child: _bar(dolu),
              ),
            ],
          );
        },
      );
    }

    if (!slayt.isBreaking) return govde;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        govde,
        const SizedBox(height: 2),
        Container(
          height: 2,
          decoration: BoxDecoration(
            color: const Color(0xFFE94057),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ],
    );
  }

  Widget _bar(Color color) => Container(
        height: 3,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      );
}

/// Avatar ve çevresindeki süre halkası.
///
/// [ilerleme] verilmezse halka çizilmiyor — çok slaytlı gruplarda süreyi
/// üstteki çubuk zaten söylüyor ve iki ayrı yerde göstermek gürültü olur.
class _AvatarHalkasi extends StatelessWidget {
  const _AvatarHalkasi({
    required this.avatarUrl,
    required this.onizleme,
    required this.renk,
    required this.ilerleme,
  });

  final String avatarUrl;
  final String onizleme;
  final Color renk;
  final Animation<double>? ilerleme;

  static const double _olcu = 36;
  static const double _halka = 2.5;

  @override
  Widget build(BuildContext context) {
    final avatar = ClipOval(
      child: StoryThumbImage(
          url: avatarUrl, size: _olcu, onizleme: onizleme),
    );
    final anim = ilerleme;
    if (anim == null) return avatar;

    return SizedBox(
      width: _olcu + _halka * 4,
      height: _olcu + _halka * 4,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: anim,
            builder: (context, _) => SizedBox(
              width: _olcu + _halka * 3,
              height: _olcu + _halka * 3,
              child: CircularProgressIndicator(
                value: anim.value,
                strokeWidth: _halka,
                backgroundColor: Colors.white.withOpacity(0.22),
                valueColor: AlwaysStoppedAnimation<Color>(renk),
              ),
            ),
          ),
          avatar,
        ],
      ),
    );
  }
}
