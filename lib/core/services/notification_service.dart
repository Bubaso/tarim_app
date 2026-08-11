import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../router/app_router.dart';
import '../utils/sw_messages.dart';

/// Ön planda gelen bildirimi göstermek için gereken messenger. `MaterialApp`
/// ağacının dışından (servis içinden) SnackBar göstermenin tek yolu bu.
final GlobalKey<ScaffoldMessengerState> appMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

class NotificationService {
  FirebaseMessaging? _messaging;
  final SupabaseClient _supabase = Supabase.instance.client;
  
  static const String _hasRequestedPermissionKey = 'has_requested_notification_permission';
  static const String _articlesReadCountKey = 'articles_read_for_notification';
  static const int _articlesRequiredForSoftPrompt = 3;

  /// Initializes listening to foreground messages and click actions
  Future<void> initialize() async {
    try {
      if (kIsWeb) {
        // Check if web push is supported on this browser (iOS Safari issues)
        final isSupported = await FirebaseMessaging.instance.isSupported();
        if (!isSupported) {
          if (kDebugMode) print('Firebase Messaging is not supported on this browser.');
          return;
        }
      }
      
      _messaging = FirebaseMessaging.instance;

      // Uygulama AÇIK ve GÖRÜNÜRKEN gelen bildirimler.
      //
      // Tarayıcı bu durumda sistem bildirimini GÖSTERMEZ. Firebase SDK'sının
      // service worker'daki push işleyicisi önce görünür pencere arıyor, bulursa
      // bildirimi hiç göstermeden mesajı sayfaya iletip çıkıyor. Yani ön planda
      // bildirimi göstermek tamamen uygulamanın sorumluluğunda; burası boş
      // kaldığı sürece uygulamayı açık tutan kullanıcı hiçbir şey görmüyordu.
      FirebaseMessaging.onMessage.listen(_showForegroundNotification);

      // Bildirime tıklandığında service worker hedef yolu buraya gönderiyor.
      listenNotificationClicks(appRouter.go);

      // Handle clicks when the app is in background but opened
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        if (kDebugMode) {
          print('Message clicked! Routing...');
        }
        _handleMessageClick(message);
      });

      // Handle initial message if the app was completely closed and opened by a notification click
      _messaging?.getInitialMessage().then((RemoteMessage? message) {
        if (message != null) {
          _handleMessageClick(message);
        }
      });

      // İzni geçmiş bir oturumda vermiş kullanıcıların token'ı aksi hâlde hiç
      // kaydedilmez: `requestPermission()` yalnızca soft prompt üzerinden bir
      // kez çağrılıyor ve `has_requested_notification_permission` işaretlendiği
      // için bir daha çalışmıyor. Token ayrıca tarayıcı tarafından sessizce
      // yenilenebiliyor. Bu yüzden her açılışta yeniden eşitliyoruz.
      await _syncTokenIfPermitted();
    } catch (e) {
      debugPrint('Bildirim servisi başlatılamadı: $e');
    }
  }

  /// İzin zaten verilmişse token'ı alıp Supabase ile eşitler.
  Future<void> _syncTokenIfPermitted() async {
    final messaging = _messaging;
    if (messaging == null) return;

    final settings = await messaging.getNotificationSettings();
    if (settings.authorizationStatus != AuthorizationStatus.authorized &&
        settings.authorizationStatus != AuthorizationStatus.provisional) {
      return;
    }

    final token = await messaging.getToken();
    if (token != null) {
      await _saveTokenToSupabase(token);
    }
    messaging.onTokenRefresh.listen(_saveTokenToSupabase);
  }

  /// Ön planda gelen bildirimi uygulama içinde gösterir.
  void _showForegroundNotification(RemoteMessage message) {
    // Salt veri gönderiyoruz; `notification` alanı yalnızca eski sürümden
    // kalan bir gönderim olursa devreye girer.
    final title = message.data['title'] as String? ?? message.notification?.title;
    final body = message.data['body'] as String? ?? message.notification?.body;
    final path = message.data['path'] as String?;

    if (title == null && body == null) return;

    final messenger = appMessengerKey.currentState;
    if (messenger == null) return;

    // Arka arkaya iki bildirim gelirse ikincisi kuyruğa girip dakikalarca
    // beklemesin; yenisi eskisinin yerini alsın.
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 8),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null)
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            if (body != null)
              Text(
                body,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        action: path == null
            ? null
            : SnackBarAction(
                label: 'Oku',
                onPressed: () => appRouter.go(path),
              ),
      ),
    );
  }

  void _handleMessageClick(RemoteMessage message) {
    if (message.data.containsKey('path')) {
      final path = message.data['path'] as String;
      appRouter.go(path);
    }
  }

  /// Check if we should show the Soft Prompt
  Future<bool> shouldShowSoftPrompt() async {
    final prefs = await SharedPreferences.getInstance();
    final hasRequested = prefs.getBool(_hasRequestedPermissionKey) ?? false;
    
    if (hasRequested) return false;

    final readCount = prefs.getInt(_articlesReadCountKey) ?? 0;
    return readCount >= _articlesRequiredForSoftPrompt;
  }

  /// Increment article read count (called when entering ArticleDetailScreen)
  Future<void> incrementArticleReadCount() async {
    final prefs = await SharedPreferences.getInstance();
    final hasRequested = prefs.getBool(_hasRequestedPermissionKey) ?? false;
    if (hasRequested) return; // Don't count if already asked

    final readCount = (prefs.getInt(_articlesReadCountKey) ?? 0) + 1;
    await prefs.setInt(_articlesReadCountKey, readCount);
  }

  /// Request actual browser permission (Hard Prompt)
  Future<bool> requestPermission() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasRequestedPermissionKey, true);

    if (_messaging == null) {
      if (kIsWeb) {
        final isSupported = await FirebaseMessaging.instance.isSupported();
        if (!isSupported) {
          if (kDebugMode) print('Firebase Messaging is not supported on this browser.');
          return false;
        }
      }
      _messaging = FirebaseMessaging.instance;
    }

    try {
      NotificationSettings settings = await _messaging!.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        await _syncTokenIfPermitted();
        return true;
      }
    } catch (e) {
      debugPrint('Bildirim izni istenirken hata: $e');
    }

    return false;
  }

  Future<void> _saveTokenToSupabase(String token) async {
    try {
      // Aynı cihaz her açılışta yeniden yazar; `token` birincil anahtar olduğu
      // için çakışma güncellemeye dönüşür.
      await _supabase.from('push_tokens').upsert({
        'token': token,
        'platform': kIsWeb ? 'web' : defaultTargetPlatform.name,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'token');
    } catch (e) {
      // Bu hata sessiz kalırsa bildirim sistemi hiç çalışmaz ama hiçbir belirti
      // vermez: kullanıcı izni verir, token alınır, kayıt RLS'e takılır ve
      // zamanlanmış fonksiyonlar boş listeye gönderim yapar. Bu yüzden
      // release derlemesinde de yazdırılıyor.
      debugPrint('FCM token Supabase\'e kaydedilemedi: $e');
    }
  }

  /// Deny Soft Prompt logic
  Future<void> denySoftPrompt() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasRequestedPermissionKey, true);
  }
}
