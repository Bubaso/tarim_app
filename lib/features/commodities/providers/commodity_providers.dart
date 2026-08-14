import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/supabase_client.dart';
import '../data/models/commodity_price.dart';
import '../data/repositories/commodity_repository.dart';

final commodityRepositoryProvider = Provider<CommodityRepository>((ref) {
  return CommodityRepository(ref.watch(supabaseClientProvider));
});

/// Şeridin verisi.
///
/// StreamProvider ve realtime abonelik bilerek kullanılmadı: fiyat günde bir
/// kez, bülten yayımlandığında değişiyor. Açık bir soket bütün gün boyunca
/// gelmeyecek bir güncellemeyi bekler.
final latestCommodityPricesProvider = FutureProvider<List<CommodityPrice>>((ref) {
  return ref.watch(commodityRepositoryProvider).fetchLatestPrices();
});

/// Detay sayfasındaki grafiğin verisi.
final commodityHistoryProvider =
    FutureProvider.family<List<CommodityPricePoint>, String>((ref, slug) {
  return ref.watch(commodityRepositoryProvider).fetchHistory(slug);
});

/// Tek bir ürünün son fiyatı — şeritten gelen listeden okunuyor.
///
/// Detay sayfası bağlantıyla doğrudan açıldığında (kartın üzerinden değil)
/// şerit verisi zaten yüklü olmuyor; o durumda liste sağlayıcısı kendi
/// isteğini atıyor ve bu sağlayıcı da onunla birlikte doluyor.
final commodityBySlugProvider =
    Provider.family<CommodityPrice?, String>((ref, slug) {
  final prices = ref.watch(latestCommodityPricesProvider).valueOrNull;
  if (prices == null) return null;
  for (final price in prices) {
    if (price.slug == slug) return price;
  }
  return null;
});
