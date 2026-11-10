# TİGEM — Kurum Dosyası Sayı 06 · kaynak araştırması

**Tarım İşletmeleri Genel Müdürlüğü.** Kurum rotasyonunda sıra 6 (§8.13);
DSİ devir göçü takvime "Yakında: TİGEM" yazdı. DSİ penceresi **16 Kasım
2026**'da kapanıyor.

> **SUPABASE KAPALI.** Proje `exceed_storage_size_quota` nedeniyle 402
> veriyor; canlı site içeriksiz. Bu dosyanın 1–9. turları Supabase'e hiç
> dokunmuyor. Yalnız devir (tur 10) bekliyor.

---

## Erişim haritası

Önce bu okunur. **Durum koduna değil içerik türüne ve gövde uzunluğuna
bakıldı** — Irak dosyasının dersi: pek çok kurum sitesi olmayan yol için
200 + text/html döndürüyor.

### Açık

| kaynak | sınıf | ne veriyor |
|---|---|---|
| `tigem.gov.tr/Tarih` | KURUMUN BEYANI | İki kök: Osmanlı haraları ve 1937 Zirai Kombinaları; 1984 birleşmesi |
| `tigem.gov.tr/Hakkimizda` | KURUMUN BEYANI | Ana statü görevleri; "yer kiralar, **kiraya verir**" |
| `tigem.gov.tr/Isletme/Index/1` | KURUMUN BEYANI | Faaliyette olan işletmeler |
| `tigem.gov.tr/Isletme/Index/2` | KURUMUN BEYANI | **Kiraya verilen işletmeler — kiracı şirketlerle birlikte** |
| `tigem.gov.tr/Isletme/Index/3` | KURUMUN BEYANI | İştirakler |
| `tigem.gov.tr/Mevzuat/Index/1,2,3` | — | Ana Statü · kanunlar ve KHK'lar · ikincil mevzuat (61 PDF) |
| `tigem.gov.tr/Bilgi/Tohumluk`, `/Bilgi/Damizlik`, `/Bilgi/Istatistikler` | KURUMUN BEYANI | Tohumluk, damızlık, istatistik sayfaları |
| `resmigazete.gov.tr/arsiv/18435_1.pdf` | **BİRİNCİL** | 233 sayılı KHK'nın yayımlandığı RG nüshası · 11,7 MB · `%PDF` doğrulandı |
| `mevzuat.gov.tr/MevzuatMetin/4.5.233.pdf` | **BİRİNCİL** | 233 sayılı KHK, derlenmiş metin · 524 KB · `%PDF` doğrulandı |
| `sayistay.gov.tr/reports/category/8-kamu-isletmeleri-genel-raporlari` | **BAĞIMSIZ** | Kamu İşletmeleri Genel Raporu, **2015–2024 serisi** |
| `sayistay.gov.tr/reports/download/<id>` | **BAĞIMSIZ** | Raporun kendisi · 2024: 532 KB, 37 sayfa, `%PDF` |

**Sayıştay raporu doğrulandı:** 2024 nüshasının 27. sayfasında TİGEM'in mali
satırı var ve **TMO ile TCDD aynı tabloda** — kurumlar arası karşılaştırma
hazır geliyor. On yıllık seri grafik için yeterli.

### Kapalı ya da sorunlu — tekrar denenmesin

| kaynak | sonuç |
|---|---|
| `tigem.gov.tr/Sayfa/Detay/<ad>` (tahminî yollar) | 200 ama **tam olarak 40.313 bayt** — üç ayrı yol aynı kabuk, yumuşak 404 |
| `tigem.gov.tr/AraziVarligi` | 200, sayfa gerçek, ama HTML'de **ölçülü tek rakam yok** — JavaScript ya da bulunamayan bir PDF |
| `tigem.gov.tr/StratejikPlan` | aynı — gövdede rakam yok |
| `mevzuat.gov.tr/MevzuatMetin/1.3.5433.pdf` | 200 ama **text/html** — yumuşak 404; 1950 Devlet Üretme Çiftlikleri kanunu başka yoldan aranacak |
| `sayistay.gov.tr/reports?q=…` ve `?category=…` | **418** — sorgu parametresine bot savunması. Temiz kategori yolu çalışıyor |
| `sbb.gov.tr/kamu-isletmeleri-raporu/` | 404 |
| `tbmm.gov.tr/komisyon/kit` | 404 — üstelik hata sayfası `image/png` döndürüyor |
| `data.tuik.gov.tr/Kategori/GetKategori` | 200 ama 3,6 KB — JavaScript kabuğu |

---

## Tur 1'de çıkan ve tur 2'ye taşınan izler

**1. İki kök, ikisi de orduyla başlıyor.** `/Tarih` sayfası TİGEM'in iki
koluna işaret ediyor: Osmanlı **haraları** (ordunun ve sarayın iaşesi, at
yetiştirme) ve Cumhuriyet'in **Zirai Kombinaları** (1937; ordunun gerektiğinde
halkın gıda ihtiyacı). İkisi 1984'te 233 sayılı KHK ile tek çatı altında
toplanıyor. §8.9/1 "kurucu kişi ve fikir" için tek kurucu yok — **iki soy** var.

**2. Devletin çiftçisi, çiftliklerinin bir bölümünü kiraya vermiş.**
`/Isletme/Index/2` kiraya verilen işletmeleri kiracı şirketlerin iletişim
bilgileriyle listeliyor (Acıpayam–Denizli, Alparslan–Muş, Altındere–Van,
Atatürk–Yalova, Çiçekdağı–Kırşehir, Gelemen–Samsun…). Ana statü de bunu
açıkça yetki olarak sayıyor: "yer kiralar, kiraya verir". Eksen adayı.

**3. Dizide dördüncü kurum türü.** TMO kırmızı = kamu gücü, Ziraat yeşil =
finans, Tarım Kredi toprak = üretici örgütü, DSİ = altyapı. TİGEM bunların
hiçbiri değil: **devletin bizzat üretici olması.** Küme ve palet tur 6'da
buradan kurulacak.

## Açık kalan — tur 2'de aranacak

1. **Arazi varlığı rakamı.** Kurumun tanımlayıcı sayısı; sayfada yok.
   Sayıştay raporunda ya da faaliyet raporunda aranacak.
2. **TİGEM faaliyet raporları.** Site haritasında görünmedi; `/Folder/`
   altındaki PDF'ler taranacak.
3. **1950 tarihli 5433 sayılı kanun** (Devlet Üretme Çiftlikleri) — Resmî
   Gazete arşivinden sayı numarasıyla aranacak.
4. **İşletme sayıları.** Faaliyette olan ve kiraya verilen işletmelerin
   kesin sayısı; HTML'den sayılacak, menü tekrarından ayıklanarak.
