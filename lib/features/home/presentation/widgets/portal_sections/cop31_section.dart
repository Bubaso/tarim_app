import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tarim_app/core/theme/app_colors.dart';
import 'package:tarim_app/core/utils/hover.dart';

import '../../../../../core/utils/fade_page_route.dart';
import '../../../../../core/utils/image_fallback_helper.dart';
import '../../../../../core/utils/localization_helper.dart';
import '../../../../../core/utils/responsive_breakpoints.dart';
import '../../../../../core/widgets/article_timestamp.dart';
import '../../../../../core/widgets/haber_dokunma_alani.dart';
import '../../../data/models/news_article.dart';
import '../../../providers/home_providers.dart';
import '../../screens/article_detail_screen.dart';
import '../../screens/cop31_liste_ekrani.dart';

/// COP31 iklim zirvesi bölümü — "Türkiye'den Haberler"in altında.
///
/// NEDEN [SectionContainer] KULLANMIYOR
/// 6 Kasım 2026 anasayfa denetimi (A8/Ö8) on beş bölümün aynı kalıpta
/// açıldığını, kalıp tekrarlandıkça hiyerarşi taşımayı bıraktığını ölçmüştü.
/// Bu bölümün süreli ve ayrıksı olması gerekiyor: kendi yüzeyi, kendi
/// çerçevesi ve kendi künyesi var. On altıncı tekrar olmak istemiyor.
///
/// Bölüm boşsa ya da ömrü dolduysa hiç çizilmiyor — 25 Kasım'da anasayfadan
/// kendiliğinden kalkmasının yolu bu, kod değişikliği gerekmiyor.
class Cop31Section extends ConsumerWidget {
  final bool isDark;

  /// Bölümden SONRAKİ boşluk — `DossierStrip`/`KisaKisaSection` ile aynı kural.
  ///
  /// Boşluk bölümün kendi içinde: 25 Kasım'da bölüm çizilmeyi bıraktığında
  /// boşluğu da götürüyor. Anasayfaya ayrı bir `SizedBox` olarak konsaydı
  /// o tarihten sonra sayfada iki boşluk üst üste binerdi.
  final double spacing;

  const Cop31Section({super.key, required this.isDark, this.spacing = 0});

  // Zirve kimliği: portalın yeşil/buğday paletinden kopmayan ama ondan
  // ayrışan derin deniz yeşili. İklim/su gündemi buğday sarısıyla
  // anlatılamıyordu; tarım yeşiliyle anlatılınca da bölüm sayfanın geri
  // kalanına karışıyordu.
  static const _vurguAcik = Color(0xFF0E5C52);
  static const _vurguKoyu = Color(0xFF57C9B0);
  static const _yuzeyAcik = Color(0xFFEDF4F1);
  static const _yuzeyKoyu = Color(0xFF0F1F1C);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ozelBolumAktif(ref.watch(simdiProvider)())) {
      return const SizedBox.shrink();
    }

    final liste = ref.watch(cop31ArticlesProvider);
    if (liste.isEmpty) return const SizedBox.shrink();

    ref.watch(localeProvider); // dil değişiminde yeniden çiz
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < ResponsiveBreakpoints.mobileMax;
    final isTablet = !isMobile && width < ResponsiveBreakpoints.contentWide;

    final vurgu = isDark ? _vurguKoyu : _vurguAcik;
    final yuzey = isDark ? _yuzeyKoyu : _yuzeyAcik;
    final metin = isDark ? AppColors.creamBackground : AppColors.earthText;

    // "Tümü" ekranı manşete çıkanları da göstersin: bölüm listesi onları
    // ayıklıyor (aynı kart sayfada iki kez görünmesin diye) ama ayrı ekranda
    // zirvenin tamamı olmalı.
    final tamListe = ref.watch(ozelBolumAkisiProvider).valueOrNull ?? liste;

    return Padding(
      padding: EdgeInsets.only(
          bottom: spacing, left: isMobile ? 16 : 0, right: isMobile ? 16 : 0),
      child: Container(
        decoration: BoxDecoration(
          color: yuzey,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: vurgu.withValues(alpha: isDark ? 0.35 : 0.22)),
        ),
        padding: EdgeInsets.fromLTRB(
            isMobile ? 16 : 24, isMobile ? 18 : 22, isMobile ? 16 : 24, isMobile ? 18 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Kunye(
              vurgu: vurgu,
              metin: metin,
              isDark: isDark,
              isMobile: isMobile,
              isEn: isEn,
              adet: tamListe.length,
              // Ortak kategori ekranı KULLANILMIYOR: önizlemede o ekranda
              // COP31 ile ilgisi olmayan haberler göründü ve sebebi
              // açıklanamadı (bkz. [Cop31ListeEkrani] başındaki not).
              // Kendi ekranı hiçbir sorgu yapmıyor.
              onTumu: tamListe.isEmpty
                  ? null
                  : () => pushScreen(
                        context, Cop31ListeEkrani(tohum: tamListe)),
            ),
            SizedBox(height: isMobile ? 16 : 20),
            if (isMobile)
              _MobilDuzen(liste: liste, isDark: isDark, vurgu: vurgu, metin: metin)
            else if (isTablet)
              _TabletDuzen(liste: liste, isDark: isDark, vurgu: vurgu, metin: metin)
            else
              _MasaustuDuzen(liste: liste, isDark: isDark, vurgu: vurgu, metin: metin),
          ],
        ),
      ),
    );
  }
}

/// Bölümün künyesi: COP31 kilidi, yer, tarih ve zirvenin canlı durumu.
class _Kunye extends StatelessWidget {
  final Color vurgu;
  final Color metin;
  final bool isDark;
  final bool isMobile;
  final bool isEn;
  final int adet;
  final VoidCallback? onTumu;

  const _Kunye({
    required this.vurgu,
    required this.metin,
    required this.isDark,
    required this.isMobile,
    required this.isEn,
    required this.adet,
    this.onTumu,
  });

  /// Zirvenin o anki hâli. Büyük harfli sabitler bilerek: Türkçede
  /// `toUpperCase()` 'i' → 'I' üretiyor ve "İKLİM" yerine "IKLIM" çıkıyor.
  String _durum() {
    final simdi = DateTime.now();
    if (simdi.isBefore(kZirveBaslangic)) {
      return isEn ? 'STARTING SOON' : 'ZİRVE YAKLAŞIYOR';
    }
    if (simdi.isBefore(kZirveBitis)) {
      final gun = simdi.difference(kZirveBaslangic).inDays + 1;
      return isEn ? 'LIVE · DAY $gun' : 'ZİRVE SÜRÜYOR · $gun. GÜN';
    }
    return isEn ? 'CONCLUDED' : 'ZİRVE TAMAMLANDI';
  }

  bool get _canli {
    final simdi = DateTime.now();
    return !simdi.isBefore(kZirveBaslangic) && simdi.isBefore(kZirveBitis);
  }

  @override
  Widget build(BuildContext context) {
    final rozet = Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: _canli ? vurgu : vurgu.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_canli) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: isDark ? _koyuUzerineNokta : Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            _durum(),
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: _canli
                  ? (isDark ? _koyuUzerineNokta : Colors.white)
                  : vurgu,
            ),
          ),
        ],
      ),
    );

    final baslik = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'COP31',
          style: GoogleFonts.outfit(
            fontSize: isMobile ? 26 : 32,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
            height: 1.0,
            color: vurgu,
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            isEn ? 'CLIMATE SUMMIT · ANTALYA' : 'İKLİM ZİRVESİ · ANTALYA',
            maxLines: 2,
            style: GoogleFonts.inter(
              fontSize: isMobile ? 10 : 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.9,
              height: 1.25,
              color: metin.withValues(alpha: 0.72),
            ),
          ),
        ),
      ],
    );

    final tarih = Text(
      isEn ? '9–20 Nov 2026' : '9–20 Kasım 2026',
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: metin.withValues(alpha: 0.60),
      ),
    );

    final tumu = onTumu == null
        ? null
        : HaberDokunmaAlani(
            etiket: isEn ? 'All COP31 news' : 'Tüm COP31 haberleri',
            onTap: onTumu!,
            // Metin 12 punto; çıplak hâlde dokunma alanı ~16 px oluyordu ve
            // önizlemede üç denemenin üçü de ıskaladı. Kutu en az 44 px —
            // parmak hedefi için kabul edilen alt sınır.
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 44),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isEn ? 'All $adet' : 'Tümü ($adet)',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: vurgu,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(Icons.arrow_forward_rounded, size: 14, color: vurgu),
                  ],
                ),
              ),
            ),
          );

    // 390 px'de rozet + tarih + bağlantı tek satıra SIĞMIYOR: ölçümde tarih
    // ile "Tümü" birbirine giriyor ve ok ekran kenarından taşıyordu. Dar
    // ekranda bağlantı kendi satırına iniyor.
    final altSatir = isMobile
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [rozet, const SizedBox(width: 8), Flexible(child: tarih)]),
              if (tumu != null) ...[
                const SizedBox(height: 10),
                tumu,
              ],
            ],
          )
        : Row(
            children: [
              rozet,
              const SizedBox(width: 8),
              tarih,
              const Spacer(),
              if (tumu != null) tumu,
            ],
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        baslik,
        const SizedBox(height: 10),
        altSatir,
      ],
    );
  }

  // Koyu temada dolu rozetin üstündeki metin/nokta: vurgu rengi açık olduğu
  // için beyaz okunmuyor, koyu yüzey rengi okunuyor.
  static const _koyuUzerineNokta = Color(0xFF0B1A17);
}

/// Masaüstü: solda büyük öne çıkan, sağda numaralı başlık listesi.
class _MasaustuDuzen extends StatelessWidget {
  final List<NewsArticle> liste;
  final bool isDark;
  final Color vurgu;
  final Color metin;

  const _MasaustuDuzen({
    required this.liste,
    required this.isDark,
    required this.vurgu,
    required this.metin,
  });

  @override
  Widget build(BuildContext context) {
    final bas = liste.first;
    final kalan = liste.skip(1).take(5).toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 7,
          child: _BuyukKart(
              article: bas, isDark: isDark, vurgu: vurgu, metin: metin),
        ),
        if (kalan.isNotEmpty) ...[
          const SizedBox(width: 24),
          Container(width: 1, height: 300, color: vurgu.withValues(alpha: 0.16)),
          const SizedBox(width: 24),
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < kalan.length; i++)
                  Padding(
                    padding: EdgeInsets.only(bottom: i == kalan.length - 1 ? 0 : 14),
                    child: _NumaraliSatir(
                      article: kalan[i],
                      sira: i + 2,
                      isDark: isDark,
                      vurgu: vurgu,
                      metin: metin,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Tablet: büyük kart üstte, altında iki sütun numaralı satır.
class _TabletDuzen extends StatelessWidget {
  final List<NewsArticle> liste;
  final bool isDark;
  final Color vurgu;
  final Color metin;

  const _TabletDuzen({
    required this.liste,
    required this.isDark,
    required this.vurgu,
    required this.metin,
  });

  @override
  Widget build(BuildContext context) {
    final bas = liste.first;
    final kalan = liste.skip(1).take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _BuyukKart(article: bas, isDark: isDark, vurgu: vurgu, metin: metin),
        if (kalan.isNotEmpty) ...[
          const SizedBox(height: 20),
          Container(height: 1, color: vurgu.withValues(alpha: 0.16)),
          const SizedBox(height: 18),
          for (var satir = 0; satir < (kalan.length / 2).ceil(); satir++)
            Padding(
              padding: EdgeInsets.only(bottom: satir == (kalan.length / 2).ceil() - 1 ? 0 : 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _NumaraliSatir(
                      article: kalan[satir * 2],
                      sira: satir * 2 + 2,
                      isDark: isDark,
                      vurgu: vurgu,
                      metin: metin,
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: satir * 2 + 1 < kalan.length
                        ? _NumaraliSatir(
                            article: kalan[satir * 2 + 1],
                            sira: satir * 2 + 3,
                            isDark: isDark,
                            vurgu: vurgu,
                            metin: metin,
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }
}

/// Mobil: büyük kart + altında numaralı satırlar. Yatay kaydırma YOK —
/// ölçümde yatay şeritler sayfanın dikey akışını kesiyor ve ikinci karttan
/// sonrası görülmüyor.
class _MobilDuzen extends StatelessWidget {
  final List<NewsArticle> liste;
  final bool isDark;
  final Color vurgu;
  final Color metin;

  const _MobilDuzen({
    required this.liste,
    required this.isDark,
    required this.vurgu,
    required this.metin,
  });

  @override
  Widget build(BuildContext context) {
    final bas = liste.first;
    final kalan = liste.skip(1).take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _BuyukKart(article: bas, isDark: isDark, vurgu: vurgu, metin: metin),
        if (kalan.isNotEmpty) ...[
          const SizedBox(height: 18),
          Container(height: 1, color: vurgu.withValues(alpha: 0.16)),
          const SizedBox(height: 16),
          for (var i = 0; i < kalan.length; i++)
            Padding(
              padding: EdgeInsets.only(bottom: i == kalan.length - 1 ? 0 : 16),
              child: _NumaraliSatir(
                article: kalan[i],
                sira: i + 2,
                isDark: isDark,
                vurgu: vurgu,
                metin: metin,
              ),
            ),
        ],
      ],
    );
  }
}

/// Bölümün öne çıkan haberi: görsel + başlık + spot.
class _BuyukKart extends StatefulWidget {
  final NewsArticle article;
  final bool isDark;
  final Color vurgu;
  final Color metin;

  const _BuyukKart({
    required this.article,
    required this.isDark,
    required this.vurgu,
    required this.metin,
  });

  @override
  State<_BuyukKart> createState() => _BuyukKartState();
}

class _BuyukKartState extends State<_BuyukKart> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final a = widget.article;
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final baslik =
        (isEn && (a.titleEn?.isNotEmpty ?? false)) ? a.titleEn! : a.title;
    final spot = (isEn && (a.spotEn?.isNotEmpty ?? false))
        ? a.spotEn
        : (a.spot?.isNotEmpty ?? false)
            ? a.spot
            : a.summary;
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < ResponsiveBreakpoints.mobileMax;

    return MouseRegion(
      onEnter: (_) {
        if (hoverPointerLikely) setState(() => _hovered = true);
      },
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: HaberDokunmaAlani(
        etiket: a.title,
        onTap: () => pushScreen(context, ArticleDetailScreen(article: a)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: NewsArticleImage(
                  imageUrl: a.imageUrl,
                  fit: BoxFit.cover,
                  semanticLabel: baslik,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              baslik,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.outfit(
                fontSize: isMobile ? 19 : 23,
                fontWeight: FontWeight.w700,
                height: 1.22,
                color: _hovered ? widget.vurgu : widget.metin,
              ),
            ),
            if (spot != null && spot.isNotEmpty) ...[
              const SizedBox(height: 7),
              Text(
                spot,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: isMobile ? 13 : 14,
                  height: 1.45,
                  color: widget.metin.withValues(alpha: 0.72),
                ),
              ),
            ],
            const SizedBox(height: 8),
            ArticleTimestamp(
              published: a.publishedAt ?? a.createdAt,
              color: widget.metin.withValues(alpha: 0.55),
              fontSize: 11,
            ),
          ],
        ),
      ),
    );
  }
}

/// Numaralı başlık satırı: sıra numarası + küçük görsel + başlık.
///
/// Görsel için `thumb_image_url` tercih ediliyor; o sütun 1327 yayındaki
/// haberin 428'inde boş olduğu için `image_url`'e düşüyor. İkisi de yoksa
/// [NewsArticleImage] kendi yedeğini çiziyor, satır boş kutuyla kalmıyor.
class _NumaraliSatir extends StatefulWidget {
  final NewsArticle article;
  final int sira;
  final bool isDark;
  final Color vurgu;
  final Color metin;

  const _NumaraliSatir({
    required this.article,
    required this.sira,
    required this.isDark,
    required this.vurgu,
    required this.metin,
  });

  @override
  State<_NumaraliSatir> createState() => _NumaraliSatirState();
}

class _NumaraliSatirState extends State<_NumaraliSatir> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final a = widget.article;
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final baslik =
        (isEn && (a.titleEn?.isNotEmpty ?? false)) ? a.titleEn! : a.title;

    return MouseRegion(
      onEnter: (_) {
        if (hoverPointerLikely) setState(() => _hovered = true);
      },
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: HaberDokunmaAlani(
        etiket: a.title,
        onTap: () => pushScreen(context, ArticleDetailScreen(article: a)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 20,
              child: Text(
                '${widget.sira}',
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  height: 1.3,
                  color: widget.vurgu.withValues(alpha: 0.75),
                ),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                width: 68,
                height: 48,
                child: NewsArticleImage(
                  imageUrl: (a.thumbImageUrl?.isNotEmpty ?? false)
                      ? a.thumbImageUrl
                      : a.imageUrl,
                  fit: BoxFit.cover,
                  semanticLabel: baslik,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    baslik,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                      color: _hovered ? widget.vurgu : widget.metin,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ArticleTimestamp(
                    published: a.publishedAt ?? a.createdAt,
                    color: widget.metin.withValues(alpha: 0.52),
                    fontSize: 10,
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
