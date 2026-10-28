import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

// ══════════════════════════════════════════════════════════════════════════════
//  Fotoğrafı olmayan yazarın avatarı — buğday başağı
// ──────────────────────────────────────────────────────────────────────────────
//  CLAUDE.md §32: bu üçüncü deneme ve yürürlükte olan. Baş harfler ("HE")
//  BIRAKILDI — kimlik işareti gibi değil, eksik bir veri gibi duruyordu.
//  İnsan silueti de bırakıldı: "fotoğraf yok"un kibar biçiminden öteye
//  geçmiyordu.
//
//  Başak bir eksiği işaret etmiyor, portalın kendi işaretini taşıyor. Ayırt
//  etme işini adın kendisi yapıyor; avatarın işi yer tutup vitrini boş
//  bırakmamak. BÜTÜN YAZARLARDA AYNI GÖRÜNMESİ BİLİNÇLİ.
// ══════════════════════════════════════════════════════════════════════════════

class BasakAvatar extends StatelessWidget {
  const BasakAvatar({
    super.key,
    required this.size,
    required this.isDark,
  });

  final double size;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    // Koyu temada koyu yeşil okunmuyor; buğday rengine dönüyor
    // (AppColors.accentFor ile aynı kural).
    final cizgi = AppColors.accentFor(isDark: isDark);
    final zemin =
        isDark ? const Color(0xFF2A2E26) : const Color(0xFFEBE6D9);

    return ClipOval(
      child: Container(
        width: size,
        height: size,
        color: zemin,
        child: CustomPaint(
          painter: _BasakBoyaci(renk: cizgi),
          size: Size(size, size),
        ),
      ),
    );
  }
}

class _BasakBoyaci extends CustomPainter {
  const _BasakBoyaci({required this.renk});

  final Color renk;

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Ölçüler yarıçapa oranlı — ama çizgi kalınlığında ALT SINIR var.
    // Oranla küçülen çizgi panelin 44 pikselinde 1 pikselin altına düşüp
    // soluyordu; çizim 44'ten 100 piksele kadar aynı görünüyor (§32).
    final double kalinlik = (w * 0.055).clamp(1.3, 5.0);

    final govde = Paint()
      ..color = renk
      ..strokeWidth = kalinlik
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final dolu = Paint()
      ..color = renk
      ..style = PaintingStyle.fill;

    // Sap: alttan yukarı. Başak çizimin üst üçte ikisinde duruyor.
    final double x = w / 2;
    final double sapAlt = h * 0.84;
    final double sapUst = h * 0.30;
    canvas.drawLine(Offset(x, sapAlt), Offset(x, h * 0.42), govde);

    // Taneler: sapın iki yanında, yukarı doğru eğik. Dört çift.
    const int ciftSayisi = 4;
    final double aralik = (sapAlt - sapUst) * 0.17;
    final double taneBoyu = w * 0.20;

    for (int i = 0; i < ciftSayisi; i++) {
      final double y = h * 0.66 - i * aralik;
      // Yukarı çıktıkça taneler biraz küçülüyor — başağın doğal sivrilmesi.
      final double olcek = 1.0 - i * 0.11;
      _tane(canvas, dolu, Offset(x, y), taneBoyu * olcek, solda: true);
      _tane(canvas, dolu, Offset(x, y), taneBoyu * olcek, solda: false);
    }

    // Uçtaki DOLU tane şart: çizgilerin bittiği yeri kapatan bir şey olmadan
    // çizim başaktan çok bir oka benziyor (§32).
    final Rect uc = Rect.fromCenter(
      center: Offset(x, sapUst + taneBoyu * 0.34),
      width: taneBoyu * 0.62,
      height: taneBoyu * 1.05,
    );
    canvas.drawOval(uc, dolu);
  }

  /// Tek bir tane: saptan çıkıp yukarı eğilen damla.
  void _tane(Canvas canvas, Paint boya, Offset kok, double boy,
      {required bool solda}) {
    final double yon = solda ? -1.0 : 1.0;
    final Path p = Path()
      ..moveTo(kok.dx, kok.dy)
      // Dış kenar: saptan çıkıp yukarı-dışa savruluyor.
      ..quadraticBezierTo(
        kok.dx + yon * boy * 0.95,
        kok.dy - boy * 0.20,
        kok.dx + yon * boy * 0.80,
        kok.dy - boy * 0.78,
      )
      // İç kenar: uçtan sapa geri iniyor, damla kapanıyor.
      ..quadraticBezierTo(
        kok.dx + yon * boy * 0.28,
        kok.dy - boy * 0.58,
        kok.dx,
        kok.dy,
      )
      ..close();
    canvas.drawPath(p, boya);
  }

  @override
  bool shouldRepaint(_BasakBoyaci eski) => eski.renk != renk;
}
