# DSİ — Kurum Dosyası Sayı 05 · ham kaynak kaydı

**Tur 1 (kaynak katmanı) tamam.** Dokuz kaynağın dokuzunun kimliği
`dogrula_kaynak.py` ile sınandı. Eksen HENÜZ SEÇİLMEDİ — §8.12'nin kuralı:
bir bölümün biçimi kaynaktan önce seçilmez.

```
bash cek.sh                                    # çekim
~/tarim_ai_pipeline/venv/bin/python dogrula_kaynak.py   # kimlik sınaması
```

> `pypdf` sistem Python'unda yok, hat venv'inde var. Bu dosyanın bütün PDF
> işleri o yorumlayıcıyla çalışıyor.

## Kaynaklar ve SINIFLARI (§2.2 — üç sınıf karıştırılmaz)

| dosya | sınıf | ne |
|---|---|---|
| `kanun_6200.pdf` | **BİRİNCİL** | DSİ Genel Müdürlüğünce Yürütülen Hizmetler Hakkında Kanun · kabul 18/12/1953 · RG **25/12/1953 · 8592** · 24 sayfa |
| `kanun_6172_sulama_birlikleri.pdf` | **BİRİNCİL** | Sulama Birlikleri Kanunu · kabul 8/3/2011 · RG **22/3/2011 · 27882** · 11 sayfa |
| `faaliyet_2025.pdf` | KURUMUN BEYANI | 136 sayfa |
| `faaliyet_2022.pdf` | KURUMUN BEYANI | 164 sayfa |
| `faaliyet_2019.pdf` | KURUMUN BEYANI | 181 sayfa |
| `site_hakkimizda.html` | KURUMUN BEYANI | misyon + kurumsal silsile |
| `site_toprak_su_kaynaklari.html` | KURUMUN BEYANI | ülke su potansiyeli |
| `site_sulama_dairesi.html` | KURUMUN BEYANI | sulama dairesi görevleri |
| `site_istatistik.html` | KURUMUN BEYANI | haritalı istatistik bültenleri dizini |

**RG künyeleri birincil kaynaktan okundu.** TMO dosyasında bu mümkün
olmamıştı (§8.7: "henüz birincil kaynaktan doğrulanmadı"); `mevzuat.gov.tr`
10 Eylül 2026'da açıldı (§8.14.1) ve bu, dizinin RG künyesi taşıyan ikinci
dosyası oluyor.

## İlk iki bulgu — ikisi de birincil/beyan kaynaktan

**1. Kuruluş maddesi mülga.** 6200'ün 1. maddesi:
`(Mülga: 2/7/2018 – KHK-703/69 md.)`. Kanun duruyor, kurumu tarif eden
madde yok. Neyin yerine geçtiği HENÜZ OKUNMADI — okunmadan yoruma
gidilmeyecek.

**2. Kurum kuraklıktan doğdu.** `site_hakkimizda.html` silsileyi veriyor:
1914 Nafıa Nezareti yeniden yapılanması → 1925 "Sular Fen Heyeti" →
**1929 şiddetli kuraklık ve kıtlık neticesinde "Sular Umum Müdürlüğü"** →
1953 DSİ. Kuruluş tarihi kanun metniyle BAĞIMSIZ OLARAK örtüşüyor
(18 Aralık 1953) — iki ayrı kaynak, aynı tarih.

## Tuzaklar — tekrar düşülmesin

**Dosya adı varsayımla verilmez.** `/Sayfa/Detay/754`'ü "tarihçe" sanıp öyle
kaydetmiştim; doğrulayıcı reddetti, sayfanın "Toprak Su Kaynakları" olduğu
çıktı. Kurumsal tarih ayrı bir sayfada değil, `hakkimizda`'nın içinde.
*Doğrulayıcının yakaladığı ilk şey bu oldu ve tek işi buydu.*

**CDN adresinde Türkçe harf.** 2019 raporunun dosya adında `İ` ve boşluk var;
curl ham hâlini `Malformed input to a URL function` diye **reddediyor**.
Yüzde kodlaması zorunlu: `İ` = `%C4%B0`, boşluk = `%20`. Sayfadan kopyalanan
adres olduğu gibi yapıştırılamaz.

**Yumuşak 404.** Kurum siteleri bilinmeyen adreste 200 + HTML döndürüyor
(§8.14.1, §2.12.1). `cek.sh` boyut eşiği koyuyor, `dogrula_kaynak.py` ise
sayfanın KENDİ başlığını arıyor. Durum kodu bu projede hiçbir şey kanıtlamaz.

**Doğrulayıcı üreticiden içe aktarmıyor** (§8.14.2). Normalleştirmeyi baştan
yazıyor; ortak yardımcı paylaşılsaydı ikisi de aynı yönde yanılırdı.

## Henüz ALINMAMIŞ kaynaklar

- **Sulama devir rakamları** — DSİ'nin inşa edip birliklere devrettiği tesis
  alanı. Faaliyet raporlarında olması bekleniyor, çıkarılmadı.
- **KHK-703'ün 69. maddesi** — 6200'ün 1. maddesini neyin yerine geçirdiği.
- **Sulanan arazinin toplam tarım arazisine oranı** — TÜİK ya da raporlardan.
- **İstatistik bültenleri** — `site_istatistik.html` dizin sayfası; bültenlerin
  kendisi indirilmedi.
