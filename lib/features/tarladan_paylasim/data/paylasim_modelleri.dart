import 'package:flutter/foundation.dart';

/// Tarladan Paylaşım — derleme ve birim modelleri.
///
/// ŞEMADAKİ BOŞLUKLAR ÖLÇÜLMÜŞ BİR GERÇEĞİ TAŞIYOR (19 Kasım 2026). Dört
/// mecranın gömme kapısı farklı cömertlikte:
///
///     YouTube    hesap ✓  başlık ✓  küçük görsel ✓
///     X          hesap ✓  başlık ✗  küçük görsel ✗
///     TikTok     hesap ✗  başlık ✗  küçük görsel ✗
///     Instagram  hesap ✗  başlık ✗  küçük görsel ✗
///
/// Bu yüzden [hesap] ve [baslik] null olabilir. BOŞ ALAN SIFIR DEĞİL: hesap
/// null ise hesabı bilmiyoruz demek, hesapsız paylaşım demek değil. Gömme
/// kartı hesabı okura gösteriyor, atıf eksik kalmıyor — ama biz saklayamıyoruz.
@immutable
class PaylasimBirimi {
  final String id;
  final String? derlemeId;
  final String durum; // bekliyor · yayinda · reddedildi
  final String mecra; // x · youtube · tiktok · instagram
  final String url;
  final String? hesap;
  final String? hesapUrl;
  final String? baslik;
  final String? kucukGorsel;

  /// X, YouTube ve TikTok hazır gömme HTML'i veriyor.
  final String? gommeHtml;

  /// Instagram'ın oEmbed'i uygulama kimliği istiyor; iframe yolu istemiyor.
  final String? gommeIframe;

  final String kaynak; // hat · okur · elle
  final bool kaldirmaTalebi;
  final DateTime eklendi;

  /// Toplayıcının editöre bıraktığı bağlam — akışın başlığı ve özeti.
  ///
  /// YAYINA ÇIKMAZ. Köşe sayfası bu alanı hiç okumuyor; yalnız panel
  /// kuyruğunda görünüyor. Gerekçesi `baslik` ile karıştırılmaması:
  /// `baslik` okura çıkan bir alan (mobil künye kartı onu çiziyor) ve
  /// Google'ın özetini paylaşımın kendi başlığıymış gibi göstermek,
  /// künyeye kaynağı olmayan bilgi koymak olurdu.
  ///
  /// Panelde değeri yüksek: kuyruk gömme değil metin listesi, ve
  /// Instagram'da `hesap` da `baslik` da boş geliyor. Bu alan olmadan
  /// Instagram adayı panelde yalnız "Instagram" yazısı olarak duruyor.
  final String? hatNotu;

  const PaylasimBirimi({
    required this.id,
    required this.durum,
    required this.mecra,
    required this.url,
    required this.kaynak,
    required this.eklendi,
    this.derlemeId,
    this.hesap,
    this.hesapUrl,
    this.baslik,
    this.kucukGorsel,
    this.gommeHtml,
    this.gommeIframe,
    this.kaldirmaTalebi = false,
    this.hatNotu,
    this.dikey,
  });

  /// Gömme kodundaki en/boy oranı (en ÷ boy). Bilinmiyorsa null.
  ///
  /// NEDEN GEREKLİ — SHORTS DİKEY. YouTube kutusu 16:9 sabitti; dikey bir
  /// Shorts orada siyah bantların arasında kalırdı. oEmbed yanıtı iframe'e
  /// `width` ve `height` yazıyor (ölçüldü 19 Kasım 2026: yatay videolarda
  /// 200×113), yani oranı ücretsiz öğreniyoruz — ek alan, ek çağrı yok.
  ///
  /// Instagram'da bu yoldan oran gelmiyor; orada gömmenin kendi
  /// `postMessage` ölçüsü kullanılıyor. X ve TikTok ikisini de vermiyor.
  double? get gommeOrani {
    final kod = gommeHtml;
    if (kod == null) return null;
    final en = RegExp(r'width="(\d+)"').firstMatch(kod)?.group(1);
    final boy = RegExp(r'height="(\d+)"').firstMatch(kod)?.group(1);
    final e = double.tryParse(en ?? '');
    final b = double.tryParse(boy ?? '');
    if (e == null || b == null || e <= 0 || b <= 0) return null;
    return e / b;
  }

  /// Dikey paylaşım mı — ÖLÇÜLMÜŞ DEĞER. null = ölçülemedi.
  ///
  /// Ayrı alan olmasının sebebi oEmbed'in yalan söylemesi: 20 Kasım
  /// 2026'da gerçek bir Shorts'la ölçüldü, `shorts_mu` True dedi ama
  /// oEmbed 200×113 — yani 16:9 — bildirdi. YouTube'da orana
  /// güvenilemiyor.
  final bool? dikey;

  /// Kutunun dikey çizilip çizilmeyeceği.
  ///
  /// Ölçülmüş değer varsa o. Yoksa gömme kodundaki orana bakılıyor;
  /// TikTok'ta bu oran doğru geliyor, YouTube'da gelmiyor — ama YouTube
  /// adayları hattan geldiği için ölçülmüş değerleri zaten var.
  bool get dikeyCiz =>
      dikey ?? (gommeOrani != null && gommeOrani! < 1);

  /// Okura gösterilecek ad. Hesap bilinmiyorsa mecra adı yazılıyor —
  /// "bilinmiyor" yazmak okura bir şey söylemez, mecra adı söyler.
  String get gorunenAd => hesap ?? mecraAdi;

  String get mecraAdi => switch (mecra) {
        'x' => 'X',
        'youtube' => 'YouTube',
        'tiktok' => 'TikTok',
        'instagram' => 'Instagram',
        _ => mecra,
      };

  bool get gomulebilir => gommeHtml != null || gommeIframe != null;

  static PaylasimBirimi fromJson(Map<String, dynamic> j) => PaylasimBirimi(
        id: j['id'] as String,
        derlemeId: j['derleme_id'] as String?,
        durum: j['durum'] as String? ?? 'bekliyor',
        mecra: j['mecra'] as String? ?? '',
        url: j['url'] as String? ?? '',
        hesap: j['hesap'] as String?,
        hesapUrl: j['hesap_url'] as String?,
        baslik: j['baslik'] as String?,
        kucukGorsel: j['kucuk_gorsel'] as String?,
        gommeHtml: j['gomme_html'] as String?,
        gommeIframe: j['gomme_iframe'] as String?,
        kaynak: j['kaynak'] as String? ?? 'elle',
        kaldirmaTalebi: j['kaldirma_talebi'] as bool? ?? false,
        hatNotu: j['hat_notu'] as String?,
        dikey: j['dikey'] as bool?,
        eklendi: DateTime.tryParse(j['eklendi'] as String? ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0),
      );
}

/// Günün derlemesi. Günde bir tane; tarih veritabanında tekil.
@immutable
class PaylasimDerlemesi {
  final String id;
  final DateTime tarih;
  final String durum; // taslak · yayinda
  final DateTime? yayimZamani;
  final String? kartBirimiId;

  /// Derlemeye bağlı birimler. Listeyi depo dolduruyor; model kendi
  /// başına sorgu yapmıyor.
  final List<PaylasimBirimi> birimler;

  const PaylasimDerlemesi({
    required this.id,
    required this.tarih,
    required this.durum,
    this.yayimZamani,
    this.kartBirimiId,
    this.birimler = const [],
  });

  bool get yayinda => durum == 'yayinda';

  static PaylasimDerlemesi fromJson(Map<String, dynamic> j,
          {List<PaylasimBirimi> birimler = const []}) =>
      PaylasimDerlemesi(
        id: j['id'] as String,
        tarih: DateTime.tryParse(j['tarih'] as String? ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0),
        durum: j['durum'] as String? ?? 'taslak',
        yayimZamani: DateTime.tryParse(j['yayim_zamani'] as String? ?? ''),
        kartBirimiId: j['kart_birimi_id'] as String?,
        birimler: birimler,
      );
}
