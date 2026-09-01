import 'dart:ui' show ImageFilter;

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
import '../widgets/diger_dosyalar.dart';
import '../widgets/dosya_haberleri_bolumu.dart';
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
  const CountryDossierScreen(
      {super.key, required this.slug, this.tur = 'ulke'});

  final String slug;

  /// `ulke` | `kurum`. Yalnızca ADRESİ belirliyor: `/ulke/<slug>` mi
  /// `/kurum/<slug>` mi. Sayfanın kendisi türe bakmıyor; ayrımı tema yapıyor
  /// ve tema zaten veriden geliyor.
  final String tur;

  @override
  ConsumerState<CountryDossierScreen> createState() =>
      _CountryDossierScreenState();
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
        final kaydi = _kaydirma.offset > 150.0;
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

  Widget _sayfa(CountryDossier dosya,
      {required bool isEn, required double olcek}) {
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
    // Kapak boyutu dinamik.

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
                // Kapaktan gövdeye geçiş bandı. Motifin gövde metninin
                // arkasında değil yalnızca geçişlerde durması tasarım kuralı.
                SliverToBoxAdapter(
                  child: PolderMotif(tema: tema, yukseklik: 48, opaklik: 0.08),
                ),
                if (video != null)
                  SliverToBoxAdapter(
                    child: _Oluk(
                      dikey: 0,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 24, bottom: 8),
                        child: DossierVideoPlayer(videoUrl: video),
                      ),
                    ),
                  ),

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
                    // Bant 88 px'ti ve motif %5 opaklıkta koyu zeminde
                    // görünmüyordu: 4, 8 ve 12. bölümlerden sonra sayfada
                    // sebebi anlaşılmayan bir karanlık şerit kalıyordu.
                    // Yükseklik yarıya indi, opaklık tasarim.json'daki kabul
                    // aralığının (%4–8) üst ucuna çıktı. Aynı "ara" işareti,
                    // ama artık görülüyor.
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        bolum,
                        PolderMotif(tema: tema, yukseklik: 48, opaklik: 0.08),
                      ],
                    );
                  },
                ),

                // VERİ NOTLARI PANELİ KALDIRILDI (kullanıcı kararı, 24 Ağustos
                // 2026). Hangi rakamın bulunamadığı bir üretim günlüğüdür,
                // okuma malzemesi değil; okurun ihtiyacı olan kayıt zaten
                // cümlenin yanındaki parantezde: "(… ikincil kaynaklardan.)"
                //
                // Panel VERİYİ BOŞALTARAK değil, KODDAN ÇIKARILARAK kaldırıldı:
                // boş dizi bırakmak her yeni dosyada tekrar dolmasına açık
                // kapı bırakırdı. Boşluk kayıtları _raw/ altında duruyor.
                SliverToBoxAdapter(
                  child:
                      _Kunye(kaynaklar: dosya.sources, tema: tema, isEn: isEn),
                ),
                // Dosya bitti, konu bitmedi: aynı konunun güncel haberleri.
                // Künyeden SONRA duruyor — okuma kaynaklarıyla kapanıyor,
                // sonra devamı geliyor. Eşleşme yoksa hiç çizilmiyor.
                SliverToBoxAdapter(
                  child: DosyaHaberleriBolumu(
                      slug: dosya.summary.slug, tema: tema, isEn: isEn),
                ),
                // Dizinin tamamı — İKİ DİZİ BİRDEN (kullanıcı kararı, 29
                // Ağustos 2026). Haberlerden sonra duruyor: önce bu konunun
                // bugünü, sonra okunacak öteki dosyalar.
                SliverToBoxAdapter(
                  child: DigerDosyalar(
                      acikSlug: dosya.summary.slug, tema: tema, isEn: isEn),
                ),
                SliverToBoxAdapter(
                  child: _Oluk(
                    dikey: 24,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: DossierShareBar(
                          ozet: dosya.summary, tema: tema, isEn: isEn),
                    ),
                  ),
                ),
                // Arşiv bağlantısı en sonda: on üç bölümü bitiren okuyucu,
                // dizinin devamı olduğunu ancak burada öğrenmeli. Yukarı
                // konsaydı okunmakta olan dosyadan çıkmaya davet ederdi.
                SliverToBoxAdapter(
                  child: _ArsivBaglantisi(
                    tema: tema,
                    isEn: isEn,
                    tur: dosya.summary.tur,
                  ),
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
  const _Oluk({required this.child, this.dikey = 0, this.genislik = 720});

  final Widget child;
  final double dikey;

  /// Varsayılan 720 — okuma genişliği. `veri` bölümlerinde grafikler bunu
  /// aşıyor (bkz. [_Bolum]); METİN hiçbir zaman aşmıyor. Geniş satır uzun
  /// okumada göz satır atlatıyor ve bu, bölüm türünden bağımsız olarak doğru.
  final double genislik;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: genislik),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: dikey),
          child: child,
        ),
      ),
    );
  }
}

/// Küçük harf aralıklı üst etiket — "ÜLKE DOSYASI · 01", "VERİ NOTLARI".
/// Kapaktaki ülke/kurum adı.
///
/// Ad KELİMESİNİN ORTASINDAN bölünmesin diye punto gerektiği kadar küçülüyor.
/// Kelimeler arası sarma serbest — "Birleşik Krallık" iki satıra inebilir ve
/// bu kompozisyonu bozmuyor. Bozan şey tek kelimelik bir adın son harflerinin
/// alt satıra düşmesiydi: masaüstünde 132 punto "Netherlands" 720 px'lik okuma
/// oluğunu birkaç piksel aşıyor ve "Netherland" + "s" gibi görünüyordu.
///
/// Bu yüzden ölçek adın TAMAMINA değil, EN UZUN KELİMESİNE bakarak
/// hesaplanıyor: tek kelimelik ad tek satıra sığacak kadar küçülüyor, iki
/// kelimelik ad tam puntosunu koruyup kelime arasından sarıyor.
class _KapakAdi extends StatelessWidget {
  const _KapakAdi({required this.ad, required this.renk});

  final String ad;
  final Color renk;

  @override
  Widget build(BuildContext context) {
    final stil = AppTypography.dossierCover(context, color: renk);

    return LayoutBuilder(
      builder: (context, kutu) {
        final genislik = kutu.maxWidth;
        if (!genislik.isFinite || genislik <= 0) return Text(ad, style: stil);

        final kelimeler = ad.trim().split(RegExp(r'\s+'));
        final enUzun = kelimeler.fold<String>(
          '',
          (a, b) => b.length > a.length ? b : a,
        );

        final olcer = TextPainter(
          text: TextSpan(text: enUzun, style: stil),
          textDirection: Directionality.of(context),
          maxLines: 1,
        )..layout();

        final olcek = olcer.width > genislik ? genislik / olcer.width : 1.0;
        if (olcek >= 1.0) return Text(ad, style: stil);

        final punto = (stil.fontSize ?? 56) * olcek;
        return Text(
          ad,
          style: stil.copyWith(
            fontSize: punto,
            // Harf aralığı puntoyla orantılı tanımlı (-0.022 em); punto
            // küçülünce onun da küçülmesi gerekiyor, yoksa negatif aralık
            // oransal olarak büyüyüp harfleri birbirine geçiriyor.
            letterSpacing: punto * -0.022,
          ),
        );
      },
    );
  }
}

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

    // Kapak kendi renklerini kullanıyor. Ülke dosyasında bu kopya gövdeyle
    // aynı; Kurum Dosyası'nda koyu mukavva kapak ile kağıt gövdeyi ayıran şey
    // tam olarak burası.
    final tema = this.tema.kapakTemasi;

    // Kapak EN AZ bir ekran boyunda.
    //
    // Bu sınır bir süre yoktu ve kapak içeriği kadar yükseliyordu: telefonda
    // ilk ekranda hem kapak hem gövdenin başı görünüyor, dosya sıradan bir
    // haber sayfasından ayrışmıyordu. Kapak tek başına bir ekran olduğunda okur
    // önce "bir şeyin başına geldiğini" görüyor, sonra okumaya başlıyor —
    // basılı bir dosyanın kapak sayfasının yaptığı iş.
    //
    // minHeight, sabit height DEĞİL. Yazı ölçeği okur tarafından büyütülebiliyor;
    // sabit yükseklikte 132 px'lik ad iki satıra çıktığında kapak taşardı.
    // Asgari sınırda kutu büyür, kompozisyon bozulmaz.
    return ConstrainedBox(
      key: const Key('dosya-kapak'),
      constraints: BoxConstraints(minHeight: olcu.size.height),
      child: Container(
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
                      ozet.seriEtiketi(isEn),
                      renk: tema.vurgu,
                    ),
                    // Adı alt üçte bire iten boşluk. Spacer DEĞİL: kapak bir
                    // SliverToBoxAdapter içinde, orada yükseklik sınırsız ve
                    // Spacer sonsuz yükseklik isteyip patlar. Ekran yüksekliğinin
                    // oranı olarak veriliyor; sabit piksel 560 px'lik pencerede
                    // adı ekrandan taşırıyordu.
                    SizedBox(
                        height: (olcu.size.height * 0.24).clamp(12.0, 220.0)),
                    // Ad tek satıra sığmayabilir ("Birleşik Krallık"): sarma
                    // serbest, kırpma yok. Dar telefonda iki satır olması
                    // sorun değil, ölçek zaten kompozisyonun kendisi.
                    _KapakAdi(ad: ozet.name(isEn), renk: tema.murekkep),
                    const SizedBox(height: 18),
                    // Tez cümlesi kapakta duruyor: dosyanın ne iddia ettiğini
                    // okur ilk ekranda öğrenmeli, on üç bölüm sonra değil.
                    ConstrainedBox(
                      // Tez satırı adın altında dar bir sütun: dev başlıkla
                      // aynı genişlikte akarsa ikisi tek blok gibi okunur.
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Text(
                        ozet.thesis(isEn),
                        style:
                            AppTypography.deck(context, color: tema.murekkep),
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
                    // Dizinin devamı KAPAKTA da duyuruluyor (kullanıcı kararı,
                    // 29 Ağustos 2026).
                    //
                    // Eskiden bu bağlantı yalnızca dosyanın SONUNDAYDI ve
                    // gerekçesi şuydu: "on üç bölümü bitiren okuyucu dizinin
                    // devamı olduğunu ancak burada öğrenmeli; yukarı konsaydı
                    // okunmakta olan dosyadan çıkmaya davet ederdi."
                    //
                    // Gerekçe tersine döndü: sonuna kadar okumayan okur —ki
                    // çoğunluk odur— başka dosya olduğunu HİÇ öğrenmiyordu.
                    // Bir davet, görünmeyen bir arşivden iyidir. Bağlantı
                    // kapağın en altında, tez cümlesinin ve rozetin ardında:
                    // ilk göze çarpan şey hâlâ dosyanın kendisi.
                    const SizedBox(height: 4),
                    _ArsivBaglantisi(
                      tema: tema,
                      isEn: isEn,
                      tur: ozet.tur,
                      oluk: false,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
        // Bölüm başlığı bloğu.
        //
        // Burada bir zamanlar iki numara vardı: arkada 132 px'lik soluk bir
        // "hayalet rakam" ve önde "03 / 13" sayacı. İkisi de aynı şeyi
        // söylüyordu ve hayalet rakam daha azını: sayaç konumu VE toplamı
        // veriyor, hayalet rakam yalnızca konumu. Üstelik %15 opaklıkta kendi
        // bloğunun dışına taşıyor, bölümler arasındaki boşluğu belirsiz
        // kılıyordu. Bilgi taşımayan yapısal süs kaldırıldı; sayaç kaldı.
        _Oluk(
          child: Padding(
            padding: const EdgeInsets.only(top: 32, bottom: 24),
            child: Column(
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
                    // "03 / 13" ilerleme sayacı. Okuyucu nerede olduğunu
                    // ve ne kadar kaldığını tek bakışta görür.
                    Text(
                      '${bolum.ordLabel} / ${toplamBolum.toString().padLeft(2, '0')}',
                      style: AppTypography.meta(context, color: tema.sessiz)
                          .copyWith(
                        fontWeight: FontWeight.w700,
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
          ),
        ),
        // Görsel başlıktan hemen sonra: bölümün açılışı. Metnin ardına
        // konsaydı okur konuyu okuduktan sonra görürdü; dergi dosyasında
        // görsel önce gelir, metin onu açıklar.
        if (bolum.gorsel != null)
          _BolumGorseli(gorsel: bolum.gorsel!, tema: tema, isEn: isEn),
        // Metin her zaman 720'de. Grafik, bölüm türü `veri` ise oluğu kırıyor:
        // ikili çubuk ve yığın grafikleri 720'de eksen etiketlerini sıkıştırıp
        // okunmaz hâle geliyordu. Metnin genişlemesi ise okumayı bozardı, o
        // yüzden ikisi ayrı oluklara alındı.
        _Oluk(
          child: Padding(
            padding: EdgeInsets.only(bottom: grafikler.isEmpty ? 24 : 8),
            child:
                DossierProse(govde: bolum.body(isEn), tema: tema, olcek: olcek),
          ),
        ),
        if (grafikler.isNotEmpty)
          _Oluk(
            genislik: bolum.genisVeri ? 1040 : 720,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final grafik in grafikler)
                    DossierChartView(chart: grafik, tema: tema, isEn: isEn),
                ],
              ),
            ),
          ),
        // Bölüm ayırıcısı.
        //
        // Önceki hâli 120 px'lik bir çizgiydi ve `cizgi` rengini %30 opaklıkla
        // kullanıyordu: `cizgi` zaten 1.52:1 ve bunun %30'u koyu zeminde hiç
        // görünmüyordu. Ayırıcı görünmeyince aradaki boşluk "bölüm bitti"
        // demiyor, sadece boşluk gibi duruyordu.
        //
        // Şimdi anlam taşıyan çizgi rengiyle (`cizgiVurgu`, 3.48:1) ve okuma
        // oluğunun genişliğinde. Boşluk azalmadı, işaretlendi.
        if (!sonuncu)
          _Oluk(
            child: Container(
              height: 1,
              color: tema.cizgiVurgu.withValues(alpha: 0.55),
              margin: const EdgeInsets.only(top: 4, bottom: 28),
            ),
          ),
      ],
    );
  }
}

// ─── Bölüm görseli ──────────────────────────────────────────────────────────

/// Bölümün konusunu gösteren görsel ve **zorunlu** atıf satırı.
///
/// Grafik veriyi anlatır, görsel konuyu gösterir; ikisi birbirinin yerine
/// geçmiyor. Dosya on üç bölüm boyunca yalnızca grafik gösteriyordu.
///
/// Atıf katlanabilir bir kutuda veya `alt` metninde saklı değil, görselin
/// hemen altında açıkta duruyor — veri notları panelindeki mantığın aynısı:
/// kaynağı gizlemek, kaynağı olmamaktan farksız.
class _BolumGorseli extends StatelessWidget {
  const _BolumGorseli({
    required this.gorsel,
    required this.tema,
    required this.isEn,
  });

  final DossierGorsel gorsel;
  final DossierTheme tema;
  final bool isEn;

  @override
  Widget build(BuildContext context) {
    return _Oluk(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kare değil, 4:3 pencere. Uydu görselleri kare geliyor ve tam
            // kare bir blok 720 px olukta ekranın tamamını yiyip metni
            // aşağı itiyordu; kırpma kompozisyonu koruyor.
            AspectRatio(
              aspectRatio: 4 / 3,
              child: ColoredBox(
                color: tema.yuzey,
                // NewsArticleImage DEĞİL: o, yüklenirken sonsuz bir shimmer
                // animasyonu çiziyor. İki sorun — (1) okuma sayfasının
                // ortasında nabız gibi atan bir blok, belge sakinliğini
                // bozuyor; (2) animasyon hiç durmadığı için widget testinde
                // pumpAndSettle sonsuza kadar bekliyor. Yer tutucu, yüzey
                // renginde sabit bir alan: görsel gelmezse bölüm sessizce
                // metinle devam eder.
                child: Image.network(
                  gorsel.url,
                  fit: BoxFit.cover,
                  semanticLabel: gorsel.alt(isEn),
                  loadingBuilder: (context, child, ilerleme) =>
                      ilerleme == null ? child : const SizedBox.expand(),
                  errorBuilder: (context, hata, iz) => const SizedBox.expand(),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              gorsel.alt(isEn),
              style: AppTypography.meta(context, color: tema.murekkep),
            ),
            const SizedBox(height: 4),
            Text(
              gorsel.atif,
              style: AppTypography.meta(context, color: tema.sessiz),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Veri notları ───────────────────────────────────────────────────────────

class _Kunye extends StatelessWidget {
  const _Kunye(
      {required this.kaynaklar, required this.tema, required this.isEn});

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

/// "Bütün kurum dosyaları →" — dosyanın sonundan arşive açılan tek kapı.
///
/// Metin ve hedef adres dizi türüne göre değişiyor. Sabit yazıldığında kurum
/// dosyasının sonunda "Bütün ülke dosyaları" çıkıyor ve okur yanlış arşive
/// gidiyordu.
class _ArsivBaglantisi extends StatelessWidget {
  const _ArsivBaglantisi({
    required this.tema,
    required this.isEn,
    required this.tur,
    this.oluk = true,
  });

  final DossierTheme tema;
  final bool isEn;
  final String tur;

  /// Kapakta `false`: kapak kendi iç boşluğunda duruyor, ikinci bir oluk
  /// bağlantıyı metnin hizasından kaydırıyordu.
  final bool oluk;

  bool get _kurum => tur == 'kurum';

  @override
  Widget build(BuildContext context) {
    final govde = Align(
        alignment: Alignment.centerLeft,
        child: InkWell(
          onTap: () => pushScreen(
            context,
            DossierIndexScreen(tur: _kurum ? 'kurum' : 'ulke'),
          ),
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
                    _kurum
                        ? (isEn
                            ? 'All institution dossiers'
                            : 'Bütün kurum dosyaları')
                        : (isEn
                            ? 'All country dossiers'
                            : 'Bütün ülke dosyaları'),
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
      );
    return oluk ? _Oluk(dikey: 20, child: govde) : govde;
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
      child: ClipRect(
        child: BackdropFilter(
          filter:
              ImageFilter.blur(sigmaX: kaydi ? 12 : 0, sigmaY: kaydi ? 12 : 0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            height: ust + kToolbarHeight,
            padding: EdgeInsets.only(top: ust, left: 4, right: 16),
            decoration: BoxDecoration(
              color: kaydi
                  ? tema.zemin.withValues(alpha: 0.75)
                  : Colors.transparent,
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
