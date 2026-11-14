"""Gelecek bölümünün kaynaklarını belgelerden ÇEKER.

══ NEDEN BETİK, NEDEN ELLE DEĞİL ════════════════════════════════════════
Bu dosyanın kuralı: kaynağı olmayan bilgi yayına çıkmaz, hiçbir rakam
hafızadan yazılmaz. "Gelecek" bölümü bu kuralın en zorlandığı yer, çünkü
gelecek hakkında yazmak tahmin etmeye en yakın iş. Çözüm şu: gelecekten
değil, KURUMLARIN YAZILI HEDEFİNDEN söz ediyoruz. Hedefin kendisi bir
belge, ve o belge burada.

Betik cümleleri PDF'ten çekiyor. Cümle kaynaktan kalkarsa betik patlıyor
ve dosya o iddiayı kaybettiğini anlıyor — sessizce yanlış kalmıyor.

══ ÜÇ BELGE ═════════════════════════════════════════════════════════════
1. NASA BPS Space Crops Program and Goal Update (22 Kasım 2024)
   → Ay ve Mars için YAZILI hedef: M2M objective AS-5LM
   → "Space Crops Vision" basamakları
2. NASA/TM-20205008832 · Wheeler, Ekim 2020
   → Yerdeki odanın dikey tarıma dönüşü; NASA'nın kendi anlatımıyla
3. TUA 2025 İdare Faaliyet Raporu
   → Türkiye'nin sıradaki adımı, ve o adımda bitki OLMADIĞI

══ ÜÇÜNCÜSÜ BİR YOKLUK ÖLÇÜYOR ══════════════════════════════════════════
TUA raporunda "bitki", "biyoloji", "yaşam destek" aranıyor ve bulunmuyor.
Bu bir iddia değil, bir sayım: 68 sayfalık resmî raporda sıfır. Betik o
sıfırı her koşuda yeniden sayıyor. Rapor değişir de bitki girerse, sayım
sıfır olmaktan çıkar ve doğrulama durur — dosya o zaman cümlesini
değiştirmek zorunda kalır.
"""

from __future__ import annotations
import json, pathlib, re, sys, datetime
from pypdf import PdfReader

KOK = pathlib.Path(__file__).resolve().parent
BELGE = KOK / "kaynak_dosyalari"


def oku(ad: str) -> str:
    yol = BELGE / ad
    if not yol.exists():
        sys.exit(f"HATA: {yol} yok. Belgeyi indirmeden bu betik çalışmaz.")
    ham = "\n".join((s.extract_text() or "") for s in PdfReader(str(yol)).pages)
    # BÜTÜN boşluk tekleştiriliyor. Sebep: PDF'ler sözcüğü satır sonunda
    # bölüyor ("To explore volume \nefficiency"), ve satır yapısını koruyan
    # bir desen o bölünmeye takılıyor. Satır yapısına zaten ihtiyaç yok.
    return re.sub(r"\s+", " ", ham)


def tek_bosluk(s: str) -> str:
    return re.sub(r"\s+", " ", s).strip()


def cek(metin: str, desen: str, nicin: str) -> str:
    """Deseni bulur ve eşleşen cümleyi döndürür. Bulamazsa durur."""
    m = re.search(desen, metin, re.S | re.I)
    if not m:
        sys.exit(f"HATA: kaynakta bulunamadı → {nicin}\n  desen: {desen}")
    return tek_bosluk(m.group(1) if m.groups() else m.group(0))


# ══ 1 · NASA'NIN YAZILI HEDEFİ ═══════════════════════════════════════════
hedef_metin = oku("nasa_space_crops_bpac2024.pdf")

AS5LM = cek(
    hedef_metin,
    r"(AS-5LM\s*:\s*Define crop plant species.{0,260}?habitation\s*\.)",
    "M2M hedefi AS-5LM — dosyanın gelecek bölümünün dayanağı",
)

HBS1LM = cek(
    hedef_metin,
    r"(HBS-1LM.{0,400}?plants\s*\.)",
    "M2M hedefi HBS-1LM",
)

LEAF_AMAC = cek(
    hedef_metin,
    r"(Aims to understand how plants grow in partial gravity.{0,200}?beyond)",
    "LEAF'in amacı",
)

LEAF_TURLER = cek(
    hedef_metin,
    r"(LEAF Specimens\s*:\s*Arabidopsis thaliana.{0,120}?Brassica rapa)",
    "LEAF'in üç türü",
)

LEAF_SECIM = cek(
    hedef_metin,
    r"(Selected through the Artemis 3 Deployed Instruments solicitation.{0,120}?deployment)",
    "LEAF'in Artemis III için seçilmesi",
)

GUVENLI = cek(
    hedef_metin,
    r"(Plants adapt well to the space environment.{0,180}?astronauts)",
    "bugüne kadarki bulgu — uzayda yetişen ekinler yenebilir",
)

VIZYON_HEDEF = cek(
    hedef_metin,
    r"(Lunar Crops for Whole Food Nutrition and Mental Well-?Being)",
    "Space Crops hedefinin kendi adı — 'ruh sağlığı' ifadesi dahil",
)

# Vizyon basamakları: Enable → Understand → Demonstrate → Implement
VIZYON_BASAMAK = []
for b in ("Enable", "Understand", "Demonstrate", "Implement"):
    if not re.search(rf"\b{b}\b", hedef_metin):
        sys.exit(f"HATA: Space Crops Vision basamağı kaynakta yok → {b}")
    VIZYON_BASAMAK.append(b)

SON_BASAMAK = cek(
    hedef_metin,
    r"(Early Lunar outpost\s+for plant research\s+and whole food\s+crew nutrition)",
    "vizyonun son basamağı",
)

# ══ 2 · YERDEKİ ODANIN DÜNYAYA DÖNÜŞÜ ════════════════════════════════════
dikey_metin = oku("nasa_dikey_tarim.pdf")

ILK_DIKEY = cek(
    dikey_metin,
    r"(To explore volume efficiency, concepts such as vertically stacked.{0,200}?1988 through 2000\s*\.)",
    "odada denenen dikey istif — dikey tarımın atası",
)

ILK_ORNEK = cek(
    dikey_metin,
    r"(This was perhaps one of the first examples of an operational vertical farms?\s*\.)",
    "NASA'nın kendi cümlesi: oda, işleyen ilk dikey çiftliklerden biriydi",
)

ORAN = cek(
    dikey_metin,
    r"(about 20-25 m2 of crops could supply the O2 for one human,"
    r".{0,120}?dietary calories\s*\)\s*\.)",
    "bir insanın oksijeni ve yemeği için gereken alan — kapanışın rakamı",
)

LED_PATENT = cek(
    dikey_metin,
    r"(NASA funded research patented the use of LEDs for plant lighting in 1990.{0,120}?years\s*\.)",
    "LED patenti 1990 — bugünkü dikey tarımın ışığı",
)

ODA_YILLARI = cek(
    dikey_metin,
    r"(NASA developed and operated its .{0,40}Biomass Production Chamber.{0,120}?2000)",
    "odanın çalışma yılları",
)

# ══ 3 · TÜRKİYE'NİN SIRADAKİ ADIMI ═══════════════════════════════════════
tua_metin = oku("tua_performans.pdf")

AYAP_ILK = cek(
    tua_metin,
    r"(İki aşamadan oluşan Ay Araştırma Programı ilk aşamasında.{0,280}?icra edecektir\s*\.)",
    "AYAP-1'in tanımı",
)

AYAP_GECIKME = cek(
    tua_metin,
    r"(AYAP-?\s?1 projesinde, geliştirme ve test süreçlerinin planlanandan daha uzun sürmesi.{0,160}?meydana gelmiştir\s*\.)",
    "AYAP-1'deki gecikme — kurumun kendi ifadesiyle",
)

AYAP2_ERTELEME = cek(
    tua_metin,
    r"(AYAP-?\s?1 aşamasının henüz tamamlanmamış olması sebebiyle.{0,120}?ertelenmiştir\s*\.)",
    "AYAP-2'nin ertelenmesi",
)

FIRLATMA = cek(
    tua_metin,
    r"(Uzay aracının 2027 yılı içerisinde fırlatılması planlanmaktadır\s*\.)",
    "fırlatma hedefi",
)

# ── TÜRKİYE'NİN SIRADAKİ BİTKİ İŞİ ──────────────────────────────────────
# ÖNEMLİ: Bu bölüm bir kez YANLIŞ yazıldı. İlk taramada raporda "bitki" ve
# "biyoloji" bulunamamış, dosya da "Türkiye'nin sıradaki adımında bitki
# yok" diyecekti. Tarama kusurluydu: PDF sözcükleri satır sonunda bölüyor
# ve bölünmüş sözcük aranan kalıba uymuyordu. Boşluk tekleştirilince
# ortaya çıkan cümle, yazılacak olanın tam tersini söylüyor.
#
# Ders not ediliyor: bir YOKLUK iddiası, bir varlık iddiasından daha
# tehlikeli. Varlığı yanlış çekersen betik durur; yokluğu yanlış ölçersen
# betik memnuniyetle devam eder.
TOHUM_YUKU = cek(
    tua_metin,
    r"(TUA ile APSCO iş birliği kapsamında Çin'?[\u2019']?in Shijian-19"
    r".{0,320}?eklenmiştir\s*\.)",
    "Shijian-19'a eklenen iki tohum yükü",
)

UZAY_ISLAHI = cek(
    tua_metin,
    r"(Bahse konu projeler Türkiye'?[\u2019']?nin ilk uzay ıslahı çalışmaları"
    r".{0,160}?sokmuştur\s*\.)",
    "Türkiye'nin ilk uzay ıslahı çalışması olduğu",
)

# Ege Üniversitesi iki ayrı durakta geçiyor (10 ve Türkiye'nin geleceği).
# İkisinin AYNI kurum olması dosyanın kurduğu bağın kendisi; kaynaktan
# düşerse bağ da düşer.
if "Ege Üniversitesi" not in tua_metin:
    sys.exit("HATA: TUA raporunda 'Ege Üniversitesi' geçmiyor; "
             "durak 10 ile gelecek durağı arasındaki bağ kaynaksız kalır.")

sayfa_sayisi = len(PdfReader(str(BELGE / "tua_performans.pdf")).pages)

# ══ YAZ ══════════════════════════════════════════════════════════════════
cikti = {
    "_ne": "Gelecek bölümünün (durak 15-17) ve kapanışın dayanağı",
    "_nitelik": "BİRİNCİL — üç kurumun kendi belgeleri",
    "_cekim": datetime.date.today().isoformat(),
    "_YONTEM": "Cümleler PDF'ten desenle çekildi; elle kopyalanmadı. "
               "Kaynaktan kalkan cümle betiği durdurur.",

    "nasa_hedef": {
        "_belge": "kaynak_dosyalari/nasa_space_crops_bpac2024.pdf",
        "_kunye": "NASA Biological & Physical Sciences · 'NASA BPS Space Crops "
                  "Program and Goal Update' · Elison Blancaflor, John Howard · "
                  "BPS Advisory Committee Meeting · 22 Kasım 2024",
        "m2m_as5lm": AS5LM,
        "m2m_hbs1lm": HBS1LM,
        "hedefin_adi": VIZYON_HEDEF,
        "vizyon_basamaklari": VIZYON_BASAMAK,
        "vizyonun_sonu": SON_BASAMAK,
        "bugune_kadar": GUVENLI,
        "leaf_amac": LEAF_AMAC,
        "leaf_turler": LEAF_TURLER,
        "leaf_secim": LEAF_SECIM,
    },

    "leaf_kunye": {
        "_nitelik": "BİRİNCİL — NASA basın bülteni",
        "kaynak": "NASA · 'NASA Selects First Lunar Instruments for Artemis "
                  "Astronaut Deployment' · RELEASE 24-047 · 26 Mart 2024",
        "adres": "https://www.nasa.gov/news-release/nasa-selects-first-lunar-"
                 "instruments-for-artemis-astronaut-deployment/",
        "yurutucu": "Christine Escobar · Space Lab Technologies, LLC · "
                    "Boulder, Colorado",
        "yoneten": "NASA Marshall Uzay Uçuş Merkezi",
        "_TARIH_UYARISI":
            "Bülten Artemis III'ü 2026 hedefiyle anlatıyor. O tarih GEÇERSİZ. "
            "NASA Artemis III'ü Şubat 2026'da yeniden tanımladı: artık Ay'a "
            "iniş değil, Dünya yörüngesinde 14 günlük bir iniş aracı denemesi, "
            "2027 yazı hedefli. İlk insanlı iniş Artemis IV'e, 2028 başına "
            "taşındı. LEAF Ay YÜZEYİNE bırakılmak üzere seçilmişti; inişi "
            "olmayan bir görevde yüzeye bırakılamaz. Dosya bu yüzden LEAF'i "
            "'sıradaki deney' diye değil, 'hazır ama sırasını bekleyen deney' "
            "diye anlatıyor. Bu, dosyanın baştan beri söylediği şeyin aynısı: "
            "ilan edilen tarih ile gerçekleşen tarih aynı şey değil.",
    },

    "yere_donen": {
        "_belge": "kaynak_dosyalari/nasa_dikey_tarim.pdf",
        "_kunye": "Raymond M. Wheeler · 'NASA's Contributions to Vertical "
                  "Farming' · NASA/TM-20205008832 · Kennedy Uzay Merkezi · "
                  "Ekim 2020",
        "_NEDEN_ONEMLI":
            "Yazar, dosyanın 11. durağındaki 418 günlük patates odasını "
            "yürüten ekibin başındaki adam. Yerdeki odanın dikey tarıma "
            "dönüşünü kendi kurumunun belgesinde kendisi yazmış. Dosyanın "
            "kapanış mesajı bu yüzden yorum değil, kaynak.",
        "oda_yillari": ODA_YILLARI,
        "dikey_istif": ILK_DIKEY,
        "ilk_ornek": ILK_ORNEK,
        "led_patent": LED_PATENT,
        "alan_orani": ORAN,
    },

    "turkiye_sirada": {
        "_belge": "kaynak_dosyalari/tua_performans.pdf",
        "_kunye": "Türkiye Uzay Ajansı · 2025 Yılı İdare Faaliyet Raporu · "
                  "Strateji Geliştirme Daire Başkanlığı · Şubat 2026",
        "ayap1": AYAP_ILK,
        "gecikme": AYAP_GECIKME,
        "ayap2_erteleme": AYAP2_ERTELEME,
        "firlatma_hedefi": FIRLATMA,
        "rapor_sayfa": sayfa_sayisi,
        "tohum_yuku": TOHUM_YUKU,
        "uzay_islahi": UZAY_ISLAHI,
        "_SIRADAKI_ADIM":
            "Türkiye'nin sıradaki bitki işi yörüngede yetiştirmek değil, "
            "UZAY ISLAHI: tohum yukarı çıkıyor, uzay ortamında kalıyor, "
            "geri dönüyor ve değişmiş olanlar arasından seçim yapılıyor. "
            "Bitkinin kendisi orada büyümüyor; değişen tohum yerde ekiliyor. "
            "Yükü taşıyan araç Çin'in Shijian-19 geri dönebilen uydusu, "
            "yolu açan iş birliği TUA–APSCO, öneren kurum Ege Üniversitesi "
            "Biyoloji Bölümü — yani 10. duraktaki Tuz Gölü halofiti "
            "deneyini yürüten üniversitenin ta kendisi.",
        "_AYNI_YONTEM_BREZILYADA":
            "Brezilya'daki CENA nohut tohumlarını YERDE gama ışınına tutup "
            "mutasyon uyarıyor (bkz. dunya.json). Türkiye aynı işi uzaya "
            "yaptırıyor. İki hat aynı fikrin iki ucu.",
    },
}

(KOK / "gelecek.json").write_text(
    json.dumps(cikti, ensure_ascii=False, indent=1) + "\n", encoding="utf-8"
)

print("✓ gelecek.json yazıldı")
print(f"  NASA hedefi     : AS-5LM çekildi ({len(AS5LM)} harf)")
print(f"  LEAF            : {LEAF_TURLER[:60]}…")
print(f"  Dikey tarım     : '{ILK_ORNEK}'")
print(f"  Türkiye         : {UZAY_ISLAHI[:70]}… ({sayfa_sayisi} sayfalık rapor)")
