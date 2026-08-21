import 'package:flutter/material.dart';

/// Bir bölümün ekrana ilk girişinde belirmesi.
///
/// **Neden.** Dosya on üç bölüm; hepsi aynı anda tam görünürlükte durduğunda
/// sayfa tek bir upuzun blok gibi okunuyor. Bölüm ekrana girerken kısa bir
/// belirme, okura "burada yeni bir şey başlıyor" diyor — basılı bir dosyada
/// sayfa çevirmenin yaptığı iş.
///
/// **Neden yalnızca bir kez.** Bölümler tembel kurulduğu için yukarı geri
/// kaydırıldığında yeniden kurulabiliyor. Her kuruluşta yeniden oynasaydı
/// aşağı-yukarı gezinen okurun gözünde sayfa sürekli yanıp sönerdi. Hangi
/// bölümün oynadığını çağıran ekran tutuyor ve [etkin] ile bildiriyor.
///
/// **Hareket azaltma.** Sistemde "hareketi azalt" açıksa animasyon hiç
/// çalışmıyor; bölüm doğrudan yerinde ve tam görünür başlıyor. Vestibüler
/// rahatsızlığı olan okur için bu bir tercih değil, gereklilik.
class DossierReveal extends StatefulWidget {
  const DossierReveal({super.key, required this.child, this.etkin = true});

  final Widget child;

  /// Bu bölüm daha önce belirdi mi. `false` ise animasyon atlanıyor.
  final bool etkin;

  @override
  State<DossierReveal> createState() => _DossierRevealState();
}

class _DossierRevealState extends State<DossierReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _denetim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 460),
  );

  late final Animation<double> _egri = CurvedAnimation(
    parent: _denetim,
    curve: Curves.easeOutCubic,
  );

  late final Animation<Offset> _kayma = Tween<Offset>(
    // Yüksekliğin %3'ü kadar aşağıdan geliyor. Piksel değil oran: büyük
    // yazı tipinde bölüm de büyüyor, hareket onunla orantılı kalıyor.
    begin: const Offset(0, 0.03),
    end: Offset.zero,
  ).animate(_egri);

  bool _basladi = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // `initState` değil: `MediaQuery` oradan okunamaz.
    if (_basladi) return;
    _basladi = true;
    if (!widget.etkin || MediaQuery.of(context).disableAnimations) {
      _denetim.value = 1;
    } else {
      _denetim.forward();
    }
  }

  @override
  void dispose() {
    _denetim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _egri,
      child: SlideTransition(position: _kayma, child: widget.child),
    );
  }
}
