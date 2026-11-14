import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../home/data/models/news_article.dart';
import '../../domain/rakam_eslestirme.dart';
import '../../../home/providers/home_providers.dart';
import '../../../../core/utils/image_fallback_helper.dart';

// ══════════════════════════════════════════════════════════════════════════════
//  İnceleme kartı — yayın kararının verildiği yer
// ──────────────────────────────────────────────────────────────────────────────
//  CLAUDE.md §29.3: tek ekranda üç soruyu cevaplıyor.
//
//    ne yayınlanacak  → gövde önizlemesi, Türkçe/İngilizce sekmeli
//    doğru mu         → kaynak bağlantısı + muhabirin doğrulama verisi
//    eksik var mı     → benzer yayın denetimi, görsel listesi
//
//  Buradaki verinin TAMAMI zaten üretiliyordu ve hat içinde kullanılıp
//  ATILIYORDU (§29.2). Yeni yapay zekâ maliyeti yok; yalnızca kararı VEREN
//  kişiye gösteriliyor. Eski kayıtlarda alanlar boş — kart bunu açıkça yazıyor.
//
//  İngilizce sekmesi bilerek eşit ağırlıkta: site iki dilli ve İngilizce sürüm
//  bugüne kadar hiçbir aşamada insan gözünden geçmiyordu.
// ══════════════════════════════════════════════════════════════════════════════

class IncelemeKarti extends ConsumerStatefulWidget {
  const IncelemeKarti({
    super.key,
    required this.article,
    required this.isDark,
    this.onDegisti,
  });

  final NewsArticle article;
  final bool isDark;
  final VoidCallback? onDegisti;

  @override
  ConsumerState<IncelemeKarti> createState() => _IncelemeKartiState();
}

class _IncelemeKartiState extends ConsumerState<IncelemeKarti> {
  @override
  void dispose() {
    _baslikDenetleyici.dispose();
    super.dispose();
  }

  bool _ingilizce = false;
  bool _islemde = false;
  List<NewsArticle>? _benzerler;
  bool _benzerArandi = false;

  /// Denetim ÇALIŞTI ama başarısız oldu.
  ///
  /// Üç durumu ayırmak zorundayız: hiç denenmedi · denendi ve temiz ·
  /// denendi ve cevap alınamadı. Üçüncüsü ikincisiyle aynı ekrana
  /// yazılamaz — aşağıdaki açıklamaya bakın.
  String? _benzerHatasi;

  NewsArticle get a => widget.article;
  bool get isDark => widget.isDark;

  Color get _metin => isDark ? Colors.white : Colors.black87;
  Color get _soluk => isDark ? Colors.grey[400]! : Colors.grey[700]!;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B22) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _baslik(),
          const SizedBox(height: 14),
          _benzerDenetimi(),
          const SizedBox(height: 18),
          _yayinlanacakMetin(),
          const SizedBox(height: 18),
          _govdeGorselleri(),
          const SizedBox(height: 18),
          _kaynakDogrulama(),
          const SizedBox(height: 18),
          _alintilar(),
        ],
      ),
    );
  }

  // ── Başlık + kaynak ────────────────────────────────────────────────────────

  // ── Başlık düzenleme ───────────────────────────────────────────────────
  //
  // Kuyrukta düzenleme yolu YOKTU: kart yalnızca kapak görselini ve gövdeyi
  // yazabiliyordu. Başlığı bozuk bir haber için moderatörün iki seçeneği
  // vardı — olduğu gibi onaylamak ya da reddetmek. Editör formu da yalnızca
  // YAYINDAKİLERİ listeliyor, yani "önce yayınla sonra düzelt" demek
  // bozuk başlığı okura göstermek demekti.
  //
  // 15 KASIM 2026: artık başlıkla sınırlı değil. Özet, spot ve gövde de
  // buradan düzeltilebiliyor (madde 14). Eskiden özetteki tek bir yazım
  // hatası için haberi önce yayınlayıp sonra Haberlerim sekmesinde, 500'lük
  // listede bulup düzenleyiciyi açmak gerekiyordu — ya da haberi reddedip
  // kaynağı kaybetmek.
  bool _basligiDuzenle = false;
  final TextEditingController _baslikDenetleyici = TextEditingController();
  bool _baslikKaydediliyor = false;

  Future<void> _basligiKaydet() async {
    final yeni = _baslikDenetleyici.text.trim();
    if (yeni.isEmpty || yeni == a.title) {
      setState(() => _basligiDuzenle = false);
      return;
    }
    setState(() => _baslikKaydediliyor = true);
    final repo = ref.read(homeRepositoryProvider);
    final ok = await repo.alanlariGuncelle(a.id, {'title': yeni});
    if (!mounted) return;
    setState(() {
      _baslikKaydediliyor = false;
      if (ok) _basligiDuzenle = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok
            ? 'Başlık güncellendi.'
            : 'Başlık yazılamadı: ${repo.sonYazmaHatasi ?? 'yetki yok'}'),
        backgroundColor: ok ? null : Colors.redAccent,
      ),
    );
    if (ok) widget.onDegisti?.call();
  }

  /// Tek bir metin alanını düzenler (özet, spot, gövde).
  ///
  /// Alt sayfada açılıyor: kart zaten uzun, satır içi bir kutu daha koymak
  /// kararın verildiği yeri okunmaz hâle getirirdi. Telefonda tam ekran
  /// açılıyor, klavye alanı itiyor.
  Future<void> _alaniDuzenle({
    required String alan,
    required String etiket,
    required String mevcut,
    required bool hamHtml,
  }) async {
    final denetleyici = TextEditingController(text: mevcut);
    final yeni = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('$etiket düzenle',
                        style: GoogleFonts.outfit(
                            fontSize: 17, fontWeight: FontWeight.w800)),
                  ),
                  IconButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      icon: const Icon(Icons.close_rounded)),
                ],
              ),
              if (hamHtml)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Gövde HAM HTML olarak düzenleniyor. Etiketleri bozma; '
                    'yalnız metni düzelt.',
                    style: GoogleFonts.inter(
                        fontSize: 12, color: Colors.orange.shade800),
                  ),
                ),
              ConstrainedBox(
                constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(ctx).size.height * 0.45),
                child: TextField(
                  controller: denetleyici,
                  autofocus: true,
                  maxLines: null,
                  expands: false,
                  keyboardType: TextInputType.multiline,
                  style: hamHtml
                      ? GoogleFonts.robotoMono(fontSize: 12.5, height: 1.5)
                      : GoogleFonts.inter(fontSize: 14, height: 1.5),
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), isDense: true),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  FilledButton(
                    onPressed: () =>
                        Navigator.of(ctx).pop(denetleyici.text),
                    child: const Text('Kaydet'),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Vazgeç')),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
    denetleyici.dispose();
    if (yeni == null || yeni == mevcut || !mounted) return;

    // BOŞALTMAYA KARŞI KORUMA: etiketler sökülünce geriye hiçbir şey
    // kalmıyorsa kayıt yapılmıyor. Yanlışlıkla seçip silmek, yayındaki bir
    // haberin metnini tek dokunuşla yok edebilirdi.
    if (_duzMetin(yeni).trim().isEmpty) {
      _bitir('Kaydedilmedi: alan boş kalıyordu.');
      return;
    }

    setState(() => _islemde = true);
    final repo = ref.read(homeRepositoryProvider);
    final ok = await repo.alanlariGuncelle(a.id, {alan: yeni});
    if (!mounted) return;
    setState(() => _islemde = false);
    _bitir(ok
        ? '$etiket güncellendi.'
        : '$etiket yazılamadı: ${repo.sonYazmaHatasi ?? 'yetki yok'}');
    if (ok) widget.onDegisti?.call();
  }

  /// Düzenle düğmesi — başlık satırındakiyle aynı görünüm.
  Widget _duzenleDugmesi(String ipucu, VoidCallback bas) => IconButton(
        tooltip: ipucu,
        iconSize: 18,
        visualDensity: VisualDensity.compact,
        onPressed: _islemde ? null : bas,
        icon: Icon(Icons.edit_outlined, color: _soluk),
      );

  Widget _baslik() {
    final kaynak = (a.sourceName ?? '').trim();
    final adres = (a.sourceUrl ?? '').trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_basligiDuzenle)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _baslikDenetleyici,
                autofocus: true,
                maxLines: null,
                style: GoogleFonts.outfit(
                    fontSize: 19, fontWeight: FontWeight.bold, color: _metin),
                decoration: const InputDecoration(
                  isDense: true,
                  border: OutlineInputBorder(),
                  labelText: 'Başlık',
                ),
                onSubmitted: (_) => _basligiKaydet(),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  FilledButton(
                    onPressed: _baslikKaydediliyor ? null : _basligiKaydet,
                    child: Text(_baslikKaydediliyor ? 'Kaydediliyor…' : 'Kaydet'),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: _baslikKaydediliyor
                        ? null
                        : () => setState(() => _basligiDuzenle = false),
                    child: const Text('Vazgeç'),
                  ),
                ],
              ),
            ],
          )
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SelectableText(
                  a.title,
                  style: GoogleFonts.outfit(
                      fontSize: 19, fontWeight: FontWeight.bold, color: _metin),
                ),
              ),
              IconButton(
                tooltip: 'Başlığı düzenle',
                iconSize: 18,
                visualDensity: VisualDensity.compact,
                onPressed: () => setState(() {
                  _baslikDenetleyici.text = a.title;
                  _basligiDuzenle = true;
                }),
                icon: Icon(Icons.edit_outlined, color: _soluk),
              ),
            ],
          ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 10,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (kaynak.isNotEmpty)
              Text(kaynak,
                  style: GoogleFonts.inter(fontSize: 12.5, color: _soluk)),
            if (adres.isNotEmpty)
              SelectableText(
                adres,
                style: GoogleFonts.inter(
                    fontSize: 12, color: Colors.blue.shade700),
              ),
            if (adres.isEmpty)
              Text('Kaynak adresi yok',
                  style: GoogleFonts.inter(
                      fontSize: 12, color: Colors.orange.shade800)),
          ],
        ),
      ],
    );
  }

  // ── Benzer yayın denetimi ──────────────────────────────────────────────────
  //
  // Mükerreri şimdiye kadar yalnızca `articles_slug_key` kısıtı yakalıyordu —
  // yani aynı haber başka sözcüklerle geldiğinde hiçbir şey uyarmıyordu.

  Widget _benzerDenetimi() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: _islemde ? null : _benzerAra,
              icon: const Icon(Icons.copy_all_outlined, size: 18),
              label: Text('Benzer yayınları denetle',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        if (_benzerHatasi != null) ...[
          const SizedBox(height: 8),
          // YEŞİL DEĞİL. Eskiden RPC düştüğünde istisna yutuluyor, liste boş
          // kalıyor ve kart yeşil "Benzer haber bulunamadı" yazıyordu: yani
          // moderatör hiç yapılmamış bir denetimin onayını alıyordu. Yanlış
          // güvence, güvence yokluğundan tehlikeli.
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.error_outline_rounded,
                  size: 16, color: Colors.red.shade700),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Denetim yapılamadı — $_benzerHatasi\n'
                  'Bu haber mükerrer OLABİLİR; denetim çalışmadı.',
                  style: GoogleFonts.inter(
                      fontSize: 12.5,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                      color: Colors.red.shade700),
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: _islemde ? null : _benzerAra,
                child: Text('Yeniden dene',
                    style: GoogleFonts.inter(
                        fontSize: 12.5, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ] else if (_benzerArandi) ...[
          const SizedBox(height: 8),
          if ((_benzerler ?? const []).isEmpty)
            Text('Benzer haber bulunamadı.',
                style: GoogleFonts.inter(
                    fontSize: 13, color: Colors.green.shade700))
          else
            ...(_benzerler ?? const []).map(
              (b) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        size: 16, color: Colors.orange.shade800),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(b.title,
                          style: GoogleFonts.inter(
                              fontSize: 12.5, color: _soluk)),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ],
    );
  }

  Future<void> _benzerAra() async {
    setState(() {
      _islemde = true;
      _benzerHatasi = null;
    });

    List<NewsArticle> bulunan;
    try {
      bulunan = await ref.read(homeRepositoryProvider).searchArticles(a.title);
    } catch (e) {
      // Hata YUTULMUYOR, ekrana çıkıyor. Boş listeye düşmek burada sessiz
      // bir yalan üretiyordu.
      if (!mounted) return;
      setState(() {
        _benzerHatasi = _hataMetni(e);
        _benzerler = null;
        _benzerArandi = false;
        _islemde = false;
      });
      return;
    }

    if (!mounted) return;
    setState(() {
      // Haberin KENDİSİ listede çıkar; onu saymak her haberi "mükerrer"
      // gösterirdi.
      _benzerler = bulunan.where((b) => b.id != a.id).take(5).toList();
      _benzerArandi = true;
      _islemde = false;
    });
  }

  /// İstisnayı moderatörün okuyabileceği tek satıra indirir.
  String _hataMetni(Object e) {
    final ham = e.toString().replaceAll('\n', ' ').trim();
    return ham.length > 140 ? '${ham.substring(0, 140)}…' : ham;
  }

  // ── Yayınlanacak metin ─────────────────────────────────────────────────────

  Widget _yayinlanacakMetin() {
    final govde = _ingilizce ? (a.contentEn ?? '') : a.content;
    final duz = _duzMetin(govde);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Telefonda tek satıra sığmıyordu: başlık + etiket + iki düğme.
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 4,
          children: [
            _bolumBasligi('Yayınlanacak metin'),
            _duzenleDugmesi(
              'Gövdeyi düzenle',
              () => _alaniDuzenle(
                alan: _ingilizce ? 'content_en' : 'content',
                etiket: _ingilizce ? 'İngilizce gövde' : 'Gövde',
                mevcut: _ingilizce ? (a.contentEn ?? '') : a.content,
                hamHtml: true,
              ),
            ),
            Text('Yayın Dili',
                style: GoogleFonts.inter(fontSize: 12, color: _soluk)),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text('TR')),
                ButtonSegment(value: true, label: Text('EN')),
              ],
              selected: {_ingilizce},
              onSelectionChanged: (s) =>
                  setState(() => _ingilizce = s.first),
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                textStyle: WidgetStatePropertyAll(
                    GoogleFonts.inter(fontSize: 12)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // ÖZET VE SPOT (madde 14). İkisi de kartlarda ve haberin tepesinde
        // görünüyor; en sık düzeltilen metinler bunlar.
        _kisaAlan(
          etiket: 'Özet',
          deger: _ingilizce ? (a.summaryEn ?? '') : (a.summary ?? ''),
          alan: _ingilizce ? 'summary_en' : 'summary',
        ),
        _kisaAlan(
          etiket: 'Spot',
          deger: _ingilizce ? (a.spotEn ?? '') : (a.spot ?? ''),
          alan: _ingilizce ? 'spot_en' : 'spot',
        ),
        const SizedBox(height: 8),
        if (duz.isEmpty)
          _uyari(_ingilizce
              ? 'İngilizce gövde boş — yayınlanırsa okur Türkçesini görür.'
              : 'Gövde boş.')
        else
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxHeight: 260),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? Colors.white10 : const Color(0xFFF7F5F0),
              borderRadius: BorderRadius.circular(8),
            ),
            child: SingleChildScrollView(
              child: SelectableText(
                duz,
                style: GoogleFonts.inter(
                    fontSize: 13.5, height: 1.6, color: _metin),
              ),
            ),
          ),
      ],
    );
  }

  /// Özet/spot satırı — metin, yanında düzenle düğmesi.
  Widget _kisaAlan({
    required String etiket,
    required String deger,
    required String alan,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 44,
            child: Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(etiket,
                  style: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: _soluk)),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                deger.trim().isEmpty ? '—' : deger,
                style: GoogleFonts.inter(
                    fontSize: 13, height: 1.5, color: _metin),
              ),
            ),
          ),
          _duzenleDugmesi(
            '$etiket düzenle',
            () => _alaniDuzenle(
                alan: alan, etiket: etiket, mevcut: deger, hamHtml: false),
          ),
        ],
      ),
    );
  }

  // ── Gövde görselleri ───────────────────────────────────────────────────────
  //
  // Hangi görselin kalacağına, hangisinin kapak olacağına burada karar
  // veriliyor. Gövdeden silme YAYINDAKİ metni değiştiriyor, o yüzden §39.6'nın
  // kuralı geçerli: desen körlemesine uygulanmaz — her görselin KENDİ etiketi
  // tek tek eşleştirilip yalnızca o çıkarılıyor.

  Widget _govdeGorselleri() {
    final govde = _ingilizce ? (a.contentEn ?? '') : a.content;
    final gorseller = _gorselleriBul(govde);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _bolumBasligi('Gövdedeki görseller (${gorseller.length})'),
        const SizedBox(height: 8),
        if (gorseller.isEmpty)
          Text('Gövdede görsel yok.',
              style: GoogleFonts.inter(fontSize: 13, color: _soluk))
        else
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: gorseller
                .map((g) => _gorselKutusu(g, govde))
                .toList(growable: false),
          ),
      ],
    );
  }

  Widget _gorselKutusu(_Gorsel g, String govde) {
    final kapakMi = (a.imageUrl ?? '').trim() == g.url;
    return SizedBox(
      width: 168,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 96,
              width: 168,
              child: NewsArticleImage(imageUrl: g.url, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 4),
          if (kapakMi)
            Text('Kapak',
                style: GoogleFonts.inter(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700))
          else
            TextButton(
              onPressed: _islemde ? null : () => _kapakYap(g.url),
              style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 28),
                  visualDensity: VisualDensity.compact),
              child: Text('Kapak yap',
                  style: GoogleFonts.inter(fontSize: 11.5)),
            ),
          TextButton(
            onPressed: _islemde ? null : () => _gorseliKaldir(g, govde),
            style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 28),
                visualDensity: VisualDensity.compact),
            child: Text('Gövdeden kaldır',
                style: GoogleFonts.inter(
                    fontSize: 11.5, color: Colors.red.shade700)),
          ),
        ],
      ),
    );
  }

  Future<void> _kapakYap(String url) async {
    setState(() => _islemde = true);
    final ok = await ref
        .read(homeRepositoryProvider)
        .alanlariGuncelle(a.id, {'image_url': url});
    _bitir(ok ? 'Kapak güncellendi.' : 'Kayıt başarısız: kapak yazılamadı.');
  }

  Future<void> _gorseliKaldir(_Gorsel g, String govde) async {
    // Tam eşleşme: görselin KENDİ etiketi çıkarılıyor, desenle süpürme yok.
    if (!govde.contains(g.etiket)) {
      _bitir('Kaldırma kaydedilemedi: etiket gövdede bulunamadı.');
      return;
    }
    final yeni = govde.replaceFirst(g.etiket, '');
    setState(() => _islemde = true);
    final alan = _ingilizce ? 'content_en' : 'content';
    final ok = await ref
        .read(homeRepositoryProvider)
        .alanlariGuncelle(a.id, {alan: yeni});
    _bitir(ok ? 'Görsel gövdeden kaldırıldı.' : 'Kaldırma kaydedilemedi.');
  }

  // ── Kaynak doğrulama ───────────────────────────────────────────────────────

  Widget _kaynakDogrulama() {
    final f = a.facts;
    final figurler = a.figures ?? const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _bolumBasligi('Kaynak doğrulama'),
        const SizedBox(height: 8),
        if (f == null && figurler.isEmpty)
          _uyari('Bu kayıtta doğrulama verisi yok (eski kayıt).')
        else ...[
          if (f != null) _besNbirK(f),
          if (figurler.isNotEmpty) ...[
            const SizedBox(height: 10),
            _rakamOzeti(),
            const SizedBox(height: 6),
            ...figurler.map(_figurSatiri),
          ],
        ],
      ],
    );
  }

  Widget _besNbirK(Map<String, dynamic> f) {
    const etiketler = {
      'who': 'Kim',
      'what': 'Ne',
      'when': 'Ne zaman',
      'where': 'Nerede',
      'why': 'Neden',
      'how': 'Nasıl',
    };
    final satirlar = <Widget>[];
    etiketler.forEach((anahtar, etiket) {
      final v = (f[anahtar] ?? '').toString().trim();
      if (v.isEmpty) return;
      satirlar.add(Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 76,
              child: Text(etiket,
                  style: GoogleFonts.inter(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: _soluk)),
            ),
            Expanded(
              child: SelectableText(v,
                  style: GoogleFonts.inter(fontSize: 12.5, color: _metin)),
            ),
          ],
        ),
      ));
    });
    if (satirlar.isEmpty) return const SizedBox.shrink();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: satirlar);
  }

  /// Rakamların yayınlanacak metinle eşleşmesi.
  ///
  /// Muhabir ajanı rakamları kaynaktan çıkarıyor, sonra editör ajanı metni
  /// yeniden kuruyor. Aradaki adımda bir rakam düşebiliyor ya da
  /// değişebiliyor ve bunu kimse görmüyordu — panel rakamları yalnızca
  /// LİSTELİYORDU. Artık her rakamın metinde geçip geçmediği sınanıyor.
  ///
  /// Ölçüldü (150 gerçek haber, 1.042 rakam): %94,2 eşleşiyor, %2,4
  /// bulunamıyor. Yani kırmızı bir işaret gerçekten bir şey anlatıyor.
  List<RakamDenetimi> get _rakamDenetimi =>
      rakamlariDenetle(a.figures, _ingilizce ? a.contentEn : a.content);

  Widget _rakamOzeti() {
    final d = _rakamDenetimi;
    final eksik = d.where((x) => x.durum == Eslesme.bulunamadi).length;
    if (eksik == 0) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: isDark ? 0.16 : 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.priority_high_rounded,
              size: 15, color: Colors.red.shade600),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              '$eksik rakam yayınlanacak metinde geçmiyor. '
              'Editör düşürmüş ya da sayı değişmiş olabilir.',
              style: GoogleFonts.inter(
                  fontSize: 12, color: Colors.red.shade600, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _figurSatiri(dynamic ham) {
    if (ham is! Map) return const SizedBox.shrink();
    final label = (ham['label'] ?? '').toString();
    final value = (ham['value'] ?? '').toString();
    final unit = (ham['unit'] ?? '').toString();
    final period = (ham['period'] ?? '').toString();
    final source = (ham['source'] ?? '').toString();

    // Bu rakamın eşleşme durumu — etikete göre bulunuyor.
    final denetim = _rakamDenetimi.firstWhere(
      (x) => x.etiket == label,
      orElse: () => RakamDenetimi(
          etiket: label,
          deger: value,
          birim: unit,
          durum: Eslesme.bilinmiyor),
    );
    final eksik = denetim.durum == Eslesme.bulunamadi;
    final bulundu = denetim.durum == Eslesme.bulundu;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // İŞARET DURUMU SÖYLÜYOR: bulundu ✓, bulunamadı !, sınanamadı #.
          // Üçüncüsü ayrı tutuluyor — "bilmiyorum" ile "yok" aynı şey değil.
          Tooltip(
            message: eksik
                ? 'Bu rakam metinde bulunamadı'
                : bulundu
                    ? 'Metinde "${denetim.bulunanBicim}" olarak geçiyor'
                    : 'Sınanamadı',
            child: Icon(
                eksik
                    ? Icons.priority_high_rounded
                    : bulundu
                        ? Icons.check_rounded
                        : Icons.tag,
                size: 15,
                color: eksik
                    ? Colors.red.shade600
                    : bulundu
                        ? Colors.green.shade600
                        : _soluk),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.inter(fontSize: 12.5, color: _metin),
                children: [
                  TextSpan(
                      text: '$value${unit.isEmpty ? '' : ' $unit'}  ',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: eksik ? Colors.red.shade600 : null)),
                  TextSpan(text: label),
                  if (period.isNotEmpty)
                    TextSpan(
                        text: '  · $period',
                        style: TextStyle(color: _soluk)),
                  // Rakamın kaynağı YAZILMADAN rakam gösterilmez (§2.2).
                  if (source.isNotEmpty)
                    TextSpan(
                        text: '  · $source',
                        style: TextStyle(color: _soluk)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Alıntılar ──────────────────────────────────────────────────────────────

  Widget _alintilar() {
    final q = a.quotes ?? const [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _bolumBasligi('Kaynaktaki alıntılar'),
        const SizedBox(height: 8),
        if (q.isEmpty)
          Text('Alıntı yok.',
              style: GoogleFonts.inter(fontSize: 13, color: _soluk))
        else
          ...q.map((ham) {
            if (ham is! Map) return const SizedBox.shrink();
            final konusan = (ham['speaker'] ?? '').toString();
            final unvan = (ham['title'] ?? '').toString();
            final metin = (ham['text'] ?? '').toString();

            // Alıntı yayınlanacak metinde geçiyor mu? Tam eşleşme
            // aranmıyor — editör kısaltabiliyor. Alıntının BAŞINDAN
            // yeterince uzun bir parça yoksa alıntı metne hiç girmemiş
            // demektir. Ölçüldü: 247 alıntının 229'u eşleşiyor.
            final eslesme = alintilariDenetle([ham],
                _ingilizce ? a.contentEn : a.content);
            final eksik = eslesme.isNotEmpty &&
                eslesme.first.durum == Eslesme.bulunamadi;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.only(left: 10),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                      color: eksik
                          ? Colors.red.shade600
                          : _soluk.withValues(alpha: 0.4),
                      width: 3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(metin,
                      style: GoogleFonts.inter(
                          fontSize: 12.5, height: 1.5, color: _metin)),
                  const SizedBox(height: 3),
                  Text(
                    [konusan, unvan].where((x) => x.isNotEmpty).join(' · '),
                    style: GoogleFonts.inter(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: _soluk),
                  ),
                  if (eksik)
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Row(
                        children: [
                          Icon(Icons.priority_high_rounded,
                              size: 13, color: Colors.red.shade600),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Bu alıntı yayınlanacak metinde geçmiyor.',
                              style: GoogleFonts.inter(
                                  fontSize: 11.5,
                                  color: Colors.red.shade600),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          }),
      ],
    );
  }

  // ── Ortak parçalar ─────────────────────────────────────────────────────────

  Widget _bolumBasligi(String s) => Text(
        s,
        style: GoogleFonts.outfit(
            fontSize: 14.5, fontWeight: FontWeight.bold, color: _metin),
      );

  Widget _uyari(String s) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 16, color: Colors.orange.shade800),
          const SizedBox(width: 6),
          Expanded(
            child: Text(s,
                style: GoogleFonts.inter(
                    fontSize: 12.5, color: Colors.orange.shade800)),
          ),
        ],
      );

  void _bitir(String mesaj) {
    if (!mounted) return;
    setState(() => _islemde = false);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mesaj)));
    widget.onDegisti?.call();
  }

  /// HTML gövdeyi okunur düz metne indirger. Etiketleri olduğu gibi göstermek
  /// yayın kararını kolaylaştırmaz.
  static String _duzMetin(String html) => html
      .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'</p>', caseSensitive: false), '\n\n')
      .replaceAll(RegExp(r'<[^>]+>'), '')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&')
      .replaceAll('&quot;', '"')
      .replaceAll(RegExp(r'\n{3,}'), '\n\n')
      .trim();

  /// Gövdedeki `<img>` etiketlerini, ETİKETİN TAMAMIYLA birlikte döndürür.
  /// Kaldırma işlemi desenle değil bu tam dizeyle yapılıyor (§39.6).
  static List<_Gorsel> _gorselleriBul(String html) {
    final out = <_Gorsel>[];
    for (final m in RegExp(r'<img\b[^>]*>', caseSensitive: false)
        .allMatches(html)) {
      final etiket = m.group(0)!;
      final src = RegExp(r'''src\s*=\s*["']([^"']+)["']''', caseSensitive: false)
          .firstMatch(etiket)
          ?.group(1);
      if (src == null || src.trim().isEmpty) continue;
      out.add(_Gorsel(url: src.trim(), etiket: etiket));
    }
    return out;
  }
}

class _Gorsel {
  const _Gorsel({required this.url, required this.etiket});
  final String url;

  /// Gövdedeki etiketin tam metni — kaldırmada bire bir eşleştirilir.
  final String etiket;
}
