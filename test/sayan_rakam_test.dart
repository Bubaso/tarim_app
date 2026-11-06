import 'package:flutter_test/flutter_test.dart';
import 'package:tarim_app/features/stories/presentation/widgets/sayan_rakam.dart';

// ══════════════════════════════════════════════════════════════════════════
//  Vurucu değerin ayrıştırılması — Ö2.
//
//  Değer serbest bir dize ve hattan geliyor: "%30", "9.250 ₺", "900 bin+ ha",
//  "-%90", "%8 → %4", "veri yok". Sayaç yalnızca ilk sayı öbeğini sayıyor;
//  gerisi olduğu gibi duruyor. Ayrıştırma yanlış olursa ekranda "0" ya da
//  bozuk bir dize kalır, o yüzden sınırlar tek tek sınanıyor.
// ══════════════════════════════════════════════════════════════════════════

void main() {
  group('sayma ölçütü', () {
    // Kullanıcı 6 Kasım 2026'da bildirdi: "her rakam böyle olunca çok
    // sıkıcı bir hal alıyor". On kart üst üste aynı hareketi yapınca
    // hareket bilgi taşımayı bırakıyor. Ölçüt dört basamak: sayma,
    // basamakların gerçekten döndüğü yerde anlamlı.

    test('üç basamak ve altı SAYILMIYOR', () {
      for (final v in ['%30', '%8', '462 ton', '64 bin ton', '10 milyar TL']) {
        expect(rakamiAyir(v).sayilmaliMi, isFalse, reason: v);
      }
    });

    test('dört basamak ve üstü SAYILIYOR', () {
      for (final v in ['9.250 ₺', '48.000₺', '3.083.200 ha', '1.234,5 ton']) {
        expect(rakamiAyir(v).sayilmaliMi, isTrue, reason: v);
      }
    });

    test('ondalıkta TAM kısma bakılıyor', () {
      // "183,8 milyar" üç basamak — sayılmaz; birim büyüklüğü taşıyor,
      // rakamın kendisi değil.
      expect(rakamiAyir('183,8 milyar m³').sayilmaliMi, isFalse);
      expect(rakamiAyir('1.000,5').sayilmaliMi, isTrue);
    });

    test('sayı olmayan değer sayılmıyor', () {
      expect(rakamiAyir('veri yok').sayilmaliMi, isFalse);
      expect(rakamiAyir('').sayilmaliMi, isFalse);
    });
  });

  group('ayrıştırma', () {
    test('yüzde: önek korunuyor', () {
      final p = rakamiAyir('%30');
      expect(p.onek, '%');
      expect(p.deger, 30);
      expect(p.sonek, '');
      expect(p.ondalik, 0);
    });

    test('binlik ayıraçlı para', () {
      final p = rakamiAyir('9.250 ₺');
      expect(p.deger, 9250);
      expect(p.sonek, ' ₺');
      expect(p.ondalik, 0);
    });

    test('ondalıklı değerde basamak sayısı korunuyor', () {
      final p = rakamiAyir('%36,9');
      expect(p.deger, closeTo(36.9, 0.001));
      expect(p.ondalik, 1);
    });

    test('negatif önek', () {
      final p = rakamiAyir('-%90');
      expect(p.onek, '-%');
      expect(p.deger, 90);
    });

    test('sayıdan sonra sözcük', () {
      final p = rakamiAyir('900 bin+ ha');
      expect(p.deger, 900);
      expect(p.sonek, ' bin+ ha');
    });

    test('İKİ sayı varsa yalnız ilki sayılıyor', () {
      // "%8 → %4" gibi bir değerde iki sayacın yarışması okunmazdı.
      final p = rakamiAyir('%8 → %4');
      expect(p.onek, '%');
      expect(p.deger, 8);
      expect(p.sonek, ' → %4');
    });

    test('sayısız metin OLDUĞU GİBİ geçiyor', () {
      final p = rakamiAyir('veri yok');
      expect(p.sayilabilir, isFalse);
      expect(p.onek, 'veri yok');
    });

    test('boş dize çökmüyor', () {
      final p = rakamiAyir('');
      expect(p.sayilabilir, isFalse);
    });

    test('üç basamaktan fazla ondalık kırpılıyor', () {
      // Sayaçta okunmuyor; kaynakta varsa da gösterilmiyor.
      expect(rakamiAyir('1,23456').ondalik, 3);
    });

    test('binlik ve ondalık birlikte', () {
      final p = rakamiAyir('1.234,5 ton');
      expect(p.deger, closeTo(1234.5, 0.001));
      expect(p.ondalik, 1);
      expect(p.sonek, ' ton');
    });
  });
}
