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
///
/// ── Neden yalnızca dinlemek yetmiyor ──────────────────────────────────────
/// `navigator.serviceWorker` mesajları tamponlamıyor: sayfa tam o anda
/// dinlemiyorsa mesaj sessizce düşüyor. Bu dinleyici ise uygulama önyüklemesinin
/// epey geç bir noktasında kuruluyor (Flutter motoru → Firebase → Supabase →
/// `isSupported()`). Tarayıcının geri yüklediği bir sekmede tıklama bu
/// kuruluştan ÖNCE gerçekleşiyor ve okuyucu bulunduğu sayfada kalıyordu.
///
/// Bu yüzden dinleyici kurulur kurulmaz worker'a "bekleyen hedef var mı" diye
/// soruluyor. Yol teslim alındığında `ack` gönderiliyor ki aynı tıklama ikinci
/// kez uygulanmasın.
void listenNotificationClicks(
  void Function(String path, String? kind) onClick,
) {
  final container = html.window.navigator.serviceWorker;
  if (container == null) return;

  container.onMessage.listen((event) {
    final data = event.data;
    if (data is! Map) return;
    if (data['type'] != 'notification-click') return;

    final path = data['path'];
    if (path is String && path.isNotEmpty) {
      // `kind` yalnızca ölçüm için; eski bir service worker hâlâ etkinse bu
      // alan gelmez ve yönlendirme aynen çalışır.
      final kind = data['kind'];
      onClick(path, kind is String && kind.isNotEmpty ? kind : null);
      _postToWorkers(container, {'type': 'notification-click-ack'});
    }
  });

  // Dinleyici kurulmadan önce gelmiş olabilecek tıklamayı topla.
  _postToWorkers(container, {'type': 'notification-click-poll'});
}

/// Mesajı kayıtlı service worker'lara iletir.
///
/// Doğrudan `container.controller` KULLANILAMAZ: FCM worker'ının kapsamı
/// `/firebase-cloud-messaging-push-scope`, uygulama sayfası ise `/` altında —
/// yani bu worker sayfayı kontrol etmiyor ve `controller` ondan başkasını
/// gösteriyor.
///
/// Kapsam adı yerine tüm kayıtlar dolaşılıyor; o ad Firebase'in kendi iç
/// ayrıntısı ve sürümle değişirse sabit yazılmış bir kapsam sessizce boşa
/// düşerdi. Tanımadığı mesaj türünü diğer worker'lar zaten yok sayıyor.
void _postToWorkers(
  html.ServiceWorkerContainer container,
  Map<String, dynamic> message,
) {
  container.getRegistrations().then((registrations) {
    for (final registration in registrations) {
      if (registration is! html.ServiceWorkerRegistration) continue;
      registration.active?.postMessage(message);
    }
  }).catchError((Object _) {
    // Kayıt listesi alınamadıysa yapılacak bir şey yok; bildirim yönlendirmesi
    // canlı mesaj yoluna düşer. Uygulamanın açılışını engellememeli.
  });
}
