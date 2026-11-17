# Yapay Zeka ve Dijital Tarım — araştırma günlüğü

Kararlar `KARARLAR.md`'de (Tur 0, elli soru). Bu dosya turların günlüğü.

---

## Tur 1 — ÖLÇÜM, İSKELET, ÖRNEK BÖLÜM · 16 Kasım 2026

Kullanıcı: "kaynakları olabildiğine geniş tut."

### 1 · Kaynak erişim haritası — 93 kaynak

`erisim_haritasi.py` → `erisim.json`. Her kaynağa tek istek; sınıflandırma
**durum kodu + içerik türü + gövde uzunluğu + içerik** birlikte (yumuşak
404'e karşı, §2.12.1).

```
93 kaynak · 68 AÇIK · 11 anahtar/engel · 6 kabuk · 6 kapalı · 2 hız sınırı
68 açığın yalnız 16'sı MAKİNE OKUNUR (API ya da RSS)
```

| katman | toplam | açık | makine okunur |
|---|---|---|---|
| mevzuat | 22 | 17 | **0** |
| akademik | 17 | 12 | 7 |
| kurumsal | 22 | 16 | **0** |
| veri | 13 | 10 | 4 |
| patent | 4 | 1 | **0** |
| sektör | 15 | 12 | 5 |

> **MİMARİYİ BELİRLEYEN BULGU.** Türkiye'nin bütün resmî kaynakları ve
> bütün uluslararası kurumlar yalnız SAYFA. Otomatik tarama iki ayrı iş
> yapacak: akademik/veri/sektörde **gerçek içerik çeker** (arXiv,
> OpenAlex, Crossref, DOAJ, Europe PMC, Zenodo, Hugging Face, OECD veri
> API'si, Dünya Bankası, AB Açık Veri, NASA CMR, AgFunder ve Google News
> RSS); mevzuat ve kurumsal katmanda yalnız **"bu sayfa değişti" der**,
> okumayı onaya bırakır. Bu, karar 17 ile (taslak üretir, kullanıcı
> onaylar) zaten örtüşüyor. **Patent katmanı fiilen kapalı.**

#### Ölçüm aracı iki yerde yanıldı — düzeltildi

1. **Küçük API cevabını kabuk sandı.** 2.000 baytlık eşik HTML'deki
   JavaScript kabukları için konmuştu ve her türe uygulanıyordu. Sayfa
   başına iki kayıt istenen Dünya Bankası (872 B) ve Europe PMC (1.904 B)
   kabuk diye elendi — ikisi de gerçek veri. Eşik artık yalnız HTML'e;
   JSON ayrıştırılarak, XML kayıt aranarak, PDF imzasıyla sınanıyor.
2. **429'ları kendisi üretti.** Sekiz eşzamanlı istek OpenAlex, Semantic
   Scholar ve CORE'u hız sınırına itti — üçü de açık API. Eşzamanlılık
   2'ye indi. *Ölçüm aracı ölçtüğü şeyi bozmamalı.*

İlk koşu 31 açık gösteriyordu; düzeltmeden sonra 36 (46 kaynakta).

### 2 · ULUSAL YAPAY ZEKA STRATEJİSİNDE TARIM YOK

> **TUR 2 DÜZELTMESİ (16 Kasım 2026).** Bu bulgu yalnız **2024-2025
> planına** ait. Yerine gelen **Türkiye Yapay Zekâ Eylem Planı
> (2026-2030)** 18 Ağustos 2026'da yürürlüğe girdi ve tarım orada 11 somut
> bağlamda var. Değişmeyen: Tarım ve Orman Bakanlığı iki planda da ne
> sorumlu ne iş birliği kurumu. Ayrıntı aşağıda, Tur 2 §1.

`cbddo.gov.tr` bu ortamdan **erişilemiyor**: DNS çözülüyor
(212.174.186.39) ama TLS el sıkışmasında bağlantı karşı taraftan kesiliyor
("Connection reset by peer"); tarayıcı da açamıyor.

Belgenin üçüncü taraf bir yansıması bulundu ve okundu:

```
Ulusal Yapay Zekâ Stratejisi 2024-2025 Eylem Planı
14 sayfa · 6 stratejik öncelik · 71 eylem (1.1 → 6.19)
```

71 eylem basının verdiği sayıyla birebir — belge tam.

| aranan | geçme sayısı |
|---|---|
| tarım / Tarım / TARIM | **0** |
| gıda, çiftçi, kırsal, orman, TAGEM | **0** |
| sulama, toprak, iklim, uydu, köy, hayvan, bitki | **0** |

Sorumlu ya da ilgili kurum olarak **11 bakanlık** geçiyor — Kültür ve
Turizm de, Gençlik ve Spor da var. **Tarım ve Orman Bakanlığı hiç yok.**

**Çıkarma sağlamlığı sınandı:** metin bozuk çıksaydı "tarım" zaten
bulunamazdı. Ama 953 "ı", 264 "ğ", 338 "ş" var, "Bakanlığı" 134 kez,
"Eylem" 99 kez geçiyor. Sıfır gerçek.

> Bakanlık kendi **Yapay Zeka Destekli Dijital Dönüşüm Strateji
> Belgesi**'ni ayrıca hazırlıyor (henüz yayımlanmadı). Yani Türkiye'de
> tarımsal yapay zeka politikası ulusal stratejiden **ayrı bir hatta**
> yürüyor. §23'ün çekirdek bulgusu.

**Şerh:** kopya üçüncü taraf yansıması (SHA-256 `7a99b2e5…`). Resmî kopyaya
erişilince karşılaştırılacak. Paylaşılan kayda (`ham_kaynaklar.json`)
işlendi.

### 3 · İskelet — 30 başlık

`iskelet_uret.py` → `iskelet.json`. 8 katman, 10 teknoloji etiketi.
İskelet KURALLARIYLA üretiliyor ve kurallar durduruyor: 25-30 başlık,
ardışık numara, ASCII adres (§2.1), bilinen etiket ve hedef, iki dilli
özet, sıralı süreç ekseni, kararla bağlı başlıkların varlığı, ölü etiket
yokluğu.

| katman | başlıklar |
|---|---|
| Çerçeve | §1 Bugün nerede duruyoruz · §2 Kavramlar · §3 Tarihçe |
| Tarlanın takvimi | §4-§11 — topraktan hasat sonrasına, süreç sırasıyla |
| Üretim alanları | §12 Hayvancılık · §13 Sera · §14 Su ürünleri · §15 Ormancılık |
| Zincirin öteki ucu | §16 Pazar · §17 İklim ve sigorta · §18 Danışmanlık ve dil modelleri |
| Altyapı | §19 Uydu · §20 Sensörler · §21 Veri ve sahiplik |
| Dünya ve Türkiye | §22 Dünya · §23 Türkiye · §24 Mevzuat · §25 Türkiye dizini |
| Eleştirel bakış | §26 Riskler ve sınırlar · §27 Başarısızlıklar ve abartılar |
| Anlatı ve başvuru | §28 Saha hikâyeleri · §29 Sözlük · §30 Kaynakça |

**"Biçim serbest, HEDEF KAYITLI."** Karar 12 (düzen konuya göre değişsin)
ile otomatik güncelleme arasındaki gerilim böyle çözüldü: her başlık
künyesinde `oto_hedefler` taşıyor ve tarama listede olmayan alanı önermez.

**Türkiye bir SÖZ değil bir DURUM.** Her başlığın `turkiye` alanı
'bilinmiyor' başlıyor; yazım turu ölçüp 'var' yapar. Kullanıcı kararı 5:
"her başlıkta Türkiye ile ilgili bir şey yazacağım diye kasmayalım."

### 4 · Örnek bölüm — §8 Görüntü işleme ve hedefli ilaçlama

`_raw/b08_kaynaklar.json` (kilitli kayıt) → `bolumler/08-…tr.md` ve `.en.md`.

**Beş doğrulanmış kaynak**, her biri KENDİ metninden okunarak:

| kayıt | nitelik | nasıl doğrulandı |
|---|---|---|
| Azghadi vd. 2025, *Comput. Electron. Agric.* 235 | hakemli | arXiv özeti |
| Allmendinger vd. 2024, *Plants* 13 | hakemli | Europe PMC API |
| Mohanty vd. 2016, *Front. Plant Sci.* 7:1419 | hakemli | **basılı PDF** |
| John Deere 2024 bülteni | satıcı | şirket sayfası |
| John Deere 2025 bülteni | satıcı | şirket sayfası |

#### Arama özeti yanılıyordu — basılı metin okununca düzeldi

Arama motoru PlantVillage'ın saha doğruluğu için "%31,4 yalnız ön baskıda,
basılı sürümde doğrulanamadı" diyordu. Basılı PDF doğrudan okundu: rakam
**basılı sürümde var ve daha kesin** — iki saha veri setinde **%31,40 ve
%31,69** (121 ve 119 görüntü). Ön baskıdan alıntı yapılmadı.

Bir incelik daha çıktı: 31,69 **32'ye** yuvarlanır. "%31'e düşüyor" ikisini
birden doğru anlatmıyordu. Makalenin kendi ifadesi kullanıldı: **"%31'in
hemen üstüne"**.

#### Kendi kuralımı çiğnemiştim — yakalandı

Reddedilen satıcı rakamları için (%90, %98) "sayı olarak verilmiyor" diye
not düşülmüştü — ama metne SAYI OLARAK yazılmıştı. İki dilde de çıkarıldı.

#### Sayı izi temiz

Metindeki her rakam, **yazıldığı basamakta** bir kayıttan türetiliyor
(dosya doğrulayıcılarındaki kural: "%99" → round(99,35) ✓).

#### Reddedilen üç kaynak

- **`tprds.duckdns.org`'daki "Ceylanpınar, 4.200 görüntü" çalışması** —
  dinamik DNS adresinde barınıyor, künyesi tutarsız, yazarı belirsiz.
  Konu ilgi çekici ama doğrulanamayan kaynak girmez.
- **Blue River satın almasının fiyatı (305 milyon $)** — birincil kaynaktan
  doğrulanamadı; rakamsız da yazılmadı. Doğrulanınca §3'e girer.
- **Satıcı üst rakamları (%90, %98)** — çoğu çıplak toprak senaryosu.

#### Türkiye — var ama tespit düzeyinde

Tez düzeyinde çalışma var (Pamukkale Ü., Tokat Gaziosmanpaşa Ü.); **ilaç
tasarrufunu sahada ölçen yayımlanmış bir Türkiye denemesi bulunamadı.**
Bölüm bunu tek paragrafta ve boşluğuyla birlikte söylüyor.

### 5 · Çiziciye düşen gereksinim

Bölüm sayfaları `##` alt başlık ve `>` özet bloğu kullanıyor. Dosya
dizisinin çizicisi (`dossier_prose.dart`) bunların **ikisini de
tanımıyor** — yalnız paragraf, kalın, italik ve tablo. Yeni bölümün
kendi çizicisi bu ikisini tanımak zorunda; yoksa `##` ekrana olduğu gibi
basılır.

## Tur 2'ye kalanlar

1. Tarama hattının iskeleti: hafif bağlama (her haber çekiminde) +
   kapsamlı tarama betiği, `bekleyen_guncellemeler` kuyruğu.
2. Haber etiketleme: editör ajanına çapraz etiket kararı + ilişki tablosu
   göçü + son 300 haberin geriye dönük taranması.
3. Doğrulayıcılar — dosya dizisindeki gibi tam (karar 48).
4. Kalan 29 başlığın yazımı, turlara yayılarak.
5. Tasarım: açık zemin, "makine ve bitki" paleti, veri-tarla ızgarası,
   etkileşimli harita.

---

## Tur 2 — ULUSAL STRATEJİ, ETİKET HATTI, TARAMA, DOĞRULAYICILAR · 16 Kasım 2026

Kullanıcı: "tur 2'ye geç. 2024-2025 yılından sonra ulusal yapay zeka
stratejisi yayınlanmış mı Türkiye'de, onu da teyit et." Tur sırasında
2027 Yıllık Programı'nı da verdi: "aklında bulunsun. özellikle 160-170
sayfa arası" — ve ardından "kendini hapsetme buraya".

### 1 · Tur 1'in §23 bulgusu düzeltildi — yeni plan var

| belge | tarım | Tarım ve Orman Bakanlığı |
|---|---|---|
| Ulusal YZ Stratejisi 2024-2025 Eylem Planı (71 eylem) | **0** geçiş | sorumlu/ilgili 11 bakanlık arasında **yok** |
| **Türkiye YZ Eylem Planı 2026-2030** (16 eylem; Genelge 2026/9, RG 18.08.2026 sayı 33344) | 19 geçiş, 13 benzersiz, **11 somut bağlam** | 16 "Ana sorumlu" alanındaki 9 bakanlık arasında **yok** |
| **2027 Yıllık Programı** (RG 27.10.2026 sayı 33413 mük.) | politika 489: "Dijitalleşme, yapay zekâ ve veriye dayalı iş modelleriyle akıllı tarım uygulamaları yaygınlaştırılacaktır" | **sorumlu (S)** |
| Bakanlığın kendi YZ strateji belgesi | — | "yılın başında" paylaşılacaktı (Kas 2025), "hazırlandı" (Haz 2026), **yayımlanmadı** → beklemede |

**Bulgu: iki ayrı hat.** Ulusal plan Sanayi ve Teknoloji koordinasyonunda
ve tarımı bir uygulama sektörü olarak anıyor; tarımın kendi yapay zekâ
politikası Kalkınma Planı ve yıllık programlarda, bakanlığın
sorumluluğunda. Yıllık programda o politikanın 2027 faaliyetleri ortak
makine parkı ve elektronik küpe; programın tek somut yapay zekâ işi
TAKİS'te 1-4 hafta önceden kuraklık tahmini ve "planlanmaktadır" kipinde.
Bölümün 15 performans göstergesinin hiçbiri dijitalleşmeyi ölçmüyor.

Kayıtlar: `strateji_karsilastirma.json`, `yillik_program_2027.json`.
Kaynak PDF'ler `kaynak_dosyalari/`'nda, SHA-256'ları `ham_kaynaklar.json`'da.

#### Bu turda yakalanan dört kayıt hatası

1. **"Sorumlu Kurum" büyük harfle arandı**, 0 çıktı ve "yeni planda eylem
   başına sorumlu kurum yok" diye kayda geçti. Alanlar küçük harfle
   "Ana sorumlu:" yazılmış — 16 eylemin 16'sında var. Düzeltme bulguyu
   GÜÇLENDİRDİ: karşılaştırma artık birebir.
2. **Sulama tedbirleri §6'ya bağlanmıştı** (§6 ekim, §7 sulama).
3. **Toprak etüdü §21'e (veri) bağlanmıştı** — doğrulayıcının konu kuralı
   yakaladı.
4. **Bakanlık ayrıştırıcısı "Savunma Sanayii Başkanlığı, Ticaret"i tek ad
   sandı** — doğrulayıcı tutarsızlık olarak durdu.

Resmî Gazete kopyası bu Mac'ten de dış okuyucudan da "connection reset"
verdi; programı hazırlayan kurumun (SBB) PDF'i okundu. Sayfa numaraları
SBB kopyasının basılı numaraları.

### 2 · Haber etiketi — ölçüldü, ölçütü değişti, hatta bağlandı

**İlk sürüm** ("haberin KONUSU bu teknoloji mi"), son 300 haber: kapı 27,
EVET 19 (%6,3), beş kategoriye dağılıyor — çapraz etiket kararı (26)
doğru. Ama elle okuma COP31 kusurunu buldu: Bakan'ın yol haritası
haberinin üç sürümü (üçünde aynı "yapay zekâ tabanlı Karar Destek
Sistemi" cümlesi) 1 EVET 2 HAYIR; bir yapay zekâ asistanının tanıtıldığını
yazan iki haberden biri EVET biri HAYIR.

**Yeni ölçüt — kanıta dayalı** (`kanit-v2`): "haberde somut bir bilgi var
mı, varsa o cümleyi metinden kelimesi kelimesine kopyala". Kanıt metinde
bulunmazsa etiket konmaz. Aynı 27 haber, her biri İKİ kez:

| | ilk sürüm | kanit-v2 |
|---|---|---|
| bölüme giren | 19 | **25** (%8,3) |
| kanıtı metinde bulunamayan EVET | — | **0** |
| iki koşuda aynı durum | ölçülmedi | **27/27** (2 haberde yalnız başlık numarası değişti: §13↔§20, §9↔§19) |
| İş Bankası çifti (yapay zekâ asistanı tanıtımı) | EVET + HAYIR | **iki aktif** |
| Bakan'ın yol haritası, üç sürüm | 1 EVET 2 HAYIR | 2 aktif + 1 sınırda |

**Yol haritasının üçüncü sürümü neden sınırda kaldı:** haber 9.157
karakter, model ilk 4.000'ini görüyordu; "Karar Destek Sistemi gibi yapay
zeka araçları" cümlesi o sınırın ötesindeydi. `kanit-v3` uzun haberde baş
kısma ek olarak anahtar kelime geçen cümleleri modelin önüne koyuyor.

**kanit-v3 ölçümü** (aynı 27 haber): aktif 25, sınırda 2, kanıtsız EVET
0. Bakan'ın yol haritası haberlerinin DÖRDÜ de (bakanlığın kendi
açıklaması dahil) aynı kanıt türüyle — "yapay zekâ tabanlı Karar Destek
Sistemi ile yangın riski bir hafta önceden" — ve aynı başlıkta (§15)
aktif. Aynı olayın sürümlerine farklı karar sorunu kapandı. Sınırda
kalan ikisi doğru yerde: biri "dijital tarım olanaklarının üretime
entegrasyonu" diye genel geçiyor, öteki bir reform listesinde "akıllı
tarım teknolojileri" sayıyor.

**Kapsayıcılığın bedeli:** v2'de 25 aktifin üçü genel bir cümleyle girdi
("yapay zekâ destekli otomasyon iş birliğinin geleceğini şekillendiriyor"
— Kazakistan buğday haberi; gıda arz güvenliği; gıda güvenliği kongresi).
v3'te gıda arz güvenliği sınırda düştü, öteki ikisi aktif kaldı.
Kullanıcının ilk ifadesi "içinde yapay zeka geçen tüm haberler"; bunlar o
tanıma giriyor ve panelden tek tıkla kalkıyor (karar 33).

**Dizin adayı süzgeci:** ilk koşuda 20 Türkiye dizini adayının 10'u
"Tarım ve Orman Bakanlığı"ydı. Bakanlık, genel müdürlük, belediye artık
kurum olarak önerilmiyor (adı konmuş projeleri öneriliyor); aynı kuruluş
ad üzerinden tekil, her haberde yeniden kuyruğa düşmüyor.

**Durumlar:** `aktif` (bölümde) · `sinirda` (kapıdan geçti, kanıtlı EVET
yok — panelde tek tıkla eklenir) · `kaldirildi` (editör kaldırdı; hat
EZMEZ). Editörün elle verdiği karara da hat dokunmuyor.

| parça | yer | durum |
|---|---|---|
| ilişki tablosu + kuyruk + tarama kaydı + izlenen sayfalar | `supabase/migrations/20261116120000_yz_bolumu.sql` | **yazıldı, UYGULANMADI** |
| değerlendirme ve yazım | `~/tarim_ai_pipeline/src/utils/yz_bolumu.py` | hazır |
| hatta bağlantı | `src/main.py`, kayıttan sonra, kendi `try`'ında | hazır — göç yoksa etiketi sessizce atlar, model çağırmaz |
| son 300 haber | `yz_geriye_donuk.py` | önizleme varsayılan; `--yaz` onay bekliyor |
| ölçüm | `yz_olcum.py --model --tekrar` | salt okunur |

### 3 · Tarama hattı

`~/tarim_ai_pipeline/src/yz_tarama.py`, üç kol: **akademik** (arXiv,
OpenAlex — `tarama_sorgulari.json`'daki 19 başlık sorgusu, başlığında
hem alan hem teknoloji terimi geçen en yeni 3 kayıt), **haber** (Google
Haberler, Türkçe 4 sorgu → §23-25), **sayfa** (`erisim.json`'daki 29
resmî/kurumsal sayfa; metin değil BAĞLANTI kümesi izleniyor, yalnız yeni
bağlantılar kuyruğa düşüyor). Panelden `agent_jobs.job_type='yz_tarama'`.

**Önizleme koşusu** (yazmadan, 17 Ekim 2026 sonrası): 30 öneri — OpenAlex
9, arXiv 1, Google Haberler 20; 29 sayfanın 28'i taban kaydı aldı. İki
zaman aşımı (arXiv bir sorguda, TOBB sayfası) koşuyu durdurmadı, sayıldı.
Haber kolunun ilk sonuçları §23 için doğrudan malzeme: "Trakya'da yapay
zeka destekli kuraklık tahmin sistemi devrede" (AA, 21 Ekim) ve "ÇKS
kayıtları yapay zekâ ve uyduyla doğrulanıyor" (9 Kasım) — ikisi de
okunup doğrulanmadan kayda girmez.

arXiv'in tek kayıtla dönmesi süzgecin sıkılığından: başlığında hem alan
hem teknoloji terimi isteniyor. Kuyruk birkaç ay gözlendikten sonra
gevşetilip gevşetilmeyeceğine karar verilir.

**Bilinen sınır:** Google Haberler RSS'i haberin kendi adresini değil bir
yönlendirme adresi veriyor. Kuyrukta yayın organının adı ve başlık duruyor;
asıl adres onay sırasında açılınca görülüyor. Kayda girecek her haber
kendi adresinden okunur.

### 4 · Doğrulayıcılar (karar 48)

| betik | ne sınıyor | sonuç |
|---|---|---|
| `dogrula_alintilar.py` | kayıtlardaki her alıntı, sayı, sayfa numarası ve başlık bağı PDF'in kendisinden | 71 alıntı · 16 sayı · 14 sayfa · 40 bağ · 4 dosya özeti ✓ |
| `dogrula_bolumler.py` | bölüm metnindeki her sayı yazıldığı basamakta kilitli kayıttan; reddedilen sayı yok; satıcı rakamı etiketli; iki dilin sayıları aynı | §8: 36+36 sayı ✓ · bilerek yerleştirilen 7 hatanın 7'si yakalandı |
| `dogrula_tarama.py` | `gelisme` hedefli her başlık bir sorguya ya da gerekçeli `elle` listesine bağlı | 27 başlık: 19 akademik, 3 haber, 5 elle ✓ |

### Canlı veritabanına yazılanlar — kullanıcı onayıyla ("üçünü de onaylıyorum, uygula")

1. **Göç `20261116120000_yz_bolumu.sql` uygulandı.** Önce `migration list`
   (yerel ve uzak senkron, son uzak sürüm `20261115160000`) ve
   `db push --dry-run` (yalnız bu göç). Göçün kendi sağlaması geçti.
   **Bu dosya artık KİLİTLİ** — değişiklik yeni bir göçle yapılır.
   Okur sınaması (anon anahtar): aktif etiket görünüyor; kuyruk, tarama
   kaydı ve izlenen sayfalar boş dönüyor.
2. **`yz_geriye_donuk.py 300 --yaz`** (kanit-v3): kapıdan geçen 27 haberin
   **27'si aktif**, kanıtı doğrulanmamış aktif 0, hata 0. Başlıklar §15 (7),
   §7 (5), §20 ve §24 (3'er) ağırlıklı. 16 Türkiye dizini adayı kuyruğa.
   **Sapma:** v3 ölçümünde "sınırda" kalan iki genel haber (kadın
   çiftçilere finansman; gıda arz güvenliği) bu koşuda aktif çıktı. Sınır
   kararları koşudan koşuya değişebiliyor; kanıt cümlesi metinde var ama
   GENEL. Panelden kaldırılır — Tur 3'ün ilk işi panel.
3. **`python3 -m src.yz_tarama --yaz`**: kuyruğa 31 öneri (arXiv 2,
   OpenAlex 9, Google Haberler 20); 29 sayfanın 28'i taban kaydı aldı,
   TOBB zaman aşımına uğradı (durumu 'hata', karar 24). Tarama kaydı
   hatasız kapandı — aylık hatırlatmanın sayacı bu tarihten başlıyor.

Canlı sayım, okur gözüyle (anon anahtar): 27 aktif etiket görünüyor;
sınırdaki etiketler, kuyruktaki 47 öneri, tarama kaydı ve izlenen
sayfalar **0** dönüyor; okurun PATCH denemesi hiçbir satıra dokunmuyor.

## Tur 3'e kalanlar

1. **Panel:** onay kuyruğu kartına "Yapay Zeka ve Dijital Tarım" anahtarı
   (COP31 anahtarının yanına; ajanın kanıt cümlesi ve başlığıyla);
   bölümün kendi sekmesi — sınırdakiler (tek tıkla ekle), aktifler (tek
   tıkla kaldır), güncelleme kuyruğu (onay/red), son kapsamlı taramanın
   tarihi ve 30 günü geçince hatırlatma (karar 19).
2. **§23 Türkiye'de durum ve §24 Mevzuat** — bu turun kayıtlarıyla
   yazılabilir. Açık soru: TAGEM'deki Yapay Zeka ve Dijital Tarım
   Teknolojileri Araştırma Merkezi'nin kuruluşu yalnız Bakan'ın Haziran
   2026 konuşmasından (ikincil kaynak) biliniyor; birincil duyuru
   bulunmadı, adı haberlerde farklı yazılıyor.
3. Bölüm sayfası ve çizici (`##` ve `>`), tasarım, kalan başlıklar.

---

## Tur 3 — PANEL, §23 TÜRKİYE'DE DURUM, §24 MEVZUAT · 16 Kasım 2026

Kullanıcı: "bitince tur 3'e geç."

### 1 · Tek kaynak: haber alan başlıklar iskelette

`iskelet_uret.py` artık her başlığa `haber_alir` yazıyor (`HABER_ALMAYAN =
{1, 2, 3, 22, 23, 25, 28, 29, 30}`) ve yazım durumunu ELLE değil
dosyalardan çıkarıyor: iki dil + kilitli kayıt varsa `yazildi`, Türkiye
durumu başlığın kendi kaydından. Hattın başlık listesi
(`yz_bolumu.py`, `BASLIKLAR`) bu kümeyle sınanıyor; ayrışırsa geriye
dönük betik çalışmıyor. `dart_uret.py` aynı iskeleti
`lib/features/yapay_zeka/data/yz_iskelet.g.dart`'a gömüyor — panelin
başlık seçicisi oradan okuyor.

### 2 · Panel

| parça | yer |
|---|---|
| veri katmanı (oturum ve dönen satır denetimiyle) | `lib/features/yapay_zeka/data/yz_deposu.dart` |
| sağlayıcılar | `lib/features/yapay_zeka/yz_providers.dart` |
| onay kartındaki satır — ajanın kararı, kanıt cümlesi, tek tıkla al/kaldır, başlık değiştir | `presentation/yz_etiket_satiri.dart` |
| "YZ Bölümü" sekmesi — Sınırda / Bölümde / Kuyruk, son kapsamlı tarama, 30 gün hatırlatması, taramayı başlat | `presentation/yz_panel_ekrani.dart` |

Editörün her kararı `kaynak = editor` yazıyor; hat ve geriye dönük tarama
o satıra bir daha dokunmuyor. Kuyrukta "Onayla" hiçbir şeyi yayına
koymuyor: öneri bir sonraki yazım turunun malzemesi oluyor (karar 17).

**Test** (`test/yz_panel_test.dart`, 6 test): başlık kümesi, satır
ayrıştırma, 375 ve 1200 piksel, hatırlatma eşiği, onay satırı.
İlk koşu **gerçek bir taşma yakaladı** — kuyruk kartının üç düğmesi 375
pikselde 121 piksel taşıyordu; `Row` → `Wrap`.

**Kırdığım ve onardığım:** onay kuyruğu kartı yeni sağlayıcıyı izleyince
`panel_mobil_test.dart`'ın 10 testi düştü — sağlayıcı test ortamında
gerçek bir Supabase istemcisi kuruyor, istemcinin oturum yenileme
zamanlayıcısı testi askıda bırakıyordu. Testin sahte depo kurgusuna
etiket kaynağı da eklendi. Tam takım: yalnız önceden de düşen iki test
kalıyor (`author_article_detail_test`, `widget_test` — değişikliklerim
geri alınarak sınandı, onlarsız da düşüyorlar).

**Canlıya dağıtılmadı.** Panel ekranları web derlemesi ve dağıtım
bekliyor (onay ister).

### 3 · §23 Türkiye'de durum ve §24 Mevzuat ve politika

Zincir artık uçtan uca denetleniyor:

```
PDF / resmî metin ──dogrula_alintilar.py──▶ sınanmış kayıt
   ──(4. adım, 25 bağ)──▶ b23_kaynaklar.json ──dogrula_bolumler.py──▶ metin
resmî metin ──(5. adım, alıntılar)──▶ b24_kaynaklar.json ──▶ metin
```

| başlık | sayı (her dil) | kaynak |
|---|---|---|
| §23 | 54 | strateji_karsilastirma.json + yillik_program_2027.json |
| §24 | 52 | AB Yayın Ofisi'nin resmî metinleri (4 tüzük) + 2026-2030 planı · 24 alıntı |

**§24 için okunan AB metinleri** (eur-lex otomatik isteğe boş 202 döndü;
aynı belgeler Yayın Ofisi'nin `publications.europa.eu/resource/celex/…`
ucundan alındı): Yapay Zekâ Tüzüğü 2024/1689, onu değiştiren Dijital
Omnibus 2026/1744, Veri Tüzüğü 2023/2854, Makine Tüzüğü 2023/1230.

#### Kaynağı okumak iki yerde bildiğimi düzeltti

1. **Yapay Zekâ Tüzüğü'nün takvimi değişmiş.** Asıl metin ürün güvenlik
   bileşenleri için 2 Ağustos 2027 diyordu; 2026/1744 (AB Resmî Gazetesi
   24 Temmuz 2026) bunu **2 Ağustos 2028**'e, Ek III'ü 2 Aralık 2027'ye
   erteledi ve makine tüzüğünü Ek I'in A bölümünden B bölümüne — tarım
   araçlarının yanına — taşıdı. Asıl metinle yetinilseydi §24 yanlış
   tarih yazacaktı.
2. **Makine Tüzüğü 14 Ocak 2027'den uygulanıyor**, yaygın anılan 20 Ocak
   değil — Yayın Ofisi'nin güncel resmî metni.

#### Çeviri tırnak içine girmez

İngilizce sürümlerde Türkçe kaynaktan çevrilmiş cümleler tırnak içinde
duruyordu (ve tersi). Tırnak yalnız belgenin kendi dilindeki birebir söz
için; çeviriler tırnaktan çıkarıldı ya da "in translation" diye işaretlendi,
kelime anışları Türkçe aslıyla verildi ("çiftçi" (farmer)).

#### Metne girmeyenler (kayıtlarda gerekçesiyle)

TAGEM'deki araştırma merkezi, Trakya'daki derin öğrenmeli kuraklık
tahmini ve "yangın riski bir hafta önceden" beyanı (yalnız ikincil
kaynak); Meclis'teki yapay zekâ kanun teklifleri (yalnız haber aktarımı).

## Tur 4'e kalanlar

1. **Bölüm sayfası:** çizici (`##`, `>`, tablo), başlık sayfaları, haber
   akışı başlıkların altında (`bolum_etiketleri`, aktif), ana sayfa kartı
   ve canlı haber şeridi (karar 46).
2. **Tasarım** (karar 42-45): açık zemin, "makine ve bitki" paleti,
   veri-tarla ızgarası, etkileşimli harita.
3. **Panelin ve sayfanın dağıtımı** — onayla, birikmiş dağıtımla birlikte.
4. Kalan 27 başlığın yazımı, turlara yayılarak.

---

## Tur 4 — BÖLÜM SAYFASI, ÇİZİCİ, TASARIM, ANA SAYFA ŞERİDİ · 16 Kasım 2026

Kullanıcı: "tur 4'e geç."

### 1 · İçerik derlemeye gömülü (karar 21)

`dart_uret.py` iki dosya üretiyor: `yz_iskelet.g.dart` (başlıklar,
katmanlar, teknolojiler, `yazildi`, iki dilde özet) ve `yz_metinler.g.dart`
(yazılmış her başlığın TR/EN Markdown'ı + `guncellendi` tarihi). Tarih
kaydın kendisinden (`bNN_kaynaklar.json` → `guncellendi`) — karar 23,
güncellik başlık bazında. `dogrula_bolumler.py` bu alanı sayı havuzuna
ALMIYOR: tarihteki 16 ve 11 metindeki her "16"yı izlenir gösterirdi.

### 2 · Çizici — `yz_metin_gorunumu.dart`

Markdown'ın dar kesiti: `>` özet, `##` alt başlık, tablo, paragraf,
kalın/italik. Tanımadığı biçimi yutmuyor, düz metin bırakıyor. Rakam
taşıyan kalın parça eşit genişlikli ve çelik mavisi — ölçülmüş sayı
anlatılandan yazıyla ayrışıyor. Tablo geniş ekranda tablo, dar ekranda
satır başına kart.

### 3 · Görsel dil — `yz_tasarim.dart` (karar 42-45)

| | |
|---|---|
| zemin | `#F3F5F1` — klorofile eğilen kâğıt grisi; dizide ilk açık zemin |
| mürekkep | `#1D2321` grafit |
| makine | `#34507A` çelik mavisi — ölçüm, ızgara, rakam |
| bitki | `#3E7B3A` klorofil — yazılmış, canlı, haber |
| bekleyen | `#A97C2F` (çizgi) / `#7A5A1F` (metin) — hardal |
| yazı | Outfit başlık (site kuralı §36) · Newsreader gövde · IBM Plex Mono künye ve rakam |
| motif | `TarlaIzgarasi`: eğik ekim sıraları + dik veri ızgarası + düğümler; metin tarafında soluyor |

### 4 · Sayfalar

- **Merkez** `/yapay-zeka-dijital-tarim`: giriş (ızgara zeminde), durum
  satırı (iskeletten sayılıyor), **etkileşimli harita** (karar 11: katman
  satırları, başlık karoları; yazılmış dolu, yazılmakta olan boş;
  teknoloji çipi seçilince ilgisiz başlıklar sönüyor — karar 13), canlı
  haber akışı (başlık çipleriyle), "nasıl güncel tutuluyor".
- **Başlık** `/yapay-zeka-dijital-tarim/<adres>`: üst etiket, teknoloji
  çipleri, güncellik satırı, gömülü metin ya da "yazılıyor" kutusu
  (iskeletin özeti), o başlığın haberleri, önceki/sonraki.
- **Ana sayfa şeridi** (karar 46): Uzayda Tarım'ın altında, üç yerleşimde
  aynı sırada (sıra testi geçiyor). "Şu an öne çıkan" takvime bağlı
  dönüyor (karar 2); geniş ekranda son iki haber.
- **Paylaşım:** `paylasim_karti.mjs` (kart — haritanın küçültülmüşü,
  "30 BAŞLIK · 3 YAZILDI" iskeletten) ve `paylasim_sayfasi.mjs` (merkez +
  yazılmış her başlığın og kabuğu; açıklama özet bloğundan). `deploy.sh`'a
  eklendi.

### 5 · Sınama

`test/yz_bolum_test.dart` — 21 test: çizici, gömülü metnin .md ile
aynılığı, öne çıkan başlığın dönüşü, merkez/başlık/şerit 360 ve 1280
pikselde, İngilizce dar ekran, bilinmeyen adres. İki gerçek hata yakaladı:

1. **Dikey Flex içinde Flexible** — dar ekranda katman satırı kaydırılan
   alanda sınırsız yükseklik aldı; satır iki yerleşime ayrıldı.
2. **Dil** — test uygulaması varsayılan İngilizce açıldı; sayfa doğru
   davranıp İngilizce çizdi, Türkçe beklentiler boşa düştü. İngilizce dar
   ekranda karo etiketinin taşma riski görüldü, etiket esnek yapıldı.

Tarayıcıda (yayın derlemesi, yerel sunucu) görüldü: merkez, §23 masaüstü
ve telefon, ana sayfa şeridi telefon ve masaüstü. Bir hizalama hatası
gözle yakalandı (giriş bloğu ortalanıyordu) ve düzeltildi. Konsolda hata
yok. Tam takım: yalnız önceden de düşen iki test.

**Sürüm bekçisine** beş belirteç eklendi (bölüm adı, güncellik satırı,
öne çıkan satırı, panel sekmesi, kaldır düğmesi) — beşi de derlemede.

### Dağıtım — ONAY BEKLİYOR

`./deploy.sh --hosting` (fonksiyon değişmedi). Canlıya çıkacaklar: bölüm
sayfaları, ana sayfa şeridi, panelin "YZ Bölümü" sekmesi ve onay kartı
satırı, paylaşım kabukları ve kartı.

## Tur 5'e kalanlar

1. Kalan 27 başlığın yazımı — öncelik §1 "Bugün nerede duruyoruz"
   (merkez sayfanın en üstüne o gelecek), sonra §7, §15, §17 (haber
   akışının en kalabalık başlıkları) ve §29 sözlük (metin içi balon,
   karar 14).
2. Kuyruktaki 47 önerinin okunması (panelden) ve onaylananların ilgili
   başlıklara işlenmesi.
3. §30 Kaynakça — kilitli kayıtlardan kendiliğinden (karar 15).

## Tur 5 — SÜREÇ EKSENİ: §4, §5, §6, §7, §9 · 16-17 Kasım 2026

Kullanıcı: "tamamı yazılınca açılsın, dala commit et, tur 5'e geç."
(Kararlar 51-53, KARARLAR.md § H.) Tur 4'ün "Tur 5'e kalanlar" listesi
§1'i öne alıyordu; §1 bütün başlıkların özeti olduğu için sona (Tur 9)
bırakıldı, Tur 5 süreç ekseninin tarladaki halkalarına ayrıldı.

### 0 · Devralınan

- **Dağıtım yapıldı** (karar 52): panel, kuyruk ve etiket satırı canlıda;
  okur adresi canlıda genel başlıkla dönüyor, şerit çizilmiyor — ikisi de
  canlı sitede sınandı.
- `main` Tur 4'ün son commit'inde (`aa715bd`); Tur 5'in bütün commit'leri
  `yapay-zeka-bolumu` dalında, GitHub'a gönderilmedi.

### 1 · Yazılan başlıklar

| § | başlık | kaynak | alıntı | sayı (TR = EN) | commit |
|---|---|---|---|---|---|
| 7 | Sulama ve su yönetimi | 6 | 31 | 48 | `1e19254` |
| 4 | Toprak ve arazi | 5 | 43 | 52 | `8bd5468` |
| 9 | Ürün izleme ve verim tahmini | 13 | 78 | 64 | `b385e0e` |
| 6 | Ekim ve değişken oranlı uygulama | 10 | 56 | 70 | `eb96078` |
| 5 | Tohum, ıslah ve genetik | 7 | 45 | 41 | `82b3690` |

Yazılmış başlık: 8/30 (§4-§9, §23, §24). Her başlığın `turkiye` alanı
artık `var`; her metin "bu taramada bulunamayan şey" satırıyla bitiyor.

### 2 · Başlıklar arası desen

Beş başlıkta da aynı şey görüldü: **ölçülmüş tasarruf ya da doğruluk var,
kâr ve ölçek tutarsız; yapay zekâ yerleşik yöntemi çoğu yerde geçemedi.**
§9'da makine öğrenmesi AB'nin işletimdeki verim tahmin sistemine kimi
üründe yetişti, kimisinde iki kat hata yaptı; §6'da verimi benzer
doğrulukla tahmin eden iki model çok farklı azot dozları önerdi; §5'te
derin öğrenme genomik tahminde klasik modellere açık üstünlük göstermedi.
Türkiye tarafında beş başlığın hiçbirinde yapay zekânın tarladaki etkisini
ölçen yayımlanmış bir değerlendirme bulunamadı. Bu, §1 "Bugün nerede
duruyoruz"un ana cümlesine aday.

### 3 · Doğrulama sırasında yakalananlar

1. **"Türkiye'nin ilk Dijital Toprak Haritası"** (iskelet özeti, Tur 0
   notu) doğrulanamadı: TAGEM'in 2012-2015 projesi ulusal ölçekte toprak
   özelliği haritaları üretmişti. Özetten çıkarıldı; Tur 0 notundaki "ilk"
   de bu yüzden geçersiz.
2. **SoilGrids'te "BDOD"** kısaltmasının açılımı sayfa metninde yok;
   en yüksek başarı puanının ait olduğu özelliğin adı yazılmadı.
3. **"En olası değer"** yanlıştı — makale her hücre için ortanca ve
   ortalama veriyor; "tahmin" diye düzeltildi.
4. **Sayısız doğruluk beyanı** (TRGM, "yüksek doğruluk oranları") oran
   verilmediği söylenerek aktarıldı; doğruluk iddiası olarak kullanılmadı.
5. **Yokluk iddiaları kayda bağlandı** (`_denetim`): dört bülten sayısında
   dekara verim rakamı yok; AB 2021/2116'da makine öğrenmesi ve yapay zekâ
   geçmiyor; programda "genom" yalnız hayvancılıkta ve Ar-Ge listesinde.
6. **Erişim engeli aşılmadı:** bir derlemenin özetini veren iki site bot
   doğrulaması ve oturum açma istedi; kullanılmadı, aynı soruyu yanıtlayan
   açık erişimli derleme alındı. mdpi.com ve link.springer.com otomatik
   isteği reddetti; özetler Crossref'ten (yayıncının yatırdığı) okundu.
7. **Yanlış ülke:** buğday genotiplerini çok bantlı ölçümle ayıran bir
   çalışma Türkiye sanılmıştı; yazarların hepsi Pakistan ve Çin'den. Elendi.
8. **Farklı evren karşılaştırması** (ABD'de ekili alan payı ↔ dünyada
   çiftlik payı) üzerine kurulan bir çıkarım silindi.
9. **Gelecek zaman:** programdaki 2027 tedbirleri "yapılacak" diye yazıldı,
   gerçekleşmiş gibi değil.

### 4 · Sınama

`test/yz_bolum_test.dart` artık sabit bir başlık listesi değil, **yazılmış
her başlığı** ve yazılmamışların ilkini 360 ve 1280 pikselde, İngilizceyi
360 pikselde çiziyor (`_sinanacakBasliklar`). Yeni yazılan başlık
kendiliğinden teste giriyor; tur sonunda 45 test, hepsi geçiyor.
`flutter analyze lib/features/yapay_zeka` temiz.

### 5 · Kaynak deposu

`ham_kaynaklar.json`: 198 → 232 dosya. PDF'ler depo dışı (`.gitignore`),
SHA-256 ile kayıtlı; HTML ve JSON kaynaklar depoda. Yokluk denetimi için
indirilen üç bülten de kayıtlı (`_denetim` onlara işaret ediyor).

## Tur 6'ya kalanlar

1. **§10-§15:** hasat ve robotik, hasat sonrası, hayvancılık, sera ve
   kontrollü ortam, su ürünleri, ormancılık.
2. **Kuyruk okuması** — 47 öneri panelde; kullanıcının kararı.
3. **Eksik özellikler** (ilgili turlarda): seri tazeleme (karar 16), başlık
   önerileri (karar 10), Türkiye dizini sayfası (karar 38, §25), sözlük
   balonu (karar 14, §29), kaynakça (karar 15, §30).
4. **Açılıştan önce (Tur 10):** her başlığın "otomatik güncellenenler"
   paragrafı izleyicinin gerçekte yaptığıyla karşılaştırılacak; §8'in
   kaydı (Tur 2) alıntı listesi taşımıyor, yeni biçime getirilecek.

## Tur 6 — HASATTAN ORMANA: §10-§15 · 17 Kasım 2026

Kullanıcı: "tur 6'ya geç."

### 1 · Yazılan başlıklar

| § | başlık | kaynak | alıntı | sayı (TR = EN) | commit |
|---|---|---|---|---|---|
| 10 | Hasat ve robotik | 8 | 30 | 43 | `02afefd`, `3c0df52` |
| 11 | Hasat sonrası: sınıflandırma, kalite, depolama | 7 | 23 | 40 | `86527a6` |
| 12 | Hayvancılık | 6 | 32 | 54 | `99f8abf` |
| 13 | Sera ve kontrollü ortam | 4 | 23 | 14 | `9791b78` |
| 14 | Su ürünleri | 8 | 35 | 50 | `c2d5981` |
| 15 | Ormancılık | 9 | 40 | 64 | `acd9be6` |

Yazılmış başlık: 14/30 (§4-§15, §23, §24).

### 2 · Başlıklar arası desen

Tur 5'in deseni burada da tuttu, bir farkla: yapay zekânın ölçülmüş en güçlü
sonuçları **büyük ölçekte gözlem** işlerinden geliyor — uydu ve derin
öğrenmeyle balıkçı gemilerinin %72-76'sının kamuya açık izlemede görünmediği
(§14), 10 metrelik küresel ağaç boyu haritası (§15), seranın her değişkeni
ölçülen ortamında beş yapay zekâ ekibinin hepsinin yetiştiriciyi geçmesi
(§13). Fiziksel işte tablo zayıf: hasat robotları otuz yılda iyileşmemişti
(§10); piyasadaki hayvan refahı sensörlerinin yalnız %14'ü bağımsız
doğrulanmış (§12); kaybın büyük olduğu yerde açık ayıklamada değil depolamada
(§11). Türkiye'de altı başlığın hepsinde "bulunamayan şey" yine aynı:
yapay zekânın sahadaki etkisini ölçen yayımlanmış bağımsız değerlendirme.

### 3 · Türkiye için yeni bulgular (öteki başlıklara da girecek)

- **BAGİS yapay zekâ projesi** — Bakanlığın teknik ister belgesi (TÜBİTAK
  sitesinde, Haziran 2026): 1.629 gemi, veri şimdilik izleme ve kayıt için,
  ihlal kontrolünü ekran başındaki personel yapıyor. **§23 Türkiye'de durum**
  ve **§24 mevzuat** güncellemesinde kullanılacak (kuyruğa önerilmeli).
- **OGM Karar Destek Sistemi** (2022'den beri, yapay zekâ destekli) ve
  kameralı Orman Yangın Uyarı Sistemi (TÜBİTAK 2013) — §23'e aday.
- Bakanlığın istatistik bültenleri (makine, hayvan varlığı, su ürünleri,
  ormancılık, tohum) metaveriyle birlikte kayıt defterinde; "sayı" hedefi
  için seri tazelemede (karar 16) kaynak olacaklar.

### 4 · Doğrulama sırasında yakalananlar

1. **Özet içi tutarsızlık:** bir patlıcan çalışmasında F1 ile kesinlik ve
   duyarlılık birbirini tutmuyor; rakamlar kullanılmadı (`_tutarsizlik`).
2. **Doğrulanamayan ödül:** OGM sisteminin ITU ödülünü kazandığını yazan
   haberler var; birincil kazanan listesinde doğrulanamadı, yalnız adaylık
   yazıldı.
3. **Birbirini tutmayan sayılar:** haberlerdeki kule ve kamera sayıları
   farklı; yalnız TÜBİTAK duyurusundaki sayılar, tarihiyle alındı.
4. **Yanlış künye:** kayıt defterine bir yazar adı yanlış girilmişti
   (Abdikan 2022) ve bir makalenin yılı ile başlığı eksikti (Özdemir 2025);
   ikisi de Crossref'e göre düzeltildi.
5. **Erişim:** Bakanlık alan adları bir süre DNS'te çözülmedi; §10 önce
   makine verisi olmadan yazıldı, alan adı dönünce eklendi. Zenodo isteği
   "olağandışı trafik" diye reddetti; zorlanmadı.
6. **Zaman kipi:** BAGİS cihaz yenileme ve programdaki 2027 tedbirleri
   gelecek zamanla yazıldı.

### 5 · Sınama — bir hata ve düzeltmesi

§12 eklenince "öne çıkan başlık" testi düştü: test sabit on günde bütün
yazılmış başlıkların dönmesini bekliyordu, yazılmış başlık 11 oldu. Ürün
doğruydu; test N başlık için N gün dolaşacak şekilde düzeltildi (`7f8e82d`).
**§12 commit'i (`99f8abf`) bu test düşükken atıldı:** komut zincirindeki
`grep` test sonucunu maskeledi. O commit'ten sonra her commit yalnız test
çıktısında "All tests passed" görülürse atılıyor. Tur sonunda bölüm ve panel
testleri 63/63.

## Tur 7'ye kalanlar

1. **§16-§21:** pazar, fiyat ve tedarik zinciri; iklim, risk ve tarım
   sigortası; danışmanlık ve dil modelleri; uydu ve uzaktan algılama;
   sensörler ve tarımsal nesnelerin interneti; veri sahipliği ve platformlar.
2. **§23 ve §24 güncellemesi:** BAGİS yapay zekâ projesi ve OGM sistemleri
   (yukarıda § 3).
3. Tur 5'ten kalanlar sürüyor: kuyruk okuması (kullanıcı), eksik özellikler
   (karar 10, 14, 15, 16, 38), açılış öncesi denetim (Tur 10).


## Tur 7 — ZİNCİR VE ALTYAPI: §16-§21, §23 ve §24 güncellemesi · 17 Kasım 2026

Kullanıcı: "tur 7'ye ilgili diğer dahil işlere devam et", ardından
"sonuçlar gelince başlıkları yazmaya geç."

### 0 · Yöntem: araştırma ajanları (karar 54)

Kaynak taraması üç paralel araştırma ajanına bölündü (§16-§17, §18-§19,
§20-§21). Her ajan kaynakları geçici bir klasöre indirdi, alıntıları
`dogrula_alintilar.py` ile aynı kuralı uygulayan bir sınayıcıdan geçirdi ve
aday kayıt bıraktı. Adaylar kilitli kayıt sayılmadı: her kaynak yeniden
okundu, metne giren her "geçmiyor / bulunamadı / ölçülmemiş" iddiası
belgenin kendisinde arandı (aşağıda § 4). Ajanlar çalışırken §23 ve §24
güncellendi.

### 1 · Yazılan ve güncellenen başlıklar

| § | başlık | kaynak | alıntı | sayı (TR = EN) | commit |
|---|---|---|---|---|---|
| 23 | Türkiye'de durum — güncelleme | 11 | 42 | 78 | `e79b6c9` |
| 24 | Mevzuat ve politika — güncelleme | 7 | 32 | 61 | `ec53c22` |
| 16 | Pazar, fiyat ve tedarik zinciri | 9 | 41 | 38 | `9f8fd08` |
| 17 | İklim, risk ve tarım sigortası | 11 | 64 | 72 | `e86f1bb` |
| 18 | Danışmanlık ve dil modelleri | 9 | 59 | 42 | `457d960` |
| 19 | Uydu ve uzaktan algılama | 10 | 51 | 50 | `6f13a20` |
| 20 | Sensörler ve tarımsal nesnelerin interneti | 11 | 53 | 100 | `a002597` |
| 21 | Veri: sahiplik, platformlar, açık veri | 9 | 56 | 40 | `664fc2c` |

Yazılmış başlık: 20/30 (§4-§21, §23, §24). Kaynak kaydı 317 dosya.

**§23'e eklenenler:** "Programın dışında: sahada çalışan sistemler" (TRGM ürün
belirleme, OGM Karar Destek Sistemi, BAGİS yapay zekâ projesi); "Araştırma
tarafı: TAGEM" (2025 faaliyet raporu: üç yapay zekâ projesi, VetAlarm,
Master Plan'daki fırsat alanı; ZMMAE otonom sera robotu ortaklığı); strateji
belgesinin hazırlığı birincil kaynakla (Bakan'ın Mayıs 2025 konuşması, Ekim
2025 çalıştayı). TAGEM araştırma merkezinin kurulduğu hâlâ yalnız haberde —
metne plan olarak girdi. **§24'e eklenen:** "Yapay zekâya değinmeyen
kurallar" (AB 2021/2116 alan izleme zorunluluğu; BAGİS isterlerinde KVKK,
kapalı devre, sızma testi).

### 2 · Başlıklar arası desen

Zincir ve altyapı başlıklarında yapay zekâ için ölçülen şey çoğunlukla
**modelin isabeti**, tarladaki sonuç değil: GraphCast 1.380 hedefin %90'ında
önde (§17), ChatGPT yanıtları yayım elemanınınkinden yüksek puanlı (§18),
fiyat modelinin hatası ARIMA'nın altında (§16). Çiftçide ölçülmüş sonuç
yalnız dijital danışmanlıkta var ve mütevazı (§18: verim %4; kişiye özel
öneri %7). Altyapıda engel algoritma değil: kırsal bağlantı, küçük işletme,
maliyet, birlikte çalışabilirlik, güven (§20, §21).

Türkiye'de devletin dijital altyapısı kayda değer ve zorunlu: HKS künyesi
(§16), ÇKS (§21), Köy Bazlı Verim Sigortası (§17), MGM'nin 1.717 otomatik
istasyonu (§20), evrensel hizmet (§20). Ama bu altyapının üstündeki yapay
zekâ plan ya da araştırma düzeyinde: TARSİM raporunda, MGM programında, TEPGE
raporunda yapay zekâ geçmiyor; eylem planı veriyi konuşuyor ama çiftçiyi
değil. Altı başlığın altısında da "bulunamayan şey" aynı yere çıkıyor.

### 3 · Türkiye için yeni bulgular (öteki başlıklara da girecek)

- **TAGEM 2025 faaliyet raporu:** meyve ve bağda derin öğrenmeyle hastalık
  tespiti (8 enstitü, 2 üniversite), kuru kayısıda multispektral ölçüm,
  mısır ve pamukta yabancı ota hedefli ilaçlama prototipi (§8 adayı),
  VetAlarm (§12 adayı), ZMMAE otonom sera robotu (§13 adayı), TAGEM-SuET
  (§7 ve §18'de anıldı), toprak veri tabanı (§4 adayı).
- **Bakan'ın Mayıs 2025 konuşması:** otomatik sulama 3 ilde 45 bin dekar
  (kurum beyanı; §7 adayı — alıntı henüz kayda girmedi).
- **TÜBİTAK UZAY kataloğu:** GAP'ta değişken oranlı gübrelemede %25'e kadar
  tasarruf beyanı (yöntemsiz) — §19'da anıldı; §6'ya girip girmeyeceği Tur
  10'da kararlaştırılacak.

### 4 · Doğrulama sırasında yakalananlar

1. **Paydası belirsiz oran (§17):** TARSİM'in don ihbar oranı (%39,8) bütün
   ihbarların değil bitkisel ürün ihbarlarının payı; paydayı veren cümle
   kayda eklendi.
2. **Kayıtta olmayan yıl (§17):** tablodaki "2022" sütun başlığındaydı;
   doğrulayıcı yakaladı, başlık satırı alıntılandı.
3. **Tutarsız tablo (§16):** Türkiye'den bir fiyat tahmini çalışmasında bir
   modelin hatası ötekilerden yaklaşık iki basamak düşük; sonuç rakamları
   alınmadı, yalnız verinin HKS sitesinden elle derlendiği yazıldı.
4. **Nedensellik tuzağı (§19):** programda işlenmeyen arazinin üretime
   dönüşü re'sen kiralama uygulamasına bağlanıyor ve tespit yöntemi
   yazmıyor; bakanlık raporundaki "uydu + derin öğrenme" cümlesiyle
   birleştirilmedi.
5. **Ölçülmemiş öneri (§18):** domates zararlısı çalışmasında ölçülen başarı
   tespit modeline ait; tam metin okunarak dil modelinin önerilerinin
   ölçülmediği doğrulandı.
6. **Yeniden hesaplanmış rakam (§17):** FAO'nun 2023 ve 2025 kayıp toplamları
   farklı yöntemle hesaplandı; yan yana konmadı.
7. **"Geçmiyor" iddiaları belgede sayıldı:** TARSİM raporu, MGM programı,
   TEPGE raporu, bakanlık faaliyet raporu, BTK raporu, eylem planı (çiftçi,
   kırsal, köy, veri sahipliği), program (sohbet robotu, blokzincir, fiyat
   tahmini).
8. **Bağlantı/kurum:** Çukurova Üniversitesi bağı, Eldem'in üniversitesi ve
   KVKK'nın istisna maddesi belgeden alıntılanarak kayda girdi; bir "en
   geniş" üstün sıfatı çıkarıldı.

### 5 · Sınama ve önizleme

Her başlık ayrı commit; her commit "All tests passed" görüldükten sonra.
Bölüm ve panel testleri tur sonunda 81/81. Yerel önizleme: bölüm yalnız
önizleme derlemesinde açık (`build/yz_onizleme`, port 8132, `.claude/
launch.json` → `yz-onizleme`); `deploy.sh --no-build`'in kullandığı
`build/web`'e dokunulmadı, bayrak depoda kapalı.

## Tur 8'e kalanlar

1. **§22** dünyada durum (bölge bölge), **§25** Türkiye dizini (veritabanından,
   karar 38), **§26** riskler ve sınırlar, **§27** başarısız örnekler ve
   abartılar, **§28** saha hikâyeleri.
2. **Tur 10 denetimine eklenenler:** §23'ün kapanış cümlesi bütün başlıkların
   kapanışıyla yeniden sınanacak; § 3'teki TAGEM projeleri ve Bakan'ın
   sulama beyanı ilgili başlıklara (§6, §7, §8, §12, §13) girecek mi
   kararlaştırılacak.
3. Tur 5'ten kalanlar sürüyor: kuyruk okuması (kullanıcı), eksik özellikler
   (karar 10, 14, 15, 16, 38), açılış öncesi denetim (Tur 10).

---

## Tur 8 — DÜNYA, DİZİN VE ELEŞTİRİ: §22, §25-§28 · 17 Kasım 2026

Başlıklar okura KAPALI (karar 51). 30 başlığın **25'i** yazıldı; kalan beşi
Tur 9'un (§1-§3, §29, §30).

### 0 · Yöntem

Beş başlığın aday kaydını araştırma ajanları hazırladı (karar 54). Kayıt
kilitlenmeden önce her alıntı belgede yeniden sınandı; ajanın yorumu
(`_not`) metne doğrudan girmedi, iddialar alıntı ve sayısal alanlarla
karşılaştırıldı. Karar 55 (yayın metni okur içindir) bu turun bütün
metinlerine uygulandı; önceki 20 başlığın metni de turun başında okur
diline çevrildi (a5f08d1).

### 1 · Yazılan başlıklar

| § | başlık | kayıt (kaynak · alıntı) | commit |
|---|---|---|---|
| 28 | Saha hikâyeleri | 13 · 113 | 8de380e |
| 22 | Dünyada durum: bölge bölge | 12 · 106 | 99db4e7 |
| 25 | Türkiye dizini | 54 · 218 | 528897f |
| 26 | Riskler ve sınırlar | 10 · 91 | 8714cc4 |
| 27 | Başarısız örnekler ve abartılar | 14 · 68 | 7f3ebe1 |

Ayrıca §23 düzeltildi (dbf20d1): Bakanlığın 4 Haziran 2026 tarihli
sayfasına göre Yapay Zekâ ve Dijital Tarım Teknolojileri Araştırma Merkezi
"kurduk", strateji belgesi "hazırladık" — eski cümle haberlere dayanıyordu.
Merkezin birimi ve yeri sayfada yok; metin TAGEM demiyor.

### 2 · Başlıklar arası desen

- **Satıcı etiketi (karar 34/35)** §25 ve §27'de yoğun: şirketin ne yaptığı
  ya da ne vaat ettiği "şirketin kendi tanımı/beyanı"; bağımsız kayıt ayrı
  (FAO–EBRD 2025 raporu, TÜBİTAK listesi, Companies House, mahkeme süreci
  sayfası).
- **Kopya kaynak:** §25'teki kamu sistemleri ve üniversite çalışmaları
  b06-b23 kayıtlarından seçili alan ve alıntılarla kopyalandı (`_kopya`
  alanı); sayısal alanların çoğu taşınmadı, havuz dar tutuldu.
- **Tekrar eden kaynaklar:** Mohanty 2016 §8'de anılıyor, §26'da ayrıntılı,
  §27'de gönderme. Bac 2014 §10 ve §27'de. Aynı belge birden çok kayıtta
  aynı dosyayı gösteriyor (kayıtta tek dosya).

### 3 · Türkiye için yeni bulgular

- TÜBİTAK 1711'in akıllı tarım, gıda ve hayvancılık alanında **10** kabul
  kartı (elle sayıldı, `_sayim`); her kartta müşteri, teknoloji sağlayıcı
  ve üniversite. İki kartta sayfa tutarsızlığı: Doğanlar kartının müşterisi
  "Merlab", Easyflex kartının başlığı açıklamasıyla uyuşmuyor. Metin
  müşteri kuruluşu yazmıyor; Easyflex için açıklamayı esas alıyor.
- TUCSAP (Hazine Kontrolörleri, 2025 denetimi): kredinin %12,91'i
  harcanmış, hibe sıfır; 2025 bütçesi 108,8 → 55,6 milyon avro. Sütunlar
  s.17 tablo başlığından okundu.
- ÇKS'de ortalama işletme 6,9 ha (UKKS-IV, 2023); tarımda çalışanların yaş
  ortalaması 46, bütün istihdamda 39 (Şûra belgesi, TÜİK 2023).
- Türkiye'de kapanan bir tarım teknolojisi girişimine dair birincil kaynak
  bulunamadı; §27'nin Türkiye örneği takvimi kayan kamu projesi.

### 4 · Doğrulama sırasında yakalananlar

- §17/§19 EN'de Bakan için cinsiyetli zamir — kaldırıldı.
- AgCurate: "merkezi Hollanda'da" yerine "sitesinde verdiği adres".
- Actimoo: "ineklere" yerine şirket tanımındaki "hayvanlara".
- TAKİS'in yürütücü kurumu programda yazmıyor; tabloda kurum adı yok.
- HKS yönetmeliğinde "Bakanlık" 2012 metninde Gümrük ve Ticaret
  Bakanlığı; tabloda bakanlık adı yazılmadı.
- AppHarvest dava sayfasındaki "Effective Date" alanı plan yürürlüğü diye
  yorumlanmadı, metne girmedi.
- FAO %70: 2009 belgesindeki cümle başlangıç yılını yazmıyor; metin
  2005/07 bazını yalnız AT2050 ve 2017 güncellemesi için kullanıyor.
- TEKNOFEST'in "her yıl derece veriyor" cümlesi 2020-2025 derece
  başlıklarının hepsi görülerek yazıldı.
- §25'in ZDUS satırı, MGM belgesinde ayrı bir ürün olan Zirai Don Risk
  Tahmin Haritaları'nı ZDUS'a bağlamıştı; §17'deki ifadeye (bitki bazında
  5 günlük tahmin ve risk durumu) çekildi (67fa9d5).
- **Çizici:** tablo başlıkları, bölüm adı ve katman etiketleri ham
  `toUpperCase()` ile büyütülüyordu ("ŞIRKET", "ÜNIVERSITE", "DIJITAL").
  Beş yer `core/utils/turkce_metin.dart`'taki `buyukHarf(metin, isEn)` ile
  değişti; `YzMetinGorunumu` artık dili alıyor. Sınama eski kodla düşüyor
  (b33ceba).

### 5 · Sınama ve önizleme

98 test geçti. Kaynak deposu 384 dosya (`_ortak/ham_kaynaklar.json`).
Önizleme (yz-onizleme, 8132) bölüm açık bayrakla yeniden kuruldu; bayrak
derlemeden sonra geri alındı. §25'in tabloları geniş ekranda tablo, telefonda
kart olarak ve doğru Türkçe büyük harfle görüldü.

## Tur 9'a kalanlar

1. **§1-§3** (durum tespiti, kavramlar, tarihçe), **§29** sözlük ve balon
   (karar 14), **§30** kaynakça (karar 15). Bunlarla açılış eşiği (30/30)
   dolar.
2. **Karar 38:** §25'in dinamik kısmı — taramanın önerdiği dizin
   adaylarının onayla dizine girmesi (panel kuyruğu). b25 kaydı veritabanı
   için tohum olabilir.
3. **Tur 10 denetimine eklenenler:** TÜBİTAK 1711 sayfasındaki iki kart;
   §25'teki girişim sitelerinin ve FAO listesinin (2022 haritası)
   güncelliği; §27'deki şirketlerin sonraki durumu (Infarm'ın kayyum süreci
   sicile göre 4 Eylül 2025'te bitti, sonucu kaynakta yok).
4. Önceki turlardan: §23 kapanış cümlesi; TAGEM projelerinin §6, §7, §8,
   §12, §13'e girişi; kuyruk okuması (kullanıcı); eksik özellikler (karar
   10, 14, 15, 16, 38); açılış öncesi denetim (Tur 10).

## Tur 9 — DURUM, KAVRAMLAR, TARİHÇE, SÖZLÜK VE KAYNAKÇA: §1-§3, §29, §30 · 17 Kasım 2026

Başlıklar okura KAPALI (karar 51). 30 başlığın **30'u** yazıldı: açılış
eşiği (tamamı) doldu. Açılış (`yayin.json`), dağıtım ve GitHub'a gönderme
kullanıcının ayrı ayrı açık onayını bekliyor.

### 1 · Yazılan başlıklar

| § | başlık | kayıt (kaynak · alıntı) | commit |
|---|---|---|---|
| 30 | Kaynakça | üretilmiş · 261 kaynak, 29 başlık | 4386efa |
| 1 | Bugün nerede duruyoruz | 33 · 43 (hepsi öbür kayıtlardan kopya) | d220bc4 |
| 3 | Kısa tarihçe | 40 · 177 | a8b30c3 |
| 2 | Kavramlar | 23 · 166 | e9cdc4b |
| 29 | Sözlük | 30 · 93 · 58 terim | d205d12 |

§26 düzeltildi (85907be): FAO-EBRD 2025 raporundaki bakanlık anketi
(2020; çiftçilerin %3'ünden azı akıllı tarım teknolojisi kullanıyor)
eklendi, kapanış "düzenli olarak ölçen" diye daraltıldı.

### 2 · Altyapı

- **§30 kaynakça** (`kaynakca_uret.py`, karar 15): bütün kayıtlardan
  kendiliğinden. Aynı belge tek satır (künye, DOI ve adres birleşimi),
  Türk alfabesiyle sıralı, her satırda geçtiği başlıklar; İngilizce
  sayfada künyenin Türkçe parçaları çevriliyor. Elle yazılmıyor:
  `dogrula_bolumler.py` sayfanın ve `b30` kaydının üreticinin çıktısıyla
  birebir olduğunu sınıyor (§30'da sayı izi yok, yalnız bu).
- **§29 sözlük ve balon** (karar 14): `sozluk.json` → `sozluk_uret.py` →
  §29 sayfası + `b29` kaydındaki `terim_sayisi`; `dart_uret.py` →
  `yz_sozluk.g.dart`. Her tanım kayıttaki alıntıya dayanıyor. Balon
  terimin sayfadaki ilk uygun geçişinde açılıyor; kurallar:
  - Türkçe ek kelimenin sonuna kadar işaretleniyor; `=` önekli desen
    (kısaltma) büyük-küçük harfe duyarlı ve tam kelime.
  - Kalın/italik parça, tırnak içi (birebir alıntı) ve adres sayılmıyor.
  - Cümle ortasında büyük harfle başlayan geçiş özel adın parçası:
    "Türkiye Yapay Zekâ Eylem Planı", "UCI Machine Learning Repository",
    "Bitki Su Tüketimi Sistemi" işaretlenmiyor.
  - Uzun terimin BÜTÜN geçişleri kısa terime gölge: "iklim akıllı
    tarım"ın içindeki "akıllı tarım", "sohbet robotu"nun içindeki "robot"
    ayrıca işaretlenmiyor — uzun terim sayfada önceden işaretlenmiş olsa
    bile.
  - Başka anlamda geçtiği başlıklar `haric`/`yalniz` ile dışarıda
    (doğruluk: sensör doğruluğu §7, beyan doğruluğu §9 ve §23, regresyon
    ve tahmin isabeti §4-§6, §16, §17; sınıflandırma: CEMA'nın
    sınıflandırması §2, toprak sınıflandırması §4; açık veri: "kamuya açık
    veri" §6; kontrollü ortam: §26'daki çekim koşulu; otonom: §13'teki
    sera yarışması; kesinlik ve duyarlılık yalnız §18).
  - §29 ve §30 sayfalarında balon yok (`kYzSozluksuzBasliklar`).
  - Python eşleştiricisi (`terimleri_bul`) Dart'ınkinin (`yzTerimleriBul`)
    birebir karşılığı; Dart'ın `List.sort`'u kararlı olmadığı için eşit
    uzunlukta desenlerde sözlük sırası kullanılıyor. Test §29'daki
    "Geçtiği başlıklar"ı Dart'ın hesabıyla karşılaştırıyor. Üretici, iki
    dilde de hiçbir başlıkta balon açmayan terimi kabul etmiyor.
  - Tablo hücrelerinde balon yok.
- **Adres bağlantıları:** metindeki adresler dokunulabilir (§30); sondaki
  noktalama ve kapanmamış parantez adrese dahil değil.
- **Merkez sayfada §1:** özetin ilk paragrafı haritanın üstünde, "Durum
  tespitinin tamamı" bağlantısıyla (karar 6).

### 3 · Doğrulama sırasında yakalananlar

- §1-§3: Michalski ve Baskin'in ortak yazarlığı; FarmerChat'in kimin
  ürünü olduğu cümlesi; OECD 2019 tavsiyesinin tarihi; ISPA panelinin
  zamanı; "bilinen tek ölçüm" iddiası yumuşatıldı. EN §2'de tırnak
  içindeki çeviri terimler Türkçe asıllarıyla değişti, çevirisi parantezde.
- §26'nın kapanışı, bakanlığın 2020 anketi bulununca daraltıldı.
- Sözlük bağlam taramasında (`sozluk_uret.py --baglam`) eşleştirici yanlış
  yerleri işaretliyordu: "büyük veri" deseni "Büyük verim açığı"nı (§20),
  "akıllı tarım" "iklim akıllı tarım"ın içini (§27), "robot" "sohbet
  robotu"nu (§3, §18), "doğruluk" ÇKS beyanlarının doğruluk kontrolünü (§9,
  §23) ve sensör doğruluğunu (§7), "sınıflandırma" CEMA'nın
  sınıflandırmasını (§2); §2'de UYZS'nin tırnak içindeki tanımında
  "robotun"u. Büyük veri desenleri ek ek yazıldı ("verim" dışarıda), gölge,
  özel ad ve tırnak kuralları eklendi.
- Gölge ve özel ad kuralları geçici olarak bozulunca hem kendi testleri
  hem §29 eşlik testi düşüyor.
- §12'deki tanı duyarlılığı (sensitivity) için kayıtta tanım yok; Google
  sözlüğü yalnız recall'u tanımlıyor. Duyarlılık balonu yalnız §18'de.
- "Dijital ikiz" yalnız §25'in tablosunda, "bitki su tüketimi" yalnız
  TAGEM-SuET'in adında geçiyor; balon açmadıkları için sözlüğe girmedi.
- Eylem Planı sözlüğünde terim adları ayrı sütunda; pypdf tanımı adından
  ayırıyor. "LLM (Büyük Dil Modeli)" ve "Veri Alanı" tanımları etiket
  listesinin ve tanımların alfabetik sırasıyla eşleştirildi; etiketler de
  alıntı olarak kayıtta.
- Değişken oranlı uygulamanın kaynağı (ERS) ekipmanı tanımlıyor; tanım
  "uygulama" ile "ekipman" ayrımına göre yazıldı.
- §2'nin araştırma ajanı bir adrese HEAD isteği gönderdi (veri
  gönderilmedi); ajan talimatlarına "yalnız GET" açıkça yazılacak.

### 4 · Sınama ve önizleme

125 test geçti. Kaynak deposu 448 dosya.
Önizleme (yz-onizleme, 8132) bölüm açık bayrakla yeniden kuruldu; bayrak
derlemeden sonra yedekten geri yüklendi (`build/web`'e dokunulmadı).
Masaüstünde ve telefon genişliğinde balon açılıyor (ekranın altındaki
terimde yukarı doğru), "Sözlükte aç" §29'a götürüyor, §29 sayfasında
balon yok; §30 yeni sayılarla (261 kaynak, 29 başlık) çiziliyor.

## Tur 10'a kalanlar (açılış öncesi)

1. **Açılış kararı kullanıcının:** eşik doldu. `yayin.json`'daki
   `okura_acik` ancak açık onayla değişir; dağıtım ve GitHub'a gönderme
   ayrı onay ister (dal `yapay-zeka-bolumu`).
2. **Açılış öncesi denetim:** 30 başlığın baştan sona okunması (karar 55
   dili, TR/EN tutarlılığı, iç göndermeler, §1 özetinin öbür başlıklarla
   uyumu); telefonda ve masaüstünde balon, bağlantı ve tablo denetimi;
   kaynak adreslerinin canlılığı.
3. **Karar 38:** §25'in dinamik kısmı — taramanın önerdiği dizin
   adaylarının onayla dizine girmesi (panel kuyruğu).
4. **Sözlük:** tablo hücrelerinde balon yok (dijital ikiz §25'te yalnız
   tabloda); §12'deki tanı duyarlılığı ve özgüllüğü için kaynaklı tanım;
   web'de "Sözlükte aç" (`push`) adres çubuğunu değiştirmiyor — uygulamanın
   geri oku başlığa dönüyor, tarayıcının geri tuşu başlığı atlıyor.
5. Tur 8'den: TÜBİTAK 1711 sayfasındaki iki kart; §25'teki girişim
   sitelerinin ve FAO listesinin güncelliği; §27'deki şirketlerin sonraki
   durumu.
6. Önceki turlardan: §23 kapanış cümlesi; TAGEM projelerinin §6, §7, §8,
   §12, §13'e girişi; kuyruk okuması (kullanıcı); eksik özellikler (karar
   10, 16, 38).

## Tur 10 — AÇILIŞ ÖNCESİ DENETİM · 17 Kasım 2026

Başlıklar okura KAPALI (karar 51). Denetim bitti; açılış (`yayin.json`),
Supabase göçü, dağıtım ve GitHub'a gönderme kullanıcının ayrı ayrı açık
onayını bekliyor (aşağıda "Açılış adımları").

### 0 · Yöntem

30 başlık üç denetim ajanıyla baştan sona okundu (§1-§9, §10-§19,
§20-§28; §29 ve §30 üretilmiş, kendi denetleyicileri var). Her bulgu
uygulanmadan önce kayda ve belgenin kendisine karşı tek tek sınandı;
kaynağa uymayan öneri uygulanmadı ya da kaynağa göre yeniden yazıldı. Örnek:
§22'de "devlet desteği ayrı bir dijital tarım programından gelmiyor"
önerisi ERS raporuna aykırıydı (rapor son yıllarda birkaç doğrudan federal
program uygulandığını yazıyor); cümle raporun dediğine göre kuruldu.

### 1 · Eksik özellikler (karar 10, 16, 38)

- **Karar 38** (614c392): §25'in "Dizine sonradan eklenenler" listesi;
  panelde onay teyidi, "Dizinde" sekmesi, tek tıkla çıkarma. Okur yalnız
  `yz_dizin_eklenenler()`in döndürdüğü alanları görüyor. **Göç yazıldı,
  UYGULANMADI** (`supabase/migrations/20261117120000_yz_dizin_okur.sql`);
  uygulanana kadar liste boş, sayfa bozulmuyor.
- **Karar 16 ve 10** (haber hattı ff061cd, 82e150c — GitHub'a
  gönderilmedi): başlığa bağlı sayfa izleme (`tarama_sorgulari.json`
  `sayfalar`: 55 satır, 41 adres; 'seri' sayfa → `sayi_guncelleme`),
  başlık başına süzgeç, RSS; başlık önerisi (en az 3 haber; model haber
  numarası uyduramıyor, var olan başlığı yeniden öneremiyor). 11 test.
- **Sözlükten geri yol:** "Sözlükte aç" `go` ile gidiyor, `?geri=`
  sözlüğün geri okunu balonun açıldığı başlığa bağlıyor.

### 2 · Metin denetimi — kaynağa göre düzeltilenler

- **§26:** tarım istihdamının düşüşü belgenin kendi rakamlarıyla 525 bin;
  belge "yaklaşık 800 bin" diyor. Metin farkı değil iki düzeyi yazıyor;
  kayıtta `_tutarsizlik` notu.
- **§24:** "2028'den önce bağlayıcı AB gerekliliği yok" yanlıştı — Makine
  Tüzüğü'nün öğrenen güvenlik bileşenleri için bağımsız değerlendirme şartı
  14 Ocak 2027'de başlıyor. Deney alanlarının sektörleri "belli değil"
  değil: plan finans, sağlık, enerji, mobilite ve telekomünikasyonu
  sayıyor; tarım yok (alıntı b24'e eklendi).
- **§23, §25:** "merkezin bağlı birimi açıklanmadı" cümlesi çıktı
  (haberler TAGEM bünyesinde diyor). Yıllık programın "tek yapay zekâ
  işi" tarım bölümüyle sınırlandı (programın başka bölümlerinde yapay
  zekâ çok geçiyor). Bakanlığın "üç izleme işi"ne idare faaliyet
  raporundaki işlenmeyen arazi ve dikili alan tespiti eklendi; §25
  tablosuna satır.
- **§22:** Çin'deki BeiDou cihazları birikimli sayı; ABD'de çevre koruma
  ödemeleri hassas ilaçlamayı "sözleşmeye bağladı"; Eurostat analizi 2023
  araştırmasına dayanan Temmuz 2026 tarihli; Afrika sayımı "son" değil.
- **§21:** "çiftçi en az devlete güveniyor" değil, verisini en az devletle
  paylaşmak istiyor; KVKK m. 28'in iki istisnası ayrıldı.
- **§20:** örneklem "temsilî değil" değil, rastgele seçilmedi (yazarlar
  "representative" diyor). **§19:** İMECE için resmî kanal ya da somut tarım
  projesi açıklanmış değil. **§25:** Dijital Köyler Girişimi 31.12.2025'te
  tamamlandı. **§27:** %70'ten %50'ye görünen düşüşün büyük kısmı başlangıç
  yılı ve kapsam farkı (küçük bir düşüş var). **§28:** Meksika'daki sensör
  "bırakılmadı", benimsenmesi geriledi; Nuru yayım elemanlarıyla
  karşılaştırıldı, "uzman"larla değil.
- **Tutarlılık:** TUCSAP'ın adı tek biçim; "IV. Tarım Orman Şûrası";
  B-Reçete; Zirai Mücadele Merkez Araştırma Enstitüsü'nün İngilizce adı;
  "dâhil"; §2 başlığı "yapay zekâ".
- **TAGEM projeleri:** §7'ye TAGEM-SuET, §13'e otonom sera robotu (domates
  serası bilgisi TÜBİTAK 1711 kartından); §8, §10 ve §12'ye daha önce
  girmişti. §6'ya uyan TAGEM projesi yok.
- **Güncelleme paragrafları:** her başlık yalnız taramanın gerçekten
  yaptığını söylüyor; `dogrula_tarama.py` kural 4-6 bunu sınıyor (Resmî
  Gazete'yi kendi süzgeciyle izleyen dizin sayfası da kabul). Elle
  derlenen §27 ve §28'de "editör tarafından derleniyor".
- **§29:** iklim akıllı tarım tanımı ("mümkün olan yerlerde"); İngilizce
  özette "this guide". **§30:** İngilizce sayfada künyelerdeki Türkçe
  açıklamalar çevriliyor (~80 kalıp: kurum ve şehir adları, belge türleri,
  tarih notları, adres notları); İngilizce sayfa kendi metninin alfabesiyle
  sıralanıyor. Türkçe asıl başlıklar ve Türk kurumlarının adları olduğu
  gibi.

### 3 · Kayıtlar ve kaynak canlılığı

- Bütün kayıtlarda belge dosyası ve birebir alıntı (yalnız yayımlanmamış
  `bakanlik_belgesi` `_dayanak`la). Kopya kuralı (kural 7) 69 kopyayı
  asılla sınıyor. Alıntı doğrulayıcı: 2049 alıntı belgede birebir.
- `kaynak_canlilik.py` (yeni): kayıtlardaki her adres GET ile, sunucu
  başına saniyede bir; rapor `kaynak_canlilik.json`. Son koşu (17 Kasım
  2026): 209 açık, 3 kısa (FAO'nun
  betikle yönlendiren sayfaları), 39 engelli, 2 kapalı — iki kapalı adres
  (Çin bakanlığı sayfası, bir DOI) hemen ardından denendiğinde açıldı,
  geçici.
  - tucson.ars.ag.gov kapanmış (alan adı çözülmüyor): kaynak UNT End of
    Term arşivindeki kopyaya bağlandı — yerel dosyayla sha256'ca aynı.
  - Bakanlığın stratejik planı yeni adreste (SGB/Belgeler) — sha256 aynı.
  - UKKS-IV PDF'i tarayıcıda da 401 döndürüyor; bakanlığın Yayınlarımız
    sayfası hâlâ bu adrese bağlanıyor, başka resmî kopya bulunamadı.
    Kayıtta `_erisim_notu`; yerel kopya duruyor (karar 24).
  - "Engelli" satırların çoğu yayıncıların otomatik isteğe 403'ü (DOI);
    doktar.com bağlantıyı sıfırlıyor. Bunlar aşılmadı.

### 4 · Sınama ve önizleme

129 test geçti; `dogrula_bolumler.py`, `dogrula_tarama.py`,
`sozluk_uret.py --denetle`, `kaynakca_uret.py --denetle` yeşil; süreç dili
taraması temiz. Önizleme (yz-onizleme, 8132)
bu kez commit'ten açılan geçici bir `git worktree`'de, bayrak yalnız orada
açılarak derlendi; depodaki bayrak hiç değişmedi. (İlk deneme oturum
kesilince yarıda kaldı ve depodaki bayrak açık kaldı; `dart_uret.py` ile
geri alındı, commit'e girmedi.) §13 (İngilizce), §23, §25 (yeni satır,
kapanış, güncelleme paragrafı) ve §30 (iki dil) gözle görüldü. Konsoldaki
tek hata `rpc/yz_dizin_eklenenler` 404'ü: göç uygulanmadığı için beklenen,
liste boş kalıyor.

## Açılış adımları (sırayla; her biri kullanıcının ayrı onayıyla)

1. **Supabase göçü:** `supabase/migrations/20261117120000_yz_dizin_okur.sql`
   (canlı veritabanı). Uygulanmazsa §25'in dinamik listesi boş kalır.
2. **Son canlılık koşusu:** `python3 -I _raw/kaynak_canlilik.py`, sonra
   `--ozet`; yeni "kapali" satırı varsa adres düzeltilir.
3. **Açılış:** `yayin.json` → `"okura_acik": true`; `python3 -I
   dart_uret.py` (30/30'u sınar, eksik varsa durur). Doğrulayıcılar ve
   `flutter test test/yz_bolum_test.dart test/yz_panel_test.dart`.
4. **Dağıtım:** `./deploy.sh --hosting` (fonksiyon değişmedi; sürüm ve
   durum bekçileri koşuyor). Bayrak açıkken paylaşım kabukları da
   üretiliyor.
5. **Git:** `yapay-zeka-bolumu` dalının birleştirilmesi ve GitHub'a
   gönderilmesi; haber hattında ff061cd ve 82e150c (tarama ELLE koşuyor).
