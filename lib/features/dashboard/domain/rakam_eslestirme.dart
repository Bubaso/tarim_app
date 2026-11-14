// ══════════════════════════════════════════════════════════════════════════
//  Rakam ve alıntı eşleştirme — "bu sayı metinde gerçekten var mı?"
// ──────────────────────────────────────────────────────────────────────────
//  Muhabir ajanı kaynaktan rakamları ve alıntıları çıkarıp `figures` ve
//  `quotes` alanlarına yazıyor. Sonra editör ajanı metni yeniden kuruyor.
//  Aradaki adımda bir rakam düşebiliyor, yuvarlanabiliyor ya da değişebiliyor
//  ve bunu kimse görmüyordu: panel rakamları yalnızca LİSTELİYORDU.
//
//  Burası tek bir soruyu cevaplıyor: çıkarılan her rakam, yayınlanacak
//  metinde geçiyor mu? Geçmiyorsa ya editör düşürmüş ya da sayı değişmiş —
//  ikisi de yayından önce görülmesi gereken şeyler.
//
//  NEDEN KAYNAK SAYFAYLA DEĞİL
//  Kaynak metin veritabanında saklanmıyor (yalnız `source_chars`, uzunluğu).
//  Sayfayı yeniden indirmek tarayıcıdan mümkün değil (CORS) ve sunucu
//  tarafı iş. `figures` zaten KAYNAKTAN çıkarılmış veri; onu yayınlanacak
//  metinle karşılaştırmak "kaynaktaki sayı metne sağlam geçti mi" sorusunu
//  cevaplıyor — asıl sorulan da bu.
//
//  TÜRKÇE SAYI YAZIMI
//  9370 metinde "9 bin 370" diye geçiyor. 51 "yüzde 51" ya da "%51".
//  Düz basamak araması bu yüzden yetmiyor ve her rakamı "eksik" gösterirdi —
//  yanlış alarm, uyarının tamamını işe yaramaz hâle getirir. Bir sayının
//  bütün makul yazımları üretilip aranıyor.
// ══════════════════════════════════════════════════════════════════════════

enum Eslesme {
  /// Metinde bulundu.
  bulundu,

  /// Metinde bulunamadı — editör düşürmüş ya da sayı değişmiş olabilir.
  bulunamadi,

  /// Sınanamadı: değer okunamıyor ya da metin yok.
  bilinmiyor,
}

class RakamDenetimi {
  const RakamDenetimi({
    required this.etiket,
    required this.deger,
    required this.birim,
    required this.durum,
    this.bulunanBicim,
  });

  final String etiket;
  final String deger;
  final String birim;
  final Eslesme durum;

  /// Metinde hangi yazımla bulundu — yöneticiye "neyi eşleştirdim"i
  /// gösteriyor. Eşleştirmenin kendisi denetlenebilir olmalı.
  final String? bulunanBicim;
}

class AlintiDenetimi {
  const AlintiDenetimi({
    required this.metin,
    required this.durum,
    this.konusan,
  });

  final String metin;
  final String? konusan;
  final Eslesme durum;
}

/// Metni karşılaştırmaya hazırlar: etiketler sökülür, boşluklar
/// sadeleşir, tırnak çeşitleri tekleşir.
String sadelestir(String? html) {
  if (html == null) return '';
  var s = html
      .replaceAll(RegExp(r'<[^>]+>'), ' ')
      .replaceAll(RegExp(r'&nbsp;?', caseSensitive: false), ' ')
      .replaceAll('&amp;', '&');
  // Tırnak çeşitleri: kaynak “ ” ‘ ’ « » kullanırken metin " ' kullanabiliyor.
  for (final t in ['“', '”', '‘', '’', '«', '»', '"', "'"]) {
    s = s.replaceAll(t, ' ');
  }
  return s.replaceAll(RegExp(r'\s+'), ' ').trim();
}

/// Bir sayının Türkçe metinde geçebileceği yazımlar.
///
/// Örnek: 9370 → "9370", "9.370", "9 370", "9 bin 370"
///        1500 → ... ve "bin 500" (Türkçe "1 bin" demiyor)
///        51   → "51", "%51", "yüzde 51"
List<String> sayiYazimlari(num deger) {
  final yazimlar = <String>{};

  // EKSİ İŞARET METİNDE YAZMIYOR. Figür "-3,2 %" derken metin "yüzde 3,2
  // geriledi" yazıyor: yön sözcükte, rakamda değil. Ölçüldü — kalan
  // bulunamayanların en büyük kümesi buydu ve hepsi yanlış alarmdı.
  if (deger < 0) {
    yazimlar.addAll(sayiYazimlari(-deger));
    yazimlar.add('$deger');
  }
  final mutlak = deger < 0 ? -deger : deger;

  final tam = mutlak is int ? mutlak : mutlak.toInt();
  final ondalikli = mutlak != tam;
  deger = mutlak;

  if (ondalikli) {
    // Türkçede ondalık ayırıcı virgül, ama kaynak nokta da yazabiliyor.
    //
    // SONDAKİ SIFIRLAR: figür 71.2, metin "71,20 TL" yazıyor. Para
    // tutarları neredeyse her zaman iki basamakla yazılıyor ve sınır
    // denetimi "71,2"nin ardındaki 0'ı görüp eşleşmeyi reddediyordu.
    // Ölçüldü: bulunamayan rakamların çoğu buydu.
    for (final basamak in [1, 2, 3]) {
      final s = deger.toStringAsFixed(basamak);
      // Gereksiz uzatma yapma: 71.2 → "71,2" ve "71,20" yeter, "71,200"
      // metinde geçmez ama zararı da yok; üretim ucuz, arama kısa.
      yazimlar.add(s);
      yazimlar.add(s.replaceAll('.', ','));
    }
    yazimlar.add(deger.toString());
    yazimlar.add(deger.toString().replaceAll('.', ','));
    return yazimlar.toList();
  }

  yazimlar.add('$tam');

  if (tam >= 1000) {
    // Binlik ayırıcılar
    final s = tam.toString();
    final bas = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) bas.write('.');
      bas.write(s[i]);
    }
    yazimlar.add(bas.toString());
    yazimlar.add(bas.toString().replaceAll('.', ' '));
  }

  // KÜÇÜK SAYILAR HARFLE YAZILIYOR. Ölçüldü: yanlış alarmların en büyük
  // kaynağı buydu — "5 gün" figürü metinde "beş gün" diye geçiyor ve düz
  // basamak araması onu bulamıyordu.
  if (tam >= 0 && tam <= 20 && _sayiSozcukleri.containsKey(tam)) {
    yazimlar.add(_sayiSozcukleri[tam]!);
  }
  // Sıra sayıları: "1 sıra" figürü metinde "birinci sırada" diye geçiyor.
  if (tam >= 1 && tam <= 10 && _siraSozcukleri.containsKey(tam)) {
    yazimlar.add(_siraSozcukleri[tam]!);
  }

  // Türkçe gruplu yazım: 9 bin 370 · bin 500 · 117 milyon 878 bin 764
  //
  // Haber metni büyük sayıyı neredeyse her zaman böyle yazıyor. Eski sürüm
  // yalnız tam binleri ve tam milyonları üretiyordu; 117.878.764 gibi bir
  // sayıyı hiç yakalayamıyor ve "eksik" diye kırmızı gösteriyordu.
  final gruplu = _grupluYazim(tam);
  if (gruplu != null) yazimlar.add(gruplu);

  return yazimlar.toList();
}

const Map<int, String> _sayiSozcukleri = {
  0: 'sıfır', 1: 'bir', 2: 'iki', 3: 'üç', 4: 'dört', 5: 'beş',
  6: 'altı', 7: 'yedi', 8: 'sekiz', 9: 'dokuz', 10: 'on',
  11: 'on bir', 12: 'on iki', 13: 'on üç', 14: 'on dört', 15: 'on beş',
  16: 'on altı', 17: 'on yedi', 18: 'on sekiz', 19: 'on dokuz', 20: 'yirmi',
};

const Map<int, String> _siraSozcukleri = {
  1: 'birinci', 2: 'ikinci', 3: 'üçüncü', 4: 'dördüncü', 5: 'beşinci',
  6: 'altıncı', 7: 'yedinci', 8: 'sekizinci', 9: 'dokuzuncu', 10: 'onuncu',
};

/// "117 milyon 878 bin 764" · "9 bin 370" · "bin 500" · "2 milyon"
///
/// Haber metninin büyük sayıyı yazdığı biçim bu. Sıfır olan gruplar
/// atlanıyor ve Türkçede "1 milyon"/"1 bin" yerine "milyon"/"bin"
/// denildiği için o basamaklar sayısız yazılıyor.
String? _grupluYazim(int tam) {
  if (tam < 1000) return null;
  final parcalar = <String>[];

  void grup(int bolen, String ad) {
    final n = (tam ~/ bolen) % 1000;
    if (n == 0) return;
    parcalar.add(n == 1 ? ad : '$n $ad');
  }

  grup(1000000000, 'milyar');
  grup(1000000, 'milyon');
  grup(1000, 'bin');
  final birler = tam % 1000;
  if (birler != 0) parcalar.add('$birler');
  return parcalar.isEmpty ? null : parcalar.join(' ');
}

/// Rakamları yayınlanacak metinle eşleştirir.
List<RakamDenetimi> rakamlariDenetle(
  List<dynamic>? figurler,
  String? govdeHtml,
) {
  final govde = sadelestir(govdeHtml);
  final out = <RakamDenetimi>[];
  if (figurler == null) return out;

  for (final ham in figurler) {
    if (ham is! Map) continue;
    final etiket = '${ham['label'] ?? ''}'.trim();
    final birim = '${ham['unit'] ?? ''}'.trim();
    final degerHam = ham['value'];

    final sayi = degerHam is num
        ? degerHam
        : num.tryParse('$degerHam'.replaceAll(',', '.'));

    if (sayi == null || govde.isEmpty) {
      out.add(RakamDenetimi(
        etiket: etiket,
        deger: '$degerHam',
        birim: birim,
        durum: Eslesme.bilinmiyor,
      ));
      continue;
    }

    final adaylar = sayiYazimlari(sayi);
    // Yüzde birimi ayrı yazımlar getiriyor.
    if (birim == '%' || birim.toLowerCase().contains('yüzde')) {
      adaylar.addAll(['%$sayi', 'yüzde $sayi']);
    }

    String? bulunan;
    for (final aday in adaylar) {
      if (_sayiGecerMi(govde, aday)) {
        bulunan = aday;
        break;
      }
    }

    out.add(RakamDenetimi(
      etiket: etiket,
      deger: _sayiYaz(sayi),
      birim: birim,
      durum: bulunan == null ? Eslesme.bulunamadi : Eslesme.bulundu,
      bulunanBicim: bulunan,
    ));
  }
  return out;
}

String _sayiYaz(num s) => s is int || s == s.toInt()
    ? s.toInt().toString()
    : s.toString().replaceAll('.', ',');

/// Sayıyı metinde ararken SINIR gözetiliyor.
///
/// Düz `contains` "51" aramasını "9.513" içinde bulur ve rakamı var sayar.
/// Aranan dizenin iki yanında rakam olmamalı.
bool _sayiGecerMi(String govde, String aday) {
  var i = govde.indexOf(aday);
  while (i != -1) {
    final oncekiTamam =
        i == 0 || !_rakamMi(govde[i - 1]);
    final sonIndeks = i + aday.length;
    final sonrakiTamam =
        sonIndeks >= govde.length || !_rakamMi(govde[sonIndeks]);
    if (oncekiTamam && sonrakiTamam) return true;
    i = govde.indexOf(aday, i + 1);
  }
  return false;
}

bool _rakamMi(String c) => c.codeUnitAt(0) >= 48 && c.codeUnitAt(0) <= 57;

/// Alıntıların metinde geçip geçmediği.
///
/// Tam eşleşme aranmıyor: editör alıntıyı kısaltabiliyor, araya "dedi"
/// ekleyebiliyor. Alıntının BAŞINDAN yeterince uzun bir parça aranıyor —
/// bu parça da yoksa alıntı metne hiç girmemiş demektir.
List<AlintiDenetimi> alintilariDenetle(
  List<dynamic>? alintilar,
  String? govdeHtml,
) {
  final govde = sadelestir(govdeHtml);
  final out = <AlintiDenetimi>[];
  if (alintilar == null) return out;

  for (final ham in alintilar) {
    if (ham is! Map) continue;
    final metin = sadelestir('${ham['text'] ?? ''}');
    final konusan = '${ham['speaker'] ?? ''}'.trim();
    if (metin.isEmpty || govde.isEmpty) {
      out.add(AlintiDenetimi(
        metin: metin,
        konusan: konusan.isEmpty ? null : konusan,
        durum: Eslesme.bilinmiyor,
      ));
      continue;
    }
    // İlk 48 karakter: bir cümlenin başı. Daha kısası rastgele eşleşir,
    // daha uzunu editörün kısaltmasına takılır.
    final parca = metin.length <= 48 ? metin : metin.substring(0, 48);
    out.add(AlintiDenetimi(
      metin: metin,
      konusan: konusan.isEmpty ? null : konusan,
      durum: govde.contains(parca) ? Eslesme.bulundu : Eslesme.bulunamadi,
    ));
  }
  return out;
}
