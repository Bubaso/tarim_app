import 'package:flutter/widgets.dart';

/// Tarayıcının bildirdiği metin aralığı tercihleri anlamsız büyüklükteyse
/// (Android WebView'da sistem yazısı büyütülmüşken satır çarpanı ~624,9)
/// hepsini düşürür. Flutter 3.41'de bu değer bütün Text'leri ekranın dışına
/// itiyor ve sayfa boş görünüyor (flutter#190350, 3.47.0'da düzeldi).
/// Makul değerler (ör. 1,5 satır aralığı tercihi) olduğu gibi kalır;
/// okurun yazı büyütmesi (textScaler) hiç değişmez.
class MetinAraligiKoruyucusu extends StatelessWidget {
  const MetinAraligiKoruyucusu({super.key, required this.child});

  final Widget child;

  /// Bundan büyük satır çarpanı bir tercih değil, hata.
  static const double azamiSatirCarpani = 4;

  /// Harf ve kelime aralığı için mantıklı üst sınır (mantıksal piksel).
  static const double azamiAralik = 40;

  static bool bozuk(MediaQueryData m) {
    final s = m.lineHeightScaleFactorOverride;
    final h = m.letterSpacingOverride;
    final k = m.wordSpacingOverride;
    final p = m.paragraphSpacingOverride;
    return (s != null && (s > azamiSatirCarpani || s <= 0)) ||
        (h != null && h.abs() > azamiAralik) ||
        (k != null && k.abs() > azamiAralik) ||
        (p != null && p.abs() > azamiAralik * 10);
  }

  @override
  Widget build(BuildContext context) {
    final m = MediaQuery.maybeOf(context);
    if (m == null || !bozuk(m)) return child;
    return MediaQuery(
      data: m.applyTextStyleOverrides(
        lineHeightScaleFactorOverride: null,
        letterSpacingOverride: null,
        wordSpacingOverride: null,
        paragraphSpacingOverride: null,
      ),
      child: child,
    );
  }
}
