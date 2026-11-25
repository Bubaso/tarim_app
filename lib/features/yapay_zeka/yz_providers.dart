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

/// Panel — dizinde duran (onaylanmış) Türkiye dizini kayıtları; "Dizinde"
/// sekmesinden tek tıkla çıkarılıyor (karar 38).
final yzDizindeProvider = FutureProvider<List<YzGuncelleme>>((ref) {
  return ref.read(yzDeposuProvider).kuyruk(durum: 'onaylandi', tur: 'dizin_adayi');
});

/// OKUR TARAFI — §25'e onayla eklenen kuruluşlar (karar 38).
final yzDizinEklenenlerProvider = FutureProvider<List<YzDizinKaydi>>((ref) {
  return ref.read(yzDeposuProvider).dizinEklenenler();
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

/// OKUR TARAFI — haberin bölümde bağlandığı başlık (haber sayfasındaki
/// "bu haberin arka planı" kartı). Etiket yoksa null.
final yzHaberBasligiProvider = FutureProvider.family<int?, String>((ref, articleId) {
  return ref.read(yzDeposuProvider).haberinBasligi(articleId);
});

/// Bir etiket ya da kuyruk kararı yazıldıktan sonra her şeyi tazeler.
void yzTazele(WidgetRef ref) {
  ref.invalidate(yzEtiketHaritasiProvider);
  ref.invalidate(yzEtiketListesiProvider);
  ref.invalidate(yzKuyrukProvider);
  ref.invalidate(yzDizindeProvider);
  ref.invalidate(yzDizinEklenenlerProvider);
  ref.invalidate(yzSonTaramaProvider);
  ref.invalidate(yzBolumHaberleriProvider);
  ref.invalidate(yzHaberBasligiProvider);
}
