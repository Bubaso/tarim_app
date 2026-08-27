import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/country_dossier.dart';
import '../models/dosya_haberi.dart';

/// Ülke dosyalarını veritabanından okur.
///
/// Haber deposundan farklı olarak burada realtime abonelik yok: bir dosya 28
/// gün boyunca değişmiyor. Açık bir soket, ay boyunca gelmeyecek bir
/// güncellemeyi beklerdi.
class DossierRepository {
  final SupabaseClient _supabaseClient;

  DossierRepository(this._supabaseClient);

  /// Şu an yayın penceresinde olan dosya — ana sayfa şeridi için.
  ///
  /// `active_country_dossier` görünümü pencereyi ve 'published' durumunu
  /// kendisi süzüyor; burada tekrar filtrelenmiyor ki iki yerde iki farklı
  /// kural oluşmasın. Görünüm `data` sütununu taşımıyor.
  ///
  /// Aktif dosya yoksa null döner ve ana sayfa bölümü hiç çizilmez —
  /// boş bir başlık göstermektense hiç göstermemek doğru.
  /// [tur] ile süzmek ZORUNLU. Görünüm her diziden bir satır döndürüyor
  /// (`distinct on (tur)`); süzülmezse `maybeSingle` iki satır görüp hata
  /// verir ve ana sayfa bandı sessizce boşalır.
  Future<DossierSummary?> fetchActive({String tur = 'ulke'}) async {
    try {
      final response = await _supabaseClient
          .from('active_country_dossier')
          .select()
          .eq('tur', tur)
          .maybeSingle();
      if (response == null) return null;
      return DossierSummary.fromJson(response);
    } catch (e) {
      if (kDebugMode) print('fetchActive dossier error: $e');
      return null;
    }
  }

  /// Tek bir dosyanın tamamı — metin sayfası için.
  ///
  /// İki sorgu atılıyor: ağır satır (44 KB `data`) ve bölümler. Tek sorguda
  /// gömülü seçimle de alınabilirdi ama o zaman `data` bloğu her bölüm
  /// satırıyla birlikte tekrar tekrar serileşirdi.
  ///
  /// Arşivden okunan dosyalar da buradan geliyor: RLS 'published' ve
  /// 'archived' olanı açıyor, taslağı açmıyor.
  Future<CountryDossier?> fetchBySlug(String slug) async {
    try {
      final satir = await _supabaseClient
          .from('country_dossiers')
          .select()
          .eq('slug', slug)
          .maybeSingle();
      if (satir == null) return null;

      final bolumler = await _supabaseClient
          .from('dossier_sections')
          .select()
          .eq('dossier_id', satir['id'])
          .order('ord', ascending: true);

      return CountryDossier(
        summary: DossierSummary.fromJson(satir),
        data: (satir['data'] as Map?)?.cast<String, dynamic>() ?? const {},
        charts: CountryDossier.parseCharts(satir['charts']),
        sections: (bolumler as List)
            .map((r) => DossierSection.fromJson(r as Map<String, dynamic>))
            .toList(),
      );
    } catch (e) {
      if (kDebugMode) print('fetchBySlug dossier error: $e');
      return null;
    }
  }

  /// Arşiv listesi — /ulkeler sayfası.
  ///
  /// `country_dossier_index` görünümü `data`'yı taşımıyor: on iki ülkelik bir
  /// liste yarım megabayt indirmemeli.
  Future<List<DossierSummary>> fetchIndex({String tur = 'ulke'}) async {
    try {
      // Türe göre süzülüyor: /ulkeler yalnızca ülkeleri, /kurumlar yalnızca
      // kurumları listeliyor. İki dizinin birbiriyle ilgisi yok.
      //
      // Bu satır bir kez süzgeçsiz kaldı ve kimse fark etmedi: imzada `tur`
      // duruyordu ama gövde onu kullanmıyordu, analyzer da bunu hata saymıyor.
      // Arşiv testi artık bunu yakalıyor.
      final response = await _supabaseClient
          .from('country_dossier_index')
          .select()
          .eq('tur', tur);
      return (response as List)
          .map((r) => DossierSummary.fromJson(r as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) print('fetchIndex dossier error: $e');
      return [];
    }
  }

  /// Dosyayla ilgili haberler — dosya sayfasının altındaki bölüm.
  ///
  /// Eşleşme dosyanın kendi ilan ettiği anahtar kelimeleriyle kuruluyor
  /// (`country_dossiers.anahtar_kelimeler`), metinden sezilmiyor. Puanlama ve
  /// eşik sunucuda; bkz. `dosya_haberleri` fonksiyonu.
  ///
  /// Boş dönmesi normal ve sessiz: eşleşen haber yoksa bölüm hiç çizilmiyor.
  /// Yanlış haber göstermektense hiç göstermemek doğru.
  Future<List<DosyaHaberi>> fetchDosyaHaberleri(String slug,
      {int limit = 6}) async {
    try {
      final yanit = await _supabaseClient.rpc(
        'dosya_haberleri',
        params: {'p_slug': slug, 'p_limit': limit},
      );
      return (yanit as List)
          .map((r) => DosyaHaberi.fromJson((r as Map).cast<String, dynamic>()))
          .toList();
    } catch (e) {
      if (kDebugMode) print('fetchDosyaHaberleri error: $e');
      return [];
    }
  }

  /// Haberin ilgili olduğu dosyalar — haber sayfasındaki şerit.
  ///
  /// Ters yön. Yalnızca gövdede geçmek YETMİYOR: bir haberin metninde adı
  /// geçen her ülke için şerit çıkarmak gürültü olurdu.
  Future<List<HaberinDosyasi>> fetchHaberDosyalari(String articleId) async {
    if (articleId.isEmpty) return [];
    try {
      final yanit = await _supabaseClient.rpc(
        'haber_dosyalari',
        params: {'p_article_id': articleId},
      );
      return (yanit as List)
          .map((r) =>
              HaberinDosyasi.fromJson((r as Map).cast<String, dynamic>()))
          .toList();
    } catch (e) {
      if (kDebugMode) print('fetchHaberDosyalari error: $e');
      return [];
    }
  }

  /// Yaklaşan dosyalar — arşivin altındaki "Yakında" kartları.
  ///
  /// Boş dönmesi normal: takvimde söz yoksa arşiv yalnızca yayımlanmışları
  /// gösterir ve hiçbir şey eksilmez.
  Future<List<DossierTakvim>> fetchTakvim({String tur = 'ulke'}) async {
    try {
      final response = await _supabaseClient
          .from('dossier_takvim')
          .select()
          .eq('tur', tur)
          .order('sira', ascending: true);
      return (response as List)
          .map((e) => DossierTakvim.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) print('fetchTakvim error: $e');
      return [];
    }
  }
}