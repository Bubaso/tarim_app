import 'tni_veri.g.dart';

/// Turkuaz Bağlantısallık Girişimi sayfasının veri modeli.
///
/// İKİ KATMAN VAR ve ayrım bilinçli:
///
///   GÖMÜLÜ  `tniVeri` — derlemeye giren sabit. Kaynağı FAO'nun kurucu belgesi
///           ve IISD tutanağı olan her şey burada. Ağ olmadan da çizilir.
///   ÖRTÜ    `public.tni_ortu` — zamanla değişen DURUMLAR. Yalnızca gömülü
///           katmandan farklı olanı taşır.
///
/// Birleştirme tek yönlü: örtü gömülüyü EZER, gömülü örtüyü doldurmaz. Örtü
/// boşsa ya da sorgu düşerse sayfa eksiksiz çizilir, yalnızca `_cekim`
/// tarihindeki fotoğrafı gösterir. Bu, portalın tipik arıza imzasına karşı
/// alınmış bir tedbir: burada hiçbir şey hata vermiyor, sessizce eksiliyor.

// ─── Durum sözlükleri ───────────────────────────────────────────────────────

enum HalkaDurumu {
  /// Oldu ve çıktısı bir kaynakta var.
  gerceklesti,

  /// Tarihi geçti, etkinlik yapıldı, ama sonuç belgesi / taahhüt metni /
  /// katılımcı listesi yayımlanmadı. SESSİZCE "gerçekleşti" sayılmıyor —
  /// takipçinin bütün anlamı bu ayrımda.
  ciktisiYayimlanmadi,

  /// Tarihi henüz gelmedi.
  bekliyor,
}

HalkaDurumu halkaDurumuCoz(String? ham) => switch (ham) {
      'gerceklesti' => HalkaDurumu.gerceklesti,
      'ciktisi_yayimlanmadi' => HalkaDurumu.ciktisiYayimlanmadi,
      _ => HalkaDurumu.bekliyor,
    };

// ─── Tarih çözümü ───────────────────────────────────────────────────────────

/// Halkaların tarihi üç biçimde geliyor: `2030`, `2022-11`, `2026-11-10`.
/// Üçü de sıralanabilir bir güne indiriliyor; eksik alanlar ayın/yılın BAŞI
/// sayılıyor. `tarih_kesin` alanı yalnızca okura ne yazılacağını belirliyor —
/// sıralama her zaman çözülen günle yapılıyor.
DateTime? tniTarihCoz(String? ham) {
  if (ham == null || ham.isEmpty) return null;
  final p = ham.split('-');
  final y = int.tryParse(p[0]);
  if (y == null) return null;
  final a = p.length > 1 ? int.tryParse(p[1]) ?? 1 : 1;
  final g = p.length > 2 ? int.tryParse(p[2]) ?? 1 : 1;
  return DateTime(y, a.clamp(1, 12), g.clamp(1, 31));
}

/// Yıl-ay-gün hassasiyeti. Okura tarih yazarken bu belirleyici: `2030` için
/// "1 Ocak 2030" yazmak uydurma bir kesinlik olurdu.
enum TarihKabasi { yil, ay, gun }

TarihKabasi tniTarihKabasi(String ham) => switch (ham.split('-').length) {
      1 => TarihKabasi.yil,
      2 => TarihKabasi.ay,
      _ => TarihKabasi.gun,
    };

// ─── Örtü satırı ────────────────────────────────────────────────────────────

class TniOrtuSatiri {
  final String kod;
  final String tur;
  final String? durum;
  final String? baslikTr, baslikEn, metinTr, metinEn;
  final String? tarih;
  final String? kaynak;
  final int sira;
  final DateTime? guncellendi;

  const TniOrtuSatiri({
    required this.kod,
    required this.tur,
    this.durum,
    this.baslikTr,
    this.baslikEn,
    this.metinTr,
    this.metinEn,
    this.tarih,
    this.kaynak,
    this.sira = 100,
    this.guncellendi,
  });

  /// Yeni bir kalem mi getiriyor, yoksa yalnız durumu mu eziyor?
  bool get yeniKalem => (baslikTr ?? '').trim().isNotEmpty;

  factory TniOrtuSatiri.jsondan(Map<String, dynamic> j) => TniOrtuSatiri(
        kod: (j['kod'] ?? '') as String,
        tur: (j['tur'] ?? '') as String,
        durum: j['durum'] as String?,
        baslikTr: j['baslik_tr'] as String?,
        baslikEn: j['baslik_en'] as String?,
        metinTr: j['metin_tr'] as String?,
        metinEn: j['metin_en'] as String?,
        tarih: j['tarih'] as String?,
        kaynak: j['kaynak'] as String?,
        sira: (j['sira'] as num?)?.toInt() ?? 100,
        guncellendi: DateTime.tryParse((j['guncellendi'] ?? '') as String),
      );
}

// ─── Halka ──────────────────────────────────────────────────────────────────

class TniHalka {
  final String kod;
  final String tarihHam;
  final DateTime? tarih;
  final TarihKabasi kabalik;
  final bool tarihKesin;
  final String baslikTr, baslikEn, metinTr, metinEn;
  final HalkaDurumu durum;
  final String? durumNotu;
  final String? kaynak;

  /// Durumu canlı örtüden mi geldi? Künye bunu okura söylüyor.
  final bool ortudenGeldi;

  const TniHalka({
    required this.kod,
    required this.tarihHam,
    required this.tarih,
    required this.kabalik,
    required this.tarihKesin,
    required this.baslikTr,
    required this.baslikEn,
    required this.metinTr,
    required this.metinEn,
    required this.durum,
    this.durumNotu,
    this.kaynak,
    this.ortudenGeldi = false,
  });

  String baslik(bool en) => en ? baslikEn : baslikTr;
  String metin(bool en) => en ? metinEn : metinTr;

  /// Bugünden kaç gün sonra? Geçmiş halkalar için negatif.
  int? gunKaldi(DateTime simdi) {
    final t = tarih;
    if (t == null) return null;
    return DateTime(t.year, t.month, t.day)
        .difference(DateTime(simdi.year, simdi.month, simdi.day))
        .inDays;
  }
}

// ─── Bilinmeyen ─────────────────────────────────────────────────────────────

class TniBilinmeyen {
  final String kod;
  final String tr, en;
  final String durumTr, durumEn;
  final bool cozuldu;
  final bool ortudenGeldi;

  const TniBilinmeyen({
    required this.kod,
    required this.tr,
    required this.en,
    required this.durumTr,
    required this.durumEn,
    this.cozuldu = false,
    this.ortudenGeldi = false,
  });

  String ad(bool isEn) => isEn ? en : tr;
  String durum(bool isEn) => isEn ? durumEn : durumTr;
}

// ─── Birleştirilmiş sayfa verisi ────────────────────────────────────────────

class TniSayfaVerisi {
  final List<TniHalka> halkalar;
  final List<TniBilinmeyen> bilinmeyenler;

  /// Örtü okunabildi mi? Okunamadıysa sayfa gömülü katmanla çizilir ve
  /// künyede bunu SÖYLER. Sessiz eksilme yok.
  final bool ortuOkundu;
  final DateTime? ortuGuncellendi;

  const TniSayfaVerisi({
    required this.halkalar,
    required this.bilinmeyenler,
    required this.ortuOkundu,
    this.ortuGuncellendi,
  });

  int get gerceklesen =>
      halkalar.where((h) => h.durum == HalkaDurumu.gerceklesti).length;
  int get askida => halkalar
      .where((h) => h.durum == HalkaDurumu.ciktisiYayimlanmadi)
      .length;
  int get bekleyen =>
      halkalar.where((h) => h.durum == HalkaDurumu.bekliyor).length;
  int get acikBilinmeyen => bilinmeyenler.where((b) => !b.cozuldu).length;

  /// Gömülü katman + örtü. Örtü listesi boş geçilirse sonuç saf gömülü katman.
  factory TniSayfaVerisi.birlestir({
    required List<TniOrtuSatiri> ortu,
    required bool ortuOkundu,
  }) {
    final halkaOrtu = <String, TniOrtuSatiri>{};
    final bilinmeyenOrtu = <String, TniOrtuSatiri>{};
    DateTime? enYeni;
    for (final o in ortu) {
      final i = o.kod.indexOf(':');
      if (i <= 0) continue;
      final anahtar = o.kod.substring(i + 1);
      if (o.tur == 'halka') {
        halkaOrtu[anahtar] = o;
      } else if (o.tur == 'bilinmeyen') {
        bilinmeyenOrtu[anahtar] = o;
      }
      final g = o.guncellendi;
      if (g != null && (enYeni == null || g.isAfter(enYeni))) enYeni = g;
    }

    // ── Halkalar ──────────────────────────────────────────────────────────
    final kronoloji = (tniVeri['kronoloji'] as Map)['halkalar'] as List;
    final halkalar = <TniHalka>[];
    for (final ham in kronoloji) {
      final h = ham as Map;
      final kod = h['kod'] as String;
      final o = halkaOrtu.remove(kod);
      final tarihHam = h['tarih'] as String;
      halkalar.add(TniHalka(
        kod: kod,
        tarihHam: tarihHam,
        tarih: tniTarihCoz(tarihHam),
        kabalik: tniTarihKabasi(tarihHam),
        tarihKesin: (h['tarih_kesin'] as bool?) ?? false,
        baslikTr: (o?.baslikTr ?? h['baslik_tr']) as String,
        baslikEn: (o?.baslikEn ?? h['baslik_en']) as String,
        metinTr: (o?.metinTr ?? h['metin_tr']) as String,
        metinEn: (o?.metinEn ?? h['metin_en']) as String,
        durum: halkaDurumuCoz(o?.durum ?? h['durum'] as String?),
        durumNotu: (o?.durum != null ? null : h['_durum_notu'] as String?),
        kaynak: o?.kaynak ?? h['kaynak'] as String?,
        ortudenGeldi: o != null,
      ));
    }
    // Örtüde kalan halkalar GÖMÜLÜ KATMANDA YOK — yeni kalemler.
    for (final o in halkaOrtu.values) {
      if (!o.yeniKalem || o.tarih == null) continue;
      halkalar.add(TniHalka(
        kod: o.kod,
        tarihHam: o.tarih!,
        tarih: tniTarihCoz(o.tarih),
        kabalik: tniTarihKabasi(o.tarih!),
        tarihKesin: true,
        baslikTr: o.baslikTr!,
        baslikEn: o.baslikEn!,
        metinTr: o.metinTr ?? '',
        metinEn: o.metinEn ?? '',
        durum: halkaDurumuCoz(o.durum),
        kaynak: o.kaynak,
        ortudenGeldi: true,
      ));
    }
    halkalar.sort((a, b) {
      final x = a.tarih, y = b.tarih;
      if (x == null || y == null) return 0;
      return x.compareTo(y);
    });

    // ── Bilinmeyenler ─────────────────────────────────────────────────────
    final bilinmeyenler = <TniBilinmeyen>[];
    for (final ham in tniVeri['bilinmeyenler'] as List) {
      final b = ham as Map;
      final kod = b['kod'] as String;
      final o = bilinmeyenOrtu.remove(kod);
      bilinmeyenler.add(TniBilinmeyen(
        kod: kod,
        tr: (o?.baslikTr ?? b['tr']) as String,
        en: (o?.baslikEn ?? b['en']) as String,
        durumTr: (o?.metinTr ?? b['durum_tr']) as String,
        durumEn: (o?.metinEn ?? b['durum_en']) as String,
        cozuldu: (o?.durum ?? b['durum']) == 'cozuldu',
        ortudenGeldi: o != null,
      ));
    }
    for (final o in bilinmeyenOrtu.values) {
      if (!o.yeniKalem) continue;
      bilinmeyenler.add(TniBilinmeyen(
        kod: o.kod,
        tr: o.baslikTr!,
        en: o.baslikEn!,
        durumTr: o.metinTr ?? '',
        durumEn: o.metinEn ?? '',
        cozuldu: o.durum == 'cozuldu',
        ortudenGeldi: true,
      ));
    }
    // Çözülenler sona: açık kalanlar okurun görmesi gereken kısım.
    bilinmeyenler.sort((a, b) => (a.cozuldu ? 1 : 0) - (b.cozuldu ? 1 : 0));

    return TniSayfaVerisi(
      halkalar: halkalar,
      bilinmeyenler: bilinmeyenler,
      ortuOkundu: ortuOkundu,
      ortuGuncellendi: enYeni,
    );
  }
}
