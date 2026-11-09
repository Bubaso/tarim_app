import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// ══════════════════════════════════════════════════════════════════════════
//  İnceleme paneli kuyruk nesnesiyle ÇİZİLMEMELİ
// ──────────────────────────────────────────────────────────────────────────
//  9 Kasım 2026: moderatör kuyruğa 29 haber çekti, hepsi başlık dışında
//  bomboş açıldı. "Önizle" ise her şeyi gösteriyordu.
//
//  Sebep: `watchPendingArticles` performans için `select('*')` yerine ad ad
//  sütun çekiyor (`_kuyrukSutunlari`). O liste KATLANMIŞ kuyruk kartına
//  bakılarak daraltılmış ve aynı widget'ın içinde açılan İnceleme paneli
//  atlanmıştı. Panel tam olarak listede olmayan alanları gösteriyor:
//  gövde metni, İngilizce çeviri, doğrulama verisi, alıntılar. Önizleme
//  çalışıyordu çünkü o `fetchArticleById` ile tam satırı çekiyor.
//
//  Çözüm listeyi genişletmek DEĞİL — 300 satırın gövdesini indirmek
//  kuyruğu kullanılmaz hâle getiriyor. Açılan TEK haber tam çekiliyor.
//
//  Çekim ÜST EKRANDA, panelin içinde değil: `IncelemeKarti` saf bir sunum
//  widget'ı ve `panel_kuyrugu_test.dart` onu taklit depoyla, tam nesne
//  vererek pump ediyor. I/O'yu karta koymak o beş testi kırıyor — bir kez
//  denendi ve kırdı.
//
//  Kaynak dosyayı OKUYOR, widget pump ETMİYOR: ekranı pump etmek Supabase
//  ve Riverpod istiyor, oysa soru çalışma anına ait değil.
// ══════════════════════════════════════════════════════════════════════════

String _oku(String yol) {
  final d = File(yol);
  if (!d.existsSync()) fail('Dosya yok: $yol');
  return d.readAsStringSync();
}

/// `contentEn` → `content_en`
String _sutunAdi(String alan) =>
    alan.replaceAllMapped(RegExp('[A-Z]'), (m) => '_${m[0]!.toLowerCase()}');

void main() {
  const kart = 'lib/features/dashboard/presentation/widgets/inceleme_karti.dart';
  const ekran = 'lib/features/dashboard/presentation/screens/onay_kuyrugu_ekrani.dart';
  const saglayici = 'lib/features/home/providers/home_providers.dart';
  const depo = 'lib/features/home/data/repositories/home_repository.dart';

  test('panel kuyruk nesnesiyle kurulmuyor', () {
    final e = _oku(ekran);

    // Kurulum yerini bulup ORADA ne verildiğine bakıyoruz: dosyanın
    // başka yerinde geçen `article: article` (önizleme çağrısı değil,
    // tam satır gönderiyor) yanlış alarm vermesin.
    final i = e.indexOf('IncelemeKarti(');
    expect(i, greaterThan(-1), reason: 'IncelemeKarti kurulmuyor.');
    final kurulum = e.substring(i, i + 160);
    expect(kurulum, isNot(contains('article: article')),
        reason: 'IncelemeKarti kuyruk akışından gelen nesneyle kuruluyor. '
            'O nesne gövde, çeviri, doğrulama ve alıntı taşımıyor: panel '
            'başlık dışında bomboş açılır.');

    // Önizleme de tam satır göndermek zorunda: web'de `extra` kaybolduğu
    // için rota kendisi çekiyordu, Android/iOS'ta `extra` yaşıyor.
    expect(e, contains('articleByIdProvider(article.id).future'),
        reason: 'Önizleme kuyruk nesnesini gönderiyor — mobilde gövde boş '
            'gelir, web\'de tesadüfen çalışır.');

    expect(e, contains('articleByIdProvider(article.id)'),
        reason: 'Üst ekran tam satırı istemiyor.');

    expect(e, contains('article: tam'),
        reason: 'Panel tam satırla kurulmuyor.');
  });

  test('tam satır gelmeden panel çizilmiyor', () {
    final e = _oku(ekran);

    expect(e, contains('loading:'),
        reason: '"Gövde yok" ile "gövde henüz inmedi" aynı ekrana yazılırsa '
            'moderatör dolu bir haberi boş sanıp reddeder.');
    expect(e, contains('error:'), reason: 'Hata dalı yok.');
    expect(e, contains('tam == null'),
        reason: 'Satır bulunamadığında panel yine boş çizilir.');
    expect(e, contains('Yeniden dene'),
        reason: 'Moderatöre çıkış yolu bırakılmamış.');
  });

  test('sağlayıcı tam satırı çekiyor', () {
    final s = _oku(saglayici);
    expect(s, contains('articleByIdProvider'),
        reason: 'Sağlayıcı yok.');
    expect(s, contains('fetchArticleById'),
        reason: 'articleByIdProvider tam satırı çekmiyor.');
    // Kopya sağlayıcı açılmasın: aynı haber iki ayrı önbellekte tutulursa
    // panelin yazdığı değişiklik önizlemede görünmez.
    expect(s, isNot(contains('tamHaberProvider')),
        reason: 'articleByIdProvider ile aynı işi yapan ikinci bir '
            'sağlayıcı eklenmiş.');
  });

  test('I/O panelin içine taşınmamış', () {
    expect(_oku(kart), isNot(contains('fetchArticleById')),
        reason: 'IncelemeKarti kendi sorgusunu yapıyor. Kart saf sunum '
            'widget\'ı olmak zorunda: panel_kuyrugu_test.dart onu taklit '
            'depoyla pump ediyor ve I/O o beş testi kırıyor.');
  });

  test('dar kuyruk listesi panelin ihtiyacını karşılamıyor', () {
    final m = RegExp(r"_kuyrukSutunlari\s*=\s*((?:\s*'[^']*'\s*)+);")
        .firstMatch(_oku(depo));
    expect(m, isNotNull, reason: '_kuyrukSutunlari okunamadı.');
    final sutunlar = RegExp("'([^']*)'")
        .allMatches(m!.group(1)!)
        .map((x) => x.group(1)!)
        .join()
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toSet();

    final okunan = RegExp(r'\ba\.([a-zA-Z_][a-zA-Z0-9_]*)')
        .allMatches(_oku(kart))
        .map((x) => _sutunAdi(x.group(1)!))
        .toSet();

    // Bu alanlar kuyruk sorgusunda YOK — tam çekimin gerekçesi bu.
    // Biri listeye eklenirse test kırılır ve karar yeniden verilir:
    // 300 satırın o sütununu indirmeye değer mi?
    expect(okunan.difference(sutunlar),
        containsAll(<String>['content', 'facts', 'figures', 'quotes']),
        reason: 'Panelin okuduğu alanlar dar listeyle örtüşmeye başladı — '
            'tam çekimin gerekçesi değişmiş olabilir.');
  });
}
