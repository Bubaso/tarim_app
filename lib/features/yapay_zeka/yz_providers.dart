import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/supabase_client.dart';
import 'data/yz_deposu.dart';

final yzDeposuProvider = Provider<YzDeposu>((ref) {
  return YzDeposu(ref.watch(supabaseClientProvider));
});

/// Haber kimliği → etiket. Onay kuyruğu kartı her haber için buradan okuyor.
final yzEtiketHaritasiProvider = FutureProvider<Map<String, YzEtiket>>((ref) {
  return ref.read(yzDeposuProvider).etiketHaritasi();
});

/// Bir durumdaki etiketler (`aktif`, `sinirda`, `kaldirildi`).
final yzEtiketListesiProvider =
    FutureProvider.family<List<YzEtiket>, String>((ref, durum) {
  return ref.read(yzDeposuProvider).etiketListesi(durum);
});

/// Onay bekleyen güncelleme önerileri.
final yzKuyrukProvider = FutureProvider<List<YzGuncelleme>>((ref) {
  return ref.read(yzDeposuProvider).kuyruk();
});

/// Son kapsamlı tarama (aylık hatırlatma — karar 19).
final yzSonTaramaProvider = FutureProvider<Map<String, dynamic>?>((ref) {
  return ref.read(yzDeposuProvider).sonKapsamliTarama();
});

/// OKUR TARAFI — bölümün haber akışı. `null` bütün bölüm, sayı bir başlık.
final yzBolumHaberleriProvider =
    FutureProvider.family<List<YzHaber>, int?>((ref, baslikNo) {
  return ref
      .read(yzDeposuProvider)
      .bolumHaberleri(baslikNo: baslikNo, limit: baslikNo == null ? 24 : 12);
});

/// Bir etiket ya da kuyruk kararı yazıldıktan sonra her şeyi tazeler.
void yzTazele(WidgetRef ref) {
  ref.invalidate(yzEtiketHaritasiProvider);
  ref.invalidate(yzEtiketListesiProvider);
  ref.invalidate(yzKuyrukProvider);
  ref.invalidate(yzSonTaramaProvider);
  ref.invalidate(yzBolumHaberleriProvider);
}
