import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/supabase_client.dart';
import '../data/models/country_dossier.dart';
import '../data/models/dosya_haberi.dart';
import '../data/repositories/dossier_repository.dart';

final dossierRepositoryProvider = Provider<DossierRepository>((ref) {
  return DossierRepository(ref.watch(supabaseClientProvider));
});

/// Ana sayfa bandının verisi — yayın penceresindeki dosya, dizi başına bir tane.
///
/// Aile parametresi dizi türü. Tek bir sağlayıcı olsaydı iki dizi aynı önbellek
/// girdisini paylaşır, biri diğerini ezerdi.
final activeDossierByTurProvider =
    FutureProvider.family<DossierSummary?, String>((ref, tur) {
  return ref.watch(dossierRepositoryProvider).fetchActive(tur: tur);
});

/// Ülke dosyası kartı.
final activeDossierProvider = FutureProvider<DossierSummary?>((ref) {
  return ref.watch(activeDossierByTurProvider('ulke').future);
});

/// Kurum dosyası kartı.
final activeKurumDossierProvider = FutureProvider<DossierSummary?>((ref) {
  return ref.watch(activeDossierByTurProvider('kurum').future);
});

/// Dosya sayfasının verisi. 44 KB `data` bloğu buradan geliyor —
/// yalnızca sayfa gerçekten açıldığında.
final dossierBySlugProvider =
    FutureProvider.family<CountryDossier?, String>((ref, slug) {
  return ref.watch(dossierRepositoryProvider).fetchBySlug(slug);
});

/// Arşiv listesi — dizi başına ayrı.
final dossierIndexByTurProvider =
    FutureProvider.family<List<DossierSummary>, String>((ref, tur) {
  return ref.watch(dossierRepositoryProvider).fetchIndex(tur: tur);
});

/// /ulkeler arşiv listesi.
final dossierIndexProvider = FutureProvider<List<DossierSummary>>((ref) {
  return ref.watch(dossierIndexByTurProvider('ulke').future);
});

/// Yaklaşan dosyalar — dizi başına.
final dossierTakvimProvider =
    FutureProvider.family<List<DossierTakvim>, String>((ref, tur) {
  return ref.watch(dossierRepositoryProvider).fetchTakvim(tur: tur);
});

/// Dosyayla ilgili haberler. Dosya sayfası açılınca çekiliyor.
final dosyaHaberleriProvider =
    FutureProvider.family<List<DosyaHaberi>, String>((ref, slug) {
  return ref.watch(dossierRepositoryProvider).fetchDosyaHaberleri(slug);
});

/// Haberin ilgili olduğu dosyalar. Haber sayfası açılınca çekiliyor.
///
/// Ayrı sağlayıcı: haber sayfası dosya sayfasının hiçbir verisini yüklemiyor,
/// yalnızca bu küçük listeyi.
final haberDosyalariProvider =
    FutureProvider.family<List<HaberinDosyasi>, String>((ref, articleId) {
  return ref.watch(dossierRepositoryProvider).fetchHaberDosyalari(articleId);
});
