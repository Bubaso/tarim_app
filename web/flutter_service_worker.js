'use strict';

// ─── Eski Flutter service worker'ının temizleyicisi ────────────────────────
//
// Bu dosya bilerek elle yazıldı; `flutter build web --pwa-strategy=none` ile
// derlendiği için Flutter kendi sürümünü üretip bunun üzerine yazmıyor.
//
// Neden gerekiyor:
//   Flutter'ın ürettiği `flutter_service_worker.js` artık yalnızca kendini
//   siliyor ve ardından `client.navigate()` ile tüm sekmeleri YENİDEN
//   YÜKLÜYOR. `flutter_bootstrap.js` ise her açılışta o worker'ı tekrar
//   kaydediyordu. Sonuç: kaydet → etkinleş → kendini sil → sayfayı yenile →
//   kaydet … Her ziyarette ana çerçeve üç kez yeniden yükleniyordu. Hızlı bir
//   masaüstünde göze çarpmıyor; telefonda her yenileme splash'ı baştan
//   başlattığı için uygulama "açılmıyor" gibi görünüyordu. Gizli modda
//   sorunun yaşanmaması da bundandı: orada kayıt her seferinde sıfırlanıyor.
//
// Bu sürüm iki farkla aynı temizliği yapıyor:
//   • `client.navigate()` YOK — döngüyü başlatan çağrı buydu.
//   • Eski sürümün geride bıraktığı önbellekler de siliniyor.
//
// Dosyanın var olmaya devam etmesi şart: daha önce kayıt yaptırmış
// tarayıcılar bu adresi periyodik olarak yeniden istiyor. Silinseydi
// hosting'deki `**` yönlendirmesi HTML döndürür, güncelleme MIME hatasıyla
// başarısız olur ve eski worker o tarayıcılarda sonsuza dek kayıtlı kalırdı.
//
// Kayıt yaptırmış son tarayıcı da temizlendikten sonra (birkaç ay) bu dosya
// silinebilir.

self.addEventListener('install', () => {
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    (async () => {
      try {
        await self.registration.unregister();
      } catch (e) {
        console.warn('Service worker kaydı silinemedi:', e);
      }

      try {
        const keys = await caches.keys();
        await Promise.all(
          keys.filter((k) => k.startsWith('flutter-app')).map((k) => caches.delete(k))
        );
      } catch (e) {
        console.warn('Eski önbellekler silinemedi:', e);
      }
    })()
  );
});
