import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// No transition page routes are handled by GoRouter internally.

/// Web'de URL güncellemese de mobil cihazlarda ve PWA'da geri butonunun 
/// anasayfaya dönmesi hatasını çözer. (GoRouter extra objesi tarayıcı geçmişinde tutulamaz).
Future<T?> pushScreen<T>(BuildContext context, Widget page) {
  final path = '/page/view/${DateTime.now().millisecondsSinceEpoch}';
  return context.push<T>(path, extra: page);
}

Future<T?> pushReplacementScreen<T, TO>(BuildContext context, Widget page, {TO? result}) {
  final path = '/page/view/${DateTime.now().millisecondsSinceEpoch}';
  context.replace(path, extra: page);
  return Future.value(null);
}
