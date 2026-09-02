import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Kartların üzerine gelince (`MouseRegion.onEnter`) uyguladığı hover görselini
/// yalnızca fare-birincil platformlarda aç.
///
/// Neden: Flutter web'de dokunmatik cihazlarda dokunma anında sahte bir
/// `onEnter` üretiliyor ama karşılığında `onExit` gelmiyor. Sonuç: kart
/// başlığı yeşile dönüp öyle kalıyor (özellikle ekran değişip geri gelince).
/// Dokunmatikte hover diye bir şey zaten yok; görselini hiç açmamak doğru UX.
bool get hoverPointerLikely {
  if (!kIsWeb) {
    return defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux;
  }
  return defaultTargetPlatform != TargetPlatform.iOS &&
      defaultTargetPlatform != TargetPlatform.android;
}
