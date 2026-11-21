import 'dart:convert';

import 'package:http/http.dart' as http;

/// Bağlantıdan gömme verisi çözer — TARAYICIDA.
///
/// Hattaki `src/sosyal/cozucu.py` ile aynı işi yapıyor; ikisi bilerek ayrı
/// duruyor çünkü biri panelin yapıştırma kutusunu, öteki toplama hattını
/// besliyor. İkisi de aynı ölçüme dayanıyor.
///
/// NEDEN SUNUCU DEĞİL TARAYICI (ölçüldü, 19 Kasım 2026)
/// ----------------------------------------------------
/// Üç oEmbed ucu da CORS başlığı gönderiyor:
///
///     publish.x.com     access-control-allow-origin: https://tarimportali.net
///     youtube.com       access-control-allow-origin: https://tarimportali.net
///     tiktok.com        access-control-allow-origin: *
///
/// Yani panel bağlantıyı doğrudan çözebiliyor; sunucu fonksiyonu
/// gerekmiyor. Instagram'da zaten ağ çağrısı yok — iframe adresi koddan
/// kuruluyor, çünkü Graph oEmbed'i uygulama kimliği istiyor (ölçüldü: 400
/// "Provide valid app ID") ama `/p/<kod>/embed/` istemiyor.
///
/// HER ŞEY BİR IFRAME'E İNİYOR (ölçüldü, gözle doğrulandı)
/// ---------------------------------------------------------
/// Dört mecranın dördü de bir iframe adresine indirgenebiliyor:
///
///     X          platform.twitter.com/embed/Tweet.html?id=<id>
///     YouTube    oEmbed html'indeki iframe src'si
///     TikTok     oEmbed html'indeki iframe src'si
///     Instagram  instagram.com/p/<kod>/embed/
///
/// Bu yüzden sayfada TEK TİP bileşen var: HTML enjeksiyonu yok, X'in
/// `widgets.js`'i (94 KB) hiç yüklenmiyor, blockquote ayrıştırılmıyor.
/// X'in iframe'i tarayıcıda açılıp gözle doğrulandı: avatar, metin, tarih
/// ve beğeni sayısıyla tam tweet çiziliyor.
///
/// YAN BULGU: okur gömme kartında ETKİLEŞİM SAYISINI GÖRÜYOR ama bize
/// veri olarak gelmiyor. Sıralamanın etkileşime göre yapılamamasının
/// sebebi bu — görünmediği için değil, elimize geçmediği için.
///
/// ÖLÇÜM TUZAĞI — BİR KEZ DÜŞÜLDÜ
/// -------------------------------
/// X'in oEmbed'i önce SAHTE bir tweet kimliğiyle denendi (`status/1`), 404
/// geldi ve "kapı kapanmış" sanıldı. Kapı açıktı, girdi yanlıştı. 404 burada
/// "paylaşım yok ya da gizli" demek — mecranın kapandığı anlamına gelmez.
class GommeCozucu {
  GommeCozucu({http.Client? istemci}) : _istemci = istemci ?? http.Client();

  final http.Client _istemci;
  static const _zamanAsimi = Duration(seconds: 20);

  static final _kaliplar = <String, RegExp>{
    'x': RegExp(r'^https?://(www\.)?(x|twitter)\.com/[^/]+/status/(\d+)'),
    'youtube': RegExp(
        r'^https?://(www\.)?(youtube\.com/watch\?|youtu\.be/|youtube\.com/shorts/)'),
    'tiktok': RegExp(r'^https?://(www\.)?tiktok\.com/@[^/]+/video/(\d+)'),
    'instagram':
        RegExp(r'^https?://(www\.)?instagram\.com/(p|reel|tv)/([A-Za-z0-9_-]+)'),
  };

  /// YouTube kimliğini üç ayrı biçimden çıkarır.
  static final _ytKimlik = <RegExp>[
    RegExp(r'^https?://(?:www\.)?youtube\.com/watch\?(?:.*&)?v=([A-Za-z0-9_-]+)'),
    RegExp(r'^https?://(?:www\.)?youtu\.be/([A-Za-z0-9_-]+)'),
    RegExp(r'^https?://(?:www\.)?youtube\.com/shorts/([A-Za-z0-9_-]+)'),
  ];

  /// Bağlantıyı tek bir kanonik biçime indirger.
  ///
  /// NEDEN ŞART — ŞEMANIN GÜVENCESİ BUNA DAYANIYOR
  ///
  /// `paylasim_birimleri.url` tekil ve bu tekillik İKİ İŞ yapıyor: aynı
  /// paylaşım iki kez giremiyor VE reddedilmiş bir paylaşım ikinci
  /// taramada geri gelemiyor. İkisi de yalnız aynı paylaşımın HER ZAMAN
  /// aynı metne indirgenmesiyle çalışır.
  ///
  /// Ölçülmüş çatışma: Google Alerts Instagram paylaşımını
  /// `instagram.com/reel/<kod>/` diye veriyor, insan panele
  /// `instagram.com/p/<kod>/` yapıştırıyor. Aynı paylaşım, farklı metin —
  /// tekillik yakalayamaz, reddedilen geri döner. Aynısı `twitter.com` ile
  /// `x.com`, `youtu.be` ile `watch?v=` arasında da var; üstüne mecraların
  /// kendi izleme kuyrukları (`?s=20`, `?is_from_webapp=1`).
  ///
  /// Hattaki `src/sosyal/cozucu.py` içindeki `normalle()` AYNI biçimleri
  /// üretiyor. İkisi ayrışırsa panel ile hat farklı metin yazar.
  static String normalle(String url) {
    final temiz = url.trim();
    if (temiz.isEmpty) return temiz;

    final x = _kaliplar['x']!.firstMatch(temiz);
    if (x != null) {
      final hesap = temiz.split('/status/').first.split('/').last;
      return 'https://x.com/$hesap/status/${x.group(3)}';
    }

    for (final kalip in _ytKimlik) {
      final m = kalip.firstMatch(temiz);
      if (m != null) return 'https://www.youtube.com/watch?v=${m.group(1)}';
    }

    final tt = _kaliplar['tiktok']!.firstMatch(temiz);
    if (tt != null) {
      final hesap = temiz.split('/video/').first.split('/@').last;
      return 'https://www.tiktok.com/@$hesap/video/${tt.group(2)}';
    }

    final ig = _kaliplar['instagram']!.firstMatch(temiz);
    if (ig != null) {
      // reel ve tv de /p/ ile gömülüyor; ölçüldü (19 Kasım 2026).
      return 'https://www.instagram.com/p/${ig.group(3)}/';
    }

    return temiz;
  }

  static const _oembed = <String, String>{
    'x': 'https://publish.x.com/oembed?omit_script=1&dnt=1&url=',
    'youtube': 'https://www.youtube.com/oembed?format=json&url=',
    'tiktok': 'https://www.tiktok.com/oembed?url=',
  };

  /// Mecrayı tanır; bilinmiyorsa null.
  static String? mecrayiTani(String url) {
    final temiz = url.trim();
    for (final girdi in _kaliplar.entries) {
      if (girdi.value.hasMatch(temiz)) return girdi.key;
    }
    return null;
  }

  /// Bağlantıyı veritabanına yazılabilir bir satıra çevirir.
  ///
  /// Dolduramadığı alanı null bırakır. Çözülemezse [CozulemediHatasi] atar;
  /// çağıran kullanıcıya ne olduğunu söyler, sessizce yutmaz.
  Future<Map<String, dynamic>> coz(String url) async {
    final mecra = mecrayiTani(url.trim());
    // Kanonik biçim ÇÖZMEDEN ÖNCE kuruluyor: veritabanına yazılan metin de,
    // mecraya sorulan adres de aynı olsun.
    final temiz = normalle(url);
    if (mecra == null) {
      throw const CozulemediHatasi(
          'Tanınmayan mecra. X, YouTube, TikTok ve Instagram paylaşım '
          'bağlantıları kabul ediliyor.');
    }

    // PANEL TARAFINDA DİKEYLİK ADRESTEN OKUNUYOR. Tarayıcı
    // `youtube.com/shorts/<id>` sondasını yapamıyor (çapraz kaynak,
    // yönlendirme okunamıyor), ama yapıştırılan adresin biçimi zaten
    // söylüyor. `watch?v=` biçiminde yapıştırılan bir Shorts kaçıyor;
    // editör kutuyu görünce fark eder, hattan gelende ölçüm kesin.
    final ham = url.trim();
    final bool? dikey = (ham.contains('/shorts/') || ham.contains('/reel/'))
        ? true
        : null;

    final satir = <String, dynamic>{
      'mecra': mecra,
      'dikey': dikey,
      'url': temiz,
      'hesap': null,
      'hesap_url': null,
      'baslik': null,
      'kucuk_gorsel': null,
      'gomme_html': null,
      'gomme_iframe': null,
    };

    if (mecra == 'instagram') {
      final kod = _kaliplar['instagram']!.firstMatch(temiz)!.group(3)!;
      satir['gomme_iframe'] = 'https://www.instagram.com/p/$kod/embed/';
      return satir;
    }

    final hedef = Uri.parse(_oembed[mecra]! + Uri.encodeComponent(temiz));
    final http.Response yanit;
    try {
      yanit = await _istemci.get(hedef).timeout(_zamanAsimi);
    } catch (e) {
      throw CozulemediHatasi('Mecraya ulaşılamadı: $e');
    }

    if (yanit.statusCode == 404) {
      throw const CozulemediHatasi(
          'Paylaşım bulunamadı — silinmiş ya da gizli olabilir.');
    }
    if (yanit.statusCode != 200) {
      throw CozulemediHatasi('Mecra ${yanit.statusCode} döndürdü.');
    }
    // YUMUŞAK 404'E KARŞI: duruma değil içerik türüne bakılıyor (§2.12.1).
    final tur = yanit.headers['content-type'] ?? '';
    if (!tur.contains('json')) {
      throw CozulemediHatasi("Beklenen JSON değil, '$tur' geldi.");
    }

    final veri = jsonDecode(yanit.body) as Map<String, dynamic>;
    satir['hesap'] = veri['author_name'];
    satir['hesap_url'] = veri['author_url'];
    satir['baslik'] = veri['title'];
    satir['kucuk_gorsel'] = veri['thumbnail_url'];
    satir['gomme_html'] = veri['html'];

    if (satir['gomme_html'] == null) {
      throw const CozulemediKendiHatasi();
    }

    // Sayfanın çizdiği şey IFRAME. X blockquote veriyor, o yüzden adresi
    // kendimiz kuruyoruz; YouTube ve TikTok'unki html'in içinde duruyor.
    if (mecra == 'x') {
      final id = _kaliplar['x']!.firstMatch(temiz)!.group(3)!;
      satir['gomme_iframe'] =
          'https://platform.twitter.com/embed/Tweet.html?id=$id';
    } else {
      final src = RegExp(r'src="([^"]+)"')
          .firstMatch(satir['gomme_html'] as String)
          ?.group(1);
      if (src == null) {
        throw const CozulemediHatasi(
            'Mecra gömme kodu gönderdi ama içinde iframe adresi yok; '
            'bu paylaşım köşeye konamaz.');
      }
      satir['gomme_iframe'] = src.replaceAll('&amp;', '&');
    }
    return satir;
  }
}

class CozulemediHatasi implements Exception {
  final String mesaj;
  const CozulemediHatasi(this.mesaj);
  @override
  String toString() => mesaj;
}

/// Mecra 200 döndürdü ama gömme HTML'i yok — birim çizilemez.
class CozulemediKendiHatasi extends CozulemediHatasi {
  const CozulemediKendiHatasi()
      : super('Mecra yanıt verdi ama gömme kodu göndermedi; '
            'bu paylaşım köşeye konamaz.');
}
