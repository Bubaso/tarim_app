/// Bölümün okuma olayları için İNCE gönderici — ilk yükte durabilecek kadar
/// hafif; bölümün ağır dosyalarını içe aktarmaz.
///
/// Olaylar kişisel veri taşımaz: kimlik, arama sözcüğü, alt başlık metni
/// gitmez. Hatalar yutulur; ölçüm okumayı asla bozmaz.
///
/// KALIP (birleştirme sözleşmesi): öteki gruplar yalnız [yzOlcum]'u çağırır.
void yzOlcum(String olay, Map<String, Object> parametreler) {}
