import 'dart:js_interop';

// package:web yerine üç satırlık bağ: yalnız gereken özellikler, ilk yükte
// birkaç yüz bayt.

@JS('document')
external _Belge get _belge;

@JS('performance')
external _Performans get _performans;

/// Etiket Yöneticisi'nin kuyruğu. `web/index.html` açılışta
/// `window.dataLayer = window.dataLayer || []` yazıyor, yani her zaman var;
/// yine de null denetimi duruyor — etiket engellenirse (reklam engelleyici)
/// bu dizi hiç oluşmaz ve okuma bundan etkilenmemeli.
@JS('dataLayer')
external _DataLayer? get _dataLayer;

/// `web/index.html`te tanımlanan genel `gtag` işlevi.
@JS('gtag')
external void _gtag(String komut, JSObject veri);

extension type _Belge._(JSObject _) implements JSObject {
  external _Oge? get documentElement;
  external String get title;
}

extension type _Oge._(JSObject _) implements JSObject {
  external String get lang;
  external set lang(String deger);
}

extension type _Performans._(JSObject _) implements JSObject {
  external double now();
}

extension type _DataLayer._(JSObject _) implements JSObject {
  external void push(_Kayit kayit);
}

/// `{event: '...'}` nesnesi — JS nesne sabiti olarak kuruluyor.
///
/// `dart:js_interop_unsafe`'in `setProperty`'si de işi görürdü ama ilk yüke
/// ~15 KB dinamik özellik makinesi ekliyordu (ölçüldü, 26 Kasım 2026).
/// Tipli kurulum o maliyeti sıfırlıyor.
extension type _Kayit._(JSObject _) implements JSObject {
  external factory _Kayit({String event});
}

/// `{traffic_type: 'internal'}` — GA4'ün dahili trafik filtresinin aradığı
/// parametre. Ad snake_case çünkü JS tarafındaki anahtar birebir bu.
extension type _Trafik._(JSObject _) implements JSObject {
  // ignore: non_constant_identifier_names
  external factory _Trafik({String traffic_type});
}

/// `<html lang>`'ı yazar. Ekran okuyucular metni bu dile göre seslendirir;
/// İngilizce metin `lang="tr"` altında Türkçe sesle okunuyordu.
void belgeDiliniYaz(String dil) {
  try {
    final kok = _belge.documentElement;
    if (kok != null && kok.lang != dil) kok.lang = dil;
  } catch (_) {}
}

/// Sekmede o an yazan başlık.
String? belgeBasligi() {
  try {
    return _belge.title;
  } catch (_) {
    return null;
  }
}

/// Sayfanın açılışından (gezinmenin başından) beri geçen süre, ms.
double? belgeSuresiMs() {
  try {
    return _performans.now();
  } catch (_) {
    return null;
  }
}

/// Etiket Yöneticisi'ne özel bir olay gönderir.
///
/// NEDEN GEREKLİ. Portal Flutter/CanvasKit: sayfa belge düzeyinde HİÇ
/// kaydırılmıyor (`body{overflow:hidden}`, belge yüksekliği = pencere
/// yüksekliği), uygulama içi gezinme `pathname`'i değiştirmiyor ve ekranda
/// GTM'in tutunacağı bir DOM öğesi yok. Ölçüldü (26 Kasım 2026): GTM'in
/// kaydırma, geçmiş ve tıklama tetikleyicilerinin hiçbiri ateşlenmiyor;
/// `dataLayer`'a yalnız `gtm.dom` ve `gtm.load` düşüyor.
///
/// Yani sayfa yüklemesi dışında ne olduğunu GTM'e ancak uygulamanın kendisi
/// söyleyebilir. Bu işlev o kapı.
///
/// Hata yutuluyor: ölçüm okumayı asla bozmaz.
void dataLayerOlayi(String olay) {
  try {
    final kuyruk = _dataLayer;
    if (kuyruk == null) return;
    kuyruk.push(_Kayit(event: olay));
  } catch (_) {}
}

/// Bu oturumu GA4'e DAHİLİ olarak işaretler; sonraki her olay
/// `traffic_type: internal` taşır ve mülkteki "Internal Traffic" veri
/// filtresi (26 Kasım 2026'da Etkin'e alındı) onları atar.
///
/// NEDEN GEREKLİ. Ölçüm 28 günde anasayfada kişi başı 21,7 görüntüleme ve
/// 15 dakika etkileşim gösteriyordu; `/panel`, `/giris`, `/ayarlar` ve
/// sınama sayfaları da listedeydi. Bunlar okur değil, bizdik. GA4'ün hazır
/// yolu IP kuralı, ama IP ev/ofis/mobil değişince bozulur — oturumun açık
/// olması bozulmaz.
///
/// Yerel geliştirme trafiği için aynı işaret `web/index.html`te, her şeyden
/// önce kuruluyor.
///
/// Hata yutuluyor: ölçüm okumayı asla bozmaz.
void dahiliTrafigiIsaretle() {
  try {
    _gtag('set', _Trafik(traffic_type: 'internal'));
  } catch (_) {}
}
