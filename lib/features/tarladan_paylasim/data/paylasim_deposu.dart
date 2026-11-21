import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'paylasim_modelleri.dart';

/// Tarladan Paylaşım — okuma ve yazma.
///
/// Taslak derlemenin ve bekleyen birimin dışarı sızmaması GÖRÜNÜMÜN değil
/// RLS'in işi: `anon` yalnız yayındaki derlemenin yayındaki birimlerini
/// görüyor. Görünüm atlanabilir, politika atlanamaz. (Ölçüldü: taslak
/// derlemede anon 0 satır görüyor, yayına alınınca 4.)
class PaylasimDeposu {
  PaylasimDeposu(this._sb);

  final SupabaseClient _sb;

  static const _derlemeTablo = 'paylasim_derlemeleri';
  static const _birimTablo = 'paylasim_birimleri';

  /// Köşe sayfası: son [gun] günün yayındaki derlemeleri, birimleriyle.
  ///
  /// YEDİ GÜNLÜK PENCERE BURADA, ŞEMADA DEĞİL. Pencere bir yayın kararı;
  /// eski derlemeler veritabanında duruyor, yalnız çizilmiyor.
  Future<List<PaylasimDerlemesi>> sonDerlemeler({int gun = 7}) async {
    try {
      final esik = DateTime.now().subtract(Duration(days: gun));
      final derlemeler = await _sb
          .from(_derlemeTablo)
          .select()
          .eq('durum', 'yayinda')
          .gte('tarih', esik.toIso8601String().substring(0, 10))
          .order('tarih', ascending: false);

      if ((derlemeler as List).isEmpty) return [];
      final kimlikler =
          derlemeler.map((d) => d['id'] as String).toList(growable: false);

      final birimler = await _sb
          .from(_birimTablo)
          .select()
          .inFilter('derleme_id', kimlikler)
          .eq('durum', 'yayinda')
          // SIRALAMA `eklendi`'ye DAYANIYOR. Dört mecranın hiçbiri paylaşımın
          // kendi tarihini vermiyor (ölçüldü); elimizdeki tek güvenilir zaman
          // bizim eklediğimiz an. Ekranda yeniden eskiye.
          .order('eklendi', ascending: false);

      final gruplu = <String, List<PaylasimBirimi>>{};
      for (final satir in birimler) {
        final b = PaylasimBirimi.fromJson(satir);
        (gruplu[b.derlemeId ?? ''] ??= []).add(b);
      }

      return derlemeler
          .map((d) => PaylasimDerlemesi.fromJson(d,
              birimler: gruplu[d['id'] as String] ?? const []))
          .toList();
    } catch (e) {
      if (kDebugMode) print('sonDerlemeler: $e');
      // Veri gelmezse köşe hiç görünmüyor. Emtia ve video şeridindeki
      // kuralın aynısı: yanlış ya da boş bir kutu göstermektense hiç
      // göstermemek doğru.
      return [];
    }
  }

  /// Ana sayfa şeridi: en son yayındaki derlemenin ilk [adet] birimi.
  ///
  /// `bugununDerlemesi()` BURADA KULLANILAMAZ — o işlev derleme yoksa
  /// taslak AÇIYOR, yani yazıyor. Ana sayfayı her açan ziyaretçi için
  /// satır üretmek olurdu.
  ///
  /// Yayındaki derleme yoksa boş dönüyor; şerit de hiç çizilmiyor.
  Future<List<PaylasimBirimi>> bandBirimleri({int adet = 3}) async {
    final derlemeler = await sonDerlemeler(gun: 2);
    if (derlemeler.isEmpty) return [];
    return derlemeler.first.birimler.take(adet).toList();
  }

  /// Panel kuyruğu.
  Future<List<PaylasimBirimi>> kuyruk({String durum = 'bekliyor'}) async {
    try {
      final yanit = await _sb
          .from(_birimTablo)
          .select()
          .eq('durum', durum)
          .order('eklendi', ascending: false)
          .limit(200);
      return (yanit as List)
          .map((s) => PaylasimBirimi.fromJson(s as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) print('kuyruk: $e');
      return [];
    }
  }

  /// Bugünün derlemesi; yoksa taslak olarak açılır.
  ///
  /// Tarih veritabanında tekil olduğu için aynı güne ikinci derleme
  /// açılamıyor — yarış durumunda ikinci çağrı mevcut satırı okuyor.
  Future<PaylasimDerlemesi> bugununDerlemesi() async {
    final bugun = DateTime.now().toIso8601String().substring(0, 10);
    final mevcut = await _sb
        .from(_derlemeTablo)
        .select()
        .eq('tarih', bugun)
        .maybeSingle();
    if (mevcut != null) {
      return PaylasimDerlemesi.fromJson(mevcut);
    }
    final yeni = await _sb
        .from(_derlemeTablo)
        .insert({'tarih': bugun, 'durum': 'taslak'})
        .select()
        .single();
    return PaylasimDerlemesi.fromJson(yeni);
  }

  /// Çözülmüş bir satırı kuyruğa yazar.
  ///
  /// `url` tekil olduğu için aynı paylaşım iki kez giremiyor VE reddedilmiş
  /// bir paylaşım geri gelemiyor. Çağıran bu hatayı kullanıcıya göstermeli;
  /// sessizce yutmak, editörün verdiği kararı görünmez kılar.
  Future<PaylasimBirimi> kuyrugaEkle(Map<String, dynamic> cozulmus,
      {String kaynak = 'elle'}) async {
    final satir = await _sb
        .from(_birimTablo)
        .insert({...cozulmus, 'durum': 'bekliyor', 'kaynak': kaynak})
        .select()
        .single();
    return PaylasimBirimi.fromJson(satir);
  }

  /// Birimi bugünün derlemesine alır ve yayına koyar.
  Future<void> derlemeyeAl(String birimId, String derlemeId) async {
    await _sb
        .from(_birimTablo)
        .update({'derleme_id': derlemeId, 'durum': 'yayinda'})
        .eq('id', birimId);
  }

  /// Reddeder. Kayıt SİLİNMİYOR: url tekilliği sayesinde aynı paylaşım
  /// ikinci taramada geri gelmiyor. Video toplayıcısının kayıtlı gerekçesi.
  Future<void> reddet(String birimId) async {
    await _sb
        .from(_birimTablo)
        .update({'durum': 'reddedildi', 'derleme_id': null})
        .eq('id', birimId);
  }

  /// Yayından çeker.
  Future<void> yayindanCek(String birimId) async {
    await _sb
        .from(_birimTablo)
        .update({'durum': 'bekliyor'})
        .eq('id', birimId);
  }

  /// Kaldırma talebi (47. karar): önce yayından çekiliyor, sonra
  /// işaretleniyor. Şemadaki kısıt yayındaki birime talep konulmasını
  /// engelliyor, o yüzden sıra şart.
  Future<void> kaldirmaTalebi(String birimId) async {
    await _sb
        .from(_birimTablo)
        .update({'durum': 'bekliyor'})
        .eq('id', birimId);
    await _sb
        .from(_birimTablo)
        .update({'kaldirma_talebi': true})
        .eq('id', birimId);
  }

  Future<void> derlemeyiYayinla(String derlemeId) async {
    await _sb.from(_derlemeTablo).update({
      'durum': 'yayinda',
      'yayim_zamani': DateTime.now().toIso8601String(),
    }).eq('id', derlemeId);
  }

  Future<void> derlemeyiGeriCek(String derlemeId) async {
    await _sb
        .from(_derlemeTablo)
        .update({'durum': 'taslak', 'yayim_zamani': null})
        .eq('id', derlemeId);
  }

  /// Paylaşım kartının zemini olacak birimi seçer (42. karar).
  Future<void> kartBirimiSec(String derlemeId, String? birimId) async {
    await _sb
        .from(_derlemeTablo)
        .update({'kart_birimi_id': birimId})
        .eq('id', derlemeId);
  }

  /// Bir derlemenin birimleri (taslak dahil — panel için).
  Future<List<PaylasimBirimi>> derlemeBirimleri(String derlemeId) async {
    try {
      final yanit = await _sb
          .from(_birimTablo)
          .select()
          .eq('derleme_id', derlemeId)
          .order('eklendi', ascending: false);
      return (yanit as List)
          .map((s) => PaylasimBirimi.fromJson(s as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) print('derlemeBirimleri: $e');
      return [];
    }
  }
}
