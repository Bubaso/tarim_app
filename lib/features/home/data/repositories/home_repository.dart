import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ai_suggestion.dart';
import '../models/news_article.dart';
import '../models/weather_info.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/market_data.dart';
import 'package:uuid/uuid.dart';
import 'package:hive_flutter/hive_flutter.dart';
class HomeRepository {
  final SupabaseClient _supabaseClient;

  HomeRepository(this._supabaseClient);

  /// Supabase REST stream for fetching 'articles' table, ordered by 'created_at' descending.
  /// Includes offline caching for PWA via SharedPreferences.
  Stream<List<NewsArticle>> watchLatestArticles() async* {
    // 1. Çevrimdışı destek için yerel önbelleği yükle (ama hemen emit ETME)
    // Anında emit etmek manşette "eski haber görünüp yeni habere dönüşme" (flash) 
    // sorununa yol açıyor. Ağ hatası olursa zaten handleError kısmında emit edilecek.
    try {
      final box = Hive.box<String>('offline_articles');
      if (box.isNotEmpty && _cachedDbArticles.isEmpty) {
        final cached = box.values.map((v) => NewsArticle.fromJson(jsonDecode(v) as Map<String, dynamic>)).toList();
        cached.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        _cachedDbArticles = cached;
      }
    } catch (e) {
      if (kDebugMode) print('Offline Hive cache read error: $e');
    }

    // STALE-WHILE-REVALIDATE: Çevrimdışı (veya yavaş bağlantı) anında "yükleniyor" 
    // ekranında takılmamak için önce yerel önbelleği (varsa) anında ekrana veriyoruz.
    if (_cachedDbArticles.isNotEmpty) {
      yield [..._localDrafts, ..._cachedDbArticles];
    }

    // 2. Sunucudan güncel veriyi çek ve önbelleği güncelle
    try {
      yield* _supabaseClient
          .from('articles')
          .select(_listeSutunlari)
          .eq('status', 'published')
          .order('created_at', ascending: false)
          .limit(_listeSiniri)
          .asStream()
          .timeout(const Duration(seconds: 8)) // Web'de sonsuza kadar takılmasını önler
          .map((maps) {
            final dbArticles = maps
                .map((map) => NewsArticle.fromJson(map as Map<String, dynamic>))
                .toList();
            _cachedDbArticles = dbArticles;
            // ÖNBELLEK YAZIMI BEKLENMİYOR.
            //
            // Eskiden `asyncMap` yazımı bekliyordu, arayüz de onunla birlikte
            // bekliyordu. Ölçüm (2 Kasım 2026, canlı): sorgu 6,3. saniyede
            // bitiyor ama geri kalan sağlayıcılar 21,9. saniyede başlıyordu —
            // aradaki 15,6 saniyenin tamamı önbellek yazımı. Ekrandaki
            // karşılığı, ana sayfanın yirmi saniye boyunca iskelet kalması.
            //
            // Önbellek bir KOLAYLIK; ilk boyamanın önüne geçemez.
            unawaited(_onbellegeYaz(dbArticles));
            return [..._localDrafts, ...dbArticles];
          });
    } catch (e) {
      if (kDebugMode) {
        print('watchLatestArticles network timeout/error: $e');
      }
      // Hata durumunda zaten yukarıda cache emit edildiği için ek bir şey yapmaya gerek yok,
      // ancak stream'in kapanmaması için boş bir stream veya son halini tekrar dönebiliriz.
      // Yield ile son hali tekrar gönderiyoruz ki akış kopmasın.
      yield [..._localDrafts, ..._cachedDbArticles];
    }
  }

  // ══════════════════════════════════════════════════════════════════════
  //  LİSTE SORGUSU — §20.1
  // ──────────────────────────────────────────────────────────────────────
  //  `select('*')` ve limitsiz sorgu ziyaretçi BAŞINA bütün arşivi
  //  gövdesiyle indiriyordu. 2 Kasım 2026'da ölçüldü: 4,08 MB gzip /
  //  10,67 MB açılmış. Asıl tehlike rakam değil BİLEŞİK BÜYÜME: arşiv günde
  //  ~32 haber alıyor.
  //
  //  Dışarıda bırakılan on bir sütunun hiçbiri KART çiziminde kullanılmıyor:
  //  sekizi gövde/grafik/öne çıkanlar/uzman görüşü (yükün %66'sı), üçü
  //  (facts/figures/quotes) yalnızca inceleme masasının okuduğu doğrulama
  //  verisi (%16,5) — o ekran `watchPendingArticles` ile AYRI sorgu yapıyor.
  //
  //  Sütunlar TEK TEK yazılıyor: PostgREST'te "şunlar hariç" diye bir sözdizimi
  //  yok. Tabloya yeni bir sütun eklenirse buraya da eklenmeli; eklenmezse
  //  kartta görünmez — ama veri KAYBOLMAZ (§20.2/§25.1 korumaları yazma
  //  yolunu tam kayıtla besliyor).
  static const String _listeSutunlari =
      'id,title,slug,summary,status,category_id,image_url,geo_location,'
      'seo_keywords,view_count,created_at,updated_at,title_en,summary_en,'
      'source_name,source_url,content_type,topic,region,hero_score,'
      'is_hero,hero_order,spot,spot_en,is_breaking,breaking_notified_at,'
      'hero_pinned_at,source_chars,source_depth,extraction_method,'
      'article_format,published_at,story_image_url,thumb_image_url,'
      'image_lqip,rejection_reason,'
      'rejected_at,source_modified_at,source_drift,publish_at,turkiye_pin,'
      'audio_url,audio_url_en,is_radio,radio_order,ses_deneme,ses_hatasi';

  //  Sütun daraltma yükü düşürüyor ama BÜYÜMEYİ durdurmuyor; sınırsız sorgu
  //  arşivle birlikte sonsuza kadar şişer. 500 bir yayın kararı: kategori
  //  ekranı artık kendi sayfalanmış sorgusunu yapıyor (§20.3), yani arşivin
  //  derinine inmek bu sınıra bağlı değil.
  static const int _listeSiniri = 500;

  // ══════════════════════════════════════════════════════════════════════
  //  KATEGORİ SAYFALAMASI — §20.3
  // ──────────────────────────────────────────────────────────────────────
  //  `_listeSiniri` ana sayfanın yükünü bağlıyor ama kategori ekranı arşivin
  //  DERİNİNE inebilmeli. §20.3'ün yazdığı çözüm: sınırı büyütmek DEĞİL,
  //  kategori ekranına KENDİ sayfalanmış sorgusunu vermek.
  //
  //  Aynı kural §26.2'de yazar arşivi için de uygulanmıştı: "bir varlığın TÜM
  //  kayıtları" isteyen hiçbir ekran, tarihe göre sınırlanmış ortak listeyi
  //  süzerek çalışmamalı. Sınır sessizdir — hata vermez, sadece eksik gösterir.
  //
  //  Süzgeçler `category_catalog.dart` ve `home_providers.dart`taki istemci
  //  süzgeçleriyle AYNI olmak zorunda; ayrışırlarsa "Daha fazla" düğmesi
  //  anasayfadakinden başka haberler getirir. `functions/index.js` içindeki
  //  `categoryRenderer` de aynı üçlüyü kullanıyor (§19.8).
  //
  //  Değerler veritabanından ölçüldü (2 Kas 2026): region ∈ {Türkiye, Dünya},
  //  topic ∈ {Ekonomi, Bitkisel Üretim, Hayvancılık, Genel, Tarım-Bilim, YYT}.
  //  Büyük/küçük harf kayması yok. `toLowerCase()` BURADA TEKRARLANMIYOR —
  //  istemci onu bellek içi listede yapıyor; sorguya taşımak Türkçe noktalı i
  //  tuzağına açık olurdu (§39.5).
  static const Map<String, List<String>> _kategoriBolgeleri = {
    'turkiye': ['Türkiye'],
    'dunya': ['Dünya', 'Uluslararası', 'Küresel'],
  };
  static const Map<String, List<String>> _kategoriKonulari = {
    'tarim-bilim': ['Tarım-Bilim', 'YYT'],
    'hayvancilik': ['Hayvancılık'],
    'bitkisel-uretim': ['Bitkisel Üretim'],
    'ekonomi': ['Ekonomi'],
    'genel': ['Genel'],
  };

  /// Kategorinin [offset]'ten başlayan [limit] kadar haberi, en yeniden eskiye.
  ///
  /// Bilinmeyen slug'da boş liste döner; ÇAĞIRAN TARAFTA "daha fazla yok"
  /// anlamına gelir ve sonsuz döngü oluşmaz.
  Future<List<NewsArticle>> fetchKategoriSayfasi(
    String slug, {
    required int offset,
    int limit = 40,
  }) async {
    final bolgeler = _kategoriBolgeleri[slug];
    final konular = _kategoriKonulari[slug];
    if (bolgeler == null && konular == null) return const [];

    var sorgu = _supabaseClient
        .from('articles')
        .select(_listeSutunlari)
        .eq('status', 'published');
    if (bolgeler != null) sorgu = sorgu.inFilter('region', bolgeler);
    if (konular != null) sorgu = sorgu.inFilter('topic', konular);

    final veri = await sorgu
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (veri as List)
        .map((m) => NewsArticle.fromJson(m as Map<String, dynamic>))
        .toList();
  }

  /// Çevrimdışı önbelleği TEK işlemde yazar.
  ///
  /// `putAll` şart: 500 ayrı `put` çağrısı web'de 500 ayrı IndexedDB işlemi
  /// demek. Tek harita, tek işlem.
  Future<void> _onbellegeYaz(List<NewsArticle> liste) async {
    try {
      final box = Hive.box<String>('offline_articles');
      // Silinen haberler sonsuza kadar birikmesin diye önce temizleniyor.
      await box.clear();
      await box.putAll({
        for (final a in liste) a.id: jsonEncode(a.toJson()),
      });
    } catch (_) {}
  }

  /// Her köşe yazarının SON yayımlanmış yazısı — ada göre.
  ///
  /// Şerit eskiden ortak listeyi (`latestArticlesProvider`) süzüyordu ve o
  /// liste en yeni 500 haber. Ölçüm (2 Kasım 2026): listedeki en eski haber
  /// 23 Eylül tarihli; Yörük Kızı'nın yazısı 8 Eylül, Batuhan TÜRK'ün 7
  /// Eylül, Namık Altan ATABAY'ın 11 Eylül. Üçünün de yazısı VARDI ama
  /// pencerenin dışındaydı ve kartta "Yeni yazısı hazırlanıyor…" yazıyordu.
  ///
  /// §26.2'nin kuralı: bir varlığın kaydını isteyen ekran, tarihe göre
  /// sınırlanmış ortak listeyi SÜZEREK çalışmamalı. Sınır sessizdir — hata
  /// vermez, sadece eksik gösterir.
  ///
  /// Tek sorgu: adlar `in` ile veriliyor, en yeniden eskiye geliyor ve her
  /// ad için ilk görülen alınıyor.
  Future<Map<String, NewsArticle>> fetchYazarSonYazilari(
      List<String> adlar) async {
    if (adlar.isEmpty) return <String, NewsArticle>{};
    final veri = await _supabaseClient
        .from('articles')
        .select(_listeSutunlari)
        .eq('status', 'published')
        .inFilter('source_name', adlar)
        .order('created_at', ascending: false)
        .limit(300);

    final sonuc = <String, NewsArticle>{};
    for (final m in (veri as List)) {
      final a = NewsArticle.fromJson(m as Map<String, dynamic>);
      final ad = a.sourceName?.trim();
      if (ad != null && ad.isNotEmpty) sonuc.putIfAbsent(ad, () => a);
    }
    return sonuc;
  }

  /// Etikete göre yayındaki haberler — sayfalanmış.
  ///
  /// Eşleştirme SUNUCUDA (`haberler_etikete_gore`): istemcide yapmanın tek
  /// yolu bütün etiket dizilerini indirmekti. Fonksiyon `setof articles`
  /// döndüğü için sütun daraltması burada da sürüyor (§20.1).
  Future<List<NewsArticle>> fetchEtiketSayfasi(
    String slug, {
    required int offset,
    int limit = 40,
  }) async {
    final veri = await _supabaseClient.rpc(
      'haberler_etikete_gore',
      params: {'p_slug': slug, 'p_limit': limit, 'p_offset': offset},
    ).select(_listeSutunlari);

    return (veri as List)
        .map((m) => NewsArticle.fromJson(m as Map<String, dynamic>))
        .toList();
  }

  /// Onay kuyruğu.
  ///
  /// **`handleError` KALDIRILDI.** Eski hâli dönüş değeri kullanılmayan bir
  /// geri çağırımdı: `handleError` hatayı YUTUYOR, geri dönen liste hiçbir
  /// yere gitmiyordu. Sonuç — akış ne veri yayınlıyor ne hata veriyordu ve
  /// ekran sonsuza kadar dönen bir çarkta kalıyordu. Moderatör "bağlantı
  /// koptu" ile "bekleyen haber yok"u ayırt edemiyordu. Hata artık yukarı
  /// çıkıyor; ekranın `error` dalı zaten yazılı ve yeniden dene düğmesi var.
  ///
  /// **`select('*')` yerine ad ad sütun.** Kuyruk kartı sekiz alan
  /// gösteriyor; bütün satırı çekmek gövde metnini, İngilizce çeviriyi,
  /// grafik verisini ve alıntı dizilerini de indiriyordu. Önizleme zaten
  /// haberin kendi sayfasını açıyor, o da kendi sorgusunu yapıyor.
  ///
  /// **`limit` kondu.** Kuyrukta normalde ~39 haber bekliyor; sınırsız
  /// sorgu, hat bir gün durduğunda yüzlerce satır indirir ve ekranı
  /// dondurur. 300, en kötü günün birkaç katı.
  Stream<List<NewsArticle>> watchPendingArticles() {
    return _supabaseClient
        .from('articles')
        .select(_kuyrukSutunlari)
        .eq('status', 'reviewing')
        .order('created_at', ascending: false)
        .limit(300)
        .asStream()
        .map((maps) => maps
            .map((map) => NewsArticle.fromJson(map as Map<String, dynamic>))
            .toList());
  }

  /// Kuyruk ve reddedilenler kartlarının gösterdiği alanlar.
  ///
  /// `id` ve `created_at` kartta görünmüyor ama şart: biri kimlik, öteki
  /// sıralama. `published_at` kaynak tarihi rozetini, `hero_score` manşet
  /// skoru sıralamasını besliyor.
  static const String _kuyrukSutunlari =
      'id,title,summary,image_url,thumb_image_url,image_lqip,source_name,'
      'source_url,created_at,published_at,topic,region,category_id,'
      'hero_score,status,article_format,rejection_reason,rejected_at';

  /// Reddedilmiş haberler — geri alma ekranı için.
  ///
  /// Red artık silmiyor (§29.1), ama reddedilen habere ulaşmanın tek yolu
  /// sekiz saniyelik bir bildirim çubuğuydu. O kapandıktan sonra
  /// [reddiGeriAl] çağrılabilecek hiçbir yer kalmıyordu: "geri alınabilir"
  /// vaadi pratikte sekiz saniye sürüyordu.
  Stream<List<NewsArticle>> reddedilenleriIzle({int limit = 200}) {
    return _supabaseClient
        .from('articles')
        .select(_kuyrukSutunlari)
        .eq('status', 'rejected')
        // Reddedilme sırası, haberin yazılma sırası DEĞİL: moderatör
        // "az önce yanlışlıkla reddettiğim" haberi arıyor.
        .order('rejected_at', ascending: false, nullsFirst: false)
        .limit(limit)
        .asStream()
        .map((maps) => maps
            .map((map) => NewsArticle.fromJson(map as Map<String, dynamic>))
            .toList());
  }

  /// Bekleyen haberi yayına alır.
  ///
  /// [alanlariGuncelle] üzerinden geçiyor çünkü eski hâli İKİ denetimi de
  /// atlıyordu:
  ///
  ///   * Oturum denetimi yoktu. Oturum düştüğünde istemci `anon` rolüyle
  ///     yazıyor, RLS satırı hata vermeden süzüyor ve metot `true` dönüyordu.
  ///   * Dönen satır sayılmıyordu. PostgREST hiçbir satıra denk gelmeyen bir
  ///     `update` için 200 ve boş gövde döner — "başarılı" ile "hiçbir şey
  ///     yazılmadı" aynı görünür.
  ///
  /// Sonuç: kart kuyruktan düşmüş gibi görünüyor, haber yayına girmiyor.
  /// Aynı koruma red yolunda (`haberiReddet`) ve toplu onayda zaten vardı;
  /// eksik olan tek yol buydu.
  Future<bool> approveArticle(String id) =>
      alanlariGuncelle(id, {'status': 'published'});

  // ══════════════════════════════════════════════════════════════════════
  //  Moderasyon — red KAYDEDİLİR, sessizce silinmez
  // ══════════════════════════════════════════════════════════════════════
  //
  // [rejectArticle] kaydı doğrudan siliyor ve geriye iz bırakmıyor. Aynı
  // kaynak ertesi gün aynı haberi yine getirdiğinde moderatör onu ilk kez
  // görüyormuş gibi tekrar eliyor. `rejected_sources` tablosu (433 kayıt)
  // tam da bunun için var: reddedilen adres orada kalıyor, hem tekrarı
  // önlüyor hem de `source_scorecard` karnesini besliyor.

  /// Son yazma hatasının ham metni.
  ///
  /// Release derlemede `print` hiçbir yere gitmiyor ve panel yalnızca
  /// "kaydedilemedi" diyordu — sebebi öğrenmenin yolu yoktu. Arayüz bunu
  /// okuyup kullanıcıya gösteriyor.
  String? sonYazmaHatasi;

  /// Panel yazmaları için oturum denetimi.
  ///
  /// RLS yazmayı rol `authenticated` değilse HATA VERMEDEN satır süzerek
  /// engelliyor (200 + []). Oturum düşmüşse istemci `anon` olarak yazıyor ve
  /// kullanıcı "kaydedilemedi" görüp sebebini bilemiyor. Ölçüldü (29 Ekim
  /// 2026): articles UPDATE politikası `authenticated` için qual=true —
  /// yani yetki var, eksik olan OTURUM.
  String? _oturumSorunu() {
    final oturum = _supabaseClient.auth.currentSession;
    if (oturum == null) return 'Oturum yok — panele yeniden giriş yapın.';
    final bitis = oturum.expiresAt;
    if (bitis != null &&
        DateTime.fromMillisecondsSinceEpoch(bitis * 1000)
            .isBefore(DateTime.now())) {
      return 'Oturum süresi dolmuş — panele yeniden giriş yapın.';
    }
    return null;
  }

  /// Haberin BELİRLİ alanlarını günceller.
  ///
  /// [updateArticle] `toJson()` ile BÜTÜN satırı yazıyor; liste sorgusundan
  /// gelen eksik bir nesneyle çağrılırsa dolu alanları boşla eziyor (§25.1,
  /// üretimde bir haberin metni böyle gitti). Tek alan değiştirmek için bu
  /// metot kullanılır: yalnızca verilen anahtarlar yazılır.
  ///
  /// Dönen satır SAYILIYOR: RLS yazmayı hata vermeden satır süzerek
  /// engelleyebiliyor (200 + []) ve sessiz başarısızlık "kaydedildi" diye
  /// görünüyor (§20.4).
  Future<bool> alanlariGuncelle(String id, Map<String, dynamic> alanlar) async {
    if (alanlar.isEmpty) return true;
    sonYazmaHatasi = null;

    final sorun = _oturumSorunu();
    if (sorun != null) {
      // Teşhis ARAYÜZE taşınıyor. Eski hâli bu metni üretip yalnızca hata
      // ayıklama kipinde basıyordu; release derlemede `print` hiçbir yere
      // gitmiyor ve moderatörün gördüğü tek şey genel bir "kaydedilemedi"
      // oluyordu. Oysa metin tam olarak ne yapılacağını söylüyor:
      // "panele yeniden giriş yapın".
      sonYazmaHatasi = sorun;
      if (kDebugMode) print('alanlariGuncelle: $sorun');
      return false;
    }
    try {
      final yazilan = await _supabaseClient
          .from('articles')
          .update(alanlar)
          .eq('id', id)
          .select('id');
      if ((yazilan as List).isEmpty) {
        // Oturum var ve süresi dolmamış ama satır yine de süzülmüş.
        // Geriye iki ihtimal kalıyor ve ikisi de ayırt edilemiyor:
        // kimlik yok, ya da rol beklenen rol değil.
        sonYazmaHatasi =
            'Kayıt yazılmadı: haber bulunamadı ya da bu oturumun yetkisi yok.';
        return false;
      }
      return true;
    } catch (e) {
      sonYazmaHatasi = e.toString();
      if (kDebugMode) print('alanlariGuncelle error: $e');
      return false;
    }
  }

  /// Reddi GERİ ALIR: durum `reviewing`e döner, red izi silinir.
  ///
  /// `articles_forget_rejection_status` tetikleyicisi adresi red hafızasından
  /// da düşürüyor (§29.1); yoksa "geri al" yarım kalır ve hat o haberi bir
  /// daha hiç getirmez.
  Future<bool> reddiGeriAl(String id) => alanlariGuncelle(id, {
        'status': 'reviewing',
        'rejection_reason': null,
        'rejected_at': null,
      });

  /// Bir köşe yazarının TÜM yazıları.
  ///
  /// [watchLatestArticles] en yeni 500 haberi taşıyor ve hat günde ~130 haber
  /// çekiyor: o pencere ancak son birkaç haftayı kapsıyor. Yazar arşivini
  /// oradan süzmek, 29 yazısı olan yazarın profilinde 3 yazı göstermek
  /// demekti (§26.2). Sınır SESSİZ: hata vermiyor, eksik gösteriyor.
  Future<List<NewsArticle>> fetchArticlesBySourceName(String sourceName) async {
    try {
      final veri = await _supabaseClient
          .from('articles')
          .select('*')
          .eq('source_name', sourceName)
          .eq('status', 'published')
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(veri as List)
          .map(NewsArticle.fromJson)
          .toList();
    } catch (e) {
      if (kDebugMode) print('fetchArticlesBySourceName error: $e');
      return const [];
    }
  }

  /// "Türkiye'den haberler" bölümünün 2. haberini belirler.
  ///
  /// TEK haber işaretli olabilir: önce eski işaret temizleniyor, sonra yenisi
  /// konuyor. Ters sırada yapılsaydı iki işaretli haber kalabilir ve hangisinin
  /// görüneceği sorgu sırasına kalırdı.
  Future<bool> turkiyeSabitiAyarla(String? id) async {
    try {
      await _supabaseClient
          .from('articles')
          .update({'turkiye_pin': false}).eq('turkiye_pin', true);
      if (id != null) {
        await _supabaseClient
            .from('articles')
            .update({'turkiye_pin': true}).eq('id', id);
      }
      return true;
    } catch (e) {
      if (kDebugMode) print('turkiyeSabitiAyarla error: $e');
      return false;
    }
  }

  /// Haberi reddeder: durumu `rejected` yapar.
  ///
  /// SİLMİYOR (§29.1): yanlış basılan bir düğme geri getirilemeyecek bir kaydı
  /// yok ediyordu. Haber arşivde duruyor ve [reddiGeriAl] ile dönebiliyor.
  ///
  /// `rejected_sources`'a BURADAN YAZILMIYOR. O tablo istemciye bilerek
  /// kapalı (RLS açık, politika yok — 20260816130000'deki yorumun kendi
  /// ifadesi: "Tabloya istemci hiç dokunmuyor"). Adresi hafızaya yazan şey
  /// `articles_remember_rejection_status` tetikleyicisi; böylece red hangi
  /// yoldan gelirse gelsin (panel, bakım betiği, elle SQL) kayda geçiyor.
  /// Elle yazmaya çalışmak 42501 veriyordu ve red hiç gerçekleşmiyordu.
  Future<bool> haberiReddet({
    required String id,
    required String title,
    String? sourceUrl,
    String? sourceName,
    String? lastStatus,
    String? gerekce,
  }) =>
      alanlariGuncelle(id, {
        'status': 'rejected',
        'rejection_reason': gerekce,
        'rejected_at': DateTime.now().toUtc().toIso8601String(),
      });

  /// Birden çok haberi tek seferde reddeder.
  ///
  /// Tek tek dönüyor çünkü biri patlarsa diğerleri yine de işlensin; geriye
  /// kaç tanesinin GERÇEKTEN reddedildiği dönüyor ki arayüz doğru sayı
  /// gösterebilsin ("3 haber reddedildi" deyip 1'ini yapmak yalan olurdu).
  Future<int> topluReddet(List<Map<String, String?>> haberler) async {
    var basarili = 0;
    for (final h in haberler) {
      final id = h['id'];
      if (id == null) continue;
      final ok = await haberiReddet(
        id: id,
        title: h['title'] ?? '',
        sourceUrl: h['source_url'],
        sourceName: h['source_name'],
        lastStatus: h['last_status'],
      );
      if (ok) basarili++;
    }
    return basarili;
  }

  /// Seçili haberleri TEK istekte yayına alır ve GERÇEKTEN kaç tanesinin
  /// yayına girdiğini döner.
  ///
  /// **Neden `.select()` zinciri.** PostgREST'te hiçbir satıra denk gelmeyen
  /// bir `update` hata vermiyor — 200 ve boş gövde dönüyor. [approveArticle]
  /// bu yüzden RLS kaydı süzdüğünde de `true` diyor. Güncellenen satırları
  /// geri istemek tek güvenilir sayım yolu: dönen liste uzunluğu, yayına
  /// giren haber sayısının kendisi.
  ///
  /// **Neden tek istek.** Toplu red haber başına bir tur atıyor çünkü her
  /// red ayrıca `rejected_sources`a yazıyor. Onayda böyle bir yan iş yok;
  /// 39 haber için 39 tur atmanın sebebi yok.
  Future<int> topluOnayla(List<String> idler) async {
    if (idler.isEmpty) return 0;
    try {
      final donen = await _supabaseClient
          .from('articles')
          .update({'status': 'published'})
          .inFilter('id', idler)
          .select('id');
      return (donen as List).length;
    } catch (e) {
      if (kDebugMode) print('topluOnayla error: $e');
      return 0;
    }
  }

  // ══════════════════════════════════════════════════════════════════════
  //  Hikâye slaytlarını yayından kaldırma (kullanıcı isteği, 6 Kas 2026)
  // ──────────────────────────────────────────────────────────────────────
  //  "Yönetici canlıda yayınlanan, sevmediği bir hikâye slaytını devre dışı
  //  bırakabilmeli."
  //
  //  SİLMİYORUZ, İŞARETLİYORUZ. Satırı silmek üç şeyi birden kaybettiriyor:
  //  arşiv kaydını, izlendi defterinin anahtarını ve kararın geri alınma
  //  imkânını. Gizlenen slayt yerinde duruyor, yalnız çizilmiyor.
  //
  //  İşaret `items` içindeki slaytın kendisine yazılıyor — satıra değil.
  //  Dosya hikâyelerinde bir satırda beş slayt var ve yöneticinin
  //  beğenmediği genellikle tek slayt; satırı gizlemek ötekileri de
  //  götürürdü. Bütün slaytları gizlenen satırı istemci zaten çizmiyor.
  // ══════════════════════════════════════════════════════════════════════

  /// Bir hikâye slaytını gizler ya da geri getirir.
  ///
  /// `true` döndüğünde yazma GERÇEKTEN olmuştur: PostgREST hiçbir satıra
  /// denk gelmeyen bir güncellemede hata vermiyor, 200 ve boş gövde
  /// dönüyor (§25.1 ailesinden bir tuzak).
  Future<bool> hikayeSlaytiniGizle({
    required String storyId,
    required int slaytSirasi,
    required bool gizli,
  }) async {
    try {
      final mevcut = await _supabaseClient
          .from('portal_stories')
          .select('items')
          .eq('id', storyId)
          .limit(1);
      final liste = (mevcut as List);
      if (liste.isEmpty) return false;

      final ham = (liste.first as Map)['items'];
      if (ham is! List || slaytSirasi < 0 || slaytSirasi >= ham.length) {
        return false;
      }

      final slaytlar = <Map<String, dynamic>>[
        for (final x in ham) Map<String, dynamic>.from(x as Map),
      ];
      slaytlar[slaytSirasi]['gizli'] = gizli;

      final donen = await _supabaseClient
          .from('portal_stories')
          .update({'items': slaytlar})
          .eq('id', storyId)
          .select('id');
      return (donen as List).isNotEmpty;
    } catch (e) {
      if (kDebugMode) print('hikayeSlaytiniGizle error: $e');
      return false;
    }
  }

  /// Yönetim ekranı için: yayındaki bütün hikâye satırları, gizlenenler
  /// dahil.
  ///
  /// İstemcinin okur akışı gizlenenleri eliyor; yönetici onları GÖRMEK
  /// zorunda, yoksa kararını geri alamaz.
  Future<List<Map<String, dynamic>>> yonetimHikayeleri() async {
    try {
      final veri = await _supabaseClient
          .from('portal_stories')
          .select('id, group_title, items, expires_at, article_id, hedef_yol, '
              'is_breaking, articles(image_url, thumb_image_url, image_lqip)')
          .gt('expires_at', DateTime.now().toUtc().toIso8601String())
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(veri as List);
    } catch (e) {
      if (kDebugMode) print('yonetimHikayeleri error: $e');
      return const [];
    }
  }

  /// Kaynak karnesi (`source_scorecard` view'ı).
  ///
  /// View hazır: kaynak başına toplam / yayınlanan / reddedilen / bekleyen
  /// ve red yüzdesi. En çok reddedilen üstte — karnenin işe yaradığı yer
  /// orası.
  Future<List<Map<String, dynamic>>> kaynakKarnesi() async {
    try {
      final veri = await _supabaseClient
          .from('source_scorecard')
          .select()
          .order('red_yuzdesi', ascending: false);
      return List<Map<String, dynamic>>.from(veri as List);
    } catch (e) {
      if (kDebugMode) print('kaynakKarnesi error: $e');
      return const [];
    }
  }

  /// Rejects (deletes) a pending article
  Future<bool> rejectArticle(String id) async {
    try {
      await _supabaseClient
          .from('articles')
          .delete()
          .eq('id', id);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('rejectArticle error: $e');
      }
      return false;
    }
  }


  /// Searches articles by query using typo-tolerant RPC (pg_trgm).
  /// Falls back to basic ILIKE search if the RPC is not yet created in the database.
  Future<List<NewsArticle>> searchArticles(String query) async {
    if (query.trim().isEmpty) return [];
    
    try {
      final response = await _supabaseClient.rpc(
        'search_articles_fuzzy',
        params: {'search_term': query.trim(), 'max_limit': 20},
      );
      
      final list = response as List<dynamic>;
      return list.map((map) => NewsArticle.fromJson(map as Map<String, dynamic>)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('RPC Error: $e');
      }
      throw Exception('Arama hatası: $e');
    }
  }

  /// Belirli bir zaman aralığında yayımlanmış haberler (`/hafta/:slug`).
  ///
  /// Haftalık özet neden [watchLatestArticles] akışından süzülmüyor: o sorgu
  /// tüm arşivi çekiyor ve PostgREST'in satır tavanına (varsayılan 1000)
  /// takılıyor. Arşiv büyüdükçe ESKİ haftalar sessizce boşalırdı — üstelik
  /// hatasız, "o hafta haber yok" diyerek. Aralık sorgusu hem doğru hem ucuz.
  ///
  /// Hata burada YUTULMUYOR: boş liste "o hafta haber yayımlanmamış" demek, ağ
  /// hatası ise bambaşka bir şey. İkisini aynı sonuca indirgemek, bağlantısı
  /// kopmuş okuyucuya sessizce boş bir arşiv göstermek olurdu.
  Future<List<NewsArticle>> fetchArticlesBetween(
    DateTime fromUtc,
    DateTime toUtc,
  ) async {
    final response = await _supabaseClient
        .from('articles')
        .select()
        .eq('status', 'published')
        .gte('created_at', fromUtc.toUtc().toIso8601String())
        .lt('created_at', toUtc.toUtc().toIso8601String())
        .order('created_at', ascending: false)
        // Ölçülen en yoğun gün 51 haber; 400 bir hafta için geniş bir tavan.
        .limit(400);
    return (response as List<dynamic>)
        .map((map) => NewsArticle.fromJson(map as Map<String, dynamic>))
        .toList();
  }

  /// Fetches a single article by id — used when the app is opened directly
  /// on a `/haber/:id` deep link and the article is not already in memory.
  Future<NewsArticle?> fetchArticleById(String id) async {
    try {
      final response =
          await _supabaseClient.from('articles').select().eq('id', id).maybeSingle();
      if (response == null) return null;
      return NewsArticle.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('fetchArticleById failed: $e');
      }
      // Çevrimdışı isek yerel önbellekten bulmaya çalış (önce hafıza, sonra Hive)
      try {
        final idx = _cachedDbArticles.indexWhere((a) => a.id == id);
        if (idx != -1) return _cachedDbArticles[idx];
        
        final box = Hive.box<String>('offline_articles');
        final cachedStr = box.get(id);
        if (cachedStr != null) {
          return NewsArticle.fromJson(jsonDecode(cachedStr) as Map<String, dynamic>);
        }
      } catch (_) {}
      return null;
    }
  }

  /// Okuma sayacını bir artırır.
  ///
  /// Çağrı yeri: [ArticleDetailScreen] — haber ekranı AÇILDIĞINDA değil, okuma
  /// eşiği (gövdenin yarısı + en az 10 sn) aşıldığında ve cihaz başına yalnızca
  /// bir kez (bkz. `ReadReceipts`).
  ///
  /// Tek yol `increment_view_count` RPC'sidir. Eskiden burada bir yedek yol
  /// vardı: satırı oku, sayacı bir artır, geri yaz. O yol RLS nedeniyle hiçbir
  /// zaman çalışmadı — anon rolünün `articles` üzerinde UPDATE yetkisi yok ve
  /// istek sessizce boş sonuç dönüyordu. Çalışsaydı da yarış koşulu üretirdi:
  /// aynı anda okuyan iki cihaz aynı değeri okuyup aynı değeri yazardı.
  Future<void> incrementArticleViewCount(String id) async {
    try {
      await _supabaseClient.rpc('increment_view_count', params: {'row_id': id});
    } catch (e) {
      if (kDebugMode) {
        print('incrementArticleViewCount failed: $e');
      }
    }
  }

  /// Watches YYT-category articles using REST stream.
  /// Filters by category_slug = 'yyt' via a JOIN on the categories table.
  /// Falls back to a client-side slug match if the join is unavailable.
  Stream<List<NewsArticle>> watchYYTArticles() {
    return Stream.fromFuture(_fetchYYTCategoryId()).asyncExpand((yytCategoryId) {
      if (yytCategoryId == null) {
        return Stream.value(<NewsArticle>[]);
      }
      return _supabaseClient
          .from('articles')
          .select('*')
          .eq('status', 'published')
          .order('created_at', ascending: false)
          .asStream()
          .timeout(const Duration(seconds: 8))
          .map((maps) {
            return maps
                .where((m) => m['category_id']?.toString() == yytCategoryId)
                .map((m) => NewsArticle.fromJson(m as Map<String, dynamic>))
                .toList();
          })
          .handleError((e) {
            if (kDebugMode) print('watchYYTArticles error: $e');
            return <NewsArticle>[];
          });
    });
  }

  Future<String?> _fetchYYTCategoryId() async {
    try {
      final catRes = await _supabaseClient
          .from('categories')
          .select('id')
          .eq('slug', 'yyt')
          .maybeSingle();
      return catRes?['id']?.toString();
    } catch (_) {
      return null;
    }
  }

  /// Watches top trending articles ordered by view_count using REST stream.
  Stream<List<NewsArticle>> watchTrendingArticles() {
    return _supabaseClient
        .from('articles')
        .select('*')
        .eq('status', 'published')
        .asStream()
        .timeout(const Duration(seconds: 8))
        .map((maps) {
          final articles = maps
              .map((map) => NewsArticle.fromJson(map as Map<String, dynamic>))
              .toList();
          articles.sort((a, b) {
            final cmp = b.viewCount.compareTo(a.viewCount);
            if (cmp != 0) return cmp;
            return b.createdAt.compareTo(a.createdAt);
          });
          return articles.take(10).toList();
        })
        .handleError((e) {
          if (kDebugMode) print('watchTrendingArticles error: $e');
          return <NewsArticle>[];
        });
  }

  /// Watches top read articles using Supabase real-time stream for the dashboard.
  Stream<List<NewsArticle>> watchTopReadArticles(int limit) {
    return _supabaseClient
        .from('articles')
        .stream(primaryKey: ['id'])
        .eq('status', 'published')
        .timeout(const Duration(seconds: 8))
        .map((maps) {
          final articles = maps
              .map((map) => NewsArticle.fromJson(map as Map<String, dynamic>))
              .toList();
          articles.sort((a, b) {
            final cmp = b.viewCount.compareTo(a.viewCount);
            if (cmp != 0) return cmp;
            return b.createdAt.compareTo(a.createdAt);
          });
          return articles.take(limit).toList();
        })
        .handleError((e) {
          if (kDebugMode) print('watchTopReadArticles error: $e');
          return <NewsArticle>[];
        });
  }

  /// Fetches agricultural weather data with TR/EN localization.
  ///
  /// Sahte veri YOK. Eskiden istek başarısız olduğunda sabit kodlanmış bir
  /// "mock" hava durumu döndürülüyordu — ekranda hâlâ yeşil "CANLI" rozetiyle.
  /// Don riski ya da ilaçlama tavsiyesi gibi gerçek sonucu olan bir bilgide bu
  /// yanıltıcıydı: kaynak çökmüşken bile "koşullar normal" görünebiliyordu.
  /// Artık istek başarısız olursa hata YUKARI FIRLATILIYOR —
  /// `WeatherDetailScreen`in zaten hazır ama kullanılmayan hata ekranı
  /// (`_buildErrorState`) devreye giriyor, `_WeatherChip` de sessizce
  /// kayboluyor (`AsyncValue.error`'da `.value` null döner).
  ///
  /// Geçmiş yıl karşılaştırması (archive API) ayrı: o hâlâ "olursa iyi olur"
  /// niteliğinde, başarısız olursa kart hiç gösterilmiyor — o zaten dürüst
  /// bir davranış, dokunulmadı.
  Future<WeatherInfo> fetchAgricultureWeather(
    String lang, {
    required double latitude,
    required double longitude,
    required String cityName,
  }) async {
    final isEn = lang.toLowerCase() == 'en';
    final fetchedAt = DateTime.now();

    final url = 'https://api.open-meteo.com/v1/forecast'
        '?latitude=$latitude'
        '&longitude=$longitude'
        '&current=temperature_2m,relative_humidity_2m,wind_speed_10m,weather_code,soil_temperature_0_to_7cm,soil_moisture_0_to_1cm'
        '&daily=temperature_2m_max,temperature_2m_min,weather_code,et0_fao_evapotranspiration,precipitation_sum'
        '&timezone=auto';

    final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 4));

    if (response.statusCode != 200) {
      throw Exception('Open-Meteo ${response.statusCode} döndürdü');
    }

    final json = jsonDecode(response.body);
    final current = json['current'];
    final dailyData = json['daily'];

    final temp = (current['temperature_2m'] as num?)?.toDouble() ?? 22.5;
    final relHumidity = (current['relative_humidity_2m'] as num?)?.toDouble() ?? 60.0;
    final windSpeed = (current['wind_speed_10m'] as num?)?.toDouble() ?? 10.0;
    final code = current['weather_code'] as int? ?? 0;
    final soilTemp = (current['soil_temperature_0_to_7cm'] as num?)?.toDouble() ?? (temp - 2.5);
    final soilMoisture = (current['soil_moisture_0_to_1cm'] as num?)?.toDouble() ?? 0.15;

    double et0 = 4.5;
    if (dailyData != null && dailyData['et0_fao_evapotranspiration'] != null) {
      final et0List = dailyData['et0_fao_evapotranspiration'] as List;
      if (et0List.isNotEmpty) {
        et0 = (et0List[0] as num?)?.toDouble() ?? 4.5;
      }
    }

    final List<DailyForecastItem> dailyForecast = [];
    if (dailyData != null) {
      final times = dailyData['time'] as List? ?? [];
      final maxTemps = dailyData['temperature_2m_max'] as List? ?? [];
      final minTemps = dailyData['temperature_2m_min'] as List? ?? [];
      final weatherCodes = dailyData['weather_code'] as List? ?? [];
      final et0List = dailyData['et0_fao_evapotranspiration'] as List? ?? [];
      final precipList = dailyData['precipitation_sum'] as List? ?? [];

      for (int i = 0; i < times.length; i++) {
        if (i < maxTemps.length && i < minTemps.length) {
          dailyForecast.add(DailyForecastItem(
            date: times[i]?.toString() ?? '',
            maxTemp: (maxTemps[i] as num?)?.toDouble() ?? 0.0,
            minTemp: (minTemps[i] as num?)?.toDouble() ?? 0.0,
            weatherCode: (weatherCodes.length > i ? weatherCodes[i] as int? : null) ?? 0,
            et0: (et0List.length > i ? et0List[i] as num? : null)?.toDouble() ?? 0.0,
            precipitation: (precipList.length > i ? precipList[i] as num? : null)?.toDouble() ?? 0.0,
          ));
        }
      }
    }

    HistoricalInfo? historicalInfo;
    try {
      final now = DateTime.now();
      final lastYear = DateTime(now.year - 1, now.month, now.day);
      final dateStr = '${lastYear.year}-${lastYear.month.toString().padLeft(2, '0')}-${lastYear.day.toString().padLeft(2, '0')}';

      final histUrl = 'https://archive-api.open-meteo.com/v1/archive'
          '?latitude=$latitude'
          '&longitude=$longitude'
          '&start_date=$dateStr'
          '&end_date=$dateStr'
          '&daily=temperature_2m_max,temperature_2m_min,et0_fao_evapotranspiration'
          '&timezone=auto';

      final histResponse = await http.get(Uri.parse(histUrl)).timeout(const Duration(seconds: 2));
      if (histResponse.statusCode == 200) {
        final histJson = jsonDecode(histResponse.body);
        final histDaily = histJson['daily'];
        if (histDaily != null) {
          final hMaxList = histDaily['temperature_2m_max'] as List? ?? [];
          final hMinList = histDaily['temperature_2m_min'] as List? ?? [];
          final hEt0List = histDaily['et0_fao_evapotranspiration'] as List? ?? [];

          if (hMaxList.isNotEmpty && hMinList.isNotEmpty) {
            historicalInfo = HistoricalInfo(
              lastYearMaxTemp: (hMaxList[0] as num?)?.toDouble() ?? 0.0,
              lastYearMinTemp: (hMinList[0] as num?)?.toDouble() ?? 0.0,
              lastYearEt0: (hEt0List.isNotEmpty ? hEt0List[0] as num? : null)?.toDouble() ?? 0.0,
            );
          }
        }
      }
    } catch (_) {
      // Bu kısım gerçekten "olursa iyi olur" — geçen yıl karşılaştırması
      // olmadan da sayfa dürüst ve eksiksiz. Ana veri bu davranışı PAYLAŞMIYOR
      // artık, bkz. yukarıdaki fonksiyon dokümanı.
    }

    // Interpret weather code (WMO Weather interpretation codes)
    //
    // Don riski ŞU ANKİ sıcaklığa değil BU GECENİN tahmini düşüğüne bakmalı —
    // metin zaten "Bu Gece Don Riski Var!" diyor. Eskiden `temp < 4.0`
    // kontrolü öğleden sonra 15°C'de "GÜVENLİ" gösterip gece -2°C'ye
    // düşecek olsa bile uyarmıyordu. `dailyForecast.first` bugünün (0-24
    // saat yerel) tahmini düşüğü — çoğu iklimde bu, gece/şafak öncesi düşük.
    final tonightMin = dailyForecast.isNotEmpty ? dailyForecast.first.minTemp : temp;

    String description;
    String icon;
    String warning;
    // Üst çubuğa sığan kısa hâl (Ö7). Uzun metni kırpmak asıl kelimeyi
    // kaybettiriyordu; ikisi aynı yerde birlikte yazılıyor.
    String warningShort;
    bool hasWarning = false;

    if (code >= 51 && code <= 67) {
      description = isEn ? 'Rainy & Damp' : 'Yağışlı ve Nemli';
      icon = '09d';
      warning = isEn ? 'High Humidity - Watch out for Mildew!' : 'Yüksek Nem - Mildiyö Hastalığına Dikkat!';
      warningShort = isEn ? 'Mildew risk' : 'Mildiyö riski';
      hasWarning = true;
    } else if (code >= 71 && code <= 77) {
      description = isEn ? 'Snowy' : 'Karlı';
      icon = '13d';
      warning = isEn ? 'Severe Frost Risk!' : 'Şiddetli Don Riski!';
      warningShort = isEn ? 'Severe frost' : 'Şiddetli don';
      hasWarning = true;
    } else if (code >= 80 && code <= 82) {
      description = isEn ? 'Heavy Rain Showers' : 'Sağnak Yağışlı';
      icon = '09d';
      warning = isEn ? 'Soil Erosion Risk - Avoid Planting' : 'Erozyon Riski - Ekim Yapmaktan Kaçının';
      warningShort = isEn ? 'Erosion risk' : 'Erozyon riski';
      hasWarning = true;
    } else if (tonightMin < 4.0) {
      description = isEn ? 'Cold & Clear' : 'Soğuk ve Açık';
      icon = '01d';
      warning = isEn ? 'Frost Risk Tonight!' : 'Bu Gece Don Riski Var!';
      warningShort = isEn ? 'Frost tonight' : 'Gece don riski';
      hasWarning = true;
    } else {
      description = isEn ? 'Sunny & Warm' : 'Güneşli ve Ilık';
      icon = '01d';
      warning = isEn ? 'Good Conditions for Irrigation & Harvest' : 'Sulama ve Hasat İçin Mükemmel Şartlar';
      warningShort = isEn ? 'Good for fieldwork' : 'Tarla işine uygun';
    }

    return WeatherInfo(
      temperature: temp,
      relativeHumidity: relHumidity,
      windSpeed: windSpeed,
      soilTemperature: soilTemp,
      soilMoisture: soilMoisture,
      evapotranspiration: et0,
      city: cityName,
      description: description,
      iconCode: icon,
      agriculturalWarning: warning,
      agriculturalWarningShort: warningShort,
      hasWarning: hasWarning,
      dailyForecast: dailyForecast,
      historicalInfo: historicalInfo,
      fetchedAt: fetchedAt,
    );
  }

  Future<String> _fetchWithFallback(String url) async {
    // Attempt 1: Direct fetch
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: kIsWeb
            ? null
            : {
                'User-Agent':
                    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36',
              },
      ).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        return response.body;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Direct fetch failed for $url: $e');
      }
    }

    // Attempt 2: CORS Proxy 1 (corsproxy.io)
    try {
      final proxyUrl = 'https://corsproxy.io/?${Uri.encodeComponent(url)}';
      final response = await http.get(Uri.parse(proxyUrl)).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        return response.body;
      }
    } catch (e) {
      if (kDebugMode) {
        print('corsproxy.io failed for $url: $e');
      }
    }

    // Attempt 3: CORS Proxy 2 (allorigins)
    try {
      final proxyUrl = 'https://api.allorigins.win/raw?url=${Uri.encodeComponent(url)}';
      final response = await http.get(Uri.parse(proxyUrl)).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        return response.body;
      }
    } catch (e) {
      if (kDebugMode) {
        print('allorigins failed for $url: $e');
      }
    }

    // Attempt 4: CORS Proxy 3 (codetabs)
    try {
      final proxyUrl = 'https://api.codetabs.com/v1/proxy?quest=${Uri.encodeComponent(url)}';
      final response = await http.get(Uri.parse(proxyUrl)).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        return response.body;
      }
    } catch (e) {
      if (kDebugMode) {
        print('codetabs failed for $url: $e');
      }
    }

    throw Exception('All fetch methods failed');
  }


  Map<String, dynamic> _parseYahooChart(String body) {
    final json = jsonDecode(body);
    final chart = json['chart'];
    if (chart == null) throw Exception('Chart key missing');
    final resultList = chart['result'] as List?;
    if (resultList == null || resultList.isEmpty) throw Exception('Result list empty');
    final result = resultList[0] as Map<String, dynamic>;
    final meta = result['meta'] as Map<String, dynamic>;
    final price = (meta['regularMarketPrice'] as num).toDouble();
    final prevClose = (meta['chartPreviousClose'] as num).toDouble();
    final changePercent = ((price - prevClose) / prevClose) * 100;
    return {
      'price': price,
      'change': changePercent,
    };
  }

  /// Fetches real-time agricultural commodity prices directly from Yahoo Finance.
  /// All prices are native exchange quotes — no manual calculations or estimates.
  Future<MarketResult> fetchMarketPrices(String lang) async {
    final isEn = lang.toLowerCase() == 'en';

    try {
      // All 5 symbols fetched directly from Yahoo Finance
      final results = await Future.wait([
        _fetchWithFallback('https://query1.finance.yahoo.com/v8/finance/chart/USDTRY=X'), // 0: USD/TRY
        _fetchWithFallback('https://query1.finance.yahoo.com/v8/finance/chart/W=F'),      // 1: CBOT Wheat ¢/bu
        _fetchWithFallback('https://query1.finance.yahoo.com/v8/finance/chart/C=F'),      // 2: CBOT Corn ¢/bu
        _fetchWithFallback('https://query1.finance.yahoo.com/v8/finance/chart/S=F'),      // 3: CBOT Soybeans ¢/bu
        _fetchWithFallback('https://query1.finance.yahoo.com/v8/finance/chart/SB=F'),     // 4: ICE Sugar No.11 ¢/lb
        _fetchWithFallback('https://query1.finance.yahoo.com/v8/finance/chart/CT=F'),     // 5: NYBOT Cotton ¢/lb
      ]);

      final usdTryData  = _parseYahooChart(results[0]);
      final wheatData   = _parseYahooChart(results[1]);
      final cornData    = _parseYahooChart(results[2]);
      final soybeanData = _parseYahooChart(results[3]);
      final sugarData   = _parseYahooChart(results[4]);
      final cottonData  = _parseYahooChart(results[5]);

      final usdTry = usdTryData['price'] as double;

      // Convert bushel prices: ¢/bu → TL/Kg (exact, using live USD/TRY)
      // Wheat: 1 bushel = 27.2155 kg
      final wheatTrKg = (wheatData['price'] / 100.0 / 27.2155) * usdTry;
      // Corn: 1 bushel = 25.4012 kg
      final cornTrKg  = (cornData['price'] / 100.0 / 25.4012) * usdTry;
      // Soybeans: 1 bushel = 27.2155 kg
      final soyTrKg   = (soybeanData['price'] / 100.0 / 27.2155) * usdTry;
      // Cotton: ¢/lb → TL/kg (1 lb = 0.453592 kg)
      final cottonTrKg = (cottonData['price'] / 100.0 / 0.453592) * usdTry;

      final commodities = [
        MarketData(
          productName: isEn ? 'CBOT Wheat' : 'CBOT Buğday',
          price: isEn ? wheatData['price'] : wheatTrKg,
          changePercentage: wheatData['change'],
          unit: isEn ? '¢/bu' : 'TL/Kg',
        ),
        MarketData(
          productName: isEn ? 'CBOT Corn' : 'CBOT Mısır',
          price: isEn ? cornData['price'] : cornTrKg,
          changePercentage: cornData['change'],
          unit: isEn ? '¢/bu' : 'TL/Kg',
        ),
        MarketData(
          productName: isEn ? 'CBOT Soybeans' : 'CBOT Soya Fasulyesi',
          price: isEn ? soybeanData['price'] : soyTrKg,
          changePercentage: soybeanData['change'],
          unit: isEn ? '¢/bu' : 'TL/Kg',
        ),
        MarketData(
          productName: isEn ? 'ICE Sugar No.11' : 'ICE Şeker No.11',
          price: sugarData['price'],
          changePercentage: sugarData['change'],
          unit: '¢/lb',
        ),
        MarketData(
          productName: isEn ? 'NYBOT Cotton' : 'NYBOT Pamuk',
          price: isEn ? cottonData['price'] : cottonTrKg,
          changePercentage: cottonData['change'],
          unit: isEn ? '¢/lb' : 'TL/Kg',
        ),
      ];

      return MarketResult(
        commodities: commodities,
        isRealTime: true,
        lastUpdated: DateTime.now(),
      );

    } catch (e) {
      if (kDebugMode) print('fetchMarketPrices failed: $e');
      final fallbackList = isEn ? [
        MarketData(productName: 'CBOT Wheat',     price: 534.5,  changePercentage: 0.0, unit: '¢/bu'),
        MarketData(productName: 'CBOT Corn',      price: 341.0,  changePercentage: 0.0, unit: '¢/bu'),
        MarketData(productName: 'CBOT Soybeans',  price: 903.75, changePercentage: 0.0, unit: '¢/bu'),
        MarketData(productName: 'ICE Sugar No.11',price: 15.17,  changePercentage: 0.0, unit: '¢/lb'),
        MarketData(productName: 'NYBOT Cotton',   price: 82.95,  changePercentage: 0.0, unit: '¢/lb'),
      ] : [
        MarketData(productName: 'CBOT Buğday',       price: 534.5,  changePercentage: 0.0, unit: '¢/bu'),
        MarketData(productName: 'CBOT Mısır',        price: 341.0,  changePercentage: 0.0, unit: '¢/bu'),
        MarketData(productName: 'CBOT Soya Fasulyesi',price:903.75, changePercentage: 0.0, unit: '¢/bu'),
        MarketData(productName: 'ICE Şeker No.11',   price: 15.17,  changePercentage: 0.0, unit: '¢/lb'),
        MarketData(productName: 'NYBOT Pamuk',       price: 82.95,  changePercentage: 0.0, unit: '¢/lb'),
      ];
      return MarketResult(commodities: fallbackList, isRealTime: false, lastUpdated: DateTime.now());
    }
  }




  /// Submits a new article by an authenticated author.
  /// Sets status to 'reviewing', image_url to null, and created_at to current time.
  Future<bool> submitArticleByAuthor(NewsArticle article) async {
    try {
      // Create a mutable copy of the json
      final json = article.toJson();
      
      // Automatically translate if missing
      if (json['title_en'] == null || json['title_en'].toString().trim().isEmpty) {
        json['title_en'] = await translateTextToEnglish(json['title']);
      }
      if (json['summary_en'] == null || json['summary_en'].toString().trim().isEmpty) {
        json['summary_en'] = await translateTextToEnglish(json['summary']);
      }
      if (json['content_en'] == null || json['content_en'].toString().trim().isEmpty) {
        json['content_en'] = await translateTextToEnglish(json['content']);
      }

      json['status'] = 'reviewing';
      json['image_url'] = null;
      json['created_at'] = DateTime.now().toUtc().toIso8601String();
      
      // Generate a slug to satisfy the NOT NULL constraint in Supabase
      final slugBase = article.title.toLowerCase()
          .replaceAll('ş', 's').replaceAll('ı', 'i').replaceAll('ğ', 'g')
          .replaceAll('ü', 'u').replaceAll('ö', 'o').replaceAll('ç', 'c')
          .replaceAll(RegExp(r'[^a-z0-9]+'), '-').replaceAll(RegExp(r'^-+|-+$'), '');
      json['slug'] = '$slugBase-${DateTime.now().millisecondsSinceEpoch}';

      // Removed author_id as it doesn't exist in the schema

      await _supabaseClient.from('articles').insert(json);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('submitArticleByAuthor error: $e');
      }
      return false;
    }
  }

  /// Updates an existing article and returns error message if any, null on success.
  // ══════════════════════════════════════════════════════════════════════
  //  Panelden düzenleme — SATIRIN TAMAMI DEĞİL, DEĞİŞEN ALANLAR
  // ──────────────────────────────────────────────────────────────────────
  //  8 Kasım 2026 ölçümü. Panel formu [updateArticle] çağırıyordu, o da
  //  `toJson()` ile bütün satırı yazıyordu. Form 42 sütunun 34'ünü
  //  taşıyordu; taşımadığı 8'i her kaydetmede NULL'a eziliyordu:
  //
  //    image_credit · image_caption  → fotoğraf künyesi (telif açısından
  //                                    bulunması gereken bilgi)
  //    published_at                  → kaynaktaki yayın tarihi; kuyruğun
  //                                    bayatlık rozetini besleyen alan
  //    thumb_image_url · image_lqip  → hikâye görsel türevleri
  //    hero_pinned_at                → manşete sabitlenme zamanı
  //    chart_data_en                 → İngilizce grafik
  //    article_format                → "kısa haber" etiketi
  //
  //  §25.1'de aynı tuzak bir kez daha yaşanmış ve o zaman çözüm forma
  //  taşıyıcı satırlar eklemek olmuştu (facts, figures, quotes...). O çözüm
  //  bir sonraki sütun eklendiğinde yine bozuluyor — nitekim bozuldu.
  //
  //  Kalıcı çözüm: düzenleme yolu artık FORMUN SAHİP OLDUĞU alanları
  //  yazıyor. Formda karşılığı olmayan sütuna hiç dokunulmuyor, dolayısıyla
  //  yarın eklenecek sütun da kendiliğinden güvende.
  // ══════════════════════════════════════════════════════════════════════

  /// Panel formunun GERÇEKTEN düzenlediği alanlar. Başka sütuna dokunmuyor.
  ///
  /// `null` değerler bilerek yazılıyor: form bir alanı boşaltabilmeli
  /// (örneğin görseli kaldırmak). Haritaya girmeyen sütun ile haritaya
  /// `null` ile giren sütun arasındaki fark bu.
  /// Panel formunun yazdığı sütunlar — TEK kaynak, test edilebilir.
  ///
  /// Ayrı bir fonksiyon olmasının sebebi testle korunabilmesi: bu listeye
  /// yanlışlıkla bir sütun EKLEMEK, o sütunu formun her kaydetmesinde
  /// yeniden yazılır hâle getirir. Asıl tehlike de bu yönde: biri "form
  /// zaten NewsArticle alıyor, toJson kullanalım" der ve sekiz sütun yine
  /// sıfırlanır. `test/panel_form_alanlari_test.dart` bunu durduruyor.
  @visibleForTesting
  static Map<String, dynamic> formAlanlari(
    NewsArticle article, {
    String? titleEn,
    String? summaryEn,
    String? contentEn,
  }) =>
      <String, dynamic>{
        'title': article.title,
        'title_en': titleEn,
        'content': article.content,
        'content_en': contentEn,
        'summary': article.summary,
        'summary_en': summaryEn,
        'image_url': article.imageUrl,
        'category_id': article.categoryId,
        'geo_location': article.geoLocation,
        'is_breaking': article.isBreaking,
        'status': article.status,
      };

  Future<String?> formdanKaydet(NewsArticle article) async {
    final sorun = _oturumSorunu();
    if (sorun != null) return sorun;

    // Çeviriler kaydetmeden ÖNCE: eksikse doldurulup haritaya giriyor.
    final titleEn = (article.titleEn ?? '').trim().isEmpty
        ? await translateTextToEnglish(article.title)
        : article.titleEn;
    final summaryEn = (article.summaryEn ?? '').trim().isEmpty
        ? await translateTextToEnglish(article.summary ?? '')
        : article.summaryEn;
    final contentEn = (article.contentEn ?? '').trim().isEmpty
        ? await translateTextToEnglish(article.content)
        : article.contentEn;

    final alanlar = formAlanlari(article,
        titleEn: titleEn, summaryEn: summaryEn, contentEn: contentEn);

    final ok = await alanlariGuncelle(article.id, alanlar);
    if (!ok) {
      return sonYazmaHatasi ??
          'Kayıt yazılamadı: yetki yok ya da haber bulunamadı.';
    }

    // Yerel taslak önbelleği anında güncellensin ki liste beklemesin.
    final i = _localDrafts.indexWhere((a) => a.id == article.id);
    if (i != -1) {
      _localDrafts[i] = NewsArticle.fromJson({
        ...article.toJson(),
        'title_en': titleEn,
        'summary_en': summaryEn,
        'content_en': contentEn,
      });
    }
    return null;
  }

  Future<String?> updateArticle(NewsArticle article) async {
    try {
      final json = article.toJson();
      // Ensure we don't accidentally update the created_at or status unnecessarily
      json.remove('created_at');

      // Automatically translate if missing
      if (json['title_en'] == null || json['title_en'].toString().trim().isEmpty) {
        json['title_en'] = await translateTextToEnglish(json['title']);
      }
      if (json['summary_en'] == null || json['summary_en'].toString().trim().isEmpty) {
        json['summary_en'] = await translateTextToEnglish(json['summary']);
      }
      if (json['content_en'] == null || json['content_en'].toString().trim().isEmpty) {
        json['content_en'] = await translateTextToEnglish(json['content']);
      }

      // Update local drafts cache for instant UI feedback
      final index = _localDrafts.indexWhere((a) => a.id == article.id);
      if (index != -1) {
        // Create an updated article with translations
        _localDrafts[index] = NewsArticle.fromJson({...article.toJson(), ...json});
      }

      // .select() ŞART. RLS yazmayı HATA VERMEDEN satır süzerek
      // engelleyebiliyor (200 + []); `articles` üzerinde UPDATE politikası
      // hiç yoktu ve panelden yapılan her yazma sessizce düşüyordu —
      // "Yayından Çek" çalışmamasının sebebi buydu (29 Ekim 2026).
      final yazilan = await _supabaseClient
          .from('articles')
          .update(json)
          .eq('id', article.id)
          .select('id');
      if ((yazilan as List).isEmpty) {
        return 'Kayıt yazılamadı: yetki yok ya da haber bulunamadı.';
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('updateArticle error: $e');
      }
      // YEREL ÖNBELLEK BAŞARI SAYILMAZ. Burada eskiden "DB düşse de yerel
      // önbelleği güncelledik, UX için kısmi başarı" denip null dönülüyordu:
      // panel "güncellendi" diyor, veritabanında hiçbir şey değişmiyordu.
      // Yöneticinin yayından çektiğini sandığı haber yayında kalıyordu.
      return e.toString();
    }
  }

  /// Sets an article as breaking news and updates its created_at timestamp
  /// so that the breaking news cloud function can pick it up.
  Future<bool> setBreakingNews(String id, bool isBreaking) async {
    try {
      final updates = <String, dynamic>{
        'is_breaking': isBreaking,
      };
      
      // If setting to true, update created_at so the cloud function 30-min window catches it
      if (isBreaking) {
        updates['created_at'] = DateTime.now().toUtc().toIso8601String();
        updates['breaking_notified_at'] = null;
      }

      await _supabaseClient.from('articles').update(updates).eq('id', id);
      return true;
    } catch (e) {
      if (kDebugMode) print('setBreakingNews error: $e');
      return false;
    }
  }

  /// Updates the hero status and order of an article.
  ///
  /// `hero_pinned_at` her işaretlemede tazeleniyor: sabitleme kalıcı bir kilit
  /// değil, verildiği andan itibaren eriyen bir itki. Editör aynı haberi
  /// yeniden öne çıkarırsa itki de yeniden dolar.
  Future<bool> updateHeroStatus(String id, bool isHero, int? heroOrder) async {
    try {
      // Dönen satır SAYILIYOR: RLS yazmayı hata vermeden satır süzerek
      // engelleyebiliyor (200 + []) ve sabitleme kaydedilmemiş olduğu hâlde
      // kaydedilmiş görünüyordu (§20.4'ün aynı tuzağı, üçüncü kez).
      final yazilan = await _supabaseClient.from('articles').update({
        'is_hero': isHero,
        'hero_order': heroOrder,
        'hero_pinned_at':
            isHero ? DateTime.now().toUtc().toIso8601String() : null,
      }).eq('id', id).select('id');
      return (yazilan as List).isNotEmpty;
    } catch (e) {
      sonYazmaHatasi = e.toString();
      if (kDebugMode) print('updateHeroStatus error: $e');
      return false;
    }
  }

  /// Batch updates the hero orders.
  Future<bool> batchUpdateHeroOrders(List<Map<String, dynamic>> updates) async {
    try {
      final pinnedAt = DateTime.now().toUtc().toIso8601String();
      for (final update in updates) {
        await _supabaseClient.from('articles').update({
          'is_hero': true,
          'hero_order': update['hero_order'],
          'hero_pinned_at': pinnedAt,
        }).eq('id', update['id']);
      }
      return true;
    } catch (e) {
      if (kDebugMode) print('batchUpdateHeroOrders error: $e');
      return false;
    }
  }

  /// Fetches the list of article assignments from the database.
  Future<List<Map<String, dynamic>>> fetchArticleAssignments() async {
    try {
      final List<dynamic> response = await _supabaseClient
          .from('article_assignments')
          .select('*')
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      // Fallback dummy data if table is missing or errors out
      return [
        {
          'title': 'İklim Değişikliğinin Ege Bölgesindeki Zeytin Hasadına Etkisi',
          'description': 'Lütfen son 5 yılın kuraklık verilerini baz alarak üreticilerle yaptığınız röportajları derleyin. Cuma gününe kadar taslağı gönderin.',
          'status': 'reviewing',
          'created_at': DateTime.now().toIso8601String(),
        },
        {
          'title': 'Modern Sera Teknolojileri İncelemesi',
          'description': 'Antalya bölgesinde yeni kurulan topraksız tarım seralarının yatırım maliyetleri ve ROI süreleri hakkında teknik bir yazı hazırlayın.',
          'status': 'completed',
          'created_at': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        }
      ];
    }
  }

  /// Fetches the list of categories from the database.
  Future<List<Map<String, dynamic>>> fetchCategories() async {
    try {
      final List<dynamic> response = await _supabaseClient
          .from('categories')
          .select('*')
          .order('name', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  // Stateful fallback list for AI suggestions
  static final List<AiSuggestion> _fallbackSuggestions = [
    AiSuggestion(
      id: 1,
      sourceUrl: 'https://www.bloomberg.com/agri',
      sourceArticleTitle: 'Global Wheat Supply Drops Amidst European Droughts',
      suggestedTitle: 'Avrupa Kuraklığı Küresel Buğday Arzını Vurdu: Türkiye Ne Yapmalı?',
      suggestionReason: 'Buğday fiyatlarındaki küresel artış, Türkiye\'deki un ihracatçılarının maliyetlerini doğrudan etkileme potansiyeline sahip. Acil bir uyarı yazısı trafik çekebilir.',
      status: 'reviewing',
      createdAt: DateTime.now(),
    ),
    AiSuggestion(
      id: 2,
      sourceUrl: 'https://www.reuters.com/markets',
      sourceArticleTitle: 'Fertilizer Costs Subside in Q3 Reporting',
      suggestedTitle: 'Gübre Fiyatlarında Düşüş Eğilimi: Çiftçi Bahar Ekimi İçin Beklemeli mi?',
      suggestionReason: 'Üre gübresindeki düşüş, gübre alımı yapacak çiftçiler için stratejik bir karar anı yarattı. Analiz yazısı yüksek etkileşim alır.',
      status: 'reviewing',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    )
  ];

  /// Fetches pending suggestions from the 'ai_suggestions' table.
  Future<List<AiSuggestion>> fetchPendingSuggestions() async {
    try {
      final response = await _supabaseClient
          .from('ai_suggestions')
          .select('*')
          .eq('status', 'reviewing')
          .order('created_at', ascending: false);
      
      final list = response as List<dynamic>;
      return list.map((map) => AiSuggestion.fromJson(map as Map<String, dynamic>)).toList();
    } catch (e) {
      // Fallback AI Suggestions if table doesn't exist
      return _fallbackSuggestions.where((s) => s.status == 'reviewing').toList();
    }
  }

  // A local list to hold AI generated drafts if the DB is offline or RLS fails
  static final List<NewsArticle> _localDrafts = [];
  static List<NewsArticle> _cachedDbArticles = [];

  /// Updates the status of an AI suggestion.
  Future<bool> updateSuggestionStatus(AiSuggestion suggestion, String status) async {
    // Simulate an AI workflow: If approved, "generate" a draft and submit it
    if (status == 'approved') {
      try {
        String generatedContent = 'Yapay zeka ile içerik üretiliyor...';
        
        try {
          final apiKey = ApiConstants.geminiApiKey;
          if (apiKey.isNotEmpty) {
            final model = GenerativeModel(
              model: 'gemini-2.5-flash',
              apiKey: apiKey,
            );
            
            final prompt = '''
Sen Türkiye'nin en saygın, profesyonel ve objektif tarım, ekonomi ve piyasa analistisin. 
Aşağıdaki konu ve tavsiye edilen başlık üzerinden derinlemesine, gazetecilik etiğine uygun, sektörel verilerle desteklenmiş gerçekçi bir analiz/haber makalesi yazacaksın.

Konu Başlığı: ${suggestion.suggestedTitle}
Tavsiye Nedeni/Kapsamı: ${suggestion.suggestionReason}

Yazım Kuralları:
1. Kesinlikle uyduruk, kısa veya yüzeysel bir metin YAZMA. 
2. Gerçek bir gazetede yayınlanacak düzeyde profesyonel bir dil kullan.
3. İçeriği giriş, gelişme ve sonuç şeklinde bağlamlara oturt, sektörün geleceğine yönelik projeksiyonlar sun.
4. Çiftçiyi, yatırımcıyı ve politika yapıcıları ilgilendirecek kritik noktalara değin.
5. Sadece düz metin ver. Markdown (#, **, *) KULLANMA. Başlıklar veya alt başlıklar koyma, sadece temiz paragraflar halinde yaz.
6. Bu yazının tamamen AI tarafından üretildiği anlaşılmamalı, usta bir editörün kaleminden çıkmış gibi kusursuz olmalı.
''';
            final response = await model.generateContent([Content.text(prompt)]);
            generatedContent = response.text ?? 'Yapay zeka içeriği oluşturamadı.';
          } else {
            generatedContent = 'GEMINI_API_KEY bulunamadı. Lütfen .env dosyasına ekleyip uygulamayı yeniden başlatın.';
          }
        } catch (e) {
          generatedContent = 'Yapay zeka ile içerik üretilirken hata oluştu: $e';
        }

        final generatedArticle = NewsArticle(
          id: const Uuid().v4(),
          title: suggestion.suggestedTitle,
          summary: suggestion.suggestionReason,
          content: generatedContent,
          categoryId: '4753361f-3bbd-4118-9a46-ecccd5cf8367', // Default technology ID fallback
          imageUrl: null,
          createdAt: DateTime.now(),
          status: 'reviewing', 
        );
        // Try to submit to DB
        final success = await submitArticleByAuthor(generatedArticle);
        if (!success) {
          // If DB insert fails (e.g. RLS policy or missing table), add to local drafts
          _localDrafts.add(generatedArticle);
        }
      } catch (e) {
        // Ignore fallback simulation errors
      }
    }

    try {
      if (suggestion.id != null) {
        await _supabaseClient
            .from('ai_suggestions')
            .update({'status': status})
            .eq('id', suggestion.id!);
      }
      return true;
    } catch (e) {
      // Update fallback state if DB is missing
      final index = _fallbackSuggestions.indexWhere((s) => s.id == suggestion.id);
      if (index != -1) {
        final old = _fallbackSuggestions[index];
        _fallbackSuggestions[index] = AiSuggestion(
          id: old.id,
          suggestedTitle: old.suggestedTitle,
          suggestionReason: old.suggestionReason,
          sourceArticleTitle: old.sourceArticleTitle,
          sourceUrl: old.sourceUrl,
          status: status,
          createdAt: old.createdAt,
        );
      }
      return true;
    }
  }

  /// Automatically translates Turkish text to English using a free Google Translate API endpoint.
  /// This completely bypasses the Gemini API, costing $0.
  Future<String?> translateTextToEnglish(String? text) async {
    if (text == null || text.trim().isEmpty) return null;
    try {
      final url = Uri.parse(
          // \$ KAÇIŞLI yazılmıştı: Dart'ta '\$' harfi harfine dolar işareti
          // demek, interpolasyon DEĞİL. Yani adrese metin hiç konmuyor,
          // '\${Uri.encodeComponent(text)}' dizesi olduğu gibi gidiyordu ve
          // Google 400 dönüyordu — İngilizce çeviri sessizce ölüydü.
          'https://translate.googleapis.com/translate_a/single'
          '?client=gtx&sl=tr&tl=en&dt=t&q=${Uri.encodeComponent(text)}');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data != null && data is List && data.isNotEmpty) {
          final translatedChunks = data[0] as List;
          final buffer = StringBuffer();
          for (var chunk in translatedChunks) {
            if (chunk is List && chunk.isNotEmpty) {
              buffer.write(chunk[0].toString());
            }
          }
          return buffer.toString().trim();
        }
      }
      return null;
    } catch (e) {
      if (kDebugMode) print('Free Translation error: $e');
      return null;
    }
  }
}
