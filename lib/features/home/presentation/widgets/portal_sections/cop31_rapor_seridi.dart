import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/utils/fade_page_route.dart';
import '../../../../../core/utils/image_fallback_helper.dart';
import '../../../../../core/utils/responsive_breakpoints.dart';
import '../../../../../core/widgets/haber_dokunma_alani.dart';
import '../../../providers/home_providers.dart';
import '../../screens/cop31_rapor_ekrani.dart';

// ══════════════════════════════════════════════════════════════════════════
//  COP31 Değerlendirme şeridi — bölümün bıraktığı yerde
// ──────────────────────────────────────────────────────────────────────────
//  COP31 bölümü 25 Kasım'da kendiliğinden kalktı ve anasayfada iki ayın en
//  çok işlenen konusu bir anda yok oldu. Bu şerit o boşluğu beş gün tutuyor
//  ve okuru değerlendirme sayfasına götürüyor.
//
//  NEDEN TEK KART, YENİ BİR BÖLÜM DEĞİL
//  Kalkan bölüm kart ızgarasıyla yer kaplıyordu; onu aynı hacimde bir
//  şeyle doldurmak, biten bir olayı bitmemiş gibi göstermek olurdu. Tek
//  kart "burada bir şey vardı, muhasebesi şurada" diyor ve sayfanın geri
//  kalanını yeni habere bırakıyor.
//
//  GÖRSEL, kartın ilk hâlinde yoktu ve kart metin bloğu gibi görünüp
//  akışta kayboluyordu (kullanıcı, 25 Kasım). Artık arşivin EN YÜKSEK
//  editör puanlı haberinin görselini taşıyor: seçim sabit yazılmadı,
//  veriden geliyor; o haber yayından kalkarsa kart bir sonrakine geçiyor
//  ve boş çerçeve kalmıyor.
//
//  BOŞLUĞU KENDİ TAŞIYOR — [Cop31Section] ile aynı kural. 30 Kasım'da şerit
//  çizilmeyi bıraktığında alt boşluğu da götürüyor; anasayfaya ayrı bir
//  `SizedBox` konsaydı o tarihten sonra iki boşluk üst üste binerdi.
//
//  Renk kimliği bölümden devralındı: okur aynı şeyin devamını okuduğunu
//  renkten anlıyor.
// ══════════════════════════════════════════════════════════════════════════

class Cop31RaporSeridi extends ConsumerWidget {
  const Cop31RaporSeridi({super.key, required this.isDark, this.spacing = 0});

  final bool isDark;

  /// Şeritten SONRAKİ boşluk; şerit kalkınca birlikte gidiyor.
  final double spacing;

  static const _vurguAcik = Color(0xFF0E5C52);
  static const _vurguKoyu = Color(0xFF57C9B0);
  static const _yuzeyAcik = Color(0xFFEDF4F1);
  static const _yuzeyKoyu = Color(0xFF0F1F1C);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!raporAktif(ref.watch(simdiProvider)())) {
      return const SizedBox.shrink();
    }
    // Arşiv boşsa şerit de yok: okuru boş bir rapora göndermeyelim.
    final liste = ref.watch(cop31RaporAkisiProvider).valueOrNull ?? const [];
    if (liste.isEmpty) return const SizedBox.shrink();

    final vurgu = isDark ? _vurguKoyu : _vurguAcik;
    final yuzey = isDark ? _yuzeyKoyu : _yuzeyAcik;
    final dar = !ResponsiveBreakpoints.isContentWide(context);

    // Kartın görseli: arşivin en yüksek editör puanlı haberi. Sabit bir
    // kimlik yazmak, o haber yayından kalktığında boş çerçeve bırakırdı.
    final kapak = [...liste]..sort(
        (a, b) => (b.heroScore ?? 0).compareTo(a.heroScore ?? 0));
    final gorselli = kapak.where(
        (a) => (a.thumbImageUrl?.isNotEmpty ?? false) ||
               (a.imageUrl?.isNotEmpty ?? false));
    final kapakHaber = gorselli.isEmpty ? null : gorselli.first;

    final metin = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('COP31 · SONA ERDİ',
            style: GoogleFonts.inter(
                fontSize: 11, fontWeight: FontWeight.w800,
                letterSpacing: 1.1, color: vurgu)),
        const SizedBox(height: 9),
        Text('Zirvenin muhasebesi: ne kararlaştırıldı, ne kararlaştırılamadı',
            style: GoogleFonts.outfit(
                fontSize: dar ? 19 : 22, height: 1.22,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : Colors.black87)),
        const SizedBox(height: 9),
        Text(
          '${liste.length} haberlik izleğin değerlendirmesi: alınan ve '
          'alınamayan kararlar, tarıma düşen pay, zirveden rakamlar.',
          style: GoogleFonts.inter(
              fontSize: 13.5, height: 1.5,
              color: isDark ? Colors.grey[300] : Colors.grey[800]),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
          decoration: BoxDecoration(
            color: vurgu,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Raporu aç',
                  style: GoogleFonts.inter(
                      fontSize: 14, fontWeight: FontWeight.w700,
                      color: isDark ? Colors.black : Colors.white)),
              const SizedBox(width: 6),
              Icon(Icons.arrow_forward_rounded, size: 17,
                  color: isDark ? Colors.black : Colors.white),
            ],
          ),
        ),
      ],
    );

    // Görsel: darda üstte tam genişlik, genişte sağda sabit sütun.
    Widget? gorsel;
    if (kapakHaber != null) {
      final img = NewsArticleImage(
        imageUrl: (kapakHaber.thumbImageUrl?.isNotEmpty ?? false)
            ? kapakHaber.thumbImageUrl
            : kapakHaber.imageUrl,
        fit: BoxFit.cover,
        semanticLabel: '',
      );
      gorsel = ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: dar
            ? SizedBox(width: double.infinity, height: 150, child: img)
            : SizedBox(width: 248, height: 168, child: img),
      );
    }

    return Padding(
      padding: EdgeInsets.only(bottom: spacing),
      child: HaberDokunmaAlani(
        etiket: 'COP31 değerlendirme raporu. ${liste.length} haberin '
            'muhasebesi.',
        borderRadius: BorderRadius.circular(16),
        onTap: () => pushScreen(context, const Cop31RaporEkrani()),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: yuzey,
            borderRadius: BorderRadius.circular(16),
            // Kart akışta kaybolmasın: çerçeve bir tık koyu, üstüne hafif
            // bir gölge. Bölümün yerini tutuyor, bölüm kadar yer kaplamadan.
            border: Border.all(color: vurgu.withValues(alpha: 0.45), width: 1.4),
            boxShadow: [
              BoxShadow(
                color: vurgu.withValues(alpha: isDark ? 0.10 : 0.07),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: dar
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (gorsel != null) ...[gorsel, const SizedBox(height: 14)],
                    metin,
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: metin),
                    if (gorsel != null) ...[const SizedBox(width: 20), gorsel],
                  ],
                ),
        ),
      ),
    );
  }
}
