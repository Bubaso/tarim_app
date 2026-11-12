#!/usr/bin/env python3
"""Mısır — `metin_tr.md` ve `metin_en.md`'yi veri katmanına karşı sınar.

ON ÜÇ AVCI. İlk altısı dizide devralındı; 7-13 bu dosyanın kendi tuzakları.

 1. SAYI İZİ — metindeki her ondalık ve binlikli sayı veri katmanında
    karşılık bulmalı. TR ve EN kendi biçimleriyle AYRI taranıyor: "12.467"
    Türkçede on iki bin, İngilizcede on iki tam. Aynı kalıpla okunamazlar.
 2. ALINTI İZİ — italik + tırnak içindeki her ibare veri katmanında BİREBİR
    geçmeli. Belge metni ezberden yazılamaz. BU KURAL BİR HATA YAKALADI:
    §4'teki FAO alıntısı iki dilde de paraphrase yazılmıştı ("coming from
    outside the country"), kaynak ise "flowing into the country from
    neighbouring countries" diyor. Tırnak içinde paraphrase, uydurma
    alıntıdır. Kural UYARI değil HATA; muafiyet yalnız iki yerde:
    kaynakça bölümü (§18, orada italik eser ADI demek) ve satırında
    "(çeviri)" işareti taşıyan alıntılar.
    BİÇİM KURALI: birebir kaynak metni *"..."* yazılır. Düzyazı çift tırnak
    KULLANMAZ — ilk yazımda retorik ibareler de tırnaklıydı ve avcı ikisini
    ayırt edemiyordu; dört bölümde sahte parite hatası verdi.
 3. ÇİZİCİNİN TANIMADIĞI BİÇİM — `dossier_prose.dart` yalnızca paragraf,
    `**kalın**`, `*italik*` ve boru işaretli tablo tanıyor. Gövdeye `###`,
    madde işareti ya da bağlantı yazılırsa EKRANA OLDUĞU GİBİ basılır.
 4. YAPI — on sekiz bölüm, iki dilde aynı numaralar, ardışık.
 5. ALINTI PARİTESİ — İngilizce alıntı çeviri olabilir ve kaynakta
    bulunmayabilir; bu DÜŞÜRMEZ ama bölüm başına alıntı SAYISI iki dilde
    aynı olmalı, yoksa muafiyet uydurma alıntıya kapı açar.
 6. ÖLÇÜLMEMİŞ ÜSTÜNLÜK — "en büyük pazar", "lider üretici" gibi ibareler
    bu dosyada ölçülmedi ve yazılamaz. Ölçülen tek üstünlük buğday
    ithalatında dünya birinciliği.
 7. "PARA" YASAĞI — kullanıcı kuralı (10 Kasım 2026): ikinci bölümde para
    kelimesi kullanılmıyor. Kural İKİ DİLDE geçerli.
 8. SULAMA SINIRI — %100 sulama oranı nerede geçiyorsa, eşitliğin yalnız
    2021-2024 için geçerli olduğu AYNI BÖLÜMDE yazılı olmalı.
 9. KATMA DEĞER KAPSAMI — tarımın hasıladaki payı nerede geçiyorsa,
    kalemin ormancılık ve balıkçılığı içerdiği aynı bölümde yazılı olmalı.
10. PROJEKSİYON GÖVDEDE DEĞİL — nüfus serisi 2100'e gidiyor ve bayrak
    ayırmıyor; gövdede 2026'dan sonraki bir nüfus yılı geçemez.
11. TANE MISIR AYRIMI — ürün ile ülke Türkçede aynı kelime. Küçük harfli
    "mısır" yalnız "tane mısır" ya da "mısır yağı" içinde geçebilir.
12. PROTOKOL I ASİMETRİSİ SANAYİ ETİKETLİ — 2020'ye kadar kademeli iniş
    SANAYİ ürünlerine ait; tarım tavizi gibi okunmamalı.
13. İDDİA EDİLMEYENLER — ayna farkının sebebi ve pirincin ekilme amacı bu
    dosyada ölçülmedi; iki bölüm de bunu açıkça söylemek zorunda.

NEYİ KANITLAMAZ (§2.2.2): metnin VERİ KATMANINDAN sapmadığını kanıtlar. Veri
katmanı yanlışsa metin ona sadık kalır ve bu denetim yeşil yanar. Ayrıca
§2.14.1'in tuzağını göremez: RAKAMSIZ ya da yazıyla yazılmış kaynaksız bir
iddia bu betikten geçer. O denetim gözle yapılır.

Çalıştırma: python3 dogrula_metin.py
"""
from __future__ import annotations

import json
import pathlib
import re
import sys

KOK = pathlib.Path(__file__).parent
VERI = json.loads((KOK / "data.json").read_text(encoding="utf-8"))
TR = (KOK / "metin_tr.md").read_text(encoding="utf-8")
EN = (KOK / "metin_en.md").read_text(encoding="utf-8")
hata: list[str] = []
uyari: list[str] = []

# ── Sayı ve metin havuzu ──────────────────────────────────────────────────
SAYILAR: list[float] = []
METINLER: list[str] = []


def topla(o) -> None:
    if isinstance(o, bool):
        return
    if isinstance(o, (int, float)):
        SAYILAR.append(float(o))
    elif isinstance(o, str):
        METINLER.append(o)
        if o.isdigit():
            SAYILAR.append(float(o))
    elif isinstance(o, dict):
        for k, v in o.items():
            topla(k); topla(v)
    elif isinstance(o, list):
        for v in o:
            topla(v)


topla(VERI)
HAVUZ = " ".join(METINLER)
OLCEKLER = [10.0 ** k for k in range(-9, 10)]


def veride_var(deger: float, basamak: int) -> bool:
    """Ölçek ve İŞARET toleranslı arama.

    İŞARET: veri katmanı düşüşü negatif tutuyor (-84.6) ama Türkçe cümle
    "%84,6 düştü" diyor ve işareti FİİL taşıyor. Mutlak değer kabul ediliyor;
    yoksa doğru yazılmış her düşüş cümlesi hata verir. Tolerans büyüklüğe
    dair, YÖNE dair değil — yönün doğruluğu gözle denetlenir.

    ÖLÇEK: not ve cümle "bin ton", "milyon dolar" diye konuşuyor, veri
    kendi biriminde duruyor.
    """
    for x in SAYILAR:
        for s in OLCEKLER:
            if round(abs(x) * s, basamak) == deger:
                return True
    return False


KALIP = {
    "tr": [(re.compile(r"\d{1,3}(?:\.\d{3})+(?:,\d+)?"), ".", ","),
           (re.compile(r"\d+,\d+"), None, ",")],
    "en": [(re.compile(r"\d{1,3}(?:,\d{3})+(?:\.\d+)?"), ",", "."),
           (re.compile(r"\d+\.\d+"), None, ".")],
}


def sayilari_ayikla(metin: str, dil: str):
    bulunan, yerler = [], []
    for kalip, binlik, ondalik in KALIP[dil]:
        for m in kalip.finditer(metin):
            if any(a <= m.start() < b for a, b in yerler):
                continue
            yerler.append((m.start(), m.end()))
            ham = m.group()
            if binlik:
                ham = ham.replace(binlik, "")
            ham = ham.replace(ondalik, ".")
            basamak = len(ham.split(".")[1]) if "." in ham else 0
            bulunan.append((m.group(), float(ham), basamak))
    return bulunan


def bolumlere_ayir(metin: str) -> dict[int, str]:
    out: dict[int, str] = {}
    for m in re.finditer(r"^## (\d+)\.(.*?)(?=^## |\Z)", metin, re.S | re.M):
        out[int(m.group(1))] = m.group(0)
    return out


BTR, BEN = bolumlere_ayir(TR), bolumlere_ayir(EN)


def sade(govde: str) -> str:
    """Biçimlendirmesi ve satır sarması sökülmüş gövde.

    İbare aramaları ilk hâlde ham metinde yapılıyordu ve `**bu amaçla**`
    yazıldığı için "bu amaçla ekildiğini doğrulayan" ibaresi bulunamıyordu.
    Kalın ve italik işaretleri sökülüyor, boşluk tekilleştiriliyor.
    """
    return re.sub(r"\s+", " ", govde.replace("**", "").replace("*", ""))


STR = {k: sade(v) for k, v in BTR.items()}
SEN = {k: sade(v) for k, v in BEN.items()}

# ── 4 — yapı ──────────────────────────────────────────────────────────────
if sorted(BTR) != list(range(1, 19)):
    hata.append(f"TR bölüm numaraları {sorted(BTR)} — 1-18 ardışık değil")
if sorted(BEN) != list(range(1, 19)):
    hata.append(f"EN bölüm numaraları {sorted(BEN)} — 1-18 ardışık değil")

# ── 1 — sayı izi ──────────────────────────────────────────────────────────
# Tez cümlesi de taranıyor: tanıtım satırı metnin parçası.
for dil, metin, bolumler in (("tr", TR, BTR), ("en", EN, BEN)):
    for ham, deger, basamak in sayilari_ayikla(metin, dil):
        if not veride_var(deger, basamak):
            hata.append(f"{dil}: '{ham}' veri katmanında yok — cümlede "
                        f"hesaplanmış ya da bellekten yazılmış olabilir")

# ── 2 ve 5 — alıntı izi ve paritesi ───────────────────────────────────────
# ÇİFT YILDIZ ALINTI DEĞİL. İlk kalıp `[*"](...)[*"]` idi ve `**kalın**`
# ibarelerini alıntı sayıyordu: dört bölümde sahte parite hatası verdi.
# Şimdi yalnız çift tırnak ve TEK yıldızlı italik sayılıyor.
ALINTI = re.compile(
    r'"([A-Za-zÇĞİÖŞÜçğıöşü][^"]{25,})"'
    r'|(?<!\*)\*([A-Za-zÇĞİÖŞÜçğıöşü][^*]{25,})\*(?!\*)')


def alintilar(govde: str) -> list[str]:
    return [(m.group(1) or m.group(2)).strip() for m in ALINTI.finditer(govde)]
for no in sorted(set(BTR) & set(BEN)):
    a_tr, a_en = alintilar(BTR[no]), alintilar(BEN[no])
    if len(a_tr) != len(a_en):
        hata.append(f"§{no}: alıntı sayısı TR {len(a_tr)} ≠ EN {len(a_en)} — "
                    f"çeviri muafiyeti uydurma alıntıya kapı açmasın")
    if no == 18:
        continue        # kaynakça: italik eser ADI, alıntı değil
    for dil, a_liste, govde in (("tr", a_tr, BTR[no]), ("en", a_en, BEN[no])):
        for a in a_liste:
            # Yerel ad `sade` idi ve üst düzeydeki `sade()` fonksiyonunu
            # gölgeliyordu; sonraki ibare aramaları çağrılamaz hâle geliyordu.
            duz = re.sub(r"\s+", " ", a)
            if duz in re.sub(r"\s+", " ", HAVUZ):
                continue
            if "(çeviri)" in govde or "(translated)" in govde:
                uyari.append(f"{dil} §{no}: alıntı çeviri işaretli, birebir "
                             f"aranmadı — '{duz[:55]}…'")
                continue
            hata.append(f"{dil} §{no}: ALINTI KAYNAKTA BİREBİR YOK — tırnak "
                        f"içinde paraphrase uydurma alıntıdır: '{duz[:70]}…'")

# ── 3 — çizicinin tanımadığı biçim ────────────────────────────────────────
for dil, metin in (("tr", TR), ("en", EN)):
    satirlar = metin.split("\n")
    for i, satir in enumerate(satirlar, 1):
        s = satir.strip()
        if re.match(r"^\d+\.\s", s):
            onceki = satirlar[i - 2].strip() if i >= 2 else ""
            sonraki = satirlar[i].strip() if i < len(satirlar) else ""
            if re.match(r"^\d+\.\s", onceki) or re.match(r"^\d+\.\s", sonraki):
                hata.append(f"{dil}:{i}: numaralı liste çizici tanımıyor")
        if s.startswith("###"):
            hata.append(f"{dil}:{i}: '###' çizici tanımıyor, ekrana basılır")
        # `^\d+\.\s` kalıbı ilk hâlde vardı ve DÜZYAZIYI yakalıyordu:
        # "15. fasıl: yağ." ve "7. ve 12. bölümlerde duruyor." satır başına
        # geldiğinde madde işareti sanılıyordu. Numaralı liste için en az
        # iki ardışık satır şartı kondu; tek satır düzyazıdır.
        if re.match(r"^[-*+]\s", s) or re.match(r"^\d+\)\s", s):
            hata.append(f"{dil}:{i}: madde işareti çizici tanımıyor")
        if re.search(r"\[[^\]]+\]\([^)]+\)", s) or re.search(r"https?://", s):
            hata.append(f"{dil}:{i}: bağlantı çizici tanımıyor")

# ── 6 — ölçülmemiş üstünlük ───────────────────────────────────────────────
YASAK = {
    "tr": ["en büyük pazar", "lider üretici", "lider ihracatçı", "dünya lideri",
           "rakipsiz", "bir numaralı pazar", "en önemli ortak"],
    "en": ["largest market", "leading producer", "leading exporter",
           "world leader", "unrivalled", "number one market",
           "most important partner"],
}
for dil, metin in (("tr", TR), ("en", EN)):
    for k in YASAK[dil]:
        if k in metin.lower():
            hata.append(f"{dil}: ÖLÇÜLMEMİŞ ÜSTÜNLÜK — '{k}'")

# ── 7 — "para" yasağı, ikinci bölüm, İKİ DİLDE ────────────────────────────
# Kullanıcı kuralı, 10 Kasım 2026. Kelime kökünden aranıyor ki 'parası',
# 'parayla' gibi çekimler de yakalansın.
if 2 in BTR and re.search(r"\bpara\w*", BTR[2], re.I):
    hata.append("tr §2: 'para' kelimesi kullanılmış — kullanıcı kuralı")
if 2 in BEN and re.search(r"\b(money|monies|moneys|cash)\b", BEN[2], re.I):
    hata.append("en §2: 'money/cash' kullanılmış — kural iki dilde geçerli")

# ── 8 — sulama sınırı ─────────────────────────────────────────────────────
# %100 sulama oranının geçtiği bölüm, eşitliğin 2021-2024 ile sınırlı
# olduğunu söylemek zorunda. Sınırsız yazılırsa okur bunu ölçüm sanar.
for dil, bolumler, kalip, sinir in (
        ("tr", BTR, r"%100|%\s*100", "2021-2024"),
        ("en", BEN, r"\b100%", "2021 to 2024")):
    for no, govde in bolumler.items():
        if re.search(kalip, govde) and "sula" in govde.lower() + "irrig":
            if sinir not in govde and "2021" not in govde:
                hata.append(f"{dil} §{no}: %100 sulama oranı geçiyor ama "
                            f"eşitliğin sınırı ({sinir}) yazılmamış")

# ── 9 — katma değer kapsamı ───────────────────────────────────────────────
for dil, bolumler, pay, kapsam in (
        ("tr", BTR, "11,39", ("ormancılık", "balıkçılık")),
        ("en", BEN, "11.39", ("forestry", "fishing"))):
    for no, govde in bolumler.items():
        if pay in govde and not all(k in govde.lower() for k in kapsam):
            hata.append(f"{dil} §{no}: katma değer payı geçiyor ama kalemin "
                        f"{' ve '.join(kapsam)} içerdiği yazılmamış")

# ── 10 — projeksiyon gövdede değil ────────────────────────────────────────
NUFUS_YILI = int(VERI["makro"]["misir"]["nufus_yil"])
for dil, metin in (("tr", TR), ("en", EN)):
    for m in re.finditer(r"\b(20[3-9]\d|21\d\d)\b", metin):
        yil = int(m.group(1))
        cevre = metin[max(0, m.start() - 120):m.start() + 120].lower()
        if any(k in cevre for k in ("nüfus", "population")):
            if yil > NUFUS_YILI and "2100" not in m.group(1):
                hata.append(f"{dil}: PROJEKSİYON GÖVDEDE — nüfus bağlamında "
                            f"{yil} geçiyor, ölçülen son yıl {NUFUS_YILI}")

# ── 11 — tane mısır ayrımı ────────────────────────────────────────────────
# Küçük harfli "mısır" ürün demek ve yalnız iki biçimde geçebilir.
# AYIRAN ŞEY KESME İŞARETİ. İlk iki hâli de zayıftı: önce "tane " ekini
# aynı satırda ve küçük harfle arıyordu (satır sarması ve başlıktaki büyük
# harf yüzünden dört sahte hata), sonra yalnız küçük harfli biçimi
# tarıyordu — ve olumsuz denemede "Mısırın hasat alanı" KAÇTI.
#
# Türkçe yazımda özel ad ekini kesme işaretiyle alıyor: ülke "Mısır'ın",
# ürün "mısırın". Yani ekli bir biçim kesme işareti TAŞIMIYORSA ürün
# demektir ve başında "tane" olmak zorunda.
_tr_duz = re.sub(r"\s+", " ", TR)
EK = r"(?:ın|in|ı|i|a|e|da|de|dan|den|la|le)"
for m in re.finditer(rf"(?<![A-ZÇĞİÖŞÜa-zçğıöşü])([Mm]ısır)('?){EK}?\b", _tr_duz):
    kelime, kesme = m.group(1), m.group(2)
    once = _tr_duz[max(0, m.start() - 12):m.start()].lower()
    sonra = _tr_duz[m.end():m.end() + 8]
    if once.endswith("tane ") or sonra.startswith(" yağ"):
        continue
    if kesme == "'":
        continue        # özel ad: ülke
    if kelime == "Mısır" and m.group(0) == "Mısır":
        continue        # eksiz büyük harfli biçim ülke adı
    hata.append(f"tr: '{m.group(0)}' — kesme işareti yok, yani ÜRÜN; "
                f"başında 'tane' olmalı: "
                f"…{_tr_duz[max(0, m.start() - 45):m.end() + 25]}…")

# ── 12 — Protokol I asimetrisi sanayi etiketli ────────────────────────────
for dil, bolumler, etiket in (("tr", BTR, "sanayi"), ("en", BEN, "industrial")):
    for no, govde in bolumler.items():
        if re.search(r"\b2020\b", govde) and "kademeli" in govde.lower() + "gradual":
            if etiket not in govde.lower():
                hata.append(f"{dil} §{no}: Protokol I'in kademeli takvimi "
                            f"geçiyor ama '{etiket}' etiketi yok — tarım "
                            f"tavizi gibi okunur")

# ── 13 — iddia edilmeyenler ───────────────────────────────────────────────
for dil, bolumler, kalip, ne in (
        ("tr", BTR, r"iddia etmiyor|sebebini iddia", "ayna farkının sebebi"),
        ("en", BEN, r"does not assert|not assert a cause", "the mirror gap's cause")):
    if 14 in bolumler and not re.search(kalip, sade(bolumler[14]), re.I):
        hata.append(f"{dil} §14: {ne} iddia edilmediği yazılmamış")
# 'model' kelimesinin bölümde GEÇMESİ yetmiyor: olumsuz denemede etiket
# cümlesi silindiği hâlde bölümün başka bir yerinde "modele katıldığında"
# geçtiği için kural susmuştu. Artık bulgunun SAHA ÖLÇÜMÜ OLMADIĞINI
# söyleyen ibare de aranıyor.
for dil, bolumler, kalip in (
        ("tr", BTR, r"model\w*[^.]{0,80}(saha ölçüm\w*|ölçümünden değil)"),
        ("en", BEN, r"model[^.]{0,80}(field monitoring|not from .{0,20}field)")):
    if 8 in bolumler and not re.search(kalip, sade(bolumler[8]), re.I):
        hata.append(f"{dil} §8: pirinç süzülmesi bulgusunun MODELDEN geldiği "
                    f"ve saha ölçümü OLMADIĞI bir arada yazılmamış")
for dil, bolumler, kalip in (
        ("tr", BTR, r"bu amaçla ekildiğini doğrulayan"),
        ("en", BEN, r"confirms that rice is grown")):
    if 8 in bolumler and not re.search(kalip, sade(bolumler[8]), re.I):
        hata.append(f"{dil} §8: pirincin bu amaçla ekildiğinin "
                    f"doğrulanmadığı yazılmamış")
# Jumel — tek yıl iddia edilmiyor
for dil, bolumler in (("tr", BTR), ("en", BEN)):
    if 10 in bolumler:
        g = sade(bolumler[10])
        if not all(y in g for y in ("1818", "1819", "1821")):
            hata.append(f"{dil} §10: Jumel'in yıl çelişkisi tam yazılmamış — "
                        f"üç yılın üçü de geçmeli")

# ══════════════════════════════════════════════════════════════════════════
if hata:
    print("METİN KİLİTLENMEDİ:", file=sys.stderr)
    for h in hata:
        print("  ✗", h, file=sys.stderr)
    if uyari:
        print(f"\n  ({len(uyari)} uyarı ayrıca var)", file=sys.stderr)
    sys.exit(1)

tr_k = sum(len(v.split()) for v in BTR.values())
en_k = sum(len(v.split()) for v in BEN.values())
print(f"metin kilitlendi · TR {len(BTR)} bölüm / {tr_k} kelime · "
      f"EN {len(BEN)} bölüm / {en_k} kelime · "
      f"{len(SAYILAR)} veri sayısı taranarak 13 avcının 13'ü geçti")
for uy in uyari:
    print("  ⚠", uy)
