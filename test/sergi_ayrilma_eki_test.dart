import 'package:flutter_test/flutter_test.dart';
import 'package:tarim_app/features/sergi/presentation/screens/sergi_izleyici.dart';

/// AYRILMA HÂLİ EKİ — künyede özensizlik olmaz.
///
/// Sabit bir `'dan` eki sergide "Bangladeş'dan", "Çin'dan", "Tokat'dan"
/// üretiyordu. Buradaki adların hepsi serginin KENDİ verisinden: 11 ülke
/// ve illerden örnekler. Kural bozulursa bu sınama düşer.
void main() {
  group('ayrılma eki', () {
    test('serginin bütün ülkeleri doğru ek alıyor', () {
      const beklenen = {
        'Bangladeş': 'ten',
        'Endonezya': 'dan',
        'Hindistan': 'dan',
        'Hollanda': 'dan',
        'Myanmar': 'dan',
        'Nepal': 'den',
        'Rusya': 'dan',
        'Türkiye': 'den',
        'Vietnam': 'dan',
        'Çin': 'den',
        'İran': 'dan',
        'İtalya': 'dan',
      };
      beklenen.forEach((ad, ek) {
        expect(ayrilmaEki(ad), ek, reason: '$ad\'$ek beklendi');
      });
    });

    test('sert ünsüzle biten iller t alıyor', () {
      expect(ayrilmaEki('Tokat'), 'tan');
      expect(ayrilmaEki('Şırnak'), 'tan');
      expect(ayrilmaEki('Gaziantep'), 'ten');
      expect(ayrilmaEki('Sinop'), 'tan');
    });

    test('ince ünlüyle biten iller e alıyor', () {
      expect(ayrilmaEki('Balıkesir'), 'den');
      expect(ayrilmaEki('İzmir'), 'den');
      expect(ayrilmaEki('Artvin'), 'den');
      expect(ayrilmaEki('Edirne'), 'den');
    });

    test('kalın ünlüyle biten iller a alıyor', () {
      expect(ayrilmaEki('Trabzon'), 'dan');
      expect(ayrilmaEki('Adana'), 'dan');
      expect(ayrilmaEki('Konya'), 'dan');
      expect(ayrilmaEki('Isparta'), 'dan');
    });

    test('büyük I ve İ ayırt ediliyor — Türkçe tuzağı', () {
      // "Iğdır" kalın (I), "İzmir" ince (İ). Küçültme yapan bir çözüm
      // ikisini karıştırırdı.
      expect(ayrilmaEki('Iğdır'), 'dan');
      expect(ayrilmaEki('İzmir'), 'den');
    });
  });
}
