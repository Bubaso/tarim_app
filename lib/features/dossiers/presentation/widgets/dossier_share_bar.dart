import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/brand_icons.dart';
import '../../data/models/country_dossier.dart';
import '../../data/models/dossier_theme.dart';

class DossierShareBar extends StatelessWidget {
  final DossierSummary ozet;
  final DossierTheme tema;
  final bool isEn;

  const DossierShareBar({
    super.key,
    required this.ozet,
    required this.tema,
    required this.isEn,
  });

  static const String _productionOrigin = 'https://tarim-app-2026.web.app';

  String _buildShareUrl() {
    final origin = kIsWeb ? Uri.base.origin : _productionOrigin;
    return '$origin${countryPath(ozet.slug)}';
  }

  void _shareNative(BuildContext context) {
    final url = _buildShareUrl();
    // Includes thesis as summary text
    final text = '${ozet.name(isEn)}\n${ozet.thesis(isEn)}\n\n$url';
        
    final box = context.findRenderObject() as RenderBox?;
    try {
      Share.share(
        text,
        sharePositionOrigin: box != null ? box.localToGlobal(Offset.zero) & box.size : null,
      );
    } catch (e) {
      _copyToClipboard(context);
    }
  }

  void _copyToClipboard(BuildContext context) {
    final url = _buildShareUrl();
    Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isEn ? 'Link copied to clipboard!' : 'Bağlantı panoya kopyalandı!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareToWhatsApp() async {
    final url = _buildShareUrl();
    final text = '${ozet.name(isEn)}\n${ozet.thesis(isEn)}\n\n$url';
        
    final whatsappAppUrl = Uri.parse('whatsapp://send?text=${Uri.encodeComponent(text)}');
    final whatsappWebUrl = Uri.parse('https://api.whatsapp.com/send?text=${Uri.encodeComponent(text)}');
    
    try {
      if (await canLaunchUrl(whatsappAppUrl)) {
        await launchUrl(whatsappAppUrl);
      } else {
        await launchUrl(whatsappWebUrl, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  void _shareToTwitter() async {
    final url = _buildShareUrl();
    final text = '${ozet.name(isEn)} - ${ozet.thesis(isEn)}';
    final twitterUrl = Uri.parse('https://twitter.com/intent/tweet?text=${Uri.encodeComponent(text)}&url=${Uri.encodeComponent(url)}');
    try {
      if (await canLaunchUrl(twitterUrl)) {
        await launchUrl(twitterUrl, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  void _shareToLinkedIn() async {
    final url = _buildShareUrl();
    final linkedInUrl = Uri.parse('https://www.linkedin.com/sharing/share-offsite/?url=${Uri.encodeComponent(url)}');
    try {
      if (await canLaunchUrl(linkedInUrl)) {
        await launchUrl(linkedInUrl, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = tema.vurgu.withValues(alpha: 0.1);
    final iconColor = tema.vurgu;

    return Wrap(
      alignment: WrapAlignment.end,
      spacing: 4,
      runSpacing: 4,
      children: [
        _ShareButton(
          icon: Icon(Icons.share_rounded, size: 14, color: iconColor),
          bgColor: bgColor,
          borderColor: tema.vurgu.withValues(alpha: 0.3),
          onTap: () => _shareNative(context),
          tooltip: isEn ? 'Share' : 'Paylaş',
        ),
        _ShareButton(
          icon: Icon(Icons.copy_rounded, size: 14, color: iconColor),
          bgColor: bgColor,
          borderColor: tema.vurgu.withValues(alpha: 0.3),
          onTap: () => _copyToClipboard(context),
          tooltip: isEn ? 'Copy Link' : 'Kopyala',
        ),
        _ShareButton(
          icon: const Icon(BrandIcons.whatsapp, size: 14, color: Color(0xFF25D366)),
          bgColor: bgColor,
          borderColor: tema.vurgu.withValues(alpha: 0.3),
          onTap: _shareToWhatsApp,
          tooltip: 'WhatsApp',
        ),
        _ShareButton(
          icon: Icon(BrandIcons.x, size: 12, color: tema.murekkep),
          bgColor: bgColor,
          borderColor: tema.vurgu.withValues(alpha: 0.3),
          onTap: _shareToTwitter,
          tooltip: 'X (Twitter)',
        ),
        _ShareButton(
          icon: const Icon(BrandIcons.linkedIn, size: 12, color: Color(0xFF0A66C2)),
          bgColor: bgColor,
          borderColor: tema.vurgu.withValues(alpha: 0.3),
          onTap: _shareToLinkedIn,
          tooltip: 'LinkedIn',
        ),
      ],
    );
  }
}

class _ShareButton extends StatelessWidget {
  final Widget icon;
  final Color bgColor;
  final Color borderColor;
  final VoidCallback onTap;
  final String tooltip;

  const _ShareButton({
    required this.icon,
    required this.bgColor,
    required this.borderColor,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: SizedBox(
            width: 16,
            height: 16,
            child: Center(child: icon),
          ),
        ),
      ),
    );
  }
}
