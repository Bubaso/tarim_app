import 'package:flutter/material.dart';

/// Bir ülke dosyasının görsel künyesi — `country_dossiers.theme` jsonb'sinden.
///
/// Kuralı Faz 0.5'te koyduk: dosya sayfasında kodda serbest hex yazılmaz.
/// Her ülkenin kendi paleti var ve palet WCAG kontrast hesabıyla birlikte
/// depoda duruyor (`content/dossiers/<slug>/tasarim.json`). Burada yapılan
/// tek şey o nesneyi Flutter renklerine çevirmek.
///
/// Neden bu kadar önemli: Hollanda'nın sodyum turuncusu koyu zeminde 9,10:1
/// kontrast veriyor, açık zeminde 2,04:1 — okunmuyor. Renk ile zemini
/// birbirinden ayırıp "şuraya turuncu koy" demek, bir sonraki ülkede sessizce
/// erişilemez bir sayfa üretir.
@immutable
class DossierTheme {
  /// Sayfa arka planı — gece.
  final Color zemin;

  /// Kart, tablo, alıntı bloğu.
  final Color yuzey;

  /// Gövde metni.
  final Color murekkep;

  /// Meta, kaynak satırı, altyazı.
  final Color sessiz;

  /// Ana vurgu — rakamlar, başlık vurguları, grafiğin birinci serisi.
  final Color vurgu;

  /// İkincil vurgu — karşılaştırmanın öteki tarafı (Türkiye serisi).
  final Color ikincil;

  /// SADECE dekoratif ayırıcı. 3:1'in altında olabilir.
  ///
  /// Anlam taşıyan hiçbir yerde kullanılmaz: grafik ekseni, sınır ve odak
  /// halkası için [cizgiVurgu] var. Bu ayrım tasarim.json'da açık bir uyarı
  /// olarak duruyor, burada da isimle korunuyor.
  final Color cizgi;

  /// Grafik ekseni, ızgara çizgisi, odak halkası — anlam taşıyan çizgiler.
  final Color cizgiVurgu;

  /// Ana sayfa şeridi açık modda bu üçünü kullanır.
  ///
  /// Şerit dosya sayfasının içinde değil, ana sayfanın içinde yaşıyor; oranın
  /// krem zeminine koyu palet oturmuyor. Dosya sayfası her zaman koyu, şerit
  /// sayfayı izler — tek istisna budur.
  final Color seritMurekkep;
  final Color seritVurgu;
  final Color seritIkincil;

  /// Kapak renkleri — gövdeden AYRI olabilir.
  ///
  /// Ülke Dosyası'nda kapak ile gövde aynı: sayfanın tamamı koyu bir ada.
  /// Kurum Dosyası'nda değil — orası fiziksel dosyanın kendisi: dışı koyu
  /// mukavva kapak, içi kağıt.
  ///
  /// `tasarim.json/palet.kapak` bloğu yoksa bu dördü gövde renklerine düşüyor
  /// ve kapak eskisi gibi çiziliyor.
  final Color kapakZemin;
  final Color kapakMurekkep;
  final Color kapakSessiz;
  final Color kapakVurgu;

  /// Polder motifinin opaklığı ve ızgara aralığı.
  ///
  /// Aralık 24 px'in altına inmiyor: retina olmayan ekranlarda moiré titremesi
  /// yapıyor. Sınır motif çiziciye değil buraya konuldu ki tasarım kararı tek
  /// yerde kalsın.
  final double motifOpaklik;
  final double motifAralik;

  const DossierTheme({
    required this.zemin,
    required this.yuzey,
    required this.murekkep,
    required this.sessiz,
    required this.vurgu,
    required this.ikincil,
    required this.cizgi,
    required this.cizgiVurgu,
    required this.seritMurekkep,
    required this.seritVurgu,
    required this.seritIkincil,
    required this.kapakZemin,
    required this.kapakMurekkep,
    required this.kapakSessiz,
    required this.kapakVurgu,
    required this.motifOpaklik,
    required this.motifAralik,
  });

  /// Palet okunamazsa kullanılacak nötr koyu tema.
  ///
  /// Bir dosya, theme sütunu bozuk diye açılmamazlık etmemeli: metin hâlâ
  /// okunabilir olmalı. Buradaki renkler bilerek kimliksiz — "tema gelmedi"
  /// durumu gözle görülür olsun, sessizce Hollanda gibi görünmesin.
  static const DossierTheme yedek = DossierTheme(
    zemin: Color(0xFF101418),
    yuzey: Color(0xFF1B2228),
    murekkep: Color(0xFFE9EDEF),
    sessiz: Color(0xFF9AA5AC),
    vurgu: Color(0xFFD8DEE2),
    ikincil: Color(0xFF9AA5AC),
    cizgi: Color(0xFF2A3239),
    cizgiVurgu: Color(0xFF5B676F),
    seritMurekkep: Color(0xFF16222A),
    seritVurgu: Color(0xFF3A4750),
    seritIkincil: Color(0xFF5B676F),
    kapakZemin: Color(0xFF101418),
    kapakMurekkep: Color(0xFFE9EDEF),
    kapakSessiz: Color(0xFF9AA5AC),
    kapakVurgu: Color(0xFFD8DEE2),
    motifOpaklik: 0.05,
    motifAralik: 28,
  );

  /// `tasarim.json` yapısını çözer. Eksik her alan yedekten tamamlanır.
  ///
  /// Tek tek `?? yedek.x` yazılmasının sebebi: bir alan eksik diye tüm paleti
  /// çöpe atmak, sayfayı gereksiz yere kimliksizleştirir. Sekiz rengin yedisi
  /// gelmişse yedisi kullanılır.
  factory DossierTheme.fromJson(Map<String, dynamic>? json) {
    if (json == null) return yedek;

    final palet = json['palet'];
    if (palet is! Map) return yedek;

    // Anahtar adı 'sayfa'; ülke dosyaları 'koyu' yazıyor ve o adla kalıyor.
    // Ülke Dosyası koyu bir ada, Kurum Dosyası kağıt gövde — aynı alan bir
    // dizide koyu, diğerinde açık renk taşıyor. Geriye dönük okunuyor.
    final koyu = palet['sayfa'] ?? palet['koyu'];
    final serit = palet['serit'] ?? palet['acik_mod_seridi'];
    // Kapak bloğu isteğe bağlı; yoksa kapak gövde renklerini kullanır.
    final kapak = palet['kapak'];
    final motif = json['motif'];

    Color? renk(dynamic blok, String anahtar) {
      if (blok is! Map) return null;
      final girdi = blok[anahtar];
      // İki biçim de kabul: {"hex": "#RRGGBB"} ya da doğrudan "#RRGGBB".
      final ham = girdi is Map ? girdi['hex'] : girdi;
      return _hex(ham?.toString());
    }

    return DossierTheme(
      zemin: renk(koyu, 'zemin') ?? yedek.zemin,
      yuzey: renk(koyu, 'yuzey') ?? yedek.yuzey,
      murekkep: renk(koyu, 'murekkep') ?? yedek.murekkep,
      sessiz: renk(koyu, 'sessiz') ?? yedek.sessiz,
      vurgu: renk(koyu, 'vurgu') ?? yedek.vurgu,
      ikincil: renk(koyu, 'ikincil') ?? yedek.ikincil,
      cizgi: renk(koyu, 'cizgi') ?? yedek.cizgi,
      cizgiVurgu: renk(koyu, 'cizgiVurgu') ?? yedek.cizgiVurgu,
      seritMurekkep: renk(serit, 'murekkep') ?? yedek.seritMurekkep,
      seritVurgu: renk(serit, 'vurguKoyu') ?? yedek.seritVurgu,
      seritIkincil: renk(serit, 'ikincilKoyu') ?? yedek.seritIkincil,
      // Sırayla: kapak bloğu → gövde bloğu → yedek. Ortadaki adım önemli;
      // kapak bloğu olmayan dosyada kapak gövdeyle aynı görünmeli.
      kapakZemin: renk(kapak, 'zemin') ?? renk(koyu, 'zemin') ?? yedek.kapakZemin,
      kapakMurekkep:
          renk(kapak, 'murekkep') ?? renk(koyu, 'murekkep') ?? yedek.kapakMurekkep,
      kapakSessiz: renk(kapak, 'sessiz') ?? renk(koyu, 'sessiz') ?? yedek.kapakSessiz,
      kapakVurgu: renk(kapak, 'vurgu') ?? renk(koyu, 'vurgu') ?? yedek.kapakVurgu,
      motifOpaklik: _yuzde(motif is Map ? motif['uygulama'] : null) ?? yedek.motifOpaklik,
      motifAralik: yedek.motifAralik,
    );
  }

  /// Kapak için türetilmiş tema.
  ///
  /// Kapağın içindeki her şey gövdeyle aynı `tema` nesnesini alıyor. Renkleri
  /// tek tek değiştirmek yerine kapak renklerinin gövde renklerinin yerine
  /// geçtiği bir kopya veriliyor; kapağa yeni bir öğe eklendiğinde renk sorunu
  /// kendiliğinden çözülüyor.
  DossierTheme get kapakTemasi => DossierTheme(
        zemin: kapakZemin,
        yuzey: kapakZemin,
        murekkep: kapakMurekkep,
        sessiz: kapakSessiz,
        vurgu: kapakVurgu,
        ikincil: kapakSessiz,
        cizgi: cizgi,
        cizgiVurgu: cizgiVurgu,
        seritMurekkep: seritMurekkep,
        seritVurgu: seritVurgu,
        seritIkincil: seritIkincil,
        kapakZemin: kapakZemin,
        kapakMurekkep: kapakMurekkep,
        kapakSessiz: kapakSessiz,
        kapakVurgu: kapakVurgu,
        motifOpaklik: motifOpaklik,
        motifAralik: motifAralik,
      );

  /// Açık zeminde okunacak vurgu rengi.
  ///
  /// Ana sayfa şeridi ve paylaşım kartı bunu kullanır. Koyu paletin turuncusu
  /// beyaz üstünde 2,04:1 veriyor — AA sınırının çok altında.
  Color vurguFor({required bool koyuZemin}) => koyuZemin ? vurgu : seritVurgu;

  Color ikincilFor({required bool koyuZemin}) => koyuZemin ? ikincil : seritIkincil;

  static Color? _hex(String? ham) {
    if (ham == null) return null;
    var s = ham.trim().replaceAll('#', '');
    if (s.length == 6) s = 'FF$s';
    if (s.length != 8) return null;
    final v = int.tryParse(s, radix: 16);
    return v == null ? null : Color(v);
  }

  /// "%5 (kabul aralığı %4–8)" gibi bir metinden 0.05 üretir.
  ///
  /// Tasarım dosyası insan tarafından okunmak üzere yazıldı; ilk sayı
  /// bağlayıcı olan, parantez içi yalnızca not. Aralık dışına çıkan bir değer
  /// kırpılıyor: %40 opaklıkta bir motif gövde metnini okunmaz yapar.
  static double? _yuzde(dynamic blok) {
    if (blok is! Map) return null;
    final ham = blok['opaklik']?.toString();
    if (ham == null) return null;
    final eslesme = RegExp(r'(\d+(?:[.,]\d+)?)').firstMatch(ham);
    if (eslesme == null) return null;
    final sayi = double.tryParse(eslesme.group(1)!.replaceAll(',', '.'));
    if (sayi == null) return null;
    return (sayi / 100).clamp(0.02, 0.10);
  }
}
