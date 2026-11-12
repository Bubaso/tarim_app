import 'package:flutter_test/flutter_test.dart';
import 'package:tarim_app/features/sergi/data/models/sergi_eseri.dart';

/// Sergi modelinin sınandığı tek şey var: KÜNYE SESSİZCE BOŞALMASIN.
///
/// Bir fotoğrafı künyesiz göstermek, onu çeken kişinin adını silmek demek.
/// Veritabanı kısıtı boş ad ve boş eser adını reddediyor; burada da istemci
/// tarafının o alanları bir yerde düşürmediği sınanıyor.
void main() {
  siralamaVeBaglam();

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

/// SIRALAMA VE BAĞLAM.
///
/// Sıralamanın sınanma sebebi tek bir hata: ızgaradaki sıra ile
/// izleyicideki sıra ayrışırsa, okur "sonraki kare" dediğinde ekranda
/// komşusu olmayan bir kare çıkar. Rastgele düzen aynı tohumla AYNI
/// listeyi vermek zorunda.
void siralamaVeBaglam() {
  SergiVerisi kur(List<SergiEseri> l) => SergiVerisi(
        yarisma: const SergiYarismasi(
          kod: 'utoify-16',
          sira: 16,
          yil: 2026,
          adTr: 'ad',
          adEn: 'name',
          duzenleyenTr: 'd',
          duzenleyenEn: 'd',
          kaynakAdres: 'https://ornek',
        ),
        eserler: l,
      );

  SergiEseri e({
    required String kod,
    String fotografci = 'A',
    String? il,
    String ulke = 'Türkiye',
    String tur = 'sergileme',
    int sira = 1,
  }) =>
      SergiEseri(
        kod: kod,
        yarismaKod: 'utoify-16',
        tur: tur,
        kategori: 'k',
        sira: sira,
        odulTr: '',
        odulEn: '',
        fotografci: fotografci,
        eser: 'eser $kod',
        ulkeTr: ulke,
        ulkeEn: ulke,
        adres: 'https://ornek/$kod.jpg',
        il: il,
      );

  group('sıralama', () {
    final v = kur([
      e(kod: 'odul-01', tur: 'odul', fotografci: 'Z', ulke: 'Çin', sira: 1),
      e(kod: 'sergi-001', fotografci: 'A', il: 'Trabzon', sira: 2),
      e(kod: 'sergi-002', fotografci: 'A', il: 'Artvin', sira: 3),
      e(kod: 'sergi-003', fotografci: 'B', ulke: 'İran', sira: 4),
    ]);

    test('ödül düzeni listeyi olduğu gibi bırakıyor', () {
      final l = v.sirali(SergiSirasi.odulOnce, false);
      expect(l.map((x) => x.kod).toList(),
          ['odul-01', 'sergi-001', 'sergi-002', 'sergi-003']);
    });

    test('yere göre düzen aynı ülkeyi yan yana getiriyor', () {
      final l = v.sirali(SergiSirasi.yereGore, false);
      final ulkeler = l.map((x) => x.ulkeTr).toList();
      // Aynı ülke listede bölünmüş olmamalı: her ülke tek bir blok.
      final blok = <String>[];
      for (final u in ulkeler) {
        if (blok.isEmpty || blok.last != u) blok.add(u);
      }
      expect(blok.length, blok.toSet().length,
          reason: 'bir ülke listede ikiye bölünmüş');
    });

    test('rastgele düzen aynı tohumla aynı sırayı veriyor', () {
      final a = v.sirali(SergiSirasi.rastgele, false, tohum: 4242);
      final b = v.sirali(SergiSirasi.rastgele, false, tohum: 4242);
      expect(a.map((x) => x.kod).toList(), b.map((x) => x.kod).toList());
    });

    test('rastgele düzen hiçbir kareyi düşürmüyor ya da ikizlemiyor', () {
      final a = v.sirali(SergiSirasi.rastgele, false, tohum: 7);
      expect(a.length, 4);
      expect(a.map((x) => x.kod).toSet().length, 4);
    });
  });

  group('bağlam', () {
    final v = kur([
      e(kod: 'a1', fotografci: 'Ufuk TURPCAN', il: 'Trabzon'),
      e(kod: 'a2', fotografci: 'Ufuk TURPCAN', il: 'Trabzon'),
      e(kod: 'b1', fotografci: 'Meral KAYA', il: 'Trabzon'),
      e(kod: 'c1', fotografci: 'Lihe ZHOU', ulke: 'Çin'),
    ]);

    test('aynı fotoğrafçının kareleri karenin kendisini içermiyor', () {
      final l = v.ayniFotografcidan(v.eserler.first);
      expect(l.map((x) => x.kod).toList(), ['a2']);
    });

    test('aynı yer ili esas alıyor, kendisini saymıyor', () {
      final l = v.ayniYerden(v.eserler.first, false);
      expect(l.map((x) => x.kod).toSet(), {'a2', 'b1'});
    });

    test('ili olmayan kare ülkesiyle eşleşiyor', () {
      final l = v.ayniYerden(v.eserler.last, false);
      expect(l, isEmpty);
    });
  });
}
