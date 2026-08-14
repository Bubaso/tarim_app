import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  /// Üst bilgi çubuğu (ticker/piyasa şeridi) arka planı, koyu vurgu alanları, başlık üzerindeki gradient'in koyu tonu
  static const Color darkGreen = Color(0xFF2F4B2E);

  /// Ana marka rengi — butonlar, linkler, kategori rozetleri (badge), aktif ikonlar, bölüm başlığı alt çizgisi
  static const Color primaryGreen = Color(0xFF5C8A4A);

  /// Görsel yer tutucu (placeholder) arka planları, ikincil vurgular, ayırıcı çizgiler
  static const Color wheat = Color(0xFFC9A15A);

  /// Sayfa/uygulama genel arka plan rengi (scaffold background)
  static const Color creamBackground = Color(0xFFF6F1E7);

  /// Ana gövde metin rengi, ikon rengi (koyu kontrast gereken yerlerde)
  static const Color earthText = Color(0xFF3A2E20);

  /// Uygulamadaki **tek** onaylı kırmızı: "son dakika" etiketi ve YYT özel
  /// dosya kimliği.
  ///
  /// Bölüm başlıklarında, rozetlerde veya hover renklerinde kullanılmaz —
  /// her bölüme ayrı bir vurgu rengi vermek marka kimliğini siliyor ve
  /// amatör bir gökkuşağı etkisi yaratıyor. Bölüm ayrımı tipografi ve
  /// boşlukla yapılır; vurgu gerektiğinde [primaryGreen] (koyu temada
  /// [wheat]) kullanılır.
  static const Color alertRed = Color(0xFFD32F2F);

  /// Emtia fiyatı düşüşü. Yalnızca fiyat şeridinde ve fiyat grafiğinde.
  ///
  /// [alertRed] bilerek kullanılmıyor: o renk "son dakika" demek. Buğday
  /// fiyatı yüzde yarım gerilediğinde sayfada son dakika haberiyle aynı
  /// kırmızıyı yakmak, iki uyarıyı da değersizleştirir. Bu kiremit tonu
  /// kahverengiye kaçtığı için toprak paletinin içinde durur ve düşüşü
  /// bağırmadan bildirir.
  ///
  /// Yükseliş için ayrı bir renk yok: [primaryGreen] zaten yeşil.
  static const Color marketDown = Color(0xFF9C4A3C);

  /// Bölüm ikonları, aktif durumlar, hover kenarlıkları için tek vurgu rengi.
  /// Koyu zeminde [primaryGreen] yeterli kontrast vermediği için [wheat]'e döner.
  static Color accentFor({required bool isDark}) => isDark ? wheat : primaryGreen;
}
