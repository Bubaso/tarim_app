import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router/app_router.dart';

/// Sayfalar arası geçiş — GoRouter üzerinden yapılır.
///
/// Her geçiş tarayıcı geçmişine gerçek bir kayıt ekler (multi-entry history).
/// Böylece iOS'ta kenardan sağa kaydırma hareketi uygulamadan çıkmak yerine
/// bir önceki sayfaya döner ve belge yeniden yüklenmediği için geri dönüşte
/// beyaz ekran oluşmaz.
///
/// Çağrı yerleri değişmez: verilen ekran widget'ı [routeFor] ile adresine
/// çevrilir. Router'da karşılığı olmayan bir ekran verilirse klasik
/// [Navigator.push] davranışına düşülür.
Future<T?> pushScreen<T extends Object?>(BuildContext context, Widget page) {
  final route = routeFor(page);
  if (route == null) {
    return Navigator.of(context).push<T>(
      MaterialPageRoute<T>(builder: (_) => page),
    );
  }
  return GoRouter.of(context).push<T>(route.path, extra: route.extra);
}

Future<T?> pushReplacementScreen<T extends Object?, TO extends Object?>(
  BuildContext context,
  Widget page, {
  TO? result,
}) {
  final route = routeFor(page);
  if (route == null) {
    return Navigator.of(context).pushReplacement<T, TO>(
      MaterialPageRoute<T>(builder: (_) => page),
      result: result,
    );
  }
  return GoRouter.of(context)
      .pushReplacement<T>(route.path, extra: route.extra);
}

/// Geri gitme — AppBar geri düğmeleri için.
///
/// Paylaşılan bir bağlantıyla doğrudan bir detay sayfası açıldığında altta
/// başka sayfa olmaz; bu durumda geri düğmesi hiçbir şey yapmasın diye değil,
/// ana sayfaya dönsün diye [GoRouter.canPop] kontrol edilir.
void popScreen(BuildContext context) {
  final router = GoRouter.of(context);
  if (router.canPop()) {
    router.pop();
  } else {
    router.go('/');
  }
}
