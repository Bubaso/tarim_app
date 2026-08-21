import 'dart:math' as math;

import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';
// getOffsetToReveal / RenderAbstractViewport material.dart'tan dışa vurulmuyor.
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/fade_page_route.dart';
import '../../../../core/utils/image_fallback_helper.dart';
import '../../../home/presentation/widgets/reading_progress_bar.dart';
import '../../../home/providers/font_scale_provider.dart';
import '../../data/models/country_dossier.dart';
import '../../data/models/dossier_chart.dart';
import '../../data/models/dossier_theme.dart';
import '../../providers/dossier_providers.dart';
import '../widgets/dossier_chart_view.dart';
import '../widgets/dossier_contents_sheet.dart';
import '../widgets/dossier_prose.dart';
import '../widgets/dossier_reveal.dart';
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

  /// Okuma ilerlemesi, 0–1.
  ///
  /// `setState` değil `ValueNotifier`: kaydırmanın her karesinde sayfayı
  /// yeniden kurmak on üç bölümün gövdesini de yeniden ayrıştırırdı. Burada
  /// yeniden çizilen tek şey 3 piksellik çizgi.
  final ValueNotifier<double> _ilerleme = ValueNotifier<double>(0);

  /// Kapak paralaksını besleyen ham kaydırma değeri. `_ilerleme` gibi ayrı bir
  /// bildirici: kapağın yeniden çizilmesi sayfanın geri kalanını ilgilendirmiyor.
  final ValueNotifier<double> _kapakOfset = ValueNotifier<double>(0);

  /// Beliriş animasyonunu oynatmış bölümler. Tembel liste bölümü yeniden
  /// kurabildiği için, oynatılıp oynatılmadığını widget değil ekran hatırlıyor.
  final Set<int> _belirdi = <int>{};

  /// Bölüm dizini → widget anahtarı. Bölüm çizilmemişse `currentContext` boş.
  final Map<int, GlobalKey> _bolumAnahtari = {};

  /// Bölüm dizini → o bölümün üstünün denk geldiği mutlak kaydırma konumu.
  ///
  /// Bölüm listesi tembel; uzaktaki bir bölümün gerçek konumu ancak çizildikten
  /// sonra bilinebiliyor. Burası ölçüldükçe doluyor ve hem "şu an hangi
  /// bölümdeyiz" sorusuna hem de içindekilerden sıçrarken ilk tahmine kaynaklık
  /// ediyor. Yazı boyu değiştiğinde bütün konumlar kayacağı için değerler
  /// dondurulmuyor, her kaydırma olayında tazeleniyor.
  final Map<int, double> _bolumKonumu = {};

  int _bolumSayisi = 0;

  /// Okurun içinde bulunduğu bölüm; bilinmiyorsa -1.
  ///
  /// Bildirici, çünkü üst çubuktaki yapışkan başlık buna bağlı. `setState`
  /// olsaydı kaydırmanın her karesinde on üç bölümün tamamı — içindeki `Html`
  /// gövdeleriyle birlikte — yeniden kurulurdu.
  final ValueNotifier<int> _aktifBolum = ValueNotifier<int>(-1);

  /// Kapağın ölçülen yüksekliği; üst çubuğun belirme eşiği buna bağlı.
  /// `build` içinde tazeleniyor, kaydırma dinleyicisinde okunuyor.
  double _kapakYuksekligi = 560;

  /// Bölüm hiç ölçülmemişken kullanılan kaba yükseklik.
  static const double _tahminiBolumYuksekligi = 900;

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
        // Eşik kapağın yüksekliğine bağlı: kapak artık tam ekran, sabit 220
        // px'te çubuk daha kapağın üçte birindeyken belirip dev başlığın
        // üzerine biniyordu. Kapağın üçte ikisi geçildiğinde beliriyor.
        final kaydi = _kaydirma.offset > _kapakYuksekligi * 0.66;
        if (_kaydi != kaydi) setState(() => _kaydi = kaydi);
        _olc();
      });
  }

  @override
  void dispose() {
    _sekmeBasligi(_varsayilanSekme);
    _kaydirma.dispose();
    _ilerleme.dispose();
    _kapakOfset.dispose();
    _aktifBolum.dispose();
    super.dispose();
  }

  // ─── Ölçüm ───────────────────────────────────────────────────────────────

  /// [anahtar]'ın bağlı olduğu kutuyu görüş alanında [hiza] konumuna getirecek
  /// mutlak kaydırma değeri. Bölüm henüz çizilmemişse `null`.
  ///
  /// `hiza: 0.0` kutunun üstünü görüş alanının üstüne, `1.0` altını altına
  /// hizalar.
  double? _konum(GlobalKey anahtar, {double hiza = 0.0}) {
    final nesne = anahtar.currentContext?.findRenderObject();
    if (nesne is! RenderBox || !nesne.hasSize) return null;
    final gorusAlani = RenderAbstractViewport.maybeOf(nesne);
    if (gorusAlani == null) return null;
    return gorusAlani.getOffsetToReveal(nesne, hiza).offset;
  }

  /// Her kaydırma olayında: çizili bölümlerin konumunu tazeler, ilerlemeyi ve
  /// aktif bölümü günceller.
  void _olc() {
    if (!_kaydirma.hasClients || _bolumSayisi == 0) return;
    final konum = _kaydirma.position;
    final simdiki = konum.pixels;
    _kapakOfset.value = simdiki;

    for (final giris in _bolumAnahtari.entries) {
      final k = _konum(giris.value);
      if (k != null) _bolumKonumu[giris.key] = k;
    }

    // İlerlemenin paydası `maxScrollExtent` DEĞİL: sayfanın sonunda veri
    // notları, kaynak künyesi, paylaşım çubuğu ve arşiv bağlantısı var. Son
    // bölümün son cümlesini okuyan kişi çubuğu ~%70'te görür, yani belgeyi
    // bitirdiğini anlayamazdı. Payda son bölümün ALTI ekranın altına
    // dayandığı an — tam olarak "metin bitti".
    final sonAnahtar = _bolumAnahtari[_bolumSayisi - 1];
    final bitis = sonAnahtar == null ? null : _konum(sonAnahtar, hiza: 1.0);
    final payda = bitis ?? konum.maxScrollExtent;
    _ilerleme.value = payda <= 0 ? 0 : (simdiki / payda).clamp(0.0, 1.0);

    // Üst çubuğun hemen altındaki hayalî çizgiyi geçmiş en son bölüm.
    final esik = simdiki + kToolbarHeight + 56;
    var aktif = -1;
    for (final giris in _bolumKonumu.entries) {
      if (giris.value > esik) continue;
      if (aktif == -1 || giris.value > _bolumKonumu[aktif]!) aktif = giris.key;
    }
    _aktifBolum.value = aktif;
  }

  // ─── İçindekilerden bölüme gitme ─────────────────────────────────────────

  /// Ölçülmüş bölümlerden çıkarılan ortalama bölüm yüksekliği.
  double _ortalamaBolumYuksekligi() {
    if (_bolumKonumu.length < 2) return _tahminiBolumYuksekligi;
    final dizinler = _bolumKonumu.keys.toList()..sort();
    final ilk = dizinler.first;
    final son = dizinler.last;
    final fark = _bolumKonumu[son]! - _bolumKonumu[ilk]!;
    if (son == ilk || fark <= 0) return _tahminiBolumYuksekligi;
    return fark / (son - ilk);
  }

  /// Seçilen bölüme kaydırır.
  ///
  /// Bölüm listesi tembel olduğu için hedef bölüm çoğu zaman henüz çizilmemiş
  /// olur; çizilmemiş bir widget'ın konumu da ölçülemez. Bu yüzden döngü:
  /// tahminî konuma sıçra → o çevredeki bölümler çizilsin diye bir kare bekle →
  /// gerçek konumu okumayı yeniden dene. Ölçülmüş bölümler tahmini her turda
  /// iyileştirdiği için genellikle bir ya da iki turda yakınsıyor.
  Future<void> _bolumeGit(int hedefDizin) async {
    for (var deneme = 0; deneme < 12; deneme++) {
      if (!mounted || !_kaydirma.hasClients) return;

      final anahtar = _bolumAnahtari[hedefDizin];
      final gercek = anahtar == null ? null : _konum(anahtar);
      if (gercek != null) {
        final konum = _kaydirma.position;
        final ust = MediaQuery.of(context).padding.top;
        // Başlık üst çubuğun altından başlasın; tam hizalarsa çubuğun altında
        // kalırdı.
        final hedef = (gercek - ust - kToolbarHeight - 12)
            .clamp(konum.minScrollExtent, konum.maxScrollExtent);
        await _kaydirma.animateTo(
          hedef,
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeOutCubic,
        );
        return;
      }

      if (!_sicra(hedefDizin)) return;
      await WidgetsBinding.instance.endOfFrame;
      // Sıçramadan sonra ELDE ÖLÇÜM ALINMALI. `jumpTo` dinleyiciyi karenin
      // layout'undan ÖNCE tetikliyor, sonraki karede de kaydırma değeri
      // değişmediği için dinleyici bir daha çağrılmıyor. Bu çağrı olmadan
      // `_bolumKonumu` sıçramadan önceki hâlinde kalır, bir sonraki tur aynı
      // tahmini üretir ve döngü hedefe hiç yaklaşmadan tükenir.
      _olc();
    }
  }

  /// Hedefin tahminî konumuna sıçrar. Sıçranacak yer kalmadıysa `false`.
  bool _sicra(int hedefDizin) {
    final konum = _kaydirma.position;

    double tahmin;
    final olculmus = _bolumKonumu[hedefDizin];
    if (olculmus != null) {
      // Hedef bir ara ölçülmüş ama şimdi çizili değil (kaydırma sırasında
      // görüş alanının dışına çıkıp elden çıkarılmış). Tahmin etmeye gerek
      // yok; bilinen konuma sıçra, döngü bir sonraki turda oraya gerçekten
      // varıldığını ölçerek doğrulasın.
      tahmin = olculmus;
    } else if (_bolumKonumu.isEmpty) {
      tahmin = konum.maxScrollExtent * (hedefDizin / _bolumSayisi);
    } else {
      // En yakın ölçülmüş bölümden ortalama yükseklikle ilerle.
      final yakin = _bolumKonumu.keys.reduce(
        (a, b) => (a - hedefDizin).abs() <= (b - hedefDizin).abs() ? a : b,
      );
      tahmin = _bolumKonumu[yakin]! +
          (hedefDizin - yakin) * _ortalamaBolumYuksekligi();
    }

    final yeni = tahmin.clamp(konum.minScrollExtent, konum.maxScrollExtent);
    // Sıçrama bir yere varmıyorsa (örneğin zaten en dipteyiz) döngüyü kes;
    // aksi hâlde aynı yerde on iki tur dönerdi.
    if ((yeni - konum.pixels).abs() < 1) return false;
    _kaydirma.jumpTo(yeni);
    return true;
  }

  Future<void> _icindekileriAc(
    List<DossierSection> bolumler,
    DossierTheme tema,
    bool isEn,
  ) async {
    final secim = await DossierContentsSheet.ac(
      context,
      bolumler: bolumler,
      tema: tema,
      isEn: isEn,
      aktif: _aktifBolum.value,
    );
    if (secim != null && mounted) await _bolumeGit(secim);
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
        if (!mounted) return;
        _sekmeBasligi(ad);
        // İlk ölçüm: kaydırma olmadan da çizili bölümlerin konumu bilinsin.
        // Sağlayıcı asenkron olduğu için `initState`'te yapılamıyor — orada
        // henüz bölüm yok.
        _olc();
      });
    }

    final bolumler = dosya.sections;
    _bolumSayisi = bolumler.length;
    final video = dosya.summary.videoUrl;
    // Hacim bilgisi her karede yeniden sayılıyor gibi görünüyor ama gövdeler
    // dosya yüklendikten sonra değişmiyor ve bu, kapağın altında tek satırlık
    // bir metin üretiyor — ölçülebilir bir maliyeti yok.
    final kelime = bolumler.fold<int>(
      0,
      (t, b) => t + b.body(isEn).split(RegExp(r'\s+')).length,
    );
    // Kapak yüksekliğinin ikizi. `_Kapak` kendi içinde aynı hesabı yapıyor;
    // burada da tutuluyor çünkü kaydırma dinleyicisinin `context`i yok.
    _kapakYuksekligi = math.max(
      560.0,
      MediaQuery.of(context).size.height * 0.92,
    );

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
                  child: _Kapak(
                    ozet: dosya.summary,
                    tema: tema,
                    isEn: isEn,
                    ofset: _kapakOfset,
                    bolumSayisi: bolumler.length,
                    kelimeSayisi: kelime,
                  ),
                ),
                // Video kapağın içinden çıkarıldı: tam ekran kapakta ad ile
                // tez cümlesinin arasına giren bir oynatıcı kompozisyonu
                // ikiye bölüyordu. Kendi bloğu olarak hemen altında duruyor.
                if (video != null)
                  SliverToBoxAdapter(
                    child: _Oluk(
                      dikey: 24,
                      child: DossierVideoPlayer(videoUrl: video),
                    ),
                  ),
                // Kapaktan gövdeye geçiş bandı. Motifin gövde metninin
                // arkasında değil yalnızca geçişlerde durması tasarım kuralı.
                SliverToBoxAdapter(child: PolderMotif(tema: tema)),

                // Bölümler tembel: 13 bölümün toplam gövdesi ~4.800 kelime ve
                // her birinin altında grafik var. Hepsini tek seferde kurmak
                // açılışta gözle görülür bir duraklama yapıyordu.
                SliverList.builder(
                  itemCount: bolumler.length,
                  itemBuilder: (context, i) {
                    final sonuncu = i == bolumler.length - 1;
                    final bolum = DossierReveal(
                      etkin: _belirdi.add(i),
                      child: _Bolum(
                        // Anahtar bölümün konumunu ölçmek için; içindekilerden
                        // sıçrama ve ilerleme çubuğunun paydası buna dayanıyor.
                        key: _bolumAnahtari.putIfAbsent(i, GlobalKey.new),
                        bolum: bolumler[i],
                        grafikler: dosya.chartsFor(bolumler[i]),
                        tema: tema,
                        isEn: isEn,
                        olcek: olcek,
                        sonuncu: sonuncu,
                        toplamBolum: bolumler.length,
                      ),
                    );
                    // Her dört bölümde bir motif bandı: on üç bölümlük kesintisiz
                    // metin dizisine nefes aralığı. Kapaktaki geçişin aynısı,
                    // dolayısıyla sayfa boyunca tutarlı bir "ara" işareti.
                    if (sonuncu || (i + 1) % 4 != 0) return bolum;
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [bolum, PolderMotif(tema: tema)],
                    );
                  },
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
            _UstCubuk(
              baslik: ad,
              tema: tema,
              kaydi: _kaydi,
              isEn: isEn,
              onIcindekiler: bolumler.isEmpty
                  ? null
                  : () => _icindekileriAc(bolumler, tema, isEn),
              bolumler: bolumler,
              aktif: _aktifBolum,
            ),
            // Çizgi üst çubuğun alt kenarına oturuyor, bu yüzden çubuktan
            // SONRA çiziliyor — önce gelseydi çubuğun altında kalırdı.
            Positioned(
              top: MediaQuery.of(context).padding.top +
                  kToolbarHeight -
                  ReadingProgressBar.height,
              left: 0,
              right: 0,
              child: ReadingProgressBar(
                progress: _ilerleme,
                accent: tema.vurgu,
                // Çubukla birlikte beliriyor: sayfanın başındayken ilerleme
                // zaten sıfıra yakın ve üst çubuk kapak görselinin üzerinde
                // saydam duruyor, oraya çizgi çekmek kapağı ikiye bölerdi.
                visible: _kaydi,
              ),
            ),
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

/// Dosyanın kapağı — tam ekran.
///
/// **Neden tam ekran.** Kapak daha önce içeriği kadar yükselen (~400 px) bir
/// bant'tı; telefonda ilk ekranda hem kapak hem gövdenin başı görünüyordu ve
/// dosya, sıradan bir haber sayfasından ayrışmıyordu. Kapak tek başına bir
/// ekran olduğunda okur önce "bir şeyin başına geldiğini" görüyor, sonra
/// okumaya başlıyor — basılı bir dosyanın kapak sayfasının yaptığı iş.
///
/// **Kompozisyon.** Seri etiketi üstte, ülke adı ve tez cümlesi alt üçte
/// birde, en altta kaydırma daveti. Ad ile tez arasındaki hiyerarşi ölçekle
/// kuruluyor (132 px'e karşı 17 px), renkle değil.
///
/// Görsel varsa arkada durur, yoksa kapak tipografik kalır — ikisinde de aynı
/// dört şey görünür: seri etiketi, ülke adı, tez cümlesi ve pencere bilgisi.
/// Görsel bir katman, taşıyıcı değil.
class _Kapak extends StatelessWidget {
  const _Kapak({
    required this.ozet,
    required this.tema,
    required this.isEn,
    required this.ofset,
    required this.bolumSayisi,
    required this.kelimeSayisi,
  });

  final DossierSummary ozet;
  final DossierTheme tema;
  final bool isEn;
  final int bolumSayisi;
  final int kelimeSayisi;

  /// Sayfanın ham kaydırma değeri; kapak görseli bunun bir kesri kadar
  /// geride kalıyor.
  final ValueListenable<double> ofset;

  @override
  Widget build(BuildContext context) {
    final olcu = MediaQuery.of(context);
    final ust = olcu.padding.top;
    final gorselVar = ozet.coverUrl != null;

    // Ekranın %92'si: alt kenarda kalan %8 gövdenin başlangıcını gösteriyor,
    // yani kapak bir "son" değil bir "başlangıç" gibi duruyor. Alt sınır 560
    // px — çok kısa pencerelerde (yatay telefon) dev başlık taşmasın diye
    // yükseklik içeriğin altına inmiyor.
    final yukseklik = math.max(560.0, olcu.size.height * 0.92);

    return SizedBox(
      width: double.infinity,
      height: yukseklik,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(color: tema.zemin),
          if (gorselVar)
            Positioned.fill(
              child: ClipRect(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Paralaks: görsel kaydırmanın üçte biri kadar hareket
                    // ediyor, yani metnin gerisinde kalıyor. Büyütme şart —
                    // görsel aşağı kayarken üst kenarında boşluk açılmasın.
                    // Perde bu katmanın DIŞINDA: o da kaysaydı metnin altındaki
                    // koyuluk kayar, okunurluk kaydırmaya bağlı hâle gelirdi.
                    ValueListenableBuilder<double>(
                      valueListenable: ofset,
                      builder: (context, o, child) => Transform.translate(
                        offset: Offset(
                          0,
                          MediaQuery.of(context).disableAnimations
                              ? 0
                              : o * 0.32,
                        ),
                        child: child,
                      ),
                      child: Transform.scale(
                        scale: 1.16,
                        child: NewsArticleImage(
                          imageUrl: ozet.coverUrl,
                          fit: BoxFit.cover,
                          isHighQuality: true,
                          semanticLabel: ozet.name(isEn),
                        ),
                      ),
                    ),
                    // Perde iki katman.
                    //
                    // 1) Radyal: koyuluğu yalnızca metnin bulunduğu sol-alt
                    // köşeye topluyor. Tek yönlü lineer perde tüm görseli
                    // eşit karartıyordu; görselin üst köşeleri açık kalınca
                    // kapak fotoğraf gibi duruyor, karartma da metnin
                    // gerektiği yerde oluyor.
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: const Alignment(-0.65, 0.55),
                          radius: 1.25,
                          colors: [
                            tema.zemin.withValues(alpha: 0.88),
                            tema.zemin.withValues(alpha: 0.20),
                          ],
                        ),
                      ),
                    ),
                    // 2) Lineer: alt kenarın zemine tamamen kavuşmasını
                    // garantiliyor — kapaktan gövdeye kesik bir geçiş olmasın.
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.0, 0.35, 0.72, 1.0],
                          colors: [
                            tema.zemin.withValues(alpha: 0.42),
                            tema.zemin.withValues(alpha: 0.10),
                            tema.zemin.withValues(alpha: 0.72),
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
            padding: EdgeInsets.only(
              top: ust + kToolbarHeight + 20,
              bottom: 20,
            ),
            child: _Oluk(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Etiket(
                    '${isEn ? 'COUNTRY DOSSIER' : 'ÜLKE DOSYASI'} · ${ozet.editionLabel}',
                    renk: tema.vurgu,
                  ),
                  // Esnek boşluk adı alt üçte bire itiyor. Sabit bir değer
                  // olsaydı 560 px'lik pencerede ad ekrandan taşardı.
                  const Spacer(),
                  // Ad tek satıra sığmayabilir ("Birleşik Krallık"): sarma
                  // serbest, kırpma yok. Dar telefonda iki satır olması
                  // sorun değil, ölçek zaten kompozisyonun kendisi.
                  Text(
                    ozet.name(isEn),
                    style: AppTypography.dossierCover(
                      context,
                      color: tema.murekkep,
                    ),
                  ),
                  const SizedBox(height: 18),
                  // Tez cümlesi kapakta duruyor: dosyanın ne iddia ettiğini
                  // okur ilk ekranda öğrenmeli, on üç bölüm sonra değil.
                  ConstrainedBox(
                    // Tez satırı adın altında dar bir sütun: dev başlıkla
                    // aynı genişlikte akarsa ikisi tek blok gibi okunur.
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Text(
                      ozet.thesis(isEn),
                      style: AppTypography.deck(context, color: tema.murekkep),
                    ),
                  ),
                  const SizedBox(height: 22),
                  // Paylaşım çubuğu adın yanından alındı: 132 px'lik bir
                  // başlığın yanında ikonlar sıkışıyor ve kompozisyonu
                  // bozuyordu. Pencere rozetiyle aynı satırda, alt sırada.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Esnek: dar telefonda rozet metni sarmalı, paylaşım
                      // düğmelerini ekran dışına itmemeli.
                      Flexible(
                        child: _Pencere(ozet: ozet, tema: tema, isEn: isEn),
                      ),
                      const SizedBox(width: 12),
                      DossierShareBar(ozet: ozet, tema: tema, isEn: isEn),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Center(
                    child: _KaydirmaDaveti(
                      bolumSayisi: bolumSayisi,
                      kelimeSayisi: kelimeSayisi,
                      tema: tema,
                      isEn: isEn,
                    ),
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

/// Kapağın alt kenarındaki "aşağıda devamı var" işareti.
///
/// Tam ekran bir kapağın tek riski, okurun sayfanın burada bittiğini
/// sanması. İnce bir ok ve dosyanın hacmi (`13 BÖLÜM · ~4.800 KELİME`)
/// bunu tek bakışta çözüyor; hacim bilgisi ayrıca okura ne kadarlık bir işe
/// giriştiğini söylüyor.
///
/// Yavaş yanıp sönme dikkat çekmek için değil, işaretin canlı olduğunu
/// göstermek için — "hareketi azalt" açıksa sabit tam görünürlükte duruyor.
class _KaydirmaDaveti extends StatefulWidget {
  const _KaydirmaDaveti({
    required this.bolumSayisi,
    required this.kelimeSayisi,
    required this.tema,
    required this.isEn,
  });

  final int bolumSayisi;

  /// Dosyanın toplam kelimesi. Veritabanında tutulmuyor — gövdelerden
  /// sayılıyor, çünkü metin düzenlendiğinde ayrı bir alanın güncellenmesi
  /// unutulur ve okura yanlış bir hacim bildirilir.
  final int kelimeSayisi;
  final DossierTheme tema;
  final bool isEn;

  @override
  State<_KaydirmaDaveti> createState() => _KaydirmaDavetiState();
}

class _KaydirmaDavetiState extends State<_KaydirmaDaveti>
    with SingleTickerProviderStateMixin {
  late final AnimationController _denetim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  late final Animation<double> _nabiz = Tween<double>(
    begin: 0.42,
    end: 1.0,
  ).animate(CurvedAnimation(parent: _denetim, curve: Curves.easeInOut));

  /// Nabız sonsuza kadar atmıyor: üç turdan sonra tam görünürlükte duruyor.
  ///
  /// Kapağın altında durmadan yanıp sönen bir işaret, okur sayfada kaldığı
  /// sürece göz ucunda hareket eden bir şey demek — dikkati metinden çekiyor.
  /// Üç tur "bu bir işaret" demeye yetiyor, sonrası ısrar oluyor.
  int _tur = 0;
  static const int _maksTur = 3;

  bool _basladi = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_basladi) return;
    _basladi = true;
    if (MediaQuery.of(context).disableAnimations) {
      _denetim.value = 1;
    } else {
      _denetim.addStatusListener(_durum);
      _denetim.forward();
    }
  }

  void _durum(AnimationStatus s) {
    if (_tur >= _maksTur) return;
    if (s == AnimationStatus.completed) {
      _denetim.reverse();
    } else if (s == AnimationStatus.dismissed) {
      _tur++;
      // Son turda değeri doğrudan koymak yeni bir durum bildirimi tetikliyor;
      // yukarıdaki koruma o çağrıyı sessizce geri çeviriyor.
      _tur >= _maksTur ? _denetim.value = 1 : _denetim.forward();
    }
  }

  @override
  void dispose() {
    _denetim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tema = widget.tema;
    final parcalar = <String>[
      if (widget.bolumSayisi > 0)
        widget.isEn
            ? '${widget.bolumSayisi} SECTIONS'
            : '${widget.bolumSayisi} BÖLÜM',
      if (widget.kelimeSayisi >= 100)
        widget.isEn
            ? '~${_bin(widget.kelimeSayisi)} WORDS'
            : '~${_bin(widget.kelimeSayisi)} KELİME',
    ];

    return FadeTransition(
      opacity: _nabiz,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (parcalar.isNotEmpty) ...[
            Text(
              parcalar.join('  ·  '),
              style: AppTypography.meta(context, color: tema.sessiz).copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 1.8,
              ),
            ),
            const SizedBox(height: 6),
          ],
          Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 22,
            color: tema.sessiz,
            // Ok salt dekoratif; hacim bilgisi zaten metin olarak okunuyor.
            semanticLabel: null,
          ),
        ],
      ),
    );
  }

  /// 4823 → "4.800" (TR) / "4,800" (EN). Kelime sayısı yaklaşık bir büyüklük;
  /// birler basamağına kadar yazmak sahte bir kesinlik olurdu.
  String _bin(int n) {
    final yuvarlak = (n / 100).round() * 100;
    final metin = yuvarlak.toString();
    if (metin.length <= 3) return metin;
    final ayrac = widget.isEn ? ',' : '.';
    return '${metin.substring(0, metin.length - 3)}$ayrac'
        '${metin.substring(metin.length - 3)}';
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
    super.key,
    required this.bolum,
    required this.grafikler,
    required this.tema,
    required this.isEn,
    required this.olcek,
    required this.sonuncu,
    required this.toplamBolum,
  });

  final DossierSection bolum;
  final List<DossierChart> grafikler;
  final DossierTheme tema;
  final bool isEn;
  final double olcek;
  final bool sonuncu;
  final int toplamBolum;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Bölüm başlığı bloğu: hayalet rakam arkada, başlık önde.
        //
        // Üstteki 72 px'lik boşluk bilinçli olarak alttakinden (56) büyük:
        // başlık kendinden önceki bölümün metnine değil, kendi gövdesine ait
        // görünmeli. Eşit boşlukta başlık iki blok arasında asılı kalıyor.
        _Oluk(
          child: Padding(
            padding: const EdgeInsets.only(top: 72, bottom: 24),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Hayalet rakam. %5 opaklıkta, yani bir doku; okunması
                // gerekmiyor, okunan rakam zaten başlığın üstündeki etikette.
                // Bu yüzden ekran okuyucudan gizli.
                Positioned(
                  left: -8,
                  top: -34,
                  child: ExcludeSemantics(
                    child: Text(
                      bolum.ordLabel,
                      style: AppTypography.dossierCover(
                        context,
                        color: tema.murekkep.withValues(alpha: 0.05),
                      ),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Vurgu çizgisi: bölümün başladığı yer, başlık okunmadan
                    // önce fark edilsin. Renk körü okur için de çizginin
                    // varlığı (rengi değil) işaret taşıyor.
                    Container(width: 48, height: 3, color: tema.vurgu),
                    const SizedBox(height: 18),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _Etiket(bolum.ordLabel, renk: tema.vurgu),
                        const SizedBox(width: 8),
                        // "03 / 13" ilerleme sayacı. Okuyucu nerede olduğunu
                        // ve ne kadar kaldığını tek bakışta görür.
                        Text(
                          '/ ${toplamBolum.toString().padLeft(2, '0')}',
                          style: AppTypography.meta(context, color: tema.sessiz)
                              .copyWith(
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1.0,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      bolum.title(isEn),
                      style: AppTypography.dossierSection(
                        context,
                        color: tema.murekkep,
                        scale: olcek,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        _Oluk(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 56),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DossierProse(govde: bolum.body(isEn), tema: tema, olcek: olcek),
                for (final grafik in grafikler)
                  DossierChartView(chart: grafik, tema: tema, isEn: isEn),
              ],
            ),
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
  const _UstCubuk({
    required this.baslik,
    required this.tema,
    required this.kaydi,
    this.isEn = false,
    this.onIcindekiler,
    this.bolumler = const [],
    this.aktif,
  });

  final String baslik;
  final DossierTheme tema;
  final bool kaydi;
  final bool isEn;

  /// Boşsa düğme hiç çizilmiyor — bekleme ve hata ekranında gidilecek bölüm yok.
  final VoidCallback? onIcindekiler;

  /// Yapışkan başlık için: okunmakta olan bölümün adı buradan alınıyor.
  final List<DossierSection> bolumler;

  /// Okunan bölümün dizini. `null` ya da -1 ise çubukta ülke adı yazıyor.
  final ValueListenable<int>? aktif;

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
                child: _YapiskanBaslik(
                  ulke: baslik,
                  bolumler: bolumler,
                  tema: tema,
                  isEn: isEn,
                  aktif: aktif,
                ),
              ),
            ),
            // Düğme kaydırmadan bağımsız olarak hep görünür: on üç bölümlük
            // bir belgede içindekiler en çok sayfanın BAŞINDA gerekiyor —
            // okur neyi okuyacağına orada karar veriyor.
            if (onIcindekiler != null)
              IconButton(
                icon: const Icon(Icons.list_rounded, size: 22),
                color: tema.murekkep,
                tooltip: isEn ? 'Contents' : 'İçindekiler',
                onPressed: onIcindekiler,
              ),
          ],
        ),
      ),
    );
  }
}

/// Üst çubuktaki başlık: okunan bölümün adı, yoksa ülke adı.
///
/// **Neden bölüm adı.** Dosya on üç bölüm ve tek bir ekrandan uzun. Çubukta
/// sabit duran ülke adı okur zaten hangi ülkeyi okuduğunu bilirken hiçbir şey
/// söylemiyordu; asıl kaybolunan bilgi "kaçıncı bölümdeyim". Numara metnin
/// önünde (`03 · Gölgeler`) çünkü konumu veren o.
///
/// Yalnızca bu satır [ValueListenableBuilder] içinde: bölüm değiştiğinde
/// sayfanın kalanı değil bu metin yeniden çiziliyor.
class _YapiskanBaslik extends StatelessWidget {
  const _YapiskanBaslik({
    required this.ulke,
    required this.bolumler,
    required this.tema,
    required this.isEn,
    required this.aktif,
  });

  final String ulke;
  final List<DossierSection> bolumler;
  final DossierTheme tema;
  final bool isEn;
  final ValueListenable<int>? aktif;

  @override
  Widget build(BuildContext context) {
    final bildirici = aktif;
    if (bildirici == null || bolumler.isEmpty) return _duz(context, ulke);

    return ValueListenableBuilder<int>(
      valueListenable: bildirici,
      builder: (context, i, _) {
        if (i < 0 || i >= bolumler.length) return _duz(context, ulke);
        final b = bolumler[i];
        return Row(
          children: [
            Text(
              b.ordLabel,
              style: AppTypography.meta(context, color: tema.vurgu).copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(width: 8),
            // Ayraç yalnızca görsel; ekran okuyucu iki metni zaten ardışık
            // okuyor, araya "orta nokta" demesi gürültü olurdu.
            ExcludeSemantics(
              child: Text(
                '·',
                style: AppTypography.meta(context, color: tema.sessiz),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(child: _duz(context, b.title(isEn))),
          ],
        );
      },
    );
  }

  Widget _duz(BuildContext context, String metin) => Text(
    metin,
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    style: AppTypography.meta(
      context,
      color: tema.murekkep,
    ).copyWith(fontWeight: FontWeight.w700),
  );
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
