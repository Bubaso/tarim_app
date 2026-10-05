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
