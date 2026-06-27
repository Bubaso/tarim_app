import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final bgColor = isDark ? const Color(0xFF0D1117) : const Color(0xFFF9F9F9);
    final textColor = isDark ? const Color(0xFFE6EDF3) : const Color(0xFF24292F);
    final subtleColor = isDark ? const Color(0xFF8B949E) : const Color(0xFF57606A);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: textColor),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.eco_rounded, color: Colors.green, size: 24),
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
                  'Hakkımızda',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Tarım Portalı, Türkiye tarım, hayvancılık ve ekosistem ekonomisinin kalbinin attığı yerdir. '
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
                  'Misyonumuz',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Toprağın bereketi ile modern teknolojiyi harmanlayarak, daha sürdürülebilir ve kazançlı bir tarım ekosisteminin inşasına bilgi ve haber yoluyla destek olmaktır.',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    height: 1.6,
                    color: subtleColor,
                  ),
                ),
                const SizedBox(height: 48),

                // Künye
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF161B22) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? const Color(0xFF30363D) : const Color(0xFFE0E0E0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.gavel_rounded, color: theme.colorScheme.primary, size: 24),
                          const SizedBox(width: 12),
                          Text(
                            'Yayın Künyesi',
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildKunyeItem('İmtiyaz Sahibi', 'Tarım Portalı Dijital Yayıncılık A.Ş.', textColor, subtleColor),
                      _buildKunyeItem('Genel Yayın Yönetmeni', 'Burhan Gökçek', textColor, subtleColor),
                      _buildKunyeItem('Sorumlu Yazı İşleri Müdürü', 'Ali Yılmaz', textColor, subtleColor),
                      _buildKunyeItem('Teknik Altyapı', 'Antigravity Studio', textColor, subtleColor),
                      _buildKunyeItem('Adres', 'Bilişim Vadisi, Teknopark Ofis B-Z02, Gebze/Kocaeli', textColor, subtleColor),
                      _buildKunyeItem('İletişim', 'info@tarimportali.com', textColor, subtleColor),
                    ],
                  ),
                ),
                const SizedBox(height: 48),

                // Gizlilik / İletişim vs. (Dummy placeholder text)
                Text(
                  'Gizlilik ve Hukuki Şartlar',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Tarım Portalı Basın Meslek İlkelerine uymaya söz vermiştir. Sitemizde yer alan içeriklerin telif hakları yayınevine ait olup, kaynak gösterilmeden kopyalanamaz. Dış bağlantıların sorumluluğu ilgili web sitelerine aittir.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    height: 1.6,
                    color: subtleColor,
                  ),
                ),
                const SizedBox(height: 64),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKunyeItem(String title, String value, Color textColor, Color subtleColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: subtleColor,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
