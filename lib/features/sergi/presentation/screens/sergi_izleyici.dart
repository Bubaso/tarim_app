import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/utils/image_fallback_helper.dart';
import '../../data/models/sergi_eseri.dart';
import '../../providers/sergi_gorunum.dart';
import '../../providers/sergi_providers.dart';

/// İZLEYİCİ — tek karenin ekranı.
///
/// NEDEN AYRI SAYFA, DİYALOG DEĞİL. Eski ışık kutusu bir `showDialog`'du ve
/// çıkmaz sokaktı: bir kareyi açınca gezinmek için kapatıp ızgarada yerini
/// yeniden bulmak gerekiyordu. Sayfa olunca üç şey birden geliyor — kareler
/// arası geçiş, paylaşılabilir adres (`/sergi/eser/odul-01`) ve telefonda
/// geri tuşunun sayfadan değil KAREDEN çıkması.
///
/// ÇÖZÜNÜRLÜK TAVANI DEĞİŞMEDİ: kare hiçbir koşulda büyütülmüyor. Ölçek
/// her zaman 1'in altında; büyük ekranda kazanılan şey boyut değil, kareyi
/// çevreleyen sessizlik.
class SergiIzleyici extends ConsumerStatefulWidget {
  final String yarisma;
  final String kod;

  const SergiIzleyici({
    super.key,
    required this.kod,
    this.yarisma = 'utoify-16',
  });

  @override
  ConsumerState<SergiIzleyici> createState() => _SergiIzleyiciDurumu();
}

const _zemin = Color(0xFF0A0C0D);
const _yuzey = Color(0xFF15191C);
const _metin = Color(0xFFEDF1F2);
const _ikincil = Color(0xFF99A5A8);
const _vurgu = Color(0xFFC9A15A);

/// Gezintide bir karenin ekranda kalma süresi.
///
/// Yedi saniye: bir fotoğrafa bakmaya yetiyor, beklemeye dönüşmüyor.
const _gezintiAraligi = Duration(seconds: 7);

class _SergiIzleyiciDurumu extends ConsumerState<SergiIzleyici> {
  PageController? _denetim;
  final FocusNode _odak = FocusNode();
  int _sira = 0;
  bool _gezinti = false;
  Timer? _saat;

  /// Bağlam bağlantısından gelen atlama isteği. Liste yeniden kurulduktan
  /// SONRA işleniyor; süzgeç temizlenmişse kare ancak o zaman listede olur.
  String? _hedef;

  @override
  void dispose() {
    _saat?.cancel();
    _denetim?.dispose();
    _odak.dispose();
    super.dispose();
  }

  void _gezintiDegis() {
    setState(() => _gezinti = !_gezinti);
    _saat?.cancel();
    if (_gezinti) {
      _saat = Timer.periodic(_gezintiAraligi, (_) => _ilerle(1, dongu: true));
    }
  }

  void _ilerle(int yon, {bool dongu = false, int? uzunluk}) {
    final d = _denetim;
    if (d == null || !d.hasClients) return;
    final n = uzunluk ?? _uzunluk;
    if (n <= 1) return;
    var hedef = _sira + yon;
    if (hedef < 0) hedef = dongu ? n - 1 : 0;
    if (hedef >= n) hedef = dongu ? 0 : n - 1;
    if (hedef == _sira) return;
    d.animateToPage(
      hedef,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  int _uzunluk = 0;

  /// Komşu kareleri önden indir: geçiş anında boş çerçeve görünmesin.
  void _ondenYukle(List<SergiEseri> l, int i) {
    for (final k in [i - 1, i + 1, i + 2]) {
      if (k < 0 || k >= l.length) continue;
      final p = NewsArticleImage.providerFor(l[k].adres, estimatedWidth: 700);
      if (p != null) precacheImage(p, context);
    }
  }

  KeyEventResult _tus(FocusNode _, KeyEvent o) {
    if (o is! KeyDownEvent) return KeyEventResult.ignored;
    final t = o.logicalKey;
    if (t == LogicalKeyboardKey.arrowRight || t == LogicalKeyboardKey.keyD) {
      _ilerle(1);
      return KeyEventResult.handled;
    }
    if (t == LogicalKeyboardKey.arrowLeft || t == LogicalKeyboardKey.keyA) {
      _ilerle(-1);
      return KeyEventResult.handled;
    }
    if (t == LogicalKeyboardKey.space) {
      _gezintiDegis();
      return KeyEventResult.handled;
    }
    if (t == LogicalKeyboardKey.escape) {
      if (_gezinti) {
        _gezintiDegis();
      } else {
        _kapat();
      }
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _kapat() => context.canPop() ? context.pop() : context.go('/sergi');

  @override
  Widget build(BuildContext context) {
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final veri = ref.watch(sergiVerisiProvider(widget.yarisma));

    return Scaffold(
      backgroundColor: _zemin,
      body: veri.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: _vurgu, strokeWidth: 2),
        ),
        error: (_, __) => _Yok(isEn: isEn, kapat: _kapat),
        data: (v) {
          if (v == null) return _Yok(isEn: isEn, kapat: _kapat);

          var liste = sergiListesi(
            veri: v,
            suzgec: ref.watch(sergiSuzgeciProvider),
            yer: ref.watch(sergiYeriProvider),
            sira: ref.watch(sergiSirasiProvider),
            tohum: ref.watch(sergiTohumuProvider),
            isEn: isEn,
          );

          // Derin bağlantı açık bir süzgece düşebilir: adresteki kare süzgecin
          // dışında kalıyorsa süzgeci değil LİSTEYİ genişletiyoruz. Okurun
          // adresini açmak, okurun süzgecini bozmaktan önce gelir.
          final aranan = _hedef ?? widget.kod;
          if (!liste.any((e) => e.kod == aranan)) {
            liste = v.sirali(
              ref.watch(sergiSirasiProvider),
              isEn,
              tohum: ref.watch(sergiTohumuProvider),
            );
          }
          if (liste.isEmpty) return _Yok(isEn: isEn, kapat: _kapat);
          _uzunluk = liste.length;

          var i = liste.indexWhere((e) => e.kod == aranan);
          if (i < 0) i = 0;

          if (_denetim == null) {
            _sira = i;
            _denetim = PageController(initialPage: i);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _ondenYukle(liste, i);
            });
          } else if (_hedef != null) {
            final h = i;
            _hedef = null;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              final d = _denetim;
              if (d != null && d.hasClients && h != _sira) d.jumpToPage(h);
            });
          }

          return Focus(
            focusNode: _odak,
            autofocus: true,
            onKeyEvent: _tus,
            child: _Sahne(
              liste: liste,
              denetim: _denetim!,
              sira: _sira,
              isEn: isEn,
              veri: v,
              gezinti: _gezinti,
              gezintiDegis: _gezintiDegis,
              kapat: _kapat,
              ilerle: (y) => _ilerle(y),
              sayfaDegisti: (yeni) {
                setState(() => _sira = yeni);
                _ondenYukle(liste, yeni);
                // Adres kareyi izliyor ki paylaşılabilsin. `replace`:
                // geçmişe 114 giriş yığmıyor, geri tuşu ızgaraya dönüyor.
                final k = liste[yeni].kod;
                if (k != widget.kod) {
                  context.replace('/sergi/eser/$k');
                }
              },
              atla: (kod) {
                // Bağlam bağlantısı: süzgeci temizle, sonra o kareye git.
                ref.read(sergiSuzgeciProvider.notifier).state =
                    SergiSuzgeci.hepsi;
                ref.read(sergiYeriProvider.notifier).state = null;
                setState(() => _hedef = kod);
              },
              yereGit: (yer) {
                ref.read(sergiYeriProvider.notifier).state = yer;
                _kapat();
              },
            ),
          );
        },
      ),
    );
  }
}

class _Yok extends StatelessWidget {
  final bool isEn;
  final VoidCallback kapat;
  const _Yok({required this.isEn, required this.kapat});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isEn ? 'This photograph could not be found.'
                   : 'Bu kare bulunamadı.',
              style: GoogleFonts.inter(color: _ikincil, fontSize: 15),
            ),
            const SizedBox(height: 14),
            TextButton(
              onPressed: kapat,
              child: Text(
                isEn ? 'Back to the exhibition' : 'Sergiye dön',
                style: GoogleFonts.inter(color: _vurgu, fontSize: 14),
              ),
            ),
          ],
        ),
      );
}

/// Karenin kipi. Ekran boyu ve gezinti bunu belirliyor.
enum _Kip {
  /// Geniş ekran: solda kare, sağda künye. Kare büyüyemediği için büyük
  /// ekranda kazanılan yer künyeye ve boşluğa gidiyor.
  iki,

  /// Dar ekran: kare üstte, künye altında.
  alt,

  /// Yatay telefon ve gezinti: kare ekranı doldurur, künye tek satır.
  /// Künye YİNE DE var — kareden ayrılmıyor.
  satir,
}

class _Sahne extends StatelessWidget {
  final List<SergiEseri> liste;
  final PageController denetim;
  final int sira;
  final bool isEn;
  final SergiVerisi veri;
  final bool gezinti;
  final VoidCallback gezintiDegis;
  final VoidCallback kapat;
  final void Function(int) ilerle;
  final void Function(int) sayfaDegisti;
  final void Function(String) atla;
  final void Function(String) yereGit;

  const _Sahne({
    required this.liste,
    required this.denetim,
    required this.sira,
    required this.isEn,
    required this.veri,
    required this.gezinti,
    required this.gezintiDegis,
    required this.kapat,
    required this.ilerle,
    required this.sayfaDegisti,
    required this.atla,
    required this.yereGit,
  });

  @override
  Widget build(BuildContext context) {
    final g = MediaQuery.sizeOf(context);
    final _Kip kip;
    if (gezinti || g.height < 560) {
      kip = _Kip.satir;
    } else if (g.width >= 1000) {
      kip = _Kip.iki;
    } else {
      kip = _Kip.alt;
    }
    final okCikar = g.width >= 760;

    return Stack(
      children: [
        Positioned.fill(
          child: PageView.builder(
            controller: denetim,
            onPageChanged: sayfaDegisti,
            itemCount: liste.length,
            itemBuilder: (context, i) => _Kare(
              eser: liste[i],
              isEn: isEn,
              veri: veri,
              kip: kip,
              atla: atla,
              yereGit: yereGit,
              sayac: '${i + 1} / ${liste.length}',
            ),
          ),
        ),
        if (okCikar) ...[
          _Ok(
            sol: true,
            etkin: sira > 0,
            bas: () => ilerle(-1),
            isEn: isEn,
          ),
          _Ok(
            sol: false,
            etkin: sira < liste.length - 1,
            bas: () => ilerle(1),
            isEn: isEn,
          ),
        ],
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: _UstCubuk(
            isEn: isEn,
            gezinti: gezinti,
            gezintiDegis: gezintiDegis,
            kapat: kapat,
            sayac: '${sira + 1} / ${liste.length}',
          ),
        ),
      ],
    );
  }
}

/// Tek karenin sahnesi.
class _Kare extends StatelessWidget {
  final SergiEseri eser;
  final bool isEn;
  final SergiVerisi veri;
  final _Kip kip;
  final void Function(String) atla;
  final void Function(String) yereGit;
  final String sayac;

  const _Kare({
    required this.eser,
    required this.isEn,
    required this.veri,
    required this.kip,
    required this.atla,
    required this.yereGit,
    required this.sayac,
  });

  @override
  Widget build(BuildContext context) {
    final ust = MediaQuery.paddingOf(context).top + 52;
    switch (kip) {
      case _Kip.satir:
        return Padding(
          padding: EdgeInsets.fromLTRB(12, ust, 12, 12),
          child: Column(
            children: [
              Expanded(
                child: _Cerceve(eser: eser, isEn: isEn, mat: 0),
              ),
              const SizedBox(height: 10),
              _KunyeSatiri(eser: eser, isEn: isEn, sayac: sayac),
            ],
          ),
        );
      case _Kip.alt:
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16, ust, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Yükseklik KARENİN KENDİ ORANINDAN geliyor, ekranın sabit
              // bir yüzdesinden değil. Yüzdeye bağlandığında kare
              // genişlikten sınırlanıyor ve altında yüz altmış piksellik
              // ölü boşluk kalıyordu. Tavan yine de var: çok dikey bir
              // kare (sergide iki tane) künyeyi ekrandan atmasın.
              Builder(builder: (context) {
                const mat = 8.0;
                final ekran = MediaQuery.sizeOf(context);
                final icEn = ekran.width - 32 - mat * 2;
                final oran = eser.enBoy <= 0 ? 1.5 : eser.enBoy;
                final boy = math.min(
                  icEn / oran + mat * 2,
                  ekran.height * 0.62,
                );
                return SizedBox(
                  height: math.max(200, boy),
                  child: _Cerceve(eser: eser, isEn: isEn, mat: mat),
                );
              }),
              const SizedBox(height: 22),
              _KunyePaneli(
                eser: eser,
                isEn: isEn,
                veri: veri,
                atla: atla,
                yereGit: yereGit,
                sayac: sayac,
                genis: false,
              ),
            ],
          ),
        );
      case _Kip.iki:
        return Padding(
          padding: EdgeInsets.fromLTRB(56, ust + 8, 56, 44),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: _Cerceve(eser: eser, isEn: isEn, mat: 16)),
              const SizedBox(width: 48),
              SizedBox(
                width: 340,
                child: SingleChildScrollView(
                  child: _KunyePaneli(
                    eser: eser,
                    isEn: isEn,
                    veri: veri,
                    atla: atla,
                    yereGit: yereGit,
                    sayac: sayac,
                    genis: true,
                  ),
                ),
              ),
            ],
          ),
        );
    }
  }
}

/// KARE VE ÇERÇEVESİ. Tek kural: ölçek asla 1'i geçmiyor.
class _Cerceve extends StatelessWidget {
  final SergiEseri eser;
  final bool isEn;
  final double mat;

  const _Cerceve({required this.eser, required this.isEn, required this.mat});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, k) {
      final kaynakEn = (eser.en ?? 600).toDouble();
      final kaynakBoy =
          (eser.boy ?? (kaynakEn / (eser.enBoy == 0 ? 1.5 : eser.enBoy)))
              .toDouble();
      final alanEn = math.max(80.0, k.maxWidth - mat * 2);
      final alanBoy = math.max(
        80.0,
        (k.maxHeight.isFinite ? k.maxHeight : kaynakBoy) - mat * 2,
      );
      // BÜYÜTME YOK: ölçek 1'in üstüne çıkamaz. Yatay telefonda sınırlayan
      // yükseklik, geniş ekranda kaynağın kendisi oluyor.
      final olcek =
          math.min(1.0, math.min(alanEn / kaynakEn, alanBoy / kaynakBoy));
      final en = kaynakEn * olcek;
      final boy = kaynakBoy * olcek;

      return Center(
        child: Container(
          padding: EdgeInsets.all(mat),
          decoration: mat == 0
              ? null
              : BoxDecoration(
                  color: _yuzey,
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.07)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.55),
                      blurRadius: 34,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
          child: Semantics(
            image: true,
            label: eser.kunye(isEn),
            child: SizedBox(
              width: en,
              height: boy,
              child: NewsArticleImage(
                imageUrl: eser.adres,
                fit: BoxFit.contain,
                isHighQuality: true,
                semanticLabel: eser.kunye(isEn),
              ),
            ),
          ),
        ),
      );
    });
  }
}

/// KÜNYE PANELİ. Fotoğrafçının adı sayfanın en büyük yazısı — kare
/// büyüyemiyor, büyüyen şey künye oluyor.
class _KunyePaneli extends StatelessWidget {
  final SergiEseri eser;
  final bool isEn;
  final SergiVerisi veri;
  final void Function(String) atla;
  final void Function(String) yereGit;
  final String sayac;
  final bool genis;

  const _KunyePaneli({
    required this.eser,
    required this.isEn,
    required this.veri,
    required this.atla,
    required this.yereGit,
    required this.sayac,
    required this.genis,
  });

  @override
  Widget build(BuildContext context) {
    final ayniKisi = veri.ayniFotografcidan(eser);
    final ayniYer = veri.ayniYerden(eser, isEn);
    final yerAnahtari =
        eser.il?.trim().isNotEmpty == true ? eser.il!.trim() : eser.ulke(isEn);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (eser.odulluMu) ...[
          Text(
            eser.odul(isEn).toUpperCase(),
            style: GoogleFonts.inter(
              color: _vurgu,
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
        ],
        Text(
          eser.eser,
          style: GoogleFonts.outfit(
            color: _metin.withValues(alpha: 0.92),
            fontSize: genis ? 17 : 16,
            fontWeight: FontWeight.w500,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          eser.fotografci,
          style: GoogleFonts.outfit(
            color: _metin,
            fontSize: genis ? 30 : 26,
            fontWeight: FontWeight.w700,
            height: 1.12,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 9),
        InkWell(
          onTap: () => yereGit(yerAnahtari),
          borderRadius: BorderRadius.circular(3),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.place_outlined,
                    size: 14, color: _ikincil.withValues(alpha: 0.8)),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    eser.yer(isEn),
                    style: GoogleFonts.inter(
                      color: _ikincil,
                      fontSize: 13.5,
                      decoration: TextDecoration.underline,
                      decorationColor: _ikincil.withValues(alpha: 0.35),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Container(height: 1, color: Colors.white.withValues(alpha: 0.08)),
        const SizedBox(height: 16),
        if (ayniKisi.isNotEmpty) ...[
          Text(
            isEn
                ? 'ALSO BY THIS PHOTOGRAPHER · ${ayniKisi.length}'
                : 'BU FOTOĞRAFÇININ DİĞER KARELERİ · ${ayniKisi.length}',
            style: GoogleFonts.inter(
              color: _ikincil.withValues(alpha: 0.75),
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final k in ayniKisi.take(4))
                Semantics(
                  button: true,
                  label: k.kunye(isEn),
                  child: InkWell(
                    onTap: () => atla(k.kod),
                    child: SizedBox(
                      width: 74,
                      height: 50,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: NewsArticleImage(
                          imageUrl: k.adres,
                          fit: BoxFit.cover,
                          semanticLabel: k.kunye(isEn),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
        ],
        if (ayniYer.isNotEmpty)
          InkWell(
            onTap: () => yereGit(yerAnahtari),
            borderRadius: BorderRadius.circular(3),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                border:
                    Border.all(color: _ikincil.withValues(alpha: 0.32)),
              ),
              child: Text(
                isEn
                    ? '${ayniYer.length + 1} photographs from $yerAnahtari'
                    : '$yerAnahtari\'${ayrilmaEki(yerAnahtari)} '
                        '${ayniYer.length + 1} kare',
                style: GoogleFonts.inter(
                  color: _metin.withValues(alpha: 0.88),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        const SizedBox(height: 18),
        Text(
          sayac,
          style: GoogleFonts.robotoMono(
            color: _ikincil.withValues(alpha: 0.55),
            fontSize: 11.5,
          ),
        ),
      ],
    );
  }
}

/// Tek satırlık künye — yatay telefonda ve gezintide. Kısalıyor ama
/// KAYBOLMUYOR.
class _KunyeSatiri extends StatelessWidget {
  final SergiEseri eser;
  final bool isEn;
  final String sayac;

  const _KunyeSatiri({
    required this.eser,
    required this.isEn,
    required this.sayac,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: RichText(
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              children: [
                TextSpan(
                  text: eser.eser,
                  style: GoogleFonts.outfit(
                    color: _metin.withValues(alpha: 0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextSpan(
                  text: '  ·  ',
                  style: GoogleFonts.inter(
                      color: _ikincil.withValues(alpha: 0.6), fontSize: 13),
                ),
                TextSpan(
                  text: eser.fotografci,
                  style: GoogleFonts.outfit(
                    color: _metin,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(
                  text: ', ${eser.yer(isEn)}',
                  style: GoogleFonts.inter(color: _ikincil, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 14),
        Text(
          sayac,
          style: GoogleFonts.robotoMono(
            color: _ikincil.withValues(alpha: 0.55),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _UstCubuk extends StatelessWidget {
  final bool isEn;
  final bool gezinti;
  final VoidCallback gezintiDegis;
  final VoidCallback kapat;
  final String sayac;

  const _UstCubuk({
    required this.isEn,
    required this.gezinti,
    required this.gezintiDegis,
    required this.kapat,
    required this.sayac,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            IconButton(
              onPressed: kapat,
              icon: const Icon(Icons.arrow_back_rounded),
              color: _metin.withValues(alpha: 0.85),
              tooltip: isEn ? 'Back' : 'Geri',
            ),
            const Spacer(),
            Text(
              sayac,
              style: GoogleFonts.robotoMono(
                color: _ikincil.withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 6),
            IconButton(
              onPressed: gezintiDegis,
              icon: Icon(gezinti
                  ? Icons.pause_rounded
                  : Icons.play_arrow_rounded),
              color: gezinti ? _vurgu : _metin.withValues(alpha: 0.85),
              tooltip: gezinti
                  ? (isEn ? 'Pause the walk' : 'Gezintiyi durdur')
                  : (isEn ? 'Walk through the exhibition' : 'Sergi gezintisi'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Ok extends StatelessWidget {
  final bool sol;
  final bool etkin;
  final VoidCallback bas;
  final bool isEn;

  const _Ok({
    required this.sol,
    required this.etkin,
    required this.bas,
    required this.isEn,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: sol ? 6 : null,
      right: sol ? null : 6,
      top: 0,
      bottom: 0,
      child: Center(
        child: AnimatedOpacity(
          opacity: etkin ? 1 : 0.18,
          duration: const Duration(milliseconds: 180),
          child: IconButton(
            onPressed: etkin ? bas : null,
            iconSize: 30,
            color: _metin.withValues(alpha: 0.75),
            tooltip: sol
                ? (isEn ? 'Previous' : 'Önceki')
                : (isEn ? 'Next' : 'Sonraki'),
            icon: Icon(sol
                ? Icons.chevron_left_rounded
                : Icons.chevron_right_rounded),
          ),
        ),
      ),
    );
  }
}

/// Türkçe AYRILMA HÂLİ EKİ: -dan / -den / -tan / -ten.
///
/// NEDEN ELLE. Sabit bir `'dan` eki "Bangladeş'dan", "Çin'dan",
/// "İzmir'dan" üretiyordu. Sergide 42 il ve 11 ülke var; hepsi künyenin
/// parçası ve künyede özensizlik olmaz.
///
/// Kural iki parçalı: son ÜNLÜ eki inceltir ya da kalınlaştırır, son HARF
/// sertse ek de sertleşir. Büyük/küçük harfe çevirme YOK — Türkçede
/// `I`/`İ` dönüşümü bozuk; harf kümeleri iki biçimi de doğrudan sayıyor
/// (bkz. hattın `kucult` kuralı).
String ayrilmaEki(String ad) {
  // İSTİSNA. Alıntı sözcüklerde son `l` ince okunur ve kalın ünlüye
  // rağmen ince ek alır: "Nepal'den", "Kemal'den", "kabulden". Bu kuraldan
  // türetilemiyor, sözlük gerektiriyor. Serginin verisindeki 11 ülke ve
  // 42 ilin tamamı tek tek sınandı; kuralı bozan yalnız bu ad.
  const istisna = {'Nepal': 'den'};
  final i = istisna[ad];
  if (i != null) return i;

  const unluler = 'aeıioöuüâAEIİOÖUÜÂ';
  const kalinlar = 'aıouâAIOUÂ';
  const sertler = 'fstkçşhpFSTKÇŞHP';

  var kalin = true;
  for (var i = ad.length - 1; i >= 0; i--) {
    if (unluler.contains(ad[i])) {
      kalin = kalinlar.contains(ad[i]);
      break;
    }
  }
  final sert = ad.isNotEmpty && sertler.contains(ad[ad.length - 1]);
  if (kalin) return sert ? 'tan' : 'dan';
  return sert ? 'ten' : 'den';
}
