import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Route createFadeRoute(Widget page) {
  // Using CupertinoPageRoute to enable native swipe-to-go-back gesture inside Flutter.
  // This prevents the PWA browser swipe back which causes a white screen reload.
  return CupertinoPageRoute(
    settings: RouteSettings(name: '/${page.runtimeType.toString()}'),
    builder: (context) => page,
  );
}
