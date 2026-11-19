/// Tarayıcı belgesine dokunan üç küçük iş: belge dili, sekme başlığını
/// okumak ve sayfanın açılışından beri geçen süre. Web dışında (testler,
/// telefon uygulaması) hepsi etkisiz.
library;

export 'belge_stub.dart' if (dart.library.js_interop) 'belge_web.dart';
