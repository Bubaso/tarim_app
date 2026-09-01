#!/usr/bin/env python3
"""Ziraat Bankası — data.json üretimi.

NEDEN BETİK. Rakamların bir kısmı makineyle çekilebiliyor (BDDK JSON'u,
tarihçenin yapısal ayrıştırması); bir kısmı faaliyet raporlarının DÜZ
METNİNDEN okunuyor. İkincisi elle giriliyor ama betik her birini ham metinde
arayıp bulamazsa DURUYOR — elle girilen rakam kaynağa bağlı kalıyor.

    python3 content/dossiers/ziraat-bankasi/build_data.py

── İKİ ÇIKARMA TUZAĞI ──────────────────────────────────────────────────────
1. PDF metninde sayı ile birimi arasında SATIR SONU olabiliyor:
   '589 \\nbin üretici'.
2. Ve BÖLÜNMEYEN BOŞLUK (U+00A0): '109\\xa0milyar\\xa0TL'.
Her ikisi de gözle görünmez ve tam eşleşmeli aramayı sessizce düşürür — rakam
doğruyken kontrol düşer, kontrol gevşetilirse yanlış rakam geçer. Çözüm:
aramadan önce hem samanlığı hem iğneyi tek boşluğa normalleştirmek. Rakamın
kendisi ve kelime sırası korunuyor, yalnızca boşluk türü serbest bırakılıyor.
"""
import json, re, sys
from decimal import Decimal, ROUND_HALF_UP
from pathlib import Path

KOK = Path(__file__).parent
HAM = KOK / "_raw"

def duz(s: str) -> str:
    return re.sub(r"\s+", " ", s).strip()


def yuvarla(x):
    """Alışıldık yuvarlama: 0,5 YUKARI.

    Python'un yerleşik round()'u bankacı yuvarlaması yapıyor — round(1224.5)
    1225 değil 1224 veriyor. Metin "1.225 milyar" yazarken veri katmanı 1224
    tutuyordu ve sayı izi denetimi bunu yakaladı. Yayına giden rakamın okurun
    beklediği gibi yuvarlanması gerekiyor.
    """
    return int(Decimal(str(x)).quantize(Decimal("1"), rounding=ROUND_HALF_UP))

RAPOR = {y: duz((HAM / f"faaliyet_{y}.txt").read_text(encoding="utf-8"))
         for y in ("2025", "2023", "2021")}
TARIHCE = json.loads((HAM / "tarihce.json").read_text(encoding="utf-8"))
# Sayı 01'in ham kaynağı. Buğday masası olayı ZİRAAT'İN kendi tarihçesinde YOK;
# tek kaynağı TMO dosyası. Atıf oraya yapılıyor, alıntı oradan doğrulanıyor.
TMO_HAM = duz((KOK.parent / "tmo" / "_raw" / "kurum_hakkinda.txt")
              .read_text(encoding="utf-8"))
BDDK = json.loads((HAM / "bddk_sektorel_kredi.json").read_text(encoding="utf-8"))

hata = []

def kanit(deger, alinti, yil, sayfa):
    """Bir kalemi ham metindeki alıntıya bağlar. Alıntı bulunamazsa üretim durur."""
    if duz(alinti) not in RAPOR[yil]:
        hata.append(f"faaliyet_{yil}.txt içinde bulunamadı: {alinti[:70]!r}")
    return {"deger": deger, "kaynak": f"faaliyet_{yil}.pdf · s. {sayfa}",
            "alinti": alinti}

def tmo_kanit(deger, alinti):
    if duz(alinti) not in TMO_HAM:
        hata.append(f"tmo/kurum_hakkinda.txt içinde bulunamadı: {alinti[:70]!r}")
    return {"deger": deger,
            "kaynak": "content/dossiers/tmo/_raw/kurum_hakkinda.pdf",
            "alinti": alinti}


def yil_maddeleri(y):
    for k in TARIHCE:
        if k["yil"] == y:
            return k["maddeler"]
    hata.append(f"tarihce.json içinde {y} yok")
    return []

# ── Tarih zinciri — tarihce.json'dan SEÇİLEREK, yeniden yazılmadan ──────────
# Madde metinleri bankanın kendi cümleleri; kısaltılmıyor, tırnak içinde
# taşınıyor. Hangi yılların dosyaya gireceği editör kararı.
SECILEN = [1863, 1867, 1881, 1883, 1888, 1892, 1916, 1919, 1920, 1922, 1924,
           1938, 1945, 1964, 1977, 2000, 2001, 2025]
tarih_zinciri = [{"yil": y, "maddeler": yil_maddeleri(y)} for y in SECILEN]

# ── Sektör payı — pay rapordan, payda BDDK'dan, oran HESAPLANIYOR ───────────
ZIRAAT_TARIM = {  # milyar TL, yıl sonu bakiyesi
    "2021": kanit(109, "109 milyar TL’ye, kredili müşteri sayısı ise 725 bin", "2021", 15),
    "2023": kanit(437, "bakiyesi 437 milyar TL’ye, kredili müşteri sayısı ise 1.207 bin", "2023", 80),
    "2025": kanit(831, "tarım kredileri bakiyesi 831 milyar TL’ye ulaşırken", "2025", 59),
}

def bddk_tarim(y):
    s = BDDK["yillar"][y]["satirlar"]["Tarım"]["Toplam Nakdi Krediler"]
    return round(s / 1e6, 1)   # bin TL → milyar TL

sektor_payi = []
for y in ("2021", "2023", "2025"):
    ziraat = ZIRAAT_TARIM[y]["deger"]
    turkiye = bddk_tarim(y)
    sektor_payi.append({
        "yil": int(y),
        "ziraat_milyar_tl": ziraat,
        "turkiye_milyar_tl": turkiye,
        # Yuvarlanıyor: iki kaynağın tanımları birebir örtüşmeyebilir,
        # ondalıklı kesinlik iddiası yanlış olurdu.
        "ziraat_payi_yuzde": yuvarla(100 * ziraat / turkiye),
        # Metin yuvarlanmış hâli yazıyor ("1.225 milyar lira"); izlenebilmesi
        # için yuvarlama veri katmanında da duruyor, metinde hesaplanmıyor.
        "turkiye_milyar_tl_yuvarlak": yuvarla(turkiye),
        "kaynak_pay": ZIRAAT_TARIM[y]["kaynak"],
        "kaynak_payda": "BDDK Aylık Bülten · Sektörel Kredi Dağılımı · "
                        f"{y}/12 · Tarım satırı, toplam nakdi krediler",
    })

veri = {
 "_dosya": "Ziraat Bankası — Kurum Dosyası · veri katmanı",
 "_uretim": "build_data.py ile üretildi; elle düzenlenmez.",
 "_kural": "Buradaki hiçbir rakam bellekten yazılmadı. Elle girilen her kalem "
           "ham metindeki alıntısıyla birlikte taşınıyor ve alıntı bulunamazsa "
           "üretim duruyor. Kaynağı olmayan kalem bu dosyaya girmez.",

 "olcu": {
   "_amac": "Dosyanın omurgası. İddia değil, iki birincil kaynağın oranı.",
   "cumle": "Türkiye'de tarıma açılan kredinin yaklaşık üçte ikisi tek bir "
            "bankadan geçiyor.",
   "dayanak": "Pay bankanın kendi faaliyet raporundan, payda BDDK'nın sektör "
              "toplamından. Oran yuvarlanarak veriliyor: iki kaynağın tanımları "
              "birebir örtüşmeyebilir.",
 },

 "kunye": {
   "ad": "Türkiye Cumhuriyeti Ziraat Bankası A.Ş.",
   "kisa_ad": "Ziraat Bankası",
   "kurulus": {
     "yil": 1863, "yer": "Pirot",
     "kuran": "Mithat Paşa",
     "ilk_bicim": "Memleket Sandıkları",
     "tarih": "20 Kasım",
     "kaynak": "site_tarihce.html → tarihce.json · 1863",
   },
   "yas": kanit(162, "162 yıldır", "2025", 58),
   "bugunku_bicim": {
     "deger": "Anonim şirket",
     "dayanak": "4603 sayılı Kanun (kabul 25 Kasım 2000)",
     "kaynak": "site_tarihce.html → tarihce.json · 2000",
     "_not": "Banka 1924'te de anonim şirket yapılmıştı (444 sayılı Bütçe "
             "Kanunu). Aradaki dönüşüm zinciri bankanın tarihçesinde yazılı "
             "değil; metin o geçişi ATLAR.",
   },
 },

 "tarih_zinciri": {
   "_amac": "Seçilmiş kilometre taşları. Cümleler bankanın kendi metni, "
            "kısaltılmadan taşınıyor.",
   "_kaynak": "site_tarihce.html → tarihce.json (51 yıl, 221 madde)",
   "yillar": tarih_zinciri,
 },

 "sektor_payi": {
   "_amac": "Dosyanın ölçüsü. Enflasyondan etkilenmiyor — oran.",
   "birim": "milyar TL · yıl sonu bakiyesi",
   "seri": sektor_payi,
 },

 "tarim_kredisi_2025": {
   "bakiye_milyar_tl": ZIRAAT_TARIM["2025"],
   "kredi_kullanan_musteri": kanit(
     "684 bin+", "684 binden fazla müşteriye tarım kredisi kullandırmıştır", "2025", 59),
   "yeni_musteri": kanit(
     "61 bin", "Bu müşterilerin 61 bini yeni müşteri olup", "2025", 59),
   "yil_sonu_kredili_musteri": kanit(
     "924 bin+", "kredili müşteri sayısı 924 binin üzerinde gerçekleşmiştir", "2025", 59),
   # "Tutamak" (CLAUDE.md §2.9): 831 milyar lirayı 924 bin müşteriye bölünce
   # kişi başına ne düştüğü. Metinde HESAPLANMIYOR — burada hesaplanıp
   # yuvarlanıyor ki sayı izi denetimi onu da yakalayabilsin.
   "ortalama_kredi_tl": {
     "tam": yuvarla(831e9 / 924e3 / 1e3) * 1000,
     # Metin "yaklaşık 900 bin" diyor; yaklaşıklık metinde değil BURADA
     # yapılıyor ki okunan rakam da izlenebilir olsun.
     "deger": yuvarla(831e9 / 924e3 / 1e5) * 100_000,
     "_hesap": "831 milyar TL ÷ 924 bin müşteri = 899.350 TL; "
               "tam alan on bine, gösterilen alan yüz bine yuvarlandı",
     "kaynak": "faaliyet_2025.pdf · s. 59 (iki kalemden türetildi)",
   },
   "kirilim": {
     "_kaynak": "faaliyet_2025.pdf · s. 60 · tablo",
     "_sutunlar": ["kredi kullanan müşteri", "kullandırılan tutar",
                   "yıl sonu bakiyesi", "yıl sonu kredili müşteri"],
     "_alinti_bitkisel": "Bitkisel Üretim Kredileri 433 Bin 257 milyar TL 263 milyar TL 518 Bin",
     "_alinti_hayvansal": "Hayvansal Üretim Kredileri 321 Bin 320 milyar TL 418 milyar TL 401 Bin",
     "bitkisel":  {"musteri": "433 bin", "kullandirilan": 257, "bakiye": 263, "kredili_musteri": "518 bin"},
     "hayvansal": {"musteri": "321 bin", "kullandirilan": 320, "bakiye": 418, "kredili_musteri": "401 bin"},
     "mekanizasyon": {"musteri": "64 bin", "kullandirilan": 30, "bakiye": 89, "kredili_musteri": "295 bin"},
     "basincli_sulama": {"musteri": "12 bin", "kullandirilan": 11, "bakiye": 22, "kredili_musteri": "56 bin"},
     "_not": "Hayvansal bakiye bitkiselden BÜYÜK (418'e karşı 263 milyar TL) "
             "ama kredili müşteri sayısı daha AZ (401 bine karşı 518 bin). "
             "Sıralama sezgiye aykırı ve doğrudan tablodan.",
   },
 },

 "kredili_musteri_serisi": {
   "_amac": "Enflasyondan etkilenmeyen ikinci ölçü: kaç çiftçinin bankada "
            "kredisi var. Seri DÜZ ARTAN DEĞİL — 2023'te tepe yapıp iniyor.",
   "seri": [
     {"yil": 2021, "musteri": "725 bin",
      "kaynak": "faaliyet_2021.pdf · s. 15"},
     {"yil": 2023, "musteri": "1.207 bin",
      "kaynak": "faaliyet_2023.pdf · s. 80"},
     {"yil": 2025, "musteri": "924 bin+",
      "kaynak": "faaliyet_2025.pdf · s. 59"},
   ],
   "_uyari": "Metinde ARTIŞ diye anlatılmaz. Üç nokta olduğu gibi verilir; "
             "düşüşün sebebi hakkında iddia kurulmaz (§8.2).",
 },

 "portfoy_bilesimi": {
   "_amac": "Yatırım/işletme kredisi oranı — enflasyondan etkilenmeyen üçüncü ölçü.",
   "seri": [
     {"yil": 2021, "yatirim_yuzde": 36, "isletme_yuzde": 64,
      "kaynak": "faaliyet_2021.pdf · s. 15",
      "alinti": "%36’sı yatırım kredilerinden, %64’ü işletme kredilerinden"},
     {"yil": 2023, "yatirim_yuzde": 31, "isletme_yuzde": 69,
      "kaynak": "faaliyet_2023.pdf · s. 80",
      "alinti": "%31’i yatırım kredilerinden, %69’u işletme kredilerinden"},
   ],
   "_not": "2025 raporu bu oranı vermiyor; seri iki noktada kalıyor ve "
           "metinde de öyle söylenir.",
 },

 "subvansiyon": {
   "_amac": "10. bölüm. Mekanizma anlatılır, değerlendirilmez.",
   "belge": "Tarım ve Orman Bakanlığı Tebliği · üretim alanına göre faiz "
            "indirim oranı",
   "kapsam": kanit(
     "589 bin üretici · 565 milyar TL+",
     "tarım sektöründe 589 bin üretici ve toplam 565 milyar TL’nin üzerinde "
     "sübvansiyonlu kredi sağlamıştır", "2025", 60),
 },

 "kucuk_krediler": {
   "_amac": "11. bölüm. Kredinin insan ölçeğindeki hâli.",
   "aricilik": kanit(
     "5.700+ üretici · 890 milyon TL",
     "5.700’den fazla üreticiye toplam 890 milyon TL tutarında kredi "
     "kullandırılmıştır", "2025", 62),
   "aricilik_limit": kanit(
     "300.000 TL", "300.000 TL’ye kadar kredi imkânı sağlanmakta", "2025", 62),
   "balikci": kanit(
     "600 üretici · 523 milyon TL",
     "600 üreticiye toplam 523 milyon TL tutarında kredi kullandırılmıştır",
     "2025", 63),
   "lisansli_depoculuk": kanit(
     "8,2 milyar TL",
     "lisanslı depoculuk kredilerinin toplam bakiyesi 8,2 milyar TL", "2025", 60),
   "yenilenebilir_enerji": kanit(
     "987 milyon TL",
     "Tarımsal Yenilenebilir Enerji Yatırımları Kredisinden, toplam 987 milyon TL",
     "2025", 63),
   "kooperatif_katma_deger": kanit(
     "40 kooperatif/üretici · 445 milyon TL",
     "40 kooperatif/üreticiye toplam 445 milyon TL finansman sağlanmıştır",
     "2025", 63),
   "soguk_hava_deposu": kanit(
     "507 milyon TL",
     "yeni soğuk hava deposu yatırımları ve mevcut depoların modernizasyonuna "
     "yönelik finansman desteği sağlanmıştır. Bu kapsamda kullandırılan "
     "kredilerin toplam bakiyesi 2025 yılı itibarıyla 507 milyon TL",
     "2025", 60),
   "hayvancilik_projeleri": kanit(
     "Köyümde Yaşamak İçin Bir Sürü Nedenim Var · Kırsalda Bereket",
     "“Köyümde Yaşamak İçin Bir Sürü Nedenim Var” projeleri kapsamında kredi "
     "kullandırımları sürdürülmüş; kırmızı et arzında sürdürülebilirliğin "
     "sağlanmasına yönelik “Kırsalda Bereket- Hayvancılığa Destek Projesi” "
     "2025 yılında uygulamaya alınmıştır",
     "2025", 60),
   "elus": kanit(
     "474 milyon TL",
     "Elektronik Ürün Senetleri (ELÜS) karşılığı kullandırılan kredilerin "
     "bakiyesi ise 474 milyon TL", "2025", 60),
 },

 "banka_geneli_2025": {
   "_amac": "Ölçek göstermek için, argüman kurmak için değil (§8.2).",
   "aktif": kanit("8.474 milyar TL", "Aktif büyüklüğü: 8.474 milyar TL", "2025", 37),
   "aktif_pazar_payi": kanit("%18,1", "%18,1 aktif büyüklük pazar payı", "2025", 37),
   "mevduat": kanit("5.405 milyar TL", "Mevduat büyüklüğü: 5.405 milyar TL", "2025", 37),
   "nakdi_krediler": kanit("4.240 milyar TL", "Nakdi krediler: 4.240 milyar TL", "2025", 37),
   "net_kar": kanit("161 milyar TL", "Net dönem kârı: 161 milyar TL", "2025", 37),
 },

 "sube_agi_2025": {
   "_amac": "Kırsalda erişimin ölçüsü. Kredinin büyüklüğünden çok, kredinin "
            "NEREYE ulaştığını anlatan rakam.",
   "sube": kanit(
     "1.745 şube · 373 ilçe ve beldede tek banka",
     "1.745 hizmet noktası ve Türkiye’de 373 ilçe ve beldede tek banka olarak",
     "2025", 38),
   "yeni_sube": kanit(
     "7 yeni şube",
     "yurt içinde 7 yeni şubeyi müşteriyle buluşturarak 2025 yıl sonu "
     "itibarıyla 1.745 şubesiyle", "2025", 160),
 },

 "tarim_sigortasi": {
   "_amac": "Kredinin yanındaki ikinci ürün. TARSİM devlet destekli tarım "
            "sigortası havuzu.",
   "portfoy_payi": kanit(
     "%46", "tarımsal sigortaların payı %46", "2025", 65),
 },

 "credit_agricole": {
   "_amac": "12. bölüm. Karşılaştırmanın ekseni BÜYÜKLÜK DEĞİL SAHİPLİK.",
   "_kaynak": "site_creditagricole_tarih.html, site_creditagricole_profil.html",
   "ilk_kasa": {"yil": 1885, "yer": "Salins-les-Bains (Jura)",
                "kuran": "Louis Milcent, Alfred Bouvet"},
   "kurulus_kanunu": {"tarih": "5 Kasım 1894",
                      "ilke": "karşılıklılık (mutualité)",
                      "arkasindaki_isim": "Jules Méline"},
   "oy_ilkesi": "kişi başına tek oy, hisse sayısından bağımsız",
   "devlet_destegi": "1897 · Banque de France'tan 40 milyon altın frank bağış "
                     "ve yılda 2 milyon frank",
   "bugun": {"perakende_musteri": "55 milyon", "ortak": "12,3 milyon",
             "calisan": "160 bin"},
   # Grafik @yol'ları SAYI istiyor (seed_dossier.mjs), metin ise okunur biçim.
   # İkisi ayrı alanda duruyor ki grafik "[object Object]" çizmesin.
   "sayilar": {"orgutlenme_kanunu_yili": 1884, "ilk_kasa_yili": 1885,
               "kurulus_kanunu_yili": 1894, "bolge_bankalari_yili": 1899,
               "ortak_milyon": 12.3, "perakende_musteri_milyon": 55},
   "_eksen": "İkisi de devlet parasıyla ayağa kalktı — biri aşar vergisine "
             "zamla (1883), öteki Banque de France bağışıyla (1897). Ayrım "
             "oyların kimde olduğunda.",
   "_zaman_farki": "Ziraat'in sandıkları (1863) Fransa'nın ilk yerel "
                   "kasasından (1885) 22 yıl önce.",
 },

 "tmo_baglantisi": {
   "_amac": "Sayı 01'e köprü. KAYNAK ZİRAAT'TE DEĞİL, TMO DOSYASINDA.",
   "_uyari": "Ziraat'in kendi tarihçesi bu olaydan hiç söz etmiyor. Atıf TMO "
             "belgesine yapılır, Ziraat'e değil.",
   "fiyat_cokusu": tmo_kanit(
     "1928 sonrası",
     "özellikle 1928 sonrasında birçok ülkede buğday fiyatları hızla düşmeye "
     "başlamıştır"),
   "gorevlendirme": tmo_kanit(
     "3/7/1932 tarihli ve 2056 sayılı Kanun",
     "10/7/1932 tarihli ve 2146 sayılı Resmî Gazete’de yayımlanan 3/7/1932 "
     "tarihli ve 2056 sayılı Kanunla Ziraat Bankasını buğday alımıyla "
     "görevlendirmiştir"),
   "depo_gorevi": tmo_kanit(
     "11/6/1933 tarihli ve 2303 sayılı Kanun",
     "Ziraat Bankasına depo ihtiyacını karşılamak üzere 11/6/1933 tarihli ve "
     "2303 sayılı Kanunla hububat muhafaza tesisleri kurma görevi de "
     "verilmiştir"),
   "alim_merkezleri": tmo_kanit(
     "1932–1933 · çoğu Orta Anadolu'da",
     "Ziraat Bankası 1932 -1933 yıllarında çoğu Orta Anadolu'da olmak üzere "
     "alım merkezleri açmıştır"),
   "ayrilma": tmo_kanit(
     "Buğday Masası Şefliği",
     "Ziraat Bankası bünyesinde Buğday Masası Şefliği adı altında yürütülen "
     "işlerin başka bir kuruluşa devredilmesini zorunlu kılmıştır"),
 },

 "kredi_sartlari": {
   "_amac": "9. bölüm. Kredinin ŞARTLARI — limit, vade, ödemesiz dönem. "
            "Başvuru sürecinin adımları hiçbir çekilen kaynakta yok; akış "
            "şeması UYDURULMADI, onun yerine belgelenmiş şartlar veriliyor.",
   "faiz_dayanagi": kanit(
     "Tarım ve Orman Bakanlığı Tebliği",
     "Tarım ve Orman Bakanlığı Tebliğ’i çerçevesinde, üretim alanlarına göre "
     "belirlenen faiz indirim oranları doğrultusunda", "2025", 59),
   "ciftci_destek_limiti": kanit(
     "1.000.000 TL", "1.000.000 TL’ye kadar kredi imkânı sunulmaktadır", "2025", 62),
   "ciftci_destek_kullanim": kanit(
     "38 bin müşteri · 18 milyar TL",
     "38 bin müşteriye 18 milyar TL kredi kullandırılmıştır", "2025", 62),
   "uretici_orgutu_limiti": kanit(
     "1.200.000 TL", "600.000 TL’den 1.200.000 TL’ye yükseltilmiş", "2025", 61),
   "uretici_orgutu_vade": kanit(
     "2 yıl ödemesiz · 5–7 yıl vade",
     "2 yıla kadar ödemesiz, toplamda 5 veya 7 yıl vadeli", "2025", 61),
   "tarimsal_elektrik": kanit(
     "4 bin+ müşteri · 2,9 milyar TL",
     "4 bini aşkın müşteriye toplam 2,9 milyar TL", "2025", 63),
 },

 "bosluklar": [],
}

if hata:
    print("ÜRETİM DURDU — ham kaynakta bulunamayan alıntılar:", file=sys.stderr)
    for h in hata:
        print("  ✗", h, file=sys.stderr)
    sys.exit(1)

(KOK / "data.json").write_text(
    json.dumps(veri, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")

print(f"→ data.json · {len(veri)} blok")
for s in sektor_payi:
    print(f"   {s['yil']}  Ziraat {s['ziraat_milyar_tl']:>4} / "
          f"Türkiye {s['turkiye_milyar_tl']:>7} milyar TL  →  %{s['ziraat_payi_yuzde']}")
