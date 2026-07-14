import 'package:flutter/material.dart';

Route createFadeRoute(Widget page) {
  return PageRouteBuilder(
    settings: RouteSettings(name: '/${page.runtimeType.toString()}'),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 250),
    reverseTransitionDuration: const Duration(milliseconds: 200),
  );
}
