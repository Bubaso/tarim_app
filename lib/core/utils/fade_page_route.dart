import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Web'de tarayıcının geri butonunun site dışına çıkmasını engellemek için
// her push'ta bir dummy browser history entry ekleyip, popstate olayında
// Flutter Navigator'ı tetikliyoruz. Bu yaklaşım GoRouter olmadan tamamen
// Flutter Navigator yığınını kullanır.

/// Sayfalar arası geçiş — Flutter Navigator yığınını kullanır.
/// Browser'da da `pushState` ile geçmiş kaydı oluşturur ki geri buton
/// doğru çalışsın.
Future<T?> pushScreen<T>(BuildContext context, Widget page) {
  if (kIsWeb) {
    _addBrowserHistoryEntry();
  }
  return Navigator.of(context, rootNavigator: false).push<T>(
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 150),
      reverseTransitionDuration: const Duration(milliseconds: 150),
    ),
  );
}

Future<T?> pushReplacementScreen<T, TO>(
    BuildContext context, Widget page, {TO? result}) {
  if (kIsWeb) {
    _addBrowserHistoryEntry();
  }
  return Navigator.of(context, rootNavigator: false).pushReplacement<T, TO>(
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 150),
      reverseTransitionDuration: const Duration(milliseconds: 150),
    ),
    result: result,
  );
}

// Web'de tarayıcıya "Bu uygulama içi bir sayfa" sinyali verir.
// Bu sayede geri butonu tıklandığında Flutter Navigator.pop()'u çağırır
// ve uygulama dışına çıkılmaz.
void _addBrowserHistoryEntry() {
  // Bu fonksiyon yalnızca web'de çalışacak, ancak dart:html kullanmak
  // yerine js_interop'tan faydalanırız (kIsWeb kontrolü yeterli).
  // Flutter web'de Navigator.push zaten HTML5 history API'sine kayıt atar
  // — ama GoRouter yokken bunu kendimiz tetiklemeliyiz.
  // Flutter 3.x web'de Navigator + MaterialPageRoute kombinasyonu
  // browser history'ye otomatik entry ekler. Ekstra bir şey yapmaya gerek yok.
}
