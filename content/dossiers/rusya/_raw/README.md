# Rusya dosyası — ham veri katmanı

Buradaki `.json` dosyaları **çekilmiş ham veridir**. Elle düzenlenmez.
Bir rakam değişecekse betik yeniden çalıştırılır, JSON yeniden üretilir,
sonra `../build_data.mjs` ile `../data.json` yenilenir.

```
kaynak API/CSV  →  _raw/*.json  →  data.json  →  dosya metni
```

---

## Kapalı kapılar — bu dosyanın Hollanda'dan en büyük farkı

Hollanda dosyasında ülkenin kendi istatistik kurumu (CBS StatLine) vardı:
birincil kaynak, kendi tanımıyla, doğrudan. **Rusya'da o katman yok.**

23 Ağustos 2026'da ölçüldü:

| Kaynak | Sonuç |
|---|---|
| `rosstat.gov.ru` | bağlantı kurulamadı (iki denemede de sıfır yanıt) |
| `customs.gov.ru` | 25 saniyede zaman aşımı |
| `fenixservices.fao.org` (FAOSTAT API) | HTTP 521 — Hollanda'da da böyleydi |

Rus Gümrük İdaresi 2022'den beri ayrıntılı ticaret istatistiği yayımlamıyor;
sitesine erişim ayrı bir sorun. Bu iki şeyi karıştırmamak gerekir: **veri
yayımlanmıyor** (yöntem sorunu) ile **siteye erişilemiyor** (ağ sorunu).
Erişim sorununun ülke engellemesi mi yerel ağ mı olduğu **çözülmedi** —
dosya metninde "erişilemedi" denir, "yasaklandı" denmez.

### Sonuç: bu dosya ayna istatistik kullanır

> **Rusya'ya ait rakamların çoğu Rusya'nın kendi kaydı değildir.**
> Rusya'nın ne sattığını, satın alan ülkelerin kayıtlarından okuyoruz.

Buradan çıkan dört kural — metin bunlara uymak zorunda:

1. **Türkiye–Rusya ticaretinde birincil kaynak TÜİK ve Türkiye gümrük
   kaydıdır.** `comtrade_ikili.json` raporlayan taraf olarak Türkiye'yi
   (792) alıyor. Bu bir zayıflık değil: ilişkinin bize bakan yüzünde veri
   tam bizde.
2. **Rusya'nın üretimi için USDA PSD ve FAOSTAT birlikte okunur.** İkisi de
   tahmin içerir. **Çeliştiklerinde ikisi de yazılır, ortalama alınmaz.**
3. **Ayna olduğu her tabloda yazar.** Okur hangi ülkenin defterine baktığını
   bilmeli.
4. **Yaptırım kapsamındaki ödeme ve lojistik kalemlerinde doğrulanamayan
   hiçbir sayı metne girmez.**

---

## "Ortak yıl + ileri not" kuralı

*(Kullanıcı kararı, 23 Ağustos 2026 — bu diziye kalıcı kural.)*

Karşılaştırma, **iki ülkede de veri bulunan en son ortak yıldan** kurulur.
Ama bir ülkede daha yeni veri varsa, o karşılaştırmanın **hemen altına**
düşülür:

> Rusya'nın tahıl verimi 2023'te 3.167 kg/ha, Türkiye'nin 3.659 kg/ha.
> *(Türkiye'de 2024 rakamı 3.429 kg/ha; Rusya için aynı yıl bulunamadı.)*

Bu kural betiklere gömülü, iyi niyete bırakılmadı:

- `worldbank.json → gostergeler[*]._ortak_son_yil` ve `._ileri_not`
- `usda_psd.json → _ortak_yillar[*].kesin_ortak_son_yil` ve `._ileri_not`

`_ileri_not` doluysa metinde karşılık gelen cümlenin altında bir not
**olmak zorunda**. Doğrulayıcı bunu sınayacak.

Rusya'da bu notların neredeyse hepsi tek yöne bakıyor: **daha yeni veri
hep Türkiye'de.** Bunun kendisi bir bulgu — Rusya'nın uluslararası
raporlaması 2022'den sonra seyrekleşti.

---

## Dosyalar

| Dosya | Üreten betik | Kaynak | Lisans |
|---|---|---|---|
| `worldbank.json` | `wb_fetch.mjs` | World Bank WDI API | CC BY 4.0 |
| `usda_psd.json` | `psd_fetch.mjs` | USDA FAS PSD toplu CSV | ABD kamu malı |
| `comtrade_ikili.json` | `comtrade_fetch.mjs` | UN Comtrade public preview | — |
| `faostat_*.json` | `fao_extract.mjs` | FAOSTAT toplu CSV | CC BY 4.0 |
| `kurumlar.json` | — (elle) | kurumların kendi yayınları | — |

Elle girilen dosyalarda `_giris_yontemi` ve `_dogrulama_tarihi` alanları
zorunlu; birincil kaynaktan teyit edilemeyen kalemler `dogrulanmamis`
bloğuna yazılır ve **metne giremez**.

---

## Bilinmesi gereken tuzaklar

### Comtrade her hücreyi iki kere veriyor

Uç nokta her hücreyi hem toplu hem kırılımlı döndürüyor: `customsCode`
(C00 = tüm gümrük rejimleri, C01/C04/C05/C06 = kırılım) ve `motCode`
(0 = tüm taşıma türleri, 2100/3200… = kırılım). Gelen satırların hepsi
toplanırsa sonuç **gerçeğin tam iki katı** çıkar.

Ölçüldü — 2023, HS 1001 (buğday), Rusya'dan ithalat:

```
C00 / mot 0        5.321.335.842 $   ← doğru
tüm satırlar      10.642.671.684 $   ← iki katı
C01+C04+C05+C06    5.321.335.842 $   ← kırılım, toplamı doğruyu veriyor
```

**Kural: yalnızca `customsCode='C00'` ve `motCode=0`.** Sorguya süzgeç
olarak konuyor *ve* gelen satır ayrıca süzülüyor — iki kere, çünkü bu hata
sessiz. Yanlış rakam makul görünür.

### Comtrade 500 satırda kesiyor — sessizce

Süzgeçsiz sorgu tavana çarpıyor ve veriyi uyarı vermeden kırpıyor. 1. turda
HS 01-24 ithalat sorgusu tam 500 satır döndü; o turdaki 8,87 milyar dolar
bir **taban**dı, gerçek değil. C00/mot0 süzgeci satırı ~7 kat düşürüyor
(85 → 12). Betik yine de her yanıtı tavana karşı sınıyor ve çarparsa hata
atıyor.

### Comtrade hız sınırı sert

Arka arkaya iki istek 429 veriyor. Aralar 6 saniye, 429'da üstel geri
çekilme var. 48 istek yaklaşık 6 dakika sürüyor — normaldir, takılma değil.

### FAOSTAT Türkiye'yi Asya'ya, Rusya'yı Avrupa'ya koyuyor

Tek bölge dosyası indirilirse karşılaştırmanın yarısı **sessizce boş gelir**.
Hata vermez, satır bulunmaz. `fao_fetch.sh` ikisini birden indiriyor.

### FAOSTAT API çalışmıyor

`fenixservices.fao.org` HTTP 521. Hollanda'da da böyleydi, hâlâ böyle.
Toplu CSV zorunlu. `trade/` ve `food_security/` yolları 403 veriyor;
çalışan yol **`production/` altındaki bölge dosyaları**.

### FAOSTAT CSV'lerinde her alan tırnaklı

Satır `"150",` diye başlar, `150,` diye değil.

### PSD'nin son iki yılı ölçüm değil

USDA PSD yürüyen ve gelecek pazarlama yılını da yayımlıyor. Ağustos 2026
itibarıyla **2024 son kesin yıl**, 2025 tahmin, 2026 öngörü. İki ülkenin de
2026 verisi var, yani ham `ortak_son_yil` 2026 çıkıyor — **o yıldan
karşılaştırma cümlesi kurulmaz.** `kesin_ortak_son_yil` kullanılır.

### PSD'de SSCB ayrı bir ülkedir

`Union of Soviet Socialist Repu` 1960-1986, `Russia` 1987'den itibaren.
**Tek seri gibi birleştirilmez:** SSCB on beş cumhuriyettir, Rusya biri.
Metinde ikisi ayrı ayrı adlandırılır. Grafikte aynı eksende gösterilecekse
kırılma noktası işaretlenir.

### PSD pazarlama yılı takvim yılı değildir

Buğdayda Rusya ve Türkiye için Temmuz-Haziran. "2023" = Temmuz 2023 -
Haziran 2024. Takvim yılı serileriyle (Comtrade, World Bank) aynı cümlede
oran olarak kullanılamaz.

### Rusya'nın dolarlı serileri rublenin oynaklığını taşır

`NV.AGR.TOTL.CD` (tarımsal katma değer, cari USD) Rusya için kur hareketiyle
birlikte oynuyor. İki ülkeyi aynı yılda karşılaştırmak geçerli, ama
**Rusya'nın kendi zaman serisindeki iniş çıkış üretim değişimi sanılmamalı.**
Zaman içi karşılaştırma için miktar serisi (PSD, FAOSTAT) kullanılır.

### Birim karıştırma yasağı

Üretim değeri *sabit 2014-16 uluslararası doları*, ticaret *cari ABD doları*,
PSD *bin ton*. Bu üçü birbirine bölünmez. Karşılaştırma yalnızca **aynı
ölçünün iki ülkedeki oranı** üzerinden yapılır.

---

## Yeniden üretim

Doğrudan çalışanlar:

```bash
node content/dossiers/rusya/_raw/wb_fetch.mjs          # ~30 sn
node content/dossiers/rusya/_raw/psd_fetch.mjs         # ~1 dk, 56 MB iner
node content/dossiers/rusya/_raw/comtrade_fetch.mjs    # ~6 dk, hız sınırlı
```

FAOSTAT toplu CSV bekler (~237 MB iner, ~1 GB açılır, depoda tutulmuyor):

```bash
bash content/dossiers/rusya/_raw/fao_fetch.sh
node content/dossiers/rusya/_raw/fao_extract.mjs
node content/dossiers/rusya/build_data.mjs
rm -rf content/dossiers/rusya/_raw/x content/dossiers/rusya/_raw/*.zip
```
