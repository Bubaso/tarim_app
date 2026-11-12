import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/sergi_eseri.dart';

/// SERGİNİN GÖRÜNÜM DURUMU — süzgeç, yer, sıralama.
///
/// NEDEN EKRANIN İÇİNDE DEĞİL. Izgara ve izleyici artık iki ayrı sayfa.
/// İzleyicideki "sonraki kare" ızgaradaki komşu olmak zorunda; bu ancak
/// ikisi de aynı süzgeci ve aynı sıralamayı okursa mümkün. Durum ekranın
/// `State`'inde kalsaydı, izleyici adresten doğrudan açıldığında (derin
/// bağlantı) o durumu hiç göremezdi.
enum SergiSuzgeci { hepsi, odul, sergileme }

final sergiSuzgeciProvider =
    StateProvider<SergiSuzgeci>((ref) => SergiSuzgeci.hepsi);

/// Seçili il ya da ülke. Boşsa yer süzgeci yok.
final sergiYeriProvider = StateProvider<String?>((ref) => null);

final sergiSirasiProvider =
    StateProvider<SergiSirasi>((ref) => SergiSirasi.odulOnce);

/// Rastgele sıralamanın tohumu. Okur "rastgele"yi her seçtiğinde
/// değişiyor; arada sabit kalıyor ki kaydırırken kareler yerinden
/// oynamasın.
final sergiTohumuProvider = StateProvider<int>((ref) => 1);

/// Süzgeçten ve sıralamadan geçmiş liste. TEK KAYNAK: hem ızgara hem
/// izleyici bunu çağırıyor.
///
/// `isEn` dışarıdan geliyor çünkü yer adı dile bağlı ("Türkiye"/"Türkiye"
/// aynı ama "Çin"/"China" değil) ve yerel ayar `Localizations`'ta, bir
/// sağlayıcının erişemeyeceği yerde.
List<SergiEseri> sergiListesi({
  required SergiVerisi veri,
  required SergiSuzgeci suzgec,
  required String? yer,
  required SergiSirasi sira,
  required int tohum,
  required bool isEn,
}) {
  var l = veri.sirali(sira, isEn, tohum: tohum);
  if (suzgec == SergiSuzgeci.odul) {
    l = l.where((e) => e.odulluMu).toList(growable: false);
  } else if (suzgec == SergiSuzgeci.sergileme) {
    l = l.where((e) => !e.odulluMu).toList(growable: false);
  }
  if (yer != null && yer.isNotEmpty) {
    l = l
        .where((e) => e.il == yer || e.ulke(isEn) == yer)
        .toList(growable: false);
  }
  return l;
}
