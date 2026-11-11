import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dark_mode.dart';
import '../../../../core/utils/fade_page_route.dart';
import '../../../home/data/models/news_article.dart';
import '../../../home/presentation/screens/article_detail_screen.dart';
import '../../../home/providers/home_providers.dart';
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
        if (ham.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.inbox_rounded, size: 44, color: _soluk),
                const SizedBox(height: 12),
                Text('Kuyruk boş — onay bekleyen haber yok.',
                    style: GoogleFonts.inter(fontSize: 15, color: _soluk)),
              ],
            ),
          );
        }

        final liste = _suz(ham);
        // Süzgeç değiştiyse görünmeyen bir haber seçili kalmasın: "3 seçili"
        // deyip ekranda 1 haber görünmesi, toplu işlemde sürpriz üretir.
        _secili.removeWhere((id) => !liste.any((a) => a.id == id));

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _ustCubuk(ham, liste)),
            // Tembel: 39 kartın tamamını bir kerede kurmak, kuyruk
            // büyüdüğünde panelin açılışını kilitliyordu.
            SliverList.separated(
              itemCount: liste.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _kart(context, liste[i]),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 48)),
          ],
        );
      },
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
              Text(
                liste.length == ham.length
                    ? '${ham.length} haber karar bekliyor'
                    : '${liste.length} / ${ham.length} haber',
                style: GoogleFonts.outfit(
                    fontSize: 20, fontWeight: FontWeight.w900, color: _metin),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Kuyruğu tazele',
                onPressed: _islemde
                    ? null
                    : () => ref.invalidate(pendingArticlesProvider),
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
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
          Row(
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
              const Spacer(),
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

  Future<void> _tekOnayla(NewsArticle article) async {
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
    ref.invalidate(kaynakKarnesiProvider);
  }
}
