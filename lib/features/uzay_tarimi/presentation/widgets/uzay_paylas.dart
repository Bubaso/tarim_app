import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/brand_icons.dart';
import '../uzay_tasarim.dart';

/// Künyedeki paylaş satırı.
///
/// ══ NEDEN KÜNYEDE, NEDEN TEPEDE DEĞİL ════════════════════════════════════
/// Dosyanın üstünde geri düğmesinden başka hiçbir şey yok ve bu bilerek:
/// akış on dokuz durak ve her çerçeve okumayı böler. Paylaş düğmesi okurun
/// dosyayı BİTİRDİĞİ yerde duruyor — paylaşmaya karar vermek için önce
/// okumak gerekiyor. Portalın kendi geleneği de bu (bkz. Turkuaz şeridi:
/// "şeridin işi çağırmak, paylaşmak değil").
///
/// ══ NEDEN KÜÇÜK ══════════════════════════════════════════════════════════
/// Künye dosyanın en sessiz sayfası: belgeler, künyeler, sınırlar. Oraya
/// renkli büyük düğmeler koymak sayfanın tonunu bozardı. Düğmeler dosyanın
/// kendi pembesinde, ince çerçeveli ve küçük; marka renkleri yalnız
/// WhatsApp ve X ikonlarının kendisinde.
///
/// ══ PAYLAŞILAN ADRES GİRİŞE DÜŞÜRÜYOR ════════════════════════════════════
/// Bağlantı `/uzayda-tarim`. Alan adı çalışma anında okunuyor (`Uri.base`),
/// yani yerelde yerel, canlıda canlı adres paylaşılıyor — elle yazılmış bir
/// alan adı bir gün yanlış yere götürürdü.
///
/// Bağlantıyı açan kişi giriş animasyonundan başlıyor: animasyon oturum
/// başına bir kez oynuyor ve paylaşılan bir bağlantı her zaman yeni bir
/// oturum demek. Ek bir işaret ya da sorgu parametresi gerekmiyor.
class UzayPaylas extends StatelessWidget {
  final bool isEn;

  const UzayPaylas({super.key, required this.isEn});

  static const _uretimAdresi = 'https://tarimportali.net';

  String get _adres {
    final kok = kIsWeb ? Uri.base.origin : _uretimAdresi;
    return '$kok/uzayda-tarim';
  }

  String get _baslik => isEn ? 'Farming in Space' : 'Uzayda Tarım';

  String get _ozet => isEn
      ? 'A hundred years of trying to grow food beyond Earth.'
      : 'Dünya dışında yemek yetiştirme çabasının yüz yılı.';

  void _yerli(BuildContext context) {
    final kutu = context.findRenderObject() as RenderBox?;
    try {
      SharePlus.instance.share(ShareParams(
        text: '$_baslik\n$_ozet\n\n$_adres',
        sharePositionOrigin:
            kutu != null ? kutu.localToGlobal(Offset.zero) & kutu.size : null,
      ));
    } catch (_) {
      _kopyala(context);
    }
  }

  void _kopyala(BuildContext context) {
    Clipboard.setData(ClipboardData(text: _adres));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isEn ? 'Link copied.' : 'Bağlantı kopyalandı.'),
        duration: const Duration(seconds: 2),
        backgroundColor: UzayRenk.yuzey,
      ),
    );
  }

  Future<void> _ac(Uri u) async {
    try {
      if (await canLaunchUrl(u)) {
        await launchUrl(u, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      // Açılamazsa sessiz: paylaşmanın öteki yolları yanında duruyor.
    }
  }

  @override
  Widget build(BuildContext context) {
    final metin = '$_baslik\n$_ozet\n\n$_adres';
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 4),
          child: Text(
            isEn ? 'Share this dossier' : 'Bu dosyayı paylaş',
            style: UzayYazi.kunye(context).copyWith(fontSize: 12.5),
          ),
        ),
        _Dugme(
          ikon: const Icon(Icons.share_rounded,
              size: 15, color: UzayRenk.led),
          etiket: isEn ? 'Share' : 'Paylaş',
          onBas: () => _yerli(context),
        ),
        _Dugme(
          ikon: const Icon(Icons.link_rounded, size: 15, color: UzayRenk.led),
          etiket: isEn ? 'Copy link' : 'Bağlantıyı kopyala',
          onBas: () => _kopyala(context),
        ),
        _Dugme(
          ikon: const Icon(BrandIcons.whatsapp,
              size: 14, color: Color(0xFF25D366)),
          etiket: 'WhatsApp',
          onBas: () => _ac(Uri.parse(
              'https://api.whatsapp.com/send?text=${Uri.encodeComponent(metin)}')),
        ),
        _Dugme(
          ikon: const Icon(BrandIcons.x, size: 12, color: UzayRenk.metin),
          etiket: 'X',
          onBas: () => _ac(Uri.parse(
              'https://twitter.com/intent/tweet?text=${Uri.encodeComponent('$_baslik — $_ozet')}'
              '&url=${Uri.encodeComponent(_adres)}')),
        ),
      ],
    );
  }
}

class _Dugme extends StatelessWidget {
  final Widget ikon;
  final String etiket;
  final VoidCallback onBas;

  const _Dugme({required this.ikon, required this.etiket, required this.onBas});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: etiket,
      child: Tooltip(
        message: etiket,
        child: Material(
          color: UzayRenk.led.withValues(alpha: 0.10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
            side: BorderSide(color: UzayRenk.led.withValues(alpha: 0.28)),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onBas,
            // 36 nokta: künyenin ölçeğinde kalacak kadar küçük, parmakla
            // ıskalanmayacak kadar büyük.
            child: SizedBox(width: 36, height: 36, child: Center(child: ikon)),
          ),
        ),
      ),
    );
  }
}
