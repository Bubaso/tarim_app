import 'package:flutter_test/flutter_test.dart';
import 'package:tarim_app/features/dashboard/domain/yayin_denetimi.dart';
import 'package:tarim_app/features/home/data/models/news_article.dart';

// ══════════════════════════════════════════════════════════════════════════
//  Onay ekranının kural motoru
// ──────────────────────────────────────────────────────────────────────────
//  Her kural tek tek sınanıyor. Sebebi: bu uyarılar yöneticinin yayın
//  kararını etkiliyor. Yanlış çıkan bir uyarı iki yönde de zarar veriyor —
//  olmayan bir sorun için haberi geciktirir ya da gerçek sorunu gizler.
//
//  "Temiz haber hiç uyarı üretmez" sınavı özellikle önemli: kurallardan biri
//  fazla hevesli olursa her haberde uyarı çıkar, yönetici hepsini görmezden
//  gelmeye alışır ve uyarı sistemi işlevini yitirir.
// ══════════════════════════════════════════════════════════════════════════

NewsArticle _haber({
  String baslik = 'TÜRKŞEKER pancar üreticisine ödenen bedeli açıkladı',
  String? ozet = 'Pancar üreticilerine aktarılan toplam nakit ödemenin '
      '80 milyar lirayı aştığı bildirildi.',
  String? govde,
  String? kapak = 'https://x/k_1200x630.jpg',
  String? kare = 'https://x/k_320x320.jpg',
  String? hikaye = 'https://x/k_1080x2340.jpg',
  String? enBaslik = 'TURKSEKER announced the amount paid to beet growers',
  String? enGovde,
  String? kaynakAdres = 'https://turkseker.gov.tr/haber/1',
}) {
  const uzun = 'Şahin, sözleşmeli pancar üretiminden elde edilen '
      'öngörülebilir gelirin çiftçinin münavebe kapsamında yetiştirdiği '
      'ürünler için de üretim planı yapmasına katkı sağladığını anlattı. ';
  return NewsArticle(
    id: 'a1',
    title: baslik,
    summary: ozet,
    content: govde ?? '<p>$uzun$uzun</p>',
    contentEn: enGovde ?? '<p>${uzun * 2}</p>',
    titleEn: enBaslik,
    imageUrl: kapak,
    thumbImageUrl: kare,
    storyImageUrl: hikaye,
    sourceUrl: kaynakAdres,
    createdAt: DateTime(2026, 11, 15),
  );
}

Set<String> _anahtarlar(List<DenetimBulgusu> b) =>
    b.map((x) => x.anahtar).toSet();

void main() {
  group('temiz haber', () {
    test('hiçbir uyarı üretmiyor', () {
      expect(haberiDenetle(_haber()), isEmpty);
    });

    test('mükerrer listesi boşken mükerrer kuralı çalışmıyor', () {
      // "Bilmiyorum" ile "temiz" aynı şey değil: liste verilmediğinde
      // uyarı üretmek yanlış olurdu.
      final b = haberiDenetle(_haber(), yayindakiBasliklar: const []);
      expect(_anahtarlar(b), isNot(contains('mukerrer_baslik')));
    });
  });

  group('başlık', () {
    test('110 karakteri aşan başlık uyarı veriyor', () {
      final b = haberiDenetle(_haber(baslik: 'A' * 120));
      expect(_anahtarlar(b), contains('baslik_uzun'));
      expect(b.firstWhere((x) => x.anahtar == 'baslik_uzun').agir, isFalse);
    });

    test('çok kısa başlık uyarı veriyor', () {
      expect(_anahtarlar(haberiDenetle(_haber(baslik: 'Açıklama yapıldı'))),
          contains('baslik_kisa'));
    });

    test('sınırdaki başlık uyarı vermiyor', () {
      expect(_anahtarlar(haberiDenetle(_haber(baslik: 'A' * kBaslikEnCok))),
          isNot(contains('baslik_uzun')));
    });
  });

  group('özet', () {
    test('boş özet AĞIR', () {
      final b = haberiDenetle(_haber(ozet: ''));
      final bulgu = b.firstWhere((x) => x.anahtar == 'ozet_yok');
      expect(bulgu.agir, isTrue);
      expect(bulgu.alan, 'ozet');
    });

    test('uzun özet yalnız uyarı', () {
      final b = haberiDenetle(_haber(ozet: 'a' * 500));
      expect(b.firstWhere((x) => x.anahtar == 'ozet_uzun').agir, isFalse);
    });
  });

  group('gövde', () {
    test('kısa gövde AĞIR', () {
      final b = haberiDenetle(_haber(govde: '<p>Kısa.</p>'));
      expect(b.firstWhere((x) => x.anahtar == 'govde_kisa').agir, isTrue);
    });

    test('kapanmamış paragraf etiketi yakalanıyor', () {
      // Çevirmen ajanı 12 Kasım 2026'da tam olarak bunu üretti.
      final b = haberiDenetle(_haber(
          govde: '<p>${'Uzun bir gövde metni burada duruyor. ' * 12}'));
      expect(_anahtarlar(b), contains('govde_etiket'));
    });

    test('noktalamayla biten gövde yarım sayılmıyor', () {
      expect(_anahtarlar(haberiDenetle(_haber())),
          isNot(contains('govde_yarim')));
    });

    test('noktalamasız biten gövde yarım uyarısı veriyor', () {
      final b = haberiDenetle(_haber(
          govde: '<p>${'Uzun bir gövde metni burada duruyor. ' * 12}'
              've cümle burada kesiliyor</p>'));
      expect(_anahtarlar(b), contains('govde_yarim'));
    });
  });

  group('görsel', () {
    test('kapak yoksa AĞIR ve türev kuralları çalışmıyor', () {
      // Kapak yokken "kare türev yok" demek gürültü: asıl sorun kapak.
      final b = haberiDenetle(_haber(kapak: null, kare: null, hikaye: null));
      expect(b.firstWhere((x) => x.anahtar == 'kapak_yok').agir, isTrue);
      expect(_anahtarlar(b), isNot(contains('kare_yok')));
      expect(_anahtarlar(b), isNot(contains('hikaye_yok')));
    });

    test('kapak varken eksik türevler uyarı', () {
      final b = haberiDenetle(_haber(kare: null, hikaye: null));
      expect(_anahtarlar(b), containsAll(['kare_yok', 'hikaye_yok']));
      expect(b.where((x) => x.agir), isEmpty);
    });
  });

  group('İngilizce', () {
    test('boş İngilizce uyarı veriyor', () {
      expect(_anahtarlar(haberiDenetle(_haber(enBaslik: '', enGovde: ''))),
          contains('ingilizce_eksik'));
    });

    test('Türkçesiyle aynı başlık çevrilmemiş sayılıyor', () {
      const t = 'TÜRKŞEKER pancar üreticisine ödenen bedeli açıkladı';
      expect(_anahtarlar(haberiDenetle(_haber(baslik: t, enBaslik: t))),
          contains('ingilizce_cevrilmemis'));
    });

    test('İngilizce uyarısı hiçbir zaman AĞIR değil', () {
      // Kullanıcı kararı: İngilizce yalnız uyarı. Eksik çeviri yayını
      // durdurmuyor — okur Türkçesini görüyor, bu kaybedilecek bir şey değil.
      final b = haberiDenetle(_haber(enBaslik: '', enGovde: ''));
      expect(b.firstWhere((x) => x.anahtar == 'ingilizce_eksik').agir, isFalse);
    });
  });

  group('mükerrer', () {
    test('aynı kaynak adresi AĞIR', () {
      final b = haberiDenetle(_haber(),
          yayindakiAdresler: {'https://turkseker.gov.tr/haber/1'});
      expect(b.firstWhere((x) => x.anahtar == 'mukerrer_adres').agir, isTrue);
    });

    test('aynı başlık farklı yazımla yakalanıyor', () {
      final b = haberiDenetle(
        _haber(baslik: 'TÜRKŞEKER Pancar Üreticisine Ödenen Bedeli Açıkladı'),
        yayindakiBasliklar: const [
          'türkşeker pancar üreticisine ödenen bedeli açıkladı!'
        ],
      );
      expect(_anahtarlar(b), contains('mukerrer_baslik'));
    });

    test('Türkçe büyük I karışıklığı imzayı bozmuyor', () {
      // 'IĞDIR'.toLowerCase() → 'iğdir'; elle eşleme olmasaydı iki başlık
      // farklı imza üretir ve mükerrer kaçardı.
      final b = haberiDenetle(
        _haber(baslik: 'IĞDIR ovasında sulama yatırımı tamamlandı'),
        yayindakiBasliklar: const ['Iğdır ovasında sulama yatırımı tamamlandı'],
      );
      expect(_anahtarlar(b), contains('mukerrer_baslik'));
    });

    test('benzemeyen başlık mükerrer saymıyor', () {
      final b = haberiDenetle(_haber(),
          yayindakiBasliklar: const ['Bambaşka bir haber başlığı burada']);
      expect(_anahtarlar(b), isNot(contains('mukerrer_baslik')));
    });
  });

  group('sıralama', () {
    test('ağır bulgular listenin başında', () {
      final b = haberiDenetle(
          _haber(ozet: '', baslik: 'A' * 120, kare: null));
      expect(b.first.agir, isTrue);
    });
  });

  _govdesizSinavlar();

  group('gövde görselleri', () {
    test('src adresleri sırayla çıkarılıyor', () {
      const h = '<p>a</p><img src="https://x/1.jpg" /><p>b</p>'
          '<img alt="k" src="https://x/2.jpg">';
      expect(govdeGorselleri(h), ['https://x/1.jpg', 'https://x/2.jpg']);
    });

    test('görsel yoksa boş liste', () {
      expect(govdeGorselleri('<p>yok</p>'), isEmpty);
    });
  });
}

// Gövdesiz çağrı — kuyruk listesi dar sütun kümesiyle çalışıyor.
void _govdesizSinavlar() {
  group('gövdesiz denetim (liste görünümü)', () {
    test('gövde kuralları hiç çalışmıyor', () {
      final b = haberiDenetle(_haber(govde: ''), govdeDenetle: false);
      final a = b.map((x) => x.anahtar).toSet();
      expect(a, isNot(contains('govde_kisa')));
      expect(a, isNot(contains('govde_etiket')));
      expect(a, isNot(contains('govde_yarim')));
    });

    test('görsel ve başlık kuralları yine çalışıyor', () {
      final b = haberiDenetle(_haber(govde: '', kapak: null),
          govdeDenetle: false);
      expect(b.map((x) => x.anahtar), contains('kapak_yok'));
    });

    test('İngilizce gövdesi boş olsa bile uyarı çıkmıyor', () {
      // Başlık varsa: gövdeyi görmediğimiz için "İngilizce eksik" diyemeyiz.
      final b = haberiDenetle(_haber(govde: '', enGovde: ''),
          govdeDenetle: false);
      expect(b.map((x) => x.anahtar), isNot(contains('ingilizce_eksik')));
    });
  });
}
