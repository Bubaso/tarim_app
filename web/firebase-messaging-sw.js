importScripts("https://www.gstatic.com/firebasejs/10.12.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.12.0/firebase-messaging-compat.js");

const firebaseConfig = {
  apiKey: "AIzaSyDik1Xy9PHxV64y3Avq2LLWDRWbT0zJxPQ",
  authDomain: "tarim-app-2026.firebaseapp.com",
  projectId: "tarim-app-2026",
  storageBucket: "tarim-app-2026.firebasestorage.app",
  messagingSenderId: "966840360726",
  appId: "1:966840360726:web:2d237d44ba55915e94fa37"
};

firebase.initializeApp(firebaseConfig);
const messaging = firebase.messaging();

// Sunucu SALT VERİ gönderiyor (functions/index.js). Böylece bildirimi gösteren
// tek yer burası; SDK'nın otomatik gösterimi devreye girmediği için aynı
// bildirim iki kez görünmüyor ve tıklama yönlendirmesi bizde kalıyor.
//
// `payload.notification` ARTIK OKUNMUYOR: salt veri gönderiminde böyle bir alan
// yok ve eski kod burada `undefined.title` ile patlardı. Patlayan bir push
// işleyicisinde tarayıcı kendi jenerik "bu site arka planda güncellendi"
// bildirimini gösterir.
messaging.onBackgroundMessage((payload) => {
  const data = payload.data || {};
  const path = data.path || '/';

  return self.registration.showNotification(data.title || 'Tarım Portalı', {
    body: data.body || '',
    icon: '/icons/Icon-192.png',
    badge: '/icons/Icon-192.png',
    // Aynı habere ait ikinci bir bildirim yenisiyle değiştirilir, üst üste
    // yığılmaz. Aynı anda iki push gelirse de tek bildirim kalır.
    tag: path,
    renotify: true,
    data: { path: path },
  });
});

self.addEventListener('notificationclick', (event) => {
  event.notification.close();

  const targetPath = (event.notification.data && event.notification.data.path) || '/';
  const urlToOpen = new URL(targetPath, self.location.origin).href;

  event.waitUntil((async () => {
    const windowClients = await clients.matchAll({
      type: 'window',
      includeUncontrolled: true,
    });

    // Zaten habere açık bir pencere varsa yalnızca öne alınır.
    for (const client of windowClients) {
      if (client.url === urlToOpen && 'focus' in client) {
        return client.focus();
      }
    }

    // Açık ama başka bir sayfada duran pencere varsa yolu UYGULAMAYA bildirip
    // odağı ona veriyoruz; yönlendirmeyi uygulamanın kendi router'ı yapıyor
    // (bkz. lib/core/utils/sw_messages_web.dart).
    //
    // Burada `client.navigate()` KULLANILAMAZ. Spesifikasyon gereği bir pencere
    // yalnızca kendisini KONTROL EDEN service worker tarafından gezdirilebilir.
    // Bu worker'ın kapsamı `/firebase-cloud-messaging-push-scope`; uygulama
    // penceresi ise `/` altında ve bu kayda bağlı değil. Dolayısıyla navigate()
    // her tarayıcıda TypeError ile reddediliyor, kod sessizce `focus()`a
    // düşüyor ve kullanıcı hangi sayfadaysa orada kalıyordu. Bildirime
    // tıklayınca ana sayfanın açılmasının nedeni buydu.
    const openClient = windowClients.find((c) => 'focus' in c);
    if (openClient) {
      openClient.postMessage({ type: 'notification-click', path: targetPath });
      return openClient.focus();
    }

    // Uygulama hiç açık değilse tarayıcı doğrudan hedef adreste açar.
    if (clients.openWindow) {
      return clients.openWindow(urlToOpen);
    }
  })());
});
