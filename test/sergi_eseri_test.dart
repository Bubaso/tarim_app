import 'package:flutter_test/flutter_test.dart';
import 'package:tarim_app/features/sergi/data/models/sergi_eseri.dart';

/// Sergi modelinin sınandığı tek şey var: KÜNYE SESSİZCE BOŞALMASIN.
///
/// Bir fotoğrafı künyesiz göstermek, onu çeken kişinin adını silmek demek.
/// Veritabanı kısıtı boş ad ve boş eser adını reddediyor; burada da istemci
/// tarafının o alanları bir yerde düşürmediği sınanıyor.
void main() {
  Map<String, dynamic> ham({
    String kod = 'sergi-001',
    String fotografci = 'Abdulmecit ÇEVRİM',
    String eser = 'Bulgur',
    String? il = 'Şırnak',
    String ulkeTr = 'Türkiye',
    String ulkeEn = 'Türkiye',
    String tur = 'sergileme',
  }) =>
      {
        'kod': kod,
        'yarisma_kod': 'utoify-16',
        'tur': tur,
        'kategori': 'sergileme',
        'sira': 1,
        'odul_tr': 'Sergilemeye değer bulundu',
        'odul_en': 'Selected for exhibition',
        'fotografci': fotografci,
        'eser': eser,
        'il': il,
        'ulke_tr': ulkeTr,
        'ulke_en': ulkeEn,
        'adres': 'https://tarimportali.net/sergi/utoify-16/$kod.jpg',
        'en': 549,
        'boy': 364,
        'en_boy': 1.5082,
      };

  group('künye', () {
    test('iki dilde de fotoğrafçı adını ve eser adını taşıyor', () {
      final e = SergiEseri.fromJson(ham());
      for (final isEn in [false, true]) {
        final k = e.kunye(isEn);
        expect(k, contains('Abdulmecit ÇEVRİM'));
        expect(k, contains('Bulgur'));
        expect(k.trim(), isNotEmpty);
      }
    });

    test('il yoksa yer yalnız ülkedir, başında virgül kalmaz', () {
      final e = SergiEseri.fromJson(
          ham(il: null, ulkeTr: 'Endonezya', ulkeEn: 'Indonesia'));
      expect(e.yer(false), 'Endonezya');
      expect(e.yer(true), 'Indonesia');
      expect(e.yer(false).startsWith(','), isFalse);
    });

    test('boş dizgi gelen il de yok sayılıyor', () {
      // Veritabanı `il`i null yerine '' döndürebiliyor; ikisi aynı şey.
      final e = SergiEseri.fromJson(ham(il: '  '));
      expect(e.il, isNull);
      expect(e.yer(false), 'Türkiye');
    });

    test('eser adı ÇEVRİLMİYOR — iki dilde de aynı', () {
      final e = SergiEseri.fromJson(ham(eser: 'The Last Racks'));
      expect(e.eser, 'The Last Racks');
      expect(e.kunye(false), contains('The Last Racks'));
      expect(e.kunye(true), contains('The Last Racks'));
    });
  });

  group('sayım', () {
    final veri = SergiVerisi(
      yarisma: SergiYarismasi.fromJson(const {
        'kod': 'utoify-16',
        'sira': 16,
        'yil': 2026,
        'ad_tr': '16. UTOİFY',
        'ad_en': '16th UTOIFY',
        'duzenleyen_tr': 'Bakanlık',
        'duzenleyen_en': 'Ministry',
        'kaynak_adres': 'https://www.tarimormaninsan.com/',
      }),
      eserler: [
        SergiEseri.fromJson(ham(kod: 'a', il: 'Trabzon')),
        SergiEseri.fromJson(ham(kod: 'b', il: 'Trabzon')),
        SergiEseri.fromJson(ham(kod: 'c', il: 'Van')),
        SergiEseri.fromJson(ham(
            kod: 'd', il: null, ulkeTr: 'Çin', ulkeEn: 'China', tur: 'odul')),
      ],
    );

    test('iller çoktan aza sıralanıyor', () {
      expect(veri.illeGore.first.key, 'Trabzon');
      expect(veri.illeGore.first.value, 2);
      expect(veri.illeGore.length, 2); // Çin il değil
    });

    test('ülke sayımı Türkiye dahil, il sayımından ayrı', () {
      final u = Map.fromEntries(veri.ulkeyeGore(false));
      expect(u['Türkiye'], 3);
      expect(u['Çin'], 1);
    });

    test('ödül ve sergileme ayrı toplanıyor', () {
      expect(veri.odullu.length, 1);
      expect(veri.sergilenen.length, 3);
    });
  });
}
