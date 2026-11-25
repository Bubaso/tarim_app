import 'dart:async';

import 'package:flutter/material.dart';

// ══════════════════════════════════════════════════════════════════════════
//  Erteli sayfa — ayrı pakette duran bir ekranı indirip kuran bekleme sayfası
// ──────────────────────────────────────────────────────────────────────────
//  `deferred as` ile içe aktarılan kütüphane İLK YÜKTE İNMİYOR: kodu ayrı
//  bir parçada (main.dart.js_N.part.js) duruyor ve yalnız o ekrana giren
//  okur indiriyor. deploy.sh'in ağırlık bekçisi ilk yükü ölçtüğü için yer
//  açmanın yolu budur (bkz. deploy.sh, JS_TAVAN notu).
//
//  Bu sayfa düzeneğin okura dönük yüzü: paketi indirir, inince ekranı kurar.
//  İlk örneği Yapay Zeka bölümünde yazıldı (yz_erteli.dart); orası bölümün
//  kendi yazı tiplerini ve açılış ölçümünü de beklediği için ayrı kaldı.
//  Burada o davranışın yazı tipinden ve bölümden bağımsız hâli var — yeni
//  bir ekranı ertelemek artık bir dosya yazmayı gerektirmiyor.
//
//  GÖSTERGE 400 MS SONRA beliriyor: hızlı bağlantıda paket bundan önce
//  iniyor ve okur hiçbir şey görmüyor. Hemen çizilse her girişte bir
//  titreme olurdu.
//
//  İNDİRME DÜŞERSE sayfa bunu söylüyor ve yeniden denetiyor; okuru boş bir
//  ekranda bırakmıyor.
//
//  [kimlik] hangi paketin indiğini tutuyor: bir kez inince tarayıcıda
//  kalıyor, ikinci girişte bekleme yok. Tek bir statik bayrak yetmezdi —
//  farklı paketler birbirini inmiş sayardı.
// ══════════════════════════════════════════════════════════════════════════
class ErteliSayfa extends StatefulWidget {
  const ErteliSayfa({
    super.key,
    required this.kimlik,
    required this.yukle,
    required this.kur,
  });

  /// Paketin adı — yalnız "indi mi" kaydı için.
  final String kimlik;

  /// Erteli kütüphanenin `loadLibrary`'si.
  final Future<void> Function() yukle;

  /// Paket inince ekranı kuran işlev. Erteli kütüphanenin TİPLERİ burada
  /// anılamaz (ilk yükte yoklar); bu yüzden tip değil, işlev alıyor.
  final Widget Function() kur;

  static final Set<String> _inenler = <String>{};

  @visibleForTesting
  static void testIcinSifirla() => _inenler.clear();

  @override
  State<ErteliSayfa> createState() => _ErteliSayfaState();
}

class _ErteliSayfaState extends State<ErteliSayfa> {
  Object? _hata;
  bool _gecikti = false;
  Timer? _sayac;

  bool get _indi => ErteliSayfa._inenler.contains(widget.kimlik);

  @override
  void initState() {
    super.initState();
    if (!_indi) _indir();
  }

  Future<void> _indir() async {
    _sayac?.cancel();
    _sayac = Timer(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _gecikti = true);
    });
    try {
      await widget.yukle();
      ErteliSayfa._inenler.add(widget.kimlik);
    } catch (e) {
      _hata = e;
    }
    _sayac?.cancel();
    if (mounted) setState(() {});
  }

  void _yenidenDene() {
    setState(() {
      _hata = null;
      _gecikti = false;
    });
    _indir();
  }

  @override
  void dispose() {
    _sayac?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_indi) return widget.kur();
    final en = Localizations.localeOf(context).languageCode == 'en';
    final tema = Theme.of(context);
    final Widget icerik;
    if (_hata != null) {
      icerik = Column(mainAxisSize: MainAxisSize.min, children: [
        Text(
          en
              ? 'The page could not be loaded. Check your connection and try again.'
              : 'Sayfa yüklenemedi. Bağlantınızı denetleyip yeniden deneyin.',
          textAlign: TextAlign.center,
          style: tema.textTheme.bodyLarge?.copyWith(height: 1.45),
        ),
        const SizedBox(height: 18),
        OutlinedButton(
          onPressed: _yenidenDene,
          child: Text(en ? 'Try again' : 'Yeniden dene'),
        ),
      ]);
    } else if (_gecikti) {
      icerik = Semantics(
        label: en ? 'Loading' : 'Yükleniyor',
        child: const SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      );
    } else {
      icerik = const SizedBox.shrink();
    }
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: icerik,
          ),
        ),
      ),
    );
  }
}
