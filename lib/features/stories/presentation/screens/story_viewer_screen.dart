import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/story_item.dart';

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
                  Image.network(
                    item.backgroundUrl,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.high,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.primaryGreen,
                      child: const Center(
                        child: Icon(Icons.broken_image, size: 64, color: Colors.white54),
                      ),
                    ),
                  ),
                  
                  // Koyu Karartma (Gradient overlay for text readability)
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.transparent,
                          Colors.black.withOpacity(0.9),
                        ],
                        stops: const [0.0, 0.4, 1.0],
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
                                child: Image.network(
                                  group.avatarUrl,
                                  width: 36,
                                  height: 36,
                                  fit: BoxFit.cover,
                                  filterQuality: FilterQuality.high,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    color: AppColors.wheat,
                                    child: const Icon(Icons.broken_image, size: 16, color: Colors.white),
                                  ),
                                ),
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
