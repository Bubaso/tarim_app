import 'package:intl/intl.dart';

/// Haber grafiklerindeki rakamların yazımı.
///
/// **Neden ayrı bir dosya.** Aynı iş dosya (ülke/kurum) tarafında
/// `SayiBicimi.bicimle` ile DOĞRU yapılıyordu; haber grafiği onu hiç
/// kullanmıyor, kendi içinde `d.toInt().toString()` çağırıyordu. Sonuç:
/// dosyada "45.000 TL/ton", haberde "45000TL/ton". İki tarafın ortak
/// kullanabileceği bir yere taşımak yerine buraya yazıldı çünkü
/// `SayiBicimi` bir dosya modeline (`bolen`/`onek`/`sonek`) bağlı; haber
/// grafiğinin elinde yalnızca ham sayı ve bir birim dizgesi var.
///
/// Türkçe ayıraçlar elle yazılmıyor: binlik `.` ondalık `,` kuralı intl'in
/// `tr_TR` yerelinde gömülü geliyor ve İngilizce sayfada aynı çağrı
/// `1,234.5` üretiyor.

/// Ham sayıyı dile göre yazar: `45000` → `45.000` (tr) / `45,000` (en).
///
/// Ondalık İSTEĞE BAĞLI: tam sayıda hiç basamak yazılmıyor (`#,##0.#`
/// deseninin `#`i sıfırı yutuyor), kesirli değerde bir basamak kalıyor.
/// Grafiklerdeki değerlerin çoğu tam sayı; hepsine `,0` eklemek rakamı
/// olduğundan daha hassas gösterirdi.
String sayiYaz(num deger, bool isEn) =>
    NumberFormat('#,##0.#', isEn ? 'en_US' : 'tr_TR').format(deger);

/// Metni olduğu gibi bırakan, sayıysa biçimleyen geçit.
///
/// Grafik verisi bir dil modelinden geliyor ve `value` alanı her zaman sayı
/// değil: "veri yok", "1 Ocak-31 Temmuz" gibi dizgeler de düşüyor. Böyle bir
/// değeri sayıya zorlamak onu `0`a çeviriyordu.
String degerYaz(dynamic ham, bool isEn) {
  if (ham == null) return '';
  if (ham is num) return sayiYaz(ham, isEn);
  final metin = ham.toString().trim();
  // Noktalı/virgüllü dizgeyi sayıya çevirmeye ÇALIŞILMIYOR: "1.234,5" ile
  // "1.234.5" (sürüm numarası) aynı deseni veriyor ve ayırmanın güvenilir
  // yolu yok. Belirsizse metin olarak geçiyor.
  final sayi = num.tryParse(metin);
  return sayi == null ? metin : sayiYaz(sayi, isEn);
}

/// Rakamı birimiyle birleştirir.
///
/// İki kural var:
///
/// 1. **Yüzde önde.** TDK yüzde işaretini sayının ÖNÜNE koyuyor: `%45`.
///    İngilizcede tersi: `45%`. Aynı veriyi iki dilde doğru yazmanın tek
///    yolu birimi tanımak.
/// 2. **Araya bölünmez boşluk.** Normal boşluk, dar bir sütunda sayıyı
///    birimden ayırıp alt satıra atabiliyor ("45.000" bir satırda, "TL/ton"
///    ötekinde). U+00A0 bunu engelliyor ve yine de boşluk kadar yer tutuyor.
String birimliYaz(dynamic ham, String birim, bool isEn) {
  final govde = degerYaz(ham, isEn);
  final b = birim.trim();
  if (govde.isEmpty || b.isEmpty) return govde;
  if (b == '%') return isEn ? '$govde%' : '%$govde';
  return '$govde\u00A0$b';
}

/// Tablo hücresinin BAŞINDAKİ büyük tam sayıyı biçimler, gerisine dokunmaz.
///
/// Tablo hücreleri hattan hazır dizge olarak geliyor ("100000 adet",
/// "17 Etap", "60 milyon TL") ve grafik değerlerinden farklı olarak sayı +
/// birim ayrımı yok. Hücreyi bütünüyle sayıya çevirmeye çalışmak metni
/// bozardı; bu yüzden yalnızca başta duran, boşlukla biten tam sayı
/// biçimleniyor.
///
/// **Eşik neden 5 basamak.** Dört basamaklı sayıların çoğu YIL: "2026"yı
/// "2.026" yazmak düpedüz hata olurdu ve tablolarda dönem sütunu yaygın.
/// Türkçe yazımda dört basamaklı sayıda ayıraç zaten zorunlu değil. Beş
/// basamaktan itibaren ayıraçsız okumak güçleşiyor ("100000" kaç?) ve yıl
/// olma ihtimali kalmıyor.
///
/// Ondalık içeren hücreye hiç dokunulmuyor: zaten biçimlenmiş olabilir ve
/// "1.234,5"i yeniden ayrıştırmanın güvenilir yolu yok.
final RegExp _bastakiBuyukSayi = RegExp(r'^(\d{5,})(?=$|\s)');

String hucreYaz(String ham, bool isEn) {
  final metin = ham.trim();
  final e = _bastakiBuyukSayi.firstMatch(metin);
  if (e == null) return ham;
  final sayi = int.tryParse(e.group(1)!);
  if (sayi == null) return ham;
  return sayiYaz(sayi, isEn) + metin.substring(e.end);
}
