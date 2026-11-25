import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/utils/fade_page_route.dart';
import '../../../../core/utils/image_fallback_helper.dart';
import '../../../../core/utils/responsive_breakpoints.dart';
import '../../../../core/widgets/haber_dokunma_alani.dart';
import '../../data/cop31_rapor_verisi.dart';
import '../../data/models/news_article.dart';
import '../../providers/home_providers.dart';
import 'article_detail_screen.dart';

// ══════════════════════════════════════════════════════════════════════════
//  COP31 Değerlendirme Raporu
// ──────────────────────────────────────────────────────────────────────────
//  Bölüm 25 Kasım'da kalktı; bu sayfa onun yerini beş gün tutuyor ve iki
//  ayın muhasebesini çıkarıyor.
//
//  SAYFANIN TEK KURALI
//  Burada yazan her cümlenin arkasında ya portalda yayımlanmış bir haber var
//  (tıklanıyor) ya da adı görünen bir dış kaynak. Dayanağı olmayan cümle
//  sayfaya girmiyor. Bir değerlendirme sayfası, haberlerin üstüne ikinci bir
//  anlatı katmanı koyar; o katmanda kaynaksız yazılan şeyi okur yine portala
//  mal eder.
//
//  Bunun kod karşılığı [_bul]: dayanak haber yayındaki listede yoksa satır
//  HİÇ ÇİZİLMİYOR. Haber sonradan yayından kalkarsa cümle de kendiliğinden
//  kayboluyor — geriye ölü bağlantı ya da dayanaksız iddia kalmıyor.
//
//  İKİ TÜR İSTATİSTİK AYRI DURUYOR
//  "Zirveden rakamlar" haberlere dayanıyor ve her kart kaynağına gidiyor.
//  "Portalın izleği" ise bizim yayın kaydımızdan hesaplanıyor. İkisi yan
//  yana konsaydı okur 54 haberi zirvenin bir çıktısı sanırdı.
//
//  RENK KİMLİĞİ bölümden devralındı (derin deniz yeşili). Okur aynı şeyin
//  devamını okuduğunu renkten anlıyor; sıfırdan bir kimlik beş günlük bir
//  sayfa için hem gereksiz hem kafa karıştırıcı olurdu.
// ══════════════════════════════════════════════════════════════════════════

const _vurguAcik = Color(0xFF0E5C52);
const _vurguKoyu = Color(0xFF57C9B0);
const _yuzeyAcik = Color(0xFFEDF4F1);
const _yuzeyKoyu = Color(0xFF0F1F1C);

/// ERTELİ PAKETİN GİRİŞİ — ana sayfa şeridi bu dosyayı `deferred as` ile
/// alıyor (bkz. cop31_rapor_seridi.dart). Sayfanın on dört parçası ve
/// `cop31_rapor_verisi.dart` artık İLK YÜKTE DEĞİL: yalnız rapora giren
/// okur indiriyor. 25 Kasım 2026'da ağırlık bekçisi ilk yükü tavanın
/// 8.608 bayt üstünde buldu; bekçinin kendi notu tavanı yükseltmeyi
/// yasaklıyor, yer açmanın yolu bu. Sayfa beş gün yayında ve okurun
/// küçük bir bölümü açıyor — ertelemeye en uygun ekran.
///
/// Şerit ekranın TİPİNİ anamıyor (erteli kütüphanenin tipleri ilk yükte
/// kullanılamaz); bu işlevi çağırıyor.
Widget raporEkrani() => const Cop31RaporEkrani();

class Cop31RaporEkrani extends ConsumerWidget {
  const Cop31RaporEkrani({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final vurgu = isDark ? _vurguKoyu : _vurguAcik;
    final yuzey = isDark ? _yuzeyKoyu : _yuzeyAcik;
    final liste = ref.watch(cop31RaporAkisiProvider).valueOrNull ?? const [];
    final sayilar = ref.watch(cop31RaporSayilariProvider);
    final genis = ResponsiveBreakpoints.isContentWide(context);

    NewsArticle? bul(String id) {
      for (final a in liste) {
        if (a.id == id) return a;
      }
      return null;
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('COP31 Değerlendirme',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w800)),
        backgroundColor: yuzey,
        foregroundColor: vurgu,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: ListView(
              padding: EdgeInsets.fromLTRB(genis ? 24 : 16, 20, genis ? 24 : 16, 48),
              children: [
                _Kunye(vurgu: vurgu, yuzey: yuzey, isDark: isDark),
                const SizedBox(height: 28),

                // ── Hüküm ──────────────────────────────────────────────
                // İki cümle birlikte duruyor. Biri olmadan öteki yanıltıyor;
                // 23 Kasım'da iki haberi de bu yüzden birlikte yayımladık.
                _Baslik('Zirve nasıl bitti', vurgu),
                for (final s in kRaporHukmu)
                  if (bul(s.haberId) != null)
                    _HukumSatiri(satir: s, haber: bul(s.haberId)!, vurgu: vurgu,
                        isDark: isDark),
                const SizedBox(height: 32),

                // ── Kararlar ───────────────────────────────────────────
                _Baslik('Ne kararlaştırıldı, ne kararlaştırılamadı', vurgu),
                const SizedBox(height: 4),
                _Aciklama('Her satır, dayandığı habere gidiyor.', isDark),
                const SizedBox(height: 14),
                if (genis)
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _KararSutunu(
                            baslik: 'Kararlaştırıldı', olumlu: true,
                            satirlar: kAlinanKararlar, bul: bul,
                            vurgu: vurgu, isDark: isDark)),
                        const SizedBox(width: 16),
                        Expanded(child: _KararSutunu(
                            baslik: 'Kararlaştırılamadı', olumlu: false,
                            satirlar: kAlinamayanlar, bul: bul,
                            vurgu: vurgu, isDark: isDark)),
                      ],
                    ),
                  )
                else ...[
                  _KararSutunu(baslik: 'Kararlaştırıldı', olumlu: true,
                      satirlar: kAlinanKararlar, bul: bul, vurgu: vurgu,
                      isDark: isDark),
                  const SizedBox(height: 14),
                  _KararSutunu(baslik: 'Kararlaştırılamadı', olumlu: false,
                      satirlar: kAlinamayanlar, bul: bul, vurgu: vurgu,
                      isDark: isDark),
                ],
                const SizedBox(height: 32),

                // ── Tarımın payı ───────────────────────────────────────
                _Baslik('Tarımın payı', vurgu),
                const SizedBox(height: 4),
                _Aciklama(
                    'Zirveyi üretici gözünden okuyan başlıklar.', isDark),
                const SizedBox(height: 12),
                for (final s in kTarimPayi)
                  if (bul(s.haberId) != null)
                    _MaddeSatiri(satir: s, haber: bul(s.haberId)!,
                        vurgu: vurgu, isDark: isDark),
                const SizedBox(height: 32),

                // ── Zirveden rakamlar ──────────────────────────────────
                _Baslik('Zirveden rakamlar', vurgu),
                const SizedBox(height: 4),
                _Aciklama(
                    'Hepsi portalda yayımlanmış bir habere dayanıyor; '
                    'karta dokununca kaynağına gidiyor.', isDark),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final r in kRaporRakamlari)
                      if (bul(r.haberId) != null)
                        _RakamKarti(rakam: r, haber: bul(r.haberId)!,
                            vurgu: vurgu, yuzey: yuzey, isDark: isDark,
                            genislik: genis ? 224 : double.infinity),
                  ],
                ),
                const SizedBox(height: 32),

                // ── Portalın izleği ────────────────────────────────────
                if (sayilar.isNotEmpty) ...[
                  _Baslik('Portalın izleği', vurgu),
                  const SizedBox(height: 4),
                  _Aciklama(
                      'Bu blok zirvenin değil, bizim yayın kaydımızın '
                      'rakamları.', isDark),
                  const SizedBox(height: 12),
                  _IzlekKutusu(sayilar: sayilar, vurgu: vurgu, yuzey: yuzey,
                      isDark: isDark),
                  const SizedBox(height: 32),
                ],

                // ── Sırada ─────────────────────────────────────────────
                _Baslik('Sırada', vurgu),
                const SizedBox(height: 10),
                for (final d in kRaporSirada)
                  _DisBilgiSatiri(bilgi: d, vurgu: vurgu, isDark: isDark),
                const SizedBox(height: 32),

                // ── Bütün arşiv ────────────────────────────────────────
                _Baslik('COP31 arşivi', vurgu),
                const SizedBox(height: 4),
                _Aciklama('${liste.length} içerik, en yeniden eskiye.', isDark),
                const SizedBox(height: 12),
                for (final a in liste)
                  _ArsivSatiri(haber: a, vurgu: vurgu, isDark: isDark),
                const SizedBox(height: 28),
                _KapanisNotu(isDark: isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Kunye extends StatelessWidget {
  const _Kunye({required this.vurgu, required this.yuzey, required this.isDark});
  final Color vurgu, yuzey;
  final bool isDark;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
        decoration: BoxDecoration(
          color: yuzey,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: vurgu.withValues(alpha: 0.32)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('COP31 · ANTALYA · 9-22 KASIM 2026',
                style: GoogleFonts.inter(
                    fontSize: 11.5, fontWeight: FontWeight.w800,
                    letterSpacing: 1.1, color: vurgu)),
            const SizedBox(height: 8),
            Text('Değerlendirme Raporu',
                style: GoogleFonts.outfit(
                    fontSize: 27, height: 1.15, fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : Colors.black87)),
            const SizedBox(height: 10),
            Text(
              'Zirvede ne kararlaştırıldı, ne kararlaştırılamadı ve tarıma '
              'ne düştü. Portalın iki aylık izleğiyle birlikte.',
              style: GoogleFonts.inter(
                  fontSize: 14.5, height: 1.55,
                  color: isDark ? Colors.grey[300] : Colors.grey[800]),
            ),
          ],
        ),
      );
}

class _Baslik extends StatelessWidget {
  const _Baslik(this.metin, this.vurgu);
  final String metin;
  final Color vurgu;
  @override
  Widget build(BuildContext context) => Text(metin,
      style: GoogleFonts.outfit(
          fontSize: 19, fontWeight: FontWeight.w800, color: vurgu));
}

class _Aciklama extends StatelessWidget {
  const _Aciklama(this.metin, this.isDark);
  final String metin;
  final bool isDark;
  @override
  Widget build(BuildContext context) => Text(metin,
      style: GoogleFonts.inter(
          fontSize: 12.5, height: 1.45,
          color: isDark ? Colors.grey[400] : Colors.grey[700]));
}

/// Haberin küçük görseli.
///
/// Sayfa baştan sona metin: iddia, künye, iddia, künye. Kullanıcının
/// gözlemi — "metin yoğunluğunun verdiği yorgunluk" — doğru; göz satır
/// aralarında tutunacak bir şey bulamıyor. Küçük görsel o çıpayı veriyor
/// ve okuma yükünü artırmıyor.
///
/// `thumb_image_url` zaten liste sorgusunda geliyor, yani ek istek yok.
/// Yoksa tam boy görsele düşüyor; o da yoksa [NewsArticleImage] kendi
/// yedeğini çiziyor ve satır boş bir kutuyla kalmıyor.
class _Kucuk extends StatelessWidget {
  const _Kucuk({required this.haber, this.en = 44, this.boy = 31});
  final NewsArticle haber;
  final double en, boy;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: SizedBox(
          width: en,
          height: boy,
          child: NewsArticleImage(
            imageUrl: (haber.thumbImageUrl?.isNotEmpty ?? false)
                ? haber.thumbImageUrl
                : haber.imageUrl,
            fit: BoxFit.cover,
            // Başlık zaten künye satırında yazıyor; ekran okuyucu aynı
            // metni iki kez söylemesin.
            semanticLabel: '',
          ),
        ),
      );
}

/// Dayanak haberin künyesi — her satırın altında aynı biçimde.
class _Dayanak extends StatelessWidget {
  const _Dayanak({required this.haber, required this.vurgu});
  final NewsArticle haber;
  final Color vurgu;

  @override
  Widget build(BuildContext context) {
    final t = haber.createdAt;
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.subdirectory_arrow_right_rounded, size: 13, color: vurgu),
          const SizedBox(width: 6),
          _Kucuk(haber: haber),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${haber.title}  ·  ${t.day}.${t.month}.${t.year}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                  fontSize: 11.5, height: 1.35, fontWeight: FontWeight.w600,
                  color: vurgu),
            ),
          ),
        ],
      ),
    );
  }
}

class _HukumSatiri extends StatelessWidget {
  const _HukumSatiri({required this.satir, required this.haber,
      required this.vurgu, required this.isDark});
  final RaporSatiri satir;
  final NewsArticle haber;
  final Color vurgu;
  final bool isDark;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 12),
        child: HaberDokunmaAlani(
          etiket: haber.title,
          borderRadius: BorderRadius.circular(10),
          onTap: () => pushScreen(context, ArticleDetailScreen(article: haber)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(satir.metin,
                  style: GoogleFonts.inter(
                      fontSize: 16, height: 1.5, fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87)),
              _Dayanak(haber: haber, vurgu: vurgu),
            ],
          ),
        ),
      );
}

class _KararSutunu extends StatelessWidget {
  const _KararSutunu({required this.baslik, required this.olumlu,
      required this.satirlar, required this.bul, required this.vurgu,
      required this.isDark});
  final String baslik;
  final bool olumlu;
  final List<RaporSatiri> satirlar;
  final NewsArticle? Function(String) bul;
  final Color vurgu;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    // Olumsuz sütun kırmızı DEĞİL: "kararlaştırılamadı" bir hata değil,
    // müzakerenin sonucu. Kırmızı, sayfaya portalın taraf tuttuğu izlenimi
    // verirdi. Ayrım simgeyle ve soluk bir çerçeveyle yapılıyor.
    final cerceve = olumlu ? vurgu : (isDark ? Colors.grey[600]! : Colors.grey[500]!);
    final mevcut = satirlar.where((s) => bul(s.haberId) != null).toList();
    if (mevcut.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cerceve.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(olumlu ? Icons.check_circle_outline_rounded
                          : Icons.remove_circle_outline_rounded,
                  size: 17, color: cerceve),
              const SizedBox(width: 7),
              Text(baslik,
                  style: GoogleFonts.outfit(
                      fontSize: 15, fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : Colors.black87)),
            ],
          ),
          for (final s in mevcut)
            _MaddeSatiri(satir: s, haber: bul(s.haberId)!, vurgu: vurgu,
                isDark: isDark),
        ],
      ),
    );
  }
}

class _MaddeSatiri extends StatelessWidget {
  const _MaddeSatiri({required this.satir, required this.haber,
      required this.vurgu, required this.isDark});
  final RaporSatiri satir;
  final NewsArticle haber;
  final Color vurgu;
  final bool isDark;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 14),
        child: HaberDokunmaAlani(
          etiket: haber.title,
          borderRadius: BorderRadius.circular(8),
          onTap: () => pushScreen(context, ArticleDetailScreen(article: haber)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(satir.metin,
                  style: GoogleFonts.inter(
                      fontSize: 14, height: 1.5,
                      color: isDark ? Colors.grey[200] : Colors.black87)),
              _Dayanak(haber: haber, vurgu: vurgu),
            ],
          ),
        ),
      );
}

class _RakamKarti extends StatelessWidget {
  const _RakamKarti({required this.rakam, required this.haber,
      required this.vurgu, required this.yuzey, required this.isDark,
      required this.genislik});
  final RaporRakami rakam;
  final NewsArticle haber;
  final Color vurgu, yuzey;
  final bool isDark;
  final double genislik;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: genislik,
        child: HaberDokunmaAlani(
          etiket: '${rakam.deger} ${rakam.etiket}. Kaynak: ${haber.title}',
          borderRadius: BorderRadius.circular(12),
          onTap: () => pushScreen(context, ArticleDetailScreen(article: haber)),
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 13, 14, 14),
            decoration: BoxDecoration(
              color: yuzey,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: vurgu.withValues(alpha: 0.26)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(rakam.deger,
                    style: GoogleFonts.outfit(
                        fontSize: 22, fontWeight: FontWeight.w800,
                        color: vurgu)),
                const SizedBox(height: 3),
                Text(rakam.etiket,
                    style: GoogleFonts.inter(
                        fontSize: 12.5, height: 1.4,
                        color: isDark ? Colors.grey[300] : Colors.grey[800])),
                _Dayanak(haber: haber, vurgu: vurgu),
              ],
            ),
          ),
        ),
      );
}

class _IzlekKutusu extends StatelessWidget {
  const _IzlekKutusu({required this.sayilar, required this.vurgu,
      required this.yuzey, required this.isDark});
  final Map<String, Object> sayilar;
  final Color vurgu, yuzey;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final haber = sayilar['haber'] as int;
    final ilk = sayilar['ilk'] as DateTime;
    final son = sayilar['son'] as DateTime;
    final konu = (sayilar['konu'] as Map<String, int>).entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final gun = son.difference(ilk).inDays + 1; // iki uç dahil

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        color: yuzey,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: vurgu.withValues(alpha: 0.26)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$haber içerik · $gun günde',
              style: GoogleFonts.outfit(
                  fontSize: 17, fontWeight: FontWeight.w800, color: vurgu)),
          const SizedBox(height: 6),
          Text(
            '${ilk.day}.${ilk.month}.${ilk.year} – ${son.day}.${son.month}.${son.year}',
            style: GoogleFonts.inter(
                fontSize: 12.5,
                color: isDark ? Colors.grey[400] : Colors.grey[700]),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final k in konu)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: vurgu.withValues(alpha: 0.35)),
                  ),
                  child: Text('${k.key}  ${k.value}',
                      style: GoogleFonts.inter(
                          fontSize: 12, fontWeight: FontWeight.w600,
                          color: isDark ? Colors.grey[200] : Colors.black87)),
                ),
            ],
          ),
        ],
      ),
    );
  }

}

class _DisBilgiSatiri extends StatelessWidget {
  const _DisBilgiSatiri({required this.bilgi, required this.vurgu,
      required this.isDark});
  final RaporDisBilgi bilgi;
  final Color vurgu;
  final bool isDark;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(bilgi.metin,
              style: GoogleFonts.inter(
                  fontSize: 14.5, height: 1.5,
                  color: isDark ? Colors.grey[200] : Colors.black87)),
          const SizedBox(height: 5),
          // Dış kaynağın adı GÖRÜNÜR. Bu satırın portalın kendi haberine
          // değil dışarıya dayandığını okur buradan anlıyor.
          Text('Kaynak: ${bilgi.kaynak}',
              style: GoogleFonts.inter(
                  fontSize: 11.5, fontWeight: FontWeight.w700, color: vurgu)),
        ],
      );
}

class _ArsivSatiri extends StatelessWidget {
  const _ArsivSatiri({required this.haber, required this.vurgu,
      required this.isDark});
  final NewsArticle haber;
  final Color vurgu;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final t = haber.createdAt;
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: HaberDokunmaAlani(
        etiket: haber.title,
        borderRadius: BorderRadius.circular(8),
        onTap: () => pushScreen(context, ArticleDetailScreen(article: haber)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 9),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 42,
                child: Padding(
                  padding: const EdgeInsets.only(top: 11),
                  child: Text('${t.day}.${t.month}',
                      style: GoogleFonts.inter(
                          fontSize: 12, fontWeight: FontWeight.w700,
                          color: vurgu)),
                ),
              ),
              _Kucuk(haber: haber, en: 58, boy: 40),
              const SizedBox(width: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 9),
                  child: Text(haber.title,
                    style: GoogleFonts.inter(
                        fontSize: 13.5, height: 1.45,
                        color: isDark ? Colors.grey[200] : Colors.black87)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KapanisNotu extends StatelessWidget {
  const _KapanisNotu({required this.isDark});
  final bool isDark;
  @override
  Widget build(BuildContext context) => Text(
        'Bu sayfa 30 Kasım 2026\'da anasayfadan kalkacak. Haberler '
        'arşivde kalmaya ve aramada çıkmaya devam ediyor.',
        style: GoogleFonts.inter(
            fontSize: 12, height: 1.5, fontStyle: FontStyle.italic,
            color: isDark ? Colors.grey[500] : Colors.grey[600]),
      );
}
