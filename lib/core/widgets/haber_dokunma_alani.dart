import 'package:flutter/material.dart';

// ══════════════════════════════════════════════════════════════════════════
//  Habere götüren dokunma alanı — klavye ve ekran okuyucu dahil
// ──────────────────────────────────────────────────────────────────────────
//  Altı bölümün kartları `GestureDetector` kullanıyordu. GestureDetector
//  yalnızca DOKUNMA tanıyor: odak alamıyor, Sekme tuşuyla gezilemiyor,
//  Enter/Boşluk ile açılamıyor ve ekran okuyucuya "bu bir düğme" demiyor.
//  Yani kartlara yalnızca fare ve parmakla ulaşılabiliyordu.
//
//  Doğru desen `hero_fold`da zaten kuruluydu (MouseRegion + MergeSemantics)
//  ama o da yarımdı: MergeSemantics düğümleri birleştiriyor, odak
//  vermiyor. Bu sarmalayıcı eksiği tamamlıyor ve tek yerde tutuyor.
//
//  GÖRÜNÜMÜ DEĞİŞTİRMİYOR. Dalga (splash) ve basılı vurgu bilerek saydam:
//  kartların kendi gölgesi, ölçeklenmesi ve kenarlığı var, üstüne mürekkep
//  efekti eklemek tasarımı değiştirirdi. Görünür tek yeni şey ODAK
//  halkası — o da yalnızca klavyeyle gezilirken çıkıyor ve zaten çıkması
//  gereken şey.
//
//  `Material(type: transparency)`: InkWell bir Material ister. Saydam tip
//  zemin boyamıyor, yani kartın kendi rengi olduğu gibi kalıyor.
// ══════════════════════════════════════════════════════════════════════════

class HaberDokunmaAlani extends StatelessWidget {
  const HaberDokunmaAlani({
    super.key,
    required this.etiket,
    required this.onTap,
    required this.child,
    this.borderRadius,
  });

  /// Ekran okuyucunun okuyacağı metin — haberin başlığı.
  ///
  /// Kartın içindeki metinler [MergeSemantics] ile tek düğüme indiriliyor;
  /// etiket verilmeseydi okuyucu başlık + kaynak + tarih + "düğme" diye
  /// dört ayrı şey okurdu.
  final String etiket;

  final VoidCallback onTap;
  final Widget child;

  /// Kartın köşe yarıçapı. Verilmezse odak halkası dikdörtgen çiziliyor;
  /// yuvarlak köşeli kartta bu, köşelerden taşan bir çerçeve demek.
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: etiket,
      child: MergeSemantics(
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: onTap,
              borderRadius: borderRadius,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
