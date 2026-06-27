// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';

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

  String _optimizeUrl(String url) {
    // Supabase Image Transformations
    if (url.contains('/object/public/')) {
      // Convert standard public URL to render/image endpoint with params
      final replaced = url.replaceFirst('/object/public/', '/render/image/public/');
      if (replaced.contains('?')) {
        return '$replaced&width=600&quality=75';
      } else {
        return '$replaced?width=600&quality=75';
      }
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    final rawUrl = imageUrl?.trim();
    if (rawUrl == null || rawUrl.isEmpty) {
      return ShimmerPlaceholder(width: width, height: height);
    }
    if (!rawUrl.startsWith('http://') && !rawUrl.startsWith('https://')) {
      return ShimmerPlaceholder(width: width, height: height);
    }

    final url = _optimizeUrl(rawUrl);

    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      fadeInDuration: const Duration(milliseconds: 300),
      httpHeaders: const {
        'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        'Accept': 'image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8',
      },
      placeholder: (context, url) => ShimmerPlaceholder(width: width, height: height),
      errorWidget: (context, url, error) => ShimmerPlaceholder(width: width, height: height),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Container(width: 50, height: 10, color: base),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Container(width: 70, height: 10, color: base),
                ),
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
          // Başlık satırı 2 (kısa, oransal)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: 0.6,
                child: Container(height: 16, color: base),
              ),
            ),
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
                Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: 0.6,
                    child: Container(height: 13, color: base),
                  ),
                ),
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
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: 0.6,
                      child: Container(height: 13, color: base),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
