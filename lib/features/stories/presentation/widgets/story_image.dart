// ignore_for_file: deprecated_member_use
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

// ══════════════════════════════════════════════════════════════════════════════
//  Hikaye görselleri — çözünürlük / kalite katmanı
// ──────────────────────────────────────────────────────────────────────────────
//  Hikaye ekranı görselleri ham `Image.network` ile, yani Supabase Storage'ın
//  `/object/public/` uç noktasından dosyanın orijinal hâliyle çekiyordu. Bunun
//  iki sonucu vardı:
//    1) Dosya diske hiç önbelleklenmiyordu (her açılışta yeniden indirme),
//    2) Görsel cihazda yeniden ölçekleniyordu — 76 px'lik avatarda 2 MB'lık
//       orijinal küçültülüyor, tam ekranda ise küçük bir görsel büyütülüyordu.
//
//  Bu dosya, tüm hikaye görsellerini Supabase'in `/render/image/public/`
//  dönüştürme uç noktasından, hedef pikselin tam ölçüsünde ve WebP olarak
//  ister. Ölçekleme sunucuda (Lanczos) yapıldığı için sonuç belirgin biçimde
//  daha net, dosya da daha küçüktür.
// ══════════════════════════════════════════════════════════════════════════════

/// WebP/AVIF pazarlığı için gereken başlıklar. Supabase dönüştürme uç noktası
/// çıktı formatını `Accept` başlığına göre seçer.
const Map<String, String> kStoryImageHeaders = {
  'Accept': 'image/avif,image/webp,image/apng,image/*,*/*;q=0.8',
};

/// Yükleme/hata sırasında ekranı dolduran nötr zemin (siyah üzerine hafif yeşil).
const Color kStoryImageBackdrop = Color(0xFF12160F);

/// URL'in Supabase Storage'ın dönüştürülebilir public uç noktasına ait olup
/// olmadığı. Harici CDN adreslerine dokunmuyoruz.
bool storyImageIsTransformable(String rawUrl) =>
    rawUrl.contains('/object/public/') || rawUrl.contains('/render/image/public/');

/// Ham depolama URL'ini, istenen piksel ölçüsünde bir dönüştürme URL'ine çevirir.
///
/// [width]/[height] **cihaz pikseli** cinsindendir (logical px * devicePixelRatio).
/// [crop] true ise sunucu görseli tam olarak verilen kutuya kırpar (avatarlar
/// için: ortadan kare kırpma, istemcinin daireye sığdırırken bozması yerine).
String storyImageUrl(
  String rawUrl, {
  required int width,
  int? height,
  int quality = 85,
  bool crop = false,
}) {
  final String url = rawUrl.trim();
  if (!url.startsWith('http')) return url;
  if (!storyImageIsTransformable(url)) return url;

  final String base = url.replaceFirst('/object/public/', '/render/image/public/');
  final StringBuffer out = StringBuffer(base)
    ..write(base.contains('?') ? '&' : '?')
    ..write('width=$width');
  if (height != null) out.write('&height=$height');
  if (crop) out.write('&resize=cover');
  out.write('&quality=$quality');
  return out.toString();
}

/// Tam ekran arka plan için hedef piksel genişliği.
///
/// Yatay (16:9) bir basın fotoğrafı dikey bir telefon ekranını `cover` ile
/// kapladığında belirleyici olan ekranın **uzun** kenarıdır; bu yüzden hedefi
/// kısa kenara göre değil uzun kenara göre hesaplıyoruz. 1920 px üst sınırı,
/// WebP q88'de ~300-500 KB'a denk gelir ve pratikte kaynak görselin çözünürlüğü
/// zaten bunun altında kalır.
int storyBackgroundTargetWidth(BuildContext context) {
  final MediaQueryData media = MediaQuery.of(context);
  final double px = media.size.longestSide * media.devicePixelRatio;
  if (px.isNaN || !px.isFinite || px <= 0) return 1440;
  return px.clamp(1080.0, 1920.0).round();
}

/// Tam ekran arka planın [ImageProvider]'ı — komşu hikayeleri `precacheImage`
/// ile önden yüklemek için ekranla birebir aynı URL'i üretir.
ImageProvider storyBackgroundProvider(BuildContext context, String rawUrl) {
  return CachedNetworkImageProvider(
    storyImageUrl(rawUrl, width: storyBackgroundTargetWidth(context), quality: 88),
    headers: kStoryImageHeaders,
  );
}

// ── Tam ekran arka plan görseli ───────────────────────────────────────────────

class StoryBackgroundImage extends StatelessWidget {
  const StoryBackgroundImage({super.key, required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final int target = storyBackgroundTargetWidth(context);
    final String hiRes = storyImageUrl(url, width: target, quality: 88);
    final bool canBlurUp = storyImageIsTransformable(url);

    return CachedNetworkImage(
      imageUrl: hiRes,
      httpHeaders: kStoryImageHeaders,
      fit: BoxFit.cover,
      // Kübik örnekleme: büyütmede de küçültmede de en temiz sonuç.
      filterQuality: FilterQuality.high,
      fadeInDuration: const Duration(milliseconds: 220),
      placeholder: (context, _) => canBlurUp
          ? _BlurUpPlaceholder(url: storyImageUrl(url, width: 48, quality: 40))
          : const ColoredBox(color: kStoryImageBackdrop),
      // Dönüştürme uç noktası bir sebeple cevap veremezse ham dosyaya düş.
      errorWidget: (context, _, __) => _RawImageFallback(url: url),
    );
  }
}

/// Yüksek çözünürlüklü kare gelene kadar gösterilen, 48 px'lik minik kopyanın
/// bulanıklaştırılmış hâli. Boş siyah ekran yerine görselin rengiyle açılır.
class _BlurUpPlaceholder extends StatelessWidget {
  const _BlurUpPlaceholder({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: kStoryImageBackdrop),
        CachedNetworkImage(
          imageUrl: url,
          httpHeaders: kStoryImageHeaders,
          fit: BoxFit.cover,
          fadeInDuration: Duration.zero,
          placeholder: (_, __) => const SizedBox.shrink(),
          errorWidget: (_, __, ___) => const SizedBox.shrink(),
          imageBuilder: (context, provider) => ImageFiltered(
            imageFilter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Image(image: provider, fit: BoxFit.cover),
          ),
        ),
      ],
    );
  }
}

/// Dönüştürme uç noktası hata verirse ham dosyayı dener; o da olmazsa nötr zemin.
class _RawImageFallback extends StatelessWidget {
  const _RawImageFallback({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      httpHeaders: kStoryImageHeaders,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.high,
      fadeInDuration: const Duration(milliseconds: 200),
      placeholder: (_, __) => const ColoredBox(color: kStoryImageBackdrop),
      errorWidget: (_, __, ___) => const ColoredBox(
        color: kStoryImageBackdrop,
        child: Center(
          child: Icon(Icons.broken_image_outlined, size: 48, color: Colors.white24),
        ),
      ),
    );
  }
}

// ── Küçük kare görsel (şerit baloncuğu / başlık avatarı) ─────────────────────

/// Hikaye baloncukları. Kare kırpma sunucuda yapılır: istemci artık geniş bir
/// basın fotoğrafını küçücük bir kutuya sığdırmaya çalışmaz, hazır kare gelir.
///
/// Kırpma tam ortadan değil, bir tık yukarıdan yapılıyor: basın fotoğraflarında
/// ilgi noktası (yüzler, ürün) genellikle karenin üst yarısında kalır, tam orta
/// hizalama insanları çene hizasından kesiyordu.
class StoryThumbImage extends StatelessWidget {
  const StoryThumbImage({
    super.key,
    required this.url,
    required this.size,
    this.fill = false,
    this.alignment = const Alignment(0, -0.2),
  });

  final String url;

  /// Logical piksel cinsinden kenar uzunluğu. [fill] true iken yalnızca
  /// indirilecek çözünürlüğü belirler, yerleşimi ebeveyn belirler.
  final double size;

  /// true ise widget kendi ölçüsünü dayatmaz, ebeveyninin kutusunu doldurur.
  final bool fill;

  /// Kırpma hizası; varsayılan olarak merkezin biraz üstü.
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final double dpr = MediaQuery.of(context).devicePixelRatio;
    final int target = (size * dpr).clamp(96.0, 512.0).round();
    final String thumb =
        storyImageUrl(url, width: target, height: target, quality: 82, crop: true);

    return CachedNetworkImage(
      imageUrl: thumb,
      httpHeaders: kStoryImageHeaders,
      width: fill ? null : size,
      height: fill ? null : size,
      fit: BoxFit.cover,
      alignment: alignment,
      filterQuality: FilterQuality.high,
      fadeInDuration: const Duration(milliseconds: 180),
      // Sunucu zaten hedef ölçüde gönderiyor; bu satır dönüştürmenin devre dışı
      // olduğu (harici CDN) durumlarda bellekteki kopyayı sınırlar.
      memCacheWidth: target,
      placeholder: (_, __) => const ColoredBox(color: kStoryImageBackdrop),
      errorWidget: (_, __, ___) =>
          _RawThumbFallback(url: url, size: fill ? null : size, alignment: alignment),
    );
  }
}

class _RawThumbFallback extends StatelessWidget {
  const _RawThumbFallback({
    required this.url,
    required this.size,
    required this.alignment,
  });

  final String url;
  final double? size;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      httpHeaders: kStoryImageHeaders,
      width: size,
      height: size,
      fit: BoxFit.cover,
      alignment: alignment,
      filterQuality: FilterQuality.high,
      placeholder: (_, __) => const ColoredBox(color: kStoryImageBackdrop),
      errorWidget: (_, __, ___) => ColoredBox(
        color: kStoryImageBackdrop,
        child: Icon(Icons.broken_image_outlined, size: (size ?? 48) * 0.3, color: Colors.white24),
      ),
    );
  }
}
