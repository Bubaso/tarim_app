import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/supabase_client.dart';
import '../data/models/country_dossier.dart';
import '../data/repositories/dossier_repository.dart';

final dossierRepositoryProvider = Provider<DossierRepository>((ref) {
  return DossierRepository(ref.watch(supabaseClientProvider));
});

/// Ana sayfa şeridinin verisi — yayın penceresindeki dosya.
///
/// FutureProvider yeterli: dosya 28 gün boyunca değişmiyor, oturum içinde bir
/// kez çekilip önbellekte kalıyor.
final activeDossierProvider = FutureProvider<DossierSummary?>((ref) {
  return ref.watch(dossierRepositoryProvider).fetchActive();
});

/// Dosya sayfasının verisi. 44 KB `data` bloğu buradan geliyor —
/// yalnızca sayfa gerçekten açıldığında.
final dossierBySlugProvider =
    FutureProvider.family<CountryDossier?, String>((ref, slug) {
  return ref.watch(dossierRepositoryProvider).fetchBySlug(slug);
});

/// /ulkeler arşiv listesi.
final dossierIndexProvider = FutureProvider<List<DossierSummary>>((ref) {
  return ref.watch(dossierRepositoryProvider).fetchIndex();
});
