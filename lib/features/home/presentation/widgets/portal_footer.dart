import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/responsive_breakpoints.dart';
import '../screens/about_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class PortalFooter extends StatelessWidget {
  final bool isDark;

  const PortalFooter({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    
    final bgColor = isDark ? const Color(0xFF161B22) : const Color(0xFFF0F0F0);
    final textColor = isDark ? const Color(0xFF8B949E) : const Color(0xFF555555);
    final linkColor = isDark ? const Color(0xFFE6EDF3) : const Color(0xFF111111);
    final dividerColor = isDark ? const Color(0xFF30363D) : const Color(0xFFD0D0D0);

    final isDesktop = ResponsiveBreakpoints.isDesktopOrLarger(context);

    return Container(
      width: double.infinity,
      color: bgColor,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 64 : 24,
        vertical: 48,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              if (isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildBrand(linkColor, textColor),
                    ),
                    const SizedBox(width: 48),
                    Expanded(
                      flex: 1,
                      child: _buildLinks(context, isEn ? 'Corporate' : 'Kurumsal', isEn ? ['About Us', 'Imprint', 'Contact'] : ['Hakkımızda', 'Künye', 'İletişim'], linkColor, textColor),
                    ),
                    Expanded(
                      flex: 1,
                      child: _buildLinks(context, isEn ? 'Legal' : 'Yasal', isEn ? ['Terms of Use', 'Privacy Policy', 'Cookies'] : ['Kullanım Koşulları', 'Gizlilik Politikası', 'Çerezler'], linkColor, textColor),
                    ),
                    Expanded(
                      flex: 1,
                      child: _buildSocials(isEn, linkColor, textColor),
                    ),
                  ],
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBrand(linkColor, textColor),
                    const SizedBox(height: 32),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildLinks(context, isEn ? 'Corporate' : 'Kurumsal', isEn ? ['About Us', 'Imprint', 'Contact'] : ['Hakkımızda', 'Künye', 'İletişim'], linkColor, textColor)),
                        Expanded(child: _buildLinks(context, isEn ? 'Legal' : 'Yasal', isEn ? ['Terms of Use', 'Privacy Policy', 'Cookies'] : ['Kullanım Koşulları', 'Gizlilik Politikası', 'Çerezler'], linkColor, textColor)),
                      ],
                    ),
                    const SizedBox(height: 32),
                    _buildSocials(isEn, linkColor, textColor),
                  ],
                ),
              const SizedBox(height: 48),
              Divider(color: dividerColor),
              const SizedBox(height: 24),
              Text(
                isEn 
                  ? '© 2026 Tarım Portalı — All rights reserved. This site operates in accordance with Turkish media law.'
                  : '© 2026 Tarım Portalı — Tüm hakları saklıdır. Bu site Türkiye medya hukukuna uygun olarak yayın yapmaktadır.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrand(Color titleColor, Color descColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.eco_rounded, color: Colors.green, size: 28),
            const SizedBox(width: 8),
            Text(
              'TARIM PORTALI',
              style: GoogleFonts.playfairDisplay(
                fontWeight: FontWeight.w900,
                fontSize: 22,
                color: titleColor,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Builder(
          builder: (context) {
            final isEn = Localizations.localeOf(context).languageCode == 'en';
            return Text(
              isEn 
                ? 'Turkey\'s most up-to-date and reliable agriculture, livestock, and economy news source. Be the first to learn about industry innovations.'
                : 'Türkiye\'nin en güncel ve güvenilir tarım, hayvancılık ve ekonomi haber kaynağı. Sektördeki yenilikleri ilk siz öğrenin.',
              style: GoogleFonts.inter(
                fontSize: 14,
                height: 1.5,
                color: descColor,
              ),
            );
          }
        ),
      ],
    );
  }

  Widget _buildLinks(BuildContext context, String title, List<String> links, Color titleColor, Color linkColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: titleColor,
          ),
        ),
        const SizedBox(height: 16),
        ...links.map((link) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    // Navigate to About screen
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => const AboutScreen(),
                        transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
                      ),
                    );
                  },
                  child: Text(
                    link,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: linkColor,
                    ),
                  ),
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildSocials(bool isEn, Color titleColor, Color iconColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isEn ? 'Follow Us' : 'Bizi Takip Edin',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: titleColor,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _SocialIcon(icon: Icons.facebook_rounded, color: iconColor, url: 'https://facebook.com'),
            const SizedBox(width: 16),
            _SocialIcon(icon: Icons.camera_alt_outlined, color: iconColor, url: 'https://instagram.com'),
            const SizedBox(width: 16),
            _SocialIcon(icon: Icons.alternate_email_rounded, color: iconColor, url: 'https://x.com'), // X / Twitter
          ],
        ),
      ],
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String url;

  const _SocialIcon({required this.icon, required this.color, required this.url});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () async {
          final uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri);
          }
        },
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }
}
