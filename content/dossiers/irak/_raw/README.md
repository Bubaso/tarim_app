# Irak — Ülke Dosyası Sayı 05 · kaynak araştırması

Rotasyonda **Pazar** rolü (§2.11, sıra 5). Model → Pazar → Rakip döngüsünde
Avustralya'dan (Model) sonra gelen halka.

---

## Tur 1 — ERİŞİM HARİTASI

Önce bu okunur. Avustralya'da ulusal tarım kurumları kapalıydı ve dosya eyalet
siciline dayanmıştı; Irak'ta durum daha sert: **ülkenin kendi kurumlarının
hiçbiri bu ağdan iş görmüyor.**

### Açık

| kaynak | sınıf | ne veriyor |
|---|---|---|
| UN Comtrade preview API | BAĞIMSIZ | Türkiye–Irak ticareti, fasıl ayrıntısında |
| FAOSTAT toplu indirme (`bulks-faostat.fao.org`) | BAĞIMSIZ | Irak üretimi; 17 MB zip |
| Dünya Bankası API | BAĞIMSIZ | makro göstergeler, 1960'tan bugüne |
| Dünya Bankası belge arama API'si | BAĞIMSIZ | Irak su/tarım raporları |
| `resmigazete.gov.tr/arsiv/<sayı>.pdf` | BİRİNCİL | 1947 onay kanunu nüshası |
| `www5.tbmm.gov.tr` tutanak PDF'leri | BİRİNCİL | antlaşma ve protokol metni |
| `fao.org/4/<belge>.pdf` | BAĞIMSIZ | FAO belgeleri (gerçek PDF) |

### Kapalı — tekrar denenmesin

| kaynak | sonuç |
|---|---|
| Irak İstatistik Kurumu `cosit.gov.iq` | **404** |
| Irak Tarım Bakanlığı `mo-ag.gov.iq` | **000** — bağlantı kurulmuyor |
| Irak Su Kaynakları Bakanlığı `mowr.gov.iq` | 200 ama gövde **139 karakter** — kabuk |
| FAO AQUASTAT ülke profili (HTML) | 200 ama gövde **1.659 karakter** — JavaScript kabuğu |
| FAOSTAT REST API (`fenixservices`) | **521** — ama TOPLU İNDİRME çalışıyor |
| IPC gıda güvenliği | **403** |
| UN-ESCWA sınıraşan sular envanteri | **403** |
| ReliefWeb API | **410** — uç nokta kaldırılmış |
| FAO `countryprofiles` | **404** |
| `fao.org/3/<belge>.pdf` | 200 + `text/html` — **yumuşak 404** (§2.12.1) |

*Yöntem notu:* DSİ dosyasında bir konuyu "kaynaksız" ilan etmeden önce konunun
KENDİ TERİMİNİ aramamıştım ve yanılmıştım. Burada ters sıra uygulandı: önce
arandı, sonra adres denendi. 1946 antlaşmasının kanun numarasını tahmin
etmiştim ve tahmin tutmadı; arama doğru tarihi verdi (kabul 5 Eylül 1947,
RG 12 Eylül 1947) ve oradan TBMM tutanağına ulaşıldı.

---

## Tur 1 — ÖLÇÜLEN İLK RAKAMLAR

Hepsi bu turda canlı çekimle doğrulandı; hiçbiri bellekten yazılmadı.

### Ticaret — dosyanın omurgası

**Türkiye → Irak tarım ihracatı (HS 01-24), 2024: 4,64 milyar dolar**
(24 faslın tamamı dolu). Aynı yıl toplam ihracat 13,00 milyar dolar; yani
Irak'a satılan her üç doların biri tarım.

Fasıl liderleri (milyon dolar, 2024):

| fasıl | | değer |
|---|---|---|
| HS 19 | hamur işleri, bisküvi, makarna | 538,9 |
| HS 08 | meyve ve sert kabuklu yemiş | 498,3 |
| HS 11 | değirmencilik ürünleri — **un** | 496,6 |
| HS 02 | et | 444,4 |
| HS 07 | sebze | 432,8 |
| HS 10 | hububat | 408,3 |
| HS 15 | katı ve sıvı yağlar | 339,6 |
| HS 23 | yem artıkları | 298,1 |

**TERS YÖN NEREDEYSE BOŞ: Irak → Türkiye tarım ithalatı 30,2 milyon dolar.**
Oran **154 kat**. Dizide ölçülen en uç dengesizlik — Avustralya'da denge
3 kat Türkiye lehineydi, burada 154.

### Irak'ın kendi tarımı (Dünya Bankası)

| | yıl | değer |
|---|---|---|
| Nüfus | 2025 | 47.020.774 |
| Tarımın GSYH payı | 2025 | %3,41 |
| Tarımda istihdam | 2025 | %8,17 |
| Tarım arazisi payı | 2024 | %21,65 |
| Tahıl verimi | 2024 | 2.651 kg/ha |
| Gıda ithalatının mal ithalatındaki payı | 2024 | %14,24 |
| **Sulanan arazi payı** | — | **VERİ YOK** |

Son satır dosyanın en anlamlı boşluğu olabilir: suyun belirleyici olduğu bir
ülkede sulanan alan oranı yayımlanmıyor.

---

## AÇIK — tur 2'de karara bağlanacak

1. **AYNA İSTATİSTİK ZORUNLU.** Irak Comtrade'e muhabir olarak neredeyse hiç
   rapor vermiyor: 2018, 2020 ve 2022 için **sıfır satır**, 2024 için bir
   satır. Bütün ticaret rakamları TÜRKİYE'NİN beyanından okunacak ve metinde
   bu açıkça yazılacak — Rusya dosyasındaki "ticaret istatistiği 2022'den beri
   yayımlanmıyor" notunun karşılığı.

2. **ÇİFT SAYIM SÜZGECİ AÇIK** (§2.2.1): `customsCode=C00`, `motCode=0`,
   `partner2Code=0`. Çekimde hem sorguya hem gelen satıra uygulanıyor.
   Avustralya'da tonaj alanları boş geliyordu; Irak muhabirinde ayrıca
   sınanacak.

3. **TEK KAYNAK ÇAPRAZ KONTROLÜ ŞART** (§2.2.1 sonu). Comtrade tek yaka;
   manşet rakam TÜİK ya da FAOSTAT ticaret serisiyle oranlanacak. Beklenen
   oran 1'e yakın; 2'ye yakın çıkarsa çift sayım sayılır.

4. **SU TARAFI — birincil belge elde, metin henüz okunmadı.** 29 Mart 1946
   tarihli Dostluk ve İyi Komşuluk Antlaşması'nın 1 numaralı ek protokolü
   "Dicle, Fırat ve Kolları Sularının Düzene Konması" başlığını taşıyor.
   TBMM S. Sayısı 241 (2,6 MB PDF) indirildi. Protokolün NE SÖYLEDİĞİ
   okunmadan metne tek cümle girmeyecek.

5. **DSİ DOSYASIYLA BAĞ KENDİLİĞİNDEN KURULUYOR.** Kurum Dosyası Sayı 05 dün
   yayımlandı ve GAP'ın Fırat üzerindeki beş barajını adıyla sayıyor. Irak
   o nehrin mansabında. Bağ gerçek ve belgeli — ama **ton dikkat ister**:
   dosya tanıtım değil ülke dosyası, yine de taraf tutan bir anlatı
   kurulmayacak. Veri ne diyorsa o.

6. **§2.8'in beş kategorisi henüz boş.** Özellikle "Türkiye bağı" ve "terk
   edilen ürün" Irak için araştırılacak.
