#!/usr/bin/env python3
"""DSİ — metni veri katmanına karşı sınar.

BAĞIMSIZ YAZILDI. `build_data.py`'den hiçbir şey içe aktarmıyor;
normalleştirmeyi de havuz kurmayı da baştan yapıyor. Gerekçe §8.14.2: ortak
yardımcı paylaşılsaydı üretici ile doğrulayıcı AYNI YÖNDE yanılırdı ve
Tarım Kredi dosyasında tam olarak bu oldu.

BEŞ AVCI:
  1. SAYI İZİ — metindeki her rakam veri katmanında bir karşılık bulmalı.
     TR ve EN kendi biçimleriyle ayrı ayrı taranıyor (§8.10/4).
  2. ALINTI İZİ — tırnak içindeki her uzun ibare, veri katmanındaki bağlı
     alıntılardan birinin içinde geçmeli. Kanun metni ezberden yazılamaz.
  3. META CÜMLE — dosyanın nasıl yapıldığı metne giremez (§8.11).
  4. REKLAM DİLİ — kurumun tanıtım dili tırnaksız kullanılamaz (§8.14.2).
  5. ÇİZİCİNİN TANIMADIĞI BİÇİM — `dossier_prose.dart` yalnızca paragraf,
     `**kalın**`, `*italik*` ve boru işaretli tablo tanıyor; sözleşmesinde
     "alt başlık yok" yazılı. Gövdeye `###` yazılırsa EKRANA OLDUĞU GİBİ
     basılır. Bir kez oldu ve canlı önizlemede kullanıcı yakaladı.
  6. EKSENİN SINIRI — "yapıyor ama işletmiyor" cümlesi kurulamaz; DSİ'nin
     kendi işlettiği alan hiçbir kaynakta yok. Hem METİN hem HİKÂYE SLAYTLARI
     taranıyor: slayt bir kez tam bu iddiayı taşıyarak yazıldı ve baloncuk
     metnin denetiminden geçmiyor.
  7. KAPSAM UYARISI — BU DOSYAYA ÖZGÜ. İki devir rakamı farklı şeyleri
     ölçüyor; 5. ve 6. bölümler kapsamını AÇIKÇA yazmak zorunda. Yazmazlarsa
     okur ikisini toplar ve bu sessiz bir hata olur.

NEYİ KANITLAMAZ (§2.2.2): metnin VERİ KATMANINDAN sapmadığını kanıtlar.
Veri katmanı yanlışsa metin ona sadık kalır ve bu denetim yeşil yanar.
Kaynak ile veri arasındaki halkayı `_raw/dogrula_kaynak.py` ve `cikar.py`'nin
`bagla()` çağrıları tutuyor.

Çalıştırma: python3 dogrula_metin.py
"""

from __future__ import annotations

import json
import pathlib
import re
import sys
import unicodedata

KOK = pathlib.Path(__file__).parent
veri = json.loads((KOK / "data.json").read_text(encoding="utf-8"))

# ── Havuz ─────────────────────────────────────────────────────────────────
sayilar: set[float] = set()
metinler: list[str] = []


def topla(o) -> None:
    if isinstance(o, dict):
        for v in o.values():
            topla(v)
    elif isinstance(o, list):
        for v in o:
            topla(v)
    elif isinstance(o, bool):
        pass
    elif isinstance(o, (int, float)):
        sayilar.add(float(o))
    elif isinstance(o, str):
        metinler.append(o)
        # Dizelerin içindeki sayılar da havuza girer: madde numaraları
        # ("Madde 3/4-c"), RG sayıları ve belge kodları ("FAC 01-09")
        # yalnızca dize alanlarda duruyor.
        for p in re.findall(r"\d+(?:[.,]\d+)?", o):
            try:
                sayilar.add(float(p.replace(",", ".")))
            except ValueError:
                pass
        # Noktalı tarihten YIL ayrıca toplanır: "02/07/2018" dizesinden
        # 2018 çıkmazsa metindeki yıl sahte bir sapma gibi görünür (§8.14.2).
        for y in re.findall(r"(?:18|19|20)\d{2}", o):
            sayilar.add(float(y))


topla(veri)

# Ölçek dönüşümleri. Havuz bilerek GENİŞ: dar tutulsaydı meşru bir cümle
# yanlış işaretlenir, yazar da denetimi gevşetirdi (§2.2.2).
genis: set[float] = set()
for v in sayilar:
    for k in (1, 1e3, 1e6, 1e9):
        genis.add(round(v / k, 6))
        genis.add(round(v * k, 6))
    genis.add(round(v * 100, 6))
    genis.add(round(v / 100, 6))
sayilar |= genis

# Bölüm numaraları, madde sıraları ve küçük tam sayılar serbest.
sayilar |= {float(n) for n in range(0, 32)}

harfli = {m.lower() for m in metinler}

hata: list[str] = []
uyari: list[str] = []


def sade(s: str) -> str:
    """Türkçe güvenli küçültme + birleştirici işaretlerin atılması.

    Python'un `lower()`'ı 'İ' için iki kod noktalı bir karakter üretiyor ve
    eşleşmeyi SESSİZCE düşürüyor (§39.5). Aşağıdaki iki satır bunun için."""
    s = s.replace("İ", "I").replace("ı", "i")
    s = s.replace("\u2019", "'").replace("\u2018", "'")
    s = unicodedata.normalize("NFD", s.lower())
    s = "".join(c for c in s if not unicodedata.combining(c))
    return re.sub(r"\s+", " ", s)


def govde(yol: pathlib.Path) -> list[tuple[str, str]]:
    """Yalnızca numaralı bölümleri döndürür.

    Yazım kuralları bloğu metnin kendisi değil; oradaki 'yok', 'denmez'
    gibi ifadeler avcıları boşa tetikler."""
    ham = yol.read_text(encoding="utf-8")
    parcalar = re.split(r"^## (\d+)\.\s*(.*)$", ham, flags=re.M)
    out = []
    for i in range(1, len(parcalar), 3):
        out.append((parcalar[i], parcalar[i + 2]))
    return out


# ── 1. Sayı izi ───────────────────────────────────────────────────────────
# TR: binlik nokta, ondalık virgül · EN: binlik virgül, ondalık nokta.
BICIM = {
    "tr": (r"\d{1,3}(?:\.\d{3})+(?:,\d+)?|\d+,\d+|\d+", ".", ","),
    "en": (r"\d{1,3}(?:,\d{3})+(?:\.\d+)?|\d+\.\d+|\d+", ",", "."),
}


def sayi_izi(dil: str, bolumler: list[tuple[str, str]]) -> None:
    desen, binlik, ondalik = BICIM[dil]
    for no, govde_metni in bolumler:
        # Tırnak içindeki kanun metni aynen alıntı; oradaki madde numarası
        # bizim cümlemiz değil. Yine de taranıyor ama KUSUR değil UYARI.
        # Tarih künyeleri ("25.12.1953", "04.04.2017", "22/3/2011") binlik
        # desenine takılıp sahte sayı üretiyordu. Tarih bir sayı dizisi
        # değil; ayrıca elenmeden taranamaz.
        temiz = re.sub(r"\b\d{1,2}[./]\d{1,2}[./]\d{2,4}\b", " ", govde_metni)
        for m in re.finditer(desen, temiz):
            ham = m.group(0)
            try:
                d = float(ham.replace(binlik, "").replace(ondalik, "."))
            except ValueError:
                continue
            if round(d, 6) in sayilar:
                continue
            # Tarih parçası mı? ("25 Aralık 1953" → 25 zaten küçük sayı)
            hata.append(f"[{dil}] §{no} · VERİDE YOK: {ham}")


# ── 2. Alıntı izi ─────────────────────────────────────────────────────────
# TR metninde tırnak içine alınan her uzun ibare veri katmanında BAĞLI bir
# alıntının içinde geçmek zorunda. Kanun metni ezberden yazılamaz.
#
# EN metninde aynı şey YAPILAMAZ ve bu bilinçli bir sınır: İngilizce
# alıntılar Türkçe kanun metninin ÇEVİRİSİ, dolayısıyla veri katmanında
# karşılıkları yok. Oradaki denetim SAYI PARİTESİ — bir bölümde İngilizce
# alıntı sayısı Türkçedekinden farklıysa ya bir alıntı uydurulmuş ya biri
# düşmüştür. USBR alıntıları zaten İngilizce olduğu için onlar eşleşiyor.
TIRNAK = re.compile(r'[\"\u201c\u201d]')
EN_KISA = 25  # bundan kısa tırnaklı ibare vurgudur, alıntı değil


def alintilar(g: str, en_az: int = EN_KISA) -> list[str]:
    """Tırnakları SIRAYLA eşleştirir: 1-2, 3-4, ...

    Uzunluk süzgecini desenin içine koymak bir hataydı ve sahte bulgu
    üretiyordu: kısa bir alıntı (\"kâr gayesi güdülemez\", 21 karakter)
    desene uymayınca onun KAPANIŞ tırnağı bir sonrakinin AÇILIŞIYLA
    eşleşiyor, aradaki düz metin alıntı sanılıyordu. Önce eşleştir, sonra
    ele."""
    yerler = [m.start() for m in TIRNAK.finditer(g)]
    ciftler = [(yerler[i], yerler[i + 1]) for i in range(0, len(yerler) - 1, 2)]
    return [g[a + 1:b] for a, b in ciftler if en_az <= b - a - 1 <= 400]


def alinti_izi_tr(bolumler: list[tuple[str, str]]) -> None:
    havuz = [sade(m) for m in metinler]
    for no, g in bolumler:
        for ham in alintilar(g):
            # Sondaki noktalama bizim cümlemizin parçası olabilir.
            ibare = sade(ham).strip(" .,;:")
            if not any(ibare in h for h in havuz):
                hata.append(f"[tr] §{no} · ALINTI VERİDE YOK: '{ham[:70]}…'")


def alinti_paritesi(tr: list[tuple[str, str]], en: list[tuple[str, str]]) -> None:
    t, e = dict(tr), dict(en)
    havuz = [sade(m) for m in metinler]
    for no in t:
        # Parite BÜTÜN tırnakları sayar (en_az=0): kısa vurgu alıntıları da
        # iki metinde aynı yerde durmalı. Uzunluk eşiği yalnızca içerik
        # aramasına ait.
        a = len(alintilar(t[no], 0))
        b = len(alintilar(e.get(no, ""), 0))
        if a != b:
            hata.append(f"[en] §{no} · ALINTI SAYISI UYUŞMUYOR · tr {a} / en {b}")
        for ham in alintilar(e.get(no, "")):
            ibare = sade(ham).strip(" .,;:")
            if any(ibare in h for h in havuz):
                continue
            # Çeviri olduğu için eşleşmiyor: kayda geçiyor, düşürmüyor.
            uyari.append(f"[en] §{no} · çeviri alıntı (tr karşılığı sayıldı): "
                          f"'{ham[:60]}…'")


# ── 3. Meta cümle (§8.11) ─────────────────────────────────────────────────
# AYRIM FİİLDE: "bu dosya ... anlatıyor" meşru ve dizide yerleşik; yasak
# olan dosyanın NASIL YAPILDIĞI.
META = {
    "tr": ["hazırlanırken", "bu dosyayı yazarken", "doğrulanamadı",
           "erişilemedi", "bulamadık", "bulunamadı", "veri katmanı",
           "kaynağa ulaşılamadı", "teyit edilemedi", "araştırma sırasında"],
    "en": ["while preparing", "could not be verified", "we could not find",
           "was not accessible", "data layer", "during our research",
           "we were unable"],
}

# ── 4. Reklam dili (§8.14.2) ──────────────────────────────────────────────
REKLAM = {
    "tr": ["en büyük", "lider", "lokomotif", "öncü rol", "dev kuruluş",
           "başarıyla", "gururla"],
    "en": ["the largest", "leading role", "flagship", "successfully",
           "proudly", "pioneering role"],
}


def kaliplar(dil: str, bolumler: list[tuple[str, str]]) -> None:
    for no, g in bolumler:
        # Tırnak içi serbest: kurumun kendi ifadesi alıntılanabilir.
        disari = sade(re.sub(r"[\"“”].*?[\"“”]", " ", g, flags=re.S))
        for k in META[dil]:
            if re.search(r"\b" + re.escape(sade(k)) + r"\b", disari):
                hata.append(f"[{dil}] §{no} · META CÜMLE: '{k}'")
        for k in REKLAM[dil]:
            if re.search(r"\b" + re.escape(sade(k)) + r"\b", disari):
                hata.append(f"[{dil}] §{no} · REKLAM DİLİ (tırnaksız): '{k}'")


# ── 5. Kapsam uyarısı — bu dosyaya özgü ───────────────────────────────────
KAPSAM = {
    # Numaralar TUR 11'de kaydı: büyük projeler bölümü 5'e girdi, devir
    # serisi 6'ya, asimetri 7'ye. Anahtarlar bölümle birlikte taşınmazsa
    # denetim yanlış bölüme bakar ve SESSİZCE geçer.
    "tr": {"6": ["yalnızca yeraltısuyu"], "7": ["bütün sulama tesislerini"]},
    "en": {"6": ["groundwater irrigation\nschemes only",
                 "groundwater irrigation schemes only"],
           "7": ["cover all\nirrigation schemes", "cover all irrigation schemes"]},
}


def kapsam_uyarisi(dil: str, bolumler: list[tuple[str, str]]) -> None:
    sozluk = dict(bolumler)
    for no, secenekler in KAPSAM[dil].items():
        g = sozluk.get(no, "")
        if not any(sade(s) in sade(g) for s in secenekler):
            hata.append(f"[{dil}] §{no} · KAPSAM UYARISI YOK — "
                        f"iki devir rakamı toplanabilir hâle geliyor")


# ── 5. Çizicinin tanımadığı biçim ────────────────────────────────────────
# Markdown'ın tamamı DEĞİL, dört yapılık bir alt kümesi destekleniyor.
# Desteklenmeyen her şey ham olarak ekrana basılır — hata vermez, sessizce
# çirkinleşir. Bölüm başlıkları (## N.) ayrı alanda duruyor; gövdedeki
# başlık işareti her zaman hatadır.
BICIM_YASAK = [
    (r"^\s*#{1,6}\s", "başlık işareti (#) — çizici alt başlık tanımıyor"),
    (r"^\s*[-*+]\s+\S", "madde imi — çizici liste tanımıyor"),
    (r"^\s*>\s*\S", "alıntı bloğu (>) — çizicide böyle bir blok tipi yok; "
                       "satır düz paragrafa karışır ve '>' ekrana basılır"),
    (r"\[[^\]]+\]\([^)]+\)", "bağlantı — çizici bağlantı tanımıyor"),
    (r"^```", "kod bloğu"),
]


def bicim_denetimi(dil: str, bolumler: list[tuple[str, str]]) -> None:
    for no, g in bolumler:
        for satir in g.split("\n"):
            for desen, mesaj in BICIM_YASAK:
                if mesaj and re.match(desen, satir):
                    hata.append(f"[{dil}] §{no} · ÇİZİCİ BU BİÇİMİ TANIMIYOR: "
                                f"{mesaj} → {satir[:60]!r}")


# ── 6. Eksenin sınırı — metin VE slaytlar ────────────────────────────────
SINIR = {
    "tr": ["isletmiyor", "işletmiyor", "kuran isletmez", "yapiyor ama"],
    "en": ["does not operate", "builds but does not"],
}


def eksen_siniri(dil: str, bolumler: list[tuple[str, str]]) -> None:
    for no, g in bolumler:
        disari = sade(re.sub(r"[\"\u201c].*?[\"\u201d]", " ", g, flags=re.S))
        for k in SINIR[dil]:
            if sade(k) in disari:
                hata.append(f"[{dil}] §{no} · EKSENİN SINIRI AŞILDI: '{k}' — "
                            "DSİ'nin kendi işlettiği alan kaynakta yok")


def slayt_siniri() -> None:
    """Hikâye baloncuğu yayin.json'da duruyor ve metin denetiminden geçmiyor;
    ayrı taranmazsa aynı iddia oradan yayına çıkar."""
    yy = json.loads((KOK / "yayin.json").read_text(encoding="utf-8"))
    for i, s in enumerate(yy.get("hikaye", {}).get("slaytlar", []), 1):
        butun = sade(" ".join(str(v) for k, v in s.items()
                              if not k.startswith("_") and k != "gorsel"))
        for dil in ("tr", "en"):
            for k in SINIR[dil]:
                if sade(k) in butun:
                    hata.append(f"[slayt {i}] EKSENİN SINIRI AŞILDI: '{k}'")
        if not s.get("gorsel", "").startswith("https://tarimportali.net/"):
            hata.append(f"[slayt {i}] GÖRSEL ADRESİ MUTLAK DEĞİL veya "
                        "kanonik alan adında değil (§1.1.1)")


# ── Koş ───────────────────────────────────────────────────────────────────
bolum: dict[str, list[tuple[str, str]]] = {}

for dil, dosya in (("tr", "metin_tr.md"), ("en", "metin_en.md")):
    yol = KOK / dosya
    if not yol.exists():
        hata.append(f"[{dil}] DOSYA YOK: {dosya}")
        continue
    b = govde(yol)
    if len(b) != 10:
        hata.append(f"[{dil}] BÖLÜM SAYISI {len(b)} — on olmalı")
    sayi_izi(dil, b)
    if dil == "tr":
        alinti_izi_tr(b)
    kaliplar(dil, b)
    bicim_denetimi(dil, b)
    eksen_siniri(dil, b)
    kapsam_uyarisi(dil, b)
    bolum[dil] = b
    kelime = sum(len(g.split()) for _, g in b)
    print(f"  {dil}: {len(b)} bölüm · {kelime} kelime · "
          f"bölüm ortalaması {kelime // max(len(b), 1)}")

slayt_siniri()

if "tr" in bolum and "en" in bolum:
    alinti_paritesi(bolum["tr"], bolum["en"])

print()
if uyari:
    for u in uyari:
        print("  ! " + u)
if hata:
    print(f"DENETİM DÜŞTÜ · {len(hata)} bulgu:\n", file=sys.stderr)
    for h in hata:
        print("  ✗ " + h, file=sys.stderr)
    sys.exit(1)
print("Temiz: metinde veri katmanına dayanmayan sayı, bağlanmamış alıntı, "
      "meta cümle veya reklam dili yok; kapsam uyarıları yerinde.")
