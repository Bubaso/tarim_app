import 'package:flutter/widgets.dart';

/// Sosyal platform marka işaretleri.
///
/// Jenerik Material ikonları (mesaj balonu = WhatsApp, çanta = LinkedIn gibi)
/// marka yerine geçmez ve güven algısını zedeler. Buradaki glifler Font Awesome
/// 7 "Brands" setinden geliyor; font `pubspec.yaml` içinde `FontAwesomeBrands`
/// ailesi olarak bağlı ve release derlemesinde yalnızca aşağıdaki kod
/// noktalarına indirgeniyor.
///
/// Lisans: assets/fonts/FontAwesome-LICENSE.txt
class BrandIcons {
  BrandIcons._();

  static const String _family = 'FontAwesomeBrands';

  static const IconData whatsapp = IconData(0xf232, fontFamily: _family);
  static const IconData x = IconData(0xe61b, fontFamily: _family);
  static const IconData linkedIn = IconData(0xf0e1, fontFamily: _family);
  static const IconData facebook = IconData(0xf39e, fontFamily: _family);
  static const IconData instagram = IconData(0xf16d, fontFamily: _family);
}
