import 'package:tarim_app/core/theme/app_colors.dart';
import 'package:tarim_app/core/theme/brand_icons.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/responsive_breakpoints.dart';
import '../screens/about_screen.dart';
import '../../../../core/utils/fade_page_route.dart';
import '../../../legal/data/legal_documents.dart';
import '../../../legal/presentation/screens/legal_page_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import 'package:url_launcher/url_launcher.dart';

/// Footer'daki bir bağlantı: görünen etiket ve gideceği ekran.
///
/// Eskiden buraya yalnızca `List<String>` geçiliyordu ve altı bağlantının
/// hepsi [AboutScreen]'e gidiyordu. Etiket ile hedefi aynı yerde tutmak,
/// bir bağlantının sessizce yanlış sayfaya gitmesini imkânsız kılar.
typedef _FooterLink = ({String label, Widget target});

_FooterLink _link(String label, Widget target) => (label: label, target: target);

/// Slug'ı bilinen bir yasal belgeye giden bağlantı.
_FooterLink _legalLink(String slug, bool isEn) {
  final doc = legalDocs[slug]!;
  return _link(doc.title(isEn), LegalPageScreen(doc: doc));
}

class PortalFooter extends StatelessWidget {
  final bool isDark;

  const PortalFooter({super.key, required this.isDark});

  List<_FooterLink> _corporateLinks(bool isEn) => [
        _link(isEn ? 'About Us' : 'Hakkımızda', const AboutScreen()),
        _legalLink('kunye', isEn),
        _legalLink('iletisim', isEn),
        // Ayarların ASIL giriş noktası burası. AppBar'daki hesap menüsü
        // yalnızca masaüstünde çıkıyor, oysa kayıtlı cihazların tamamı
        // tarayıcı ve çoğu telefon. Footer üç ekranda birden (ana sayfa,
        // haftalık özet, kategori) ve her ekran boyutunda görünüyor.
        _link(isEn ? 'Notifications & Language' : 'Bildirimler ve Dil',
            const SettingsScreen()),
      ];

  List<_FooterLink> _legalLinks(bool isEn) => [
        _legalLink('kullanim-kosullari', isEn),
        _legalLink('gizlilik', isEn),
        _legalLink('cerezler', isEn),
      ];

  @override
  Widget build(BuildContext context) {
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    
    final bgColor = isDark ? AppColors.darkGreen : const Color(0xFFF0F0F0);
    final textColor = isDark ? AppColors.wheat : const Color(0xFF555555);
    final linkColor = isDark ? const Color(0xFFE6EDF3) : AppColors.earthText;
    final dividerColor = isDark ? AppColors.wheat : const Color(0xFFD0D0D0);

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
                      child: _buildLinks(context, isEn ? 'Corporate' : 'Kurumsal', _corporateLinks(isEn), linkColor, textColor),
                    ),
                    Expanded(
                      flex: 1,
                      child: _buildLinks(context, isEn ? 'Legal' : 'Yasal', _legalLinks(isEn), linkColor, textColor),
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
                        Expanded(child: _buildLinks(context, isEn ? 'Corporate' : 'Kurumsal', _corporateLinks(isEn), linkColor, textColor)),
                        Expanded(child: _buildLinks(context, isEn ? 'Legal' : 'Yasal', _legalLinks(isEn), linkColor, textColor)),
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
            Image.asset(
              'assets/images/logo_tp.png',
              height: 48,
              errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.eco_rounded, color: Colors.green, size: 32),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TARIM PORTALI',
                  style: GoogleFonts.playfairDisplay(
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                    color: titleColor,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  'TARIMIN DOĞRU ADRESİ',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: AppColors.primaryGreen,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
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

  Widget _buildLinks(BuildContext context, String title, List<_FooterLink> links, Color titleColor, Color linkColor) {
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
        const SizedBox(height: 8),
        ...links.map((link) => InkWell(
              onTap: () => pushScreen(context, link.target),
              // 44 px: dokunma hedefi minimumu. 14 px metin + 12 px boşluk
              // yaklaşık 29 px ediyordu ve telefonda ıskalanıyordu.
              child: Container(
                constraints: const BoxConstraints(minHeight: 44),
                alignment: Alignment.centerLeft,
                child: Text(
                  link.label,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: linkColor,
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
            _SocialIcon(
              icon: BrandIcons.facebook,
              label: 'Facebook',
              color: iconColor,
              url: 'https://facebook.com',
            ),
            const SizedBox(width: 8),
            _SocialIcon(
              icon: BrandIcons.instagram,
              label: 'Instagram',
              color: iconColor,
              url: 'https://instagram.com',
            ),
            const SizedBox(width: 8),
            _SocialIcon(
              icon: BrandIcons.x,
              label: 'X (Twitter)',
              color: iconColor,
              url: 'https://x.com',
            ),
          ],
        ),
      ],
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final String url;

  const _SocialIcon({
    required this.icon,
    required this.label,
    required this.color,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () async {
          final uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri);
          }
        },
        // 44x44 → erişilebilir dokunma alanı.
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: Icon(icon, color: color, size: 20, semanticLabel: label),
          ),
        ),
      ),
    );
  }
}
