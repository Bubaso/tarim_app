import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/supabase_client.dart';
import '../../../core/utils/iso_week.dart';
import '../../../core/utils/localization_helper.dart';
import '../data/models/ai_suggestion.dart';
import '../data/models/news_article.dart';
import '../data/models/weather_info.dart';
import '../data/models/market_data.dart';
import '../data/repositories/home_repository.dart';
import 'hero_rotation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return HomeRepository(supabaseClient);
});

final initialReadArticlesProvider = FutureProvider<Set<String>>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final list = prefs.getStringList('read_articles') ?? [];
  return list.toSet();
});

class ReadArticlesNotifier extends Notifier<Set<String>> {
  static const _key = 'read_articles';

  @override
  Set<String> build() {
    // Get initial state from the FutureProvider if available
    final initial = ref.watch(initialReadArticlesProvider).valueOrNull;
    return initial ?? {};
  }

  Future<void> markAsRead(String id) async {
    if (state.contains(id)) return;
    
    final newState = {...state, id};
    state = newState;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, newState.toList());
  }
}

final readArticlesProvider = NotifierProvider<ReadArticlesNotifier, Set<String>>(ReadArticlesNotifier.new);

/// Stream provider for realtime listening to articles from Supabase.
final latestArticlesProvider = StreamProvider<List<NewsArticle>>((ref) {
  final repository = ref.watch(homeRepositoryProvider);
  return repository.watchLatestArticles();
});

/// "Son Okuduklarınız" şeridinde gösterilecek en fazla haber sayısı.
const _recentlyReadLimit = 10;

/// Okuyucunun en son okuduğu haberler — yeniden eskiye.
///
/// Manşetteki okuma cezası okunmuş haberi bilinçli olarak geriye itiyor; bu
/// şerit onun karşılığı: "gördüğüm haberi bir daha bulamıyorum" şikâyetinin
/// asıl cevabı burada. Ceza haberi listeden düşürüyor, şerit onu geri getiriyor.
///
/// Yeni depolama yok: `read_articles` zaten ekleme sırasını koruyan bir liste
/// olarak diskte duruyor, sondan başa okumak "en son okunan" demek.
///
/// Manşetten farklı olarak **canlı** [readArticlesProvider] kullanılıyor —
/// okunan haber şeride hemen düşsün diye. (Manşet oturum başı anlık görüntüyü
/// kullanıyor ki liste okuyucunun gözü önünde yeniden dizilmesin.)
final recentlyReadArticlesProvider = Provider<List<NewsArticle>>((ref) {
  final readIds = ref.watch(readArticlesProvider);
  if (readIds.isEmpty) return const [];

  final articles = ref.watch(latestArticlesProvider).valueOrNull;
  if (articles == null) return const [];

  final byId = {for (final a in articles) a.id: a};

  // Havuzdan düşmüş (silinmiş ya da yayından kaldırılmış) kimlikler eleniyor.
  return readIds.toList().reversed
      .map((id) => byId[id])
      .whereType<NewsArticle>()
      .take(_recentlyReadLimit)
      .toList();
});

/// Okunan haberin ardından önerilecek tek haber ("Sonraki haber" kartı).
///
/// Amaç okumayı sürdürmek: önce aynı konudan devam etmeye çalışır, olmazsa
/// gündeme döner. Görseli olmayan haberler elenir — kart 16:9 görselin üstüne
/// kurulu, görselsiz hâli boş bir kutu olurdu.
///
/// Burada [initialReadArticlesProvider] değil **canlı** [readArticlesProvider]
/// kullanılıyor. Ana sayfadaki sıralama providerları bilinçli olarak oturum
/// başı anlık görüntüyü okuyor (liste okuyucunun gözü önünde yeniden
/// dizilmesin diye); burada amaç tam tersi: zincirleme okumada az önce
/// bitirilen haber tekrar önerilmemeli.
final nextArticleProvider =
    Provider.family<NewsArticle?, String>((ref, currentId) {
  final articles = ref.watch(latestArticlesProvider).valueOrNull;
  if (articles == null) return null;

  // Liste yeniden eskiye sıralı; aşağıdaki "ilk eşleşen" aramaları bu sıraya
  // dayanıyor.
  final pool = articles
      .where((a) =>
          a.status == 'published' &&
          a.imageUrl != null &&
          a.imageUrl!.isNotEmpty)
      .toList();
  if (pool.isEmpty) return null;

  final readIds = ref.watch(readArticlesProvider);
  bool eligible(NewsArticle a) => a.id != currentId && !readIds.contains(a.id);

  final currentIndex = pool.indexWhere((a) => a.id == currentId);

  // Konu anahtarı: pipeline'dan gelen `topic` varsa o, yoksa kategori.
  String? keyOf(NewsArticle a) {
    final t = a.topic?.trim();
    if (t != null && t.isNotEmpty) return t.toLowerCase();
    final c = a.categoryId?.trim();
    if (c != null && c.isNotEmpty) return c;
    return null;
  }

  final currentKey = currentIndex == -1 ? null : keyOf(pool[currentIndex]);

  if (currentKey != null) {
    // 1. Aynı konudan bir sonraki (daha eski) haber — dosyayı takip etmek.
    for (var i = currentIndex + 1; i < pool.length; i++) {
      if (keyOf(pool[i]) == currentKey && eligible(pool[i])) return pool[i];
    }
    // 2. Aynı konudan en yeni okunmamış haber.
    for (final a in pool) {
      if (keyOf(a) == currentKey && eligible(a)) return a;
    }
  }

  // 3. Genel havuzdan en yeni okunmamış haber.
  for (final a in pool) {
    if (eligible(a)) return a;
  }

  // 4. Her şey okunmuşsa kartı gizlemek yerine en yeni habere yönlendir.
  for (final a in pool) {
    if (a.id != currentId) return a;
  }
  return null;
});

/// Bir ISO haftasında yayımlanan haberler (`/hafta/:slug`).
///
/// `family` anahtarı [IsoWeek]; sınıf değer eşitliği taşıdığı için aynı hafta
/// iki kez istendiğinde sorgu tekrarlanmıyor.
///
/// Sıralama bilinçli olarak burada değil sunum katmanında: bu provider yalnızca
/// haftanın penceresini getirir, "öne çıkan hangisi" ayrı bir karar.
final weeklyRecapProvider =
    FutureProvider.family<List<NewsArticle>, IsoWeek>((ref, week) {
  final repository = ref.watch(homeRepositoryProvider);
  return repository.fetchArticlesBetween(week.startUtc, week.endUtc);
});

/// Fetches a single article by id — used for `/haber/:id` deep links.
final articleByIdProvider =
    FutureProvider.family<NewsArticle?, String>((ref, id) {
  final repository = ref.watch(homeRepositoryProvider);
  return repository.fetchArticleById(id);
});

/// Stream provider for realtime listening to pending articles from Supabase.
final pendingArticlesProvider = StreamProvider<List<NewsArticle>>((ref) {
  final repository = ref.watch(homeRepositoryProvider);
  return repository.watchPendingArticles();
});

// ─── KAYNAK / TAKSONOMİ SINIFLANDIRMA ─────────────────────────────────────────
//
// Sınıflandırma artık kaynak adı listelerine değil, pipeline'ın yazdığı
// `topic` ve `region` alanlarına bakarak yapılıyor.

/// Haberin bilim/rapor içeriği olup olmadığını kontrol eder.
bool _articleIsScience(NewsArticle a) {
  final t = a.topic?.toLowerCase().trim() ?? '';
  return t == 'tarım-bilim' || t == 'yyt';
}

/// Haberin Türkiye odaklı olup olmadığını kontrol eder.
bool _articleIsTurkey(NewsArticle a) {
  final r = a.region?.toLowerCase().trim() ?? '';
  return r == 'türkiye';
}

/// Haberin uluslararası (Dünya) odaklı olup olmadığını kontrol eder.
bool _articleIsWorld(NewsArticle a) {
  final r = a.region?.toLowerCase().trim() ?? '';
  return r == 'dünya' || r == 'uluslararası' || r == 'küresel';
}

// ─── PORTAL SECTION PROVIDERS ──────────────────────────────────────────────────

// ─── EDİTÖR İTKİSİ ────────────────────────────────────────────────────────────
//
// Manşete kimin çıkacağına ve hangi sırada duracağına sistem karar veriyor.
// `is_hero` bir kilit değil, skoru çarpan bir itki: editör "şunu öne al" der,
// sistem bunu diğer sinyallerle (tazelik, editör puanı, okuma durumu) birlikte
// tartar ve gerekirse üstüne yazar.
//
// Sabitlemenin sert olduğu hâli denedik ve kırılgan çıktı: işaret elle konuyor,
// kaldırılması unutuluyor; panelde 21 işaretli haber birikmişti, en eskisi 40
// günlüktü. Süresiz kilit demek manşetin ilk sırasında aylık bir haber demekti.
// Raf ömrü koymak da yetmiyordu — ömür dolana kadar sıra yine donuyordu.

// İtki skoru ÇARPMIYOR, haberin YAŞINI geriye alıyor. Çarpan denendi ve
// ölçeklenmedi: taban skor `hero_score/(yaş+1)^0.8` iki büyüklük mertebesine
// yayılıyor (canlı veride medyan 0.131, manşete girme eşiği 1.908), dolayısıyla
// aynı işaret 30 saatlik haberde 3.7x, 143 saatlikte 12.7x gerektiriyordu —
// tek bir sabit ikisine birden hizmet edemez.
//
// Yaşı geriye almak hem editörün kastettiği şey ("bunu bugünün haberi say")
// hem de kendiliğinden ölçekli: çarpan yok, kalibrasyon sabiti yok.

/// İtkinin haberi "az önce yayımlanmış" saydığı süre (`hero_order` = 1 için).
///
/// Bu süre boyunca haber manşetin başında durur, sonra normal yaşlanmaya geçer:
/// 6 saatlik itkiden 24 saat sonra 18 saatlik bir haber gibi davranır, bir gün
/// içinde manşetten düşer. Müdahale "o an" geçerli olur, imtiyaza dönüşmez —
/// unutulan eski işaretler de bu yüzden kendiliğinden zararsızlaşıyor.
///
/// Süre `hero_order` ile 6 saatten 2.4 saate iniyor: editörün 1. sıraya koyduğu
/// haber en uzun, 10. sıraya koyduğu en kısa tutunur.
const _heroPinGrace = 6.0;

/// Aynı anda itki alabilecek en fazla haber sayısı.
///
/// Panel `hero_order`ı 1-10 arası yazdırdığı için editör alışkanlıkla manşetin
/// onunu birden işaretliyor; itkinin hepsine verilmesi rotasyonu öldürüyordu
/// (ölçümde ayrı ziyaretlerde farklı ilk sıra 5/6'dan 2/6'ya düşüyordu). Üçle
/// sınırlamak müdahaleyi "nadir ve küçük" tutuyor: geri kalan işaretler
/// yok sayılmıyor, sadece normal yaşlarıyla yarışıyorlar.
const _heroMaxBoosted = 3;

/// Manşetin kıpırtıya KAPALI tepe bölgesi.
///
/// Kıpırtı (±%15) bu sıraların dışında kalıyor. Amaç okuyucunun şikâyet ettiği
/// şey: gördüğü haberi tekrar aradığında ilk kartların yerinde durması. Taban
/// skor tohumdan bağımsız olduğu için bu üç sıra ziyaretten ziyarete DEĞİŞMEZ;
/// yalnızca haberler yaşlandıkça ya da yeni haber girdikçe değişir.
///
/// Kuyruk (4-10) eskisi gibi karışmaya devam ediyor: rotasyonun asıl işlevi
/// olan "her ziyarette farklı haberler görme" orada korunuyor.
const _heroStableTop = 3;

/// Okunmuş haberin skoruna uygulanan çarpan.
///
/// Önceden 0.1'di ve haberi manşetten tamamen siliyordu; okuduğu bir habere
/// geri dönmek isteyen okuyucunun ana sayfada onu bulmasının hiçbir yolu
/// kalmıyordu. 0.35 aynı işi daha yumuşak yapıyor: okunan haber belirgin
/// biçimde geriye düşüyor ama listeden yok olmuyor.
///
/// Not: geri dönüşün asıl yolu artık ana sayfadaki "Son Okuduklarınız" şeridi.
/// Bu çarpan yalnızca manşetin kendini tekrar etmesini engelliyor.
const _readPenalty = 0.35;

/// İtkinin haberi kaç saat gençleştirdiği.
double _heroPinRejuvenation(NewsArticle a, DateTime now) {
  final sincePin = now.difference(a.heroPinnedAt ?? a.createdAt).inMinutes / 60;
  // Damga ileri tarihliyse (cihaz saati geride) itki tam kabul edilir.
  if (sincePin <= 0) return 0;
  final order = (a.heroOrder ?? 5).clamp(1, 10);
  final grace = _heroPinGrace * (1.0 - 0.6 * (order - 1) / 9.0);
  return math.max(0.0, sincePin - grace);
}

/// İtkiyi hak eden haberlerin kimlikleri.
///
/// Sıralama "itkisi en diri olan" ölçütüne göre: en son yapılan müdahale ve o
/// müdahale içinde editörün öne koyduğu sıra kazanır. Eski, unutulmuş işaretler
/// zaten listenin sonuna düşüyor.
///
/// [NewsArticle.heroPinnedAt] yoksa `createdAt`e düşülüyor: kolonun eklendiği
/// göçten önce işaretlenmiş satırlar için tek makul çıpa o (göç bu satırları
/// `updated_at`ten geriye doldurur).
Set<String> _heroBoostedIds(List<NewsArticle> articles, DateTime now) {
  final flagged = articles.where((a) => a.isHero == true).toList()
    ..sort((a, b) =>
        _heroPinRejuvenation(a, now).compareTo(_heroPinRejuvenation(b, now)));
  return flagged.take(_heroMaxBoosted).map((a) => a.id).toSet();
}

/// İtki yürürlükteyken `hero_order`ın kendi arasındaki sıralaması.
///
/// İtkinin ilk saatlerinde işaretli haberlerin hepsi "sıfır yaşlı" göründüğü
/// için aralarındaki sırayı yaş ayıramaz. Dar bir çarpan (%35) editörün
/// tercihini kendi seçtikleri arasında geçerli kılar; işaretsiz haberlere göre
/// bir avantaj yaratacak kadar büyük değil.
double _heroPinWeight(NewsArticle a) {
  final order = (a.heroOrder ?? 5).clamp(1, 10);
  return 1.0 - 0.35 * (order - 1) / 9.0;
}

/// Manşet haberleri (Hero Section)
/// Tüm yayınlanmış, görseli olan haberler — zaman-ağırlıklı skor ile sıralı.
/// Türkiye haberleri ağırlıklı, dünyadan 1-2, bilim/rapor 1 adet.
///
/// Sıra bir ziyaret boyunca sabittir (bkz. [heroSeedProvider]): sayfalar
/// arasında gezinip geri dönen okuyucu listeyi yerinde bulur. Ziyaret
/// değiştiğinde tohum yenilenir ve sıra tazelenir.
final heroArticlesProvider = Provider<List<NewsArticle>>((ref) {
  final articlesAsync = ref.watch(latestArticlesProvider);

  // Ziyaret tohumu: sıralamayı ziyaret boyunca sabit tutan tek kaynak.
  final seed = ref.watch(heroSeedProvider);

  // Okuma durumunun ziyaret başındaki anlık görüntüsü.
  // Böylece uygulama içindeyken okunan haberler sıralamayı anında DEĞİŞTİRMEZ;
  // liste okuyucunun gözü önünde yeniden dizilmez.
  final initialReadIds = ref.watch(initialReadArticlesProvider).valueOrNull ?? {};

  return articlesAsync.when(
    data: (articles) {
      // Sadece published + görseli olan haberler
      final withImages = articles.where((a) =>
          a.status == 'published' &&
          a.imageUrl != null &&
          a.imageUrl!.isNotEmpty).toList();

      if (withImages.isEmpty) return [];

      // Skorlar tek seferde hesaplanıyor. Önceden karşılaştırıcının içindeydi:
      // her kıyasta `DateTime.now()` okunuyordu ve saat sınırını geçen bir
      // sıralamada aynı çiftin iki farklı yanıt vermesi mümkündü.
      final now = DateTime.now();
      final boostedIds = _heroBoostedIds(withImages, now);

      // İtkinin tavanı: havuzdaki EN TAZE haberin yaşı. Editörün müdahalesi
      // eski bir haberi "bugünün haberi" saydırabilir, bugünün haberinden daha
      // taze saydıramaz.
      //
      // Tavan olmadan işaretli haber taze havuzun ÜSTÜNE çıkıyordu ve puan
      // farkı kıpırtının (±%15) kapatamayacağı kadar açılıyordu: ölçümde dört
      // ziyaretin dördünde de lider kart aynı haberdi. Yani manşetin ilk sırası
      // yeniden kilitleniyordu — düzeltmeye çalıştığımız sorunun ta kendisi.
      // Hizaya çekilen haber taze partiyle aynı kümede yarışıyor: manşete
      // giriyor ama sırası ziyaretten ziyarete değişiyor.
      final youngest = withImages
          .map((a) => now.difference(a.createdAt).inMinutes / 60)
          .reduce(math.min);

      // ── 1. geçiş: kıpırtısız taban skorlar ────────────────────────────
      // Taban skor TOHUMDAN BAĞIMSIZ. Bu, aşağıdaki sabit tepe bölgesinin
      // ziyaretten ziyarete değişmemesini sağlayan şey.
      final base = <String, double>{};
      for (final a in withImages) {
        final ageHours = now.difference(a.createdAt).inMinutes / 60;

        // İtki haberi kendi gerçek yaşından DAHA YAŞLI gösteremez: `min` şart.
        final effectiveAge = boostedIds.contains(a.id)
            ? math.min(
                ageHours, math.max(youngest, _heroPinRejuvenation(a, now)))
            : ageHours;

        double s = (a.heroScore ?? 5) / math.pow(effectiveAge + 1, 0.8);
        if (boostedIds.contains(a.id)) s *= _heroPinWeight(a);

        // Okuma cezası itkiden SONRA geliyor: editörün öne aldığı haber
        // okunduysa kendi işaretsiz hâlinin de altına düşer. Kullanıcının
        // davranışı editörün kararını geçersiz kılar.
        if (initialReadIds.contains(a.id)) s *= _readPenalty;

        base[a.id] = s;
      }

      // ── 2. geçiş: kıpırtı YALNIZCA kuyruğa ────────────────────────────
      final ranked = withImages.toList()
        ..sort((a, b) => (base[b.id] ?? 0).compareTo(base[a.id] ?? 0));

      final stableCount = math.min(_heroStableTop, ranked.length);
      final stableIds = ranked.take(stableCount).map((a) => a.id).toSet();

      // Kuyruğun tavanı: sabit bölgenin en düşük skorunun hemen altı. Kıpırtı
      // en fazla 1.15x çarpabildiği için bu tavan olmadan 4. sıradaki haber
      // 3.'yü geçebilir ve "tepe sabit" sözü tutulmazdı.
      final ceiling = stableCount > 0
          ? (base[ranked[stableCount - 1].id] ?? 0) * 0.999
          : double.infinity;

      final scores = <String, double>{};
      for (final a in withImages) {
        final s = base[a.id] ?? 0;
        final ageHours = now.difference(a.createdAt).inMinutes / 60;

        // Sabit bölge, okunmuşlar ve bir haftadan eskiler kıpırdamıyor.
        if (stableIds.contains(a.id) ||
            initialReadIds.contains(a.id) ||
            ageHours >= 24 * 7) {
          scores[a.id] = s;
          continue;
        }

        // Kıpırtı çarpımsal ve dar (±%15). Önceki hâli 0-4.0 arası TOPLAMSAL
        // bir bonustu; ölçülen taban skorlar 0.13-2.43 aralığında olduğu için
        // rastgelelik hem editör puanını hem tazeliği eziyordu — bir haftalık
        // haber üç saatlik haberi düzenli olarak geçebiliyordu. Çarpımsal
        // biçim sıralamayı yalnızca yakın rakipler arasında karıştırır.
        final r = math.Random(seed ^ a.id.hashCode);
        scores[a.id] = math.min(s * (0.85 + 0.30 * r.nextDouble()), ceiling);
      }

      double scoreOf(NewsArticle a) => scores[a.id] ?? 0;

      const int heroLimit = 10;
      final List<NewsArticle> hero = [];
      final used = <String>{};

      // Kotalar manşetin BİLEŞİMİNİ belirliyor: en az bir bilim, en çok iki
      // dünya haberi gibi. Sıraya karışmıyorlar — liste en sonda skora göre
      // diziliyor.
      final remaining = withImages.toList()
        ..sort((a, b) => scoreOf(b).compareTo(scoreOf(a)));

      final turkeyBucket = <NewsArticle>[];
      final worldBucket = <NewsArticle>[];
      final scienceBucket = <NewsArticle>[];
      final generalBucket = <NewsArticle>[];

      for (final a in remaining) {
        final isScience = _articleIsScience(a);
        final isTurkey = _articleIsTurkey(a);
        final isWorld = _articleIsWorld(a);

        if (isScience) {
          scienceBucket.add(a);
        } else if (isWorld && !isTurkey) {
          worldBucket.add(a);
        } else if (isTurkey) {
          turkeyBucket.add(a);
        } else {
          generalBucket.add(a);
        }
      }

      void fill(List<NewsArticle> bucket, int quota) {
        for (final a in bucket) {
          if (hero.length >= heroLimit || quota <= 0) return;
          if (!used.add(a.id)) continue;
          hero.add(a);
          quota--;
        }
      }

      fill(scienceBucket, 1);
      fill(worldBucket, 2);
      fill(turkeyBucket, 6);
      fill(generalBucket, heroLimit);
      // Kotalar dolmadıysa (örneğin hiç Türkiye haberi yoksa) kalanlar skor
      // sırasıyla tamamlar.
      fill(remaining, heroLimit);

      // Seçim bittikten sonra sıralama yeniden skora bırakılıyor. Aksi hâlde
      // kotaların doldurulma sırası manşetin sırası olurdu ve ilk kart hep
      // bilim haberi olarak sabitlenirdi.
      hero.sort((a, b) => scoreOf(b).compareTo(scoreOf(a)));

      return hero;
    },
    loading: () => [],
    error: (e, s) => [],
  );
});

/// ICYMI (In Case You Missed It) / Gözden Kaçanlar
/// Strateji 5: Kullanıcının okumadığı, son 1-7 gün arası kaliteli içerikler.
final icymiArticlesProvider = Provider<List<NewsArticle>>((ref) {
  final articlesAsync = ref.watch(latestArticlesProvider);
  final readIds = ref.watch(readArticlesProvider);

  return articlesAsync.when(
    data: (articles) {
      final now = DateTime.now();
      
      final icymi = articles.where((a) {
        if (a.status != 'published') return false;
        if (a.imageUrl == null || a.imageUrl!.isEmpty) return false;
        if (readIds.contains(a.id)) return false; // Okunmamış olmalı
        
        // Sadece son 1-7 gün arasındaki haberler
        final ageHours = now.difference(a.createdAt).inHours;
        return ageHours > 12 && ageHours < (7 * 24);
      }).toList();

      if (icymi.isEmpty) return [];

      // Hero score'a göre yüksekten düşüğe sırala
      icymi.sort((a, b) => (b.heroScore ?? 0).compareTo(a.heroScore ?? 0));
      
      // En iyi 4'ünü al
      return icymi.take(4).toList();
    },
    loading: () => [],
    error: (e, s) => [],
  );
});

/// Türkiye'den Haberler
/// Sadece region (bölge) alanının Türkiye olup olmadığına bakar.
final turkeyNewsProvider = Provider<List<NewsArticle>>((ref) {
  final articlesAsync = ref.watch(latestArticlesProvider);
  return articlesAsync.when(
    data: (articles) {
      return articles.where((a) {
        if (a.status != 'published') return false;
        return _articleIsTurkey(a);
      }).toList();
    },
    loading: () => [],
    error: (e, s) => [],
  );
});

/// Seçtiğimiz Makaleler (Özel Kürasyon - MNT)
final curatedArticlesProvider = Provider<List<NewsArticle>>((ref) {
  final articlesAsync = ref.watch(latestArticlesProvider);
  return articlesAsync.when(
    data: (articles) {
      return articles.where((a) {
        if (a.status != 'published') return false;
        return a.sourceName?.toLowerCase() == 'medical news today';
      }).toList();
    },
    loading: () => [],
    error: (e, s) => [],
  );
});

/// Dünyadan Haberler (Türkiye dışı)
/// Sadece region (bölge) alanının Dünya olup olmadığına bakar.
final worldNewsProvider = Provider<List<NewsArticle>>((ref) {
  final articlesAsync = ref.watch(latestArticlesProvider);
  return articlesAsync.when(
    data: (articles) {
      return articles.where((a) {
        if (a.status != 'published') return false;
        return _articleIsWorld(a);
      }).toList();
    },
    loading: () => [],
    error: (e, s) => [],
  );
});

/// Özel Dosya: Tarım & Bilim (Raporlar, Analizler, Bilim Haberleri)
final scienceAndReportsProvider = Provider<List<NewsArticle>>((ref) {
  final articlesAsync = ref.watch(latestArticlesProvider);
  return articlesAsync.when(
    data: (articles) {
      return articles.where((a) {
        if (a.status != 'published') return false;
        return _articleIsScience(a);
      }).toList();
    },
    loading: () => [],
    error: (e, s) => [],
  );
});

/// Sektörel / Kategori Bazlı Haberler
/// topic alanı (pipeline'dan gelen taxonomy) önce kontrol edilir.
/// topic boşsa başlık + özet üzerinden kesin anahtar kelime eşleşmesi yapılır.
/// Her haber yalnızca ilk eşleşen kategoriye girer — çakışma olmaz.
final categoryArticlesProvider = Provider.family<List<NewsArticle>, String>((ref, topic) {
  final articlesAsync = ref.watch(latestArticlesProvider);
  return articlesAsync.when(
    data: (articles) {
      final searchTopic = topic.toLowerCase().trim();

      return articles.where((a) {
        if (a.status != 'published') return false;
        final articleTopic = a.topic?.toLowerCase().trim() ?? '';
        return articleTopic == searchTopic;
      }).toList();
    },
    loading: () => [],
    error: (e, s) => [],
  );
});

class LocationData {
  final String name;
  final double latitude;
  final double longitude;

  const LocationData({
    required this.name,
    required this.latitude,
    required this.longitude,
  });
}

class ActiveLocationNotifier extends Notifier<LocationData> {
  bool _hasAttemptedDetection = false;

  @override
  LocationData build() {
    if (!_hasAttemptedDetection) {
      _hasAttemptedDetection = true;
      Future.microtask(_detectLocation);
    }
    return const LocationData(
      name: 'Polatlı, Ankara',
      latitude: 39.58,
      longitude: 32.14,
    );
  }

  void update(LocationData value) {
    state = value;
  }

  Future<void> _detectLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 5),
      );

      final isEn = ref.read(localeProvider).languageCode == 'en';
      String name = isEn ? 'GPS Location' : 'GPS Konumu';
      
      try {
        final res = await http.get(
          Uri.parse('https://nominatim.openstreetmap.org/reverse?lat=${position.latitude}&lon=${position.longitude}&format=json&accept-language=${isEn ? "en" : "tr"}'),
          headers: {'User-Agent': 'tarim_app_agent'},
        ).timeout(const Duration(seconds: 3));
        
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          final address = data['address'];
          if (address != null) {
            name = address['suburb'] ?? address['town'] ?? address['district'] ?? address['city'] ?? address['province'] ?? name;
            final prov = address['province'] ?? address['state'] ?? '';
            if (prov.isNotEmpty && !name.contains(prov)) {
              name = '$name, $prov';
            }
          }
        }
      } catch (_) {}

      state = LocationData(
        name: name,
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (_) {
      // Ignore errors, keep default location
    }
  }
}

/// State provider for tracking active weather location. Defaults to Polatlı, Ankara.
final activeLocationProvider = NotifierProvider<ActiveLocationNotifier, LocationData>(
  ActiveLocationNotifier.new,
);

/// Future provider for fetching agricultural weather info, reacting to locale & location changes.
final weatherProvider = FutureProvider<WeatherInfo>((ref) {
  final repository = ref.watch(homeRepositoryProvider);
  final locale = ref.watch(localeProvider);
  final location = ref.watch(activeLocationProvider);
  return repository.fetchAgricultureWeather(
    locale.languageCode,
    latitude: location.latitude,
    longitude: location.longitude,
    cityName: location.name,
  );
});

/// Future provider for fetching market commodity prices, reacting to locale changes.
final marketProvider = FutureProvider<MarketResult>((ref) {
  final repository = ref.watch(homeRepositoryProvider);
  final locale = ref.watch(localeProvider);
  return repository.fetchMarketPrices(locale.languageCode);
});

/// Future provider for fetching pending AI suggestions.
final pendingSuggestionsProvider = FutureProvider<List<AiSuggestion>>((ref) {
  final repository = ref.watch(homeRepositoryProvider);
  return repository.fetchPendingSuggestions();
});

/// Future provider for searching articles by query
final searchArticlesProvider = FutureProvider.family<List<NewsArticle>, String>((ref, query) {
  if (query.isEmpty) return Future.value([]);
  final repository = ref.watch(homeRepositoryProvider);
  return repository.searchArticles(query);
});

/// Stream provider for top trending articles
final trendingArticlesProvider = StreamProvider<List<NewsArticle>>((ref) {
  final repository = ref.watch(homeRepositoryProvider);
  return repository.watchTrendingArticles();
});

/// Stream provider for YYT (Yüksek Yoğunluklu Tatlandırıcılar) category articles
final yytArticlesProvider = StreamProvider<List<NewsArticle>>((ref) {
  final repository = ref.watch(homeRepositoryProvider);
  return repository.watchYYTArticles();
});
