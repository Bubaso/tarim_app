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

  /// Komşu hikayelerin tam boy görsellerini önden indirir; böylece sağa/sola
  /// geçişte bulanık ara kare yerine doğrudan net görsel açılır.
  void _precacheNeighbours() {
    if (!mounted) return;
    for (final int offset in const [1, 2, -1]) {
      final int i = _currentGroupIndex + offset;
      if (i < 0 || i >= widget.storyGroups.length) continue;
      final group = widget.storyGroups[i];
      if (group.items.isEmpty) continue;
      precacheImage(
        storyBackgroundProvider(
          context,
          imageUrl: group.items.first.imageUrl,
          portraitUrl: group.items.first.portraitUrl,
        ),
        context,
      );
    }
  }

  /// Slaytı başlatır: süreyi metin uzunluğundan hesaplar, izlendi defterine
  /// işler ve sayacı sıfırdan başlatır.
  void _startStory() {
    final item = _currentItem;
    // Süre kaynak (Türkçe) metnin uzunluğundan hesaplanıyor; çeviriler benzer
    // uzunlukta ve bu sayede `Localizations` bağlamına ihtiyaç kalmıyor.
    _animController.duration = storySlideDuration(item.headline, item.statLabel);
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

  String _shareUrl(String articleId) {
    final origin = kIsWeb ? Uri.base.origin : _productionOrigin;
    return '$origin${articlePath(articleId)}';
  }

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
    router.push(articlePath(item.articleId));
  }

  Future<void> _share(StoryGroup group, StoryItem item, bool isEn) async {
    _animController.stop();
    StoryAnalytics.shared(groupKey: group.key, articleId: item.articleId);

    final box = context.findRenderObject() as RenderBox?;
    final text = '${item.headlineFor(isEn)}\n'
        '${item.bigStatValueFor(isEn)} · ${item.statLabelFor(isEn)}\n\n'
        '${_shareUrl(item.articleId)}';
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

                          // Üst Başlık (Kategori)
                          AnimatedBuilder(
                            animation: _animController,
                            builder: (context, child) {
                              return Opacity(
                                opacity: Curves.easeIn.transform(
                                    (_animController.value * 5).clamp(0.0, 1.0)),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryGreen,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    item.superTitleFor(isEn).toUpperCase(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                              );
                            },
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
                                      style: GoogleFonts.playfairDisplay(
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
                            style: GoogleFonts.playfairDisplay(
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
                            child: AnimatedBuilder(
                              animation: _animController,
                              builder: (context, child) {
                                return Opacity(
                                  // Animasyon biraz daha erken gelsin
                                  opacity: Curves.easeIn.transform(
                                      (_animController.value * 2 - 0.5)
                                          .clamp(0.0, 1.0)),
                                  child: child,
                                );
                              },
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
                                      isEn ? 'Read Article' : 'Haberi Oku',
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
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              ClipOval(
                                child: StoryThumbImage(
                                    url: group.avatarUrl, size: 36),
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
                                icon: const Icon(Icons.close, color: Colors.white),
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

  Widget _buildProgressBar({
    required bool isCurrentGroup,
    required int itemIndex,
    required int currentIndex,
  }) {
    if (!isCurrentGroup || itemIndex > currentIndex) {
      return _bar(Colors.white.withOpacity(0.3));
    }
    if (itemIndex < currentIndex) {
      return _bar(Colors.white);
    }

    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return Stack(
          children: [
            _bar(Colors.white.withOpacity(0.3)),
            FractionallySizedBox(
              widthFactor: _animController.value,
              child: _bar(Colors.white),
            ),
          ],
        );
      },
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
