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

