import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Telefonda görselin tam ekran gösterimi (mobil okuma turu, karar 62).
///
/// Koyu zemin, iki parmakla ya da çift dokunuşla 4 kata kadar yakınlaştırma,
/// sağ üstte 48 piksellik kapatma düğmesi, altta künye. Çentik ve alt çubuk
/// payı (güvenli alan) korunuyor. Masaüstünde eski büyütme penceresi
/// kullanılıyor (yz_gorsel.dart).
///
/// Kapatma yolları: Kapat düğmesi, görselin dışındaki koyu zemine tek
/// dokunuş ve (yakınlaşmamışken) görseli aşağı ya da yukarı çekip bırakmak.
///
/// Bilinen sınır: gösterim GoRouter'ın dışında, kök gezginde sayfasız bir
/// rota. Web'de tarayıcının geri düğmesi (ya da Android'in geri hareketi)
/// adres değişikliği olarak GoRouter'a gidiyor; gösterimi kapatmıyor,
/// makaleden de çıkıyor. Bunu düzeltmek gösterimi adres geçmişine bağlamayı
/// (yönlendirici dosyasında alt rota ya da sorgu değişkeni) gerektiriyor.
///
/// [uzun]: içerik ekran genişliğinde kuruluyor ve boyu sınırsız (çizilmiş
/// şemanın dar düzeni); 1 katta dikey kaydırılıyor, çekip kapatma yok.
///
/// [gezinti]: verilirse gösterim bir DİZİ üzerinde geziyor — oklarla,
/// klavyeyle ve yana kaydırarak. Verilmezse eski davranış birebir duruyor;
/// tek kare açan çağıranlar (yz_gorsel.dart) değişmedi.
Future<void> yzGorselTamEkran(
  BuildContext context, {
  required Widget gorunum,
  required String altyazi,
  required bool en,
  bool uzun = false,
  YzGezinti? gezinti,
}) =>
    Navigator.of(context, rootNavigator: true).push<void>(PageRouteBuilder<void>(
      opaque: true,
      fullscreenDialog: true,
      transitionDuration: const Duration(milliseconds: 180),
      reverseTransitionDuration: const Duration(milliseconds: 140),
      pageBuilder: (c, a1, a2) => YzGorselTamEkran(
          gorunum: gorunum, altyazi: altyazi, en: en, uzun: uzun, gezinti: gezinti),
      transitionsBuilder: (c, a, a2, cocuk) => FadeTransition(opacity: a, child: cocuk),
    ));

/// Tam ekranda bir diziyi gezmenin sözleşmesi.
///
/// Kareleri HAZIR WIDGET LİSTESİ olarak almıyor: 173 karelik bir galeride
/// bu, gösterim açılır açılmaz 173 `Image.network` kurardı. Kurucu
/// işlevler yalnız bakılan kareyi (ve komşularını) çiziyor.
class YzGezinti {
  const YzGezinti({
    required this.adet,
    required this.baslangic,
    required this.gorunum,
    required this.altyazi,
  }) : assert(adet > 0);

  /// Dizideki kare sayısı.
  final int adet;

  /// Açılışta gösterilen karenin sırası (0'dan).
  final int baslangic;

  /// i. karenin görünümü.
  final Widget Function(int i) gorunum;

  /// i. karenin künyesi.
  final String Function(int i) altyazi;
}

/// Görseli bu kadar çekip bırakınca gösterim kapanıyor.
const double kYzCekipKapatma = 120;

/// Neredeyse siyah; fotoğrafın renkleri ve koyu şemanın zemini ayrılıyor.
const Color kYzTamEkranZemin = Color(0xFF0C0E0D);

class YzGorselTamEkran extends StatefulWidget {
  const YzGorselTamEkran({
    super.key,
    required this.gorunum,
    required this.altyazi,
    required this.en,
    this.uzun = false,
    this.gezinti,
  });
  final Widget gorunum;
  final String altyazi;
  final bool en;
  final bool uzun;
  final YzGezinti? gezinti;

  @override
  State<YzGorselTamEkran> createState() => _YzGorselTamEkranState();
}

class _YzGorselTamEkranState extends State<YzGorselTamEkran> {
  static const double _ciftDokunusOlcegi = 2.5;

  /// Yana bu kadar çekip bırakınca bir sonraki/önceki kareye geçiliyor.
  static const double _kaydirmaEsigi = 80;

  final _donusum = TransformationController();
  final _odak = FocusNode(debugLabel: 'yzTamEkran');
  Offset _dokunus = Offset.zero;

  /// Dizideki yer. Gezinti yoksa hep 0 ve kullanılmıyor.
  late int _i = widget.gezinti?.baslangic ?? 0;

  YzGezinti? get _gez => widget.gezinti;
  bool get _gezinilir => _gez != null && _gez!.adet > 1;

  Widget get _gorunum => _gez == null ? widget.gorunum : _gez!.gorunum(_i);
  String get _altyazi => _gez == null ? widget.altyazi : _gez!.altyazi(_i);

  @override
  void dispose() {
    _donusum.dispose();
    _odak.dispose();
    super.dispose();
  }

  /// YAKINLAŞMA SIFIRLANIYOR. Kare değişirken eski karenin dönüşümü
  /// kalsaydı yeni kare 2,5 kat yakınlaşmış ve kaydırılmış açılırdı.
  void _git(int yon) {
    if (!_gezinilir) return;
    final hedef = _i + yon;
    if (hedef < 0 || hedef >= _gez!.adet) return;
    setState(() {
      _i = hedef;
      _donusum.value = Matrix4.identity();
      _kaydirma = 0;
      _cekme = 0;
    });
  }

  /// Çekip kapatma: tek parmakla, yakınlaşmamışken başlayan hareket.
  bool _cekiliyor = false;
  double _cekme = 0;

  /// Yana çekme (yalnız gezinti varken). Eksen İLK ANLAMLI HAREKETTE
  /// kilitleniyor: kilitlenmeseydi çapraz bir hareket hem kareyi kaydırır
  /// hem kapatmaya yaklaştırırdı.
  double _kaydirma = 0;
  Axis? _eksen;

  /// Çift dokunuş: yakın değilse dokunulan yere 2,5 kat yaklaş (o nokta
  /// yerinde kalır), yakınlaşmışsa geri dön.
  void _ciftDokunus() {
    final olcek = _donusum.value.getMaxScaleOnAxis();
    if (olcek > 1.01) {
      _donusum.value = Matrix4.identity();
      return;
    }
    const s = _ciftDokunusOlcegi;
    final p = _dokunus;
    _donusum.value = Matrix4.translationValues(p.dx, p.dy, 0)
      ..multiply(Matrix4.diagonal3Values(s, s, 1))
      ..multiply(Matrix4.translationValues(-p.dx, -p.dy, 0))
      ..multiply(_donusum.value);
  }

  void _kapat() => Navigator.of(context).maybePop();

  void _cekmeBasladi(ScaleStartDetails d) {
    _cekiliyor = !widget.uzun && d.pointerCount == 1 && _donusum.value.getMaxScaleOnAxis() <= 1.01;
    _eksen = null;
  }

  void _cekmeSurdu(ScaleUpdateDetails d) {
    if (!_cekiliyor) return;
    if (d.pointerCount > 1 || (d.scale - 1).abs() > 0.01) {
      // İkinci parmak geldi: yakınlaştırma, çekme değil.
      _cekiliyor = false;
      _eksen = null;
      if (_cekme != 0 || _kaydirma != 0) setState(() { _cekme = 0; _kaydirma = 0; });
      return;
    }
    final d2 = d.focalPointDelta;
    if (_eksen == null) {
      // Eksen kilidi: yatay yalnız gezinti varken açılıyor; yoksa her
      // hareket dikey sayılıyor ve eski kapatma davranışı korunuyor.
      final toplam = Offset(_kaydirma + d2.dx, _cekme + d2.dy);
      if (toplam.distance < 8) {
        setState(() { _cekme += d2.dy; _kaydirma += d2.dx; });
        return;
      }
      _eksen = (_gezinilir && toplam.dx.abs() > toplam.dy.abs())
          ? Axis.horizontal
          : Axis.vertical;
      setState(() {
        if (_eksen == Axis.horizontal) { _cekme = 0; } else { _kaydirma = 0; }
      });
    }
    setState(() {
      if (_eksen == Axis.horizontal) {
        _kaydirma += d2.dx;
      } else {
        _cekme += d2.dy;
      }
    });
  }

  void _cekmeBitti(ScaleEndDetails d) {
    final yatay = _eksen == Axis.horizontal;
    final h = d.velocity.pixelsPerSecond;
    if (_cekiliyor && yatay) {
      final gec = _kaydirma.abs() > _kaydirmaEsigi ||
          (h.dx.abs() > 900 && _kaydirma.abs() > 24);
      _cekiliyor = false;
      _eksen = null;
      if (gec) {
        _git(_kaydirma < 0 ? 1 : -1);   // sola çekmek ileri götürüyor
      } else {
        setState(() => _kaydirma = 0);
      }
      return;
    }
    final kapat = _cekiliyor &&
        (_cekme.abs() > kYzCekipKapatma || (h.dy.abs() > 900 && _cekme.abs() > 24));
    _cekiliyor = false;
    _eksen = null;
    if (kapat) {
      _kapat();
    } else if (_cekme != 0 || _kaydirma != 0) {
      setState(() { _cekme = 0; _kaydirma = 0; });
    }
  }

  /// Klavye: masaüstünde ve web'de okun karşılığı. Yakınlaşmışken de
  /// çalışıyor; _git zaten yakınlaşmayı sıfırlıyor.
  KeyEventResult _tus(FocusNode _, KeyEvent olay) {
    if (olay is! KeyDownEvent && olay is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final t = olay.logicalKey;
    if (t == LogicalKeyboardKey.arrowRight || t == LogicalKeyboardKey.pageDown) {
      _git(1);
      return KeyEventResult.handled;
    }
    if (t == LogicalKeyboardKey.arrowLeft || t == LogicalKeyboardKey.pageUp) {
      _git(-1);
      return KeyEventResult.handled;
    }
    if (t == LogicalKeyboardKey.escape) {
      _kapat();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final en = widget.en;
    final pay = MediaQuery.paddingOf(context);
    final kapat = en ? 'Close' : 'Kapat';
    // Görselin kendisine tek dokunuş bir şey yapmıyor (zemine dokunuş
    // kapatıyor); çift dokunuş dıştaki algılayıcıya kalıyor.
    final gorsel = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {},
      child: Semantics(image: true, label: _altyazi, child: _gorunum),
    );
    final Widget icerik;
    if (widget.uzun) {
      // Genişlik ve en az boy dıştaki InteractiveViewer kısmında veriliyor;
      // üstte kapatma düğmesine, altta künyeye yer bırakılıyor.
      icerik = Padding(
        padding: EdgeInsets.fromLTRB(12 + pay.left, pay.top + 60, 12 + pay.right, pay.bottom + 110),
        child: Center(child: gorsel),
      );
    } else {
      icerik = Transform.translate(
        offset: Offset(_kaydirma, _cekme),
        child: Padding(
          padding: EdgeInsets.only(top: pay.top, bottom: pay.bottom),
          child: Center(child: gorsel),
        ),
      );
    }
    return Focus(
      focusNode: _odak,
      autofocus: true,
      onKeyEvent: _tus,
      child: Material(
      color: kYzTamEkranZemin,
      child: Stack(children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: _kapat,
            onDoubleTapDown: (d) => _dokunus = d.localPosition,
            onDoubleTap: _ciftDokunus,
            child: widget.uzun
                ? LayoutBuilder(
                    builder: (context, kis) => InteractiveViewer(
                      transformationController: _donusum,
                      constrained: false,
                      minScale: 1,
                      maxScale: 4,
                      child: SizedBox(
                        width: kis.maxWidth,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minHeight: kis.maxHeight),
                          child: icerik,
                        ),
                      ),
                    ),
                  )
                : InteractiveViewer(
                    transformationController: _donusum,
                    minScale: 1,
                    maxScale: 4,
                    onInteractionStart: _cekmeBasladi,
                    onInteractionUpdate: _cekmeSurdu,
                    onInteractionEnd: _cekmeBitti,
                    child: icerik,
                  ),
          ),
        ),
        // Künye: altta, zemine koyulaşan bir geçişin üstünde.
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [kYzTamEkranZemin.withValues(alpha: 0), kYzTamEkranZemin.withValues(alpha: 0.88)],
                ),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(16 + pay.left, 28, 16 + pay.right, 16 + pay.bottom),
                child: ExcludeSemantics(
                  child: Text(
                    _altyazi,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                        fontSize: 14, fontWeight: FontWeight.w500, height: 1.4, color: const Color(0xFFE6EAE7)),
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: pay.top + 4,
          right: pay.right + 4,
          child: Semantics(
            button: true,
            label: kapat,
            onTap: _kapat,
            excludeSemantics: true,
            child: Material(
              color: Colors.black.withValues(alpha: 0.45),
              shape: const CircleBorder(),
              child: IconButton(
                tooltip: kapat,
                constraints: const BoxConstraints.tightFor(width: 48, height: 48),
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.close_rounded, color: Colors.white, size: 26),
                onPressed: _kapat,
              ),
            ),
          ),
        ),
        // ── Diziyi gezme ─────────────────────────────────────────────
        // Oklar yalnız gidilecek yer varken çiziliyor: sönük ama basılabilen
        // bir düğme, okura "burada bir şey var" diyip hiçbir şey yapmaz.
        if (_gezinilir) ...[
          if (_i > 0)
            _Ok(
              sol: true,
              pay: pay,
              etiket: en ? 'Previous' : 'Önceki',
              bas: () => _git(-1),
            ),
          if (_i < _gez!.adet - 1)
            _Ok(
              sol: false,
              pay: pay,
              etiket: en ? 'Next' : 'Sonraki',
              bas: () => _git(1),
            ),
          // Sayaç: 173 karelik bir dizide okurun nerede olduğunu söyleyen
          // tek işaret.
          Positioned(
            top: pay.top + 16,
            left: pay.left + 20,
            child: IgnorePointer(
              child: Text(
                '${_i + 1} / ${_gez!.adet}',
                style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                    color: const Color(0xFFE6EAE7)),
              ),
            ),
          ),
        ],
      ]),
      ),
    );
  }
}

/// Tam ekranda ileri/geri oku. Kapatma düğmesiyle aynı dilde: 48 piksel,
/// yarı saydam siyah daire.
class _Ok extends StatelessWidget {
  const _Ok({
    required this.sol,
    required this.pay,
    required this.etiket,
    required this.bas,
  });

  final bool sol;
  final EdgeInsets pay;
  final String etiket;
  final VoidCallback bas;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: sol ? pay.left + 8 : null,
      right: sol ? null : pay.right + 8,
      top: 0,
      bottom: 0,
      child: Center(
        child: Semantics(
          button: true,
          label: etiket,
          onTap: bas,
          excludeSemantics: true,
          child: Material(
            color: Colors.black.withValues(alpha: 0.45),
            shape: const CircleBorder(),
            child: IconButton(
              tooltip: etiket,
              constraints: const BoxConstraints.tightFor(width: 48, height: 48),
              padding: EdgeInsets.zero,
              icon: Icon(
                  sol ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
                  color: Colors.white,
                  size: 30),
              onPressed: bas,
            ),
          ),
        ),
      ),
    );
  }
}
