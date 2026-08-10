import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../router/app_router.dart';

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

      // Listen for messages when the app is in foreground
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (kDebugMode) {
          print('Got a message whilst in the foreground!');
          print('Message data: ${message.data}');
        }
        if (message.notification != null) {
          if (kDebugMode) {
            print('Message also contained a notification: ${message.notification}');
          }
        }
      });

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
    } catch (e) {
      if (kDebugMode) print('Error initializing notifications: $e');
    }
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
        
        // Get the token
        final token = await _messaging!.getToken(
          // You should pass your actual VAPID key here for production web push
          // vapidKey: 'YOUR_PUBLIC_VAPID_KEY_HERE', 
        );
        
        if (token != null) {
          await _saveTokenToSupabase(token);
        }
        
        // Listen for token refreshes
        _messaging!.onTokenRefresh.listen(_saveTokenToSupabase);
        return true;
      }
    } catch (e) {
      if (kDebugMode) print('Error requesting notification permission: $e');
    }
    
    return false;
  }

  Future<void> _saveTokenToSupabase(String token) async {
    try {
      // In a real app, you would associate this with a user_id if they are logged in.
      // For anonymous users, we just save the token to blast notifications.
      await _supabase.from('push_tokens').upsert({
        'token': token,
        'platform': kIsWeb ? 'web' : defaultTargetPlatform.name,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error saving FCM token: $e');
      }
    }
  }

  /// Deny Soft Prompt logic
  Future<void> denySoftPrompt() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasRequestedPermissionKey, true);
  }
}
