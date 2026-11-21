import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'data/gomme_cozucu.dart';
import 'data/paylasim_deposu.dart';
import 'data/paylasim_modelleri.dart';

final paylasimDeposuProvider = Provider<PaylasimDeposu>(
  (ref) => PaylasimDeposu(Supabase.instance.client),
);

final gommeCozucuProvider = Provider<GommeCozucu>((ref) => GommeCozucu());

/// Panel kuyruğu — durum başına.
final paylasimKuyruguProvider =
    FutureProvider.family<List<PaylasimBirimi>, String>(
  (ref, durum) => ref.read(paylasimDeposuProvider).kuyruk(durum: durum),
);

/// Sekme rozetindeki sayı. Hat bir aday düşürdüğünde panele giren kişi
/// hangi sekmede olursa olsun görsün diye ayrı tutuluyor.
final bekleyenPaylasimSayisiProvider = FutureProvider<int>((ref) async {
  final liste = await ref.watch(paylasimKuyruguProvider('bekliyor').future);
  return liste.length;
});

/// Bugünün derlemesi; yoksa taslak olarak açılıyor.
final bugununDerlemesiProvider = FutureProvider<PaylasimDerlemesi>(
  (ref) => ref.read(paylasimDeposuProvider).bugununDerlemesi(),
);

/// Bir derlemenin birimleri (taslak dahil).
final derlemeBirimleriProvider =
    FutureProvider.family<List<PaylasimBirimi>, String>(
  (ref, derlemeId) =>
      ref.read(paylasimDeposuProvider).derlemeBirimleri(derlemeId),
);

/// Köşe sayfası: son yedi günün yayındaki derlemeleri.
final sonDerlemelerProvider = FutureProvider<List<PaylasimDerlemesi>>(
  (ref) => ref.read(paylasimDeposuProvider).sonDerlemeler(),
);

/// Ana sayfa şeridi — en son yayındaki derlemenin ilk birkaç paylaşımı.
///
/// Şerit yalnız YAYINDAKİ derlemeyi görüyor; taslak ana sayfaya sızmıyor.
/// Bu, görünümün nezaketi değil RLS'in işi, ama sorgu da aynı şeyi
/// söylüyor olsun.
final tarladanBandiProvider = FutureProvider<List<PaylasimBirimi>>((ref) {
  return ref.watch(paylasimDeposuProvider).bandBirimleri();
});
