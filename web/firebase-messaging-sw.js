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
    // `kind` yalnızca ölçüm için taşınıyor (bkz. notification_click). Eski
    // sunucudan gelen bir bildirimde bu alan olmaz; o zaman `undefined` kalır
    // ve tıklama yönlendirmesi bugünkü gibi çalışır.
    data: { path: path, kind: data.kind },
  });
});

// Tıklanan bildirimin hedefi, uygulama onu TESLİM ALANA KADAR burada bekler.
//
// Neden gerekli: aşağıdaki `postMessage` ateşle-unut. `navigator.serviceWorker`
// mesajları TAMPONLAMAZ — sayfa o anda dinlemiyorsa mesaj sessizce düşer.
// Sayfa çoğu zaman dinlemiyor: dinleyici `NotificationService.initialize()`
// içinde kuruluyor ve o da Flutter motorunun açılışı, `Firebase.initializeApp`,
// `Supabase.initialize` ve `isSupported()` beklemelerinin ARDINDAN çalışıyor.
// Tarayıcının geri yüklediği bir sekmede bu birkaç saniye sürüyor. Pencere var
// olduğu için `openWindow` dalına da girilmiyor; sonuç, okuyucunun bildirime
// tıklayıp bulunduğu sayfada kalması oluyordu.
//
// Bu yüzden hedef burada tutuluyor ve uygulama hazır olduğunda kendisi soruyor
// (bkz. lib/core/utils/sw_messages_web.dart).
let pendingClick = null;

// Bekleyen hedefin ömrü. Bu sınır olmadan teslim alınamamış bir tıklama
// worker'ın belleğinde kalır ve okuyucu saatler sonra uygulamayı açtığında
// beklemediği bir habere fırlatılırdı.
const PENDING_TTL_MS = 60 * 1000;

function takePendingClick() {
  if (!pendingClick) return null;
  if (Date.now() - pendingClick.at >= PENDING_TTL_MS) {
    pendingClick = null;
    return null;
  }
  return pendingClick;
}

// Uygulamanın "bekleyen bir hedef var mı" sorusu ve teslim aldı bildirimi.
// Buraya YALNIZCA tıklama sonrası yönlendirme bağlı; bildirimin GÖSTERİLMESİ
// yukarıdaki `onBackgroundMessage` yolunda ve bu dinleyiciden bağımsız.
self.addEventListener('message', (event) => {
  const data = event.data || {};

  if (data.type === 'notification-click-ack') {
    pendingClick = null;
    return;
  }

  if (data.type !== 'notification-click-poll') return;

  const pending = takePendingClick();
  if (pending && pending.path && event.source) {
    event.source.postMessage({
      type: 'notification-click',
      path: pending.path,
      kind: pending.kind,
    });
  }
});

self.addEventListener('notificationclick', (event) => {
  event.notification.close();

  const notifData = event.notification.data || {};
  const targetPath = notifData.path || '/';
  const targetKind = notifData.kind;
  const urlToOpen = new URL(targetPath, self.location.origin).href;

  event.waitUntil((async () => {
    // Tıklama HER DALDA deftere yazılıyor. Ölçüm adres çubuğuna `?n=<tür>`
    // eklemek yerine bu var olan kanaldan taşınıyor: paylaşılan bir haber
    // bağlantısı ölçüm parametresini yanında götürmüyor ve `/haber/**`
    // yönlendirmesi ile ogRenderer'ın çözdüğü adres hiç değişmiyor — yani yeni
    // ölçüm, daha önce doğrulanmış yönlendirme yolunu hiçbir noktada
    // değiştirmiyor.
    pendingClick = { path: targetPath, kind: targetKind, at: Date.now() };

    const windowClients = await clients.matchAll({
      type: 'window',
      includeUncontrolled: true,
    });

    // Zaten habere açık bir pencere varsa yalnızca öne alınır. Uygulama açılışta
    // zaten sorduğu için bekleyen kayıt ona ölçümü ulaştırıyor; sayfa hâlihazırda
    // o adreste olduğundan `go` çağrısı da yerinde kalmak anlamına geliyor.
    for (const client of windowClients) {
      if (client.url === urlToOpen && 'focus' in client) {
        client.postMessage({
          type: 'notification-click',
          path: targetPath,
          kind: targetKind,
        });
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
      // Bekleyen kayıt yukarıda zaten yazıldı; mesaj düşerse uygulama açılışta
      // gelip kendisi alıyor, teslim alındığında `ack` ile siliniyor.
      openClient.postMessage({
        type: 'notification-click',
        path: targetPath,
        kind: targetKind,
      });
      return openClient.focus();
    }

    // Uygulama hiç açık değilse tarayıcı doğrudan hedef adreste açar.
    // Yönlendirme için bekleyen kayda ihtiyaç yok — adres zaten doğru — ama
    // kayıt duruyor, çünkü ÖLÇÜMÜN tek taşıyıcısı o: yeni pencere açılışta
    // sorup türü öğreniyor ve tıklamayı deftere yazıyor.
    if (clients.openWindow) {
      return clients.openWindow(urlToOpen);
    }
  })());
});
