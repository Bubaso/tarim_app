import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/presentation/screens/home_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/page/:type',
      pageBuilder: (context, state) {
        final widget = state.extra as Widget?;
        return CupertinoPage(
          child: widget ?? const HomeScreen(),
          name: state.matchedLocation,
        );
      },
    ),
  ],
);
