import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/fade_page_route.dart';
import '../../../../core/utils/image_fallback_helper.dart';
import '../../../home/providers/font_scale_provider.dart';
import '../../data/models/country_dossier.dart';
import '../../data/models/dossier_chart.dart';
import '../../data/models/dossier_theme.dart';
import '../../providers/dossier_providers.dart';
import '../widgets/dossier_chart_view.dart';
import '../widgets/dossier_prose.dart';
import '../widgets/dossier_share_bar.dart';
import '../widgets/dossier_video_player.dart';
import '../widgets/polder_motif.dart';
import 'dossier_index_screen.dart';

/// Bir ülke dosyasının tam sayfası.
///
/// **Neden koyu ve neden sistem tercihini izlemiyor.** Uygulamanın geri kalanı
/// krem zeminli ve tek modlu. Dosya sayfası bilerek bir ada: okur haber
/// akışından çıkıp başka bir şeye girdiğini renkten anlıyor. Sistem koyu moda
/// bağlansaydı ada, cihaz ayarına göre bazen var bazen yok olurdu. Bu yüzden
/// sayfadaki her renk [DossierTheme]'den geliyor ve hiçbir yerde
/// `Theme.of(context).brightness` okunmuyor.
///
/// **Kapak görseli olmadan da tam çalışır** (Faz 3 zorunluluğu). `cover_url`
/// null geldiğinde kapak tipografik iskelete düşüyor; sayfanın hiçbir bölümü
/// eksilmiyor. Hollanda dosyası şu anda tam olarak bu durumda yayına giriyor.
class CountryDossierScreen extends ConsumerStatefulWidget {
  const CountryDossierScreen({super.key, required this.slug});

  final String slug;

  @override
  ConsumerState<CountryDossierScreen> createState() => _CountryDossierScreenState();
}

class _CountryDossierScreenState extends ConsumerState<CountryDossierScreen> {
  late final ScrollController _kaydirma;
  bool _kaydi = false;

  /// Sekme başlığı bir kez yazılıyor.
  ///
  /// `build` her yeniden çizimde çalışıyor; oradan koşulsuz çağrılsaydı yazı
  /// boyu düğmesine her basışta işletim sistemine bir çağrı daha giderdi.
  String? _yazilanBaslik;

  static const String _varsayilanSekme = 'Tarım Portalı';

  /// Görev değiştiricide görünen renk. Dosya sayfası koyu olduğu için
  /// haber sayfasının yeşilini değil dosyanın gece zeminini kullanıyor.
  static const int _sekmeRengi = 0xFF101418;

  @override
  void initState() {
    super.initState();
    _kaydirma = ScrollController()
      ..addListener(() {
        final kaydi = _kaydirma.offset > 220;
        if (_kaydi != kaydi) setState(() => _kaydi = kaydi);
      });
  }

  @override
  void dispose() {
    _sekmeBasligi(_varsayilanSekme);
    _kaydirma.dispose();
    super.dispose();
  }

  void _sekmeBasligi(String etiket) {
    SystemChrome.setApplicationSwitcherDescription(
      ApplicationSwitcherDescription(label: etiket, primaryColor: _sekmeRengi),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final olcek = ref.watch(fontScaleProvider);

    return ref.watch(dossierBySlugProvider(widget.slug)).when(
          data: (dosya) => dosya == null
              ? _Durum(
                  tema: DossierTheme.yedek,
                  mesaj: isEn ? 'Dossier not found.' : 'Dosya bulunamadı.',
                )
              : _sayfa(dosya, isEn: isEn, olcek: olcek),
          loading: () => const _Durum(tema: DossierTheme.yedek, bekliyor: true),
          error: (_, __) => _Durum(
            tema: DossierTheme.yedek,
            mesaj: isEn ? 'Dossier could not be loaded.' : 'Dosya yüklenemedi.',
          ),
        );
  }

  Widget _sayfa(CountryDossier dosya, {required bool isEn, required double olcek}) {
    final tema = dosya.summary.theme;
    final ad = dosya.summary.name(isEn);

    if (_yazilanBaslik != ad) {
      _yazilanBaslik = ad;
      // Çizim sırasında platform çağrısı yapılmıyor; kare bitince yapılıyor.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _sekmeBasligi(ad);
      });
    }

    final bolumler = dosya.sections;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      // Sayfa koyu; durum çubuğu simgeleri açık olmalı. Bu da sistem
      // tercihine değil sayfanın kendi zeminine bağlı.
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: tema.zemin,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: tema.zemin,
        body: Stack(
          children: [
            CustomScrollView(
              controller: _kaydirma,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: _Kapak(ozet: dosya.summary, tema: tema, isEn: isEn),
                ),
                // Kapaktan gövdeye geçiş bandı. Motifin gövde metninin
                // arkasında değil yalnızca geçişlerde durması tasarım kuralı.
                SliverToBoxAdapter(child: PolderMotif(tema: tema)),

                // Bölümler tembel: 13 bölümün toplam gövdesi ~4.800 kelime ve
                // her birinin altında grafik var. Hepsini tek seferde kurmak
                // açılışta gözle görülür bir duraklama yapıyordu.
                SliverList.builder(
                  itemCount: bolumler.length,
                  itemBuilder: (context, i) => _Bolum(
                    bolum: bolumler[i],
                    grafikler: dosya.chartsFor(bolumler[i]),
                    tema: tema,
                    isEn: isEn,
                    olcek: olcek,
                    sonuncu: i == bolumler.length - 1,
                  ),
                ),

                SliverToBoxAdapter(
                  child: _VeriNotlari(bosluklar: dosya.gaps, tema: tema, isEn: isEn),
                ),
                SliverToBoxAdapter(
                  child: _Kunye(kaynaklar: dosya.sources, tema: tema, isEn: isEn),
                ),
                SliverToBoxAdapter(
                  child: _Oluk(
                    dikey: 24,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: DossierShareBar(ozet: dosya.summary, tema: tema, isEn: isEn),
                    ),
                  ),
                ),
                // Arşiv bağlantısı en sonda: on üç bölümü bitiren okuyucu,
                // dizinin devamı olduğunu ancak burada öğrenmeli. Yukarı
                // konsaydı okunmakta olan dosyadan çıkmaya davet ederdi.
                SliverToBoxAdapter(
                  child: _ArsivBaglantisi(tema: tema, isEn: isEn),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 72)),
              ],
            ),
            _UstCubuk(baslik: ad, tema: tema, kaydi: _kaydi),
          ],
        ),
      ),
    );
  }
}

// ─── Ortak oluk ─────────────────────────────────────────────────────────────

/// Okuma oluğu — sayfadaki her metin bloğu bundan geçiyor.
///
/// 720 px, haber sayfasındaki 800'den dar: dosya gövdesi uzun paragraflardan
/// oluşuyor ve geniş satır uzun okumada satır atlatıyor.
class _Oluk extends StatelessWidget {
  const _Oluk({required this.child, this.dikey = 0});

  final Widget child;
  final double dikey;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: dikey),
          child: child,
        ),
      ),
    );
  }
}

/// Küçük harf aralıklı üst etiket — "ÜLKE DOSYASI · 01", "VERİ NOTLARI".
class _Etiket extends StatelessWidget {
  const _Etiket(this.metin, {required this.renk});

  final String metin;
  final Color renk;

  @override
  Widget build(BuildContext context) {
    return Text(
      metin,
      style: AppTypography.meta(context, color: renk).copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 1.6,
      ),
    );
  }
}

// ─── Kapak ──────────────────────────────────────────────────────────────────

/// Dosyanın kapağı.
///
/// Görsel varsa arkada durur, yoksa kapak tipografik kalır — ikisinde de aynı
/// dört şey görünür: seri etiketi, ülke adı, tez cümlesi ve pencere bilgisi.
/// Görsel bir katman, taşıyıcı değil.
class _Kapak extends StatelessWidget {
  const _Kapak({required this.ozet, required this.tema, required this.isEn});

  final DossierSummary ozet;
  final DossierTheme tema;
  final bool isEn;

  @override
  Widget build(BuildContext context) {
    final ust = MediaQuery.of(context).padding.top;
    final gorselVar = ozet.coverUrl != null;

    final icerik = _Oluk(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _Etiket(
            '${isEn ? 'COUNTRY DOSSIER' : 'ÜLKE DOSYASI'} · ${ozet.editionLabel}',
            renk: tema.vurgu,
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  ozet.name(isEn),
                  style: AppTypography.headlineHome(context, color: tema.murekkep),
                ),
              ),
              const SizedBox(width: 16),
              DossierShareBar(ozet: ozet, tema: tema, isEn: isEn),
            ],
          ),
          const SizedBox(height: 16),
          // Tez cümlesi kapakta duruyor: dosyanın ne iddia ettiğini okur ilk
          // ekranda öğrenmeli, on üç bölüm sonra değil.
          Text(
            ozet.thesis(isEn),
            style: AppTypography.deck(context, color: tema.murekkep),
          ),
          if (ozet.slug.contains('hollanda')) ...[
            const SizedBox(height: 24),
            const DossierVideoPlayer(
              videoPath: 'assets/videos/copy_12951F0A-2908-4BF0-B083-73A1927D00B0.MOV',
            ),
            const SizedBox(height: 12),
          ] else ...[
            const SizedBox(height: 22),
          ],
          _Pencere(ozet: ozet, tema: tema, isEn: isEn),
        ],
      ),
    );

    return Container(
      width: double.infinity,
      color: tema.zemin,
      child: Stack(
        children: [
          if (gorselVar)
            Positioned.fill(
              child: ClipRect(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    NewsArticleImage(
                      imageUrl: ozet.coverUrl,
                      fit: BoxFit.cover,
                      isHighQuality: true,
                      semanticLabel: ozet.name(isEn),
                    ),
                    // Perde: metnin okunurluğu görselin şansına
                    // bırakılamaz. Alt kenar zemine tamamen kavuşuyor ki
                    // kapaktan gövdeye kesik bir geçiş olmasın.
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.0, 0.45, 1.0],
                          colors: [
                            tema.zemin.withValues(alpha: 0.55),
                            tema.zemin.withValues(alpha: 0.82),
                            tema.zemin,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Padding(
            // Üstteki boşluk çubuğun altına iniyor; kapak metni geri
            // düğmesinin altından başlıyor.
            padding: EdgeInsets.only(top: ust + kToolbarHeight + 28, bottom: ozet.slug.contains('hollanda') ? 12 : 34),
            child: icerik,
          ),
        ],
      ),
    );
  }
}

/// Yayın penceresi rozeti.
class _Pencere extends StatelessWidget {
  const _Pencere({required this.ozet, required this.tema, required this.isEn});

  final DossierSummary ozet;
  final DossierTheme tema;
  final bool isEn;

  @override
  Widget build(BuildContext context) {
    final parcalar = <String>[
      if (ozet.sectionCount > 0)
        isEn ? '${ozet.sectionCount} sections' : '${ozet.sectionCount} bölüm',
      if (ozet.daysRemaining != null && ozet.daysRemaining! > 0)
        isEn
            ? '${ozet.daysRemaining} days left'
            : '${ozet.daysRemaining} gün kaldı',
    ];
    if (parcalar.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        border: Border.all(color: tema.cizgiVurgu),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        parcalar.join(' · '),
        style: AppTypography.meta(context, color: tema.sessiz),
      ),
    );
  }
}

// ─── Bölüm ──────────────────────────────────────────────────────────────────

class _Bolum extends StatelessWidget {
  const _Bolum({
    required this.bolum,
    required this.grafikler,
    required this.tema,
    required this.isEn,
    required this.olcek,
    required this.sonuncu,
  });

  final DossierSection bolum;
  final List<DossierChart> grafikler;
  final DossierTheme tema;
  final bool isEn;
  final double olcek;
  final bool sonuncu;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Oluk(
          dikey: 28,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _Etiket(bolum.ordLabel, renk: tema.vurgu),
                  const SizedBox(width: 12),
                  // Numarayı başlıktan ayıran ince çizgi — dekoratif, bu
                  // yüzden `cizgi`. Anlam taşısaydı `cizgiVurgu` olurdu.
                  Expanded(child: Container(height: 1, color: tema.cizgi)),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                bolum.title(isEn),
                style: AppTypography.headlineCard(
                  context,
                  color: tema.murekkep,
                  scale: olcek,
                ),
              ),
              const SizedBox(height: 18),
              DossierProse(govde: bolum.body(isEn), tema: tema, olcek: olcek),
              for (final grafik in grafikler)
                DossierChartView(chart: grafik, tema: tema, isEn: isEn),
            ],
          ),
        ),
        if (!sonuncu) PolderMotif(tema: tema, yukseklik: 64),
      ],
    );
  }
}

// ─── Veri notları ───────────────────────────────────────────────────────────

/// Sayfanın dürüstlük paneli.
///
/// Gizlenecek bir şey değil, dosyanın en güçlü kısmı: hangi rakamı
/// bulamadığımızı ve yerine ne koyduğumuzu okur burada görüyor. Bu yüzden
/// katlanabilir bir kutunun içinde değil, açıkta.
class _VeriNotlari extends StatelessWidget {
  const _VeriNotlari({
    required this.bosluklar,
    required this.tema,
    required this.isEn,
  });

  final List<DossierGap> bosluklar;
  final DossierTheme tema;
  final bool isEn;

  @override
  Widget build(BuildContext context) {
    if (bosluklar.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PolderMotif(tema: tema, yukseklik: 64),
        _Oluk(
          dikey: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Etiket(isEn ? 'DATA NOTES' : 'VERİ NOTLARI', renk: tema.vurgu),
              const SizedBox(height: 10),
              Text(
                isEn
                    ? 'Every figure in this dossier comes from a named source. These are the places where the source did not have the figure, and what was put there instead.'
                    : 'Bu dosyadaki her rakamın adı konmuş bir kaynağı var. Aşağıdakiler kaynağın o rakamı vermediği yerler ve yerine ne konduğu.',
                style: AppTypography.body(context, color: tema.sessiz),
              ),
              const SizedBox(height: 20),
              for (final b in bosluklar)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  decoration: BoxDecoration(
                    color: tema.yuzey,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: tema.cizgi),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              b.konu(isEn),
                              style: AppTypography.body(
                                context,
                                color: tema.murekkep,
                              ).copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                          if (b.kapandi) ...[
                            const SizedBox(width: 10),
                            // Durum metinle de yazılı; simge tek başına
                            // bilgi taşımıyor.
                            Text(
                              isEn ? 'CLOSED' : 'KAPANDI',
                              style: AppTypography.meta(
                                context,
                                color: tema.vurgu,
                              ).copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        b.sorun(isEn),
                        style: AppTypography.meta(context, color: tema.sessiz),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        b.cozum(isEn),
                        style: AppTypography.meta(context, color: tema.murekkep),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Kaynak künyesi ─────────────────────────────────────────────────────────

class _Kunye extends StatelessWidget {
  const _Kunye({required this.kaynaklar, required this.tema, required this.isEn});

  final List<DossierSource> kaynaklar;
  final DossierTheme tema;
  final bool isEn;

  @override
  Widget build(BuildContext context) {
    if (kaynaklar.isEmpty) return const SizedBox.shrink();

    return _Oluk(
      dikey: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Etiket(isEn ? 'SOURCES' : 'KAYNAKLAR', renk: tema.vurgu),
          const SizedBox(height: 12),
          for (final k in kaynaklar)
            Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Text.rich(
                TextSpan(
                  children: [
                    // Kod, grafiklerin kaynak satırında geçen kısaltmanın
                    // aynısı — okur "FAO_TM" satırını burada açabiliyor.
                    TextSpan(
                      text: '${k.kod}  ',
                      style: AppTypography.meta(context, color: tema.vurgu)
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                    TextSpan(
                      text: k.ad,
                      style: AppTypography.meta(context, color: tema.murekkep),
                    ),
                    if (k.lisans != null)
                      TextSpan(
                        text: '  · ${k.lisans}',
                        style: AppTypography.meta(context, color: tema.sessiz),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Arşiv bağlantısı ───────────────────────────────────────────────────────

/// "Bütün ülke dosyaları →" — dosyanın sonundan arşive açılan tek kapı.
class _ArsivBaglantisi extends StatelessWidget {
  const _ArsivBaglantisi({required this.tema, required this.isEn});

  final DossierTheme tema;
  final bool isEn;

  @override
  Widget build(BuildContext context) {
    return _Oluk(
      dikey: 20,
      child: Align(
        alignment: Alignment.centerLeft,
        child: InkWell(
          onTap: () => pushScreen(context, const DossierIndexScreen()),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            // Dokunma hedefi metnin kendisinden büyük: satır yüksekliği tek
            // başına 48 px'lik hedefi vermiyor.
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    isEn ? 'All country dossiers' : 'Bütün ülke dosyaları',
                    style: AppTypography.meta(context, color: tema.vurgu)
                        .copyWith(fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(Icons.arrow_forward_rounded, size: 16, color: tema.vurgu),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Üst çubuk ──────────────────────────────────────────────────────────────

/// Geri düğmesi + kaydırınca beliren başlık.
///
/// Haber sayfasındaki çubuğun aynı davranışı, dosyanın paletiyle. Kapağın
/// üstünde saydam duruyor ki ülke adı geri düğmesinin altında kalmasın.
class _UstCubuk extends StatelessWidget {
  const _UstCubuk({required this.baslik, required this.tema, required this.kaydi});

  final String baslik;
  final DossierTheme tema;
  final bool kaydi;

  @override
  Widget build(BuildContext context) {
    final ust = MediaQuery.of(context).padding.top;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        height: ust + kToolbarHeight,
        padding: EdgeInsets.only(top: ust, left: 4, right: 16),
        decoration: BoxDecoration(
          color: kaydi ? tema.zemin.withValues(alpha: 0.97) : Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: kaydi ? tema.cizgi : Colors.transparent,
            ),
          ),
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 19),
              color: tema.murekkep,
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              onPressed: () => popScreen(context),
            ),
            Expanded(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                opacity: kaydi ? 1 : 0,
                child: Text(
                  baslik,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.meta(context, color: tema.murekkep)
                      .copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Yükleme / hata ─────────────────────────────────────────────────────────

/// Bekleme ve hata ekranı.
///
/// Bunlar da koyu: dosya açılırken bir kare krem zemin görünseydi geçiş
/// yanıp sönme gibi okunurdu. Tema henüz gelmediği için [DossierTheme.yedek]
/// kullanılıyor — kimliksiz ama sayfayla aynı karanlıkta.
class _Durum extends StatelessWidget {
  const _Durum({required this.tema, this.mesaj, this.bekliyor = false});

  final DossierTheme tema;
  final String? mesaj;
  final bool bekliyor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tema.zemin,
      body: Stack(
        children: [
          Center(
            child: bekliyor
                ? CircularProgressIndicator(color: tema.vurgu, strokeWidth: 2)
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      mesaj ?? '',
                      textAlign: TextAlign.center,
                      style: AppTypography.body(context, color: tema.murekkep),
                    ),
                  ),
          ),
          _UstCubuk(baslik: '', tema: tema, kaydi: false),
        ],
      ),
    );
  }
}
