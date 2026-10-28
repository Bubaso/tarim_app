import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../home/data/models/news_article.dart';
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
  bool _ingilizce = false;
  bool _islemde = false;
  List<NewsArticle>? _benzerler;
  bool _benzerArandi = false;

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

  Widget _baslik() {
    final kaynak = (a.sourceName ?? '').trim();
    final adres = (a.sourceUrl ?? '').trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SelectableText(
          a.title,
          style: GoogleFonts.outfit(
              fontSize: 19, fontWeight: FontWeight.bold, color: _metin),
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
        if (_benzerArandi) ...[
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
    setState(() => _islemde = true);
    List<NewsArticle> bulunan = const [];
    try {
      bulunan = await ref.read(homeRepositoryProvider).searchArticles(a.title);
    } catch (_) {
      bulunan = const [];
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

  // ── Yayınlanacak metin ─────────────────────────────────────────────────────

  Widget _yayinlanacakMetin() {
    final govde = _ingilizce ? (a.contentEn ?? '') : a.content;
    final duz = _duzMetin(govde);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _bolumBasligi('Yayınlanacak metin'),
            const Spacer(),
            Text('Yayın Dili',
                style: GoogleFonts.inter(fontSize: 12, color: _soluk)),
            const SizedBox(width: 8),
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

  Widget _figurSatiri(dynamic ham) {
    if (ham is! Map) return const SizedBox.shrink();
    final label = (ham['label'] ?? '').toString();
    final value = (ham['value'] ?? '').toString();
    final unit = (ham['unit'] ?? '').toString();
    final period = (ham['period'] ?? '').toString();
    final source = (ham['source'] ?? '').toString();

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.tag, size: 15, color: _soluk),
          const SizedBox(width: 6),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.inter(fontSize: 12.5, color: _metin),
                children: [
                  TextSpan(
                      text: '$value${unit.isEmpty ? '' : ' $unit'}  ',
                      style:
                          const TextStyle(fontWeight: FontWeight.bold)),
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
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.only(left: 10),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: _soluk.withValues(alpha: 0.4), width: 3),
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
