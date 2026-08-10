import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/fade_page_route.dart';
import '../../data/legal_documents.dart';

/// Künye, İletişim ve yasal metinlerin tamamını basan tek ekran.
///
/// Bu sayfaların yerleşimi aynı; yalnızca içerikleri farklı. Altı ayrı
/// `StatelessWidget` yazmak aynı 150 satırı altı kez kopyalamak olurdu ve
/// biri güncellendiğinde diğerleri geride kalırdı. İçerik
/// [legalDocs] içinde, biçim burada.
class LegalPageScreen extends StatelessWidget {
  final LegalDoc doc;

  const LegalPageScreen({super.key, required this.doc});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEn = Localizations.localeOf(context).languageCode == 'en';

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
        // Paylaşılan bir bağlantıyla doğrudan açıldığında altta sayfa olmaz;
        // varsayılan geri düğmesi o durumda hiç görünmezdi.
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
                  Icon(Icons.eco_rounded, color: accent, size: 24),
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
            // Okuma kolonu detay ekranıyla aynı: 800 px üzerinde satır uzunluğu
            // gözü yoruyor.
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc.title(isEn),
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _updatedLabel(doc.updatedAt, isEn),
                  style: GoogleFonts.robotoMono(
                    fontSize: AppTypography.minLabelSize,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                    color: subtleColor,
                  ),
                ),
                const SizedBox(height: 24),
                Container(height: 1, color: subtleColor.withValues(alpha: 0.4)),
                const SizedBox(height: 32),
                ...doc.blocks.map(
                  (b) => _Block(
                    block: b,
                    isEn: isEn,
                    textColor: textColor,
                    subtleColor: subtleColor,
                    accent: accent,
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

  String _updatedLabel(DateTime d, bool isEn) {
    final formatted = DateFormat.yMMMMd(isEn ? 'en_US' : 'tr_TR').format(d);
    return isEn ? 'Last updated: $formatted' : 'Son güncelleme: $formatted';
  }
}

class _Block extends StatelessWidget {
  final LegalBlock block;
  final bool isEn;
  final Color textColor;
  final Color subtleColor;
  final Color accent;

  const _Block({
    required this.block,
    required this.isEn,
    required this.textColor,
    required this.subtleColor,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    switch (block.kind) {
      case LegalBlockKind.heading:
        return Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 12),
          child: Text(
            block.text(isEn),
            style: AppTypography.headlineCard(context, color: textColor),
          ),
        );

      case LegalBlockKind.paragraph:
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            block.text(isEn),
            style: AppTypography.body(context, color: textColor),
          ),
        );

      case LegalBlockKind.bullets:
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: block.lines(isEn).map((line) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      // Madde işaretini ilk satırın x-yüksekliğine hizalar.
                      padding: const EdgeInsets.only(top: 8, right: 12),
                      child: Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        line,
                        style: AppTypography.body(context, color: textColor),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        );

      case LegalBlockKind.keyValue:
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.start,
            children: [
              SizedBox(
                width: 200,
                child: Text(
                  block.text(isEn),
                  style: AppTypography.meta(context, color: subtleColor)
                      .copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                block.value ?? '',
                style: AppTypography.body(context, color: textColor),
              ),
            ],
          ),
        );

      case LegalBlockKind.mailto:
        final address = block.value ?? '';
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: InkWell(
            onTap: () async {
              final uri = Uri(scheme: 'mailto', path: address);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              }
            },
            // 44 px: erişilebilir dokunma hedefi.
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 44),
              child: Row(
                children: [
                  Icon(Icons.mail_outline_rounded, size: 18, color: accent),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      address,
                      style: AppTypography.body(context, color: accent)
                          .copyWith(decoration: TextDecoration.underline),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
    }
  }
}
