/// Türkçe metin dönüşümleri.
///
/// **Neden var.** Dart'ın `toUpperCase()`'i değişmez kültür (invariant culture)
/// kullanıyor ve noktalı i'yi bilmiyor: `'üretici'` → `'ÜRETICI'`, `'Türkiye'`
/// → `'TÜRKIYE'`. Yanlış harf de bir büyük harf olduğu için gözle fark edilmesi
/// zor; iki ayrı turda da hatayı test ve önizleme yakaladı, okuma yakalamadı.
///
/// **Dil bayrağı ihmal edilemez.** Kuralı İngilizceye uygulamak ters yönde
/// bozuyor: `'Institution'` → `'INSTİTUTİON'`. Bu yüzden bayraksız bir kısayol
/// bilerek YOK — çağıran taraf hangi dilde yazdığını söylemek zorunda.
///
/// Bu dosya 10 Eylül 2026'da yazılmış, 4 Ekim 2026'daki iCloud kaybında
/// gitmişti (commit edilmemişti) ve 5 Ekim 2026'da CLAUDE.md §8.14.3'teki
/// tarifinden geri yazıldı.
library;

/// Dile göre büyük harfe çevirir.
///
/// Türkçede önce `i` → `İ` ve `ı` → `I` eşlemesi yapılıyor, sonra kalanı
/// standart dönüşüme bırakılıyor. Sıra önemli: `ı` önce çevrilseydi ürettiği
/// `I` ikinci adımda yerinde kalırdı ama `i`'nin çevrimi onu etkilemezdi —
/// yine de ikisini tek yerde tutmak karışıklığı bitiriyor.
String buyukHarf(String metin, bool isEn) => isEn
    ? metin.toUpperCase()
    : metin.replaceAll('i', 'İ').replaceAll('ı', 'I').toUpperCase();

/// Dile göre küçük harfe çevirir.
///
/// Ters yöndeki tuzak: `'İSTANBUL'.toLowerCase()` → `'i̇stanbul'` (i + birleşen
/// nokta, iki kod noktası). Arama ve karşılaştırmada bu iki karakterli dizge
/// hiçbir şeyle eşleşmiyor.
String kucukHarf(String metin, bool isEn) => isEn
    ? metin.toLowerCase()
    : metin.replaceAll('I', 'ı').replaceAll('İ', 'i').toLowerCase();

/// Etiket adresinin ASCII slug'ı — `etiket_slug` SQL fonksiyonunun EŞİ.
///
/// İkisi birebir aynı sonucu vermek ZORUNDA: istemci bağlantıyı bu fonksiyonla
/// kuruyor, sunucu eşleştirmeyi ötekiyle yapıyor. Ayrışırlarsa çip bir yere
/// götürür ama sayfa boş çıkar — ve hiçbir hata vermez.
///
/// Harf eşlemesi ÖNCE, `toLowerCase()` SONRA: Dart'ın `toLowerCase()`i 'İ'
/// harfinde birleşik karakter üretiyor (§39.5). Eşleme önce yapılınca
/// küçültmeye yalnızca ASCII kalıyor.
String etiketSlug(String metin) {
  const esleme = {
    'ı': 'i', 'İ': 'i', 'ş': 's', 'Ş': 's', 'ğ': 'g', 'Ğ': 'g',
    'ü': 'u', 'Ü': 'u', 'ö': 'o', 'Ö': 'o', 'ç': 'c', 'Ç': 'c',
    'â': 'a', 'Â': 'a', 'î': 'i', 'Î': 'i', 'û': 'u', 'Û': 'u',
  };
  final sb = StringBuffer();
  for (final r in metin.runes) {
    final c = String.fromCharCode(r);
    sb.write(esleme[c] ?? c);
  }
  return sb
      .toString()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
}
