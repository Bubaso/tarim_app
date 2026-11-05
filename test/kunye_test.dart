import 'package:flutter_test/flutter_test.dart';
import 'package:tarim_app/features/legal/data/legal_documents.dart';

// ══════════════════════════════════════════════════════════════════════════
//  Künye ve aydınlatma metinleri — 5 Kasım 2026 kararının bekçisi.
//
//  Künye hukuken bir BEYAN. Teyit edilmemiş bir kişi adını sorumlu sıfatıyla
//  yayımlamak, o kişiyi hiç üstlenmediği bir sorumluluğun altına sokar.
//  Karar: ad yazılmıyor, görevin yürütüldüğü belirtiliyor, kesin bilgi kayıt
//  süreci bitince yayımlanacak deniyor.
//
//  Bu sınama o kararın yanlışlıkla geri alınmasını engelliyor — eski adlar
//  depoda beş ayrı kopyada ve dokuz derlenmiş pakette duruyor, bir
//  "düzeltme" sırasında geri gelmesi kolay.
// ══════════════════════════════════════════════════════════════════════════

/// Bütün belgelerdeki bütün metin — etiket, içerik ve değer.
String get _tumMetin {
  final p = StringBuffer();
  for (final doc in legalDocs.values) {
    p.writeln(doc.titleTr);
    p.writeln(doc.titleEn);
    for (final b in doc.blocks) {
      p.writeln(b.tr);
      p.writeln(b.en);
      if (b.value != null) p.writeln(b.value);
    }
  }
  return p.toString();
}

void main() {
  group('kişi adı yok', () {
    // Eskiden künyede duran adlar. Liste açık: yenisi eklenecekse önce
    // teyit edilmeli ve bu sınama bilerek güncellenmeli.
    const eskiAdlar = ['Ali Gökçek', 'Ali Yılmaz', 'Burhan Gökçek'];

    for (final ad in eskiAdlar) {
      test('"$ad" hiçbir yasal metinde geçmiyor', () {
        expect(_tumMetin.contains(ad), isFalse,
            reason: 'Künyede kişi adı yayımlanmıyor — dosya başındaki '
                'gerekçeye bakın.');
      });
    }

    test('künyede "Genel Yayın Yönetmeni" bir DEĞER taşımıyor', () {
      // Etiket/değer satırı olarak dönerse yanına bir ad yazılmış demektir.
      final kunye = legalDocs['kunye']!;
      final adli = kunye.blocks.where((b) =>
          b.kind == LegalBlockKind.keyValue &&
          (b.tr.contains('Yönetmen') || b.tr.contains('Müdür')));
      expect(adli, isEmpty);
    });
  });

  group('uydurma kurum bilgisi yok', () {
    // 5 Kasım 2026: ticari unvan ve adres de gerçek değildi, kaldırıldı.
    // Künye hukuken bir beyan; var olmayan bir tüzel kişiyi imtiyaz
    // sahibi, var olmayan bir adresi tebligat adresi diye ilan etmek
    // bilgiyi hiç yazmamaktan ağır bir iştir.
    const uydurma = [
      'Dijital Yayıncılık',
      'Digital Publishing',
      'Bilişim Vadisi',
      'Teknopark',
      'Gebze',
      'A.Ş.',
    ];

    for (final s in uydurma) {
      test('"$s" hiçbir yasal metinde geçmiyor', () {
        expect(_tumMetin.contains(s), isFalse);
      });
    }

    test('künyede İmtiyaz Sahibi ve Adres satırı YOK', () {
      final k = legalDocs['kunye']!;
      final satirlar = k.blocks
          .where((b) => b.kind == LegalBlockKind.keyValue)
          .map((b) => b.tr);
      expect(satirlar, isNot(contains('İmtiyaz Sahibi')));
      expect(satirlar, isNot(contains('Adres')));
    });

    test('yetkili mahkeme tek bir ile bağlanmıyor', () {
      // Eski metindeki "Kocaeli Mahkemeleri" künyedeki uydurma adresten
      // türemişti; gerçek merkez olmadan dayanaksız.
      final metin =
          legalDocs['kullanim-kosullari']!.blocks.map((b) => b.tr).join(' ');
      expect(metin.contains('Kocaeli'), isFalse);
      expect(metin, contains('genel yetki kuralları'));
    });

    test('eksiklik SESSİZ değil — neden yazılmadığı söyleniyor', () {
      final kunye = legalDocs['kunye']!.blocks.map((b) => b.tr).join(' ');
      expect(kunye, contains('tüzel kişiliğine'));
      expect(kunye, contains('tebligat adresine'));
      expect(kunye, contains('bilahare'));

      final gizlilik = legalDocs['gizlilik']!.blocks.map((b) => b.tr).join(' ');
      expect(gizlilik, contains('ticari unvanı'));
    });
  });

  group('yasal yükümlülükler duruyor', () {
    test('künye Basın Kanunu dayanağını söylüyor', () {
      expect(legalDocs['kunye']!.blocks.first.tr, contains('5187'));
    });

    test('künye görevlerin bilahare yayımlanacağını söylüyor', () {
      // Eksikliği SESSİZCE bırakmak olmaz: okur neden yazmadığımızı
      // bilmeli.
      final k = legalDocs['kunye']!;
      final metin = k.blocks.map((b) => b.tr).join(' ');
      expect(metin, contains('bilahare'));
      expect(metin, contains('yayımlanacaktır'));
    });

    test('künyede yayın adı, yayın adresi ve iletişim var', () {
      // Tüzel kişilik yazılmasa da okur KİME ve NEREYE yazacağını
      // bilmeli; künyenin tamamen boşalmasına izin verilmiyor.
      final k = legalDocs['kunye']!;
      final etiketler = k.blocks.map((b) => b.tr).join(' ');
      expect(etiketler, contains('Yayın Adı'));
      expect(etiketler, contains('Yayın Adresi'));
      expect(k.blocks.any((b) => b.kind == LegalBlockKind.mailto), isTrue);
    });

    test('düzeltme ve yanıt hakkı anlatılıyor', () {
      final metin = legalDocs['kunye']!.blocks.map((b) => b.tr).join(' ');
      expect(metin, contains('md. 14'));
    });

    test('gizlilik metni KVKK md. 10 ve md. 11 dayanaklı', () {
      final metin = legalDocs['gizlilik']!.blocks.map((b) => b.tr).join(' ');
      expect(metin, contains('md. 10'));
      expect(metin, contains('md. 11'));
      expect(metin, contains('md. 9'));
    });

    test('her belgenin güncelleme tarihi var ve gelecekte değil', () {
      for (final doc in legalDocs.values) {
        expect(doc.updatedAt.isAfter(DateTime(2026, 1, 1)), isTrue,
            reason: doc.slug);
        expect(doc.updatedAt.isBefore(DateTime(2027, 6, 1)), isTrue,
            reason: doc.slug);
      }
    });

    test('beş belgenin hepsi yerinde', () {
      expect(legalDocs.keys.toSet(), {
        'kunye',
        'iletisim',
        'kullanim-kosullari',
        'gizlilik',
        'cerezler',
      });
    });
  });

  group('teknik ayrıntı sayılmıyor', () {
    // Aydınlatma metni mimari belgesi değil; kullanılan yığının adres adres
    // yayımlanması gereksiz bir saldırı yüzeyi. Sağlayıcılar kategori
    // olarak anılıyor, güncel liste başvuruyla veriliyor.
    const urunAdlari = [
      'Firebase',
      'Supabase',
      'Google Fonts',
      'localStorage',
      'service worker',
      'Antigravity',
    ];

    for (final ad in urunAdlari) {
      test('"$ad" yasal metinlerde geçmiyor', () {
        expect(_tumMetin.contains(ad), isFalse);
      });
    }

    test('aktarım yine de anlatılıyor — gizlemek değil sadeleştirmek', () {
      final metin = legalDocs['gizlilik']!.blocks.map((b) => b.tr).join(' ');
      expect(metin, contains('Barındırma hizmeti sağlayıcısı'));
      expect(metin, contains('güncel listesini'));
    });
  });

  group('iki dil de dolu', () {
    test('hiçbir blokta boş çeviri yok', () {
      for (final doc in legalDocs.values) {
        for (final b in doc.blocks) {
          expect(b.tr.trim(), isNotEmpty, reason: '${doc.slug} / tr');
          expect(b.en.trim(), isNotEmpty, reason: '${doc.slug} / en');
        }
      }
    });

    test('madde listelerinde tr ve en satır sayısı eşit', () {
      for (final doc in legalDocs.values) {
        for (final b in doc.blocks) {
          if (b.kind != LegalBlockKind.bullets) continue;
          expect(b.lines(false).length, b.lines(true).length,
              reason: '${doc.slug}: "${b.tr.split('\n').first}"');
        }
      }
    });
  });
}
