import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/utils/fade_page_route.dart';
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
//  NEDEN ŞERİT, YENİ BİR BÖLÜM DEĞİL
//  Kalkan bölüm kart ızgarasıyla yer kaplıyordu; onu aynı hacimde bir
//  şeyle doldurmak, biten bir olayı bitmemiş gibi göstermek olurdu. Şerit
//  tek satır yer kaplıyor: "burada bir şey vardı, muhasebesi şurada" diyor
//  ve sayfanın geri kalanını yeni habere bırakıyor.
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

    return Padding(
      padding: EdgeInsets.only(bottom: spacing),
      child: HaberDokunmaAlani(
        etiket: 'COP31 değerlendirme raporu. ${liste.length} haberin '
            'muhasebesi.',
        borderRadius: BorderRadius.circular(14),
        onTap: () => pushScreen(context, const Cop31RaporEkrani()),
        child: Container(
          padding: EdgeInsets.fromLTRB(18, 16, dar ? 16 : 18, 16),
          decoration: BoxDecoration(
            color: yuzey,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: vurgu.withValues(alpha: 0.34)),
          ),
          child: Flex(
            direction: dar ? Axis.vertical : Axis.horizontal,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: dar ? 0 : 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('COP31 · SONA ERDİ',
                        style: GoogleFonts.inter(
                            fontSize: 11, fontWeight: FontWeight.w800,
                            letterSpacing: 1.1, color: vurgu)),
                    const SizedBox(height: 7),
                    Text('Zirvenin muhasebesi: ne kararlaştırıldı, '
                        'ne kararlaştırılamadı',
                        style: GoogleFonts.outfit(
                            fontSize: dar ? 17 : 19, height: 1.25,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : Colors.black87)),
                    const SizedBox(height: 7),
                    Text(
                      '${liste.length} haberlik izleğin değerlendirmesi, '
                      'tarıma düşen pay ve zirveden rakamlar.',
                      style: GoogleFonts.inter(
                          fontSize: 13, height: 1.45,
                          color: isDark ? Colors.grey[300] : Colors.grey[800]),
                    ),
                  ],
                ),
              ),
              SizedBox(width: dar ? 0 : 18, height: dar ? 14 : 0),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: vurgu,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Raporu aç',
                          style: GoogleFonts.inter(
                              fontSize: 13.5, fontWeight: FontWeight.w700,
                              color: isDark ? Colors.black : Colors.white)),
                      const SizedBox(width: 6),
                      Icon(Icons.arrow_forward_rounded, size: 16,
                          color: isDark ? Colors.black : Colors.white),
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
