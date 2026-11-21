/// Gömme kutusu — paylaşımı olduğu gibi çizer.
///
/// Web'de iframe, mobilde künye kartı. Koşullu içe aktarma iki sürümü
/// ayırıyor; çağıran taraf farkı görmüyor.
///
/// NEDEN MOBİLDE IFRAME YOK: iframe bir web öğesi. Depoda `webview_flutter`
/// bağımlılığı yok ve köşe için tek başına eklemek, uygulamaya bir tarayıcı
/// motoru daha sokmak demek. Mobilde paylaşım künyesiyle duruyor, dokununca
/// kendi mecrasında açılıyor — atıf eksik kalmıyor, ağırlık gelmiyor.
library;

export 'gomme_kutusu_stub.dart'
    if (dart.library.js_interop) 'gomme_kutusu_web.dart';
