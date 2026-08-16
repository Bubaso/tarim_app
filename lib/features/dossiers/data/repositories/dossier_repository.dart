import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/country_dossier.dart';

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
  Future<DossierSummary?> fetchActive() async {
    try {
      final response = await _supabaseClient
          .from('active_country_dossier')
          .select()
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
  Future<List<DossierSummary>> fetchIndex() async {
    try {
      final response = await _supabaseClient.from('country_dossier_index').select();
      return (response as List)
          .map((r) => DossierSummary.fromJson(r as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) print('fetchIndex dossier error: $e');
      return [];
    }
  }
}
