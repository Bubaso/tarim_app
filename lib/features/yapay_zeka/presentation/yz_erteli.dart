import 'dart:async';

import 'package:flutter/material.dart';

import 'yz_tasarim.dart';

/// Erteli paketi indirip bölüm ekranını kuran sayfa (bkz. `yz_ekranlar.dart`).
///
/// Paket bir kez inince tarayıcıda kalıyor; bölüm içinde başlıktan başlığa
/// geçerken bekleme yok. [_yuklendi] bu yüzden statik: tamamlanmış bir
/// Future bile FutureBuilder'a bir kare boş ekran çizdirirdi.
///
/// Bağlantı hızlıysa okur bekleme göstergesini hiç görmüyor: gösterge
/// 400 ms sonra beliriyor. İndirme düşerse sayfa bunu söylüyor ve yeniden
/// denetiyor — boş bir sayfada bırakmıyor.
class YzErteliSayfa extends StatefulWidget {
  const YzErteliSayfa({super.key, required this.yukle, required this.kur});

  /// Erteli kütüphanenin `loadLibrary`'si.
  final Future<void> Function() yukle;

  /// Paket inince ekranı kuran işlev.
  final Widget Function() kur;

  /// Testler indirme hâllerini sırayla sınayabilsin diye.
  @visibleForTesting
  static void testIcinSifirla() => _YzErteliSayfaState._yuklendi = false;

  @override
  State<YzErteliSayfa> createState() => _YzErteliSayfaState();
}

class _YzErteliSayfaState extends State<YzErteliSayfa> {
  static bool _yuklendi = false;

  Object? _hata;
  bool _gecikti = false;
  Timer? _sayac;

  @override
  void initState() {
    super.initState();
    if (!_yuklendi) _indir();
  }

  Future<void> _indir() async {
    _sayac?.cancel();
    _sayac = Timer(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _gecikti = true);
    });
    try {
      await widget.yukle();
      _yuklendi = true;
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
    if (_yuklendi) return widget.kur();
    final en = Localizations.localeOf(context).languageCode == 'en';
    final Widget icerik;
    if (_hata != null) {
      icerik = Column(mainAxisSize: MainAxisSize.min, children: [
        Text(
          en
              ? 'The page could not be loaded. Check your connection and try again.'
              : 'Sayfa yüklenemedi. Bağlantınızı denetleyip yeniden deneyin.',
          textAlign: TextAlign.center,
          // Sitenin gövde yazısı, Newsreader DEĞİL: bu sayfa ilk yükte ve
          // YzYazi.govde Newsreader'ın yazı tipi tablosunu oraya taşırdı.
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: YzRenk.murekkep, height: 1.45),
        ),
        const SizedBox(height: 18),
        OutlinedButton(
          onPressed: _yenidenDene,
          style: OutlinedButton.styleFrom(
            foregroundColor: YzRenk.makine,
            side: const BorderSide(color: YzRenk.makine),
          ),
          child: Text(en ? 'Try again' : 'Yeniden dene'),
        ),
      ]);
    } else if (_gecikti) {
      icerik = Semantics(
        label: en ? 'Loading' : 'Yükleniyor',
        child: const SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(strokeWidth: 2.5, color: YzRenk.makine),
        ),
      );
    } else {
      icerik = const SizedBox.shrink();
    }
    return Scaffold(
      backgroundColor: YzRenk.zemin,
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
