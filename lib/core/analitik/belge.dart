/// Tarayıcı belgesine dokunan küçük işler: belge dili, sekme başlığını
/// okumak, sayfanın açılışından beri geçen süre ve Etiket Yöneticisi'ne
/// olay göndermek. Web dışında (testler, telefon uygulaması) hepsi etkisiz.
library;

export 'belge_stub.dart' if (dart.library.js_interop) 'belge_web.dart';
