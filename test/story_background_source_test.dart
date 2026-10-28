import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tarim_app/core/utils/image_fallback_helper.dart';
import 'package:tarim_app/features/stories/presentation/widgets/story_image.dart';

// Bir gerileme testi: dikey hikaye türevi kısa bir süre TÜM ekranlara
// veriliyordu. Masaüstünde sonuç felaketti — türev zaten kaynağın orta
// şeridinden kırpılmış, geniş pencerede üstüne yüksekliğinin dörtte üçü daha
// kesiliyor ve kalan parça büyütülüyordu.

const String _yatay =
    'https://x.supabase.co/storage/v1/object/public/article-images/a_1200x630.jpg';
const String _dikey =
    'https://x.supabase.co/storage/v1/object/public/article-images/a_1200x630_1080x2340.jpg';

/// [size] ölçüsündeki bir görüntü alanında seçilen zemin adresini döndürür.
Future<String> _secilen(WidgetTester tester, Size size,
    {String portrait = _dikey}) async {
  late String sonuc;
  await tester.pumpWidget(MediaQuery(
    data: MediaQueryData(size: size, devicePixelRatio: 3),
    child: Builder(builder: (context) {
      sonuc = storyBackgroundUrl(context, imageUrl: _yatay, portraitUrl: portrait);
      return const SizedBox.shrink();
    }),
  ));
  return sonuc;
}

/// Yatay kart [NewsArticleImage.resolveUrl]'den geçiyor; o da dönüştürme uç
/// noktasını BAYRAĞA bağlı kullanıyor. Supabase görsel dönüştürme ücretli
/// planın parçası ve Free'de 403 `FeatureNotEnabled` dönüyor, bu yüzden
/// varsayılan KAPALI (bkz. image_fallback_helper.dart).
///
/// Test iki hâli de doğruluyor: böylece `--dart-define=GORSEL_DONUSTURME=true`
/// ile koşturulduğunda da geçerli kalıyor. Sabitlenen şey adresin HANGİ yoldan
/// geldiği değil, yatay kartın dönüştürme yolunu İZLEDİĞİ.
final String _donusumYolu = NewsArticleImage.donusturmeAcik
    ? '/render/image/public/'
    : '/object/public/';

void main() {
  testWidgets('telefon dikey — dikey türev seçilir', (tester) async {
    expect(await _secilen(tester, const Size(390, 844)), _dikey);
  });

  testWidgets('tablet dikey — dikey türev seçilir', (tester) async {
    expect(await _secilen(tester, const Size(834, 1112)), _dikey);
  });

  testWidgets('tablet yatay — yatay kart seçilir', (tester) async {
    expect(await _secilen(tester, const Size(1112, 834)), contains('a_1200x630.jpg'));
  });

  testWidgets('masaüstü — yatay kart seçilir, dikey türev ASLA', (tester) async {
    final String url = await _secilen(tester, const Size(1920, 1080));
    expect(url, isNot(contains('1080x2340')));
    expect(url, contains(_donusumYolu));
  });

  testWidgets('dar masaüstü penceresi bile kareye yakınsa yatay kart', (tester) async {
    // Eşik geometrik ortada: √(0,46 × 1,90) = 0,94.
    final String url = await _secilen(tester, const Size(1000, 1000));
    expect(url, isNot(contains('1080x2340')));
  });

  testWidgets('türev yoksa telefonda da yatay karta düşer', (tester) async {
    final String url = await _secilen(tester, const Size(390, 844), portrait: '');
    expect(url, isNot(contains('1080x2340')));
    expect(url, contains(_donusumYolu));
  });

  testWidgets('seçilen dikey türev dönüştürmeden geçmez', (tester) async {
    // Hazır ölçüdeki dosyaya width vermek onu kırpıyor; ham gelmeli.
    expect(await _secilen(tester, const Size(390, 844)), isNot(contains('width=')));
  });
}
