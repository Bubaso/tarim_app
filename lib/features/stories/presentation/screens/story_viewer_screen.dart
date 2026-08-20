import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/story_item.dart';
import '../widgets/story_image.dart';

class StoryViewerScreen extends StatefulWidget {
  final List<StoryGroup> storyGroups;
  final int initialGroupIndex;

  const StoryViewerScreen({
    super.key,
    required this.storyGroups,
    this.initialGroupIndex = 0,
  });

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen> with TickerProviderStateMixin {
  late PageController _pageController;
  late int _currentGroupIndex;
  int _currentItemIndex = 0;
  
  Timer? _timer;
  late AnimationController _animController;
  final Duration _storyDuration = const Duration(seconds: 7);

  /// Arka plan görselinin hikaye boyunca kapanan yakınlaştırma payı.
  /// 0 yapılırsa hareket tamamen kalkar, kare sabit kalır.
  static const double _kenBurnsZoom = 0.05;

  @override
  void initState() {
    super.initState();
    _currentGroupIndex = widget.initialGroupIndex;
    _pageController = PageController(initialPage: _currentGroupIndex);
    
    _animController = AnimationController(vsync: this, duration: _storyDuration);
    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _nextStory();
      }
    });
    
    _startStory();
    WidgetsBinding.instance.addPostFrameCallback((_) => _precacheNeighbours());
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
        storyBackgroundProvider(context, group.items.first.backgroundUrl),
        context,
      );
    }
  }

  void _startStory() {
    _animController.stop();
    _animController.reset();
    _animController.forward();
  }

  void _nextStory() {
    final group = widget.storyGroups[_currentGroupIndex];
    if (_currentItemIndex < group.items.length - 1) {
      setState(() {
        _currentItemIndex++;
      });
      _startStory();
    } else {
      if (_currentGroupIndex < widget.storyGroups.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      } else {
        Navigator.of(context).pop();
      }
    }
  }

  void _previousStory() {
    if (_currentItemIndex > 0) {
      setState(() {
        _currentItemIndex--;
      });
      _startStory();
    } else {
      if (_currentGroupIndex > 0) {
        _pageController.previousPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
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

  @override
  void dispose() {
    _timer?.cancel();
    _animController.dispose();
    _pageController.dispose();
    super.dispose();
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
          onLongPressStart: (_) => _animController.stop(),
          onLongPressEnd: (_) => _animController.forward(),
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: widget.storyGroups.length,
            itemBuilder: (context, index) {
              final group = widget.storyGroups[index];
              final isCurrentGroup = index == _currentGroupIndex;
              final itemIndex = isCurrentGroup ? _currentItemIndex : 0;
              final item = group.items[itemIndex];

              final bool isEn = Localizations.localeOf(context).languageCode == 'en';
              final String displayGroupTitle = isEn && group.titleEn.isNotEmpty ? group.titleEn : group.title;
              final String displaySuperTitle = isEn && item.superTitleEn.isNotEmpty ? item.superTitleEn : item.superTitle;
              final String displayHeadline = isEn && item.headlineEn.isNotEmpty ? item.headlineEn : item.headline;
              final String displayBigStat = isEn && item.bigStatValueEn.isNotEmpty ? item.bigStatValueEn : item.bigStatValue;
              final String displayStatLabel = isEn && item.statLabelEn.isNotEmpty ? item.statLabelEn : item.statLabel;

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
                      // Çok hafif bir "Ken Burns": kare 1.05'ten 1.00'e iner,
                      // yani hikaye net kareyle biter. Kapatmak için sabiti 0 yap.
                      final double t = isCurrentGroup
                          ? Curves.easeOutSine.transform(_animController.value)
                          : 0.0;
                      return Transform.scale(
                        scale: 1.0 + _kenBurnsZoom * (1 - t),
                        child: child,
                      );
                    },
                    child: StoryBackgroundImage(url: item.backgroundUrl),
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
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Spacer(),
                          
                          // Üst Başlık (Kategori) - Artık ana istatistiğin hemen üstünde
                          AnimatedBuilder(
                            animation: _animController,
                            builder: (context, child) {
                              return Opacity(
                                opacity: Curves.easeIn.transform((_animController.value * 5).clamp(0.0, 1.0)),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryGreen,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    displaySuperTitle.toUpperCase(),
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
                              final val = Curves.elasticOut.transform((_animController.value * 2).clamp(0.0, 1.0));
                              return Transform.scale(
                                scale: 0.5 + (0.5 * val),
                                alignment: Alignment.centerLeft,
                                child: Opacity(
                                  opacity: val.clamp(0.0, 1.0),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      displayBigStat,
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
                            }
                          ),
                          const SizedBox(height: 8),
                          
                          // İstatistik Açıklaması
                          Text(
                            displayStatLabel,
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
                            displayHeadline,
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
                            onTap: () {
                              context.push('/haber/${group.articleId}');
                            },
                            child: AnimatedBuilder(
                              animation: _animController,
                              builder: (context, child) {
                                return Opacity(
                                  // Animasyon biraz daha erken gelsin
                                  opacity: Curves.easeIn.transform((_animController.value * 2 - 0.5).clamp(0.0, 1.0)),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
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
                                        const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
                                      ],
                                    ),
                                  ),
                                );
                              }
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
                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: List.generate(
                              group.items.length,
                              (i) => Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                                  child: _buildProgressBar(
                                    isCurrentGroup: isCurrentGroup,
                                    itemIndex: i,
                                    currentIndex: _currentItemIndex,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              ClipOval(
                                child: StoryCircleImage(url: group.avatarUrl, size: 36),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                displayGroupTitle,
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.white),
                                onPressed: () => Navigator.of(context).pop(),
                              )
                            ],
                          )
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
    if (!isCurrentGroup) {
      return Container(height: 3, decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), borderRadius: BorderRadius.circular(2)));
    }
    if (itemIndex < currentIndex) {
      return Container(height: 3, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(2)));
    }
    if (itemIndex > currentIndex) {
      return Container(height: 3, decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), borderRadius: BorderRadius.circular(2)));
    }
    
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return Stack(
          children: [
            Container(height: 3, decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), borderRadius: BorderRadius.circular(2))),
            FractionallySizedBox(
              widthFactor: _animController.value,
              child: Container(height: 3, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(2))),
            ),
          ],
        );
      },
    );
  }
}
