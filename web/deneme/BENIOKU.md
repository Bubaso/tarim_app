# web/deneme/

Canlıya çıkan ama siteye bağlı OLMAYAN deneme sayfaları. Hiçbir yerden
bağlantı verilmiyor; adresi bilen açıyor.

Neden `onizleme/` değil: `firebase.json` içindeki `ignore` listesi
`onizleme/**` girdisiyle o klasörü dağıtım dışı bırakıyor (orası dosya
önizleme JSON'larının yerel çalışma alanı). Oraya konan bir sayfa
sessizce yüklenmiyor ve `**` yakalayıcısı Flutter kabuğunu döndürüyor —
yani sayfa "çalışıyor" gibi görünüyor ama içeriği hiç gelmiyor.

Buradaki dosyalar karara bağlandıktan sonra silinmeli; deneme sayfası
kalıcı hâle gelirse ne olduğu unutuluyor.
