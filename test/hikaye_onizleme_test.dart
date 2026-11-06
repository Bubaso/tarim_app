import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tarim_app/features/stories/presentation/widgets/story_image.dart';

// ══════════════════════════════════════════════════════════════════════════
//  Ağ isteği gerektirmeyen önizleme — 6 Kasım 2026 denetimi, T1.
//
//  Eski mekanizma 48 px'lik bir türevi AĞDAN istiyordu ve devreye girmesi
//  dönüştürme bayrağına bağlıydı; bayrak kapalı olduğu için slaytın ilk
//  0,7–3,4 saniyesi düz koyu bir dikdörtgendi. Yenisi satırla birlikte gelen
//  base64 dizeyi çiziyor — hiçbir şeye bağlı değil.
//
//  Bu sınamanın asıl işi BOZUK GİRDİYİ korumak: önizleme hattan geliyor ve
//  bir gün boş, kırpık ya da yanlış biçimde gelebilir. O durumda ekranın
//  kaybedilmemesi gerekiyor.
// ══════════════════════════════════════════════════════════════════════════

/// 1×1 piksellik geçerli bir JPEG'in base64'ü.
const String _gecerliJpeg =
    '/9j/4AAQSkZJRgABAQEAYABgAAD/2wBDAAgGBgcGBQgHBwcJCQgKDBQNDAsLDBkSEw8UHRof'
    'Hh0aHBwgJC4nICIsIxwcKDcpLDAxNDQ0Hyc5PTgyPC4zNDL/wAALCAABAAEBAREA/8QAFAAB'
    'AAAAAAAAAAAAAAAAAAAACf/EABQQAQAAAAAAAAAAAAAAAAAAAAD/2gAIAQEAAD8AKp//2Q==';

void main() {
  group('önizleme çözümü', () {
    test('geçerli data URI çizilebilir görüntüye dönüşüyor', () {
      final g = onizlemeGoruntusu('data:image/jpeg;base64,$_gecerliJpeg');
      expect(g, isNotNull);
      expect(g!.bytes, isNotEmpty);
    });

    test('boş ve null girdi null döner', () {
      expect(onizlemeGoruntusu(null), isNull);
      expect(onizlemeGoruntusu(''), isNull);
      expect(onizlemeGoruntusu('   '), isNull);
    });

    test('data URI olmayan dize null döner', () {
      // Hattın bir gün buraya düz bir adres yazması mümkün; o durumda
      // çizmeye çalışmak yerine düz zemine düşülmeli.
      expect(onizlemeGoruntusu('https://ornek/gorsel.jpg'), isNull);
      expect(onizlemeGoruntusu('data:text/plain;base64,YWJj'), isNull);
    });

    test('bozuk base64 EKRANI KAYBETTİRMİYOR', () {
      // Kırpık bir dize `base64Decode`u fırlatır; yakalanmazsa bütün
      // görüntüleyici çöker.
      expect(onizlemeGoruntusu('data:image/jpeg;base64,!!!bozuk!!!'), isNull);
      expect(onizlemeGoruntusu('data:image/jpeg;base64,'), isNull);
      expect(onizlemeGoruntusu('data:image/jpeg'), isNull);
    });

    test('aynı dize ikinci çağrıda AYNI nesneyi veriyor', () {
      // Önbellek olmasaydı base64 her karede yeniden çözülürdü.
      const uri = 'data:image/jpeg;base64,$_gecerliJpeg';
      expect(identical(onizlemeGoruntusu(uri), onizlemeGoruntusu(uri)), isTrue);
    });

    test('çözülen baytlar kaynakla birebir', () {
      final g = onizlemeGoruntusu('data:image/jpeg;base64,$_gecerliJpeg');
      expect(g!.bytes, equals(base64Decode(_gecerliJpeg)));
    });
  });

  turevSinamalari();

  group('önizleme katmanı', () {
    testWidgets('geçerli önizlemede görüntü çiziliyor', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: SizedBox(
          width: 200,
          height: 400,
          child: StoryOnizleme(onizleme: 'data:image/jpeg;base64,$_gecerliJpeg'),
        ),
      ));
      await tester.pump();
      expect(find.byType(ImageFiltered), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('önizleme yoksa düz zemin — eski davranış', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: SizedBox(
          width: 200,
          height: 400,
          child: StoryOnizleme(onizleme: ''),
        ),
      ));
      await tester.pump();
      // Bulanıklaştırma katmanı HİÇ kurulmuyor; boş dize için iş yapmanın
      // anlamı yok.
      expect(find.byType(ImageFiltered), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('bozuk önizlemede de düz zemine düşüyor', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: SizedBox(
          width: 200,
          height: 400,
          child: StoryOnizleme(onizleme: 'data:image/jpeg;base64,???'),
        ),
      ));
      await tester.pump();
      expect(find.byType(ImageFiltered), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}

// ══════════════════════════════════════════════════════════════════════════
//  Türev gerçekten kapağa mı ait? (6 Kasım 2026 kullanıcı bildirimi)
//
//  Editör onay sırasında kapağı değiştiriyor — çoğu zaman kaynağın ikon
//  görselinden kurtulmak için — ama türevler haber alınırken bir kez
//  üretilmişti ve eski görseli göstermeye devam ediyordu. Ölçüm: 1698
//  haberin 109'unda uyuşmazlık, şeritteki 33 hikâyenin 12'si etkileniyordu;
//  tek bir türev dört ayrı haberde kullanılıyordu.
// ══════════════════════════════════════════════════════════════════════════

const String _depo =
    'https://x.supabase.co/storage/v1/object/public/article-images';

void turevSinamalari() {
  group('türev sahipliği', () {
    test('aynı karmadan üretilmiş türev KABUL ediliyor', () {
      expect(
        turevKapagaAit('$_depo/abc123_1080x2340_v2.jpg',
            '$_depo/abc123_1200x630.jpg'),
        isTrue,
      );
      expect(
        turevKapagaAit('$_depo/abc123_320x320.jpg',
            '$_depo/abc123_1200x630.jpg'),
        isTrue,
      );
    });

    test('BAŞKA karmadan gelen türev REDDEDİLİYOR', () {
      // Kullanıcının bildirdiği hata tam olarak bu.
      expect(
        turevKapagaAit('$_depo/fa3b8256b814_1080x2340_v2.webp',
            '$_depo/551807927553_1200x630.webp'),
        isFalse,
      );
    });

    test('uzantı farkı sorun DEĞİL — karma aynı', () {
      expect(
        turevKapagaAit('$_depo/abc123_1080x2340_v2.webp',
            '$_depo/abc123_1200x630.jpg'),
        isTrue,
      );
    });

    test('sorgu dizgesi kökü bozmuyor', () {
      expect(
        turevKapagaAit('$_depo/abc123_320x320.jpg?v=3',
            '$_depo/abc123_1200x630.jpg'),
        isTrue,
      );
    });

    test('biri boşsa KABUL — çelişki kanıtı yokken türev atılmaz', () {
      expect(turevKapagaAit('', '$_depo/abc123_1200x630.jpg'), isTrue);
      expect(turevKapagaAit('$_depo/abc123_320x320.jpg', ''), isTrue);
      expect(turevKapagaAit('', ''), isTrue);
    });

    test('kök okunamıyorsa KABUL', () {
      // Harici bir CDN adresi; karma düzenimize uymuyor ama çalışıyor
      // olabilir.
      expect(turevKapagaAit('https://cdn.ornek/x/', 'https://cdn.ornek/y/'),
          isTrue);
    });

    test('kök çıkarımı', () {
      expect(turevKoku('$_depo/abc123_1200x630.jpg'), 'abc123');
      expect(turevKoku('$_depo/abc123.jpg'), 'abc123');
      expect(turevKoku(''), '');
    });
  });
}
