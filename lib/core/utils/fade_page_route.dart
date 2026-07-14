import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

Route createFadeRoute(Widget page, {String? routeName}) {
  // Using CupertinoPageRoute to enable native swipe-to-go-back gesture inside Flutter.
  // This prevents the PWA browser swipe back which causes a white screen reload.
  return CupertinoPageRoute(
    settings: RouteSettings(name: routeName ?? '/${page.runtimeType.toString()}'),
    builder: (context) => page,
  );
}

/// Web'de (PWA) tarayıcı geçmişinin (browser history) güncellenmesi için
/// Navigator.push yerine GoRouter kullanmasını sağlayan yardımcı metod.
Future<T?> pushScreen<T>(BuildContext context, Widget page) {
  GoRouter.of(context).push('/page/${page.runtimeType.toString()}', extra: page);
  return Future.value(null);
}

Future<T?> pushReplacementScreen<T, TO>(BuildContext context, Widget page, {TO? result}) {
  GoRouter.of(context).pushReplacement('/page/${page.runtimeType.toString()}', extra: page);
  return Future.value(null);
}
