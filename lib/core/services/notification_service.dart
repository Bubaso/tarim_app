import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../router/app_router.dart';
import '../utils/localization_helper.dart';
import '../utils/sw_messages.dart';
import 'notification_prefs.dart';

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

  /// En son kaydedilen token. Ayarlar ekranında bir anahtar değiştiğinde satırı
  /// yeniden yazabilmek için tutuluyor; aksi hâlde tercih yalnızca cihazda
  /// kalır ve sunucu eski hâline göre gönderim yapardı.
  String? _lastToken;

  // ══════════════════════════════════════════════════════════════════════
  //  Bildirim izni isteme kuralları — 8 Kasım 2026 ölçümünden sonra
  // ──────────────────────────────────────────────────────────────────────
  //  Ölçüm: 88 günde 18 abone. Dağıtım kanalı fiilen yok. Sebep kodda
  //  dört yerde duruyordu:
  //
  //  1. Eşik ÜÇ haberdi. Haber sitelerinde oturum başına okunan haber
  //     1-2 civarı; üç haber, ziyaretçilerin büyük çoğunluğunu daveti
  //     HİÇ GÖRMEDEN eliyordu.
  //  2. "Kapat" KALICIYDI. `denySoftPrompt` tarayıcı iznini istemiş gibi
  //     `hasRequested`i işaretliyordu: 12 puntoluk bir şeride yanlışlıkla
  //     dokunan okuyucu bir daha asla davet görmüyordu.
  //  3. Tarayıcı istemi KAPATILDIĞINDA da aynı bayrak yanıyordu. Oysa
  //     kapatmak reddetmek değil; Chrome'da üç kez görmezden gelinmeden
  //     izin bloklanmıyor ve ikinci bir deneme hakkımız var.
  //  4. Davet YALNIZCA anasayfadaydı. Okuyucunun aboneliği en çok
  //     isteyeceği an haberin SONU; anasayfaya dönmesini beklemek,
  //     ilgisinin tepe noktasını kaçırmak demekti.
  //
  //  Yeni kural: iki haber, en fazla üç davet, araya on gün. Tarayıcı
  //  istemi bir kez gerçekten çıktıysa (izin verildi ya da reddedildi)
  //  bir daha hiç sorulmuyor — orası tek yönlü kapı.
  // ══════════════════════════════════════════════════════════════════════

  /// Tarayıcı izni GERÇEKTEN soruldu (verildi ya da reddedildi).
  static const String _hasRequestedPermissionKey =
      'has_requested_notification_permission';
  static const String _articlesReadCountKey = 'articles_read_for_notification';

  /// Kaç kez davet gösterildi ve sonuncusu ne zaman kapatıldı.
  static const String _davetSayisiKey = 'bildirim_daveti_sayisi';
  static const String _sonDavetKey = 'bildirim_daveti_son';

  static const int _articlesRequiredForSoftPrompt = 2;
  static const int _enFazlaDavet = 3;
  static const Duration _davetAralik = Duration(days: 10);

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
      listenNotificationClicks(_onNotificationClick);

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

  /// Bildirim tıklamasının tek girişi: önce yönlendirir, sonra ölçer.
  ///
  /// Sıra pazarlık konusu değil. `appRouter.go` ilk satırda ve senkron; ölçüm
  /// kaydı ateşle-unut ve kendi hata kalkanı içinde. Böylece Supabase yavaşlasa
  /// da, cihaz çevrimdışı olsa da, RPC henüz uygulanmamış olsa da okuyucunun
  /// habere gidişi bundan hiç etkilenmiyor.
  ///
  /// `kind` boş gelebilir: eski bir service worker hâlâ etkinse bildirimin
  /// verisinde tür yoktur. O durumda yönlendirme yapılır, ölçüm atlanır.
  void _onNotificationClick(String path, String? kind) {
    // Okuyucu zaten o adresteyse `go` ÇAĞRILMIYOR: aynı konuma gitmek rotayı
    // yeniden kurar ve makaledeki kaydırma konumu başa döner. Bu iki durumda
    // gerçekten oluyor — bildirimdeki haberi zaten açık tutan okuyucu, ve
    // bildirimle yeni açılan pencerenin açılışta bekleyen tıklamayı sorması.
    // Ölçüm yine de yazılıyor; tıklama gerçekleşti.
    if (_currentLocation() != path) appRouter.go(path);
    if (kind == null) return;
    _logClick(kind, path);
  }

  String? _currentLocation() {
    try {
      return appRouter.routeInformationProvider.value.uri.toString();
    } catch (_) {
      // Router henüz bir konum yayımlamadıysa karşılaştırma yapılamaz;
      // yönlendirmeyi atlamaktansa yapmak doğru.
      return null;
    }
  }

  Future<void> _logClick(String kind, String path) async {
    try {
      await _supabase.rpc(
        'log_notification_click',
        params: {'p_kind': kind, 'p_path': path},
      );
    } catch (e) {
      debugPrint('Bildirim tıklaması kaydedilemedi: $e');
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

  /// Davet gösterilmeli mi?
  ///
  /// Üç kapı var ve üçü de ayrı sebeplerle kapanıyor: tarayıcı izni zaten
  /// soruldu, davet hakkı doldu, ya da son kapatmanın üstünden on gün
  /// geçmedi.
  Future<bool> shouldShowSoftPrompt() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_hasRequestedPermissionKey) ?? false) return false;

    final okunan = prefs.getInt(_articlesReadCountKey) ?? 0;
    if (okunan < _articlesRequiredForSoftPrompt) return false;

    if ((prefs.getInt(_davetSayisiKey) ?? 0) >= _enFazlaDavet) return false;

    final son = prefs.getInt(_sonDavetKey);
    if (son != null) {
      final gecen = DateTime.now()
          .difference(DateTime.fromMillisecondsSinceEpoch(son));
      if (gecen < _davetAralik) return false;
    }
    return true;
  }

  /// Increment article read count (called when entering ArticleDetailScreen)
  Future<void> incrementArticleReadCount() async {
    final prefs = await SharedPreferences.getInstance();
    final hasRequested = prefs.getBool(_hasRequestedPermissionKey) ?? false;
    if (hasRequested) return; // İzin zaten soruldu, saymaya gerek yok.

    final readCount = (prefs.getInt(_articlesReadCountKey) ?? 0) + 1;
    await prefs.setInt(_articlesReadCountKey, readCount);
  }

  /// Tarayıcı iznini ister (sert istem).
  ///
  /// `hasRequested` artık BAŞTA değil, SONUÇ belli olunca işaretleniyor.
  /// Fark şurada: tarayıcı istemi kapatıldığında (Chrome'da çarpıya basmak)
  /// durum `notDetermined` kalıyor — izin ne verilmiş ne reddedilmiştir.
  /// Eski kod bunu da "soruldu" sayıp daveti ömür boyu kapatıyordu. Oysa
  /// kapatan okuyucuya on gün sonra bir kez daha sorulabilir; asıl tek
  /// yönlü kapı reddetmektir.
  Future<bool> requestPermission() async {
    final prefs = await SharedPreferences.getInstance();

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

      final durum = settings.authorizationStatus;

      if (durum == AuthorizationStatus.authorized ||
          durum == AuthorizationStatus.provisional) {
        await prefs.setBool(_hasRequestedPermissionKey, true);
        await _syncTokenIfPermitted();
        return true;
      }

      if (durum == AuthorizationStatus.denied) {
        // Gerçek ret. Tarayıcı bu kararı hatırlıyor; bir daha sormanın
        // karşılığı yok, yalnızca rahatsız etmek olurdu.
        await prefs.setBool(_hasRequestedPermissionKey, true);
        return false;
      }

      // notDetermined: istem kapatıldı. Davet sayacı ilerliyor, on gün
      // sonra bir kez daha denenebilir.
      await denySoftPrompt();
    } catch (e) {
      debugPrint('Bildirim izni istenirken hata: $e');
      await denySoftPrompt();
    }

    return false;
  }

  /// Tarayıcı/sistem bildirim izni verilmiş mi?
  ///
  /// Ayarlar ekranı buna bakıyor: izin yokken anahtarları çalışır göstermek
  /// yanıltıcı olurdu — kullanıcı hepsini açık bırakıp hiç bildirim almazdı.
  Future<bool> isPermissionGranted() async {
    try {
      if (kIsWeb && !await FirebaseMessaging.instance.isSupported()) {
        return false;
      }
      final settings =
          await (_messaging ?? FirebaseMessaging.instance)
              .getNotificationSettings();
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (_) {
      return false;
    }
  }

  /// Ayarlar ekranında bir tercih değiştiğinde çağrılır: cihazın satırını
  /// güncel `kinds` / `locale` ile yeniden yazar.
  ///
  /// Token yoksa (izin verilmemiş) sessizce çıkar — kaydedilecek bir cihaz
  /// yoktur ve tercih zaten diskte duruyor; izin verildiği anda ilk yazımda
  /// birlikte gider.
  Future<void> syncPreferences() async {
    final token = _lastToken;
    if (token == null) return;
    await _saveTokenToSupabase(token);
  }

  Future<void> _saveTokenToSupabase(String token) async {
    _lastToken = token;
    try {
      // Tercihler DİSKTEN okunuyor, Riverpod state'inden değil. Provider henüz
      // yüklenmemişken okunsaydı cihaz yanlışlıkla "hiçbir şey istemiyorum"
      // olarak kaydedilebilir ve sessizce bildirim almayı keserdi.
      //
      // `null` = kullanıcı hiç seçim yapmadı → sunucu TÜM türleri gönderir.
      final kinds = await NotificationPrefsNotifier.readSavedKinds();
      final locale = await effectiveLanguageCode();

      // Aynı cihaz her açılışta yeniden yazar; `token` birincil anahtar olduğu
      // için çakışma güncellemeye dönüşür.
      await _supabase.from('push_tokens').upsert({
        'token': token,
        'platform': kIsWeb ? 'web' : defaultTargetPlatform.name,
        'kinds': kinds?.map((k) => k.wireName).toList(),
        'locale': locale,
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

  /// Davet kapatıldı — SUSTURULDU, kapatılmadı.
  ///
  /// Eskiden burası `hasRequested`i işaretliyordu ve tek dokunuş daveti
  /// ömür boyu bitiriyordu. Artık sayaç ilerliyor: on gün sonra, en fazla
  /// üç kez olmak üzere bir kez daha soruluyor.
  Future<void> denySoftPrompt() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
        _davetSayisiKey, (prefs.getInt(_davetSayisiKey) ?? 0) + 1);
    await prefs.setInt(_sonDavetKey, DateTime.now().millisecondsSinceEpoch);
  }
}
