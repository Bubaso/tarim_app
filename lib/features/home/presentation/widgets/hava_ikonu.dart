import 'package:flutter/material.dart';

// ══════════════════════════════════════════════════════════════════════════
//  Hava durumu ikonu — emoji DEĞİL, ikon fontu
// ──────────────────────────────────────────────────────────────────────────
//  6 Kasım 2026 anasayfa denetimi (A3): hava durumu çipi glifleri emoji
//  olarak yazıyordu (☀️ 🌙 ⛅ ☁️ 🌧️ ⛈️ ❄️). CanvasKit'in emoji kapsaması
//  yok; Flutter eksik karakterleri çizebilmek için Noto sembol fontlarını
//  indiriyordu:
//
//      NotoSansSymbols2   374 KB
//      NotoSansSymbols     67 KB
//                        ───────
//                        441 KB   → ekranda 16 piksellik TEK bir glif için
//
//  Tarayıcı konsolu bunu her açılışta söylüyordu:
//  "Could not find a set of Noto fonts to display all missing characters."
//
//  Material ikon fontu zaten pakette ve budamadan sonra 31 KB; buraya
//  eklenen ikonların maliyeti birkaç yüz bayt.
//
//  İKİNCİ KAZANÇ: emoji temaya uymuyor. Koyu temada kendi renginde kalıyor
//  ve çipin geri kalanıyla uyuşmuyordu; ikon metin rengini alıyor.
//
//  Kodlar OpenWeather'ın ikon kodları (`01d`, `10n`…); `d`/`n` eki gündüz
//  ve geceyi ayırıyor ve o ayrım korunuyor — gece açık havada güneş
//  çizmek yanlış olurdu.
// ══════════════════════════════════════════════════════════════════════════

/// OpenWeather ikon kodunu Material ikonuna çevirir.
IconData havaIkonu(String kod) {
  switch (kod) {
    case '01d':
      return Icons.wb_sunny_rounded;
    case '01n':
      return Icons.nights_stay_rounded;
    case '02d':
      return Icons.wb_cloudy_rounded;
    case '02n':
      return Icons.nightlight_round;
    case '03d':
    case '03n':
    case '04d':
    case '04n':
      return Icons.cloud_rounded;
    case '09d':
    case '09n':
      return Icons.grain_rounded;
    case '10d':
    case '10n':
      return Icons.water_drop_rounded;
    case '11d':
    case '11n':
      return Icons.thunderstorm_rounded;
    case '13d':
    case '13n':
      return Icons.ac_unit_rounded;
    case '50d':
    case '50n':
      return Icons.foggy;
    default:
      return Icons.wb_cloudy_rounded;
  }
}

/// Open-Meteo'nun WMO hava kodunu Material ikonuna çevirir.
///
/// Ayrı bir işlev: iki sağlayıcı iki ayrı kodlama kullanıyor ve tek bir
/// eşlemeye zorlamak ikisini de bulanıklaştırırdı.
IconData havaIkonuWmo(int kod) {
  if (kod == 0) return Icons.wb_sunny_rounded;
  if (kod == 1 || kod == 2) return Icons.wb_cloudy_rounded;
  if (kod == 3) return Icons.cloud_rounded;
  if (kod >= 45 && kod <= 48) return Icons.foggy;
  if (kod >= 51 && kod <= 67) return Icons.water_drop_rounded;
  if (kod >= 71 && kod <= 77) return Icons.ac_unit_rounded;
  if (kod >= 80 && kod <= 82) return Icons.grain_rounded;
  if (kod >= 95) return Icons.thunderstorm_rounded;
  return Icons.cloud_rounded;
}
