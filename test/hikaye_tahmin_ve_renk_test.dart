import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tarim_app/core/theme/konu_renkleri.dart';
import 'package:tarim_app/features/stories/data/models/story_item.dart';
import 'package:tarim_app/features/stories/data/tahmin_defteri.dart';
import 'package:tarim_app/features/stories/presentation/widgets/tahmin_slayti.dart';

// ══════════════════════════════════════════════════════════════════════════
//  Konu renk sistemi (Ö7), tahmin defteri ve sonuç satırı (Ö5).
// ══════════════════════════════════════════════════════════════════════════

StoryItem _slayt({
  String id = 's1#0',
  String soru = '',
  List<String> sikler = const <String>[],
  int dogru = -1,
}) =>
    StoryItem(
      id: id,
      storyId: 's1',
      articleId: 'a1',
      superTitle: 'üst',
      headline: 'başlık',
      bigStatValue: '%30',
      statLabel: 'etiket',
      imageUrl: 'https://ornek/x.jpg',
      createdAt: DateTime(2026, 11, 6),
      tahminSoru: soru,
      tahminSecenekler: sikler,
      tahminDogru: dogru,
    );

void main() {
  group('konu renkleri', () {
    test('hikâye kategorilerinin hepsi tanınıyor', () {
      // Üretici bu adları birebir yazıyor; biri eşlemede yoksa o kategori
      // nötr griye düşer ve şeritte sessizce renksiz kalır.
      for (final k in [
        'Piyasa', 'Hasat', 'Destekleme', 'İhracat', 'Hayvancılık',
        'Su & İklim', 'Gıda', 'Teknoloji', 'Politika', 'Dünya',
        'Ülke Dosyası', 'Kurum Dosyası',
      ]) {
        expect(konuTaniniyor(k), isTrue, reason: k);
      }
    });

    test('haber konuları da tanınıyor — tek dil', () {
      for (final k in ['Bitkisel Üretim', 'Ekonomi', 'Tarım-Bilim', 'YYT']) {
        expect(konuTaniniyor(k), isTrue, reason: k);
      }
    });

    test('bilinmeyen konu nötre düşüyor, rastgele renk ÜRETİLMİYOR', () {
      // Rastgele üretim olsaydı yeni bir kategori her açılışta başka
      // renkte görünürdü.
      final a = konuRengi('Henüz Olmayan Kategori', false);
      final b = konuRengi('Başka Bir Kategori', false);
      expect(a, b);
      expect(konuTaniniyor('Henüz Olmayan Kategori'), isFalse);
    });

    test('açık ve koyu tonlar FARKLI', () {
      for (final k in tanimliKonular) {
        expect(konuRengi(k, false), isNot(konuRengi(k, true)), reason: k);
      }
    });

    test('null güvenli', () {
      expect(() => konuRengi(null, false), returnsNormally);
      expect(konuTaniniyor(null), isFalse);
    });

    test('çip rengi koyu temanın parlak tonu', () {
      // Çip tam ekran fotoğrafın üstünde duruyor; açık ton orada kayboluyor.
      expect(konuCipRengi('Piyasa'), konuRengi('Piyasa', true));
    });
  });

  group('tahmin geçerliliği', () {
    test('eksik alanla tahmin YOK sayılıyor', () {
      expect(_slayt().tahminVar, isFalse);
      expect(_slayt(soru: 'Soru?').tahminVar, isFalse);
      expect(_slayt(soru: 'Soru?', sikler: ['a', 'b']).tahminVar, isFalse);
      expect(
        _slayt(soru: 'Soru?', sikler: ['a', 'b', 'c'], dogru: -1).tahminVar,
        isFalse,
      );
      expect(
        _slayt(soru: 'Soru?', sikler: ['a', 'b', 'c'], dogru: 3).tahminVar,
        isFalse,
      );
    });

    test('tam veri varsa tahmin VAR', () {
      expect(
        _slayt(soru: 'Soru?', sikler: ['a', 'b', 'c'], dogru: 1).tahminVar,
        isTrue,
      );
    });
  });

  group('tahmin defteri', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('işaretlenen slayt defterde', () async {
      expect(await TahminDefteri.yukle(), isEmpty);
      final d = await TahminDefteri.isaretle('s1#0');
      expect(d, contains('s1#0'));
      expect(await TahminDefteri.yukle(), contains('s1#0'));
    });

    test('ikinci işaretleme kopya üretmiyor', () async {
      await TahminDefteri.isaretle('s1#0');
      final d = await TahminDefteri.isaretle('s1#0');
      expect(d.length, 1);
    });

    test('eski kayıt budanıyor', () async {
      final eski = DateTime.now()
          .subtract(const Duration(days: 40))
          .millisecondsSinceEpoch;
      SharedPreferences.setMockInitialValues({
        'answered_story_guesses_v1': ['cok_eski|$eski'],
      });
      expect(await TahminDefteri.yukle(), isEmpty);
    });

    test('bozuk satır çökmüyor', () async {
      SharedPreferences.setMockInitialValues({
        'answered_story_guesses_v1': ['ayracsiz', 'a|abc', 'b|'],
      });
      expect(await TahminDefteri.yukle(), isEmpty);
    });
  });

  group('tahmin sonucu satırı', () {
    Future<void> kur(WidgetTester t, {required int toplam, required int dogru}) =>
        t.pumpWidget(MaterialApp(
          home: Scaffold(
            body: TahminSonucu(
              dogruBildi: true,
              toplam: toplam,
              dogru: dogru,
              isEn: false,
            ),
          ),
        ));

    testWidgets('eşiğin ALTINDA yüzde gösterilmiyor', (tester) async {
      // Üç kişinin ikisi bildiğinde "%67 bildi" yazmak sayıyı olduğundan
      // anlamlı gösterir.
      await kur(tester, toplam: 3, dogru: 2);
      expect(find.textContaining('Doğru bildiniz'), findsOneWidget);
      expect(find.textContaining('%'), findsNothing);
    });

    testWidgets('eşiğin ÜSTÜNDE yüzde gösteriliyor', (tester) async {
      await kur(tester, toplam: 100, dogru: 38);
      expect(find.textContaining('%38'), findsOneWidget);
    });

    testWidgets('sunucu cevabı gelmediyse yalnız doğru/yanlış', (tester) async {
      await kur(tester, toplam: 0, dogru: 0);
      expect(find.textContaining('Doğru bildiniz'), findsOneWidget);
      expect(find.textContaining('okurların'), findsNothing);
    });
  });
}
