import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Route createFadeRoute(Widget page, {String? routeName}) {
  // Using CupertinoPageRoute to enable native swipe-to-go-back gesture inside Flutter.
  // This prevents the PWA browser swipe back which causes a white screen reload.
  return CupertinoPageRoute(
    settings: RouteSettings(name: routeName ?? '/${page.runtimeType.toString()}'),
    builder: (context) => page,
  );
}

/// Web'de (PWA) tarayıcı geçmişinin (browser history) güncellenmesi için
/// Navigator.push yerine Navigator.pushNamed kullanılmasını sağlayan yardımcı metod.
Future<T?> pushScreen<T>(BuildContext context, Widget page) {
  return Navigator.of(context).pushNamed<T>(
    '/${page.runtimeType.toString()}',
    arguments: page,
  );
}

Future<T?> pushReplacementScreen<T, TO>(BuildContext context, Widget page, {TO? result}) {
  return Navigator.of(context).pushReplacementNamed<T, TO>(
    '/${page.runtimeType.toString()}',
    result: result,
    arguments: page,
  );
}
