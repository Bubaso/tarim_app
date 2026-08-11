import 'dart:html' as html;

/// Service worker'ın `notificationclick` işleyicisinden gelen mesajı dinler.
///
/// Uygulama açıkken bildirime tıklanınca tarayıcı yeni bir sayfa açmaz, var
/// olan pencereyi öne alır. Yönlendirmeyi bu yüzden uygulamanın kendisi
/// yapmak zorunda: service worker yalnızca hedef yolu gönderir.
///
/// FCM SDK'sının `onMessageOpenedApp` akışı burada işe yaramaz — o akış
/// bildirimi SDK'nın kendisinin göstermiş olmasına bağlı. Bizde bildirimi
/// gösteren de tıklamayı yakalayan da kendi service worker'ımız.
void listenNotificationClicks(void Function(String path) onPath) {
  final container = html.window.navigator.serviceWorker;
  if (container == null) return;

  container.onMessage.listen((event) {
    final data = event.data;
    if (data is! Map) return;
    if (data['type'] != 'notification-click') return;

    final path = data['path'];
    if (path is String && path.isNotEmpty) {
      onPath(path);
    }
  });
}
