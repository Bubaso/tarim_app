import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'yz_olcum_gonderici.dart';
import 'yz_tasarim.dart';

/// Bölümün yazı tiplerini paketle birlikte ister ve en çok [azami] bekler
/// (madde 16). Newsreader, Outfit 700 ve IBM Plex Mono 500/600
/// `assets/google_fonts/`'ta gömülü; google_fonts onları ağdan değil paketin
/// varlıklarından yüklüyor, ama yükleme yine eşzamansız. Beklenmezse metin
/// ilk karede yedek yazıyla (Roboto, %4,9 daha geniş) çiziliyor, Newsreader
/// gelince bütün paragraflar yeniden diziliyor; `?bolum=` ve "Kaldığınız yer"
/// atlamaları da yedek ölçülerle hesaplanıp yanlış yere düşüyor.
///
/// Gelmezse ya da hata verirse sayfa bugünkü gibi yedek yazıyla açılıyor.
/// `pendingFonts` sitenin o an yüklenen öteki yazı tiplerini de bekliyor;
/// üst sınır bu yüzden şart.
Future<void> yzYaziTipleriniBekle({Duration azami = const Duration(milliseconds: 1200)}) async {
  try {
    GoogleFonts.newsreader();
    GoogleFonts.outfit(fontWeight: FontWeight.w700);
    GoogleFonts.ibmPlexMono(fontWeight: FontWeight.w500);
    GoogleFonts.ibmPlexMono(fontWeight: FontWeight.w600);
    await GoogleFonts.pendingFonts().timeout(azami);
  } catch (_) {
    // Süre doldu ya da yükleme düştü: yedek yazıyla devam.
  }
}

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
  const YzErteliSayfa({super.key, required this.yukle, required this.kur, this.yaziTipleri});

  /// Erteli kütüphanenin `loadLibrary`'si.
  final Future<void> Function() yukle;

  /// Paket inince ekranı kuran işlev.
  final Widget Function() kur;

  /// Paketle aynı anda beklenen yazı tipleri; verilmezse
  /// [yzYaziTipleriniBekle]. Yalnız ilk girişte beklenir.
  final Future<void> Function()? yaziTipleri;

  /// Testler indirme hâllerini sırayla sınayabilsin diye. [yaziTipleri]
  /// false ise yazı tipleri beklenmiş sayılır (testte yazı tipi yüklenmiyor).
  @visibleForTesting
  static void testIcinSifirla({bool yaziTipleri = false}) {
    _YzErteliSayfaState._yuklendi = false;
    _YzErteliSayfaState._yaziTipleriHazir = !yaziTipleri;
  }

  @override
  State<YzErteliSayfa> createState() => _YzErteliSayfaState();
}

class _YzErteliSayfaState extends State<YzErteliSayfa> {
  static bool _yuklendi = false;

  /// Yazı tipleri bir kez beklendi (geldi, süre doldu ya da düştü): ikinci
  /// girişte beklenmiyor.
  static bool _yaziTipleriHazir = false;

  Object? _hata;
  bool _gecikti = false;
  Timer? _sayac;

  @override
  void initState() {
    super.initState();
    yzOlcumAcilisBaslat();
    if (!_yuklendi) _indir();
  }

  Future<void> _indir() async {
    _sayac?.cancel();
    _sayac = Timer(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _gecikti = true);
    });
    try {
      if (_yaziTipleriHazir) {
        await widget.yukle();
      } else {
        // Paket ve yazı tipleri aynı anda (madde 16); yazı tipi en çok 1,2 s.
        await Future.wait([
          widget.yukle(),
          (widget.yaziTipleri ?? yzYaziTipleriniBekle)().then((_) => _yaziTipleriHazir = true,
              onError: (Object _) => _yaziTipleriHazir = true),
        ]);
      }
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
    if (_yuklendi) yzOlcumIlkMetinKaresi();
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
