import 'package:flutter/material.dart';

/// Bir sayfanın ana sayfadan kaç adım uzakta olduğunu söyler.
///
/// **Neden gözlemci, neden GoRouter'a sorulmuyor.** `GoRouter`'ın
/// `currentConfiguration.matches` listesi adresin EŞLEŞME zincirini veriyor
/// (`/haber/:id` tek eşleşme), üst üste binmiş sayfa yığınını değil. İki
/// haber arasında gezinen okur `/haber/a` → `/haber/b` yaptığında eşleşme
/// sayısı değişmiyor ama yığın gerçekten iki katmanlı. Sorulması gereken şey
/// Navigator'ın kendi yığını; onu da yalnızca bir gözlemci görüyor.
///
/// **Diyaloglar sayılmıyor.** Bir onay kutusu ya da alttan açılan sayfa da
/// yığına giriyor; sayılsaydı okur hiçbir yere gitmeden "iki sayfa uzakta"
/// olurdu. `PageRoute` süzgeci bunu kesiyor: `DialogRoute` ve
/// `ModalBottomSheetRoute` `PopupRoute` tarafında kalıyor.
class GezintiDerinligi extends NavigatorObserver {
  /// Yığın, en alttaki sayfa başta olmak üzere.
  ///
  /// `Set` değil `List`: sıra bilginin kendisi — derinlik bu listedeki
  /// konum. Ayrıca aynı adresin iki kez açılması (haberden habere geçiş)
  /// meşru bir durum ve iki ayrı `Route` nesnesi üretiyor.
  static final List<Route<dynamic>> _yigin = <Route<dynamic>>[];

  static bool _sayilir(Route<dynamic>? route) => route is PageRoute;

  /// Verilen rotanın derinliği. Ana sayfa 0, üstündeki 1, onun üstü 2…
  ///
  /// Bilinmeyen rota için 0 dönüyor: emin olunamayan durumda düğmeyi
  /// GÖSTERMEMEK, olmadığı yerde göstermekten iyi.
  static int derinligi(Route<dynamic>? route) {
    if (route == null) return 0;
    final i = _yigin.indexOf(route);
    return i < 0 ? 0 : i;
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (_sayilir(route)) _yigin.add(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _yigin.remove(route);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _yigin.remove(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    // Yerine koyma derinliği DEĞİŞTİRMEMELİ: aynı basamakta başka bir sayfa
    // açılıyor. Eskisini silip yenisini sona eklemek, dipteki bir sayfayı
    // tepeye taşırdı.
    final i = oldRoute == null ? -1 : _yigin.indexOf(oldRoute);
    if (i < 0) {
      if (_sayilir(newRoute)) _yigin.add(newRoute!);
      return;
    }
    if (_sayilir(newRoute)) {
      _yigin[i] = newRoute!;
    } else {
      _yigin.removeAt(i);
    }
  }

  /// Yalnızca sınama için: gözlemci süreç boyunca yaşıyor ve durumu statik.
  @visibleForTesting
  static void sifirla() => _yigin.clear();

  @visibleForTesting
  static int get yiginBoyu => _yigin.length;
}

/// Bu widget'ın bulunduğu sayfanın ana sayfadan uzaklığı.
int gezintiDerinligi(BuildContext context) =>
    GezintiDerinligi.derinligi(ModalRoute.of(context));
