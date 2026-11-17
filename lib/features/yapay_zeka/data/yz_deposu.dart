import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../home/data/models/news_article.dart';
import 'yz_iskelet.g.dart';

/// `bolum_etiketleri` tablosunun bir satırı — bir haberin Yapay Zeka ve
/// Dijital Tarım bölümüyle ilişkisi.
///
/// Durumlar (göç `20261116120000_yz_bolumu.sql`):
///   * `aktif`      — bölümde görünür; panelden tek tıkla kaldırılır (karar 33)
///   * `sinirda`    — anahtar kelime geçti ama ajan kanıt gösteremedi;
///                    bölümde görünmez, panelden tek tıkla eklenir
///   * `kaldirildi` — editör kaldırdı; hat bunu bir daha ezmez
class YzEtiket {
  const YzEtiket({
    required this.articleId,
    required this.durum,
    required this.kaynak,
    this.baslikNo,
    this.kanit,
    this.kanitDogrulandi = false,
    this.karar,
    this.anahtarlar = const [],
    this.guncellendi,
    this.haberBasligi,
    this.haberDurumu,
    this.haberTarihi,
    this.konu,
    this.kaynakAdi,
  });

  final String articleId;
  final String durum;
  final String kaynak;
  final int? baslikNo;

  /// Ajanın haber metninden BİREBİR kopyaladığı cümle. Editör tek tıkla
  /// karar verirken neye dayandığını buradan görüyor.
  final String? kanit;
  final bool kanitDogrulandi;
  final String? karar;
  final List<String> anahtarlar;
  final DateTime? guncellendi;

  // Liste ekranları için haberin kendisinden birkaç alan (gömülü sorgu).
  final String? haberBasligi;
  final String? haberDurumu;
  final DateTime? haberTarihi;
  final String? konu;
  final String? kaynakAdi;

  bool get aktif => durum == 'aktif';
  bool get sinirda => durum == 'sinirda';
  bool get kaldirildi => durum == 'kaldirildi';
  YzBaslik? get baslik => yzBaslik(baslikNo);

  factory YzEtiket.fromJson(Map<String, dynamic> m) {
    final g = (m['gerekce'] is Map)
        ? Map<String, dynamic>.from(m['gerekce'] as Map)
        : const <String, dynamic>{};
    final h = (m['articles'] is Map)
        ? Map<String, dynamic>.from(m['articles'] as Map)
        : const <String, dynamic>{};
    return YzEtiket(
      articleId: '${m['article_id']}',
      durum: '${m['durum']}',
      kaynak: '${m['kaynak']}',
      baslikNo: (m['baslik_no'] as num?)?.toInt(),
      kanit: g['kanit'] as String?,
      kanitDogrulandi: g['kanit_dogrulandi'] == true,
      karar: g['karar'] as String?,
      anahtarlar: (g['anahtarlar'] is List)
          ? List<String>.from((g['anahtarlar'] as List).map((x) => '$x'))
          : const [],
      guncellendi: DateTime.tryParse('${m['updated_at']}'),
      haberBasligi: h['title'] as String?,
      haberDurumu: h['status'] as String?,
      haberTarihi: DateTime.tryParse('${h['created_at']}'),
      konu: h['topic'] as String?,
      kaynakAdi: h['source_name'] as String?,
    );
  }
}

/// Bölümün haber akışında bir haber: haberin kendisi ve bağlı olduğu başlık.
class YzHaber {
  const YzHaber(this.haber, this.baslikNo);
  final NewsArticle haber;
  final int? baslikNo;
  YzBaslik? get baslik => yzBaslik(baslikNo);
}

/// `bekleyen_guncellemeler` tablosunun bir satırı. Tarama ve hat yalnız
/// ÖNERİR; onaylanan öneri bir sonraki yazım turunun malzemesi olur —
/// hiçbir şey onaysız ya da kendiliğinden yayına girmez (karar 17).
class YzGuncelleme {
  const YzGuncelleme({
    required this.id,
    required this.tur,
    required this.kaynak,
    required this.icerik,
    required this.durum,
    this.baslikNo,
    this.olusturuldu,
  });

  final String id;
  final String tur;
  final String kaynak;
  final Map<String, dynamic> icerik;
  final String durum;
  final int? baslikNo;
  final DateTime? olusturuldu;

  YzBaslik? get baslik => yzBaslik(baslikNo);

  /// Kartın başlığı: kaynağın başlığı, kuruluşun adı ya da sayfanın adı.
  String get baslikMetni =>
      (icerik['baslik'] ?? icerik['ad'] ?? icerik['sayfa'] ?? '').toString();

  String? get adres => (icerik['adres'] as String?)?.trim().isEmpty ?? true
      ? null
      : (icerik['adres'] as String).trim();

  factory YzGuncelleme.fromJson(Map<String, dynamic> m) => YzGuncelleme(
        id: '${m['id']}',
        tur: '${m['tur']}',
        kaynak: '${m['kaynak']}',
        icerik: (m['icerik'] is Map)
            ? Map<String, dynamic>.from(m['icerik'] as Map)
            : const {},
        durum: '${m['durum']}',
        baslikNo: (m['baslik_no'] as num?)?.toInt(),
        olusturuldu: DateTime.tryParse('${m['created_at']}'),
      );
}

/// §25'e editör onayıyla eklenen bir Türkiye kuruluşu (karar 38). Okur
/// tarafı kuyruk tablosunu görmüyor; satır `yz_dizin_eklenenler()`
/// fonksiyonundan geliyor ve yalnız okura açık alanları taşıyor.
class YzDizinKaydi {
  const YzDizinKaydi({
    required this.id,
    required this.ad,
    this.tur,
    this.eklendi,
    this.haberId,
    this.haberBaslik,
    this.haberBaslikEn,
    this.haberTarihi,
  });

  final String id;
  final String ad;

  /// `girisim`, `sirket`, `universite`, `kamu` ya da `diger` (haber hattının
  /// sorusundaki seçenekler).
  final String? tur;
  final DateTime? eklendi;

  /// Kuruluşun adının geçtiği haber — yalnız yayındaysa dolu.
  final String? haberId;
  final String? haberBaslik;
  final String? haberBaslikEn;
  final DateTime? haberTarihi;

  String? haberBasligi(bool en) =>
      en && (haberBaslikEn?.trim().isNotEmpty ?? false) ? haberBaslikEn : haberBaslik;

  factory YzDizinKaydi.fromJson(Map<String, dynamic> m) => YzDizinKaydi(
        id: '${m['id']}',
        ad: '${m['ad'] ?? ''}'.trim(),
        tur: m['tur'] as String?,
        eklendi: DateTime.tryParse('${m['eklendi']}'),
        haberId: m['haber_id'] as String?,
        haberBaslik: m['haber_baslik'] as String?,
        haberBaslikEn: m['haber_baslik_en'] as String?,
        haberTarihi: DateTime.tryParse('${m['haber_tarih']}'),
      );
}

/// Yapay Zeka ve Dijital Tarım bölümünün panel verisi.
///
/// Yazan her metot iki şeyi denetliyor — `HomeRepository.alanlariGuncelle`
/// ile aynı gerekçeyle: oturum (düşmüşse istemci `anon` rolüyle yazar ve RLS
/// satırı HATA VERMEDEN süzer) ve dönen satır sayısı (PostgREST hiçbir
/// satıra denk gelmeyen yazımda da 200 döner).
class YzDeposu {
  YzDeposu(this._db);
  final SupabaseClient _db;

  /// Son yazım hatasının ARAYÜZE gösterilecek açıklaması.
  String? sonHata;

  static const _etiketSutunlari =
      'article_id,durum,baslik_no,kaynak,gerekce,updated_at';

  String? _oturumSorunu() {
    final oturum = _db.auth.currentSession;
    if (oturum == null) return 'Oturum yok — panele yeniden giriş yapın.';
    final bitis = oturum.expiresAt;
    if (bitis != null &&
        DateTime.fromMillisecondsSinceEpoch(bitis * 1000)
            .isBefore(DateTime.now())) {
      return 'Oturum süresi dolmuş — panele yeniden giriş yapın.';
    }
    return null;
  }

  /// Bütün etiketler, haber kimliğine göre. Onay kuyruğu kartı bunu okuyor.
  Future<Map<String, YzEtiket>> etiketHaritasi({int limit = 3000}) async {
    try {
      final veri = await _db
          .from('bolum_etiketleri')
          .select(_etiketSutunlari)
          .eq('bolum', kYzBolumu)
          // ascending AÇIK: PostgREST varsayılanı azalan değil.
          .order('updated_at', ascending: false)
          .limit(limit);
      return {
        for (final m in List<Map<String, dynamic>>.from(veri as List))
          '${m['article_id']}': YzEtiket.fromJson(m),
      };
    } catch (e) {
      if (kDebugMode) print('YzDeposu.etiketHaritasi: $e');
      return const {};
    }
  }

  /// Bir durumdaki etiketler, haberin başlığıyla birlikte (gömülü sorgu).
  Future<List<YzEtiket>> etiketListesi(String durum, {int limit = 300}) async {
    try {
      final veri = await _db
          .from('bolum_etiketleri')
          .select('$_etiketSutunlari,'
              'articles(title,status,created_at,topic,source_name)')
          .eq('bolum', kYzBolumu)
          .eq('durum', durum)
          .order('updated_at', ascending: false)
          .limit(limit);
      return List<Map<String, dynamic>>.from(veri as List)
          .map(YzEtiket.fromJson)
          .toList(growable: false);
    } catch (e) {
      if (kDebugMode) print('YzDeposu.etiketListesi: $e');
      return const [];
    }
  }

  /// Etiketi ayarlar: bölüme al (`aktif`), çıkar (`kaldirildi`) ya da
  /// başlığını değiştir. Editör kararı olarak işaretleniyor (`kaynak =
  /// editor`): hat ve geriye dönük tarama bu satıra bir daha dokunmuyor.
  ///
  /// [baslikNo] verilmezse mevcut başlık korunur — upsert yalnız verilen
  /// sütunları yazıyor.
  Future<bool> etiketAyarla(
    String articleId, {
    required String durum,
    int? baslikNo,
  }) async {
    sonHata = _oturumSorunu();
    if (sonHata != null) return false;
    if (durum == 'aktif' && baslikNo == null) {
      // Bölümde haber bir başlığın altında duruyor (karar 32). Başlıksız
      // aktif etiket, bölümde hiçbir yerde görünmeyen bir haber demek.
      final mevcut = await _tekEtiket(articleId);
      if (mevcut?.baslikNo == null) {
        sonHata = 'Bölüme alırken bir başlık seçin.';
        return false;
      }
    }
    try {
      final yazilan = await _db
          .from('bolum_etiketleri')
          .upsert({
            'article_id': articleId,
            'bolum': kYzBolumu,
            'durum': durum,
            'kaynak': 'editor',
            if (baslikNo != null) 'baslik_no': baslikNo,
          }, onConflict: 'article_id,bolum')
          .select('article_id');
      if ((yazilan as List).isEmpty) {
        sonHata = 'Kayıt yazılmadı: bu oturumun yetkisi yok.';
        return false;
      }
      return true;
    } catch (e) {
      sonHata = e.toString();
      if (kDebugMode) print('YzDeposu.etiketAyarla: $e');
      return false;
    }
  }

  Future<YzEtiket?> _tekEtiket(String articleId) async {
    try {
      final m = await _db
          .from('bolum_etiketleri')
          .select(_etiketSutunlari)
          .eq('article_id', articleId)
          .eq('bolum', kYzBolumu)
          .maybeSingle();
      return m == null ? null : YzEtiket.fromJson(m);
    } catch (_) {
      return null;
    }
  }

  /// Kuyruktaki öneriler, en yeni önce. Varsayılan: onay bekleyenler.
  /// [tur] verilirse yalnız o türden (panelin "Dizinde" sekmesi
  /// onaylanmış `dizin_adayi` satırlarını böyle okuyor).
  Future<List<YzGuncelleme>> kuyruk(
      {String durum = 'bekliyor', String? tur, int limit = 300}) async {
    try {
      var sorgu = _db
          .from('bekleyen_guncellemeler')
          .select('id,tur,baslik_no,kaynak,icerik,durum,created_at')
          .eq('bolum', kYzBolumu)
          .eq('durum', durum);
      if (tur != null) sorgu = sorgu.eq('tur', tur);
      final veri =
          await sorgu.order('created_at', ascending: false).limit(limit);
      return List<Map<String, dynamic>>.from(veri as List)
          .map(YzGuncelleme.fromJson)
          .toList(growable: false);
    } catch (e) {
      if (kDebugMode) print('YzDeposu.kuyruk: $e');
      return const [];
    }
  }

  /// Öneriyi onaylar ya da reddeder. Onaylanan öneri bir sonraki yazım
  /// turunun malzemesi oluyor (karar 17) — TEK İSTİSNA `dizin_adayi`:
  /// onaylanan kuruluş §25'in "Dizine sonradan eklenenler" listesinde okura
  /// görünüyor (karar 38). Onaylanmış dizin kaydını reddetmek onu dizinden
  /// çıkarıyor.
  Future<bool> kuyrukKarari(String id, {required bool onay}) async {
    sonHata = _oturumSorunu();
    if (sonHata != null) return false;
    try {
      final yazilan = await _db
          .from('bekleyen_guncellemeler')
          .update({
            'durum': onay ? 'onaylandi' : 'reddedildi',
            'karar_at': DateTime.now().toUtc().toIso8601String(),
            'karar_veren': _db.auth.currentUser?.id,
          })
          .eq('id', id)
          .select('id');
      if ((yazilan as List).isEmpty) {
        sonHata = 'Karar yazılmadı: kayıt bulunamadı ya da yetki yok.';
        return false;
      }
      return true;
    } catch (e) {
      sonHata = e.toString();
      if (kDebugMode) print('YzDeposu.kuyrukKarari: $e');
      return false;
    }
  }

  /// OKUR TARAFI — bölümün haber akışı (karar 32: haber ilgili başlığın
  /// altında). Yalnız YAYINDAKİ haber ve AKTİF etiket: RLS de aynısını
  /// süzüyor (anon yalnız `published` haberi ve `aktif` etiketi görüyor),
  /// sorgu yine de açıkça yazıyor ki panel oturumunda da okurun gördüğünü
  /// göstersin.
  ///
  /// `!inner`: etiketi olmayan haber satırı hiç gelmesin.
  Future<List<YzHaber>> bolumHaberleri({int? baslikNo, int limit = 12}) async {
    try {
      var sorgu = _db
          .from('articles')
          .select('id,title,slug,summary,created_at,published_at,title_en,'
              'summary_en,source_name,topic,region,image_url,thumb_image_url,'
              'image_lqip,content_type,status,'
              'bolum_etiketleri!inner(baslik_no,durum,bolum)')
          .eq('status', 'published')
          .eq('bolum_etiketleri.bolum', kYzBolumu)
          .eq('bolum_etiketleri.durum', 'aktif');
      if (baslikNo != null) {
        sorgu = sorgu.eq('bolum_etiketleri.baslik_no', baslikNo);
      }
      final veri =
          await sorgu.order('created_at', ascending: false).limit(limit);
      return [
        for (final m in List<Map<String, dynamic>>.from(veri as List))
          YzHaber(
            NewsArticle.fromJson(m),
            ((m['bolum_etiketleri'] as List?)?.isNotEmpty ?? false)
                ? ((m['bolum_etiketleri'] as List).first['baslik_no'] as num?)
                    ?.toInt()
                : null,
          ),
      ];
    } catch (e) {
      if (kDebugMode) print('YzDeposu.bolumHaberleri: $e');
      return const [];
    }
  }

  /// OKUR TARAFI — §25'in dinamik kısmı (karar 38): editörün onayladığı
  /// Türkiye dizini kayıtları, en yeni önce. Kuyruk tablosu okura kapalı;
  /// `yz_dizin_eklenenler()` yalnız okura açık alanları döndürüyor
  /// (supabase/migrations/20261117120000_yz_dizin_okur.sql). Fonksiyon
  /// yoksa — göç uygulanmamışsa — liste boş, sayfa bozulmuyor.
  Future<List<YzDizinKaydi>> dizinEklenenler() async {
    try {
      final veri = await _db.rpc('yz_dizin_eklenenler');
      return [
        for (final m in List<Map<String, dynamic>>.from(veri as List))
          if ('${m['ad'] ?? ''}'.trim().isNotEmpty) YzDizinKaydi.fromJson(m),
      ];
    } catch (e) {
      if (kDebugMode) print('YzDeposu.dizinEklenenler: $e');
      return const [];
    }
  }

  /// Son kapsamlı tarama — bitmiş ve hatasız olanı. Aylık hatırlatmanın
  /// ölçüsü bu (karar 19). Hiç yoksa null.
  Future<Map<String, dynamic>?> sonKapsamliTarama() async {
    try {
      final m = await _db
          .from('tarama_kayitlari')
          .select('basladi,bitti,ozet')
          .eq('bolum', kYzBolumu)
          .eq('tur', 'kapsamli')
          .not('bitti', 'is', null)
          .isFilter('hata', null)
          .order('bitti', ascending: false)
          .limit(1)
          .maybeSingle();
      return m;
    } catch (e) {
      if (kDebugMode) print('YzDeposu.sonKapsamliTarama: $e');
      return null;
    }
  }
}
