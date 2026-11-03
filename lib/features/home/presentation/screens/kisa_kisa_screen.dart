import 'package:flutter/material.dart';
import 'package:tarim_app/core/theme/app_dark_mode.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/fade_page_route.dart';
import '../../data/models/news_article.dart';
import '../../providers/home_providers.dart';
import '../../../../core/utils/image_fallback_helper.dart';
import '../../../../core/utils/turkce_metin.dart';
import '../widgets/kisa_kisa_section.dart';
import 'article_detail_screen.dart';

/// 'Kısa Kısa' — kısa haberlerin günlük bülteni.
///
/// Neden ayrı bir sayfa var: kısa haberlerin her biri tek başına ince bir
/// sayfa (iki paragraf, görselsiz). Arama motoru için ince sayfa yığını sitenin
/// tamamının değerlendirmesini aşağı çekiyor. İki seçenek vardı — bu haberleri
/// dizinden çıkarmak (`noindex`) ya da tek bir toplu sayfada birleştirmek.
/// İkincisi seçildi: haber okuyucu için de değerli, sadece tek başına bir
/// sayfayı hak edecek kadar değil. Günlük bülten bunu düzeltiyor: haber
/// erişilebilir kalıyor, dizinde ise ince sayfalar yerine dolu bir sayfa var.
class KisaKisaScreen extends ConsumerWidget {
  const KisaKisaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = appIsDark;
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final articles = ref.watch(briefArticlesProvider);
    final durum = ref.watch(latestArticlesProvider);

    final accent = AppColors.accentFor(isDark: isDark);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkGreen : AppColors.creamBackground,
      appBar: AppBar(
        backgroundColor:
            isDark ? const Color(0xFF080B0E) : const Color(0xFFF3F2ED),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 1.0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: isDark ? Colors.white : Colors.black87,
          ),
          onPressed: () => popScreen(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bolt_rounded, size: 20, color: accent),
            const SizedBox(width: 8),
            Text(
              isEn ? 'IN BRIEF' : 'KISA KISA',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: isDark ? AppColors.creamBackground : AppColors.earthText,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
      body: durum.isLoading && articles.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _Icerik(articles: articles, isDark: isDark, isEn: isEn),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  "GÜNÜN TEZGÂHI" — kısa haber sayfasının düzeni
// ───────────────────────────────────────────────────────────────────────────
//  Eski hâli 400 haberi tek tip satır olarak alt alta diziyordu. Monotonluk
//  bir tasarım tercihi değil, KULLANILMAYAN VARLIKTI: ölçüm (3 Kasım 2026)
//  400 haberin 400'ünde görsel, 400'ünde etiket ve dört dengeli konu
//  (Bitkisel Üretim 132 · Ekonomi 105 · Hayvancılık 76 · Genel 76) olduğunu
//  gösterdi. Sayfa hiçbirini göstermiyordu.
//
//  Düzen GÜN başına üç vuruşluk bir ritim tekrarlıyor:
//
//      AÇILIŞ    geniş kart, 16:9 görsel        → günün nefesi
//      İKİLİ     iki kompakt kart, kare görsel  → tarama hızı
//      TELGRAF   üç görselsiz satır, saat rayı  → yoğunluk
//
//  Ritim bilerek DÜZENSİZ görünüyor: her blok aynı olsaydı ızgara da duvar
//  olurdu, yalnızca kartlardan yapılmış bir duvar. Göz üç farklı ağırlık
//  arasında geziniyor ve gün içinde nerede olduğunu biliyor.
//
//  Gün başlığı YAPIŞKAN ve her günün kendi veri parmak izini taşıyor: o günün
//  konu karışımı ince bir yığın çubuk olarak çiziliyor. 34 gün böylece
//  birbirinden ayırt edilebiliyor — ayrımı süs değil, günün kendi içeriği
//  yapıyor.
// ═══════════════════════════════════════════════════════════════════════════

// Konu rengi TEK KAYNAKTAN: `kisaKonuRengi` (kisa_kisa_section.dart).
// İki yüzeyin aynı dili konuşması şart; eşleme kopyalansaydı biri
// değiştiğinde öteki sessizce ayrışırdı.
Color _konuRengi(String? konu, bool isDark) => kisaKonuRengi(konu, isDark);

/// Ritim bloğu. Gün içindeki haberler bu türlere bölünüyor.
enum _Vurus { acilis, ikili, telgraf }

/// Okuma oluğu. İçerik 1200 px'te kapanıyor; fazlası kenar boşluğu oluyor.
///
/// Sayfanın ESKİ hâlinde sınır YOKTU: 1920 px'lik ekranda telgraf satırı
/// baştan başa uzuyor ve göz satır sonundan satır başına dönerken yerini
/// kaybediyordu. Uygulamanın geri kalanı zaten 1200 kullanıyor
/// (`home_screen.dart`, kategori sayfası).
///
/// Dolgu TEK YERDEN geliyor: yapışkan başlıklar ile bloklar aynı hizada
/// durmak zorunda, ayrı ayrı hesaplansaydı kaydırmada kayarlardı.
const double _olukGenisligi = 1200;

double _yatayPad(BuildContext context) {
  final w = MediaQuery.of(context).size.width;
  final fazla = (w - _olukGenisligi) / 2;
  return fazla > 16 ? fazla : 16;
}

/// Kullanılabilir içerik genişliği — kart düzeni kararları buna bakıyor,
/// EKRAN genişliğine değil.
double _icerikGenisligi(BuildContext context) {
  final w = MediaQuery.of(context).size.width;
  return (w - 2 * _yatayPad(context)).clamp(0, _olukGenisligi).toDouble();
}

class _Blok {
  const _Blok(this.tur, this.haberler);
  final _Vurus tur;
  final List<NewsArticle> haberler;
}

/// Bir günün haberlerini üç vuruşluk ritme bölüyor.
///
/// Açılış yalnızca günün BAŞINDA bir kez: her beş haberde bir geniş kart
/// koymak sayfayı yine tek tipleştirirdi, bu sefer büyük kartlardan.
List<_Blok> _ritim(List<NewsArticle> gun) {
  final bloklar = <_Blok>[];
  var i = 0;
  if (gun.isNotEmpty) {
    bloklar.add(_Blok(_Vurus.acilis, [gun.first]));
    i = 1;
  }
  var sira = 0;
  while (i < gun.length) {
    // 2 kart · 3 telgraf · 2 kart · 3 telgraf …
    final telgrafMi = sira.isOdd;
    final adet = telgrafMi ? 3 : 2;
    final dilim = gun.sublist(i, (i + adet).clamp(0, gun.length));
    bloklar.add(_Blok(telgrafMi ? _Vurus.telgraf : _Vurus.ikili, dilim));
    i += dilim.length;
    sira++;
  }
  return bloklar;
}

class _Icerik extends ConsumerStatefulWidget {
  final List<NewsArticle> articles;
  final bool isDark;
  final bool isEn;

  const _Icerik({
    required this.articles,
    required this.isDark,
    required this.isEn,
  });

  @override
  ConsumerState<_Icerik> createState() => _IcerikState();
}

class _IcerikState extends ConsumerState<_Icerik> {
  /// Seçili konu; null = tümü.
  String? _konu;

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final isEn = widget.isEn;
    if (widget.articles.isEmpty) {
      return _BosDurum(isDark: isDark, isEn: isEn);
    }

    final sayim = <String, int>{};
    for (final a in widget.articles) {
      final k = a.topic ?? 'Genel';
      sayim[k] = (sayim[k] ?? 0) + 1;
    }

    final suzulmus = _konu == null
        ? widget.articles
        : widget.articles.where((a) => (a.topic ?? 'Genel') == _konu).toList();
    final gunler = _gunlereBol(suzulmus);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(latestArticlesProvider),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _Basluk(
              isDark: isDark,
              isEn: isEn,
              adet: widget.articles.length,
              gunSayisi: _gunlereBol(widget.articles).length,
            ),
          ),
          // Süzgeç YAPIŞKAN: 34 günü kaydırırken konuyu değiştirmek için
          // başa dönmek gerekmiyor.
          SliverPersistentHeader(
            pinned: true,
            delegate: _SuzgecBasligi(
              isDark: isDark,
              isEn: isEn,
              sayim: sayim,
              secili: _konu,
              toplam: widget.articles.length,
              sec: (k) => setState(() => _konu = k),
            ),
          ),
          for (final gun in gunler)
            SliverMainAxisGroup(
              slivers: [
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _GunBasligi(
                    gun: gun.tarih,
                    haberler: gun.haberler,
                    isDark: isDark,
                    isEn: isEn,
                  ),
                ),
                // TEMBEL: eski sürüm her günün tamamını tek `SliverToBoxAdapter`
                // içinde kuruyordu, yani 34 günün 400 satırı ilk karede
                // yerleşiyordu — ana sayfada bu hafta düzeltilen E7'nin aynısı.
                SliverList.builder(
                  itemCount: _ritim(gun.haberler).length,
                  itemBuilder: (context, i) {
                    final bloklar = _ritim(gun.haberler);
                    return _Belir(
                      sira: i,
                      child: _BlokCiz(
                        blok: bloklar[i],
                        isDark: isDark,
                        isEn: isEn,
                      ),
                    );
                  },
                ),
              ],
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 64)),
        ],
      ),
    );
  }
}

// ─── Süzgeç şeridi ──────────────────────────────────────────────────────────

class _SuzgecBasligi extends SliverPersistentHeaderDelegate {
  _SuzgecBasligi({
    required this.isDark,
    required this.isEn,
    required this.sayim,
    required this.secili,
    required this.toplam,
    required this.sec,
  });

  final bool isDark;
  final bool isEn;
  final Map<String, int> sayim;
  final String? secili;
  final int toplam;
  final void Function(String?) sec;

  static const double _yukseklik = 54;

  @override
  double get minExtent => _yukseklik;
  @override
  double get maxExtent => _yukseklik;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final zemin = isDark ? AppColors.darkGreen : AppColors.creamBackground;
    final sirali = sayim.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      height: _yukseklik,
      color: zemin,
      alignment: Alignment.centerLeft,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: _yatayPad(context)),
        children: [
          _Pil(
            etiket: isEn ? 'All' : 'Tümü',
            adet: toplam,
            secili: secili == null,
            renk: isDark ? AppColors.wheat : AppColors.earthText,
            isDark: isDark,
            onTap: () => sec(null),
          ),
          for (final e in sirali)
            _Pil(
              etiket: e.key,
              adet: e.value,
              secili: secili == e.key,
              renk: _konuRengi(e.key, isDark),
              isDark: isDark,
              onTap: () => sec(secili == e.key ? null : e.key),
            ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _SuzgecBasligi eski) =>
      eski.secili != secili ||
      eski.isDark != isDark ||
      eski.toplam != toplam;
}

class _Pil extends StatelessWidget {
  const _Pil({
    required this.etiket,
    required this.adet,
    required this.secili,
    required this.renk,
    required this.isDark,
    required this.onTap,
  });

  final String etiket;
  final int adet;
  final bool secili;
  final Color renk;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Seçili pil DOLU, seçilmeyen çerçeveli. Ayrımı yalnızca renge
    // bırakmamak için dolgu/çerçeve farkı da var (§3.2).
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Center(
        child: Material(
          color: secili ? renk : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(999),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: secili ? renk : renk.withValues(alpha: 0.45),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    etiket,
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: secili
                          ? (ThemeData.estimateBrightnessForColor(renk) ==
                                  Brightness.dark
                              ? Colors.white
                              : const Color(0xFF14110D))
                          : (isDark ? Colors.white70 : AppColors.earthText),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$adet',
                    style: GoogleFonts.robotoMono(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: secili
                          ? (ThemeData.estimateBrightnessForColor(renk) ==
                                  Brightness.dark
                              ? Colors.white70
                              : const Color(0xFF14110D))
                          : (isDark ? Colors.white38 : Colors.black45),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Gün başlığı — büyük rakam + günün konu karışımı ───────────────────────

class _GunBasligi extends SliverPersistentHeaderDelegate {
  _GunBasligi({
    required this.gun,
    required this.haberler,
    required this.isDark,
    required this.isEn,
  });

  final DateTime gun;
  final List<NewsArticle> haberler;
  final bool isDark;
  final bool isEn;

  static const double _yukseklik = 74;

  @override
  double get minExtent => _yukseklik;
  @override
  double get maxExtent => _yukseklik;

  String _etiket() {
    final simdi = DateTime.now();
    final bugun = DateTime(simdi.year, simdi.month, simdi.day);
    final fark = bugun.difference(gun).inDays;
    if (fark == 0) return isEn ? 'Today' : 'Bugün';
    if (fark == 1) return isEn ? 'Yesterday' : 'Dün';
    final locale = isEn ? 'en_US' : 'tr_TR';
    return DateFormat(gun.year == simdi.year ? 'MMMM EEEE' : 'MMMM y', locale)
        .format(gun);
  }

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final zemin = isDark ? AppColors.darkGreen : AppColors.creamBackground;
    final murekkep = isDark ? AppColors.creamBackground : AppColors.earthText;
    final sessiz = isDark ? Colors.white54 : Colors.black54;

    // Günün konu karışımı. Her gün farklı bir desen üretiyor, böylece 34 gün
    // birbirinden AYIRT EDİLEBİLİYOR — ayrımı süs değil, günün kendi içeriği
    // yapıyor.
    final sayim = <String, int>{};
    for (final a in haberler) {
      final k = a.topic ?? 'Genel';
      sayim[k] = (sayim[k] ?? 0) + 1;
    }
    final sirali = sayim.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      color: zemin,
      padding: EdgeInsets.fromLTRB(_yatayPad(context), 14, _yatayPad(context), 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Gün sayısı büyük ve mono: 34 günlük listede göz tarihi
          // rakamdan yakalıyor, kelimeden değil.
          Text(
            DateFormat('dd').format(gun),
            style: GoogleFonts.outfit(
              fontSize: 34,
              height: 1,
              fontWeight: FontWeight.w800,
              color: murekkep,
              letterSpacing: -1.5,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  // `buyukHarf` ŞART: ham `toUpperCase()` "Cumartesi"yi
                  // "CUMARTESI", "Nisan"ı "NISAN" yapıyor (§39.5). Eski
                  // sürümde tam bu hata vardı.
                  buyukHarf(_etiket(), isEn),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.3,
                    color: murekkep,
                  ),
                ),
                const SizedBox(height: 6),
                // Yığın çubuk — günün konu bileşimi.
                SizedBox(
                  height: 4,
                  child: Row(
                    children: [
                      for (final e in sirali)
                        Expanded(
                          flex: e.value,
                          child: Container(
                            margin: const EdgeInsets.only(right: 2),
                            decoration: BoxDecoration(
                              color: _konuRengi(e.key, isDark),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            isEn ? '${haberler.length} items' : '${haberler.length} haber',
            style: GoogleFonts.robotoMono(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: sessiz,
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _GunBasligi eski) =>
      eski.gun != gun ||
      eski.haberler.length != haberler.length ||
      eski.isDark != isDark;
}

// ─── Vuruşlar ───────────────────────────────────────────────────────────────

class _BlokCiz extends StatelessWidget {
  const _BlokCiz({
    required this.blok,
    required this.isDark,
    required this.isEn,
  });

  final _Blok blok;
  final bool isDark;
  final bool isEn;

  @override
  Widget build(BuildContext context) {
    final yan = _yatayPad(context);
    final genis = _icerikGenisligi(context) >= 760;
    final pad = EdgeInsets.fromLTRB(
        yan, 0, yan, blok.tur == _Vurus.telgraf ? 14 : 12);

    switch (blok.tur) {
      case _Vurus.acilis:
        return Padding(
          padding: pad,
          child: _AcilisKarti(
              article: blok.haberler.first, isDark: isDark, isEn: isEn),
        );

      case _Vurus.ikili:
        // Dar ekranda yan yana iki kart okunmuyor: kare görsel + başlık
        // 180 px'e sıkışıyor. Telefonda alt alta.
        if (!genis || blok.haberler.length == 1) {
          return Padding(
            padding: pad,
            child: Column(
              children: [
                for (final a in blok.haberler)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _KompaktKart(article: a, isDark: isDark, isEn: isEn),
                  ),
              ],
            ),
          );
        }
        return Padding(
          padding: pad,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: _KompaktKart(
                      article: blok.haberler[0], isDark: isDark, isEn: isEn)),
              const SizedBox(width: 12),
              Expanded(
                  child: _KompaktKart(
                      article: blok.haberler[1], isDark: isDark, isEn: isEn)),
            ],
          ),
        );

      case _Vurus.telgraf:
        return Padding(
          padding: pad,
          child: _TelgrafSerit(
              haberler: blok.haberler, isDark: isDark, isEn: isEn),
        );
    }
  }
}

/// Günün açılışı — tek geniş kart, 16:9 görsel.
class _AcilisKarti extends StatelessWidget {
  const _AcilisKarti({
    required this.article,
    required this.isDark,
    required this.isEn,
  });

  final NewsArticle article;
  final bool isDark;
  final bool isEn;

  @override
  Widget build(BuildContext context) {
    final konu = article.topic ?? 'Genel';
    final renk = _konuRengi(konu, isDark);
    final murekkep = isDark ? AppColors.creamBackground : AppColors.earthText;
    final baslik = (isEn && (article.titleEn ?? '').isNotEmpty)
        ? article.titleEn!
        : article.title;

    // MASAÜSTÜ ile MOBİL ayrı düzen.
    //
    // 1200 px'lik olukta tam genişlik 16:9 görsel 675 piksel yüksekliğinde
    // olurdu — ekranın tamamı tek habere giderdi. Masaüstünde kart YATAY:
    // görsel solda %42, metin sağda. Telefonda dikey, çünkü yan yana 180
    // piksellik bir görsel ve 170 piksellik bir başlık ikisini de okunmaz
    // yapıyor.
    final genis = _icerikGenisligi(context) >= 760;

    final gorsel = Stack(
      fit: StackFit.expand,
      children: [
        NewsArticleImage(
            imageUrl: article.imageUrl,
            fit: BoxFit.cover,
            semanticLabel: baslik),
        // Konu etiketi görselin ÜSTÜNDE: kart görselle açılıyor, etiketi
        // altına koymak başlığı aşağı itiyordu.
        Positioned(
          left: 0,
          top: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: renk,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(4),
                bottomRight: Radius.circular(4),
              ),
            ),
            child: Text(
              buyukHarf(konu, isEn),
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: ThemeData.estimateBrightnessForColor(renk) ==
                        Brightness.dark
                    ? Colors.white
                    : const Color(0xFF14110D),
              ),
            ),
          ),
        ),
      ],
    );

    final metin = Padding(
      padding: EdgeInsets.fromLTRB(genis ? 20 : 14, genis ? 18 : 12, genis ? 22 : 14, genis ? 18 : 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            genis ? MainAxisAlignment.center : MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            baslik,
            maxLines: genis ? 4 : 3,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.outfit(
              fontSize: genis ? 24 : 19,
              height: 1.24,
              fontWeight: FontWeight.w700,
              color: murekkep,
              letterSpacing: -0.3,
            ),
          ),
          SizedBox(height: genis ? 12 : 8),
          _Kunye(article: article, isDark: isDark, isEn: isEn),
        ],
      ),
    );

    return Material(
      color: isDark ? const Color(0xFF14201C) : Colors.white,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () =>
            pushScreen(context, ArticleDetailScreen(article: article)),
        child: genis
            ? IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Görsel kartın boyunu belirliyor; metin yanında ortalanıyor.
                    SizedBox(
                      width: _icerikGenisligi(context) * 0.42,
                      child: AspectRatio(aspectRatio: 16 / 9, child: gorsel),
                    ),
                    Expanded(child: metin),
                  ],
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AspectRatio(aspectRatio: 16 / 9, child: gorsel),
                  metin,
                ],
              ),
      ),
    );
  }
}

/// İkili vuruş — kare görsel + başlık.
class _KompaktKart extends StatelessWidget {
  const _KompaktKart({
    required this.article,
    required this.isDark,
    required this.isEn,
  });

  final NewsArticle article;
  final bool isDark;
  final bool isEn;

  @override
  Widget build(BuildContext context) {
    final renk = _konuRengi(article.topic ?? 'Genel', isDark);
    final murekkep = isDark ? AppColors.creamBackground : AppColors.earthText;
    final baslik = (isEn && (article.titleEn ?? '').isNotEmpty)
        ? article.titleEn!
        : article.title;

    return Material(
      color: isDark ? const Color(0xFF14201C) : Colors.white,
      borderRadius: BorderRadius.circular(10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () =>
            pushScreen(context, ArticleDetailScreen(article: article)),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Konu şeridi: kartın sol kenarında 3 px. Renk tek başına
              // anlam taşımıyor — künyede konunun adı da yazılı (§3.2).
              Container(width: 3, color: renk),
              Padding(
                padding: const EdgeInsets.all(10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: SizedBox(
                    width: 64,
                    height: 64,
                    child: NewsArticleImage(
                        imageUrl: article.imageUrl,
                        fit: BoxFit.cover,
                        semanticLabel: baslik),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        baslik,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          fontSize: 14.5,
                          height: 1.3,
                          fontWeight: FontWeight.w600,
                          color: murekkep,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _Kunye(
                          article: article,
                          isDark: isDark,
                          isEn: isEn,
                          kisa: true),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Telgraf vuruşu — görselsiz satırlar, solda saat rayı.
///
/// Yoğunluk buradan geliyor: üç satır bir kartın yerini tutuyor. Ray, saatleri
/// tek bir dikey hatta dizerek günün akışını görünür kılıyor; ajans telekslerinin
/// kâğıt üzerindeki karşılığı.
class _TelgrafSerit extends StatelessWidget {
  const _TelgrafSerit({
    required this.haberler,
    required this.isDark,
    required this.isEn,
  });

  final List<NewsArticle> haberler;
  final bool isDark;
  final bool isEn;

  @override
  Widget build(BuildContext context) {
    final cizgi = isDark ? Colors.white24 : Colors.black26;
    final murekkep = isDark ? AppColors.creamBackground : AppColors.earthText;
    final sessiz = isDark ? Colors.white54 : Colors.black54;

    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Column(
        children: [
          for (final a in haberler)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () =>
                    pushScreen(context, ArticleDetailScreen(article: a)),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        width: 54,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 11),
                          child: Text(
                            DateFormat('HH:mm').format(a.createdAt.toLocal()),
                            style: GoogleFonts.robotoMono(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: sessiz,
                            ),
                          ),
                        ),
                      ),
                      // Ray — saatleri birbirine bağlayan dikey hat.
                      Container(width: 1, color: cizgi),
                      Expanded(
                        child: Padding(
                          padding:
                              const EdgeInsets.fromLTRB(14, 10, 0, 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                (isEn && (a.titleEn ?? '').isNotEmpty)
                                    ? a.titleEn!
                                    : a.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  height: 1.32,
                                  fontWeight: FontWeight.w500,
                                  color: murekkep,
                                ),
                              ),
                              const SizedBox(height: 4),
                              _Kunye(
                                  article: a,
                                  isDark: isDark,
                                  isEn: isEn,
                                  kisa: true),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Konu + kaynak künyesi. Konu ADIYLA yazılı — rengin yanında kelime olmadan
/// ayrım taşınmıyor (§3.2).
class _Kunye extends StatelessWidget {
  const _Kunye({
    required this.article,
    required this.isDark,
    required this.isEn,
    this.kisa = false,
  });

  final NewsArticle article;
  final bool isDark;
  final bool isEn;
  final bool kisa;

  @override
  Widget build(BuildContext context) {
    final konu = article.topic ?? 'Genel';
    final renk = _konuRengi(konu, isDark);
    final sessiz = isDark ? Colors.white54 : Colors.black54;
    final kaynak = (article.sourceName ?? '').trim();

    return Row(
      children: [
        Text(
          konu,
          style: GoogleFonts.inter(
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
            color: renk,
          ),
        ),
        if (kaynak.isNotEmpty) ...[
          Text('  ·  ',
              style: GoogleFonts.inter(fontSize: 10.5, color: sessiz)),
          Flexible(
            child: Text(
              kaynak,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(fontSize: 10.5, color: sessiz),
            ),
          ),
        ],
        if (!kisa) ...[
          const Spacer(),
          Text(
            DateFormat('HH:mm').format(article.createdAt.toLocal()),
            style: GoogleFonts.robotoMono(fontSize: 10.5, color: sessiz),
          ),
        ],
      ],
    );
  }
}

/// Göz hizasına gelen blok yumuşakça beliriyor.
///
/// "Hareketli" istendi ama ölçülü: 180 ms'lik bir yükselme + solma. Kayan,
/// zıplayan ya da kendiliğinden dönen bir öğe yok — içerik çiftliklerini
/// ciddi yayınlardan ayıran işaretlerden biri tam olarak odur.
///
/// Kademe blok SIRASINA bağlı ve 5 blokta bir sıfırlanıyor: sınırsız kademe,
/// günün sonundaki bloğu yarım saniye geciktirirdi.
class _Belir extends StatefulWidget {
  const _Belir({required this.sira, required this.child});
  final int sira;
  final Widget child;

  @override
  State<_Belir> createState() => _BelirState();
}

class _BelirState extends State<_Belir> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  bool _kapali = false;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    Future.delayed(Duration(milliseconds: 45 * (widget.sira % 5)), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _kapali = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (_kapali) _c.value = 1;
  }

  @override
  void dispose() {
    _c.stop();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_kapali) return widget.child;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final t = Curves.easeOutCubic.transform(_c.value);
        return Opacity(
          opacity: t,
          child: Transform.translate(offset: Offset(0, 10 * (1 - t)), child: child),
        );
      },
      child: widget.child,
    );
  }
}

// ─── Gün öbekleri ───────────────────────────────────────────────────────────

class _Gun {
  const _Gun(this.tarih, this.haberler);
  final DateTime tarih;
  final List<NewsArticle> haberler;
}

/// Haberleri yerel takvim gününe göre öbekler.
///
/// Sıralama korunuyor: [briefArticlesProvider] listeyi yeniden eskiye veriyor,
/// bu yüzden ilk görülen gün en yeni gün. Ayrıca sıralamaya gerek yok.
///
/// Gün sınırı UTC'de değil YEREL saatte hesaplanıyor. Aksi hâlde akşam 22:00'de
/// yayımlanan bir haber okuyucuya "yarın" tarihiyle görünüyordu.
List<_Gun> _gunlereBol(List<NewsArticle> articles) {
  final gunler = <_Gun>[];
  for (final a in articles) {
    final yerel = a.createdAt.toLocal();
    final gun = DateTime(yerel.year, yerel.month, yerel.day);
    if (gunler.isNotEmpty && gunler.last.tarih == gun) {
      gunler.last.haberler.add(a);
    } else {
      gunler.add(_Gun(gun, [a]));
    }
  }
  return gunler;
}

// ─── Sayfa başlığı ──────────────────────────────────────────────────────────

class _Basluk extends StatelessWidget {
  final bool isDark;
  final bool isEn;
  final int adet;
  final int gunSayisi;

  const _Basluk({
    required this.isDark,
    required this.isEn,
    required this.adet,
    required this.gunSayisi,
  });

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.accentFor(isDark: isDark);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : Colors.black.withValues(alpha: 0.02),
        border: Border(
          bottom: BorderSide(color: accent.withValues(alpha: 0.3), width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEn ? 'In Brief' : 'Kısa Kısa',
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: isDark ? AppColors.creamBackground : AppColors.earthText,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isEn
                ? '$adet items · $gunSayisi days'
                : '$adet haber · $gunSayisi gün',
            style: GoogleFonts.inter(
              fontSize: AppTypography.minLabelSize,
              fontWeight: FontWeight.w700,
              color: accent,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Boş durum ──────────────────────────────────────────────────────────────

class _BosDurum extends StatelessWidget {
  final bool isDark;
  final bool isEn;

  const _BosDurum({required this.isDark, required this.isEn});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bolt_outlined,
              size: 56,
              color: isDark ? Colors.white24 : Colors.black26,
            ),
            const SizedBox(height: 20),
            Text(
              isEn
                  ? 'No short items yet.\nThey appear here as sources publish them.'
                  : 'Henüz kısa haber yok.\nKaynaklar yayımladıkça burada görünecek.',
              style: GoogleFonts.inter(
                fontSize: 15,
                color: isDark ? Colors.white54 : Colors.black45,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
