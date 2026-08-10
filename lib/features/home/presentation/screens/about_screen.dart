import 'package:tarim_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/utils/fade_page_route.dart';
import '../../../legal/data/legal_documents.dart';
import '../../../legal/presentation/screens/legal_page_screen.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isEn = Localizations.localeOf(context).languageCode == 'en';

    // Renkler [LegalPageScreen] ile aynı token'lardan geliyor: okuyucu
    // Hakkımızda → Künye geçişinde iki farklı sitede gezindiğini hissetmemeli.
    final bgColor = isDark ? AppColors.darkGreen : AppColors.creamBackground;
    final textColor = isDark ? AppColors.creamBackground : AppColors.earthText;
    final subtleColor = isDark
        ? AppColors.wheat
        : AppColors.earthText.withValues(alpha: 0.70);
    final accent = AppColors.accentFor(isDark: isDark);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: textColor),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => popScreen(context),
          tooltip: isEn ? 'Back' : 'Geri',
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/logo_tp.png',
              height: 34,
              errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.eco_rounded, color: Colors.green, size: 24),
            ),
            const SizedBox(width: 8),
            Text(
              'TARIM PORTALI',
              style: GoogleFonts.playfairDisplay(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEn ? 'About Us' : 'Hakkımızda',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  isEn
                    ? 'Tarım Portalı is where the heart of Turkey\'s agriculture, livestock, and ecosystem economy beats. '
                      'We set out to convey sectoral developments, scientific production methods, and market data to our farmers, investors, '
                      'and researchers with a reliable language.'
                    : 'Tarım Portalı, Türkiye tarım, hayvancılık ve ekosistem ekonomisinin kalbinin attığı yerdir. '
                      'Sektörel gelişimleri, bilimsel üretim yöntemlerini ve pazar verilerini çiftçilerimize, yatırımcılara '
                      've araştırmacılara güvenilir bir dille aktarmak üzere yola çıktık.',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    height: 1.6,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 32),
                
                Text(
                  isEn ? 'Our Mission' : 'Misyonumuz',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  isEn 
                    ? 'To support the construction of a more sustainable and profitable agricultural ecosystem through information and news by blending the bounty of the soil with modern technology.'
                    : 'Toprağın bereketi ile modern teknolojiyi harmanlayarak, daha sürdürülebilir ve kazançlı bir tarım ekosisteminin inşasına bilgi ve haber yoluyla destek olmaktır.',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    height: 1.6,
                    color: subtleColor,
                  ),
                ),
                const SizedBox(height: 48),

                // Künye, iletişim ve yasal metinler artık kendi sayfalarında.
                // Bu ekran altı ayrı konunun toplandığı bir çöp sepeti değil,
                // yalnızca "hakkımızda".
                Text(
                  isEn ? 'More' : 'Daha Fazlası',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                for (final slug in const [
                  'kunye',
                  'iletisim',
                  'kullanim-kosullari',
                  'gizlilik',
                  'cerezler',
                ])
                  _DocLink(
                    doc: legalDocs[slug]!,
                    isEn: isEn,
                    color: textColor,
                    accent: accent,
                  ),
                const SizedBox(height: 64),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DocLink extends StatelessWidget {
  final LegalDoc doc;
  final bool isEn;
  final Color color;
  final Color accent;

  const _DocLink({
    required this.doc,
    required this.isEn,
    required this.color,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => pushScreen(context, LegalPageScreen(doc: doc)),
      child: Container(
        // 44 px dokunma hedefi.
        constraints: const BoxConstraints(minHeight: 44),
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            Icon(Icons.arrow_forward_rounded, size: 16, color: accent),
            const SizedBox(width: 10),
            Text(
              doc.title(isEn),
              style: GoogleFonts.inter(fontSize: 15, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
