// Manşet sıralamasının canlı veriyle simülasyonu.
//
// `heroArticlesProvider`ın (lib/features/home/providers/home_providers.dart)
// puanlama ve dizme mantığının birebir kopyası — Riverpod ve Flutter'a bağımlı
// kısımları çıkarılmış hâli. Aynı dilde çalışması şart: kıpırtı `String.hashCode`
// ve `math.Random(seed)`e dayanıyor, bunların JS'te birebir karşılığı yok.
//
// Sınanan davranışlar:
//   • aynı ziyaret içinde sıra sabit mi,
//   • ziyaret değişince tazeleniyor ama tamamen dağılmıyor mu,
//   • okunan haber geri düşüyor mu,
//   • editör sabitlemesi raf ömrüne uyuyor mu.
//
// Kullanım: dart run tool/hero_order_sim.dart
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

const _base = 'xkwcyavcltrweunvooeu.supabase.co';
const _key =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inhrd2N5YXZjbHRyd2V1bnZvb2V1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODEzNDk4NTIsImV4cCI6MjA5NjkyNTg1Mn0.j6miEKZCNQ2XJ_jx8eRLKMs-g_KSBBbigHsrWAgjxS4';

const pinGrace = 6.0;
const heroLimit = 10;

class A {
  A(Map<String, dynamic> m)
      : id = m['id'] as String,
        title = (m['title'] as String?) ?? '',
        imageUrl = m['image_url'] as String?,
        createdAt = DateTime.parse(m['created_at'] as String),
        heroScore = m['hero_score'] as int?,
        isHero = m['is_hero'] as bool?,
        heroOrder = m['hero_order'] as int?,
        heroPinnedAt = m['hero_pinned_at'] == null
            ? null
            : DateTime.parse(m['hero_pinned_at'] as String),
        topic = m['topic'] as String?,
        region = m['region'] as String?;

  final String id;
  final String title;
  final String? imageUrl;
  final DateTime createdAt;
  final int? heroScore;
  final bool? isHero;
  final int? heroOrder;
  final DateTime? heroPinnedAt;
  final String? topic;
  final String? region;
}

const maxBoosted = 3;

double rejuvenation(A a, DateTime now) {
  final sincePin = now.difference(a.heroPinnedAt ?? a.createdAt).inMinutes / 60;
  if (sincePin <= 0) return 0;
  final order = (a.heroOrder ?? 5).clamp(1, 10);
  final grace = pinGrace * (1.0 - 0.6 * (order - 1) / 9.0);
  return math.max(0.0, sincePin - grace);
}

Set<String> boostedIds(List<A> articles, DateTime now) {
  final flagged = articles.where((a) => a.isHero == true).toList()
    ..sort((a, b) => rejuvenation(a, now).compareTo(rejuvenation(b, now)));
  return flagged.take(maxBoosted).map((a) => a.id).toSet();
}

double pinWeight(A a) {
  final order = (a.heroOrder ?? 5).clamp(1, 10);
  return 1.0 - 0.35 * (order - 1) / 9.0;
}

bool _science(A a) {
  final t = a.topic?.toLowerCase().trim() ?? '';
  return t == 'tarım-bilim' || t == 'yyt';
}

bool _turkey(A a) => (a.region?.toLowerCase().trim() ?? '') == 'türkiye';

bool _world(A a) {
  final r = a.region?.toLowerCase().trim() ?? '';
  return r == 'dünya' || r == 'uluslararası' || r == 'küresel';
}

List<A> hero(List<A> articles, int seed, Set<String> readIds, DateTime now) {
  final withImages =
      articles.where((a) => a.imageUrl != null && a.imageUrl!.isNotEmpty).toList();
  if (withImages.isEmpty) return [];

  final boosted = boostedIds(withImages, now);
  final youngest = withImages
      .map((a) => now.difference(a.createdAt).inMinutes / 60)
      .reduce(math.min);
  final scores = <String, double>{};
  for (final a in withImages) {
    final ageHours = now.difference(a.createdAt).inMinutes / 60;
    final eff = boosted.contains(a.id)
        ? math.min(ageHours, math.max(youngest, rejuvenation(a, now)))
        : ageHours;
    double s = (a.heroScore ?? 5) / math.pow(eff + 1, 0.8);
    if (boosted.contains(a.id)) s *= pinWeight(a);
    if (readIds.contains(a.id)) {
      s *= 0.1;
    } else if (ageHours < 24 * 7) {
      final r = math.Random(seed ^ a.id.hashCode);
      s *= 0.85 + 0.30 * r.nextDouble();
    }
    scores[a.id] = s;
  }
  double scoreOf(A a) => scores[a.id] ?? 0;

  final out = <A>[];
  final used = <String>{};

  final remaining = withImages.toList()
    ..sort((a, b) => scoreOf(b).compareTo(scoreOf(a)));

  final sci = <A>[], wor = <A>[], tur = <A>[], gen = <A>[];
  for (final a in remaining) {
    if (_science(a)) {
      sci.add(a);
    } else if (_world(a) && !_turkey(a)) {
      wor.add(a);
    } else if (_turkey(a)) {
      tur.add(a);
    } else {
      gen.add(a);
    }
  }

  void fill(List<A> bucket, int quota) {
    for (final a in bucket) {
      if (out.length >= heroLimit || quota <= 0) return;
      if (!used.add(a.id)) continue;
      out.add(a);
      quota--;
    }
  }

  fill(sci, 1);
  fill(wor, 2);
  fill(tur, 6);
  fill(gen, heroLimit);
  fill(remaining, heroLimit);
  out.sort((a, b) => scoreOf(b).compareTo(scoreOf(a)));
  return out;
}

double youngestOf(List<A> a, DateTime now) => a
    .where((x) => x.imageUrl != null && x.imageUrl!.isNotEmpty)
    .map((x) => now.difference(x.createdAt).inMinutes / 60)
    .reduce(math.min);

String _short(A a) => a.title.length > 42 ? a.title.substring(0, 42) : a.title;
int _age(A a, DateTime now) => now.difference(a.createdAt).inHours;

Future<void> main() async {
  final uri = Uri.https(_base, '/rest/v1/articles', {
    'select':
        'id,title,status,image_url,created_at,hero_score,is_hero,hero_order,hero_pinned_at,topic,region',
    'status': 'eq.published',
    'order': 'created_at.desc',
    'limit': '300',
  });
  final client = HttpClient();
  final req = await client.getUrl(uri);
  req.headers.set('apikey', _key);
  req.headers.set('Authorization', 'Bearer $_key');
  final res = await req.close();
  final body = await res.transform(utf8.decoder).join();
  client.close();

  final articles =
      (jsonDecode(body) as List).map((m) => A(m as Map<String, dynamic>)).toList();
  final now = DateTime.now();
  print('${articles.length} yayınlanmış haber\n');

  // 1) Ziyaret içi sabitlik
  final a1 = hero(articles, 12345, {}, now).map((a) => a.id).join(',');
  final a2 = hero(articles, 12345, {}, now).map((a) => a.id).join(',');
  print('${a1 == a2 ? '✓' : '✗'} Aynı tohum aynı sırayı veriyor');

  // 2) Ziyaretler arası tazelenme
  final rnd = math.Random(7);
  final seeds = List.generate(6, (_) => rnd.nextInt(1 << 31));
  final lists = seeds.map((s) => hero(articles, s, {}, now)).toList();

  print('\nAyrı ziyaretlerde manşetin ilk 6 sırası:');
  for (var i = 0; i < lists.length; i++) {
    print('  ziyaret ${i + 1}');
    for (var j = 0; j < 6 && j < lists[i].length; j++) {
      final a = lists[i][j];
      print('     ${j + 1}. [${_age(a, now)}s] ${_short(a)}');
    }
  }

  final firsts = lists.map((l) => l.first.id).toSet();
  final base = lists.first.map((a) => a.id).toSet();
  final overlap =
      lists.skip(1).map((l) => l.where((a) => base.contains(a.id)).length).toList();
  final positionChanged = lists.skip(1).map((l) {
    var n = 0;
    for (var i = 0; i < l.length && i < lists.first.length; i++) {
      if (l[i].id != lists.first[i].id) n++;
    }
    return n;
  }).toList();

  print('\n  farklı 1. sıra: ${firsts.length}/${lists.length}');
  print('  1. ziyaretle aynı haberler: ${overlap.join(', ')}/$heroLimit');
  print('  yeri değişen sıra sayısı:   ${positionChanged.join(', ')}/$heroLimit');

  final ages = lists.map((l) => _age(l.first, now)).toList();
  final oldest = lists.expand((l) => l).map((a) => _age(a, now)).reduce(math.max);
  print('  1. sıradaki haberin yaşı:   ${ages.join(', ')} saat'
      '  (manşetteki en eski: $oldest saat)');

  // 3) Okunan haber
  final topId = lists.first.first.id;
  final after = hero(articles, seeds.first, {topId}, now);
  final pos = after.indexWhere((a) => a.id == topId);
  print('\n${pos != 0 ? '✓' : '✗'} Okunan 1. haber geri düştü: '
      '${pos == -1 ? 'manşetten çıktı' : '${pos + 1}. sıraya indi'}');

  final readAll = lists.first.take(5).map((a) => a.id).toSet();
  final after5 = hero(articles, seeds.first, readAll, now);
  final stillTop = after5.take(5).where((a) => readAll.contains(a.id)).length;
  print('  ilk 5 okunduğunda yerinde kalan: $stillTop/5');

  // 4) Editör itkisi: kalıcı kilit değil, eriyen bir çarpan.
  final flagged = articles.where((a) => a.isHero == true).toList()
    ..sort((a, b) => rejuvenation(a, now).compareTo(rejuvenation(b, now)));
  final boosted = boostedIds(
      articles.where((a) => a.imageUrl != null && a.imageUrl!.isNotEmpty).toList(),
      now);
  double realAge(A a) => now.difference(a.createdAt).inMinutes / 60;
  print('\n  is_hero işaretli: ${flagged.length}'
      '   itki alan: ${boosted.length} (en fazla $maxBoosted)');
  for (final a in flagged.take(6)) {
    final p = lists.first.indexWhere((x) => x.id == a.id);
    final on = boosted.contains(a.id);
    print('     order=${(a.heroOrder ?? '-').toString().padLeft(2)}'
        '  yaş ${realAge(a).round()}s → sayılan'
        ' ${(on ? math.min(realAge(a), math.max(youngestOf(articles, now), rejuvenation(a, now))) : realAge(a)).round()}s'
        '${on ? '  ●itkili' : '  ○itkisiz'}'
        ' → ${p == -1 ? 'manşette YOK' : '${p + 1}. sıra'}   ${_short(a)}');
  }
  final stale = flagged.where((a) => rejuvenation(a, now) > 48).length;
  print('     … $stale bayat işaret kendiliğinden sönmüş');

  // İtki okuma cezasını yenmemeli: editörün öne aldığı haber okunduysa geri
  // düşmeli, yoksa "sistem kullanıcı davranışına göre üstüne yazar" iddiası
  // boşa çıkar.
  final topPinned = flagged.where((a) {
    final p = lists.first.indexWhere((x) => x.id == a.id);
    return p != -1 && p < 3;
  }).toList();
  if (topPinned.isNotEmpty) {
    final t = topPinned.first;
    final before = lists.first.indexWhere((x) => x.id == t.id);
    final afterList = hero(articles, seeds.first, {t.id}, now);
    final afterPos = afterList.indexWhere((x) => x.id == t.id);
    print('\n${afterPos == -1 || afterPos > before ? '✓' : '✗'}'
        ' Okunan sabitli haber geri düştü:'
        ' ${before + 1}. → ${afterPos == -1 ? 'manşetten çıktı' : '${afterPos + 1}.'}');
  }

  // 5) Yeni çekim: havuz her toplamada büyüyor. Yeni haberler manşete kendi
  //    tazelik puanlarıyla girmeli — kıpırtı onları geride bırakmamalı.
  print('\nYeni çekim simülasyonu (10 haberlik parti, 0 saatlik):');
  final batch = List.generate(10, (i) {
    final base = articles.first;
    return A({
      'id': 'yeni-parti-$i',
      'title': 'YENİ $i',
      'status': 'published',
      'image_url': base.imageUrl,
      'created_at': now.subtract(const Duration(minutes: 5)).toIso8601String(),
      'hero_score': [8, 8, 8, 7, 7, 7, 5, 5, 5, 5][i],
      'is_hero': null,
      'hero_order': null,
      'topic': null,
      'region': i.isEven ? 'türkiye' : 'dünya',
    });
  });
  final grown = [...batch, ...articles];
  for (var v = 0; v < 3; v++) {
    final l = hero(grown, seeds[v], {}, now);
    final placed = l.where((a) => a.id.startsWith('yeni-parti-')).length;
    final firstNew = l.indexWhere((a) => a.id.startsWith('yeni-parti-'));
    print('  ziyaret ${v + 1}: manşetteki yeni haber ${placed}/$heroLimit,'
        ' ilki ${firstNew == -1 ? 'yok' : '${firstNew + 1}.'} sırada'
        '   →  ${l.take(6).map((a) => a.id.startsWith('yeni-parti-') ? 'YENİ' : 'eski').join(' ')}');
  }
}
