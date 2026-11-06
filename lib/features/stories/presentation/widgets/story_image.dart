// ignore_for_file: deprecated_member_use
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:tarim_app/core/utils/image_fallback_helper.dart';

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
//  Bu dosya, hikaye görsellerini Supabase'in `/render/image/public/`
//  dönüştürme uç noktasından, hedef pikselin tam ölçüsünde ve WebP olarak
//  ister. Ölçekleme sunucuda (Lanczos) yapıldığı için sonuç belirgin biçimde
//  daha net, dosya da daha küçüktür.
//
//  TEK İSTİSNA tam ekran zemin. Dönüştürme uç noktası hiçbir koşulda BÜYÜTME
//  yapmıyor: 1200×630'luk paylaşım kartından `width=1170` istemek yine
//  1200×630 döndürüyordu, yani dikey ekranı kaplayan şey aslında 540 px'lik
//  bir şeridin 4,7 katına şişirilmiş hâliydi. Çözüm sunucuda değil hatta:
//  `image_storage.py` artık aynı kaynaktan 1080×2340'lık dikey bir türev
//  üretiyor ve zemin onu HAM hâliyle çekiyor (bkz.
//  [storyImageIsPortraitDerivative] — hazır ölçüdeki dosyayı dönüştürmekten
//  geçirmek onu kırpıyor).
// ══════════════════════════════════════════════════════════════════════════════

/// WebP/AVIF pazarlığı için gereken başlıklar. Supabase dönüştürme uç noktası
/// çıktı formatını `Accept` başlığına göre seçer.
const Map<String, String> kStoryImageHeaders = {
  'Accept': 'image/avif,image/webp,image/apng,image/*,*/*;q=0.8',
};

/// Yükleme/hata sırasında ekranı dolduran nötr zemin (siyah üzerine hafif yeşil).
const Color kStoryImageBackdrop = Color(0xFF12160F);

// ─── Ağ isteği gerektirmeyen önizleme ──────────────────────────────────────
//
// 6 Kasım 2026 denetimi (T1): görsel gelene kadar bulanık bir önizleme
// gösteren mekanizma yazılmıştı ama devreye girmesi `donusturmeAcik`
// bayrağına bağlıydı; o bayrak kapalı olduğu için önizleme TAM DA gerektiği
// durumda hiç çizilmiyordu. Slaytın ilk 0,7–3,4 saniyesi düz koyu bir
// dikdörtgendi.
//
// Yeni yol hiçbir şeye bağlı değil: hat 24 piksellik bir kopyayı satıra
// base64 olarak yazıyor (`articles.image_lqip`, ~550 bayt) ve bu kopya
// haberle BİRLİKTE geliyor. Beklenecek istek yok, ilk karede çizilebiliyor.

/// Çözülmüş `data:` URI'lerinin önbelleği.
///
/// Aynı önizleme her yeniden kuruluşta yeniden çözülüyordu; base64 çözmek
/// ucuz ama kare başına yapılınca ucuz değil. Anahtar dizenin kendisi:
/// kopyalar zaten aynı nesneyi paylaşıyor.
final Map<String, MemoryImage?> _onizlemeOnbellek = <String, MemoryImage?>{};

/// `data:image/...;base64,...` dizesini çizilebilir bir görüntüye çevirir.
/// Biçim beklenenden farklıysa `null` döner ve çağıran düz zemine düşer.
MemoryImage? onizlemeGoruntusu(String? dataUri) {
  final s = dataUri?.trim() ?? '';
  if (s.isEmpty || !s.startsWith('data:image/')) return null;
  if (_onizlemeOnbellek.containsKey(s)) return _onizlemeOnbellek[s];

  MemoryImage? sonuc;
  final virgul = s.indexOf(',');
  if (virgul > 0) {
    try {
      final baytlar = base64Decode(s.substring(virgul + 1));
      // BOŞ bayt dizisi de başarısızlık sayılıyor: `base64Decode('')`
      // fırlatmıyor, sıfır uzunlukta bir dizi veriyor ve ondan kurulan
      // MemoryImage çizim anında çöküyor. Hata burada, sessizce yakalanmalı.
      sonuc = baytlar.isEmpty ? null : MemoryImage(baytlar);
    } catch (_) {
      sonuc = null; // bozuk dize yüzünden ekran kaybedilmez
    }
  }
  // Başarısızlık da önbelleğe yazılıyor: bozuk bir dizeyi her karede
  // yeniden çözmeye çalışmanın anlamı yok.
  _onizlemeOnbellek[s] = sonuc;
  return sonuc;
}

/// Önizlemeyi bulanıklaştırıp kutuyu dolduran katman.
class StoryOnizleme extends StatelessWidget {
  const StoryOnizleme({super.key, required this.onizleme});

  final String onizleme;

  @override
  Widget build(BuildContext context) {
    final gorsel = onizlemeGoruntusu(onizleme);
    if (gorsel == null) return const ColoredBox(color: kStoryImageBackdrop);
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: kStoryImageBackdrop),
        ImageFiltered(
          imageFilter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Image(image: gorsel, fit: BoxFit.cover),
        ),
      ],
    );
  }
}

/// URL'in Supabase Storage'ın dönüştürülebilir public uç noktasına ait olup
/// olmadığı. Harici CDN adreslerine dokunmuyoruz.
bool storyImageIsTransformable(String rawUrl) =>
    rawUrl.contains('/object/public/') ||
    rawUrl.contains('/render/image/public/');

/// Hattın ürettiği dikey hikaye türevinin adında bu damga geçer (bkz.
/// `image_storage.py`, `STORY_W`×`STORY_H`).
///
/// Uzantı ve sürüm eki bilerek dışarıda: dosya adı `..._1080x2340_v2.jpg`
/// biçiminde ve üretim yolu her değiştiğinde sürüm artıyor (önbellek düşsün
/// diye). Burada sürüme bağlanmak, hattın her güncellemesinde uygulamanın da
/// değişmesini gerektirirdi.
const String _kDikeyTurevEki = '_1080x2340';

/// Dosya zaten hikaye ekranının ölçüsünde mi?
///
/// Önemli, çünkü bu dosyayı dönüştürme uç noktasından geçirmek onu BOZUYOR:
/// `width` verilip `height` verilmediğinde uç nokta oranı korumuyor, ortadan
/// KIRPIYOR (ölçüldü: kırpılmış çıktıyla piksel farkı 0,94; oranı korunmuş
/// çıktıyla 43,93 — yani gelen şey kırpılmış olan). 1080 px'lik türevden
/// `width=1170` istemek de bir işe yaramıyor: uç nokta asla büyütmüyor.
///
/// Hazır ölçüdeki dosya için doğru davranış, hiç dokunmadan ham hâlini
/// vermektir.
bool storyImageIsPortraitDerivative(String rawUrl) =>
    rawUrl.contains(_kDikeyTurevEki);

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
  // Dönüştürme uç noktası Free planda 403 `FeatureNotEnabled` dönüyor; bayrak
  // kapalıyken ham dosya veriliyor (bkz. [NewsArticleImage.donusturmeAcik]).
  // Veritabanındaki adreslerin hepsi `/object/public/` — denetlendi — yani
  // ham hâli vermek doğru dosyayı veriyor.
  if (!NewsArticleImage.donusturmeAcik) return url;

  final String base =
      url.replaceFirst('/object/public/', '/render/image/public/');
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

/// Paylaşım kartının oranı (`image_storage.py` → `SOCIAL_W/SOCIAL_H`).
const double _kYatayOran = 1200 / 630; // 1,90
/// Hikaye türevinin oranı (`image_storage.py` → `STORY_W/STORY_H`).
const double _kDikeyOran = 1080 / 2340; // 0,46

/// Tam ekran zemin için indirilecek nihai adres.
///
/// İki kaynak var ve HANGİSİNİN kullanılacağı görüntü alanının biçimine bağlı:
///
///   telefon (0,46)   → dikey türev; yatay kartla doldurmak 4 kat büyütme
///                      demekti, sorunun kendisi buydu.
///   masaüstü (1,78)  → YATAY kart. Dikey türevi geniş bir pencerede `cover`
///                      ile yaymak felaket: türev zaten kaynağın orta
///                      şeridinden kırpılmış, üstüne bir de yüksekliğinin
///                      %75'i kesiliyor ve kalan parça 1,8 kat büyütülüyor.
///                      Ekranda "resme 10 kat yakınlaşılmış" gibi duruyor.
///
/// Karar, iki oranın hangisinin görüntü alanına daha yakın olduğuna bakılarak
/// veriliyor. Oranlar çarpımsal büyüklükler olduğu için karşılaştırma logaritma
/// üzerinden yapılıyor; aksi hâlde 0,46 ile 1,90 arasındaki eşik yanlış yere,
/// aritmetik ortaya (1,18) düşer. Doğru eşik geometrik orta: √(0,46 × 1,90) =
/// 0,94. Yani görüntü alanı boyundan dar olduğu sürece dikey türev, kareye
/// yaklaştığı andan itibaren yatay kart kazanıyor. Tabletin dikey (0,75) ve
/// yatay (1,33) duruşu bu eşiğin iki ayrı yanına düşüyor.
String storyBackgroundUrl(
  BuildContext context, {
  required String imageUrl,
  required String portraitUrl,
}) {
  final Size size = MediaQuery.of(context).size;
  final bool olculebilir = size.width > 0 && size.height > 0;
  final double gorusOrani =
      olculebilir ? size.width / size.height : _kDikeyOran;

  final bool dikeyDahaYakin = portraitUrl.trim().isNotEmpty &&
      (math.log(gorusOrani / _kDikeyOran)).abs() <
          (math.log(gorusOrani / _kYatayOran)).abs();

  if (dikeyDahaYakin) return portraitUrl.trim();
  return storyImageUrl(imageUrl,
      width: storyBackgroundTargetWidth(context), quality: 88);
}

/// Tam ekran arka planın [ImageProvider]'ı — komşu hikayeleri `precacheImage`
/// ile önden yüklemek için ekranla birebir aynı URL'i üretir.
ImageProvider storyBackgroundProvider(
  BuildContext context, {
  required String imageUrl,
  required String portraitUrl,
}) {
  return CachedNetworkImageProvider(
    storyBackgroundUrl(context, imageUrl: imageUrl, portraitUrl: portraitUrl),
    headers: kStoryImageHeaders,
  );
}

// ── Tam ekran arka plan görseli ───────────────────────────────────────────────

class StoryBackgroundImage extends StatelessWidget {
  const StoryBackgroundImage({
    super.key,
    required this.imageUrl,
    required this.portraitUrl,
    this.onizleme = '',
  });

  /// 24 px önizlemenin `data:` URI'si; boşsa düz zemin.
  final String onizleme;

  /// Yatay paylaşım kartı — geniş ekranların kaynağı, aynı zamanda dikey
  /// türev üretilememiş haberlerin yedeği.
  final String imageUrl;

  /// Dikey türev; boş olabilir.
  final String portraitUrl;

  @override
  Widget build(BuildContext context) {
    final String hiRes = storyBackgroundUrl(
      context,
      imageUrl: imageUrl,
      portraitUrl: portraitUrl,
    );
    // Bulanık önizleme her zaman yatay karttan: küçücük ve tek işi rengi
    // vermek, iki ayrı dosyayı önbelleğe almanın anlamı yok.
    final String url = imageUrl;
    // Yer tutucu artık HİÇBİR İSTEĞE bağlı değil: önizleme satırla birlikte
    // geldi, ilk karede çizilebiliyor. Eskiden burada 48 px'lik bir türev
    // isteniyordu ve o istek dönüştürme kapalıyken tam boyutlu dosyaya
    // çözülüyordu — yani "önizleme" diye asıl görselin kendisi indiriliyordu
    // (T1). Önizleme boşsa davranış eskisi gibi: düz koyu zemin.
    return CachedNetworkImage(
      imageUrl: hiRes,
      httpHeaders: kStoryImageHeaders,
      fit: BoxFit.cover,
      // Kübik örnekleme: büyütmede de küçültmede de en temiz sonuç.
      filterQuality: FilterQuality.high,
      fadeInDuration: const Duration(milliseconds: 220),
      placeholder: (context, _) => StoryOnizleme(onizleme: onizleme),
      // Dönüştürme uç noktası bir sebeple cevap veremezse ham dosyaya düş.
      errorWidget: (context, _, __) =>
          _RawImageFallback(url: url, onizleme: onizleme),
    );
  }
}

/// Dönüştürme uç noktası hata verirse ham dosyayı dener; o da olmazsa nötr zemin.
class _RawImageFallback extends StatelessWidget {
  const _RawImageFallback({required this.url, this.onizleme = ''});

  final String url;
  final String onizleme;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      httpHeaders: kStoryImageHeaders,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.high,
      fadeInDuration: const Duration(milliseconds: 200),
      placeholder: (_, __) => StoryOnizleme(onizleme: onizleme),
      errorWidget: (_, __, ___) => const ColoredBox(
        color: kStoryImageBackdrop,
        child: Center(
          child: Icon(Icons.broken_image_outlined,
              size: 48, color: Colors.white24),
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
    this.onizleme = '',
  });

  /// 24 px önizlemenin `data:` URI'si; boşsa düz zemin.
  final String onizleme;

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
    final String thumb = storyImageUrl(url,
        width: target, height: target, quality: 82, crop: true);

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
      placeholder: (_, __) => StoryOnizleme(onizleme: onizleme),
      errorWidget: (_, __, ___) => _RawThumbFallback(
          url: url,
          size: fill ? null : size,
          alignment: alignment,
          onizleme: onizleme),
    );
  }
}

class _RawThumbFallback extends StatelessWidget {
  const _RawThumbFallback({
    required this.url,
    required this.size,
    required this.alignment,
    this.onizleme = '',
  });

  final String url;
  final double? size;
  final Alignment alignment;
  final String onizleme;

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
      placeholder: (_, __) => StoryOnizleme(onizleme: onizleme),
      errorWidget: (_, __, ___) => ColoredBox(
        color: kStoryImageBackdrop,
        child: Icon(Icons.broken_image_outlined,
            size: (size ?? 48) * 0.3, color: Colors.white24),
      ),
    );
  }
}
