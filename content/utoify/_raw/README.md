# 16. UTOİFY — sergi hattı günlüğü

Anasayfanın sonunda, kapanış bloğuyla altbilgi arasında duran sergi bandı ve
kendi sayfası (`/sergi`). 12 Kasım 2026'da kuruldu.

```
iki PDF → kunye_cikar.py → veri_kur.py → veri.json → goc_uret.py → göç
                        ↘ gorsel_cikar.py → web/sergi/utoify-16/ (114 kare)
```

## Kaynaklar

| dosya | bayt | sha256 (ilk 16) | adres |
|---|---:|---|---|
| `16th_utoify_odul.pdf` | 3.534.448 | `93f3730e5934757f` | https://www.tarimormaninsan.com/16th_utoify_odul.pdf |
| `16th_utoify_sergileme.pdf` | 21.073.267 | `f9271563a1321807` | https://www.tarimormaninsan.com/16th_utoify_sergileme.pdf |
| `brosur.pdf` | 3.703.992 | `e339cc1c90c25ef1` | https://www.tarimorman.gov.tr/EYDB/Belgeler/utoify/16UTOIFYbrosur.pdf |

Üçü de **git'te tutulmuyor** (ikili ham kaynak kuralı). Kayıtları
`content/dossiers/_ortak/ham_kaynaklar.json` içinde; yeniden indirilip sha256
ile doğrulanabiliyor.

## Ölçülenler

**114 kare: 14 ödül + 100 sergileme.** Hepsi künyeli — fotoğrafçı adı, eser
adı, yer. Künye kaynağın kendisinde olduğu için atıf sorunu yok.

**42 il, 11 yabancı ülke.** Türkiye'den 85 kare, dışarıdan 29. Trabzon tek
başına 11 kareyle önde; ardından Konya 5, Afyonkarahisar 4, Manisa 4.
Yabancı ülkeler: Çin 9, Bangladeş 3, Hindistan 3, İran 3, Endonezya 2,
Vietnam 2, Rusya 2, Hollanda 2, İtalya 1, Nepal 1, Myanmar 1.

**Çözünürlük tavanı düşük ve bu her yerde böyle.** Ödül kareleri 613×399,
sergileme kareleri 549×364, ikisi de CMYK. Yarışmanın kendi sitesi yalnız
`/400/` servis ediyor; `/800/`, `/1200/`, `/orijinal/` 404 veriyor. Yani
bundan büyüğü **hiçbir yerde yok**. Sayfa bu yüzden kareyi büyütmüyor;
ışık kutusunda kare kendi boyutunda duruyor, büyüyen şey künye oluyor.

**16. yarışmanın albümü sitede YOK.** Albümler menüsü 2025'te bitiyor,
`/Yarisma/16` boş kabuk döndürüyor (9.825 bayt, `/Yarisma/17` ile birebir
aynı). Sonuçlar şu an yalnız bu iki PDF olarak var.

**Her eserin bir hikâyesi var ve yayımlanmadı.** Şartname: *"Katılımcıların
başvurduğu her eserin bir hikâyesi olacaktır. Hikâyesi olmayan eserlere ait
başvurular kabul edilmeyecektir."* O hikâyeler hiçbir yerde yayımlanmıyor —
istenirse sayfanın en güçlü eki olurdu.

## Dört tuzak — hepsi ölçüldü

**1. Görsel sırası yerleşim sırası DEĞİL.** `page.images` kaynak sözlüğü
sırasını veriyor. Sayfa 1'de metnin 3. satırı "The Last Racks" ama kaynak
sırasındaki 3. görsel kazlardı. Sırayla eşlemek **birinin fotoğrafını
başkasının adına yazmak** demekti. Eşleşme görselin sayfadaki y konumundan
kuruluyor.

**2. Düz metin sütunları birleştiriyor.** "Abdulmecit ÇEVRİM Bulgur Şırnak,
Türkiye" — ad nerede biter belli değil. Sütunlar `extraction_mode="layout"`
ile ayrılıyor.

**3. Düzen kipi sözcük bölüyor.** Kerning yüzünden "Endonez ya", "Ar tvin",
"Ispar ta", "Türk iye". Düz kipte bu yok. Bu yüzden **sütunlar düzen kipinden,
sözcükler düz kipten**.

**4. Uzun ad ve eser ismi satır taşırıyor, hem de düzensiz yönde.** Sayfa 9'da
ad önce taşıyor ("Muzaffer Murat" / sonraki satırda "İLHAN"); sayfa 14'te eser
ismi iki ayrı satıra dağılıp araya başka kayıt giriyor. Konuma ya da komşuluğa
dayalı sezgiler bunu çözmedi — iki geçişli yöntem çözdü: adlar düzen kipinden
toplanıp düz metinde çapa olarak kullanılıyor, kayıt sınırları oradan çıkıyor.

Tek başına kalan "Türkiye" satırı da bir sonraki kaydın adının önüne
yapışıyordu ("Türkiye Ekrem ŞAHİN") ve düz metinde o dizi gerçekten geçtiği
için metin sınaması bile yakalamıyordu. Ülke kümesi önce toplanıyor; ülke adı
asla ad öneki olamıyor.

## Gözle doğrulama

Eşleşme **gözle sınandı**, `_raw/dogrulama/` altındaki temas baskıları:

- `eslesme_ornek.jpg` — taşma yaşanan sayfalardan 18 kayıt. 17'si başlığıyla
  birebir tutuyor (Bulgur→bulgur kaynatma, Kaz→kazlar, Serenti→mısır
  serenderi, The Last Racks→kurutma sehpaları, Elma→elma yığınları,
  Filamingo→flamingo, Eller→avuçtaki fındık), biri makul.
- `odul_eslesme.jpg` — 14 ödülün **14'ü** tutuyor (Ağ Onaran Kadın→ağdaki
  kadın, Tek→ormandaki tek sarı ağaç, Karagöl→göl, Orak→hasat, Üzüm
  Kurutma→havadan kurutma tarlaları).

Ödül künyeleri **elle** yazıldı (`odul_kunyeleri.json`): 3 sütunlu ızgara,
sütun adları taştığında kayıyor ve on dört kayıt için kırılgan bir ayrıştırıcı
yazmak yanlış eşleşmeyi sessizce üretmenin yoluydu. Görsel eşlemesi yine
konumdan.

## Telif

Kareler **fotoğrafçılarının telifinde**. Yarışmanın katılım şartları sayfası
(`tarimormaninsan.com/Katilim-Sartlari`) **boş dönüyor** — menü ve iletişim
dışında tek satır metin yok. Başvuru portalında da görünür bir şartname yok.
Yani kamuya açık bir kullanım lisansı **bulunamadı**; bu araştırmanın bulgusu.

Yayım kararı 12 Kasım 2026'da kullanıcıya ait: sonuçlar kamuya açık bir ilan
ve sergi, bakanlığın ilgili sayfası, eser sahibi ve kaynak bağlantısı dahil
edilerek yayımlanıyor.

Yapı buna göre kuruldu:
- Künye **veritabanı kısıtı**: `fotografci` ve `eser` boş geçilemiyor.
- Kaynak bağlantısı yarışma satırında **zorunlu**, bandın altında ve sayfanın
  künyesinde görünüyor.
- `sergi_eserleri.yayinda` ve `sergi_yarismalari.yayinda` bayrakları: itiraz
  gelirse tek satırlık bir güncelleme tek kareyi de, serginin tamamını da
  sayfadan kaldırıyor. Dağıtım gerekmiyor.

## Teyit bekleyen

Ödül listesinde **Ulusal Birincilik — Şirzat TEMİZ, "Ağ Onaran Kadın",
Vietnam** yazıyor. Ulusal ödül, yurt dışında çekilmiş kare. Muhtemelen doğru
(ulusal = vatandaşlık) ama kaynağın kendi PDF'inden başka teyidi yok.
