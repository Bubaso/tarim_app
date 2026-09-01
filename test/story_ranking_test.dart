import 'package:flutter_test/flutter_test.dart';
import 'package:tarim_app/features/stories/data/models/story_item.dart';
import 'package:tarim_app/features/stories/data/story_constants.dart';
import 'package:tarim_app/features/stories/providers/story_providers.dart';

StoryItem _item(
  String id, {
  required DateTime createdAt,
  DateTime? expiresAt,
  bool isBreaking = false,
  bool sabit = false,
}) {
  return StoryItem(
    id: id,
    storyId: id,
    articleId: 'a-$id',
    superTitle: 'ETİKET',
    headline: 'Başlık $id',
    bigStatValue: '+%4.2',
    statLabel: 'Etiket',
    imageUrl: 'https://example.com/$id.jpg',
    createdAt: createdAt,
    expiresAt: expiresAt,
    isBreaking: isBreaking,
    sabit: sabit,
  );
}

StoryGroup _group(
  String key,
  List<StoryItem> items, {
  bool isBreaking = false,
  bool sabit = false,
}) {
  return StoryGroup(
    key: key,
    title: key,
    avatarUrl: items.first.imageUrl,
    items: items,
    latestAt: items.first.createdAt,
    isBreaking: isBreaking,
    sabit: sabit,
  );
}

void main() {
  final now = DateTime(2026, 8, 20, 12);

  /// Dosya hikâyesi: yayın penceresi boyunca şeritte kalması gereken kart.
  StoryGroup _dosya(String key, {required Duration yas, DateTime? bitis}) {
    final t = now.subtract(yas);
    return _group(
      key,
      [_item(key, createdAt: t, expiresAt: bitis, sabit: true)],
      sabit: true,
    );
  }

  group('sabit hikâyeler', () {
    test('yaşlansa da kesintiye kurban gitmiyor', () {
      // Asıl şikâyet buydu: dosya haftalarca yayında ama baloncuk günler sonra
      // şeritten düşüyordu. Tazelik puanı sıfıra yaklaşan bir dosya, on taze
      // haberle birlikte listede olmalı.
      final haberler = [
        for (var i = 0; i < StoryRules.maxGroups + 4; i++)
          _group('haber$i', [
            _item('haber$i', createdAt: now.subtract(Duration(minutes: i))),
          ]),
      ];
      final dosya = _dosya('Ülke Dosyası', yas: const Duration(days: 20));

      final sonuc = rankStoryGroups([...haberler, dosya], const {}, now);

      expect(sonuc.map((g) => g.key), contains('Ülke Dosyası'));
      expect(sonuc.length, StoryRules.maxGroups,
          reason: 'sabitler listeye eklenmiyor, yer ayırıyor');
    });

    test('iki dosya birden kalıyor', () {
      // Ülke ve kurum dosyası aynı anda yayında olabiliyor; ikisi de kalmalı.
      final haberler = [
        for (var i = 0; i < StoryRules.maxGroups; i++)
          _group('haber$i', [
            _item('haber$i', createdAt: now.subtract(Duration(minutes: i))),
          ]),
      ];
      final sonuc = rankStoryGroups(
        [
          ...haberler,
          _dosya('Ülke Dosyası', yas: const Duration(days: 12)),
          _dosya('Kurum Dosyası', yas: const Duration(days: 6)),
        ],
        const {},
        now,
      );

      final anahtarlar = sonuc.map((g) => g.key);
      expect(anahtarlar, contains('Ülke Dosyası'));
      expect(anahtarlar, contains('Kurum Dosyası'));
    });

    test('puan tabanı sayesinde dünkü haberlerin önünde', () {
      // Muafiyet tek başına yetmiyordu: dosya listede kalır ama en sona
      // düşerdi ve şeritte pratikte görünmezdi.
      final eskiHaber = _group('dün', [
        _item('dün', createdAt: now.subtract(const Duration(hours: 30))),
      ]);
      final dosya = _dosya('Ülke Dosyası', yas: const Duration(days: 20));

      final sonuc = rankStoryGroups([eskiHaber, dosya], const {}, now);
      expect(sonuc.first.key, 'Ülke Dosyası');
    });

    test('taze haberin önüne GEÇMİYOR', () {
      // Dosya son dakika değil. Sabitlik "hep görünür" demek, "hep başta"
      // demek değil.
      final taze = _group('taze', [
        _item('taze', createdAt: now.subtract(const Duration(minutes: 5))),
      ]);
      final dosya = _dosya('Ülke Dosyası', yas: const Duration(days: 20));

      final sonuc = rankStoryGroups([taze, dosya], const {}, now);
      expect(sonuc.first.key, 'taze');
    });

    test('penceresi kapanınca düşüyor', () {
      // Sabitlik sonsuza kadar değil: ömrü expires_at, yani dosyanın penceresi
      // belirliyor. Kapanmış bir dosyaya çağıran kart kalmamalı.
      final dosya = _dosya(
        'Ülke Dosyası',
        yas: const Duration(days: 20),
        bitis: now.subtract(const Duration(minutes: 1)),
      );

      final sonuc = rankStoryGroups([dosya], const {}, now);
      expect(sonuc, isEmpty);
    });

    test('izlenmiş dosya izlenmemiş haberin arkasına geçiyor', () {
      // Dosyayı izlemiş okura aynı baloncuğu her gün başta göstermek
      // bunaltırdı. Kart listede kalıyor, yalnızca sırası değişiyor.
      final dosya = _dosya('Ülke Dosyası', yas: const Duration(days: 2));
      final haber = _group('haber', [
        _item('haber', createdAt: now.subtract(const Duration(hours: 20))),
      ]);

      final sonuc = rankStoryGroups(
        [dosya, haber],
        {'Ülke Dosyası'},
        now,
      );

      expect(sonuc.map((g) => g.key), contains('Ülke Dosyası'));
      expect(sonuc.first.key, 'haber');
    });
  });

  group('rankStoryGroups', () {
    test('süresi dolan slaytları eler, grubu boşalırsa düşürür', () {
      final live = _item('live',
          createdAt: now.subtract(const Duration(hours: 1)),
          expiresAt: now.add(const Duration(hours: 5)));
      final dead = _item('dead',
          createdAt: now.subtract(const Duration(hours: 2)),
          expiresAt: now.subtract(const Duration(minutes: 1)));

      final result = rankStoryGroups(
        [
          _group('piyasa', [live, dead]),
          _group('hasat', [dead]),
        ],
        const <String>{},
        now,
      );

      expect(result.length, 1);
      expect(result.single.key, 'piyasa');
      expect(result.single.items.map((i) => i.id), ['live']);
    });

    test('izlenmemiş grup, daha taze ama izlenmiş grubun önüne geçer', () {
      final seenFresh = _item('fresh', createdAt: now);
      final unseenOld =
          _item('old', createdAt: now.subtract(const Duration(hours: 10)));

      final result = rankStoryGroups(
        [
          _group('taze', [seenFresh]),
          _group('eski', [unseenOld]),
        ],
        {'fresh'},
        now,
      );

      expect(result.map((g) => g.key), ['eski', 'taze']);
      expect(result.first.isSeen, isFalse);
      expect(result.last.isSeen, isTrue);
    });

    test('son dakika bonusu süresi dolunca tazelik kazanır', () {
      final staleBreaking = _item('breaking',
          createdAt: now.subtract(StoryRules.breakingBonusWindow +
              const Duration(hours: 1)),
          isBreaking: true);
      final fresh =
          _item('normal', createdAt: now.subtract(const Duration(hours: 1)));

      final result = rankStoryGroups(
        [
          _group('sondakika', [staleBreaking], isBreaking: true),
          _group('normal', [fresh]),
        ],
        const <String>{},
        now,
      );

      expect(result.map((g) => g.key), ['normal', 'sondakika']);
    });

    test('taze son dakika, aynı yaştaki normal haberin önünde', () {
      final breaking = _item('b',
          createdAt: now.subtract(const Duration(hours: 2)), isBreaking: true);
      final normal =
          _item('n', createdAt: now.subtract(const Duration(hours: 2)));

      final result = rankStoryGroups(
        [
          _group('normal', [normal]),
          _group('sondakika', [breaking], isBreaking: true),
        ],
        const <String>{},
        now,
      );

      expect(result.first.key, 'sondakika');
    });

    test('gelecek tarihli hikâye puanı şişirmiyor', () {
      // Üretimde görüldü: `created_at` veritabanı saatiyle yazılıyor, puan
      // cihaz saatiyle hesaplanıyor. İkisi kaydığında yaş NEGATİF çıkıyor ve
      // 0.5^(-12) = 4096 gibi bir puan doğuyordu; dört gün ileri tarihli tek
      // bir satır şeridi tamamen ele geçiriyordu.
      //
      // Doğru davranış onu elemek değil — saat kayması hikâyenin suçu değil —
      // "az önce yayımlanmış" saymak. Yani en fazla 1.0 puan: taze bir son
      // dakika haberi (1.0 + 0.6 bonus) hâlâ önünde olmalı.
      final gelecek = _group('gelecek', [
        _item('gelecek', createdAt: now.add(const Duration(days: 4))),
      ]);
      final sonDakika = _group(
        'son dakika',
        [_item('son dakika', createdAt: now.subtract(const Duration(minutes: 1)), isBreaking: true)],
        isBreaking: true,
      );

      final sonuc = rankStoryGroups([gelecek, sonDakika], const {}, now);
      expect(sonuc.first.key, 'son dakika');
    });

    test('grup sayısı üst sınırla kesilir', () {
      final groups = List.generate(
        StoryRules.maxGroups + 4,
        (i) => _group('konu$i', [
          _item('i$i', createdAt: now.subtract(Duration(minutes: i))),
        ]),
      );

      expect(rankStoryGroups(groups, const <String>{}, now).length,
          StoryRules.maxGroups);
    });
  });

  group('storySlideDuration', () {
    test('metin yoksa taban süre', () {
      expect(storySlideDuration('', ''), StoryRules.minSlideDuration);
    });

    test('uzun metinde tavan süreyi aşmaz', () {
      final duration = storySlideDuration('x' * 200, 'y' * 200);
      expect(duration, StoryRules.maxSlideDuration);
    });

    test('metin uzadıkça süre artar', () {
      final short = storySlideDuration('x' * 10, '');
      final long = storySlideDuration('x' * 60, '');
      expect(long, greaterThan(short));
      expect(long, lessThanOrEqualTo(StoryRules.maxSlideDuration));
    });
  });
}
