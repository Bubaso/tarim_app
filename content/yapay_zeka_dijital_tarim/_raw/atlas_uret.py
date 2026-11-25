#!/usr/bin/env python3
"""Türkiye Dijital Tarım Atlası — kayıtlar (atlas turu, 25 Kasım 2026).

    python3 -I content/yapay_zeka_dijital_tarim/_raw/atlas_uret.py

Rapor basar: il başına kayıt sayısı, İngilizce hizalama oranı, dışlanan
eşleşmeler, eşlenemeyen kurumlar. Dart sabitini `dart_uret.py` yazar
(`lib/features/yapay_zeka/data/yz_atlas.g.dart`, bu betiğin
`dart_kaynagi()`ıyla); `dogrula_bolumler.py` kural 17 aynı kayıtları metne ve
eşleme dosyasına karşı sınar ve üretilmiş dosyanın güncel olduğunu denetler.

HARİTA — IZGARA. Gerçek il sınırı yok: her il 17 × 7'lik ızgarada bir kare
hücre, kabaca coğrafi yerinde (bölümün motifi veri-tarla ızgarası, karar 44).
Yerleşim `il_izgarasi.json`; üreticisi `il_izgarasi.py 17 7 il_izgarasi.json`.
Betikteki koordinatlar il merkezlerinin yaklaşık değerleri ve YALNIZ yerleşim
için; okura gösterilmiyor, Dart'a da gitmiyor.

ÜÇ TÜR KAYIT — hepsi kaynaklı, okura giden metin harfi harfine kaynaktan:

  1. DOSYADA. 30 başlığın Türkçe metinlerinde (§29 sözlük ve §30 kaynakça
     hariç) il adı geçen cümleler: paragraf ve liste maddesi; cümle sınırı
     telefon bölücüsünün kuralı (`telefon_bolme.cumle_sinirlari`). Cümle
     kısaltılmaz. İngilizce karşılık aynı başlığın .en.md'sinde AYNI blok
     sırasındaki paragraftan (liste maddesinden) ilin geçtiği cümle: TR
     paragrafında ilin geçtiği k. cümle ↔ EN paragrafında ilin geçtiği k.
     cümle, iki sayı eşitse. Eşit değilse kayıt İngilizcede gösterilmez.
     Bağlantı başlığın adresi; cümle bir alt başlığın altındaysa o alt
     başlığın metni de kayıtta (sayfa `?bolum=` derin bağlantısını onunla
     kuruyor, yz_makale.dart ile aynı `etiketSlug`).
  2. TÜRKİYE DİZİNİNDE. §25'in tabloları. "Girişimler": ili "Kuruluş"
     sütunundan ("2012, İzmir"). "Araştırma ve destek programları" ve
     "Üniversiteler": ili üniversite sütunundaki kurumlardan,
     `atlas_kurum_ili.json` ile (elle; dayanak "adında" ya da "üniversitenin
     merkezinin bulunduğu il"). Birden çok kurumlu hücre birden çok ile
     düşer; aynı ile düşen kurumlar tek kayıt. Kamu tabloları ulusal
     sistemler: haritaya konmaz. Gösterilen metin tablo hücrelerinin
     kendisi (kurum adı, ek hücre, açıklama hücresi ve o sütunun başlığı).
  3. HABERLERDE. Çalışma anında, bölümün okura açık etiketli haberleri
     (yz_atlas_veri.dart); burada yok.

İL ADI. Büyük harfle başlayan sözcük (büyük-küçük harfe duyarlı): "ordu",
"duruyordu" Ordu değildir. Türkçe ekler: kesmeyle ("Antalya'da",
"Sakarya'nın") ve kesmesiz -lı/-li/-lu/-lü ("Antalyalı", "Antalyalılar";
"-lık" değil: "Aydınlık" Aydın değildir). İngilizce metinde "Istanbul" gibi
yazımlar ve "'s". Kurum adındaki il geçerli ("Tekirdağ Namık Kemal
Üniversitesi" Tekirdağ). DIŞLAMA aşağıda: il adıyla başlayan ama il olmayan
sözler (Van der Velde bir soyadı). Aynı liste Dart'a da gidiyor; haber
eşleştiricisi de onu kullanıyor.
"""
from __future__ import annotations

import importlib.util
import json
import re
import sys
from pathlib import Path

BURASI = Path(__file__).resolve().parent                  # _raw
KOK = BURASI.parent                                        # content/yapay_zeka_dijital_tarim
DEPO = KOK.parents[1]
BOLUMLER = KOK / "bolumler"
IZGARA = BURASI / "il_izgarasi.json"
KURUM = BURASI / "atlas_kurum_ili.json"
CIKIS = DEPO / "lib/features/yapay_zeka/data/yz_atlas.g.dart"

SUTUN, SATIR = 17, 7

# §29 Sözlük ve §30 Kaynakça: üretilmiş başvuru sayfaları, il cümlesi taşımaz.
HARIC_BASLIKLAR = {29, 30}
DIZIN_NO = 25

# İl adıyla başlayan ama il olmayan sözler. Eşleşme bu sözlerden biriyle
# başlıyorsa sayılmaz. Gerekçe her satırda; Dart'a yalnız söz gidiyor.
DISLAMA: list[tuple[str, str]] = [
    ("Van der ", "Hollandaca soyadı öneki: 'Van der Velde ve Nisini (2019)' (§9) bir yazar, Van ili değil"),
    ("Van den ", "Hollandaca soyadı öneki (Van der'in eşi); metinde yok, haber başlıkları için"),
]

# Yazım çeşitleri: aynı ilin resmî adının öbür yazılışı. Halk ağzındaki
# kısa adlar (Afyon, Urfa, Antep, Maraş) EKLENMEDİ: "Antep fıstığı" bir ürün
# adı; il adı resmî adıyla aranır.
CESITLER = {"Hakkâri": 30}

# §25'te ilin okunduğu tablolar: başlık satırı → hangi sütun ne.
#   ad: kaydın adı · ek: ad altındaki hücre (yoksa None) · aciklama: açıklama
#   hücresi (sütun başlığıyla gösteriliyor) · il: ilin okunduğu sütun ·
#   kaynak: "kurum" (atlas_kurum_ili.json) ya da "kurulus" ("2012, İzmir").
DIZIN_TABLOLARI: dict[tuple[str, ...], dict] = {
    ("Proje", "Konu", "Teknoloji sağlayıcı ya da paydaş", "Üniversite ya da araştırma kurumu"):
        {"ad": 0, "ek": 3, "aciklama": 1, "il": 3, "kaynak": "kurum"},
    ("Merkez", "Üniversite", "Dayanak", "Amaçlarından"):
        {"ad": 0, "ek": 1, "aciklama": 3, "il": 1, "kaynak": "kurum"},
    ("Üniversite", "Çalışma"):
        {"ad": 0, "ek": None, "aciklama": 1, "il": 0, "kaynak": "kurum"},
    ("Şirket", "Kuruluş", "Alan", "Ne yapıyor (şirketin kendi tanımı)"):
        {"ad": 0, "ek": 1, "aciklama": 3, "il": 1, "kaynak": "kurulus"},
}
# İlin okunduğu §25 alt başlıkları. "Kamu: …" tabloları ulusal sistemler.
DIZIN_BOLUMLERI = ("Araştırma ve destek programları", "Üniversiteler", "Girişimler")


def _modul(ad: str):
    sp = importlib.util.spec_from_file_location(f"atlas_{ad}", BURASI / f"{ad}.py")
    m = importlib.util.module_from_spec(sp)
    sp.loader.exec_module(m)
    return m


_telefon_bolme = _modul("telefon_bolme")


# ── İller ve ızgara ──────────────────────────────────────────────────────

def iller() -> dict[int, dict]:
    """plaka → {ad, sutun, satir}. 81 plaka, 81 ayrı hücre, ızgaranın içinde."""
    ham = json.loads(IZGARA.read_text(encoding="utf-8"))
    d = {int(p): v for p, v in ham.items()}
    if sorted(d) != list(range(1, 82)):
        raise SystemExit(f"✗ {IZGARA.name}: 1-81 plakaların hepsi yok")
    hucreler = {(v["sutun"], v["satir"]) for v in d.values()}
    if len(hucreler) != 81:
        raise SystemExit(f"✗ {IZGARA.name}: iki il aynı hücrede")
    for p, v in d.items():
        if not (0 <= v["sutun"] < SUTUN and 0 <= v["satir"] < SATIR):
            raise SystemExit(f"✗ {IZGARA.name}: {p} ızgaranın dışında")
    return d


_KATLA = str.maketrans("İıŞşĞğÜüÖöÇçÂâÎîÛû", "IiSsGgUuOoCcAaIiUu")


def en_adlari(ad: str) -> list[str]:
    """İngilizce metindeki yazılışlar: Türkçe adın kendisi ("İzmir"), yalnız
    İ'si noktasız ("Istanbul") ve bütünüyle ASCII ("Sanliurfa")."""
    adlar = [ad, ad.replace("İ", "I"), ad.translate(_KATLA)]
    return list(dict.fromkeys(adlar))


def _ad_plaka(en: bool) -> dict[str, int]:
    d: dict[str, int] = {}
    for p, v in iller().items():
        for a in (en_adlari(v["ad"]) if en else [v["ad"]]):
            d[a] = p
    for a, p in CESITLER.items():
        for b in (en_adlari(a) if en else [a]):
            d.setdefault(b, p)
    return d


def _desen(en: bool) -> re.Pattern:
    adlar = "|".join(re.escape(a) for a in sorted(_ad_plaka(en), key=len, reverse=True))
    # Ad sözcük başında; ardından ek ya da sözcük sonu. Python'un \w'si
    # Unicode harfi ve rakamı kapsıyor.
    ek = r"(?:['’]s)?" if en else r"(?:['’]\w+|l[ıiuü](?![kğ])\w*)?"
    return re.compile(rf"(?<!\w)({adlar}){ek}(?!\w)")


_DESENLER: dict[bool, re.Pattern] = {}
_ADLAR: dict[bool, dict[str, int]] = {}


def il_bul(metin: str, en: bool = False) -> list[tuple[int, int, int]]:
    """Metinde geçen iller: (plaka, adın başı, adın sonu). Ek dahil değil."""
    if en not in _DESENLER:
        _DESENLER[en] = _desen(en)
        _ADLAR[en] = _ad_plaka(en)
    sonuc = []
    for m in _DESENLER[en].finditer(metin):
        if any(metin.startswith(soz, m.start()) for soz, _ in DISLAMA):
            continue
        sonuc.append((_ADLAR[en][m.group(1)], m.start(1), m.end(1)))
    return sonuc


def dislananlar(metin: str, en: bool = False) -> list[str]:
    """Dışlama listesine takılan eşleşmeler (rapor için)."""
    if en not in _DESENLER:
        il_bul("", en)
    return [metin[m.start():m.start() + 40] for m in _DESENLER[en].finditer(metin)
            if any(metin.startswith(soz, m.start()) for soz, _ in DISLAMA)]


# ── Metin ────────────────────────────────────────────────────────────────

_YONERGE = re.compile(r"^\[\[([a-z]+):([a-z0-9-]+)\]\]$")
_BILINEN_YONERGE = {"grafik", "gorsel", "cekme", "canli"}
_AYIRAC = re.compile(r"^\|?[\s:|-]+\|?$")


def bloklar(md: str) -> list[dict]:
    """Sayfanın blokları — `dogrula_bolumler.sayfa_bloklari` ve Dart'taki
    `yzAyristir` ile aynı sınırlar; tablo satırları hücreleriyle (ayıraç
    satırı düşüyor)."""
    cikti: list[dict] = []
    par: list[str] = []
    satirlar = md.replace("\r\n", "\n").split("\n")

    def kapat():
        if par:
            cikti.append({"tur": "paragraf", "metin": " ".join(par)})
            par.clear()

    i = 0
    while i < len(satirlar):
        t = satirlar[i].strip()
        m = _YONERGE.fullmatch(t)
        if not t or t.startswith("# "):
            kapat(); i += 1
        elif m:
            kapat(); i += 1
            if m.group(1) in _BILINEN_YONERGE:
                cikti.append({"tur": m.group(1), "metin": m.group(2)})
        elif t.startswith("## "):
            kapat(); cikti.append({"tur": "altBaslik", "metin": t[3:].strip()}); i += 1
        elif t.startswith("- "):
            kapat()
            ogeler = []
            while i < len(satirlar) and satirlar[i].strip().startswith("- "):
                ogeler.append(satirlar[i].strip()[2:].strip()); i += 1
            cikti.append({"tur": "liste", "ogeler": ogeler})
        elif t.startswith(">"):
            kapat()
            while i < len(satirlar) and satirlar[i].strip().startswith(">"):
                i += 1
            cikti.append({"tur": "ozet"})
        elif t.startswith("|"):
            kapat()
            tablo = []
            while i < len(satirlar) and satirlar[i].strip().startswith("|"):
                s = satirlar[i].strip(); i += 1
                if not _AYIRAC.fullmatch(s):
                    tablo.append([h.strip() for h in s.strip("|").split("|")])
            cikti.append({"tur": "tablo", "satirlar": tablo})
        else:
            par.append(t); i += 1
    kapat()
    return cikti


def cumleler(metin: str, en: bool = False) -> list[str]:
    """Paragrafın cümleleri; sınırlar telefon bölücüsünün kuralıyla."""
    sinir = [0, *_telefon_bolme.cumle_sinirlari(metin, en), len(metin)]
    return [metin[a:b].strip() for a, b in zip(sinir, sinir[1:]) if metin[a:b].strip()]


def basliklar() -> list[tuple[int, Path, Path]]:
    """(no, .tr.md, .en.md) — §29 ve §30 hariç."""
    cikti = []
    for tr in sorted(BOLUMLER.glob("*.tr.md")):
        no = int(tr.name[:2])
        if no in HARIC_BASLIKLAR:
            continue
        cikti.append((no, tr, tr.with_name(tr.name.replace(".tr.md", ".en.md"))))
    return cikti


# ── 1. Dosyada ───────────────────────────────────────────────────────────

def _metinler(b: dict) -> list[str]:
    if b["tur"] == "paragraf":
        return [b["metin"]]
    if b["tur"] == "liste":
        return list(b["ogeler"])
    return []


def dosya_kayitlari() -> tuple[list[dict], dict]:
    """Başlık metinlerinde il adı geçen cümleler. İstatistik: hizalanan,
    toplam, dışlanan eşleşmeler, tablo hücresinde (cümle değil) geçen il."""
    kayitlar: list[dict] = []
    ist = {"toplam": 0, "hizalanan": 0, "hizalanmayan": [], "dislanan": [], "tablo": []}
    for no, tr_yol, en_yol in basliklar():
        tr_b = bloklar(tr_yol.read_text(encoding="utf-8"))
        en_b = bloklar(en_yol.read_text(encoding="utf-8")) if en_yol.exists() else []
        alt_tr = alt_en = None
        for i, b in enumerate(tr_b):
            karsi = en_b[i] if i < len(en_b) and en_b[i]["tur"] == b["tur"] else None
            if b["tur"] == "altBaslik":
                alt_tr, alt_en = b["metin"], (karsi or {}).get("metin")
                continue
            if b["tur"] == "tablo" and no != DIZIN_NO:
                for s in b["satirlar"]:
                    for h in s:
                        if il_bul(h):
                            ist["tablo"].append(f"§{no}: {h[:60]}")
            tr_metinler = _metinler(b)
            en_metinler = _metinler(karsi) if karsi else []
            for j, metin in enumerate(tr_metinler):
                ist["dislanan"] += [f"§{no}: {x}…" for x in dislananlar(metin)]
                tr_c = cumleler(metin)
                en_metin = en_metinler[j] if len(en_metinler) == len(tr_metinler) else ""
                en_c = cumleler(en_metin, en=True) if en_metin else []
                for c in tr_c:
                    for plaka in dict.fromkeys(p for p, _, _ in il_bul(c)):
                        # İlin geçtiği k. Türkçe cümle ↔ ilin geçtiği k. İngilizce cümle.
                        tr_il = [x for x in tr_c if any(p == plaka for p, _, _ in il_bul(x))]
                        en_il = [x for x in en_c if any(p == plaka for p, _, _ in il_bul(x, en=True))]
                        en = en_il[tr_il.index(c)] if len(en_il) == len(tr_il) else None
                        ist["toplam"] += 1
                        if en:
                            ist["hizalanan"] += 1
                        else:
                            ist["hizalanmayan"].append(f"§{no} {iller()[plaka]['ad']}: {c[:70]}…")
                        kayitlar.append({
                            "il": plaka, "baslik": no,
                            "alt_tr": alt_tr, "alt_en": alt_en if en else None,
                            "tr": c, "en": en,
                            "dosya_tr": tr_yol.name, "dosya_en": en_yol.name,
                        })
    return kayitlar, ist


# ── 2. Türkiye dizininde ─────────────────────────────────────────────────

def kurum_dosyasi() -> dict:
    return json.loads(KURUM.read_text(encoding="utf-8"))


def _kurum_parcalari(hucre: str, hucre_en: str | None, bilinen: set[str]) -> list[tuple[str, str, str | None]]:
    """Hücredeki kurumlar: (kurumun adı, hücredeki yazılışı, İngilizce
    hücredeki yazılışı ya da None).

    "Kırşehir Ahi Evran, Ankara ve Selçuk üniversiteleri" → üç üniversite;
    "Ege Üniversitesi, İzmir Yüksek Teknoloji Enstitüsü" → iki kurum. Adında
    "ve" geçen kurum ("Konya Gıda ve Tarım Üniversitesi") bölünmez: önce
    bütün parça eşleme dosyasında aranıyor. Tanınmayan parça ValueError."""
    m = re.fullmatch(r"(.+) üniversiteleri", hucre)
    if m:
        tr = re.split(r", | ve ", m.group(1))
        me = re.fullmatch(r"(.+) universities", hucre_en or "")
        en = re.split(r", | and ", me.group(1)) if me else []
        en = en if len(en) == len(tr) else [None] * len(tr)
        cikti = [(f"{p} Üniversitesi", p, e) for p, e in zip(tr, en)]
    else:
        tr = hucre.split(", ")
        en = (hucre_en or "").split(", ")
        en = en if len(en) == len(tr) else [None] * len(tr)
        cikti = []
        for p, e in zip(tr, en):
            if p in bilinen:
                cikti.append((p, p, e))
                continue
            alt = p.split(" ve ")
            alt_en = (e or "").split(" and ")
            alt_en = alt_en if len(alt_en) == len(alt) else [None] * len(alt)
            cikti += [(a, a, b) for a, b in zip(alt, alt_en)]
    for ad, _, _ in cikti:
        if ad not in bilinen:
            raise ValueError(ad)
    return cikti


def dizin_kayitlari() -> tuple[list[dict], dict]:
    """§25'in girişim, araştırma ve üniversite tablolarından il kayıtları."""
    esleme = kurum_dosyasi()
    kurumlar, eslenmeyen = esleme["kurumlar"], esleme["eslenmeyen"]
    bilinen = set(kurumlar) | set(eslenmeyen)
    ad_plaka = {v["ad"]: p for p, v in iller().items()}
    tr_yol = next(BOLUMLER.glob(f"{DIZIN_NO}-*.tr.md"))
    en_yol = tr_yol.with_name(tr_yol.name.replace(".tr.md", ".en.md"))
    tr_b = bloklar(tr_yol.read_text(encoding="utf-8"))
    en_b = bloklar(en_yol.read_text(encoding="utf-8"))
    kayitlar: list[dict] = []
    ist = {"satir": 0, "eslenmeyen": [], "ilsiz": [], "hatalar": []}
    bolum = bolum_en = None
    for i, b in enumerate(tr_b):
        karsi = en_b[i] if i < len(en_b) and en_b[i]["tur"] == b["tur"] else None
        if b["tur"] == "altBaslik":
            bolum, bolum_en = b["metin"], (karsi or {}).get("metin")
            continue
        if b["tur"] != "tablo" or bolum not in DIZIN_BOLUMLERI:
            continue
        baslik = tuple(b["satirlar"][0])
        dz = DIZIN_TABLOLARI.get(baslik)
        if dz is None:
            ist["hatalar"].append(f"§25 '{bolum}': tanınmayan tablo başlığı {baslik} — DIZIN_TABLOLARI'na ekle")
            continue
        en_satirlar = (karsi or {}).get("satirlar") or []
        if len(en_satirlar) != len(b["satirlar"]) or any(len(s) != len(baslik) for s in en_satirlar):
            ist["hatalar"].append(f"§25 '{bolum}': İngilizce tablo Türkçeyle aynı biçimde değil")
            continue
        for j, satir in enumerate(b["satirlar"][1:], start=1):
            ist["satir"] += 1
            en_s = en_satirlar[j]
            hucre, hucre_en = satir[dz["il"]], en_s[dz["il"]]
            # il → (Türkçe vurgular, İngilizce vurgular, dayanaklar, kurumlar)
            gruplar: dict[int, tuple[list, list, list, list]] = {}
            if dz["kaynak"] == "kurulus":
                bul = il_bul(hucre)
                bul_en = il_bul(hucre_en, en=True)
                if len({p for p, _, _ in bul}) != 1:
                    ist["hatalar"].append(f"§25 '{satir[0]}': Kuruluş hücresinde tek il yok ({hucre!r})")
                    continue
                p, a, z = bul[0]
                en_vurgu = [hucre_en[x:y] for q, x, y in bul_en if q == p][:1]
                gruplar[p] = ([hucre[a:z]], en_vurgu, ["Kuruluş sütunu"], [satir[0]])
            else:
                try:
                    parcalar = _kurum_parcalari(hucre, hucre_en, bilinen)
                except ValueError as e:
                    ist["hatalar"].append(f"§25 '{satir[0]}': '{e}' atlas_kurum_ili.json'da yok "
                                          "(eşle ya da gerekçesiyle eslenmeyen'e yaz)")
                    continue
                for ad, parca, parca_en in parcalar:
                    if ad in eslenmeyen:
                        ist["eslenmeyen"].append(f"{ad} — §25 '{satir[0]}'")
                        continue
                    k = kurumlar[ad]
                    p = ad_plaka.get(k["il"])
                    if p is None or k["dayanak"] not in esleme["dayanaklar"]:
                        ist["hatalar"].append(f"atlas_kurum_ili.json '{ad}': il ya da dayanak geçersiz")
                        continue
                    g = gruplar.setdefault(p, ([], [], [], []))
                    g[0].append(parca)
                    g[1].append(parca_en)
                    g[2].append(k["dayanak"])
                    g[3].append(ad)
            if not gruplar:
                ist["ilsiz"].append(f"§25 '{satir[0]}' ({hucre})")
            for p, (vurgu, vurgu_en, dayanak, kurum) in gruplar.items():
                kayitlar.append({
                    "il": p,
                    "bolum_tr": bolum, "bolum_en": bolum_en,
                    "ad_tr": satir[dz["ad"]], "ad_en": en_s[dz["ad"]],
                    "ek_tr": satir[dz["ek"]] if dz["ek"] is not None else None,
                    "ek_en": en_s[dz["ek"]] if dz["ek"] is not None else None,
                    "aciklama_basligi_tr": baslik[dz["aciklama"]],
                    "aciklama_basligi_en": en_satirlar[0][dz["aciklama"]],
                    "aciklama_tr": satir[dz["aciklama"]], "aciklama_en": en_s[dz["aciklama"]],
                    "vurgu_tr": vurgu,
                    # Bir yazılış bile bulunamadıysa İngilizcede vurgu yok.
                    "vurgu_en": vurgu_en if vurgu_en and all(vurgu_en) else [],
                    "kurum": kurum, "dayanak": dayanak,
                    "il_hucresi_tr": hucre,
                })
    return kayitlar, ist


# ── Hepsi ────────────────────────────────────────────────────────────────

def kayitlar() -> dict:
    dosya, dosya_ist = dosya_kayitlari()
    dizin, dizin_ist = dizin_kayitlari()
    return {"iller": iller(), "dosya": dosya, "dizin": dizin,
            "dosya_ist": dosya_ist, "dizin_ist": dizin_ist}


def _dizgi(s: str | None) -> str:
    if s is None:
        return "null"
    return json.dumps(s, ensure_ascii=False).replace("$", r"\$")


def _liste(xs: list[str]) -> str:
    return "[" + ", ".join(_dizgi(x) for x in xs) + "]"


def dart_kaynagi(k: dict | None = None) -> str:
    """`yz_atlas.g.dart`ın içeriği (dart_uret.py yazar; kural 17 karşılaştırır)."""
    k = k or kayitlar()
    il = k["iller"]
    d = [
        "// ÜRETİLMİŞ DOSYA — ELLE DEĞİŞTİRİLMEZ.",
        "// Kaynak: content/yapay_zeka_dijital_tarim/_raw/il_izgarasi.json,",
        "//         _raw/atlas_kurum_ili.json ve bolumler/NN-*.{tr,en}.md",
        "// Üretici: content/yapay_zeka_dijital_tarim/dart_uret.py (_raw/atlas_uret.py)",
        "//",
        "// Türkiye Dijital Tarım Atlası (atlas turu, 25 Kasım 2026): 81 il ızgara",
        "// haritada, dosyada ve Türkiye dizininde adı geçtiği kayıtlarla. Haber",
        "// kayıtları çalışma anında (yz_atlas_veri.dart). YALNIZ erteli paketten",
        "// içe aktarılır (test/yz_erteli_test.dart).",
        "",
        "/// Izgaranın boyu: 17 sütun × 7 satır; her il bir hücre.",
        f"const int kYzAtlasSutun = {SUTUN};",
        f"const int kYzAtlasSatir = {SATIR};",
        "",
        "class YzAtlasIl {",
        "  const YzAtlasIl(this.plaka, this.ad, this.sutun, this.satir);",
        "  final int plaka;",
        "  final String ad;",
        "",
        "  /// Hücrenin yeri (0'dan; sütun batıdan doğuya, satır kuzeyden güneye).",
        "  final int sutun;",
        "  final int satir;",
        "}",
        "",
        "/// Plaka sırasıyla 81 il.",
        "const List<YzAtlasIl> kYzAtlasIller = [",
    ]
    for p in sorted(il):
        v = il[p]
        d.append(f"  YzAtlasIl({p}, {_dizgi(v['ad'])}, {v['sutun']}, {v['satir']}),")
    d += [
        "];",
        "",
        "/// Metinde aranan adlar → plaka. Türkçe: resmî ad ve yazım çeşidi.",
        "const Map<String, int> kYzAtlasAdlarTr = {",
        *[f"  {_dizgi(a)}: {p}," for a, p in _ad_plaka(False).items()],
        "};",
        "",
        "/// İngilizce metindeki yazılışlar (\"İzmir\", \"Istanbul\", \"Sanliurfa\").",
        "const Map<String, int> kYzAtlasAdlarEn = {",
        *[f"  {_dizgi(a)}: {p}," for a, p in _ad_plaka(True).items()],
        "};",
        "",
        "/// İl adıyla başlayan ama il olmayan sözler (gerekçeleri atlas_uret.py'de).",
        "const List<String> kYzAtlasDislama = [",
        *[f"  {_dizgi(s)}," for s, _ in DISLAMA],
        "];",
        "",
        "/// Dosyada: başlık metninde ilin adı geçen cümle, harfi harfine.",
        "class YzAtlasDosyaKaydi {",
        "  const YzAtlasDosyaKaydi(this.il, this.baslikNo, this.altBaslikTr, this.altBaslikEn, this.tr, this.en);",
        "  final int il;",
        "  final int baslikNo;",
        "",
        "  /// Cümlenin altında durduğu alt başlık (girişteyse null): `?bolum=`.",
        "  final String? altBaslikTr;",
        "  final String? altBaslikEn;",
        "  final String tr;",
        "",
        "  /// Aynı blok sırasındaki İngilizce cümle; bulunamadıysa null ve kayıt",
        "  /// İngilizcede gösterilmez.",
        "  final String? en;",
        "}",
        "",
        "const List<YzAtlasDosyaKaydi> kYzAtlasDosya = [",
    ]
    for r in k["dosya"]:
        d.append(f"  YzAtlasDosyaKaydi({r['il']}, {r['baslik']}, {_dizgi(r['alt_tr'])}, {_dizgi(r['alt_en'])},")
        d.append(f"      {_dizgi(r['tr'])},")
        d.append(f"      {_dizgi(r['en'])}),")
    d += [
        "];",
        "",
        "/// Türkiye dizininde: §25 tablosunun bir satırı, hücreleri harfi harfine.",
        "class YzAtlasDizinKaydi {",
        "  const YzAtlasDizinKaydi(this.il, this.bolumTr, this.bolumEn, this.adTr, this.adEn, this.ekTr,",
        "      this.ekEn, this.aciklamaBasligiTr, this.aciklamaBasligiEn, this.aciklamaTr, this.aciklamaEn,",
        "      this.vurguTr, this.vurguEn);",
        "  final int il;",
        "",
        "  /// Tablonun durduğu alt başlık (\"Girişimler\"): `?bolum=`.",
        "  final String bolumTr;",
        "  final String bolumEn;",
        "  final String adTr;",
        "  final String adEn;",
        "",
        "  /// Adın altındaki hücre (üniversite, \"2012, İzmir\"); yoksa null.",
        "  final String? ekTr;",
        "  final String? ekEn;",
        "",
        "  /// Açıklama hücresi ve sütununun başlığı (\"Ne yapıyor (şirketin kendi",
        "  /// tanımı)\").",
        "  final String aciklamaBasligiTr;",
        "  final String aciklamaBasligiEn;",
        "  final String aciklamaTr;",
        "  final String aciklamaEn;",
        "",
        "  /// Satırı bu ile bağlayan yazılışlar (\"Selçuk\", \"İzmir\"): fosforlu kalem.",
        "  final List<String> vurguTr;",
        "  final List<String> vurguEn;",
        "}",
        "",
        "const List<YzAtlasDizinKaydi> kYzAtlasDizin = [",
    ]
    for r in k["dizin"]:
        d.append(f"  YzAtlasDizinKaydi({r['il']}, {_dizgi(r['bolum_tr'])}, {_dizgi(r['bolum_en'])},")
        d.append(f"      {_dizgi(r['ad_tr'])}, {_dizgi(r['ad_en'])},")
        d.append(f"      {_dizgi(r['ek_tr'])}, {_dizgi(r['ek_en'])},")
        d.append(f"      {_dizgi(r['aciklama_basligi_tr'])}, {_dizgi(r['aciklama_basligi_en'])},")
        d.append(f"      {_dizgi(r['aciklama_tr'])},")
        d.append(f"      {_dizgi(r['aciklama_en'])},")
        d.append(f"      {_liste(r['vurgu_tr'])}, {_liste(r['vurgu_en'])}),")
    d += ["];", ""]
    return "\n".join(d)


def rapor(k: dict | None = None) -> None:
    k = k or kayitlar()
    il = k["iller"]
    di, zi = k["dosya_ist"], k["dizin_ist"]
    sayi: dict[int, list[int]] = {}
    for r in k["dosya"]:
        sayi.setdefault(r["il"], [0, 0])[0] += 1
    for r in k["dizin"]:
        sayi.setdefault(r["il"], [0, 0])[1] += 1
    print(f"Dosyada: {len(k['dosya'])} kayıt · Türkiye dizininde: {len(k['dizin'])} kayıt "
          f"({zi['satir']} tablo satırından) · {len(sayi)} il")
    oran = di["hizalanan"] / di["toplam"] if di["toplam"] else 1.0
    print(f"İngilizce hizalama: {di['hizalanan']}/{di['toplam']} (%{oran * 100:.0f})")
    for x in di["hizalanmayan"]:
        print(f"  · İngilizcede gösterilmeyecek: {x}")
    for x in di["dislanan"]:
        print(f"  · dışlandı: {x}")
    for x in di["tablo"]:
        print(f"  · tablo hücresinde il (cümle değil, sayılmadı): {x}")
    print("İl başına (dosyada + dizinde):")
    for p, (a, b) in sorted(sayi.items(), key=lambda x: (-sum(x[1]), x[0])):
        print(f"  {p:02d} {il[p]['ad']:<15} {a + b:>3}  (dosyada {a}, dizinde {b})")
    print(f"Eşlenemeyen kurumlar ({len(zi['eslenmeyen'])}):")
    for x in zi["eslenmeyen"]:
        print(f"  · {x}")
    for x in zi["ilsiz"]:
        print(f"  · haritada yeri olmayan satır: {x}")
    for x in zi["hatalar"]:
        print(f"  ✗ {x}")


def main() -> int:
    k = kayitlar()
    rapor(k)
    return 1 if k["dizin_ist"]["hatalar"] else 0


if __name__ == "__main__":
    sys.exit(main())
