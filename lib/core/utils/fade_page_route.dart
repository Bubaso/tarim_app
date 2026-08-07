import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

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
      transitionDuration: const Duration(milliseconds: 100),
      reverseTransitionDuration: const Duration(milliseconds: 100),
    ),
  );
}

Future<T?> pushReplacementScreen<T, TO>(
    BuildContext context, Widget page, {TO? result}) {
  if (kIsWeb) {
    // If replacing, we might not want to add a new history entry, but to be safe:
    // we can skip adding an entry, or add it depending on behavior.
  }
  return Navigator.of(context, rootNavigator: false).pushReplacement<T, TO>(
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 100),
      reverseTransitionDuration: const Duration(milliseconds: 100),
    ),
    result: result,
  );
}

// Web'de tarayıcıya "Bu uygulama içi bir sayfa" sinyali verir.
// Bu sayede geri butonu tıklandığında Flutter Navigator.pop()'u çağırır
// ve uygulama dışına çıkılmaz.
void _addBrowserHistoryEntry() {
  if (kIsWeb) {
    // We push a new state to the browser history with the exact same URL.
    // This allows the browser back button to fire a popstate event,
    // which Flutter catches and maps to Navigator.pop() instead of exiting the site.
    web.window.history.pushState(
      null,
      '',
      web.window.location.href,
    );
  }
}
