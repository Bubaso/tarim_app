import 'dart:js_interop';

// package:web yerine üç satırlık bağ: yalnız gereken özellikler, ilk yükte
// birkaç yüz bayt.

@JS('document')
external _Belge get _belge;

@JS('performance')
external _Performans get _performans;

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
