import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dark_mode.dart';
import '../../../../core/utils/fade_page_route.dart';
import '../../../home/data/models/news_article.dart';
import '../../../home/presentation/screens/article_detail_screen.dart';
import '../../../home/providers/home_providers.dart';
import '../../domain/yayin_denetimi.dart';
import '../widgets/denetim_serisi.dart';
import '../widgets/inceleme_karti.dart';

// ══════════════════════════════════════════════════════════════════════════
//  Onay kuyruğu — yayın kararının verildiği ekran
// ──────────────────────────────────────────────────────────────────────────
//  Eskiden bu kuyruk istatistik sekmesinin ORTASINDA, iki istatistik
//  bloğunun arasında duruyordu. Panele giren kişi kaç haberin kararını
//  beklediğini ekranı bulup aşağı kaydırmadan öğrenemiyordu. Artık kendi
//  sekmesi ve sekmede canlı bir sayaç var.
//
//  Beş şey değişti:
//
//  1. KAYNAK TARİHİ. Kart yalnızca başlık, kaynak ve iki satır özet
//     gösteriyordu. `published_at` tam bu iş için tutuluyor — haberin
//     kaynakta yayımlandığı gün. Bugün girenle üç gün önce yayımlanmış
//     olan aynı görünüyordu.
//
//  2. TOPLU ONAY. Yalnızca toplu red vardı. Günde ~39 haberin kabul
//     edilenleri tek tek tıklanıyordu.
//
//  3. SIRALAMA VE SÜZME. Tek sıralama `created_at desc`; kaynağa, konuya
//     ya da bayatlığa göre süzme yoktu.
//
//  4. TEMBEL LİSTE. Kartların tamamı tek seferde kuruluyordu.
//
//  5. GERÇEK ÖNİZLEME. "Nasıl görünecek" sorusu cevapsızdı; ham HTML okumak
//     bunu cevaplamıyor. `/haber/:id` rotası `extra` ile gelen haberi yayın
//     durumuna BAKMADAN açıyor, yani yeni ekran yazmadan çözülüyor.
// ══════════════════════════════════════════════════════════════════════════

/// Sekme rozetini besleyen bekleyen sayısı.
///
/// Akış yüklenmediyse ya da düştüyse 0: rozet yokluğu "bilmiyorum" demek,
/// yanlış bir sayı yazmaktan iyi.
final bekleyenSayisiProvider = Provider<int>((ref) {
  return ref.watch(pendingArticlesProvider).maybeWhen(
        data: (liste) => liste.length,
        orElse: () => 0,
      );
});

/// Haberin kaynakta yayımlanmasından bu yana geçen tam gün.
///
/// `published_at` bir tarih (saat yok), o yüzden karşılaştırma da gün
/// üzerinden yapılıyor; saatli bir fark "0,8 gün" gibi anlamsız sonuç
/// verirdi.
int? bayatlikGunu(NewsArticle a, {DateTime? simdi}) {
  final y = a.publishedAt;
  if (y == null) return null;
  final bugun = simdi ?? DateTime.now();
  final g1 = DateTime(y.year, y.month, y.day);
  final g2 = DateTime(bugun.year, bugun.month, bugun.day);
  final fark = g2.difference(g1).inDays;
  return fark < 0 ? 0 : fark;
}

enum _Gorunum { deste, liste }

enum _Siralama { yeniOnce, eskiOnce, bayatOnce, skorOnce }

extension on _Siralama {
  String get etiket => switch (this) {
        _Siralama.yeniOnce => 'Hatta en yeni',
        _Siralama.eskiOnce => 'Hatta en eski',
        _Siralama.bayatOnce => 'En bayat kaynak',
        _Siralama.skorOnce => 'Manşet skoru',
      };
}

class OnayKuyruguEkrani extends ConsumerStatefulWidget {
  const OnayKuyruguEkrani({super.key});

  @override
  ConsumerState<OnayKuyruguEkrani> createState() => _OnayKuyruguEkraniState();
}

class _OnayKuyruguEkraniState extends ConsumerState<OnayKuyruguEkrani> {
  final Set<String> _secili = <String>{};
  String? _acikInceleme;
  bool _islemde = false;

  /// Çalışma biçimi (kullanıcı kararı: "ikisi birden, düğmeyle geçiş").
  ///
  /// DESTE varsayılan: ekranda tek haber durur, karar verilince sıradaki
  /// gelir. Kaydırma yok, dağılma yok — günde 20-40 haber için en hızlısı.
  /// LİSTE toplu tarama için: hangi haberler geldi, neyi toplu reddedeceğim.
  _Gorunum _gorunum = _Gorunum.deste;

  /// Destede kaçıncı haberdeyiz.
  int _sira = 0;

  /// Denetim şeridi açık mı (haber kimliğine göre).
  String? _acikDenetim;

  _Siralama _siralama = _Siralama.yeniOnce;
  String? _kaynak;
  String? _konu;
  String? _bolge;

  bool get isDark => appIsDark;
  Color get _metin => isDark ? Colors.white : Colors.black;
  Color get _soluk => isDark ? Colors.grey[400]! : Colors.grey[700]!;

  /// COP31 bölümünün vurgu rengi — bölüm widget'ındakiyle aynı iki ton.
  Color get _cop31Renk =>
      isDark ? const Color(0xFF57C9B0) : const Color(0xFF0E5C52);

  // ── Süzme ve sıralama ────────────────────────────────────────────────────

  List<NewsArticle> _suz(List<NewsArticle> ham) {
    final liste = ham.where((a) {
      if (_kaynak != null && (a.sourceName ?? '') != _kaynak) return false;
      if (_konu != null && (a.topic ?? '') != _konu) return false;
      if (_bolge != null && (a.region ?? '') != _bolge) return false;
      return true;
    }).toList();

    switch (_siralama) {
      case _Siralama.yeniOnce:
        liste.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case _Siralama.eskiOnce:
        liste.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      case _Siralama.bayatOnce:
        // Tarihi OLMAYAN en sona: "bilinmiyor" bir bayatlık derecesi değil
        // ve listenin başını tutarsa asıl bayat haberleri gizler.
        liste.sort((a, b) {
          final x = bayatlikGunu(a), y = bayatlikGunu(b);
          if (x == null && y == null) return 0;
          if (x == null) return 1;
          if (y == null) return -1;
          return y.compareTo(x);
        });
      case _Siralama.skorOnce:
        liste.sort((a, b) => (b.heroScore ?? -1).compareTo(a.heroScore ?? -1));
    }
    return liste;
  }

  List<String> _degerler(
          List<NewsArticle> ham, String? Function(NewsArticle) al) =>
      (ham.map(al).whereType<String>().where((s) => s.trim().isNotEmpty).toSet()
            ..remove(''))
          .toList()
        ..sort();

  // ── Çizim ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final pendingAsync = ref.watch(pendingArticlesProvider);

    return pendingAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded,
                  size: 40, color: Colors.red.shade700),
              const SizedBox(height: 12),
              Text('Kuyruk yüklenemedi.',
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700, color: _metin)),
              const SizedBox(height: 6),
              Text('$e',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 12.5, color: _soluk)),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => ref.invalidate(pendingArticlesProvider),
                child: const Text('Yeniden dene'),
              ),
            ],
          ),
        ),
      ),
      data: (ham) {
        if (ham.isEmpty) return _kuyrukBitti();

        final liste = _suz(ham);
        // Süzgeç değiştiyse görünmeyen bir haber seçili kalmasın: "3 seçili"
        // deyip ekranda 1 haber görünmesi, toplu işlemde sürpriz üretir.
        _secili.removeWhere((id) => !liste.any((a) => a.id == id));

        if (liste.isEmpty) {
          // Kuyrukta haber var ama süzgeç hepsini eledi. "Kuyruk boş"
          // demek yanlış olurdu — sorun süzgeçte.
          return Column(children: [
            _ustCubuk(ham, liste),
            Expanded(
              child: Center(
                child: Text('Süzgece uyan haber yok.',
                    style: GoogleFonts.inter(fontSize: 14, color: _soluk)),
              ),
            ),
          ]);
        }

        if (_sira >= liste.length) _sira = liste.length - 1;
        if (_sira < 0) _sira = 0;

        return Column(
          children: [
            _ustCubuk(ham, liste),
            Expanded(
              child: _gorunum == _Gorunum.deste
                  ? _deste(context, liste)
                  : _listeGorunumu(context, liste),
            ),
          ],
        );
      },
    );
  }

  // ── Deste: tek haber, tam ekran ─────────────────────────────────────────
  //
  // Kullanıcı kararı. Masaüstünde ekran ikiye bölünüyor: solda karar ve
  // denetimler, sağda okurun göreceği sayfanın TA KENDİSİ. Önizleme için
  // sayfa değiştirip geri dönmek gerekmiyor — "nasıl görünecek" sorusu
  // kararın verildiği anda, aynı ekranda cevaplanıyor.
  //
  // Telefonda bölme yok (yan yana iki sütun 375 pikselde ikisini birden
  // okunmaz yapar); önizleme "Önizle" düğmesiyle tam sayfa açılıyor.

  Widget _deste(BuildContext context, List<NewsArticle> liste) {
    final genislik = MediaQuery.of(context).size.width;
    final bolunmus = genislik >= 1000;
    final article = liste[_sira];

    final kararSutunu = SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
          bolunmus ? 24 : 16, 4, bolunmus ? 20 : 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _desteBasligi(liste),
          const SizedBox(height: 12),
          _kart(context, article),
        ],
      ),
    );

    if (!bolunmus) return kararSutunu;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Karar sütunu sabit genişlikte: 520'den geniş olunca satırlar
        // okuma oluğunu aşıyor, dar olunca düğmeler alt alta sarıyor.
        SizedBox(width: 520, child: kararSutunu),
        const VerticalDivider(width: 1),
        Expanded(child: _canliOnizleme(article)),
      ],
    );
  }

  Widget _desteBasligi(List<NewsArticle> liste) {
    return Row(
      children: [
        IconButton(
          tooltip: 'Önceki',
          onPressed: _sira > 0 ? () => setState(() => _sira--) : null,
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        Expanded(
          child: Text(
            '${_sira + 1} / ${liste.length}',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
                fontSize: 13, fontWeight: FontWeight.w700, color: _soluk),
          ),
        ),
        IconButton(
          tooltip: 'Sonraki',
          onPressed: _sira < liste.length - 1
              ? () => setState(() => _sira++)
              : null,
          icon: const Icon(Icons.chevron_right_rounded),
        ),
      ],
    );
  }

  /// Sağ sütun: haberin okur gözüyle hâli.
  ///
  /// Kuyruk akışı gövdeyi çekmiyor (dar sütun kümesi), o yüzden tam satır
  /// burada ayrıca alınıyor. Sağlayıcı önbellekli: aynı habere dönüldüğünde
  /// ağa çıkılmıyor.
  Widget _canliOnizleme(NewsArticle article) {
    final tam = ref.watch(articleByIdProvider(article.id));
    return tam.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Önizleme yüklenemedi: $e',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 12.5, color: _soluk)),
        ),
      ),
      data: (h) => h == null
          ? Center(
              child: Text('Haber bulunamadı.',
                  style: GoogleFonts.inter(color: _soluk)))
          : ClipRect(
              // Önizleme GERÇEK okuyucu ekranı — ayrı bir "temsilî" görünüm
              // değil. Yayınlanınca ne görünecekse burada o görünüyor.
              child: IgnorePointer(
                // Dokunmalar yutuluyor: sağdaki önizlemeye basıp yanlışlıkla
                // başka bir habere gitmek, karar ekranını kaybettirirdi.
                child: ArticleDetailScreen(article: h),
              ),
            ),
    );
  }

  // ── Liste görünümü: toplu tarama ────────────────────────────────────────
  //
  // Kartlar deste görünümündekinden çok daha küçük: bir ekranda 8-10 haber
  // görünüyor. Amaç karar vermek değil, NE GELDİĞİNİ görmek ve toplu red
  // yapmak. Ayrıntı isteyince haber destede açılıyor.

  Widget _listeGorunumu(BuildContext context, List<NewsArticle> liste) {
    final dar = MediaQuery.of(context).size.width < 600;
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(dar ? 12 : 24, 4, dar ? 12 : 24, 48),
      itemCount: liste.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) => _listeSatiri(liste[i], i),
    );
  }

  Widget _listeSatiri(NewsArticle a, int i) {
    final secili = _secili.contains(a.id);
    final bulgular = haberiDenetle(a, govdeDenetle: false);
    final agir = bulgular.any((b) => b.agir);
    final gun = bayatlikGunu(a);

    return InkWell(
      onTap: () => setState(() {
        _sira = i;
        _gorunum = _Gorunum.deste;
      }),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.fromLTRB(4, 8, 12, 8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkGreen : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: secili ? Colors.red.shade300 : AppColors.wheat),
        ),
        child: Row(
          children: [
            Checkbox(
              value: secili,
              onChanged: _islemde
                  ? null
                  : (v) => setState(() {
                        if (v == true) {
                          _secili.add(a.id);
                        } else {
                          _secili.remove(a.id);
                        }
                      }),
            ),
            if (a.thumbImageUrl != null || a.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.network(
                  a.thumbImageUrl ?? a.imageUrl!,
                  width: 44,
                  height: 44,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox(width: 44),
                ),
              )
            else
              Icon(Icons.image_not_supported_outlined,
                  size: 22, color: _soluk),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(a.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: _metin)),
                  const SizedBox(height: 2),
                  Text(
                    [
                      a.sourceName ?? '—',
                      if (gun != null && gun >= 2) '$gun gün',
                      if (a.scheduledAt != null) 'programlı',
                    ].join(' · '),
                    style: GoogleFonts.inter(fontSize: 11.5, color: _soluk),
                  ),
                ],
              ),
            ),
            if (bulgular.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(
                  agir
                      ? Icons.error_rounded
                      : Icons.info_outline_rounded,
                  size: 17,
                  color: agir
                      ? Colors.red.shade600
                      : Colors.orange.shade700,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Kuyruk bittiğinde: günün özeti ve bekleyen işler ────────────────────

  Widget _kuyrukBitti() {
    final s = ref.watch(panelSayaclariProvider).valueOrNull ?? const {};
    int al(String k) => (s[k] as num?)?.toInt() ?? 0;

    final isler = <String>[
      if (al('kapaksiz') > 0) '${al('kapaksiz')} yayındaki haberde kapak yok',
      if (al('hikaye_eksik') > 0)
        '${al('hikaye_eksik')} haberde hikâye türevi eksik',
      if (al('zamanlanmis') > 0) '${al('zamanlanmis')} haber programlı',
    ];

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline_rounded,
                size: 44, color: AppColors.primaryGreen),
            const SizedBox(height: 14),
            Text('Kuyruk boş',
                style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: _metin)),
            const SizedBox(height: 6),
            Text(
              s.isEmpty
                  ? 'Onay bekleyen haber yok.'
                  : 'Bugün ${al('bugun_gelen')} haber geldi, '
                      '${al('bugun_yayinlanan')} tanesi yayına girdi.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 14, color: _soluk),
            ),
            if (isler.isNotEmpty) ...[
              const SizedBox(height: 22),
              Container(
                constraints: const BoxConstraints(maxWidth: 420),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : const Color(0xFFF6F6F4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Bekleyen işler',
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: _metin)),
                    const SizedBox(height: 8),
                    ...isler.map((x) => Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('· ',
                                  style: GoogleFonts.inter(color: _soluk)),
                              Expanded(
                                child: Text(x,
                                    style: GoogleFonts.inter(
                                        fontSize: 13, color: _soluk)),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Üst çubuk: sayaç · sıralama · süzgeçler · toplu işlem ───────────────

  Widget _ustCubuk(List<NewsArticle> ham, List<NewsArticle> liste) {
    final hepsiSecili = liste.isNotEmpty && _secili.length == liste.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // ESNEK (15 Kasım 2026): metin `Expanded` içinde değildi ve
              // sağındaki düğmeyle birlikte dar ekranda satırı taşırıyordu.
              // `Spacer` taşmayı engellemiyor — boşluk ancak artan yer varsa
              // iş görür.
              Expanded(
                child: Text(
                  liste.length == ham.length
                      ? '${ham.length} haber karar bekliyor'
                      : '${liste.length} / ${ham.length} haber',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: _metin),
                ),
              ),
              // GÖRÜNÜM DÜĞMESİ (kullanıcı kararı: "ikisi birden").
              // Deste karar vermek, liste toplu bakmak için.
              IconButton(
                tooltip: _gorunum == _Gorunum.deste
                    ? 'Liste görünümü'
                    : 'Deste görünümü',
                onPressed: () => setState(() {
                  _gorunum = _gorunum == _Gorunum.deste
                      ? _Gorunum.liste
                      : _Gorunum.deste;
                }),
                icon: Icon(_gorunum == _Gorunum.deste
                    ? Icons.view_list_rounded
                    : Icons.view_agenda_rounded),
              ),
              IconButton(
                tooltip: 'Kuyruğu tazele',
                onPressed: _islemde
                    ? null
                    : () => ref.invalidate(pendingArticlesProvider),
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          _programSeridi(),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _siralamaSecici(),
              _suzgec(
                etiket: 'Kaynak',
                deger: _kaynak,
                secenekler: _degerler(ham, (a) => a.sourceName),
                sec: (v) => setState(() => _kaynak = v),
              ),
              _suzgec(
                etiket: 'Konu',
                deger: _konu,
                secenekler: _degerler(ham, (a) => a.topic),
                sec: (v) => setState(() => _konu = v),
              ),
              _suzgec(
                etiket: 'Bölge',
                deger: _bolge,
                secenekler: _degerler(ham, (a) => a.region),
                sec: (v) => setState(() => _bolge = v),
              ),
              if (_kaynak != null || _konu != null || _bolge != null)
                TextButton.icon(
                  onPressed: () => setState(() {
                    _kaynak = null;
                    _konu = null;
                    _bolge = null;
                  }),
                  icon: const Icon(Icons.filter_alt_off_rounded, size: 18),
                  label: const Text('Süzgeçleri temizle'),
                ),
            ],
          ),
          const Divider(height: 28),
          // Dar ekranda düğmeler alta sarıyor: tek satıra sığdırmaya
          // çalışmak hem taşırıyor hem de dokunma hedeflerini daraltıyordu.
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 6,
            children: [
              Checkbox(
                value: hepsiSecili,
                onChanged: _islemde
                    ? null
                    : (v) => setState(() {
                          _secili.clear();
                          if (v == true) {
                            _secili.addAll(liste.map((a) => a.id));
                          }
                        }),
              ),
              Text(
                _secili.isEmpty
                    ? 'Görünenlerin tümünü seç'
                    : '${_secili.length} haber seçili',
                style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey[300] : Colors.grey[800]),
              ),
              const SizedBox(width: 8),
              if (_secili.isNotEmpty) ...[
                TextButton.icon(
                  onPressed: _islemde ? null : () => _topluReddet(liste),
                  icon: const Icon(Icons.playlist_remove_rounded,
                      color: Colors.red, size: 20),
                  label: Text('Toplu red',
                      style: GoogleFonts.inter(
                          color: Colors.red, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: _islemde ? null : () => _topluOnayla(liste),
                  icon: const Icon(Icons.playlist_add_check_rounded, size: 20),
                  label: Text('Toplu onay',
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                ),
              ],
            ],
          ),
          if (_islemde) ...[
            const SizedBox(height: 10),
            const LinearProgressIndicator(minHeight: 2),
          ],
        ],
      ),
    );
  }

  /// Programlanmış haberler şeridi (kullanıcı kararı: kuyruğun üstünde).
  ///
  /// Kapalıyken tek satır. Açılınca saatleriyle listeleniyor. Kuyruk
  /// akışını bozmuyor: programlı haber kuyrukta da duruyor, burası yalnız
  /// "ne zaman ne çıkacak" sorusunu tek bakışta cevaplıyor.
  Widget _programSeridi() {
    final liste = ref.watch(zamanlanmisHaberlerProvider).valueOrNull;
    if (liste == null || liste.isEmpty) return const SizedBox.shrink();

    final renk = isDark ? const Color(0xFF57C9B0) : const Color(0xFF0E5C52);
    final kenar = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
      side: BorderSide(color: renk.withValues(alpha: 0.4)),
    );

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 12),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          shape: kenar,
          collapsedShape: kenar,
          backgroundColor: renk.withValues(alpha: isDark ? 0.10 : 0.06),
          collapsedBackgroundColor:
              renk.withValues(alpha: isDark ? 0.10 : 0.06),
          leading: Icon(Icons.event_available_rounded, size: 19, color: renk),
          title: Text(
            '${liste.length} haber programlı',
            style: GoogleFonts.inter(
                fontSize: 13, fontWeight: FontWeight.w700, color: renk),
          ),
          children: liste.map((a) {
            final z = a.scheduledAt?.toLocal();
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 92,
                    child: Text(
                      z == null
                          ? '—'
                          : '${z.day} ${_ayKisa(z.month)} '
                              '${z.hour.toString().padLeft(2, '0')}:'
                              '${z.minute.toString().padLeft(2, '0')}',
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: renk),
                    ),
                  ),
                  Expanded(
                    child: Text(a.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                            fontSize: 12.5, color: _metin)),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _siralamaSecici() => DropdownButton<_Siralama>(
        value: _siralama,
        underline: const SizedBox.shrink(),
        borderRadius: BorderRadius.circular(10),
        icon: const Icon(Icons.sort_rounded, size: 18),
        items: [
          for (final s in _Siralama.values)
            DropdownMenuItem(
              value: s,
              child: Text(s.etiket,
                  style: GoogleFonts.inter(fontSize: 13, color: _metin)),
            ),
        ],
        onChanged: _islemde
            ? null
            : (v) => setState(() => _siralama = v ?? _siralama),
      );

  Widget _suzgec({
    required String etiket,
    required String? deger,
    required List<String> secenekler,
    required void Function(String?) sec,
  }) {
    // Tek değer varsa süzgeç bir şey ayırt etmiyor; çubuğu kalabalıklaştırmaya
    // değmez.
    if (secenekler.length < 2) return const SizedBox.shrink();
    return DropdownButton<String?>(
      value: deger,
      hint: Text(etiket,
          style: GoogleFonts.inter(fontSize: 13, color: _soluk)),
      underline: const SizedBox.shrink(),
      borderRadius: BorderRadius.circular(10),
      items: [
        DropdownMenuItem<String?>(
          value: null,
          child: Text('$etiket: hepsi',
              style: GoogleFonts.inter(fontSize: 13, color: _soluk)),
        ),
        for (final s in secenekler)
          DropdownMenuItem<String?>(
            value: s,
            child: Text(s,
                style: GoogleFonts.inter(fontSize: 13, color: _metin)),
          ),
      ],
      onChanged: _islemde ? null : sec,
    );
  }

  // ── Kart ─────────────────────────────────────────────────────────────────

  Widget _kart(BuildContext context, NewsArticle article) {
    final secili = _secili.contains(article.id);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkGreen : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: secili ? Colors.red.shade300 : AppColors.wheat),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // DENETİM ÖNCE. Bir sorun varsa yönetici onu başlığı okumadan
          // görüyor; sorun yoksa burada hiçbir şey çizilmiyor (temiz
          // haberde yeşil rozet bile yok — her haberde görünen bir işaret
          // bir süre sonra görülmez oluyor).
          _denetimSeridi(article),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: secili,
                onChanged: _islemde
                    ? null
                    : (v) => setState(() {
                          if (v == true) {
                            _secili.add(article.id);
                          } else {
                            _secili.remove(article.id);
                          }
                        }),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _metin),
                    ),
                    const SizedBox(height: 6),
                    _kunye(article),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            article.summary ?? '',
            style: GoogleFonts.inter(fontSize: 14, color: _soluk),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          // COP31 kararı KARAR OLARAK soruluyor, düğme kalabalığının arasına
          // karışan bir seçenek olarak değil.
          //
          // Otomatik atama denendi ve bırakıldı (12 Kasım 2026): yargı
          // "zirvede söylendi" ile "zirveden söz edildi" ayrımını tutarlı
          // yapamıyordu. Hat artık hiçbir haberi kendiliğinden işaretlemiyor;
          // bölüme ne girerse buradan giriyor.
          //
          // Satır yalnızca bölüm açıkken var; 25 Kasım'dan sonra kuyruk
          // kendiliğinden sadeleşiyor.
          if (ozelBolumAktif()) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.fromLTRB(12, 2, 6, 2),
              decoration: BoxDecoration(
                color: _cop31Renk.withValues(alpha: isDark ? 0.16 : 0.08),
                borderRadius: BorderRadius.circular(10),
                border:
                    Border.all(color: _cop31Renk.withValues(alpha: 0.38)),
              ),
              child: Row(
                children: [
                  Icon(Icons.eco_rounded, size: 18, color: _cop31Renk),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Bu haber COP31 özel bölümüne gitsin mi?',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _cop31Renk,
                      ),
                    ),
                  ),
                  Text(
                    article.ozelBolum == kOzelBolum ? 'Evet' : 'Hayır',
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: article.ozelBolum == kOzelBolum
                          ? _cop31Renk
                          : _soluk,
                    ),
                  ),
                  Switch(
                    value: article.ozelBolum == kOzelBolum,
                    activeThumbColor: _cop31Renk,
                    onChanged: _islemde
                        ? null
                        : (_) => _cop31Degistir(article),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
          _yayinKararlari(article),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 8,
            runSpacing: 8,
            children: [
              TextButton.icon(
                onPressed: () => setState(() {
                  _acikInceleme =
                      _acikInceleme == article.id ? null : article.id;
                }),
                icon: Icon(
                    _acikInceleme == article.id
                        ? Icons.expand_less_rounded
                        : Icons.fact_check_outlined,
                    size: 20),
                label: Text(
                    _acikInceleme == article.id ? 'İncelemeyi kapat' : 'İncele',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              ),
              TextButton.icon(
                onPressed: () => _onizle(article),
                icon: const Icon(Icons.visibility_outlined, size: 20),
                label: Text('Önizle',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              ),
              // ZAMANLA (madde 20). Yayın anı = onay anı olmak zorunda
              // değil artık: sabah hazırlanan haber öğlene, ambargolu
              // duyuru saatine bırakılabiliyor.
              TextButton.icon(
                onPressed: _islemde ? null : () => _zamanla(article),
                icon: Icon(
                    article.scheduledAt == null
                        ? Icons.schedule_rounded
                        : Icons.event_available_rounded,
                    size: 20),
                label: Text(article.scheduledAt == null ? 'Zamanla' : 'Programlı',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              ),
              TextButton.icon(
                onPressed: _islemde ? null : () => _tekReddet(article),
                icon: const Icon(Icons.delete_outline,
                    color: Colors.red, size: 20),
                label: Text('Reddet',
                    style: GoogleFonts.inter(
                        color: Colors.red, fontWeight: FontWeight.bold)),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _islemde ? null : () => _tekOnayla(article),
                icon: const Icon(Icons.check, size: 20),
                label: Text('Onayla',
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          if (_acikInceleme == article.id) ...[
            const SizedBox(height: 14),
            _inceleme(article),
          ],
        ],
      ),
    );
  }

  // ── Denetim ─────────────────────────────────────────────────────────────

  /// Haberin denetim bulguları.
  ///
  /// Gövdeye bağlı kurallar yalnız TAM SATIR elde olduğunda çalışıyor.
  /// Kuyruk akışı gövdeyi çekmiyor; gövdesi olmayan bir kaydı "gövdesi
  /// kısa" diye işaretlemek her haberde yanlış uyarı üretirdi.
  ///
  /// Mükerrer denetimi yayındaki listeden besleniyor — ek sorgu yok.
  List<DenetimBulgusu> _bulgular(NewsArticle article) {
    final tam = ref.watch(articleByIdProvider(article.id)).valueOrNull;
    final yayinda = ref.watch(latestArticlesProvider).valueOrNull ?? const [];
    return haberiDenetle(
      tam ?? article,
      govdeDenetle: tam != null,
      yayindakiBasliklar: yayinda.map((a) => a.title),
      yayindakiAdresler: yayinda
          .map((a) => (a.sourceUrl ?? '').trim())
          .where((s) => s.isNotEmpty)
          .toSet(),
    );
  }

  Widget _denetimSeridi(NewsArticle article) {
    final bulgular = _bulgular(article);
    if (bulgular.isEmpty) return const SizedBox.shrink();
    // Kullanıcı kararı: "sakin, ama sorun varsa kendiliğinden açılsın."
    // Ağır bulgu varsa şerit açık doğuyor; hafif uyarıda kapalı duruyor.
    final acik = _acikDenetim == article.id ||
        (_acikDenetim == null && bulgular.any((b) => b.agir));
    return DenetimSeridi(
      bulgular: bulgular,
      isDark: isDark,
      acikMi: acik,
      acKapa: () => setState(
          () => _acikDenetim = _acikDenetim == article.id ? '' : article.id),
    );
  }

  // ── Yayın kararları: manşet adayı · son dakika ──────────────────────────

  Widget _yayinKararlari(NewsArticle a) {
    return Wrap(
      spacing: 10,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // MANŞET ADAYI (kullanıcı kararı: "hızlı işaret + ayrı sekmede
        // sıralama"). Burada yalnız aday işaretleniyor; sıra Hero
        // sekmesinde veriliyor. `is_hero` bir kilit değil, skoru çarpan bir
        // itki — yani işaretlemek haberi zorla manşete koymuyor.
        _kararCipi(
          ikon: Icons.star_rounded,
          etiket: 'Manşet adayı',
          acik: a.isHero == true,
          renk: const Color(0xFFB8860B),
          degistir: () => _mansetAdayi(a),
        ),
        // SON DAKİKA (kullanıcı kararı: "açıkça sorulsun"). Varsayılan
        // kapalı. Açmak onay istiyor: yayınlanınca bütün cihazlara anlık
        // bildirim gidiyor ve geri alınamıyor.
        _kararCipi(
          ikon: Icons.notifications_active_rounded,
          etiket: 'Son dakika',
          acik: a.isBreaking == true,
          renk: Colors.red.shade700,
          degistir: () => _sonDakika(a),
        ),
      ],
    );
  }

  Widget _kararCipi({
    required IconData ikon,
    required String etiket,
    required bool acik,
    required Color renk,
    required VoidCallback degistir,
  }) {
    return InkWell(
      onTap: _islemde ? null : degistir,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        // Dokunma hedefi 44: telefonda daha küçüğü parmakla ıskalanıyor.
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: acik ? renk.withValues(alpha: 0.14) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: acik
                  ? renk.withValues(alpha: 0.6)
                  : (isDark ? Colors.white24 : Colors.black26)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(ikon, size: 17, color: acik ? renk : _soluk),
            const SizedBox(width: 7),
            Text(etiket,
                style: GoogleFonts.inter(
                    fontSize: 12.5,
                    fontWeight: acik ? FontWeight.w800 : FontWeight.w600,
                    color: acik ? renk : _soluk)),
          ],
        ),
      ),
    );
  }

  Future<void> _mansetAdayi(NewsArticle a) async {
    final yeni = !(a.isHero == true);
    setState(() => _islemde = true);
    final ok = await ref.read(homeRepositoryProvider).alanlariGuncelle(a.id, {
      'is_hero': yeni,
      // Manşet itkisi sabitleme anından itibaren sönüyor; işaretlenen an
      // yazılmazsa haber `created_at`ten sayılır ve eski bir haber
      // işaretlendiğinde itki hiç çalışmaz.
      if (yeni) 'hero_pinned_at': DateTime.now().toUtc().toIso8601String(),
    });
    _tazele();
    _bildir(ok
        ? (yeni
            ? 'Manşet adayı işaretlendi. Sırayı Hero sekmesinden ver.'
            : 'Manşet adaylığı kaldırıldı.')
        : 'Yazılamadı — yetki yok ya da haber bulunamadı.');
  }

  Future<void> _sonDakika(NewsArticle a) async {
    final yeni = !(a.isBreaking == true);
    if (yeni) {
      final onay = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Son dakika bildirimi',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          content: Text(
            'Bu haber yayına girdiği anda uygulamayı kurmuş BÜTÜN '
            'kullanıcılara anlık bildirim gidecek.\n\n'
            'Gönderilen bildirim geri alınamaz.',
            style: GoogleFonts.inter(),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Vazgeç')),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Son dakika yap'),
            ),
          ],
        ),
      );
      if (onay != true || !mounted) return;
    }
    setState(() => _islemde = true);
    final ok = await ref
        .read(homeRepositoryProvider)
        .alanlariGuncelle(a.id, {'is_breaking': yeni});
    _tazele();
    _bildir(ok
        ? (yeni
            ? 'Son dakika işaretlendi. Yayınlanınca bildirim gidecek.'
            : 'Son dakika işareti kaldırıldı.')
        : 'Yazılamadı — yetki yok ya da haber bulunamadı.');
  }

  /// İnceleme paneli — tam satır gelene kadar ÇİZİLMİYOR.
  ///
  /// Kuyruk akışı dar bir sütun listesi çekiyor, panel ise gövde metnini,
  /// çeviriyi, doğrulama verisini ve alıntıları gösteriyor. Eksik nesneyle
  /// çizmek "haberin içi boş" demek oluyordu ve moderatör dolu bir haberi
  /// boş sanıp reddedebiliyordu. Gerekçenin tamamı [articleByIdProvider]'da.
  Widget _inceleme(NewsArticle article) {
    const hata = 'Haberin içeriği getirilemedi. '
        'Onay vermeden önce yeniden deneyin.';
    return ref.watch(articleByIdProvider(article.id)).when(
          loading: () => _incelemeDurumu('Haberin tamamı getiriliyor…'),
          error: (_, __) => _incelemeDurumu(hata, yeniden: article.id),
          data: (tam) => tam == null
              ? _incelemeDurumu(hata, yeniden: article.id)
              : IncelemeKarti(
                  article: tam,
                  isDark: isDark,
                  onDegisti: () {
                    // Panel kendi yazdığı değişikliği göremezse moderatör
                    // aynı düzeltmeyi ikinci kez yapmaya çalışıyor.
                    ref.invalidate(articleByIdProvider(article.id));
                    _tazele();
                  }),
        );
  }

  Widget _incelemeDurumu(String mesaj, {String? yeniden}) {
    final kirmizi = yeniden != null;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B22) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: kirmizi
                ? Colors.red.shade700.withValues(alpha: 0.45)
                : (isDark
                    ? Colors.white10
                    : Colors.black.withValues(alpha: 0.08))),
      ),
      child: Row(children: [
        if (kirmizi)
          Icon(Icons.cloud_off_rounded, size: 16, color: Colors.red.shade700)
        else
          const SizedBox(
              width: 15,
              height: 15,
              child: CircularProgressIndicator(strokeWidth: 2)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(mesaj,
              style: GoogleFonts.inter(
                  fontSize: 12.5,
                  color: kirmizi ? Colors.red.shade700 : _soluk)),
        ),
        if (kirmizi)
          TextButton(
            onPressed: () => ref.invalidate(articleByIdProvider(yeniden)),
            child: const Text('Yeniden dene'),
          ),
      ]),
    );
  }

  /// Kaynak · kaynak tarihi · bayatlık · konu · bölge.
  Widget _kunye(NewsArticle a) {
    final gun = bayatlikGunu(a);
    final parcalar = <Widget>[];

    void yaz(String metin, {Color? renk, bool kalin = false}) {
      parcalar.add(Text(
        metin,
        style: GoogleFonts.inter(
          fontSize: 12,
          color: renk ?? _soluk,
          fontWeight: kalin ? FontWeight.w700 : FontWeight.w400,
        ),
      ));
    }

    final kaynak = (a.sourceName ?? '').trim();
    if (kaynak.isNotEmpty) yaz(kaynak);

    if (a.publishedAt != null) {
      yaz('Kaynak tarihi: ${_gunYaz(a.publishedAt!)}');
    } else {
      // Tarihsizlik de bir bilgi: eski kayıtların ~%3'ünde alan boş ve
      // bayatlık hiç ölçülemiyor. Sessizce atlanırsa moderatör tarihin
      // kontrol edildiğini sanır.
      yaz('Kaynak tarihi yok', renk: Colors.orange.shade800);
    }

    if (gun != null && gun >= 2) {
      // Eşik 2: hat her sabah çalışıyor, yani 0–1 gün normal akış. İki gün
      // ve üstü gerçekten geç kalmış demek.
      yaz(
        gun >= 7 ? '$gun gün bayat' : '$gun gün önce',
        renk: gun >= 7 ? Colors.red.shade700 : Colors.orange.shade800,
        kalin: true,
      );
    }

    final konu = (a.topic ?? '').trim();
    if (konu.isNotEmpty) yaz(konu);
    final bolge = (a.region ?? '').trim();
    if (bolge.isNotEmpty) yaz(bolge);
    if (a.heroScore != null) yaz('skor ${a.heroScore}');

    // Programlı haber kuyrukta duruyor ama kararı verilmiş: ne zaman
    // çıkacağı kartın üstünde yazmalı, yoksa "neden hâlâ burada?" sorusu
    // doğuyor.
    final z = a.scheduledAt?.toLocal();
    if (z != null) {
      yaz(
        '⏱ ${z.day} ${_ayKisa(z.month)} '
        '${z.hour.toString().padLeft(2, '0')}:'
        '${z.minute.toString().padLeft(2, '0')} yayına girecek',
        renk: const Color(0xFF0E5C52),
        kalin: true,
      );
    }

    return Wrap(spacing: 12, runSpacing: 4, children: parcalar);
  }

  String _gunYaz(DateTime d) {
    const aylar = [
      'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz',
      'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara',
    ];
    return '${d.day} ${aylar[d.month - 1]} ${d.year}';
  }

  // ── İşlemler ─────────────────────────────────────────────────────────────

  /// Gerçek okuyucu görünümünde önizleme.
  ///
  /// Yeni ekran yazmaya gerek yok: `/haber/:id` rotası `extra` ile gelen
  /// haberi yayın durumuna BAKMADAN açıyor, yani kuyruktaki haber de tam
  /// olarak yayınlanınca görüneceği gibi çiziliyor.
  ///
  /// **Kuyruk nesnesi DEĞİL, tam satır gönderiliyor.** Kuyruk akışı ad ad
  /// sütun çekiyor ve `content` o listede yok; detay ekranı gövdeyi
  /// doğrudan `widget.article.content`ten okuyor. Web'de bu fark
  /// görünmüyordu: "Önizle" URL'i değiştirdiği için `extra` kayboluyor ve
  /// rota [articleByIdProvider] ile tam satırı kendisi çekiyor. Ama
  /// Android/iOS'ta `extra` hayatta kalıyor — önizleme orada da boş
  /// gövdeyle açılırdı. Sağlayıcı önbellekli: panel zaten açıksa bu
  /// çağrı ağa çıkmıyor.
  Future<void> _onizle(NewsArticle article) async {
    final tam = await ref.read(articleByIdProvider(article.id).future);
    if (!mounted) return;
    pushScreen(context, ArticleDetailScreen(article: tam ?? article));
  }

  static const _aylar = [
    'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz',
    'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara',
  ];

  String _ayKisa(int ay) => _aylar[ay - 1];

  /// Haberi ileri bir saate programlar (madde 20).
  ///
  /// MATERIAL TAKVİM VE SAAT SEÇİCİSİ KULLANILMIYOR. Ölçüldü: `showDatePicker`
  /// ve `showTimePicker` birlikte paketi 52 KB (gzip) büyütüyor ve
  /// `deploy.sh`'deki 1.800.000 baytlık tavanı aştırıyor. Yerine gün ve saat
  /// için hazır seçenekler kondu — haber odasında zaten ihtiyaç bu: "yarın
  /// sabah", "bu akşam". Keyfi bir takvim tarihi seçmek değil.
  ///
  /// Haber kuyrukta `reviewing` olarak kalıyor; vakti gelince Firebase'deki
  /// `zamanlanmisYayin` fonksiyonu yayına alıyor. Yani program kurmak bir
  /// karar, yayınlamak değil — fikir değişirse "Programı kaldır" ile geri
  /// alınıyor.
  Future<void> _zamanla(NewsArticle article) async {
    final simdi = DateTime.now();
    final mevcut = article.scheduledAt?.toLocal();

    if (mevcut != null) {
      // Zaten programlı: kaldırma seçeneği de sunuluyor.
      final karar = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Programlı yayın',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          content: Text(
            '"${article.title}"\n\n'
            '${mevcut.day} ${_ayKisa(mevcut.month)} ${mevcut.year}, '
            '${mevcut.hour.toString().padLeft(2, '0')}:'
            '${mevcut.minute.toString().padLeft(2, '0')} '
            'tarihinde yayına girecek.',
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(ctx).pop('kaldir'),
                child: const Text('Programı kaldır',
                    style: TextStyle(color: Colors.red))),
            TextButton(
                onPressed: () => Navigator.of(ctx).pop('degistir'),
                child: const Text('Saati değiştir')),
            TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Kapat')),
          ],
        ),
      );
      if (karar == null || !mounted) return;
      if (karar == 'kaldir') {
        await _zamaniYaz(article, null);
        return;
      }
    }

    final zaman = await showDialog<DateTime>(
      context: context,
      builder: (ctx) => _ZamanSecici(simdi: simdi, mevcut: mevcut),
    );
    if (zaman == null || !mounted) return;
    if (zaman.isBefore(simdi)) {
      _bildir('Geçmiş bir saate program kurulamaz.');
      return;
    }
    await _zamaniYaz(article, zaman);
  }

  Future<void> _zamaniYaz(NewsArticle article, DateTime? zaman) async {
    setState(() => _islemde = true);
    final ok = await ref
        .read(homeRepositoryProvider)
        .yayinZamaniAyarla(article.id, zaman);
    if (!mounted) return;
    _tazele();
    ref.invalidate(panelSayaclariProvider);
    _bildir(ok
        ? (zaman == null
            ? 'Program kaldırıldı. Haber kuyrukta bekliyor.'
            : 'Programlandı: ${zaman.day} ${_ayKisa(zaman.month)} '
                '${zaman.hour.toString().padLeft(2, '0')}:'
                '${zaman.minute.toString().padLeft(2, '0')}')
        : 'Program yazılamadı: yetki yok ya da haber bulunamadı.');
  }

  Future<void> _tekOnayla(NewsArticle article) async {
    // AĞIR BULGULAR BİR KEZ SORULUYOR (kullanıcı kararı).
    //
    // Hafif uyarı yayını hiç durdurmuyor; ağır bulgu — kapak yok, özet boş,
    // aynı haber zaten yayında — "yine de?" diye soruyor. Soruda bulguların
    // KENDİSİ yazıyor: ne olduğunu görmeden verilen onay, onay değildir.
    //
    // Üçüncü bir "engelle" basamağı bilerek yok. Ekran yöneticinin yerine
    // karar vermiyor, gördüğünü söylüyor.
    final agirlar = _bulgular(article).where((b) => b.agir).toList();
    if (agirlar.isNotEmpty) {
      final devam = await agirUyariOnayi(context, agirlar);
      if (!devam || !mounted) return;
    }

    setState(() => _islemde = true);
    final sayi =
        await ref.read(homeRepositoryProvider).topluOnayla([article.id]);
    // Tek haberde de GERÇEKLEŞEN sayıya bakılıyor: RLS kaydı süzdüğünde
    // `approveArticle` sessizce `true` dönüyordu.
    _bildir(sayi == 1
        ? 'Haber yayına alındı.'
        : 'Yayına alınamadı — yetki yok ya da kayıt yazılamadı.');
    _secili.remove(article.id);
    _tazele();
  }

  Future<void> _topluOnayla(List<NewsArticle> liste) async {
    final hedef =
        liste.where((a) => _secili.contains(a.id)).toList(growable: false);
    if (hedef.isEmpty) return;

    // Onay SORULUYOR. Red geri alınabilir bir durum değişikliği; onay ise
    // haberi canlı siteye çıkarıyor. Tek tıkla 39 haber yayınlamak, yanlış
    // basıldığında okurun gördüğü bir sonuç üretir.
    final onay = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Toplu onay',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Text(
          '${hedef.length} haber YAYINA alınacak ve siteye çıkacak.',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Vazgeç')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Yayına al',
                style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
    if (onay != true) return;

    setState(() => _islemde = true);
    final sayi = await ref
        .read(homeRepositoryProvider)
        .topluOnayla(hedef.map((a) => a.id).toList());
    _secili.clear();
    _bildir(sayi == hedef.length
        ? '$sayi haber yayına alındı.'
        : '$sayi / ${hedef.length} haber yayına alındı; kalanlar kuyrukta.');
    _tazele();
  }

  Future<void> _tekReddet(NewsArticle article) async {
    setState(() => _islemde = true);
    final ok = await ref.read(homeRepositoryProvider).haberiReddet(
          id: article.id,
          title: article.title,
          sourceUrl: article.sourceUrl,
          sourceName: article.sourceName,
          lastStatus: article.status,
        );
    _secili.remove(article.id);
    if (ok) {
      _bildir('Haber silindi. Geri alınamaz.');
    } else {
      _bildir('Reddetme başarısız — yetki yok ya da kayıt silinemedi.');
    }
    _tazele();
  }

  /// Haberi COP31 bölümüne alır ya da çıkarır.
  ///
  /// `topic`/`region`'a DOKUNMUYOR: haber Türkiye/Dünya kimliğini koruyor,
  /// bölümün ömrü dolunca oraya geri akıyor.
  Future<void> _cop31Degistir(NewsArticle article) async {
    final icindeydi = article.ozelBolum == kOzelBolum;
    setState(() => _islemde = true);
    final ok = await ref
        .read(homeRepositoryProvider)
        .ozelBolumAyarla(article.id, icindeydi ? null : kOzelBolum);
    if (ok) {
      _bildir(icindeydi
          ? 'Haber COP31 bölümünden çıkarıldı.'
          : 'Haber COP31 bölümüne alındı.');
      // Bölüm kendi sorgusuyla besleniyor; ortak listeyi tazelemek yetmiyor.
      ref.invalidate(ozelBolumAkisiProvider);
    } else {
      _bildir('Değiştirilemedi — yetki yok ya da kayıt yazılamadı.');
    }
    _tazele();
  }

  Future<void> _topluReddet(List<NewsArticle> liste) async {
    final hedef =
        liste.where((a) => _secili.contains(a.id)).toList(growable: false);
    if (hedef.isEmpty) return;

    final onay = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Toplu red',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Text(
          '${hedef.length} haber KALICI OLARAK SİLİNECEK. Geri alınamaz. '
          'Adresleri kaydedilir, aynı haber tekrar kuyruğa düşmez.',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Vazgeç')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Reddet', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (onay != true) return;

    setState(() => _islemde = true);
    final sayi = await ref.read(homeRepositoryProvider).topluReddet(
          hedef
              .map((a) => <String, String?>{
                    'id': a.id,
                    'title': a.title,
                    'source_url': a.sourceUrl,
                    'source_name': a.sourceName,
                    'last_status': a.status,
                  })
              .toList(),
        );
    _secili.clear();
    _bildir(sayi == hedef.length
        ? '$sayi haber silindi. Geri alınamaz.'
        : '$sayi / ${hedef.length} haber silindi; kalanlar kuyrukta.');
    _tazele();
  }

  // `_bildirGeriAlinabilir` kaldırıldı (11 Kas 2026): red artık satırı
  // siliyor, geri alınacak bir kayıt kalmıyor. "Geri al" düğmesini bırakmak
  // çalışmayan bir söz vermek olurdu.

  void _bildir(String mesaj) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mesaj)));
  }

  void _tazele() {
    if (!mounted) return;
    setState(() => _islemde = false);
    ref.invalidate(pendingArticlesProvider);
    ref.invalidate(latestArticlesProvider);
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  Zaman seçici — gün ve saat, hazır seçeneklerle
// ──────────────────────────────────────────────────────────────────────────
//  Material'ın takvim ve saat seçicileri KULLANILMIYOR: ölçüldü, ikisi
//  birlikte paketi 52 KB (gzip) büyütüyor ve dağıtım bekçisinin tavanını
//  aştırıyor.
//
//  Kayıp yok, çünkü haber odasında ihtiyaç keyfi bir takvim tarihi değil:
//  "bu akşam", "yarın sabah", "pazartesi 09:00". Dört gün ve altı saat
//  seçeneği bunun tamamını karşılıyor; iki dokunuşla bitiyor, takvimde
//  gezinmekten de hızlı.
// ══════════════════════════════════════════════════════════════════════════
class _ZamanSecici extends StatefulWidget {
  const _ZamanSecici({required this.simdi, this.mevcut});

  final DateTime simdi;
  final DateTime? mevcut;

  @override
  State<_ZamanSecici> createState() => _ZamanSeciciState();
}

class _ZamanSeciciState extends State<_ZamanSecici> {
  late int _gunFarki;
  late int _saat;
  int _dakika = 0;

  static const _gunler = ['Bugün', 'Yarın', '2 gün sonra', '3 gün sonra'];
  static const _saatler = [7, 9, 12, 15, 18, 21];
  static const _aylar = [
    'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz',
    'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara',
  ];

  @override
  void initState() {
    super.initState();
    final m = widget.mevcut;
    if (m != null) {
      final bugun = DateTime(
          widget.simdi.year, widget.simdi.month, widget.simdi.day);
      _gunFarki =
          DateTime(m.year, m.month, m.day).difference(bugun).inDays.clamp(0, 3);
      _saat = m.hour;
      _dakika = m.minute;
    } else {
      // Varsayılan: en yakın mantıklı an. Gün bitmişse yarın sabah.
      final sonraki = _saatler.firstWhere((s) => s > widget.simdi.hour,
          orElse: () => -1);
      _gunFarki = sonraki == -1 ? 1 : 0;
      _saat = sonraki == -1 ? 7 : sonraki;
    }
  }

  DateTime get _secilen {
    final g = widget.simdi.add(Duration(days: _gunFarki));
    return DateTime(g.year, g.month, g.day, _saat, _dakika);
  }

  @override
  Widget build(BuildContext context) {
    final gecmis = _secilen.isBefore(widget.simdi);
    final s = _secilen;

    return AlertDialog(
      title: Text('Yayın zamanı',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Gün', style: GoogleFonts.inter(fontSize: 12.5)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(_gunler.length, (i) {
                final g = widget.simdi.add(Duration(days: i));
                return ChoiceChip(
                  selected: _gunFarki == i,
                  onSelected: (_) => setState(() => _gunFarki = i),
                  label: Text(
                    i < 2
                        ? _gunler[i]
                        : '${g.day} ${_aylar[g.month - 1]}',
                    style: GoogleFonts.inter(fontSize: 12.5),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            Text('Saat', style: GoogleFonts.inter(fontSize: 12.5)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _saatler
                  .map((h) => ChoiceChip(
                        selected: _saat == h && _dakika == 0,
                        onSelected: (_) => setState(() {
                          _saat = h;
                          _dakika = 0;
                        }),
                        label: Text('${h.toString().padLeft(2, '0')}:00',
                            style: GoogleFonts.inter(fontSize: 12.5)),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 14),
            // Seçilen an AÇIKÇA yazılıyor: çip seçmek ile "ne zaman
            // çıkacak" arasında zihinden hesap yaptırmamak için.
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: gecmis
                    ? Colors.red.withValues(alpha: 0.10)
                    : const Color(0xFF0E5C52).withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                gecmis
                    ? 'Bu an geçti — ileri bir saat seç.'
                    : '${s.day} ${_aylar[s.month - 1]} ${s.year}, '
                        '${s.hour.toString().padLeft(2, '0')}:'
                        '${s.minute.toString().padLeft(2, '0')}',
                style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: gecmis
                        ? Colors.red.shade700
                        : const Color(0xFF0E5C52)),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Vazgeç')),
        FilledButton(
          onPressed: gecmis ? null : () => Navigator.of(context).pop(_secilen),
          child: const Text('Programla'),
        ),
      ],
    );
  }
}
