// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:tarim_app/core/theme/app_dark_mode.dart';
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
    final isDark = appIsDark;
    // Anasayfa zeminine uygun ama "yükleniyor"un okunduğu tonlar. Eski taban
    // (#EBE6DD) kremin üstünde neredeyse görünmezdi ve gri bir "bozuk görsel"
    // gibi duruyordu; biraz koyulaştırıldı, parıltı farkı açıldı.
    final base    = isDark ? const Color(0xFF253B24) : const Color(0xFFE0D8C6);
    final hilite  = isDark ? const Color(0xFF355234) : const Color(0xFFF2ECDF);

    return Shimmer.fromColors(
      baseColor:     base,
      highlightColor: hilite,
      period: const Duration(milliseconds: 1300),
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
  final String? semanticLabel;
  final bool isHighQuality;

  const NewsArticleImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.semanticLabel,
    this.isHighQuality = false,
  });


  /// Ham Supabase URL'ini istenen genişlik/kaliteyle CDN-render adresine
  /// çevirir. `build` ve [providerFor] (ön yükleme) aynı adresi üretsin diye
  /// tek yerde.
  static String resolveUrl(String rawUrl,
      {required int requestedWidth, required bool highQuality}) {
    final q = highQuality ? 90 : 65;
    if (!rawUrl.contains('/object/public/')) return rawUrl;
    final replaced =
        rawUrl.replaceFirst('/object/public/', '/render/image/public/');
    final sep = replaced.contains('?') ? '&' : '?';
    return '$replaced${sep}width=$requestedWidth&quality=$q&format=webp';
  }

  static int _clampWidth(double render, bool highQuality) {
    var w = highQuality ? 2000 : (render * 2).toInt();
    if (w > 2000) w = 2000;
    if (w < 300) w = 300;
    return w;
  }

  /// Hero gibi öncelikli görsellerin `precacheImage` ile önden yüklenmesi için.
  static ImageProvider? providerFor(String? rawUrl,
      {double estimatedWidth = 1200, bool highQuality = true}) {
    final u = rawUrl?.trim();
    if (u == null || u.isEmpty || !u.startsWith('http')) return null;
    return CachedNetworkImageProvider(resolveUrl(u,
        requestedWidth: _clampWidth(estimatedWidth, highQuality),
        highQuality: highQuality));
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

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate the actual rendering width.
        double renderWidth = (width != null && width!.isFinite)
            ? width!
            : (constraints.maxWidth.isFinite ? constraints.maxWidth : 600);
        // Fallback safety limit
        if (renderWidth <= 0 || renderWidth.isInfinite) renderWidth = 600;

        final requestedWidth = _clampWidth(renderWidth, isHighQuality);
        final url = resolveUrl(rawUrl,
            requestedWidth: requestedWidth, highQuality: isHighQuality);

        final imageWidget = CachedNetworkImage(
          imageUrl: url,
          width: width ?? (constraints.maxWidth.isFinite ? constraints.maxWidth : null),
          height: height ?? (constraints.maxHeight.isFinite ? constraints.maxHeight : null),
          fit: fit,
          filterQuality: isHighQuality ? FilterQuality.high : FilterQuality.medium,
          // İstenen çözünürlükte çöz — daha küçük bir kartta 2000 px'lik bir
          // görseli tam boyutta decode etmek web'de gözle görülür takılma
          // yapıyordu.
          memCacheWidth: requestedWidth,
          fadeInDuration: const Duration(milliseconds: 300),
          httpHeaders: const {
            'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
            'Accept': 'image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8',
          },
          placeholder: (context, url) => ShimmerPlaceholder(width: width, height: height),
          errorWidget: (context, url, error) => ShimmerPlaceholder(width: width, height: height),
        );

        if (semanticLabel != null && semanticLabel!.isNotEmpty) {
          return Semantics(
            label: semanticLabel,
            image: true,
            child: imageWidget,
          );
        } else {
          return ExcludeSemantics(child: imageWidget);
        }
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
    final base    = isDark ? const Color(0xFF253B24) : const Color(0xFFEBE6DD);
    final hilite  = isDark ? const Color(0xFF355234) : const Color(0xFFF4EFE6);

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
    final base    = isDark ? const Color(0xFF253B24) : const Color(0xFFEBE6DD);
    final hilite  = isDark ? const Color(0xFF355234) : const Color(0xFFF4EFE6);

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
    final base    = isDark ? const Color(0xFF253B24) : const Color(0xFFEBE6DD);
    final hilite  = isDark ? const Color(0xFF355234) : const Color(0xFFF4EFE6);

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
