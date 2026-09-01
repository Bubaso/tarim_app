import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/video_haberi.dart';

/// Video haberlerini okur ve panelin onay kararını yazar.
///
/// Onaylanmamış kayıtların dışarı sızmaması GÖRÜNÜMÜN değil RLS'in işi:
/// `anon` rolü yalnızca `durum = 'onaylandi'` satırlarını görüyor. Görünüm
/// atlanabilir, politika atlanamaz.
class VideoRepository {
  final SupabaseClient _supabaseClient;

  VideoRepository(this._supabaseClient);

  /// Anasayfa şeridi.
  Future<List<VideoHaberi>> yayindakiler({int limit = 12}) async {
    try {
      final yanit = await _supabaseClient
          .from('yayindaki_videolar')
          .select()
          .limit(limit);
      return (yanit as List)
          .map((satir) => VideoHaberi.fromJson(satir as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) print('yayindakiler error: $e');
      // Veri gelmezse bölüm hiç görünmüyor. Emtia şeridindeki kuralın aynısı:
      // yanlış ya da boş bir kutu göstermektense hiç göstermemek doğru.
      return [];
    }
  }

  /// Paneldeki onay kuyruğu.
  Future<List<VideoAdayi>> kuyruk({String durum = 'bekliyor'}) async {
    try {
      final yanit = await _supabaseClient
          .from('video_haberleri')
          .select()
          .eq('durum', durum)
          .order('yayim_tarihi', ascending: false)
          .limit(100);
      return (yanit as List)
          .map((satir) => VideoAdayi.fromJson(satir as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) print('kuyruk error: $e');
      return [];
    }
  }

  /// Onaylar ya da reddeder.
  ///
  /// Reddedilen kayıt SİLİNMİYOR. Silinseydi toplayıcı aynı videoyu bir
  /// sonraki taramada yeniden bulur ve editör aynı kararı her gün yeniden
  /// vermek zorunda kalırdı.
  Future<bool> karar(int id, {required bool onay, String? redSebebi}) async {
    try {
      await _supabaseClient.from('video_haberleri').update({
        'durum': onay ? 'onaylandi' : 'reddedildi',
        'red_sebebi': onay ? null : redSebebi,
        'onaylayan': _supabaseClient.auth.currentUser?.id,
        'onay_tarihi': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', id);
      return true;
    } catch (e) {
      if (kDebugMode) print('karar error: $e');
      return false;
    }
  }
}
