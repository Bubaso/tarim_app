import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/supabase_client.dart';
import '../data/models/video_haberi.dart';
import '../data/repositories/video_repository.dart';

final videoRepositoryProvider = Provider<VideoRepository>((ref) {
  return VideoRepository(ref.watch(supabaseClientProvider));
});

/// Anasayfa şeridinin verisi.
///
/// Emtia şeridiyle aynı gerekçe: realtime abonelik yok. Yayına alma günde
/// birkaç kez, elle oluyor; açık bir soket bütün gün gelmeyecek bir
/// güncellemeyi bekler.
final yayindakiVideolarProvider = FutureProvider<List<VideoHaberi>>((ref) {
  return ref.watch(videoRepositoryProvider).yayindakiler();
});

/// Paneldeki onay kuyruğu.
final videoKuyruguProvider =
    FutureProvider.family<List<VideoAdayi>, String>((ref, durum) {
  return ref.watch(videoRepositoryProvider).kuyruk(durum: durum);
});
