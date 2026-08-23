# Gömülü yazı tipleri

Paylaşım kartı üreteci bu dosyaları **base64 olarak HTML'e gömer**; Chromium
karta çizerken ağa hiç çıkmaz.

**Neden gömülü.** `networkidle0` ile Google Fonts'tan indirmeyi denedik; tarayıcı
işlemi bu ağda takılıyor ve betik zaman aşımına düşüyor. Daha kötüsü, ağ yavaş
olduğunda ekran görüntüsü **sessizce sistem fontuyla** alınabiliyor — fark ancak
kart paylaşıldığında görülür. Gömülü font bu iki riski birden kaldırıyor.

| Dosya | Kaynak | Alt küme |
|---|---|---|
| `LibreFranklin-latin.woff2` | Google Fonts · Libre Franklin v20 | latin |
| `LibreFranklin-latin-ext.woff2` | Google Fonts · Libre Franklin v20 | latin-ext — **Türkçe için zorunlu** (ğ ş İ ı) |

Değişken font: tek dosya 100–900 arası tüm ağırlıkları taşır.
Lisans: SIL Open Font License 1.1.

Tazelemek için `css2?family=Libre+Franklin:wght@500;600;900` adresini tarayıcı
User-Agent'ı ile çekip woff2 adreslerini yeniden okuyun; Google sürüm
değiştirdiğinde dosya adı da değişir.
