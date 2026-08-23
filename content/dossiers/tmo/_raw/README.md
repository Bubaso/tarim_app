# TMO — ham kaynaklar

Zincir: **kaynak → `_raw/` → `data.json` → `grafikler.json` → seed → veritabanı.**
Bu klasör zincirin ilk halkası. Buradaki hiçbir dosya elle düzenlenmez;
`./cek.sh` yeniden çalıştırılarak tazelenir.

## Çekilenler

| Dosya | Kaynak | Ne için |
|---|---|---|
| `ana_statu.pdf` | TMO · Mevzuat → Ana Statü | Hukuki kimlik: statü, organlar, faaliyet konuları |
| `faaliyet_2025.pdf` | TMO · Bilgi Merkezi → Faaliyet Raporları | **88. Hesap Dönemi.** Künye, personel, alım, mali tablolar |
| `faaliyet_2024.pdf`, `faaliyet_2022.pdf` | aynı | Seri karşılaştırma |
| `kurum_hakkinda.pdf` | TMO · Genel Müdürlük | Kurumun kendi özeti — *kurumun anlatısı, veri değil* |
| `tasra_teskilati.pdf` | TMO · Genel Müdürlük | Şube/başmüdürlük dağılımı (5. bölüm: taşra ayağı) |
| `site_kanunlar.html` | TMO · Mevzuat → Kanunlar | İlgili kanunlar dizini |

## Doğrulanmış — birincil kaynaktan okundu

### Kuruluş
`kurum_hakkinda.pdf` (TMO'nun kendi metni), `faaliyet_2025.pdf` s.283:

- **3491 sayılı Kanun · kabul 24/6/1938 · RG 13/7/1938.** TMO kendi belgesinde
  bu üçünü birlikte veriyor; Vikipedi de aynı üçlüyü tekrarlıyor. RG **sayısı**
  hiçbir kaynakta geçmiyor — künyede tarih yeterli, sayı aranmayacak.
- Kuruluş öncesi iş **Ziraat Bankası bünyesinde "Buğday Masası Şefliği"**
  olarak yürütülüyordu. TMO o masanın ayrılmasıyla doğdu.
  *(Dizinin 2. sayısı Ziraat Bankası; iki dosya buradan birbirine bağlanıyor.)*
- **Uyuşturucu madde tekeli kuruluş kanununda var** — sonradan eklenmiş bir
  görev değil. Kanunun saydığı görevler: buğday fiyatının üretici aleyhine
  düşmesini ve halk aleyhine yükselmesini engellemek, piyasayı korumak ve
  düzenlemek, gerektiğinde ithalat/ihracat, dünya buğday hareketlerini izlemek,
  gerekli yerlerde un ve ekmek fabrikaları kurmak, **uyuşturucu maddelerle
  ilgili devlet tekelini yürütmek**.

### Ürün yetkisi kanunla değil, kararla genişledi
`kurum_hakkinda.pdf`:

| Tarih | Eklenen |
|---|---|
| 27 Ekim 1939 | arpa, yulaf |
| 28 Kasım 1940 | çavdar |
| 25 Nisan 1941 | mısır |
| 13 Ağustos 1941 | kuru fasulye, pirinç |

Savaş yıllarında liste tarım dışına taştı: benzin, otomobil lastiği, et
kavurması, margarin, kahve, nohut, akdarı, fasulye, mercimek, bakla, börülce,
susam, yağlı tohum, kasaplık hayvan, balık.

### Bugünkü hukuki kimlik — DÜZELTME
`ana_statu.pdf` MADDE 4:

> TMO; tüzel kişiliğe sahip, faaliyetlerinde özerk ve sorumluluğu sermayesiyle
> sınırlı **iktisadi devlet teşekkülüdür**.

- Dayanak: **233 sayılı KHK** (8/6/1984) ve **399 sayılı KHK** (1990).
- **Tarım ve Orman Bakanlığının ilgili kuruluşu.** Merkez Ankara.
- **TBMM ve Sayıştay denetimine tabi** (md. 4/6) — 10. bölümün dayanağı.
- Yürürlükteki Ana Statü **30 Eylül 2021** tarihli Resmî Gazete'de yayımlandı;
  dayanağı **4518 sayılı Cumhurbaşkanı Kararı**. 11/12/1984 tarihli ve 18602
  sayılı RG'de yayımlanan eski Ana Statü'yü yürürlükten kaldırdı.

> **Bir ara "TMO bugün anonim şirket" diye okundu; YANLIŞTI.** Ana Statü'nün
> md. 1'i ve md. 3(i) tanımı "Toprak Mahsulleri Ofisi Anonim Şirketi" diyor,
> ama hukuki bünyeyi kuran md. 4 ve belgenin bütün dipnotları "iktisadi devlet
> teşekkülü" / "kamu iktisadi teşebbüsü" diyor. İkisi çelişiyor; belirleyici
> olan md. 4. Metinde bu tutarsızlığa **iddia olarak değil, belgedeki hâliyle**
> yer verilebilir.

### Sermaye — dört yılda beş kez yazıldı
`ana_statu.pdf` dipnotları. Ana metindeki sermaye 2021'de **2,55 milyar TL**:

| Karar | Tarih | Nominal sermaye |
|---|---|---|
| CB 5893 | 27/7/2022 | 12,55 milyar TL |
| CB 7479 | 7/8/2023 | 52,55 milyar TL |
| CB 7974 | 22/12/2023 | 124,55 milyar TL |
| CB 9730 | 17/4/2025 | **94,55 milyar TL** ← düşürüldü |

### 2025 faaliyeti
`faaliyet_2025.pdf` (88. Hesap Dönemi), Tablo 29:

- Toplam alım **6.150.332 ton · 81.624.184 bin TL**; iç %86, dış %14
- Buğday: program 2.500.000 t → gerçekleşen **3.841.000 t**
- Arpa: program 1.000.000 t → gerçekleşen **171.000 t**
- Alım fiyatları: buğday 13.500 TL/t · arpa 11.000 TL/t · mısır 11.400 / 11.300
- Afyon alkaloidlerinde **piyasada tekel**; Bolvadin'de Afyon Alkaloidleri
  Fabrikası İşletme Müdürlüğü
- Kuraklık: 2025 su yılı yağışı 422,5 mm (normali 573,4; önceki yıl 597) —
  rapor bunu son 52 yılın en düşüğü diyor, kaynak olarak MGM'yi gösteriyor.
  Üretim kaybı buğday %13,7, arpa %25,9.

> **Kuraklık yılında TMO hedefinin üzerinde buğday aldı, arpada ise hedefin
> altında kaldı.** Raporun açıklaması: buğdayda alım fiyatı iç ve dış piyasanın
> üzerinde kaldı, tüccar ve sanayici finansman maliyeti yüzünden çekildi;
> arpada piyasa fiyatı üretici lehine seyredince ürün Ofis'e gelmedi.
> *Bu kurumun kendi anlatısıdır; 11. bölümde bağımsız kayıtlarla karşılaştırılacak.*

### Künyeye GİRMEYECEK
Personel sayısı ve kadro dağılımı **künyeden çıkarıldı** (kullanıcı kararı).
Kurumu anlatan şey bordrosu değil; ölçüsü alım hacmi, sermayesi ve yetki alanı.

## Henüz doğrulanmadı — metne giremez

- **Kuruluşta bağlı olunan makam.** İkincil kaynaklar "Ticaret Vekâleti" diyor;
  TMO'nun kendi metinlerinde geçmiyor. Bir kaynak daha bulunmadan yazılmayacak.
- **233 ve 399 sayılı KHK'ların RG tarih/sayıları.** Kanun tarihleri elde
  (8/6/1984 ve 1990); RG künyeleri yok.
- Cumhurbaşkanlığı sistemine geçişte TMO'yu Tarım ve Orman Bakanlığına bağlayan
  CBK'nın numarası ve RG künyesi.
- Sayıştay / TBMM KİT Komisyonu denetim bulguları (11. bölüm bunlara dayanacak).
- Görev zararı ve Hazine ilişkisi rakamları.
- 3298 ve 2313 sayılı kanunlar üzerinden haşhaş/afyon tekeli — TMO'nun ikinci
  ayağı ve dosyanın sürpriz bölümü olabilir.

## Kural

`data.json`'a yalnızca yukarıdaki **Doğrulanmış** bölümünden rakam girer.
Doğrulanmayanlar `yayin.json → veri_bosluklari` içine yazılır ve sayfada
**Veri Notları** panelinde açıkta gösterilir.
