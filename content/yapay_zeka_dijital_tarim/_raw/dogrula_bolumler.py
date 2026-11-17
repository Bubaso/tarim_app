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
  9. TEKNOLOJİ SAYFASI (karar 57). `teknolojiler/<kod>.{tr,en}.md` başlıklar
     gibi sınanır: sayılar `tek_<kod>_kaynaklar.json`'dan (başlık
     kayıtlarından kopya; kural 7), iki dil aynı, üslup kuralı geçerli;
     ilk satır "# <teknolojinin adı>".
 11. GRAFİK (karar 58). `grafikler.json`'daki her değer bir kaydın sayısal
     alanına birebir eşit (ya da kaynağın kendi alıntısında geçiyor);
     metinlerdeki `[[grafik:…]]` yönergeleri tanımlı grafiğe gidiyor, iki dilde
     aynı sırada; kullanılmayan grafik yok.
 12. GÖRSEL (karar 58). `gorseller.json`'daki her görselin dosyası
     `web/yz/gorsel/` altında, sha256'sı tutuyor; künye ve kaynak iki dilde;
     adres ve indirme günü yazılı; yapay zekâ üretimi fotoğraf yok.
 10. KESİŞİM NOTU (karar 57). Bir başlık bir teknolojiyle etiketliyse
     `kesisim_<kod>.json`'da o başlığın tek cümlelik notu var, değilse yok.
     Notun sayıları başlığın kendi kaydından, iki dilde aynı.
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
        if re.fullmatch(r"\s*\[\[(grafik|gorsel):[a-z0-9-]+\]\]\s*", satir):
            continue                        # grafik/görsel yönergesi (karar 58)
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


def sina(no: str, dosyalar: dict[str, Path], kayit_yolu: Path | None = None,
         ilk_satir: str | None = None, ad: str | None = None) -> None:
    """Metnin sayıları kendi kaydına karşı (kural 1-5). Başlık için kayıt
    bNN_kaynaklar.json; teknoloji sayfası için tek_<kod>_kaynaklar.json."""
    kayit_yolu = kayit_yolu or BURASI / f"b{no}_kaynaklar.json"
    ad = ad or f"§{int(no)}"
    if not kayit_yolu.exists():
        hata(f"{ad}: kilitli kayıt yok ({kayit_yolu.name}) — yazılmış sayılmaz")
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
        if not re.match(ilk_satir or rf"# {int(no)} · \S", ilk):
            hata(f"{yol.name}: başlık satırı beklenen biçimde değil: {ilk[:50]!r}")
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
        hata(f"{ad}: iki dilin sayıları farklı — yalnız TR {yalniz_tr}, yalnız EN {yalniz_en}")


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


TEKNOLOJILER = BURASI.parent / "teknolojiler"
NOT_EN_UZUN = 220


def _iskelet() -> dict:
    return json.loads((BURASI.parent / "iskelet.json").read_text(encoding="utf-8"))


def sina_teknoloji_sayfalari() -> None:
    """Kural 9 (karar 57): her teknolojinin alanlar arası durum sayfası
    (`teknolojiler/<kod>.{tr,en}.md`) kendi kaydına (`tek_<kod>_kaynaklar.json`,
    başlık kayıtlarından kopya) karşı başlıklar gibi sınanır; üslup kuralı da."""
    print("\nTeknoloji sayfaları")
    for kod, t in _iskelet()["teknoloji"].items():
        dosyalar = {dil: TEKNOLOJILER / f"{kod}.{dil}.md" for dil in ("tr", "en")}
        eksik = [y.name for y in dosyalar.values() if not y.exists()]
        if eksik:
            hata(f"teknoloji {kod}: sayfa yok ({', '.join(eksik)})")
            continue
        ilk = rf"# ({re.escape(t['tr'])}|{re.escape(t['en'])})$"
        sina(kod, dosyalar, kayit_yolu=BURASI / f"tek_{kod}_kaynaklar.json",
             ilk_satir=ilk, ad=f"teknoloji {kod}")
        sina_uslup("tek", dosyalar)


def sina_kesisimler() -> None:
    """Kural 10 (karar 57): her teknoloji–başlık kesişiminin (başlık o
    teknolojiyle etiketliyse) kısa bir notu var; fazlası yok. Not tek cümle,
    kalın ve § yok; sayıları başlığın kendi kaydından, iki dilde aynı."""
    print("\nKesişim notları")
    isk = _iskelet()
    etiketli = {kod: {b["no"] for b in isk["basliklar"] if kod in b["teknoloji"]}
                for kod in isk["teknoloji"]}
    sayac = 0
    for kod, nolar in etiketli.items():
        yol = BURASI / f"kesisim_{kod}.json"
        if not yol.exists():
            hata(f"{yol.name} yok")
            continue
        notlar = {int(k): v for k, v in json.loads(yol.read_text(encoding="utf-8")).get("notlar", {}).items()}
        for no in sorted(nolar - set(notlar)):
            hata(f"{yol.name}: §{no} etiketli ama notu yok")
        for no in sorted(set(notlar) - nolar):
            hata(f"{yol.name}: §{no} bu teknolojiyle etiketli değil, notu olmamalı")
        for no, n in sorted(notlar.items()):
            kayit_yolu = BURASI / f"b{no:02d}_kaynaklar.json"
            havuz = kayit_sayilari({k: v for k, v in json.loads(kayit_yolu.read_text(encoding="utf-8")).items()
                                    if not k.startswith("_")}) if kayit_yolu.exists() else []
            kume = {}
            for dil in ("tr", "en"):
                metin = (n or {}).get(dil, "")
                if not metin.strip():
                    hata(f"{yol.name} §{no}: {dil} notu boş")
                    continue
                if len(metin) > NOT_EN_UZUN:
                    hata(f"{yol.name} §{no} {dil}: {len(metin)} karakter (en çok {NOT_EN_UZUN})")
                if "§" in metin or "**" in metin or "\n" in metin:
                    hata(f"{yol.name} §{no} {dil}: §, kalın ya da satır sonu var")
                sayilar = metin_sayilari(metin, dil)
                for deger, bas, _ in sayilar:
                    if not izlenir(deger, bas, havuz):
                        hata(f"{yol.name} §{no} {dil}: {deger:g} b{no:02d} kaydında yok")
                kume[dil] = sorted({round(d, 4) for d, _, _ in sayilar})
                sayac += 1
            if set(kume) == {"tr", "en"} and kume["tr"] != kume["en"]:
                hata(f"{yol.name} §{no}: iki dilin sayıları farklı {kume['tr']} / {kume['en']}")
    print(f"  · {sayac} not sınandı")


GRAFIK_TURLERI = {"yatay_cubuk", "dikey_cubuk", "cizgi", "alan", "dumbbell", "aralik", "pay",
                  "waffle", "egim", "kpi", "isi", "zaman"}
YONERGE_DESENI = re.compile(r"^\[\[(grafik|gorsel):([a-z0-9-]+)\]\]$", re.M)


def _alan_degerleri(deger) -> list[float]:
    """Kayıt alanının sayıları: 12.5 → [12.5]; "24-37" → [24, 37]."""
    if isinstance(deger, (int, float)) and not isinstance(deger, bool):
        return [float(deger)]
    if isinstance(deger, str):
        return [float(x.replace(",", ".")) for x in re.findall(r"\d+(?:[.,]\d+)?", deger)]
    return []


def sina_grafikler() -> None:
    """Kural 11 (karar 58): her grafik değeri bir kaydın sayısal alanına
    birebir eşit (ya da kaydın kendi alıntısında geçiyor); metinlerdeki her
    [[grafik:…]] yönergesi tanımlı bir grafiğe gidiyor; iki dilin yönergeleri
    aynı sırada; tanımlanıp hiçbir yerde kullanılmayan grafik yok."""
    print("\nGrafikler")
    yol = BURASI / "grafikler.json"
    grafikler = json.loads(yol.read_text(encoding="utf-8")).get("grafikler", {}) if yol.exists() else {}
    kayitlar: dict[str, dict] = {}

    def kayit(ad: str) -> dict:
        if ad not in kayitlar:
            ky = BURASI / ad
            kayitlar[ad] = json.loads(ky.read_text(encoding="utf-8")) if ky.exists() else {}
        return kayitlar[ad]

    for kimlik, g in grafikler.items():
        if g.get("tur") not in GRAFIK_TURLERI:
            hata(f"grafik {kimlik}: bilinmeyen tür {g.get('tur')!r}")
        for a in ("baslik", "aciklama", "kaynak"):
            if not all((g.get(a) or {}).get(d, "").strip() for d in ("tr", "en")):
                hata(f"grafik {kimlik}: {a} iki dilde de dolu değil")
        if not g.get("noktalar"):
            hata(f"grafik {kimlik}: nokta yok")
        dizi_kodlari = {d["kod"] for d in g.get("diziler", [])}
        for n in g.get("noktalar", []):
            if dizi_kodlari and n.get("dizi") not in dizi_kodlari:
                hata(f"grafik {kimlik}: nokta dizisi {n.get('dizi')!r} tanımlı değil")
            k = kayit(n.get("kayit", ""))
            kaynak = (k.get("kaynaklar") or {}).get(n.get("kaynak", ""))
            if kaynak is None:
                hata(f"grafik {kimlik}: {n.get('kayit')} · {n.get('kaynak')} kaynağı yok")
                continue
            v = float(n["deger"])
            if n.get("alan"):
                adaylar = _alan_degerleri(kaynak.get(n["alan"]))
                if not any(abs(v - x) < 1e-9 for x in adaylar):
                    hata(f"grafik {kimlik}: {v:g} ≠ {n['kayit']} · {n['kaynak']} · {n['alan']} ({kaynak.get(n['alan'])!r})")
            elif n.get("alinti"):
                if n["alinti"] not in json.dumps(kaynak.get("alinti", []), ensure_ascii=False):
                    hata(f"grafik {kimlik}: alıntı kaynağın alıntılarında yok — {n['alinti'][:60]!r}")
                elif not any(abs(v - x) < 1e-9 for x in _alan_degerleri(n["alinti"].replace(",", ""))
                             + _alan_degerleri(n["alinti"])):
                    hata(f"grafik {kimlik}: {v:g} alıntıda geçmiyor — {n['alinti'][:60]!r}")
            else:
                hata(f"grafik {kimlik}: değerin alanı da alıntısı da yok")

    kullanilan: set[str] = set()
    sayfalar = [*sorted(BOLUMLER.glob("[0-2][0-9]-*.tr.md")), *sorted(TEKNOLOJILER.glob("*.tr.md"))]
    for tr in sayfalar:
        en = tr.with_name(tr.name.replace(".tr.md", ".en.md"))
        y_tr = YONERGE_DESENI.findall(tr.read_text(encoding="utf-8"))
        y_en = YONERGE_DESENI.findall(en.read_text(encoding="utf-8")) if en.exists() else []
        if y_tr != y_en:
            hata(f"{tr.name}: TR ve EN'deki grafik/görsel yönergeleri aynı değil")
        for tur, kimlik in y_tr:
            if tur == "grafik":
                if kimlik not in grafikler:
                    hata(f"{tr.name}: [[grafik:{kimlik}]] tanımlı değil")
                kullanilan.add(kimlik)
    for kimlik in sorted(set(grafikler) - kullanilan):
        hata(f"grafik {kimlik}: hiçbir metinde kullanılmıyor")
    print(f"  · {len(grafikler)} grafik, {len(kullanilan)} yönerge sınandı")


def sina_gorseller() -> None:
    """Kural 12 (karar 58): her görselin dosyası `web/yz/gorsel/` altında ve
    sha256'sı kayıttakiyle aynı; künye ve kaynak satırı iki dilde dolu;
    adresi ve indirme günü yazılı; yapay zekâ üretimi FOTOĞRAF yok (istisna
    kullanıcı onayıyla, `istisna` alanında); metindeki her [[gorsel:…]]
    tanımlı, tanımlı her görsel kullanılıyor."""
    import hashlib
    print("\nGörseller")
    yol = BURASI / "gorseller.json"
    gorseller = json.loads(yol.read_text(encoding="utf-8")).get("gorseller", {}) if yol.exists() else {}
    depo = BURASI.parents[2]
    for kimlik, g in gorseller.items():
        dosya = depo / g.get("dosya", "")
        if not g.get("dosya", "").startswith("web/yz/gorsel/") or not dosya.exists():
            hata(f"görsel {kimlik}: dosya yok ya da yanlış yerde ({g.get('dosya')!r})")
        elif hashlib.sha256(dosya.read_bytes()).hexdigest() != g.get("sha256"):
            hata(f"görsel {kimlik}: sha256 tutmuyor")
        for a in ("kunye", "kaynak"):
            if not all((g.get(a) or {}).get(d, "").strip() for d in ("tr", "en")):
                hata(f"görsel {kimlik}: {a} iki dilde de dolu değil")
        if not str(g.get("sayfa_adresi") or g.get("gorsel_adresi") or "").startswith("https://") and not g.get("yapay_zeka"):
            hata(f"görsel {kimlik}: kaynak adresi yok")
        if not g.get("indirme_gunu") and not g.get("yapay_zeka"):
            hata(f"görsel {kimlik}: indirme günü yok")
        if g.get("yapay_zeka") and g.get("tur") not in ("sema", "illustrasyon") and not g.get("istisna"):
            hata(f"görsel {kimlik}: yapay zekâ üretimi fotoğraf (karar 58: yalnız şema/illüstrasyon)")
    kullanilan: set[str] = set()
    for md in [*BOLUMLER.glob("[0-2][0-9]-*.md"), *TEKNOLOJILER.glob("*.md")]:
        for tur, kimlik in YONERGE_DESENI.findall(md.read_text(encoding="utf-8")):
            if tur == "gorsel":
                if kimlik not in gorseller:
                    hata(f"{md.name}: [[gorsel:{kimlik}]] tanımlı değil")
                kullanilan.add(kimlik)
    for kimlik in sorted(set(gorseller) - kullanilan):
        hata(f"görsel {kimlik}: hiçbir metinde kullanılmıyor")
    print(f"  · {len(gorseller)} görsel sınandı")


def sina_kopyalar() -> None:
    """Kural 7: kopya kaynak asılla aynı mı."""
    kayitlar = {y.name: json.loads(y.read_text(encoding="utf-8"))
                for y in sorted([*BURASI.glob("b[0-9][0-9]_kaynaklar.json"),
                                 *BURASI.glob("tek_*_kaynaklar.json")])}
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
    sina_teknoloji_sayfalari()
    sina_kesisimler()
    sina_grafikler()
    sina_gorseller()
    sina_kopyalar()
    if hatalar:
        print(f"\n✗ {len(hatalar)} HATA")
        return 1
    print("\n✓ Bölüm metinleri kayıtlarıyla birebir")
    return 0


if __name__ == "__main__":
    sys.exit(main())
