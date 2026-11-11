// ignore_for_file: deprecated_member_use
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/story_item.dart';
import '../../data/story_analytics.dart';
import '../../data/story_constants.dart';
import '../../providers/story_providers.dart';
import '../widgets/story_image.dart';
import '../../../../core/theme/konu_renkleri.dart';
import '../../../../core/utils/turkce_metin.dart';
import '../widgets/sayan_rakam.dart';
import '../widgets/ozet_karti.dart';
import '../../data/tahmin_defteri.dart';
import '../widgets/tahmin_slayti.dart';
import '../../../../core/network/supabase_client.dart';

class StoryViewerScreen extends ConsumerStatefulWidget {
  final List<StoryGroup> storyGroups;
  final int initialGroupIndex;

  const StoryViewerScreen({
    super.key,
    required this.storyGroups,
    this.initialGroupIndex = 0,
  });

  @override
  ConsumerState<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends ConsumerState<StoryViewerScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  PageController _pageController = PageController();
  late int _currentGroupIndex;
  int _currentItemIndex = 0;

  late AnimationController _animController;

  /// Okuyucu parmağını basılı tuttuğu için mi durduk? Uygulama arka plandan
  /// döndüğünde yanlışlıkla devam ettirmemek için ayrı tutuyoruz.
  bool _heldDown = false;

  // ── Okuma hızına uyum (Ö9) ─────────────────────────────────────────────
  //
  // Slayt süresi metin uzunluğundan hesaplanıyor (5-7 sn) — doğru temel ama
  // okurlar aynı hızda okumuyor. İki sinyal var ve ikisi de bedava:
  //
  //   · Okur slaytı ELLE geçtiyse hızlı okuyor ya da ilgilenmiyor; sonraki
  //     slaytlar biraz kısalıyor.
  //   · Parmağını BASILI TUTUP okuduysa yavaş okuyor; slaytlar uzuyor.
  //
  // Oturum içinde kalıyor, cihaza yazılmıyor: okuma hızı günden güne değil
  // o anki bağlama göre değişiyor (otobüste başka, masa başında başka).
  double _hizCarpani = 1.0;

  /// Çarpanın sınırları. Dar tutuldu: 5 saniyelik bir slaytı 3,5'e indirmek
  /// metni okunmaz, 7,5'e çıkarmak sıkıcı yapıyor.
  static const double _hizEnAz = 0.78;
  static const double _hizEnCok = 1.35;

  /// Basılı tutma bundan kısa sürerse "okuma" sayılmıyor — parmağın ekrana
  /// değip kalkması da uzun basma olarak algılanabiliyor.
  static const Duration _okumaEsigi = Duration(milliseconds: 600);
  DateTime? _basiliBaslangic;

  void _hiziAyarla(double carpan) {
    final yeni = (_hizCarpani * carpan).clamp(_hizEnAz, _hizEnCok);
    if ((yeni - _hizCarpani).abs() < 0.001) return;
    _hizCarpani = yeni;
  }

  /// Arka plan görselinin hikaye boyunca kapanan yakınlaştırma payı.
  /// 0 yapılırsa hareket tamamen kalkar, kare sabit kalır.
  ///
  /// 0,05'ten indirildi. Bu pay bedava değil: dikey türev 1080 px genişliğinde
  /// ve iPhone 12 gibi 1170 px'lik bir ekranda zaten 1,08 kat büyütülüyor.
  /// Üstüne %5 binince toplam 1,14 kata çıkıyordu ve hikayenin ilk saniyeleri
  /// gözle görülür biçimde yumuşak açılıyordu. %2'de hareket hâlâ seçiliyor,
  /// büyütme payı 1,10 katta kalıyor.
  static const double _kenBurnsZoom = 0.02;

  static const String _productionOrigin = 'https://tarim-app-2026.web.app';

  // ── Masaüstü vitrini (Ö4) ──────────────────────────────────────────────
  //
  // Hikâye biçimi telefon için doğdu. 1440×900 bir pencerede aynı dikey
  // düzeni tam ekrana yaymak, içeriği sol alt köşede bırakıp tuvalin üçte
  // ikisini boş siyah olarak gösteriyordu (denetim, T6).
  //
  // Esnetmek yerine SAHNELEMEK: ortada 9:16 oranında tek bir çerçeve, iki
  // yanında kısmen görünen komşu kartlar, altında klavye ipucu. Boş kalan
  // tuval artık boş değil — komşuları göstermek için orada.
  static const double _vitrinEsigi = 900;
  static const double _cerceveOrani = 9 / 16;

  /// Çerçevenin yüksekliği: pencerenin %86'sı, 940 pikselde tavan.
  /// Tavan olmadan çok uzun bir pencerede kart devleşiyor ve 9:16 oranı
  /// ekranı yatayda taşırıyordu.
  double _cerceveYuksekligi(Size ekran) =>
      (ekran.height * 0.86).clamp(420.0, 940.0);

  double _cerceveGenisligi(Size ekran) {
    final h = _cerceveYuksekligi(ekran);
    // Yatayda da sığmalı: dar ama kısa bir pencerede oran korunurken
    // kart pencereden taşmasın.
    return (h * _cerceveOrani).clamp(260.0, ekran.width * 0.56);
  }

  bool _vitrinMi(Size ekran) => ekran.width >= _vitrinEsigi;

  /// `PageView`in görüntü payı — komşuların ne kadarının görüneceği.
  double _gorusPayi(Size ekran) => _vitrinMi(ekran)
      ? (_cerceveGenisligi(ekran) / ekran.width).clamp(0.2, 1.0)
      : 1.0;

  /// Denetleyici görüntü payına bağlı ve pay pencere ölçüsüyle değişiyor;
  /// pay değiştiğinde denetleyici YENİDEN KURULMAK zorunda (alan salt
  /// okunur). Açık sayfa korunuyor.
  double _kuruluPay = 1.0;

  /// Açık kartın çizim sınırı — paylaşım görüntüsü buradan alınıyor (T10).
  final GlobalKey _kartAnahtari = GlobalKey();

  // ── Tahmin slaytı (Ö5) ─────────────────────────────────────────────────
  //
  // Cevaplanan sorular cihazda tutuluyor: aynı soruyu ikinci kez sormak,
  // cevabı bilen okur için bilmece değil engel.
  Set<String> _cevaplanan = const <String>{};

  /// Bu oturumda verilen cevapların sonucu — slaytId -> (doğru mu, toplam, doğru).
  final Map<String, _TahminSonucu> _sonuclar = {};

  /// Açık slaytta cevaplanmamış bir soru var mı?
  ///
  /// Varsa sayaç DURUYOR: soru sorulup cevap beklenirken hikâyenin
  /// kendiliğinden ilerlemesi, okura düşünme fırsatı vermemek olurdu.
  bool get _soruBekliyor =>
      !_ozetteyiz &&
      _currentItem.tahminVar &&
      !_cevaplanan.contains(_currentItem.id);

  Future<void> _defteriYukle() async {
    final d = await TahminDefteri.yukle();
    if (!mounted) return;
    setState(() => _cevaplanan = d);
    // Defter geldiğinde açık slaytta bekleyen soru kalmadıysa sayaç
    // başlatılıyor; yükleme asenkron ve ilk kare ondan önce çiziliyor.
    if (!_soruBekliyor && !_heldDown) _animController.forward();
  }

  Future<void> _tahminiIsle(StoryItem slayt, int secim) async {
    final dogru = secim == slayt.tahminDogru;
    final defter = await TahminDefteri.isaretle(slayt.id);
    if (!mounted) return;

    setState(() {
      _cevaplanan = defter;
      _sonuclar[slayt.id] = _TahminSonucu(dogru: dogru, toplam: 0, bilen: 0);
    });
    // Cevap görüldü; sayaç buradan itibaren işliyor.
    if (!_heldDown) _animController.forward();

    // Toplu sonuç ARKA PLANDA: ağ beklenirse cevabın açılması gecikir ve
    // okur dokunduğunun işe yaramadığını sanır.
    try {
      final yanit = await ref
          .read(supabaseClientProvider)
          .rpc('hikaye_tahmin_kaydet', params: {
        'p_story_id': slayt.storyId,
        'p_slayt': int.tryParse(slayt.id.split('#').last) ?? 0,
        'p_dogru': dogru,
      });
      if (!mounted) return;
      final satir = (yanit is List && yanit.isNotEmpty) ? yanit.first : null;
      if (satir is Map) {
        setState(() {
          _sonuclar[slayt.id] = _TahminSonucu(
            dogru: dogru,
            toplam: (satir['toplam'] as num?)?.toInt() ?? 0,
            bilen: (satir['dogru'] as num?)?.toInt() ?? 0,
          );
        });
      }
    } catch (_) {
      // Sayaç yazılamazsa cevap yine açık kalıyor; yüzde gösterilmiyor.
    }
  }

  void _payiTazele(Size ekran) {
    final pay = _gorusPayi(ekran);
    if ((pay - _kuruluPay).abs() < 0.01) return;
    _kuruluPay = pay;
    final eski = _pageController;
    _pageController = PageController(
      initialPage: _currentGroupIndex,
      viewportFraction: pay,
    );
    // Eski denetleyici bu karede hâlâ bağlı; kareden sonra bırakılıyor.
    WidgetsBinding.instance.addPostFrameCallback((_) => eski.dispose());
  }

  /// Klavye: ok tuşlarıyla gezinme, boşlukla duraklatma, Esc ile kapatma.
  /// Masaüstünde fare tek giriş yolu olmamalı.
  KeyEventResult _klavye(FocusNode node, KeyEvent olay) {
    if (olay is! KeyDownEvent) return KeyEventResult.ignored;
    final k = olay.logicalKey;
    if (k == LogicalKeyboardKey.arrowRight) {
      _nextStory();
    } else if (k == LogicalKeyboardKey.arrowLeft) {
      _previousStory();
    } else if (k == LogicalKeyboardKey.escape) {
      Navigator.of(context).pop();
    } else if (k == LogicalKeyboardKey.space) {
      if (_animController.isAnimating) {
        _animController.stop();
        _heldDown = true;
      } else {
        _heldDown = false;
        _animController.forward();
      }
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  StoryGroup get _currentGroup => widget.storyGroups[_currentGroupIndex];

  /// Açık slayt. Özet slaytındayken grubun SON öğesine düşüyor: paylaşım ve
  /// "izlendi" işaretlemesi gibi işler yine gerçek bir slayta bağlı kalmalı.
  StoryItem get _currentItem =>
      _currentGroup.items[_currentItemIndex.clamp(0, _currentGroup.items.length - 1)];

  /// Şu an grubun özet kartında mıyız?
  bool get _ozetteyiz => _ozetVar(_currentGroup) &&
      _currentItemIndex >= _currentGroup.items.length;

  /// Grubun sonuna özet ("Rakamlarla") kartı konuyor mu?
  ///
  /// KONMUYOR — yayın kararı, 12 Kasım 2026. Her bölümün sonundaki özet
  /// slaytı istenmedi: okur hikâyeyi bitirip çıkmak isterken araya giren
  /// fazladan bir ekran oluyordu.
  ///
  /// Mekanizma tek noktadan kapatıldı; [_slaytSayisi], [_ozetteyiz] ve
  /// çizim dalı bu değere bağlı olduğu için hepsi birlikte susuyor.
  /// `ozet_karti.dart` ve çizim dalı yerinde bırakıldı: karar geri alınmak
  /// istenirse bu satır yeter.
  static bool _ozetVar(StoryGroup g) => false;

  /// Gruptaki toplam ekran sayısı — özet dahil.
  static int _slaytSayisi(StoryGroup g) =>
      g.items.length + (_ozetVar(g) ? 1 : 0);

  /// Özet kartının süresi. Normal slayttan uzun: okur burada dört beş
  /// satır tarıyor ve dokunacağı satırı seçiyor.
  static const Duration _ozetSuresi = Duration(seconds: 9);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _currentGroupIndex = widget.initialGroupIndex;
    _pageController = PageController(initialPage: _currentGroupIndex);

    _animController = AnimationController(
      vsync: this,
      duration: StoryRules.maxSlideDuration,
    );
    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _nextStory(auto: true);
      }
    });

    _defteriYukle();
    StoryAnalytics.opened(
      groupKey: _currentGroup.key,
      groupCount: widget.storyGroups.length,
    );
    _startStory();
    WidgetsBinding.instance.addPostFrameCallback((_) => _precacheNeighbours());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Sayaç arka planda da işlemeye devam ediyordu: telefonu cebine koyup
    // dönen okuyucu hikayeleri izlemeden atlamış oluyordu.
    if (state == AppLifecycleState.resumed) {
      if (!_heldDown && !_soruBekliyor && mounted) _animController.forward();
    } else {
      _animController.stop();
    }
  }

  /// Birazdan gösterilecek görselleri önden indirir.
  ///
  /// İKİ YÖNE bakıyor ve sıra önemli:
  ///
  /// 1. **Açık grubun kalan slaytları.** Eskiden yalnızca komşu grupların
  ///    İLK slaytı indiriliyordu; grup içinde ikinci, üçüncü slayta geçen
  ///    okur her seferinde sıfırdan bekliyordu. Oysa grup içi geçiş,
  ///    gruplar arası geçişten çok daha sık (6 Kasım 2026 denetimi).
  /// 2. **Komşu grupların ilk slaytı**, sağa/sola kaydırma için.
  ///
  /// Açık grup önce geliyor çünkü okurun bir sonraki hamlesi büyük
  /// ihtimalle o: hikâye kendiliğinden ilerliyor, kaydırmak için
  /// müdahale gerekiyor.
  void _precacheNeighbours() {
    if (!mounted) return;

    void al(StoryItem item) {
      precacheImage(
        storyBackgroundProvider(
          context,
          imageUrl: item.imageUrl,
          portraitUrl: item.portraitUrl,
        ),
        context,
      );
    }

    final acik = _currentGroup.items;
    for (var i = _currentItemIndex + 1; i < acik.length; i++) {
      al(acik[i]);
    }

    for (final int offset in const [1, -1, 2]) {
      final int i = _currentGroupIndex + offset;
      if (i < 0 || i >= widget.storyGroups.length) continue;
      final group = widget.storyGroups[i];
      if (group.items.isEmpty) continue;
      al(group.items.first);
    }
  }

  /// Slaytı başlatır: süreyi metin uzunluğundan hesaplar, izlendi defterine
  /// işler ve sayacı sıfırdan başlatır.
  void _startStory() {
    final item = _currentItem;
    // Grup içinde ilerledikçe ön yükleme yeniden hesaplanıyor; aksi hâlde
    // yalnızca açılışta bir kez çalışır ve uzun gruplarda sonu beklemede
    // kalırdı.
    WidgetsBinding.instance.addPostFrameCallback((_) => _precacheNeighbours());
    // Süre kaynak (Türkçe) metnin uzunluğundan hesaplanıyor; çeviriler benzer
    // uzunlukta ve bu sayede `Localizations` bağlamına ihtiyaç kalmıyor.
    if (_ozetteyiz) {
      // Özet kartı okuma hızı çarpanından ETKİLENMİYOR: süresi metinden
      // değil, taranacak satır sayısından geliyor.
      _animController.duration = _ozetSuresi;
      _animController.stop();
      _animController.reset();
      _animController.forward();
      return;
    }

    final taban = storySlideDuration(item.headline, item.statLabel);
    _animController.duration = Duration(
      milliseconds: (taban.inMilliseconds * _hizCarpani).round(),
    );
    _animController.stop();
    _animController.reset();
    // Cevaplanmamış soru varsa sayaç BAŞLAMIYOR; cevap verilince
    // `_tahminiIsle` başlatıyor.
    if (!_soruBekliyor) _animController.forward();
    ref.read(storySeenProvider.notifier).markSeen([item.id]);
  }

  void _nextStory({bool auto = false}) {
    // Elle geçildiyse okur bu hızı fazla yavaş buluyor demektir.
    // Özet kartından geçmek bu sinyali VERMİYOR: orada okumak değil
    // seçmek var.
    if (!auto && !_ozetteyiz) _hiziAyarla(0.92);
    final group = _currentGroup;
    if (_currentItemIndex < _slaytSayisi(group) - 1) {
      setState(() => _currentItemIndex++);
      _startStory();
      return;
    }

    if (auto) {
      StoryAnalytics.completed(
        groupKey: group.key,
        itemCount: group.items.length,
      );
    }

    if (_currentGroupIndex < widget.storyGroups.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  void _previousStory() {
    if (_currentItemIndex > 0) {
      setState(() => _currentItemIndex--);
      _startStory();
      return;
    }
    if (_currentGroupIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentGroupIndex = index;
      _currentItemIndex = 0;
    });
    _startStory();
    _precacheNeighbours();
  }

  void _onTapDown(TapDownDetails details) {
    _animController.stop();
  }

  void _onTapUp(TapUpDetails details) {
    final Size ekran = MediaQuery.of(context).size;
    final double dx = details.globalPosition.dx;

    if (!_vitrinMi(ekran)) {
      // Telefon: sol üçte bir geri, gerisi ileri.
      if (dx < ekran.width / 3) {
        _previousStory();
      } else {
        _nextStory();
      }
      return;
    }

    // Vitrinde kart pencerenin tamamını kaplamıyor. Pencerenin sol üçte
    // birini ölçüt almak, kartın DIŞINA yapılan bir dokunuşu "geri" sayıp
    // okurun komşu karta geçme niyetini tersine çeviriyordu.
    final double yari = _cerceveGenisligi(ekran) / 2;
    final double merkez = ekran.width / 2;
    if (dx < merkez - yari) {
      _previousStory();
    } else if (dx > merkez + yari) {
      _nextStory();
    } else if (dx < merkez - yari / 3) {
      // Kartın İÇİNDE sol şerit: geri.
      _previousStory();
    } else {
      _nextStory();
    }
  }

  /// Paylaşılan adres: dosya hikâyesinde dosyanın kendisi, haberde haber.
  String _shareUrl(StoryItem item) {
    final origin = kIsWeb ? Uri.base.origin : _productionOrigin;
    return '$origin${_hedef(item)}';
  }

  /// Slaytın gideceği uygulama içi adres.
  ///
  /// Hedef satırda yazılıysa o kullanılıyor; yazılı değilse eski davranış
  /// sürüyor ve haberin adresine gidiliyor. Kod hedefi yorumlamıyor — böylece
  /// yarın emtia veya hafta dosyası hikâyesi eklendiğinde burası değişmiyor.
  String _hedef(StoryItem item) =>
      item.dosyaHikayesi ? item.hedefYol : articlePath(item.articleId);

  /// Habere geçerken hikayeyi kapatıyoruz: eskiden ekran arkada açık kalıyor
  /// ve sayaç haberi okurken de işlemeye devam ediyordu.
  void _openArticle(StoryGroup group, StoryItem item) {
    StoryAnalytics.articleOpened(
      groupKey: group.key,
      articleId: item.articleId,
      slideIndex: _currentItemIndex,
    );
    final router = GoRouter.of(context);
    Navigator.of(context).pop();
    router.push(_hedef(item));
  }

  /// Açık kartın görüntüsünü PNG olarak yakalar.
  ///
  /// Sunucuda ikinci bir çizici yazmak yerine EKRANDAKİNİ almak: okurun
  /// paylaştığı şey gördüğünün birebir aynısı oluyor ve kart tasarımı
  /// değiştiğinde paylaşım görüntüsü kendiliğinden güncelleniyor. Ayrı bir
  /// çizici, ilk tasarım değişikliğinde sessizce eskirdi.
  ///
  /// Başarısızlıkta null: görüntü alınamazsa paylaşım metinle sürüyor.
  Future<Uint8List?> _kartiYakala() async {
    try {
      final nesne = _kartAnahtari.currentContext?.findRenderObject();
      if (nesne is! RenderRepaintBoundary) return null;
      // 2,5 kat: 1080 piksel genişliğinde bir kart ediyor — paylaşım
      // uygulamalarının beklediği ölçü. 3 kat bellekte dört katına
      // çıkıyor ve gözle fark edilmiyor.
      final goruntu = await nesne.toImage(pixelRatio: 2.5);
      final bayt = await goruntu.toByteData(format: ui.ImageByteFormat.png);
      goruntu.dispose();
      return bayt?.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }

  Future<void> _share(StoryGroup group, StoryItem item, bool isEn) async {
    _animController.stop();
    StoryAnalytics.shared(groupKey: group.key, articleId: item.articleId);

    final box = context.findRenderObject() as RenderBox?;
    final kutu =
        box != null ? box.localToGlobal(Offset.zero) & box.size : null;
    final text = '${item.headlineFor(isEn)}\n'
        '${item.bigStatValueFor(isEn)} · ${item.statLabelFor(isEn)}\n\n'
        '${_shareUrl(item)}';

    try {
      final png = await _kartiYakala();
      if (png != null) {
        // Dosya DİSKE yazılmıyor: `XFile.fromData` baytları doğrudan
        // veriyor ve web'de de çalışıyor. Geçici dosya yazmak web'de
        // `path_provider` gerektirirdi ve orada çalışmıyor.
        await Share.shareXFiles(
          [
            XFile.fromData(
              png,
              mimeType: 'image/png',
              name: 'tarim-portali-hikaye.png',
            ),
          ],
          text: text,
          sharePositionOrigin: kutu,
        );
      } else {
        await Share.share(text, sharePositionOrigin: kutu);
      }
    } catch (_) {
      // Görüntü paylaşımı desteklenmiyorsa metne düş; o da olmazsa
      // hikâye akmaya devam etsin.
      try {
        await Share.share(text, sharePositionOrigin: kutu);
      } catch (_) {}
    }
    if (mounted && !_heldDown) _animController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final ekran = MediaQuery.of(context).size;
    final vitrin = _vitrinMi(ekran);
    _payiTazele(ekran);

    final govde = GestureDetector(
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onLongPressStart: (_) {
            _heldDown = true;
            _basiliBaslangic = DateTime.now();
            _animController.stop();
          },
          onLongPressEnd: (_) {
            _heldDown = false;
            // Yeterince uzun tutulduysa okur metni okuyordu; sonraki
            // slaytlara biraz nefes veriliyor.
            final bas = _basiliBaslangic;
            if (bas != null &&
                DateTime.now().difference(bas) >= _okumaEsigi) {
              _hiziAyarla(1.12);
            }
            _basiliBaslangic = null;
            _animController.forward();
          },
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: widget.storyGroups.length,
            itemBuilder: (context, index) {
              final group = widget.storyGroups[index];
              final isCurrentGroup = index == _currentGroupIndex;
              final itemIndex = isCurrentGroup ? _currentItemIndex : 0;
              // Özet kartında gerçek bir slayt yok; zemin ve paylaşım için
              // grubun son öğesine düşülüyor.
              final bool ozet =
                  isCurrentGroup && itemIndex >= group.items.length;
              final item =
                  group.items[itemIndex.clamp(0, group.items.length - 1)];
              // Soru YALNIZCA açık kartta sorulabilir: komşu kartlar sessiz
              // önizleme ve oradaki bir şıkka dokunmak anlamsız olurdu.
              final bool soruAcik = isCurrentGroup &&
                  !ozet &&
                  item.tahminVar &&
                  !_cevaplanan.contains(item.id);
              final _TahminSonucu? sonuc = _sonuclar[item.id];

              final bool isEn =
                  Localizations.localeOf(context).languageCode == 'en';

              final sahne = Stack(
                fit: StackFit.expand,
                children: [
                  // Arka plan Görseli (Tam Ekran)
                  // Görsel, cihazın piksel yoğunluğuna göre boyutlandırılmış
                  // olarak Supabase dönüştürme uç noktasından gelir; ayrıntı
                  // için bkz. widgets/story_image.dart
                  AnimatedBuilder(
                    animation: _animController,
                    builder: (context, child) {
                      // Çok hafif bir "Ken Burns": kare 1.02'den 1.00'e iner,
                      // yani hikaye net kareyle biter.
                      final double t = isCurrentGroup
                          ? Curves.easeOutSine.transform(_animController.value)
                          : 0.0;
                      return Transform.scale(
                        scale: 1.0 + _kenBurnsZoom * (1 - t),
                        child: child,
                      );
                    },
                    child: StoryBackgroundImage(
                      imageUrl: item.imageUrl,
                      portraitUrl: item.portraitUrl,
                      onizleme: item.onizleme,
                    ),
                  ),

                  // Koyu Karartma (metin okunabilirliği için degrade perde)
                  // Ara duraklar bilinçli olarak sık: 3 duraklı bir degrade koyu
                  // fotoğraflarda 8-bit ekranlarda görünür bantlanma yapıyordu.
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.72),
                          Colors.black.withOpacity(0.38),
                          Colors.black.withOpacity(0.12),
                          Colors.transparent,
                          Colors.black.withOpacity(0.30),
                          Colors.black.withOpacity(0.68),
                          Colors.black.withOpacity(0.92),
                        ],
                        stops: const [0.0, 0.10, 0.22, 0.40, 0.62, 0.82, 1.0],
                      ),
                    ),
                  ),

                  // İçerik (Veri Gösterimi)
                  if (ozet)
                    SafeArea(
                      child: OzetKarti(
                        grup: group,
                        isEn: isEn,
                        renk: konuCipRengi(group.title),
                        ac: (s) => _openArticle(group, s),
                        paylas: () => _share(group, item, isEn),
                      ),
                    )
                  else
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Spacer(),

                          if (soruAcik)
                            // Kaydırılabilir: soru üç satıra çıkıp üç şık da
                            // uzun yazıldığında içerik kartı taşırıyordu —
                            // masaüstü çerçevesi 9:16 ve telefondan (9:19,5)
                            // daha kısa, yani asıl dar yer orası. Taşma
                            // yerine kaydırma, hiçbir şıkkı erişilemez
                            // bırakmıyor.
                            Flexible(
                              child: SingleChildScrollView(
                                child: TahminSlayti(
                                  slayt: item,
                                  isEn: isEn,
                                  renk: konuCipRengi(group.title),
                                  sec: (i) => _tahminiIsle(item, i),
                                ),
                              ),
                            )
                          else ...[

                          // Üst Başlık (Kategori) — T7.
                          //
                          // Üç şey değişti. (1) Zemin konunun rengi, sabit
                          // yeşil değil: çip artık hangi bölümde olduğunu
                          // söylüyor. (2) Punto 12'den 13'e, mürekkep koyu:
                          // parlak ton üzerinde beyaz yazı okunmuyordu.
                          // (3) Beliriş animasyonu KALDIRILDI — çip okurun
                          // nerede olduğunu söyleyen tek işaret ve ilk
                          // saniyede görünmez olması tam da en çok
                          // gerektiği anda yok olması demekti.
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: konuCipRengi(group.title),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              // Ham `toUpperCase()` DEĞİL (§39.5).
                              buyukHarf(item.superTitleFor(isEn), isEn),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                color: konuCipMurekkebi,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),

                          // Büyük İstatistik Değeri — Ö2.
                          //
                          // Eskiden `elasticOut` ile yaylanarak büyüyordu ama
                          // DEĞERİ baştan yazılıydı: hareket vardı, bilgi
                          // yoktu. Artık sıfırdan sayarak geliyor ve
                          // slaytın ilk %40'ında hedefe oturuyor. Yaylanma
                          // kaldırıldı: sayan bir rakam ayrıca zıplarsa iki
                          // hareket birbiriyle yarışıyor.
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: SayanRakam(
                              ham: item.bigStatValueFor(isEn),
                              ilerleme: isCurrentGroup
                                  ? _animController
                                  : const AlwaysStoppedAnimation<double>(1.0),
                              isEn: isEn,
                              style: GoogleFonts.outfit(
                                color: AppColors.wheat,
                                fontSize: 72,
                                height: 1.0,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // İstatistik Açıklaması
                          Text(
                            item.statLabelFor(isEn),
                            style: GoogleFonts.inter(
                              color: AppColors.wheat,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                          // Tahmin cevaplandıysa sonucu rakamın hemen
                          // altında duruyor — cevabın kendisiyle aynı
                          // bakışta okunsun diye.
                          if (sonuc != null)
                            TahminSonucu(
                              dogruBildi: sonuc.dogru,
                              toplam: sonuc.toplam,
                              dogru: sonuc.bilen,
                              isEn: isEn,
                            ),
                          const SizedBox(height: 24),

                          // Ana Başlık
                          Text(
                            item.headlineFor(isEn),
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 28,
                              height: 1.2,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Habere Git Butonu
                          GestureDetector(
                            onTap: () => _openArticle(group, item),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.5),
                                    width: 1),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      item.dosyaHikayesi
                                          ? (isEn
                                              ? 'Open Dossier'
                                              : 'Dosyayı Aç')
                                          : (isEn
                                              ? 'Read Article'
                                              : 'Haberi Oku'),
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.arrow_forward_ios,
                                        color: Colors.white, size: 14),
                                  ],
                                ),
                              ),
                          ),
                          const SizedBox(height: 40),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // Header (Progress bars + Profile)
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 10.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Ö8 — TEK SLAYTLIK grupta çubuk çizilmiyor.
                          // Aktif hikâyelerin çoğu tek slayt taşıyor ve
                          // ekranın tepesinde tek parça, hiç bölünmeyen bir
                          // çubuk "burada bir şey eksik" izlenimi veriyordu.
                          // Süreyi avatarın çevresindeki halka söylüyor.
                          if (_slaytSayisi(group) > 1)
                            Row(
                              children: List.generate(
                                _slaytSayisi(group),
                                (i) => Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 2.0),
                                    child: _buildProgressBar(
                                      isCurrentGroup: isCurrentGroup,
                                      itemIndex: i,
                                      currentIndex: itemIndex,
                                      // Özet segmentinin kendi slaytı yok;
                                      // son slaytın bayrağını devralıyor.
                                      slayt: group.items[
                                          i.clamp(0, group.items.length - 1)],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          SizedBox(height: _slaytSayisi(group) > 1 ? 12 : 4),
                          Row(
                            children: [
                              // Tek slaytta süre halkası avatarın çevresinde:
                              // bilgi kaybolmuyor, ekranın tepesi sessizleşiyor.
                              _AvatarHalkasi(
                                avatarUrl: group.avatarUrl,
                                onizleme: group.avatarOnizleme,
                                renk: konuCipRengi(group.title),
                                ilerleme: _slaytSayisi(group) > 1
                                    ? null
                                    : (isCurrentGroup ? _animController : null),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  group.titleFor(isEn),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.ios_share,
                                    color: Colors.white, size: 20),
                                tooltip: isEn ? 'Share' : 'Paylaş',
                                onPressed: () => _share(group, item, isEn),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close,
                                    color: Colors.white),
                                tooltip: isEn ? 'Close' : 'Kapat',
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );

              // Paylaşım görüntüsü AÇIK karttan alınıyor; sınır yalnızca
              // ona konuyor. Her sayfaya koymak, görünmeyen kartlar için de
              // ayrı bir çizim katmanı ayırmak olurdu.
              final sarili =
                  isCurrentGroup ? RepaintBoundary(key: _kartAnahtari, child: sahne) : sahne;

              if (!vitrin) return sarili;

              // Vitrinde her sayfa kendi çerçevesinde duruyor. Açık olmayan
              // kartlar KÜÇÜLTÜLÜP soluklaştırılıyor: komşunun orada olduğu
              // görünsün ama gözü açık kartla yarıştırmasın.
              final acik = index == _currentGroupIndex;
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 13),
                  child: AnimatedScale(
                    scale: acik ? 1.0 : 0.88,
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOutCubic,
                    child: AnimatedOpacity(
                      opacity: acik ? 1.0 : 0.45,
                      duration: const Duration(milliseconds: 260),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: acik
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.55),
                                    blurRadius: 42,
                                    offset: const Offset(0, 14),
                                  ),
                                ]
                              : const [],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: AspectRatio(
                            aspectRatio: _cerceveOrani,
                            child: sarili,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );

    // Aşağı kaydırarak kapatma TELEFON hareketi. Masaüstünde fare tekerleği
    // bu hareketi yanlışlıkla tetikliyor ve okur hikâyeyi kaydırmak isterken
    // kapatmış oluyor.
    final sarmal = vitrin
        ? govde
        : Dismissible(
            key: const Key('story_dismiss'),
            direction: DismissDirection.down,
            onDismissed: (_) => Navigator.of(context).pop(),
            child: govde,
          );

    return Scaffold(
      backgroundColor: vitrin ? const Color(0xFF07090A) : Colors.black,
      body: Focus(
        autofocus: true,
        onKeyEvent: _klavye,
        child: vitrin ? _vitrin(ekran, sarmal) : sarmal,
      ),
    );
  }

  /// Masaüstü sahnesi: ortada çerçeve, üstte kapatma, altta klavye ipucu.
  Widget _vitrin(Size ekran, Widget govde) {
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    return Stack(
      children: [
        // Sahne zemini: açık karttan türetilmiş çok koyu bir ışık havuzu.
        // Düz siyah, kartı havada asılı bırakıyordu.
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 0.9,
                colors: [
                  konuCipRengi(_currentGroup.title).withValues(alpha: 0.13),
                  const Color(0xFF07090A),
                ],
              ),
            ),
          ),
        ),
        Center(
          child: SizedBox(height: _cerceveYuksekligi(ekran), child: govde),
        ),
        Positioned(
          top: 18,
          right: 22,
          child: IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white70),
            tooltip: isEn ? 'Close (Esc)' : 'Kapat (Esc)',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 16,
          child: Center(
            child: Text(
              isEn
                  ? '← →  switch · space  pause · esc  close'
                  : '← →  geçiş · boşluk  duraklat · esc  kapat',
              style: GoogleFonts.inter(
                color: Colors.white.withValues(alpha: 0.38),
                fontSize: 12,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Ö6 — segment BİLGİ TAŞIYOR.
  ///
  /// Eskiden çubuklar yalnızca "kaç slayt kaldı" diyordu. Artık dolan kısım
  /// o slaytın konu rengiyle boyanıyor ve son dakika slaytının segmenti
  /// altında ince bir kırmızı çizgi taşıyor: okur grubu açmadan hangi
  /// slaytın acil olduğunu görüyor.
  Widget _buildProgressBar({
    required bool isCurrentGroup,
    required int itemIndex,
    required int currentIndex,
    required StoryItem slayt,
  }) {
    final Color dolu = konuCipRengi(_currentGroup.title);

    Widget govde;
    if (!isCurrentGroup || itemIndex > currentIndex) {
      govde = _bar(Colors.white.withOpacity(0.28));
    } else if (itemIndex < currentIndex) {
      govde = _bar(dolu);
    } else {
      govde = AnimatedBuilder(
        animation: _animController,
        builder: (context, child) {
          return Stack(
            children: [
              _bar(Colors.white.withOpacity(0.28)),
              FractionallySizedBox(
                widthFactor: _animController.value,
                child: _bar(dolu),
              ),
            ],
          );
        },
      );
    }

    if (!slayt.isBreaking) return govde;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        govde,
        const SizedBox(height: 2),
        Container(
          height: 2,
          decoration: BoxDecoration(
            color: const Color(0xFFE94057),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ],
    );
  }

  Widget _bar(Color color) => Container(
        height: 3,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      );
}

/// Avatar ve çevresindeki süre halkası.
///
/// [ilerleme] verilmezse halka çizilmiyor — çok slaytlı gruplarda süreyi
/// üstteki çubuk zaten söylüyor ve iki ayrı yerde göstermek gürültü olur.
class _AvatarHalkasi extends StatelessWidget {
  const _AvatarHalkasi({
    required this.avatarUrl,
    required this.onizleme,
    required this.renk,
    required this.ilerleme,
  });

  final String avatarUrl;
  final String onizleme;
  final Color renk;
  final Animation<double>? ilerleme;

  static const double _olcu = 36;
  static const double _halka = 2.5;

  @override
  Widget build(BuildContext context) {
    final avatar = ClipOval(
      child: StoryThumbImage(
          url: avatarUrl, size: _olcu, onizleme: onizleme),
    );
    final anim = ilerleme;
    if (anim == null) return avatar;

    return SizedBox(
      width: _olcu + _halka * 4,
      height: _olcu + _halka * 4,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: anim,
            builder: (context, _) => SizedBox(
              width: _olcu + _halka * 3,
              height: _olcu + _halka * 3,
              child: CircularProgressIndicator(
                value: anim.value,
                strokeWidth: _halka,
                backgroundColor: Colors.white.withOpacity(0.22),
                valueColor: AlwaysStoppedAnimation<Color>(renk),
              ),
            ),
          ),
          avatar,
        ],
      ),
    );
  }
}


/// Bir tahmin sorusunun sonucu.
///
/// [toplam] 0 ise sunucu sayacı henüz gelmedi (ya da gelemedi); o durumda
/// yalnız doğru/yanlış gösteriliyor, yüzde gösterilmiyor.
@immutable
class _TahminSonucu {
  final bool dogru;
  final int toplam;
  final int bilen;

  const _TahminSonucu({
    required this.dogru,
    required this.toplam,
    required this.bilen,
  });
}
