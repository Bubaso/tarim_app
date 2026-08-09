import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Sayfalar arası geçiş — Flutter Navigator yığınını kullanır.
/// Browser'da `RouteSettings` sayesinde Flutter'ın yerleşik geçmiş (history)
/// senkronizasyonunu tetikler, böylece iOS PWA sağa kaydırarak geri gelme 
/// (swipe back) hareketi sorunsuz çalışır.
Future<T?> pushScreen<T>(BuildContext context, Widget page) {
  return Navigator.of(context, rootNavigator: false).push<T>(
    PageRouteBuilder(
      settings: RouteSettings(name: '/?page=${page.runtimeType}_${DateTime.now().millisecondsSinceEpoch}'),
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
  return Navigator.of(context, rootNavigator: false).pushReplacement<T, TO>(
    PageRouteBuilder(
      settings: RouteSettings(name: '/?page=${page.runtimeType}_${DateTime.now().millisecondsSinceEpoch}'),
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
