import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/brand_icons.dart';
import '../data/yz_iskelet.g.dart';
import 'yz_tasarim.dart';
import 'yz_yollar.dart';

/// Bölümün merkez sayfasını paylaşan küçük ikon satırı — portalın öteki
/// dosyalarındaki paylaş satırıyla aynı aile (bkz. `UzayPaylas`).
///
/// Kullanıcı (19 Kas 2026): merkez sayfada "Başlıklar" ve "Son haberler"
/// başlıklarının hemen üstünde; bağlantı doğrudan bu sayfayı açsın. Adres
/// `/yapay-zeka-dijital-tarim`; alan adı çalışma anında okunuyor
/// (`Uri.base`), canlıda canlı adres paylaşılıyor. Sayfanın paylaşım kartı
/// (`paylasim_sayfasi.mjs`) bu adrese bağlı.
class YzPaylasSatiri extends StatelessWidget {
  const YzPaylasSatiri({super.key, required this.en});

  final bool en;

  static const _uretimAdresi = 'https://tarimportali.net';

  String get _adres => '${kIsWeb ? Uri.base.origin : _uretimAdresi}$yzPath';

  String get _baslik => en ? kYzAdEn : kYzAdTr;

  String get _ozet => en
      ? 'Where artificial intelligence and digital technology in farming stand today: a reference file built on measured, sourced figures.'
      : 'Yapay zekâ ve dijital teknolojiler tarımda bugün nerede duruyor: ölçülmüş, kaynaklı rakamlar üzerine kurulan bir başvuru dosyası.';

  String get _metin => '$_baslik\n$_ozet\n\n$_adres';

  Future<void> _yerli(BuildContext context) async {
    final kutu = context.findRenderObject() as RenderBox?;
    try {
      final sonuc = await SharePlus.instance.share(ShareParams(
        text: _metin,
        sharePositionOrigin: kutu != null ? kutu.localToGlobal(Offset.zero) & kutu.size : null,
      ));
      // Web'de share_plus başarılı paylaşımdan sonra da `unavailable`
      // döndürüyor; orada kopyalama yalnız hata durumunda.
      if (!kIsWeb && sonuc.status == ShareResultStatus.unavailable && context.mounted) {
        _kopyala(context);
      }
    } catch (_) {
      if (context.mounted) _kopyala(context);
    }
  }

  void _kopyala(BuildContext context) {
    Clipboard.setData(ClipboardData(text: _adres));
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(
      content: Text(en ? 'Link copied.' : 'Bağlantı kopyalandı.'),
      duration: const Duration(seconds: 2),
      backgroundColor: YzRenk.makine,
    ));
  }

  Future<void> _ac(Uri u) async {
    try {
      await launchUrl(u, mode: LaunchMode.externalApplication);
    } catch (_) {
      // Açılamazsa sessiz: paylaşmanın öteki yolları yanında duruyor.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _Dugme(
          ikon: const Icon(Icons.share_rounded, size: 15, color: YzRenk.makine),
          etiket: en ? 'Share' : 'Paylaş',
          onBas: () => _yerli(context),
        ),
        _Dugme(
          ikon: const Icon(Icons.link_rounded, size: 15, color: YzRenk.makine),
          etiket: en ? 'Copy link' : 'Bağlantıyı kopyala',
          onBas: () => _kopyala(context),
        ),
        _Dugme(
          ikon: const Icon(BrandIcons.whatsapp, size: 14, color: Color(0xFF25D366)),
          etiket: 'WhatsApp',
          onBas: () => _ac(Uri.parse('https://api.whatsapp.com/send?text=${Uri.encodeComponent(_metin)}')),
        ),
        _Dugme(
          ikon: const Icon(BrandIcons.x, size: 12, color: YzRenk.murekkep),
          etiket: 'X',
          onBas: () => _ac(Uri.parse('https://twitter.com/intent/tweet?text='
              '${Uri.encodeComponent('$_baslik — $_ozet')}&url=${Uri.encodeComponent(_adres)}')),
        ),
        _Dugme(
          ikon: const Icon(BrandIcons.linkedIn, size: 13, color: Color(0xFF0A66C2)),
          etiket: 'LinkedIn',
          onBas: () => _ac(Uri.parse(
              'https://www.linkedin.com/sharing/share-offsite/?url=${Uri.encodeComponent(_adres)}')),
        ),
      ],
    );
  }
}

class _Dugme extends StatelessWidget {
  const _Dugme({required this.ikon, required this.etiket, required this.onBas});

  final Widget ikon;
  final String etiket;
  final VoidCallback onBas;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: etiket,
      child: Tooltip(
        message: etiket,
        child: Material(
          color: YzRenk.makineAcik,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
            side: BorderSide(color: YzRenk.makine.withValues(alpha: 0.22)),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onBas,
            child: SizedBox(width: 36, height: 36, child: Center(child: ikon)),
          ),
        ),
      ),
    );
  }
}
