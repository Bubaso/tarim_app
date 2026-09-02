// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';

import '../../../../core/utils/image_fallback_helper.dart';
import '../../../../core/utils/responsive_breakpoints.dart';

// ══════════════════════════════════════════════════════════════════════════════
//  Home skeleton yükleyicisi — veri gelene kadar shimmer iskelet
// ══════════════════════════════════════════════════════════════════════════════

/// İskelet, yerini tuttuğu düzenin birebir aynısı olmalı; aksi hâlde veri
/// gelince sayfa zıplar. Bu yüzden [_buildBody] ile **aynı** kırılım
/// noktalarını ve aynı dolgu/boşluk değerlerini kullanıyoruz:
///   Mobil   (< 650)  → kenardan kenara, ListView padding yok
///   Tablet  (650–1099) → EdgeInsets.all(24)
///   Masaüstü (≥ 1100) → maxWidth 1200, hPad 24 / vPad 20
/// Hero bloğu ise HeroFold'un kendi 900 px eşiğini izler.
class HomeSkeletonLoader extends StatelessWidget {
  final bool isDark;

  const HomeSkeletonLoader({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width >= ResponsiveBreakpoints.tabletMax) {
      return SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _SkeletonHero(isDark: isDark, splitColumns: true),
                const SizedBox(height: 40),
                _SkeletonSection(isDark: isDark, compactHeader: false),
                const SizedBox(height: 40),
                _SkeletonSection(isDark: isDark, compactHeader: false),
              ],
            ),
          ),
        ),
      );
    }

    if (width >= ResponsiveBreakpoints.mobileMax) {
      final splitColumns = width >= ResponsiveBreakpoints.contentWide;
      return SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero kendi 900 px eşiğini izliyor; bölüm başlığı ise mobileMax'ı
            // — bu aralıkta (650–1099) başlık artık geniş sürümde.
            _SkeletonHero(isDark: isDark, splitColumns: splitColumns),
            const SizedBox(height: 36),
            _SkeletonSection(isDark: isDark, compactHeader: false),
            const SizedBox(height: 36),
            _SkeletonSection(isDark: isDark, compactHeader: false),
          ],
        ),
      );
    }

    // Mobil — gerçek düzende ListView padding'i sıfır, manşet kenardan kenara.
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SkeletonHero(isDark: isDark, splitColumns: false),
          const SizedBox(height: 28),
          _SkeletonSection(isDark: isDark, compactHeader: true),
          const SizedBox(height: 28),
          _SkeletonSection(isDark: isDark, compactHeader: true),
        ],
      ),
    );
  }
}

/// HeroFold'un iskeleti. [splitColumns] true iken masaüstündeki 7:3 satır,
/// false iken mobildeki "manşet + yatay yazar şeridi" sütunu taklit edilir.
class _SkeletonHero extends StatelessWidget {
  final bool isDark;
  final bool splitColumns;

  const _SkeletonHero({required this.isDark, required this.splitColumns});

  @override
  Widget build(BuildContext context) {
    // HeroFold'daki carousel ile aynı en–boy oranı.
    const carousel = AspectRatio(
      aspectRatio: 1.8,
      child:
          ShimmerPlaceholder(width: double.infinity, height: double.infinity),
    );

    if (splitColumns) {
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Expanded(flex: 7, child: carousel),
            const SizedBox(width: 28),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ShimmerPlaceholder(width: 140, height: 20),
                  const SizedBox(height: 6),
                  const ShimmerPlaceholder(width: 40, height: 3),
                  const SizedBox(height: 16),
                  for (var i = 0; i < 3; i++) ...[
                    SmallCardSkeleton(isDark: isDark),
                    const SizedBox(height: 14),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        carousel,
        const SizedBox(height: 28),
        // "YAZARLARIMIZ" başlığı — gerçek düzende 16 px yatay dolgulu.
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerPlaceholder(width: 160, height: 20),
              SizedBox(height: 6),
              ShimmerPlaceholder(width: 40, height: 3),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Yatay kaydırılabilir yazar şeridi (gerçek yükseklik: 180).
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 4,
            itemBuilder: (context, index) => const Padding(
              padding: EdgeInsets.only(right: 12),
              child: ShimmerPlaceholder(width: 130, height: 180),
            ),
          ),
        ),
      ],
    );
  }
}

/// `_SectionContainer` + yatay kart şeridinin iskeleti.
class _SkeletonSection extends StatelessWidget {
  final bool isDark;

  /// `_SectionContainer` başlığı `ResponsiveBreakpoints.mobileMax` altında
  /// küçülüyor; iskelet aynı eşiği izlemeli, yoksa veri gelince başlık zıplar.
  final bool compactHeader;

  const _SkeletonSection({required this.isDark, required this.compactHeader});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bölüm üstündeki 1 px ayırıcı.
              const ShimmerPlaceholder(width: double.infinity, height: 1),
              const SizedBox(height: 16),
              Row(
                children: [
                  ShimmerPlaceholder(
                    width: compactHeader ? 20 : 24,
                    height: compactHeader ? 20 : 24,
                  ),
                  const SizedBox(width: 8),
                  ShimmerPlaceholder(
                    width: compactHeader ? 200 : 260,
                    height: compactHeader ? 17 : 20,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Yatay kart şeridi — gerçek düzende 320 yükseklik / 260 genişlik.
        SizedBox(
          height: 320,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 4,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.only(right: 16),
              child: SizedBox(
                width: 260,
                child: NewsCardSkeleton(isDark: isDark),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
