import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/presentation/screens/home_screen.dart';

// GoRouter sadece kök "/" route'unu yönetir.
// Tüm sayfa geçişleri (haber detayı, yazar profili vs.) Navigator.push ile
// yapılır — bu sayede Flutter'ın kendi sayfa yığını korunur ve browser
// geri butonu doğru çalışır.
final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
  ],
);
