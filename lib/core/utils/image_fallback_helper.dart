// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

// ══════════════════════════════════════════════════════════════════════════════
//  Shimmer skeleton — tüm yükleme iskeletlerinde kullanılan paylaşımlı widget
// ══════════════════════════════════════════════════════════════════════════════

class ShimmerPlaceholder extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const ShimmerPlaceholder({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base    = isDark ? const Color(0xFF1E2631) : const Color(0xFFE8E6E1);
    final hilite  = isDark ? const Color(0xFF2C3A4A) : const Color(0xFFF5F3EF);

    return Shimmer.fromColors(
      baseColor:     base,
      highlightColor: hilite,
      period: const Duration(milliseconds: 1400),
      child: Container(
        width:  width,
        height: height,
        decoration: BoxDecoration(
          color: base,
          borderRadius: borderRadius ?? BorderRadius.zero,
        ),
      ),
    );
  }
}

// ── Haber resmi — yüklenirken shimmer, hata durumunda shimmer ────────────────

class NewsArticleImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;

  const NewsArticleImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim();
    if (url == null || url.isEmpty) {
      return ShimmerPlaceholder(width: width, height: height);
    }
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      return ShimmerPlaceholder(width: width, height: height);
    }

    return Image.network(
      url,
      width:  width,
      height: height,
      fit:    fit,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return ShimmerPlaceholder(width: width, height: height);
      },
      errorBuilder: (context, error, stackTrace) {
        return ShimmerPlaceholder(width: width, height: height);
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  Skeleton bileşenleri — paylaşımlı iskelet kutu türleri
// ══════════════════════════════════════════════════════════════════════════════

/// Tek bir iskelet kutu — genişlik/yükseklik ve opsiyonel köşe yuvarlama
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const SkeletonBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerPlaceholder(
      width: width,
      height: height,
      borderRadius: borderRadius,
    );
  }
}

/// Haber kartı iskelet yükleyicisi — 16:9 görsel + 3 metin satırı
class NewsCardSkeleton extends StatelessWidget {
  final bool isDark;

  const NewsCardSkeleton({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final base   = isDark ? const Color(0xFF1E2631) : const Color(0xFFE8E6E1);
    final hilite = isDark ? const Color(0xFF2C3A4A) : const Color(0xFFF5F3EF);

    return Shimmer.fromColors(
      baseColor:     base,
      highlightColor: hilite,
      period: const Duration(milliseconds: 1400),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 16:9 görsel kutusu
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(color: base),
          ),
          const SizedBox(height: 12),
          // Kaynak etiketi + tarih satırı
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                Container(width: 64, height: 10, color: base),
                const Spacer(),
                Container(width: 80, height: 10, color: base),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Başlık satırı 1
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Container(width: double.infinity, height: 16, color: base),
          ),
          const SizedBox(height: 6),
          // Başlık satırı 2 (kısa)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Container(width: 200, height: 16, color: base),
          ),
          const SizedBox(height: 8),
          // Özet satırı
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Container(width: double.infinity, height: 12, color: base),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// Küçük liste satırı iskelet (SmallCard / ListItem için)
class SmallCardSkeleton extends StatelessWidget {
  final bool isDark;

  const SmallCardSkeleton({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final base   = isDark ? const Color(0xFF1E2631) : const Color(0xFFE8E6E1);
    final hilite = isDark ? const Color(0xFF2C3A4A) : const Color(0xFFF5F3EF);

    return Shimmer.fromColors(
      baseColor:     base,
      highlightColor: hilite,
      period: const Duration(milliseconds: 1400),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 80, height: 80, color: base),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 60, height: 9, color: base),
                const SizedBox(height: 6),
                Container(width: double.infinity, height: 13, color: base),
                const SizedBox(height: 5),
                Container(width: 140, height: 13, color: base),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Yatay ilgili haber kartı iskeleti (ArticleDetailScreen related strip)
class RelatedCardSkeleton extends StatelessWidget {
  final bool isDark;

  const RelatedCardSkeleton({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final base   = isDark ? const Color(0xFF1E2631) : const Color(0xFFE8E6E1);
    final hilite = isDark ? const Color(0xFF2C3A4A) : const Color(0xFFF5F3EF);

    return Shimmer.fromColors(
      baseColor:     base,
      highlightColor: hilite,
      period: const Duration(milliseconds: 1400),
      child: SizedBox(
        width: 220,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 16:9 görsel
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(color: base),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 50, height: 9, color: base),
                  const SizedBox(height: 6),
                  Container(width: double.infinity, height: 13, color: base),
                  const SizedBox(height: 4),
                  Container(width: 140, height: 13, color: base),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
