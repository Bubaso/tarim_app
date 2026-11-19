import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Sitenin TEK ölçüm kapısı — ilk yükte durur, hafiftir.
///
/// İKİ AYRI FIREBASE SDK'SI VAR. `web/index.html` kendi Firebase SDK'sını
/// (10.12.2) açılışta kuruyor ve GA'nın ilk `page_view`'ünü o gönderiyor.
/// Dart tarafının SDK'sı (firebase_core_web'in yüklediği sürüm) AYRI bir
/// kopya: ilk yöntem çağrısında kendi `gtag('config', ...)`'unu yapıyor ve
/// Firebase'in varsayılanıyla bu da bir `page_view` daha sayardı. Site içi
/// geçişleri artık açıkça gönderdiğimiz için o kendiliğinden sayım çift
/// sayım olurdu; `send_page_view: false` onu kapatıyor. Bu seçenek yalnız
/// ÖRNEĞİN İLK kurulduğu çağrıda geçerli (önbelleğe alınıyor), bu yüzden
/// FirebaseAnalytics'e her yerden bu işlevle ulaşılıyor ve yönlendirici
/// kurulurken bir kez çağrılıyor (bkz. `sayfaGorunumunuIzle`).
const Map<String, dynamic> _webSecenekleri = {
  'config': {'send_page_view': false},
};

/// Firebase başlatılmışsa paylaşılan ölçüm örneği; değilse null.
FirebaseAnalytics? analitikOrnegi() {
  try {
    if (Firebase.apps.isEmpty) return null;
    return FirebaseAnalytics.instanceFor(
      app: Firebase.app(),
      webOptions: _webSecenekleri,
    );
  } catch (_) {
    return null;
  }
}

/// Okur uygulama içinde en az bir kez sayfa değiştirdi mi. Yönlendirici
/// dinleyicisi adres değiştiği AN (sayfa kurulmadan önce) işaretliyor;
/// bölümün açılış hızı ölçümü soğuk açılışı buradan ayırıyor.
bool sayfaGecisiOldu = false;

/// Testlerde gönderilen olayları yakalamak için.
@visibleForTesting
void Function(String ad, Map<String, Object> parametreler)? analitikDinleyici;

/// Olayı GA'ya gönderir. Firebase yoksa ya da gönderim hata verirse
/// sessizce yutulur: ölçüm okumayı asla bozmaz.
void analitikOlay(String ad, Map<String, Object> parametreler) {
  analitikDinleyici?.call(ad, parametreler);
  try {
    final analitik = analitikOrnegi();
    if (analitik == null) return;
    analitik
        .logEvent(name: ad, parameters: parametreler)
        .catchError((Object _) {});
  } catch (_) {
    // Eşzamanlı hata (ör. ayrılmış olay adı): yutulur.
  }
}
