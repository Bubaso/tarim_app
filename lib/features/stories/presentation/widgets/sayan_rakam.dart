import 'package:flutter/material.dart';

import '../../../../core/utils/sayi_yazimi.dart';

// ══════════════════════════════════════════════════════════════════════════
//  Sayarak gelen vurucu rakam — 6 Kasım 2026 denetimi, Ö2
// ──────────────────────────────────────────────────────────────────────────
//  Rakam eskiden `elasticOut` ile yaylanarak büyüyordu ama DEĞERİ baştan
//  yazılıydı: hareket vardı, bilgi yoktu. Göz bir rakamın değiştiğini
//  görünce ona bakar; sabit duran rakamı okur geçer.
//
//  Metni ayrıştırmak zorundayız çünkü vurucu değer serbest bir dize:
//  "%30", "9.250 ₺", "900 bin+ ha", "-%90", "64 bin ton", "%8 → %4".
//  Yalnızca İLK sayı öbeği sayılıyor, gerisi olduğu gibi duruyor — ikinci
//  bir sayıyı da saymak "%8 → %4" gibi bir değerde iki ayrı sayacın yarışı
//  anlamına gelirdi.
//
//  Sayı bulunamazsa metin olduğu gibi yazılıyor: hat bir gün "veri yok"
//  yazarsa ekran kaybedilmiyor.
// ══════════════════════════════════════════════════════════════════════════

/// Dizedeki ilk sayı öbeği — ayıraçlar dahil.
final RegExp _ilkSayi = RegExp(r'\d[\d.,]*');

@immutable
class RakamParcalari {
  /// Sayıdan önceki kısım: "%", "-%", "≈" …
  final String onek;

  /// Sayıdan sonraki kısım: " bin ton", " ₺", "+ ha" …
  final String sonek;

  /// Sayının kendisi; bulunamadıysa null.
  final num? deger;

  /// Kaynakta kaç ondalık basamak yazılmış.
  ///
  /// Hedefe varırken kaynaktaki yazımı korumak için: "36,9" sayılırken
  /// bir basamakla, "30" sıfır basamakla gitmeli.
  final int ondalik;

  const RakamParcalari({
    required this.onek,
    required this.sonek,
    required this.deger,
    required this.ondalik,
  });

  bool get sayilabilir => deger != null;
}

/// Vurucu değeri önek / sayı / sonek olarak ayırır.
RakamParcalari rakamiAyir(String ham) {
  final metin = ham.trim();
  final e = _ilkSayi.firstMatch(metin);
  if (e == null) {
    return RakamParcalari(onek: metin, sonek: '', deger: null, ondalik: 0);
  }

  final yazili = e.group(0)!;
  // Türkçe yazımda binlik '.' ondalık ','. Son virgülden sonrası ondalık
  // sayılıyor; virgül yoksa sayı tamdır ve noktalar binlik ayıracıdır.
  final virgul = yazili.lastIndexOf(',');
  final int ondalik = virgul < 0 ? 0 : yazili.length - virgul - 1;
  final sade = yazili.replaceAll('.', '').replaceAll(',', '.');
  final deger = num.tryParse(sade);

  if (deger == null) {
    return RakamParcalari(onek: metin, sonek: '', deger: null, ondalik: 0);
  }
  return RakamParcalari(
    onek: metin.substring(0, e.start),
    sonek: metin.substring(e.end),
    deger: deger,
    // Üç basamaktan fazlası sayaçta okunmuyor; kaynakta varsa da kırpılıyor.
    ondalik: ondalik.clamp(0, 3),
  );
}

/// Sayarak gelen rakam.
///
/// [ilerleme] slaytın kendi sayacı; rakam onun İLK [pay] kadarlık kısmında
/// hedefe varıyor. Slaytın tamamına yayılsaydı okur rakamı ancak slayt
/// biterken görürdü.
class SayanRakam extends StatelessWidget {
  const SayanRakam({
    super.key,
    required this.ham,
    required this.ilerleme,
    required this.isEn,
    required this.style,
    this.pay = 0.40,
  });

  final String ham;
  final Animation<double> ilerleme;
  final bool isEn;
  final TextStyle style;
  final double pay;

  @override
  Widget build(BuildContext context) {
    final p = rakamiAyir(ham);
    if (!p.sayilabilir) {
      return Text(ham, style: style, maxLines: 1);
    }

    return AnimatedBuilder(
      animation: ilerleme,
      builder: (context, _) {
        final t = (ilerleme.value / pay).clamp(0.0, 1.0);
        // easeOutCubic: sayı hızlı başlayıp hedefe yavaşlayarak oturuyor.
        // Doğrusal sayım mekanik, yaylanan sayım okunamaz oluyor.
        final o = Curves.easeOutCubic.transform(t);
        final guncel = p.deger! * o;

        final govde = p.ondalik == 0
            ? sayiYaz(guncel.round(), isEn)
            : _ondalikli(guncel, p.ondalik, isEn);

        return Text('${p.onek}$govde${p.sonek}', style: style, maxLines: 1);
      },
    );
  }

  /// Ondalıklı ara değer. `sayiYaz` tek basamakla sınırlı olduğu için
  /// kaynaktaki basamak sayısı korunarak elle kuruluyor; binlik ayıracı
  /// yine `sayiYaz`dan geliyor.
  String _ondalikli(num v, int basamak, bool isEn) {
    final carpan = [1, 10, 100, 1000][basamak];
    final tam = v.truncate();
    final kesir = ((v - tam) * carpan).round().clamp(0, carpan - 1);
    final ayirac = isEn ? '.' : ',';
    return '${sayiYaz(tam, isEn)}$ayirac'
        '${kesir.toString().padLeft(basamak, '0')}';
  }
}
