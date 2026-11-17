#!/usr/bin/env python3
"""
Yapay Zeka ve Dijital Tarım — bölüm metinlerinin doğrulayıcısı (karar 25/48).

    python3 dogrula_bolumler.py

Her `bolumler/NN-*.{tr,en}.md` dosyası kendi kilitli kaydına
(`_raw/bNN_kaynaklar.json`) karşı sınanır. Kayıt yoksa bölüm yazılmış
sayılmaz — DURUR.

KURALLAR
  1. SAYI İZİ. Metindeki her sayı, YAZILDIĞI BASAMAKTA kayıttaki bir
     değerden türetilebilmeli: "%99" ← 99,35 ✓; "%31" ← 31,40 ✓.
     Kayıtta olmayan sayı metne giremez ("kaynağı olmayan bilgi yayına
     çıkmaz").
  2. REDDEDİLEN SAYI. Kaydın `_reddedilen` bölümündeki sayılar (doğrulanamayan
     satıcı rakamları, birincil kaynaktan teyit edilemeyen tutarlar) metinde
     geçemez — Tur 1'de reddedilen rakamlar metne yazılmış, elle yakalanmıştı.
  3. SATICI ETİKETİ (karar 34). Niteliği SATICI olan bir kaydın sayısını
     taşıyan satır, satıcı beyanı olduğunu söylemeli.
  4. İKİ DİL. TR ve EN sürümlerin sayı kümeleri aynı olmalı: bir dilde olup
     ötekinde olmayan sayı, çeviride düşen ya da eklenen bilgi demek.
  5. BİÇİM. Başlık satırı "# NN · …" ile başlamalı ve dosya adındaki
     numarayla tutmalı (dosya biçimi; okura görünmüyor).
  6. ÜRETİLMİŞ BAŞLIK. §30 Kaynakça elle yazılmıyor, bütün kayıtlardan
     üretiliyor (`kaynakca_uret.py`). Künyelerdeki DOI, tarih ve sayfa
     numaraları iki dilin sayı ayrıştırıcısında farklı okunduğu için §30 sayı
     izine değil, üreticinin o anki çıktısına karşı sınanır: kayıtlar
     değişip kaynakça eski kalırsa DURUR. §29 Sözlük de üretiliyor
     (`sozluk_uret.py`, `sozluk.json`dan); tanımları elle yazıldığı için hem
     sayı izine hem üreticinin çıktısına karşı sınanır.
  7. KOPYA. Bir kayıttaki kaynak başka bir başlığın kaydından kopyalanmışsa
     (`_kopya`: "bNN_kaynaklar.json · anahtar[ · not]") kopyanın her alanı
     (künye, dosya, sayısal alanlar) asıldakiyle aynı olmalı. Asıl değişip
     kopya eski kalırsa DURUR: §1'in özeti ve §25'in dizini öbür başlıkların
     kayıtlarından kopyalanıyor; bir başlıkta ölçüm değişince onlar da
     yeniden okunmalı. Alıntılar burada sınanmıyor: her alıntı belgenin
     kendisine karşı `dogrula_alintilar.py`de sınanıyor ve kopya aynı
     belgeden ek alıntı taşıyabilir.
  8. ÜSLUP (karar 56). Metin başlık satırından sonra doğrudan düz yazıyla
     başlar (alt başlık, tablo ya da alıntı bloğu ile değil); hiçbir yerde
     özet/alıntı bloğu (">"), "§" göndermesi, "Bu sayfa nasıl güncelleniyor"
     bölümü ya da "Eksik olan ise …" kalıbı yok. §29 ve §30 üretilmiş: ilk
     satır kuralı onlara uygulanmaz, ötekiler uygulanır.
"""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

BURASI = Path(__file__).resolve().parent
BOLUMLER = BURASI.parent / "bolumler"

hatalar: list[str] = []


def hata(m: str) -> None:
    hatalar.append(m)
    print(f"  ✗ {m}")


# Künye ve tarih alanlarından YALNIZ YIL alınır; tanıtıcı alanlardan hiçbir
# şey alınmaz. Aksi hâlde DOI'deki, cilt ve sayfa numarasındaki rakamlar
# havuzu doldurur ve uydurma bir sayı tesadüfen "izlenir" görünür.
YALNIZ_YIL = {"kunye", "yayim_tarihi", "tarih"}
# `guncellendi` sayfanın künyesi, metnin dayanağı değil: tarihindeki 16 ve
# 11 havuza girerse metindeki her "16" kendiliğinden "izlenir" görünürdü.
TANITICI = {"doi", "on_baski", "adres", "dogrulandigi_yer", "lisans_adresi",
            "guncellendi", "dosya"}


def kayit_sayilari(dugum, anahtar: str = "") -> list[float]:
    """Kayıttaki sayılar: sayısal alanlar, metin alanlarındaki rakamlar
    ('3-6 gün' gibi aralıklar) ve künyedeki yıl."""
    cikti: list[float] = []
    if isinstance(dugum, bool) or anahtar in TANITICI:
        return cikti
    if isinstance(dugum, (int, float)):
        cikti.append(float(dugum))
    elif isinstance(dugum, str):
        if anahtar in YALNIZ_YIL:
            return [float(y) for y in re.findall(r"(?<!\d)(?:19|20)\d{2}(?!\d)", dugum)]
        for s in re.findall(r"\d+(?:[.,]\d+)?", dugum):
            try:
                cikti.append(float(s.replace(",", ".")))
            except ValueError:
                pass
            if re.fullmatch(r"\d{1,3}[.,]\d{3}", s):        # binlik ayraçlı
                cikti.append(float(s.replace(".", "").replace(",", "")))
    elif isinstance(dugum, dict):
        for a, v in dugum.items():
            if not a.startswith("_"):
                cikti += kayit_sayilari(v, a)
    elif isinstance(dugum, list):
        for v in dugum:
            cikti += kayit_sayilari(v, anahtar)
    return cikti


def metin_sayilari(metin: str, dil: str) -> list[tuple[float, int, str]]:
    """(değer, ondalık basamak, satır) üçlüleri. TR: binlik '.', ondalık ','.
    EN: binlik ',', ondalık '.'."""
    binlik, ondalik = (r"\.", ",") if dil == "tr" else (",", r"\.")
    desen = re.compile(rf"(?<![\w.,])(\d{{1,3}}(?:{binlik}\d{{3}})+|\d+(?:{ondalik}\d+)?)(?![\d])")
    cikti = []
    for satir in metin.splitlines():
        if satir.startswith("# "):
            continue                        # başlık satırı: bölüm numarası
        # "§8" bir veri değil, bölümün iç göndermesi; ayrıca sınanıyor
        # (gönderilen başlık iskelette var mı — `gondermeler`).
        satir = re.sub(r"§\d+", "§", satir)
        for m in desen.finditer(satir):
            ham = m.group(1)
            if re.fullmatch(rf"\d{{1,3}}(?:{binlik}\d{{3}})+", ham):
                deger, bas = float(re.sub(binlik, "", ham)), 0
            else:
                ayrac = "," if dil == "tr" else "."
                deger = float(ham.replace(ayrac, "."))
                bas = len(ham.split(ayrac)[1]) if ayrac in ham else 0
            cikti.append((deger, bas, satir.strip()))
    return cikti


def izlenir(deger: float, bas: int, havuz: list[float]) -> bool:
    return any(abs(round(v, bas) - deger) < 1e-9 or abs(v - deger) < 1e-9 for v in havuz)


GECERLI_BASLIKLAR = {b["no"] for b in json.loads(
    (BURASI.parent / "iskelet.json").read_text(encoding="utf-8"))["basliklar"]}

# PROJE: teknolojiyi geliştiren firmanın da yazdığı proje broşürü (§7,
# AquaTag). Satıcı beyanı gibi etiketlenir — karar 34.
SATICI_ETIKETI = {"tr": re.compile(r"[Şş]irket(in)? (kendi )?(beyan|rakam)|[Ss]atıcı|proje beyan"),
                  "en": re.compile(r"[Vv]endor|[Cc]ompany('s)? (own )?(statement|figure)|project statement")}


def sina(no: str, dosyalar: dict[str, Path]) -> None:
    kayit_yolu = BURASI / f"b{no}_kaynaklar.json"
    if not kayit_yolu.exists():
        hata(f"§{int(no)}: kilitli kayıt yok ({kayit_yolu.name}) — bölüm yazılmış sayılmaz")
        return
    kayit = json.loads(kayit_yolu.read_text(encoding="utf-8"))
    havuz = kayit_sayilari({k: v for k, v in kayit.items() if not k.startswith("_")})
    red = {float(x) for x in re.findall(r"\d+", json.dumps(kayit.get("_reddedilen", {}), ensure_ascii=False))} - set(havuz)
    saticilar = [v for v in kayit.get("kaynaklar", {}).values() if v.get("nitelik") in ("SATICI", "PROJE")]
    satici_sayilari = {v for s in saticilar for v in kayit_sayilari(
                           {a: x for a, x in s.items() if a not in ("alinti", "kunye")})
                       if v not in (0, 1)}
    # Satıcı rakamı başka bir kaynakta da geçiyorsa (aynı sayı, başka ölçüm)
    # etiket zorunluluğu o satırda anlamsız olur: yalnız satıcıya ÖZGÜ sayılar.
    oteki = {v for k, s in kayit.get("kaynaklar", {}).items()
             if isinstance(s, dict) and s.get("nitelik") not in ("SATICI", "PROJE")
             for v in kayit_sayilari({a: x for a, x in s.items() if a != "kunye"})}
    satici_sayilari -= oteki

    kume = {}
    for dil, yol in dosyalar.items():
        metin = yol.read_text(encoding="utf-8")
        ilk = metin.splitlines()[0] if metin else ""
        if not re.match(rf"# {int(no)} · \S", ilk):
            hata(f"{yol.name}: başlık satırı '# {int(no)} · …' değil: {ilk[:50]!r}")
        sayilar = metin_sayilari(metin, dil)
        for deger, bas, satir in sayilar:
            if not izlenir(deger, bas, havuz):
                hata(f"{yol.name}: {deger:g} kayıtta yok — «{satir[:90]}»")
            if any(abs(deger - r) < 1e-9 for r in red):
                hata(f"{yol.name}: REDDEDİLMİŞ sayı {deger:g} metinde — «{satir[:90]}»")
            if deger in satici_sayilari and not SATICI_ETIKETI[dil].search(satir):
                hata(f"{yol.name}: satıcı rakamı {deger:g} etiketsiz — «{satir[:90]}»")
        kume[dil] = sorted({round(d, 4) for d, _, _ in sayilar})
        print(f"  · {yol.name}: {len(sayilar)} sayı, hepsi kayda karşı sınandı")
    if set(kume) == {"tr", "en"} and kume["tr"] != kume["en"]:
        yalniz_tr = sorted(set(kume["tr"]) - set(kume["en"]))
        yalniz_en = sorted(set(kume["en"]) - set(kume["tr"]))
        hata(f"§{int(no)}: iki dilin sayıları farklı — yalnız TR {yalniz_tr}, yalnız EN {yalniz_en}")


URETICI = {"29": "sozluk_uret.py", "30": "kaynakca_uret.py"}
SAYI_IZI_YOK = {"30"}


def sina_uretilmis(no: str, dosyalar: dict[str, Path]) -> None:
    """Üretilmiş başlık: dosyalar (ve üretici kayıt da yazıyorsa kayıt),
    üreticinin şimdiki çıktısıyla birebir mi."""
    import importlib.util
    spec = importlib.util.spec_from_file_location(f"uretici_{no}", BURASI / URETICI[no])
    uretici = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(uretici)
    try:
        tr, en, kayit = uretici.uret()
    except SystemExit as e:                 # üretici kendi denetiminde durdu
        hata(f"{URETICI[no]}: {e}")
        return
    for dil, beklenen in (("tr", tr), ("en", en)):
        yol = dosyalar.get(dil)
        if yol is None:
            continue
        ilk = yol.read_text(encoding="utf-8").splitlines()[0]
        if not re.match(rf"# {int(no)} · \S", ilk):
            hata(f"{yol.name}: başlık satırı '# {int(no)} · …' değil")
        if yol.read_text(encoding="utf-8") != beklenen:
            hata(f"{yol.name}: üreticinin çıktısıyla aynı değil — {URETICI[no]} koşturulmalı")
        else:
            print(f"  · {yol.name}: üreticinin çıktısıyla birebir")
    if kayit is not None:
        kayit_yolu = BURASI / f"b{no}_kaynaklar.json"
        if not kayit_yolu.exists() or kayit_yolu.read_text(encoding="utf-8") != kayit:
            hata(f"b{no}_kaynaklar.json üreticinin çıktısıyla aynı değil — {URETICI[no]} koşturulmalı")


USLUP_YASAK = [
    (re.compile(r"^> ", re.M), "özet ya da alıntı bloğu ('> ')"),
    (re.compile(r"§\d"), "'§' göndermesi"),
    (re.compile(r"^## (Bu sayfa nasıl güncelleniyor|How this page is kept up to date)", re.M),
     "'Bu sayfa nasıl güncelleniyor' bölümü"),
    (re.compile(r"Eksik olan ise|What is missing is"), "'Eksik olan ise' kalıbı"),
]


def sina_uslup(no: str, dosyalar: dict[str, Path]) -> None:
    """Kural 8 (karar 56): metin doğrudan başlar; tekrar eden kalıp yok."""
    for yol in dosyalar.values():
        satirlar = yol.read_text(encoding="utf-8").splitlines()
        govde = "\n".join(satirlar[1:])
        for desen, ad in USLUP_YASAK:
            m = desen.search(govde)
            if m:
                satir = govde[:m.start()].count("\n") + 2
                hata(f"{yol.name}:{satir}: {ad} var (karar 56)")
        if no in URETICI:
            continue
        ilk = next((s for s in satirlar[1:] if s.strip()), "")
        if ilk.startswith(("#", "|", ">")):
            hata(f"{yol.name}: metin doğrudan başlamıyor — ilk satır {ilk[:40]!r} (karar 56)")


def sina_kopyalar() -> None:
    """Kural 7: kopya kaynak asılla aynı mı."""
    kayitlar = {y.name: json.loads(y.read_text(encoding="utf-8"))
                for y in sorted(BURASI.glob("b[0-9][0-9]_kaynaklar.json"))}
    sayi = 0
    print("\nKopyalar")
    for ad, kayit in kayitlar.items():
        for anahtar, k in kayit.get("kaynaklar", {}).items():
            iz = k.get("_kopya")
            if not iz:
                continue
            sayi += 1
            m = re.fullmatch(r"(b\d{2}_kaynaklar\.json) · (\S+)(?: · .*)?", iz)
            if not m or m.group(1) not in kayitlar:
                hata(f"{ad} · {anahtar}: _kopya '{iz}' çözülemiyor")
                continue
            asil = kayitlar[m.group(1)].get("kaynaklar", {}).get(m.group(2))
            if asil is None:
                hata(f"{ad} · {anahtar}: asıl kaynak {iz} artık yok")
                continue
            for alan, deger in k.items():
                if alan.startswith("_") or alan == "alinti":
                    continue
                if asil.get(alan) != deger:
                    hata(f"{ad} · {anahtar}: '{alan}' asıldan ({iz}) ayrışmış — kopya yeniden okunmalı")
    print(f"  · {sayi} kopya kaynak asıllarıyla sınandı")


def main() -> int:
    gruplar: dict[str, dict[str, Path]] = {}
    for yol in sorted(BOLUMLER.glob("*.md")):
        m = re.match(r"(\d{2})-[a-z0-9-]+\.(tr|en)\.md$", yol.name)
        if not m:
            hata(f"{yol.name}: ad 'NN-adres.tr.md' biçiminde değil")
            continue
        gruplar.setdefault(m.group(1), {})[m.group(2)] = yol
    # Dosya adındaki adres iskeletteki adresle aynı olmalı: bölüm sayfası
    # dosyayı iskeletten kurduğu adla arıyor; ayrışan ad sessizce boş sayfa.
    iskelet = {b["no"]: b["slug"] for b in json.loads(
        (BURASI.parent / "iskelet.json").read_text(encoding="utf-8"))["basliklar"]}
    for no, dosyalar in gruplar.items():
        for yol in dosyalar.values():
            beklenen = f"{no}-{iskelet.get(int(no), '?')}."
            if not yol.name.startswith(beklenen):
                hata(f"{yol.name}: adres iskeletle tutmuyor — '{beklenen}…' bekleniyordu")
    print(f"{len(gruplar)} bölüm")
    for no, dosyalar in sorted(gruplar.items()):
        if set(dosyalar) != {"tr", "en"}:
            hata(f"§{int(no)}: iki dilden biri eksik ({', '.join(dosyalar)}) — karar 7")
        print(f"\n§{int(no)}")
        if no in URETICI:
            sina_uretilmis(no, dosyalar)
        if no not in SAYI_IZI_YOK:
            sina(no, dosyalar)
        sina_uslup(no, dosyalar)
    sina_kopyalar()
    if hatalar:
        print(f"\n✗ {len(hatalar)} HATA")
        return 1
    print("\n✓ Bölüm metinleri kayıtlarıyla birebir")
    return 0


if __name__ == "__main__":
    sys.exit(main())
