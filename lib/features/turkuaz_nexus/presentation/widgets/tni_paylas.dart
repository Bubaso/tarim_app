import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/brand_icons.dart';
import '../tni_tasarim.dart';

/// Sayfanın paylaşım çubuğu.
///
/// Dosya sayfalarındaki `DossierShareBar` ile AYNI davranış — aynı beş düğme,
/// aynı sıra, aynı yedekleme (yerel paylaşım açılamazsa panoya kopyalar).
/// Ayrı bir dosya olmasının tek sebebi tasarım: o çubuk `DossierTheme`
/// istiyor, bu sayfanın teması ise `TniRenk`. Davranışı kopyalamak yerine
/// temayı çevirmek, iki sayfanın paylaşım davranışını birbirinden
/// ayırabilirdi.
///
/// ADRES ÇALIŞMA ANINDA KURULUYOR. Sabit bir alan adı yazılsaydı yerel
/// önizlemede paylaşılan bağlantı canlıyı gösterirdi; `Uri.base.origin`
/// sayfanın kendi kaynağını veriyor. Web dışında taban adrese düşüyor.
class TniPaylas extends StatelessWidget {
  final bool isEn;
  final bool karanlik;

  /// Paylaşılan metnin ikinci satırı — sayfanın tek cümlelik tanımı.
  final String ozet;

  /// Paylaşılan metnin ilk satırı — girişimin adı.
  final String baslik;

  const TniPaylas({
    super.key,
    required this.isEn,
    required this.karanlik,
    required this.baslik,
    required this.ozet,
  });

  static const String _yayinKaynagi = 'https://tarimportali.net';

  String get _adres {
    final taban = kIsWeb ? Uri.base.origin : _yayinKaynagi;
    return '$taban$turkuazPath';
  }

  String get _metin => '$baslik\n$ozet\n\n$_adres';

  void _yerel(BuildContext context) {
    final kutu = context.findRenderObject() as RenderBox?;
    try {
      Share.share(
        _metin,
        sharePositionOrigin:
            kutu != null ? kutu.localToGlobal(Offset.zero) & kutu.size : null,
      );
    } catch (_) {
      _kopyala(context);
    }
  }

  void _kopyala(BuildContext context) {
    Clipboard.setData(ClipboardData(text: _adres));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isEn
            ? 'Link copied to clipboard!'
            : 'Bağlantı panoya kopyalandı!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _ac(Uri birincil, [Uri? yedek]) async {
    try {
      if (await canLaunchUrl(birincil)) {
        await launchUrl(birincil);
      } else if (yedek != null) {
        await launchUrl(yedek, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final k = karanlik;   // sayfanın geri kalanıyla aynı kaynak
    final zemin = TniRenk.iklim(k).withValues(alpha: 0.1);
    final kenar = TniRenk.iklim(k).withValues(alpha: 0.32);
    final simge = TniRenk.iklim(k);
    const e = Uri.encodeComponent;

    return Wrap(
      alignment: WrapAlignment.end,
      spacing: 6,
      runSpacing: 6,
      children: [
        _Dugme(
          simge: Icon(Icons.share_rounded, size: 14, color: simge),
          zemin: zemin,
          kenar: kenar,
          ipucu: isEn ? 'Share' : 'Paylaş',
          bas: () => _yerel(context),
        ),
        _Dugme(
          simge: Icon(Icons.copy_rounded, size: 14, color: simge),
          zemin: zemin,
          kenar: kenar,
          ipucu: isEn ? 'Copy link' : 'Bağlantıyı kopyala',
          bas: () => _kopyala(context),
        ),
        _Dugme(
          simge: const Icon(BrandIcons.whatsapp,
              size: 14, color: Color(0xFF25D366)),
          zemin: zemin,
          kenar: kenar,
          ipucu: 'WhatsApp',
          bas: () => _ac(
            Uri.parse('whatsapp://send?text=${e(_metin)}'),
            Uri.parse('https://api.whatsapp.com/send?text=${e(_metin)}'),
          ),
        ),
        _Dugme(
          simge: Icon(BrandIcons.x, size: 12, color: TniRenk.metin(k)),
          zemin: zemin,
          kenar: kenar,
          ipucu: 'X',
          bas: () => _ac(Uri.parse(
              'https://twitter.com/intent/tweet?text=${e('$baslik — $ozet')}'
              '&url=${e(_adres)}')),
        ),
        _Dugme(
          simge: const Icon(BrandIcons.linkedIn,
              size: 12, color: Color(0xFF0A66C2)),
          zemin: zemin,
          kenar: kenar,
          ipucu: 'LinkedIn',
          bas: () => _ac(Uri.parse(
              'https://www.linkedin.com/sharing/share-offsite/?url=${e(_adres)}')),
        ),
      ],
    );
  }
}

class _Dugme extends StatelessWidget {
  final Widget simge;
  final Color zemin;
  final Color kenar;
  final String ipucu;
  final VoidCallback bas;

  const _Dugme({
    required this.simge,
    required this.zemin,
    required this.kenar,
    required this.ipucu,
    required this.bas,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: ipucu,
      child: InkWell(
        onTap: bas,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: zemin,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: kenar, width: 1),
          ),
          child: SizedBox(
              width: 16, height: 16, child: Center(child: simge)),
        ),
      ),
    );
  }
}
