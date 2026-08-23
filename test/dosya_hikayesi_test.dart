import 'package:flutter_test/flutter_test.dart';
import 'package:tarim_app/features/stories/data/models/story_item.dart';

/// Dosya hikâyeleri — habere bağlı olmayan baloncuklar.
///
/// Hikâye sistemi baştan "her hikâye bir haberden çıkar" varsayımıyla
/// yazılmıştı. Ülke ve Kurum Dosyası hikâyeleri bunu kırıyor; bu testler
/// varsayımın geri sızmadığını sınıyor.
void main() {
  StoryItem yap({String hedefYol = '', String articleId = 'a1'}) => StoryItem(
        id: 's1#0',
        storyId: 's1',
        articleId: articleId,
        hedefYol: hedefYol,
        superTitle: 'ÜST',
        headline: 'Başlık',
        bigStatValue: '%21',
        statLabel: 'Etiket',
        imageUrl: 'https://ornek/kart.jpg',
        createdAt: DateTime.now(),
      );

  test('hedef yolu olan slayt dosya hikâyesi sayılır', () {
    expect(yap(hedefYol: '/kurum/tmo').dosyaHikayesi, isTrue);
    expect(yap(hedefYol: '/ulke/hollanda').dosyaHikayesi, isTrue);
  });

  test('hedef yolu olmayan slayt haber hikâyesi kalır', () {
    // Eski davranış korunuyor: hedef yazılı değilse haberin adresine gidilir.
    expect(yap().dosyaHikayesi, isFalse);
  });

  test('habersiz slaytta articleId boş kalabiliyor', () {
    // article_id artık null olabiliyor. Sağlayıcı `null` yerine boş dize
    // yazıyor; `.toString()` çağrılsaydı "/haber/null" adresi üretilirdi.
    final s = yap(hedefYol: '/kurum/tmo', articleId: '');
    expect(s.articleId, isEmpty);
    expect(s.dosyaHikayesi, isTrue);
  });
}
