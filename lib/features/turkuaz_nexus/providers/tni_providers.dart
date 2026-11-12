import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/supabase_client.dart';
import '../../dossiers/data/models/dosya_haberi.dart';
import '../data/tni_deposu.dart';
import '../data/tni_model.dart';

final tniDeposuProvider = Provider<TniDeposu>((ref) {
  return TniDeposu(ref.watch(supabaseClientProvider));
});

/// Sayfanın birleştirilmiş verisi: gömülü katman + canlı örtü.
///
/// `FutureProvider` ama sayfa BUNU BEKLEMİYOR: yükleme ve hata hâllerinde de
/// gömülü katmanla çizilen bir sonuç veriliyor. Örtü geldiğinde durumlar
/// kendiliğinden yerine oturuyor. Böylece ağ yavaşsa sayfa boş değil, eski
/// doğru hâliyle duruyor.
final tniSayfaVerisiProvider = FutureProvider<TniSayfaVerisi>((ref) async {
  final sonuc = await ref.watch(tniDeposuProvider).ortuGetir();
  return TniSayfaVerisi.birlestir(
    ortu: sonuc.satirlar,
    ortuOkundu: sonuc.okundu,
  );
});

/// Örtüsüz hâl — yükleme ve hata dallarında kullanılıyor.
final tniGomuluVerisi = TniSayfaVerisi.birlestir(ortu: [], ortuOkundu: false);

/// Girişimi anan haberler. Ölçüm: 12 Kasım 2026'da tam üç haber.
final tniHaberleriProvider = FutureProvider<List<DosyaHaberi>>((ref) {
  return ref.watch(tniDeposuProvider).haberler(limit: 6);
});
