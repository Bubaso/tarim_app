# Hollanda dosyası — ham veri katmanı

Buradaki `.json` dosyaları **çekilmiş ham veridir**. Elle düzenlenmez.
Bir rakam değişecekse betik yeniden çalıştırılır, JSON yeniden üretilir,
sonra `../build_data.mjs` ile `../data.json` yenilenir.

## Neden ara katman var

Dosya metnindeki her sayının izlenebilir bir zinciri olmalı:

```
kaynak API/CSV  →  _raw/*.json  →  data.json  →  dosya metni
```

Bu zincir olmadan bir yıl sonra "bu rakam nereden geldi" sorusunun cevabı yok.

## Dosyalar

| Dosya | Üreten betik | Kaynak |
|---|---|---|
| `worldbank.json` | `wb_fetch.mjs` | World Bank WDI API |
| `faostat.json` | `fao_extract.mjs` | FAOSTAT QCL + QV + Employment |
| `faostat_ticaret.json` | `fao_trade.mjs` | FAOSTAT TCL |
| `faostat_ikili.json` | `fao_bilateral.mjs` | FAOSTAT Detailed Trade Matrix |
| `faostat_siralama.json` | `fao_rank.mjs` | FAOSTAT TCL, 198 ülke |
| `cbs.json` | `cbs_fetch.mjs` | CBS StatLine OData, tablo 81302ned |
| `cbs_ihracat.json` | — (elle) | cbs.nl haber bülteni, 2026-01-16 |
| `kurumlar.json` | — (elle) | Beş kurumun kendi resmî yayınları |

### Elle girilen iki dosya

`cbs_ihracat.json` ve `kurumlar.json` betikle üretilmiyor çünkü kaynaklarında
API yok. İkisi de **birincil kaynaktan WebFetch ile doğrulandı** ve içlerinde
`_giris_yontemi` / `_dogrulama_tarihi` alanları var.

`kurumlar.json` içinde her kurumun bir `dogrulanmamis` bloğu olabilir: arama
sonucunda görülen ama birincil kaynaktan teyit edilemeyen kalemler oraya
yazılır ve **dosya metnine giremez**. `build_data.mjs` bunları `data.json`'a
`kurumlar._dogrulanmamis_kalemler` altında ayrı taşır.

## Yeniden üretim

`wb_fetch.mjs` doğrudan çalışır (API'den çeker):

```bash
node content/dossiers/hollanda/_raw/wb_fetch.mjs
node content/dossiers/hollanda/_raw/cbs_fetch.mjs
```

FAOSTAT betikleri toplu CSV bekler. CSV'ler 2,2 GB tuttuğu için depoda
**tutulmuyor**; önce indirilmeleri gerekir:

```bash
bash content/dossiers/hollanda/_raw/fetch_faostat.sh
node content/dossiers/hollanda/_raw/fao_extract.mjs
node content/dossiers/hollanda/_raw/fao_trade.mjs
node content/dossiers/hollanda/_raw/fao_bilateral.mjs
node content/dossiers/hollanda/_raw/fao_rank.mjs
node content/dossiers/hollanda/build_data.mjs
rm -rf content/dossiers/hollanda/_raw/x content/dossiers/hollanda/_raw/*.zip
```

## Bilinmesi gereken tuzaklar

- **FAOSTAT API (`fenixservices.fao.org`) çalışmıyor** — HTTP 521 veriyor.
  Bu yüzden toplu CSV kullanıldı. API düzelirse betikler sadeleştirilebilir.
- **Türkiye, FAOSTAT'ta Asya grubunda.** Avrupa dosyasında tek satırı yok.
  Betikler iki bölgeyi birden okuyor.
- **FAOSTAT CSV'lerinde her alan tırnaklı** — satır `"150",` diye başlar,
  `150,` diye değil.
- **Hollanda'nın ürün bazlı üretim değeri 2017'de kesiliyor.** Türkiye 2023'e
  gidiyor. İkisi karşılaştırılmaz; ürün bazlı sıralama için üretim miktarı ve
  ticaret değeri kullanılır.
- **CBS ihracat serisi EUR, FAOSTAT ticaret serisi USD.** CBS'in
  "landbouwgoederen" tanımı FAOSTAT'ın "Crops and livestock products"
  tanımıyla aynı şey değil. İki seri aynı cümlede oran olarak kullanılamaz.
- **CBS tablosunda dönem `2025JJ00` biçiminde** — ilk dört karakter yıl,
  `JJ00` yıllık demek.
- **`royalfloraholland.com` WebFetch'e 403 veriyor.** FloraHolland rakamları
  çatı örgütü NCR (`cooperatie.nl`) üzerinden alındı.
- **Hollanda'nın dünya tohum pazarı payı kaynaklara göre değişiyor**
  (Plantum %38 sebze tohumu, PBL ~%35). Agrimatie yüzde pay vermiyor. Bu
  yüzden metinde pay değil, mutlak ihracat rakamı kullanılır.
- **`AG.LND.PRCP.MM` (ortalama yağış) yıllık seri DEĞİL.** Dünya Bankası
  1990-2022 arasındaki 33 yılın hepsine aynı sayıyı yazıyor (NLD 778, TUR 593):
  bu bir uzun dönem ortalaması. "2022'de şu kadar yağmur yağdı" diye
  yazılamaz. Yıllık yağış gerekirse başka kaynak bulunmalı.

## Düzeltilen bir hata

İlk taslakta `verim.aciklama` "açık tarla ürünlerinde fark neredeyse yok"
diyordu. Veri bunu yalanladı: patates 1,1× ve soğan 1,1× iddiayı destekliyor
ama **buğday 2,6× ve arpa 2,3×**. İddia üç kademeye ayrıldı (örtüaltı 5–12×,
yumru/kök 1,1–1,2×, tahıl 2,2–2,6×) ve `verim.tahil_farki` bloğu eklendi.

Tahıl farkının **kapandığı** da oradan görülüyor: 3,16× (1990) → 2,21× (2023).
Türkiye'nin tahıl verimi bu sürede %65 arttı, Hollanda'nınki %16. Bu, sera
farkının tersi yönde bir hikâye — dosyada ikisi karıştırılmayacak.

Ders: veri sayfası metinden önce derlenmeli **ve** derlendikten sonra
okunmalı. İlk açıklama cümlesi veriden değil, sezgiden yazılmıştı.
