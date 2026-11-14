import 'package:flutter_test/flutter_test.dart';
import 'package:tarim_app/features/dashboard/domain/rakam_eslestirme.dart';

// ══════════════════════════════════════════════════════════════════════════
//  Rakam ve alıntı eşleştirme
// ──────────────────────────────────────────────────────────────────────────
//  Bu denetimin işe yaraması tek bir şeye bağlı: YANLIŞ ALARM VERMEMESİ.
//  Gerçekten metinde geçen bir rakamı "eksik" diye kırmızı gösterirse
//  yönetici bir hafta sonra bütün kırmızıları görmezden gelmeye başlar ve
//  gerçek bir kayıp da o gürültünün içinde kaybolur.
//
//  Bu yüzden sınavların çoğu "BULUNMALI" tarafında: Türkçenin sayıyı kaç
//  türlü yazdığını tek tek kapsıyorlar.
// ══════════════════════════════════════════════════════════════════════════

List<Map<String, dynamic>> _fig(num deger, {String birim = '', String etiket = 'x'}) =>
    [
      {'value': deger, 'unit': birim, 'label': etiket}
    ];

void main() {
  group('sayı yazımları', () {
    test('düz basamak', () {
      expect(sayiYazimlari(51), contains('51'));
    });

    test('binlik ayırıcılı ve boşluklu', () {
      final y = sayiYazimlari(9370);
      expect(y, containsAll(['9370', '9.370', '9 370']));
    });

    test('Türkçe sözcüklü yazım', () {
      expect(sayiYazimlari(9370), contains('9 bin 370'));
    });

    test('bin ile başlayan sayı "1 bin" demiyor', () {
      // Türkçede 1500 "bin 500"dür, "1 bin 500" değil.
      expect(sayiYazimlari(1500), contains('bin 500'));
      expect(sayiYazimlari(1500), isNot(contains('1 bin 500')));
    });

    test('tam binler', () {
      expect(sayiYazimlari(20000), contains('20 bin'));
    });

    test('milyonlar', () {
      expect(sayiYazimlari(2300000), contains('2 milyon 300 bin'));
    });

    test('ondalık virgülle yazılıyor', () {
      expect(sayiYazimlari(3.5), contains('3,5'));
    });
  });

  group('rakam metinde bulunuyor', () {
    test('düz basamakla geçiyorsa', () {
      final d = rakamlariDenetle(_fig(4011, birim: 'dekar'),
          '<p>Toplam alan 4011 dekara ulaştı.</p>');
      expect(d.single.durum, Eslesme.bulundu);
    });

    test('Türkçe sözcüklü yazımla geçiyorsa', () {
      // Gerçek örnek: rekolte "9 bin 370 ton" diye yazılıyor, figures 9370.
      final d = rakamlariDenetle(_fig(9370, birim: 'ton'),
          '<p>Rekolte 9 bin 370 tona ulaştı.</p>');
      expect(d.single.durum, Eslesme.bulundu);
      expect(d.single.bulunanBicim, '9 bin 370');
    });

    test('binlik ayırıcıyla geçiyorsa', () {
      final d = rakamlariDenetle(
          _fig(9370), '<p>Üretim 9.370 ton olarak kaydedildi.</p>');
      expect(d.single.durum, Eslesme.bulundu);
    });

    test('yüzde işaretiyle geçiyorsa', () {
      final d = rakamlariDenetle(
          _fig(51, birim: '%'), '<p>Artış %51 olarak gerçekleşti.</p>');
      expect(d.single.durum, Eslesme.bulundu);
    });

    test('"yüzde" sözcüğüyle geçiyorsa', () {
      final d = rakamlariDenetle(
          _fig(51, birim: '%'), '<p>Rekolte yüzde 51 arttı.</p>');
      expect(d.single.durum, Eslesme.bulundu);
    });
  });

  group('gerçek veriden çıkan tuzaklar', () {
    // Aşağıdakilerin hepsi 150 gerçek haber üzerinde ölçülerek bulundu.
    // Her biri YANLIŞ ALARM üretiyordu; bulunamayan rakam oranı %8,3'ten
    // %2,4'e bu dört düzeltmeyle indi.

    test('küçük sayı metinde harfle yazılıyor', () {
      // "5 gün" figürü, metinde "beş gün".
      final d = rakamlariDenetle(_fig(5, birim: 'gün'),
          '<p>Fuar beş gün boyunca açık kalacak.</p>');
      expect(d.single.durum, Eslesme.bulundu);
    });

    test('sıra sayısı sözcükle yazılıyor', () {
      final d = rakamlariDenetle(_fig(1, birim: 'sıra'),
          '<p>Türkiye Avrupa\'da birinci sırada.</p>');
      expect(d.single.durum, Eslesme.bulundu);
    });

    test('büyük sayı gruplu yazılıyor', () {
      // 117.878.764 TL → "117 milyon 878 bin 764 lira"
      final d = rakamlariDenetle(_fig(117878764, birim: 'TL'),
          '<p>Toplam 117 milyon 878 bin 764 lira hibe verildi.</p>');
      expect(d.single.durum, Eslesme.bulundu);
    });

    test('para tutarı iki basamakla yazılıyor', () {
      // Figür 71.2, metin "71,20 TL". Sınır denetimi sondaki sıfırı
      // görüp eşleşmeyi reddediyordu.
      final d = rakamlariDenetle(
          _fig(71.2, birim: 'TL'), '<p>Benzinin litresi 71,20 TL.</p>');
      expect(d.single.durum, Eslesme.bulundu);
    });

    test('eksi değerde işaret metinde yazmıyor', () {
      // Figür -3,2 %, metin "yüzde 3,2 geriledi". Yön sözcükte.
      final d = rakamlariDenetle(
          _fig(-3.2, birim: '%'), '<p>Soya fiyatı yüzde 3,2 geriledi.</p>');
      expect(d.single.durum, Eslesme.bulundu);
    });
  });

  group('rakam metinde YOK', () {
    test('hiç geçmiyorsa bulunamadı', () {
      final d = rakamlariDenetle(
          _fig(375, birim: 'milyon TL'), '<p>Ekonomiye katkı bekleniyor.</p>');
      expect(d.single.durum, Eslesme.bulunamadi);
    });

    test('başka bir sayının içinde geçmesi SAYILMIYOR', () {
      // "51" dizesi "9.513" içinde geçiyor ama o başka bir sayı. Sınır
      // gözetilmeseydi her küçük rakam "var" çıkar ve denetim hiçbir şey
      // yakalamazdı.
      final d = rakamlariDenetle(
          _fig(51), '<p>Üretim 9513 tona ulaştı.</p>');
      expect(d.single.durum, Eslesme.bulunamadi);
    });

    test('sayının bir parçası olarak geçmesi sayılmıyor (sonek)', () {
      final d = rakamlariDenetle(_fig(37), '<p>Toplam 370 dekar.</p>');
      expect(d.single.durum, Eslesme.bulunamadi);
    });
  });

  group('sınanamayan durumlar', () {
    test('gövde yoksa bilinmiyor', () {
      expect(rakamlariDenetle(_fig(10), '').single.durum, Eslesme.bilinmiyor);
    });

    test('değer okunamıyorsa bilinmiyor', () {
      final d = rakamlariDenetle([
        {'value': 'yaklaşık', 'unit': '', 'label': 'x'}
      ], '<p>metin</p>');
      expect(d.single.durum, Eslesme.bilinmiyor);
    });

    test('figures null ise boş liste', () {
      expect(rakamlariDenetle(null, '<p>a</p>'), isEmpty);
    });
  });

  group('alıntılar', () {
    const alinti = 'Burdur Şeker Fabrikamızda gerçekleştirdiğimiz kapsamlı '
        'revizyon ve modernizasyon yatırımlarıyla geleceğe yatırım yapıyoruz.';

    test('gövdede geçen alıntı bulunuyor', () {
      final d = alintilariDenetle([
        {'text': alinti, 'speaker': 'Muhiddin Şahin'}
      ], '<p>Şahin, "$alinti" dedi.</p>');
      expect(d.single.durum, Eslesme.bulundu);
      expect(d.single.konusan, 'Muhiddin Şahin');
    });

    test('editör kısaltmışsa yine bulunuyor', () {
      // Alıntının başı duruyorsa alıntı metne girmiş demektir.
      final kisa = alinti.substring(0, 70);
      final d = alintilariDenetle([
        {'text': alinti}
      ], '<p>Şahin, "$kisa…" dedi.</p>');
      expect(d.single.durum, Eslesme.bulundu);
    });

    test('tırnak çeşidi farkı eşleşmeyi bozmuyor', () {
      final d = alintilariDenetle([
        {'text': '“$alinti”'}
      ], '<p>Şahin, «$alinti» dedi.</p>');
      expect(d.single.durum, Eslesme.bulundu);
    });

    test('gövdede hiç geçmiyorsa bulunamadı', () {
      final d = alintilariDenetle([
        {'text': alinti}
      ], '<p>Fabrikada çalışmalar sürüyor.</p>');
      expect(d.single.durum, Eslesme.bulunamadi);
    });
  });
}
