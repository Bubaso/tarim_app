import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tarim_app/features/tarladan_paylasim/data/paylasim_modelleri.dart';
import 'package:tarim_app/features/tarladan_paylasim/paylasim_providers.dart';
import 'package:tarim_app/features/tarladan_paylasim/presentation/widgets/gomme_kutusu.dart';
import 'package:tarim_app/features/tarladan_paylasim/presentation/widgets/tarladan_bandi.dart';

// ══════════════════════════════════════════════════════════════════════════
//  Ana sayfa Tarladan şeridi
// ──────────────────────────────────────────────────────────────────────────
//  BOŞKEN HİÇ ÇİZİLMEMESİ bir görünüm tercihi değil, portalın kuralı:
//  yanlış ya da boş bir kutu göstermektense hiç göstermemek. Şerit ana
//  sayfanın sonunda duruyor; boş bir başlık ve boş bir "tamamına git"
//  bağlantısı okura köşe çöktü dedirtir.
//
//  Bu sınama VM'de koşuyor, yani gömme kutusunun web sürümü değil künye
//  kartı çiziliyor. Şeridin KABUĞUNU doğruluyor: boşlukta susması,
//  doluyken başlığı ve kapıyı göstermesi. Gömmenin kendisi tarayıcıda
//  gözle denetleniyor.
//
//  DİL: sınama koşucusunun varsayılan yereli `en`, o yüzden beklenen
//  metinler İngilizce. Türkçe dal aynı kod yolunun `isEn` çevirmesi;
//  ayrı yerel kurmak için `MaterialApp`'e delege yığını gerekiyor ve
//  sınanan şey değişmiyor.
//
//  "Hiç çizilmiyor" sınamaları tek başına zayıf olurdu — widget hiç
//  kurulmasa da geçerlerdi. Üçüncü sınama doluyken çizildiğini
//  gösterdiği için ikisi birlikte anlamlı.
// ══════════════════════════════════════════════════════════════════════════

PaylasimBirimi _birim(String id, String mecra, String url) =>
    PaylasimBirimi.fromJson({
      'id': id,
      'durum': 'yayinda',
      'mecra': mecra,
      'url': url,
      'kaynak': 'hat',
      'eklendi': '2026-11-20T09:00:00Z',
      'gomme_iframe': 'https://example.test/embed',
    });

Widget _sar(List<Override> ustunlukler) => ProviderScope(
      overrides: ustunlukler,
      child: const MaterialApp(
        home: Scaffold(body: SingleChildScrollView(child: TarladanBandi())),
      ),
    );

void main() {
  testWidgets('yayında derleme yoksa hiç çizilmiyor', (tester) async {
    await tester.pumpWidget(_sar([
      tarladanBandiProvider.overrideWith((ref) async => <PaylasimBirimi>[]),
    ]));
    await tester.pumpAndSettle();

    expect(find.byType(GommeKutusu), findsNothing);
    expect(find.byType(Text), findsNothing);
  });

  testWidgets('veri gelmezse de hiç çizilmiyor', (tester) async {
    // Okura veritabanı hatası anlatılmıyor; şerit yalnız susuyor.
    await tester.pumpWidget(_sar([
      tarladanBandiProvider
          .overrideWith((ref) async => throw Exception('ağ yok')),
    ]));
    await tester.pumpAndSettle();

    expect(find.byType(GommeKutusu), findsNothing);
    expect(find.byType(Text), findsNothing);
  });

  testWidgets('paylaşım varsa başlık, tarih ve kapı görünüyor',
      (tester) async {
    await tester.pumpWidget(_sar([
      tarladanBandiProvider.overrideWith((ref) async => [
            _birim('1', 'instagram', 'https://www.instagram.com/p/a/'),
            _birim('2', 'youtube', 'https://www.youtube.com/watch?v=b'),
          ]),
    ]));
    await tester.pumpAndSettle();

    expect(find.text('From the Field'), findsOneWidget);
    expect(find.text('November 20'), findsOneWidget);
    expect(find.text('See the whole corner'), findsOneWidget);
    // Verilen kaç paylaşım varsa o kadar kutu — şerit eleme yapmıyor.
    expect(find.byType(GommeKutusu), findsNWidgets(2));
  });

  testWidgets('şeritte bizim yazdığımız yorum metni yok', (tester) async {
    // Köşenin kuralı: ekranda yalnız tarih, sayı ve köşenin adı olur.
    // Paylaşımlar kendi kartlarıyla konuşuyor.
    await tester.pumpWidget(_sar([
      tarladanBandiProvider.overrideWith((ref) async => [
            _birim('1', 'instagram', 'https://www.instagram.com/p/a/'),
          ]),
    ]));
    await tester.pumpAndSettle();

    final metinler = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data ?? '')
        .where((s) => s.isNotEmpty)
        .toList();

    // Başlık, tarih, kapı ve künye kartının kendi alanları dışında metin
    // olmamalı. Özellikle "günün seçkisi", "editörden" gibi bir giriş yok.
    for (final yasak in ['seçki', 'editör', 'öneri', 'bizden']) {
      expect(metinler.any((m) => m.toLowerCase().contains(yasak)), isFalse,
          reason: 'şeritte yorum metni çıkmış: $yasak');
    }
  });
}
