import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/supabase_client.dart';
import '../data/models/sergi_eseri.dart';
import '../data/sergi_deposu.dart';

final sergiDeposuProvider = Provider<SergiDeposu>((ref) {
  return SergiDeposu(ref.watch(supabaseClientProvider));
});

/// Anasayfa bandı — on iki kare, gün başına seçili.
final sergiGununSecimiProvider =
    FutureProvider<List<SergiEseri>>((ref) {
  return ref.watch(sergiDeposuProvider).gununSecimi();
});

/// Sergi sayfasının tamamı — 114 kare. Yalnız sayfa açıldığında çekiliyor.
final sergiVerisiProvider =
    FutureProvider.family<SergiVerisi?, String>((ref, yarisma) {
  return ref.watch(sergiDeposuProvider).tumu(yarisma: yarisma);
});
