import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// No transition page routes are handled by GoRouter internally.

/// Web'de (PWA) tarayıcı geçmişinin (browser history) güncellenmesi için
/// Navigator.push yerine GoRouter kullanmasını sağlayan yardımcı metod.
Future<T?> pushScreen<T>(BuildContext context, Widget page) {
  final id = DateTime.now().millisecondsSinceEpoch;
  GoRouter.of(context).push('/page/${page.runtimeType.toString()}/$id', extra: page);
  return Future.value(null);
}

Future<T?> pushReplacementScreen<T, TO>(BuildContext context, Widget page, {TO? result}) {
  final id = DateTime.now().millisecondsSinceEpoch;
  GoRouter.of(context).pushReplacement('/page/${page.runtimeType.toString()}/$id', extra: page);
  return Future.value(null);
}
