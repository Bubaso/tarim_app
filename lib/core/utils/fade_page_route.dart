import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// No transition page routes are handled by GoRouter internally.

/// Web'de URL güncellemese de mobil cihazlarda ve PWA'da geri butonunun 
/// anasayfaya dönmesi hatasını çözer. (GoRouter extra objesi tarayıcı geçmişinde tutulamaz).
Future<T?> pushScreen<T>(BuildContext context, Widget page) {
  return Navigator.of(context).push<T>(
    MaterialPageRoute(builder: (context) => page),
  );
}

Future<T?> pushReplacementScreen<T, TO>(BuildContext context, Widget page, {TO? result}) {
  return Navigator.of(context).pushReplacement<T, TO>(
    MaterialPageRoute(builder: (context) => page),
    result: result,
  );
}
