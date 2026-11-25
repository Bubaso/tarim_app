#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Yedi bölüm çiftini birleştirir: 29 → 22 bölüm.

Kullanıcı kararı (24 Kasım 2026): "4 · Birleştirilebilecek bölümler
başlığında önerdiğin bölümleri birleştir."

BİRLEŞTİRME YAPIŞTIRMA DEĞİL. İki gövdeyi uç uca eklemek, iki bölümün
birbirine bakmadan yazıldığı yerlerde dikiş bırakıyor. İki yerde gerçek
düzeltme gerekti:

  §2+§3 · Hisse senedi İKİ KEZ anlatılıyordu. §2 senedi ayrıntısıyla
          tarif ediyor; §3 "Uşak'ınki bugün elimizde duruyor ve üzerinde
          şirketin adı Osmanlı harfleriyle yazılı" diye tekrar ediyordu.
          Tekrar silindi. Ayrıca §2'nin "bugün Uşak'ta fabrika yok"
          paragrafı bölümün SONUNA alındı: yerinde kalsaydı okur 2025'ten
          1925'e geri sıçrardı.

  §25+§26 · §26'nın kapanışı "geriye kalan yalnız fabrikalar değil: bir
          türbin, kampanyalar ve bir zincir" diye sayıyordu. Rölyef artık
          aynı bölümün içinde; sayıma o da eklendi. Eklenen bilgi yeni
          değil — rölyefin Genel Müdürlük'te sergilendiği §25'te yazılı.

ÖTEKİ BEŞİNDE DİKİŞ ZATEN TUTUYOR. §6 "Kendi fabrikasını kurabilen bir
sanayinin bir sonraki adımı…", §21 "Kendi elektriğini üreten bir fabrikanın
ne anlama geldiği…", §11 §10'un açılış cümlesinin devamı. Bu üçü
birbirine bakarak yazılmıştı; gövdeler olduğu gibi eklendi.

BOŞTA KALAN GÖRSELLER GALERİYE. Her birleşme bir bölüm görselini boşta
bırakıyor; kullanıcının 24 Kasım kuralı: "bulup değiştirdiğin eski
görselleri galeriye taşırsın." Yedisi de `parti: 3` ile galerinin sonuna
gidiyor.
"""
import json
import pathlib
import re
import sys

RAW = pathlib.Path(__file__).parent
KOK = RAW.parent

# (tutulan, eklenen, başlık_tr, başlık_en, tür, boşta kalanın öbeği)
BIRLESME = [
    (2, 3, "İki şirket, iki temel", "Two companies, two foundations",
     "belge", "tarih"),
    (5, 6, "Dörtten otuza, sonra Özbekistan'a",
     "From four to thirty, then Uzbekistan", "anlati", "fabrika_ici"),
    (10, 11, "Tohumdan şekere", "From seed to sugar", "veri", "fabrika_ici"),
    (15, 16, "Bugün: on dört fabrika", "Today: fourteen factories",
     "veri", "fabrikalar"),
    (17, 18, "Kendi tezgâhı, kendi yatırımı",
     "Its own workshop, its own investment", "veri", "fabrikalar"),
    (20, 21, "Fabrikanın kendi elektriği", "The factory's own electricity",
     "veri", "urun"),
    (25, 26, "Bir rölyef, bir türbin", "A relief and a turbine",
     "anlati", "fabrika_ici"),
]

# ── dikiş düzeltmeleri ────────────────────────────────────────────────────
# (bölüm, dil, aranan, konan). Aranan birebir bulunamazsa betik DÜŞÜYOR:
# metin değişmişse düzeltme sessizce atlanmamalı.
DUZELTME = [
    (3, "tr",
     "İki şirketin sermayesi toplamda 1.100.000 lira. İkisi de hisse senedi\n"
     "çıkardı; Uşak'ınki bugün elimizde duruyor ve üzerinde şirketin adı Osmanlı\n"
     "harfleriyle yazılı.",
     "İki şirketin sermayesi toplamda 1.100.000 lira. İkisi de hisse senedi\n"
     "çıkardı."),
    (3, "en",
     "The two companies' capital came to 1,100,000 lira in total. Both issued\n"
     "shares; the Uşak certificate survives, with the company's name set in\n"
     "Ottoman script.",
     "The two companies' capital came to 1,100,000 lira in total. Both issued\n"
     "shares."),
    (26, "tr",
     "hâlâ dönen bir türbin, hâlâ sayılan kampanyalar ve hâlâ aynı kampüste duran\n"
     "bir zincir.",
     "hâlâ dönen bir türbin, hâlâ sayılan kampanyalar, Genel Müdürlük'te asılı\n"
     "duran bir tablo ve hâlâ aynı kampüste duran bir zincir."),
    (26, "en",
     "factories: a turbine still turning, campaigns still being counted, and a\n"
     "chain still standing on the same campus.",
     "factories: a turbine still turning, campaigns still being counted, a panel\n"
     "hanging at the head office, and a chain still standing on the same campus."),
]

# §2'nin son paragrafı birleşmiş bölümün SONUNA taşınıyor.
TASIN_SONA = {
    "tr": "Bugün Uşak'ta pancar şekeri üreten bir fabrika bulunmuyor.",
    "en": "There is no beet sugar factory at Uşak today.",
}


def coz(metin):
    p = re.split(r"^## (\d+)\. (.+)$", metin, flags=re.M)
    bas = p[0]
    return bas, {int(p[i]): [p[i + 1].strip(), p[i + 2].strip()]
                 for i in range(1, len(p), 3)}


def paragraflar(govde):
    return [b.strip() for b in govde.split("\n\n") if b.strip()]


def birlestir(dil, metin):
    bas, B = coz(metin)
    if len(B) != 29:
        sys.exit("✗ %s: %d bölüm, 29 bekleniyordu" % (dil, len(B)))

    for no, d, aranan, konan in DUZELTME:
        if d != dil:
            continue
        if aranan not in B[no][1]:
            sys.exit("✗ %s §%d: düzeltilecek metin bulunamadı" % (dil, no))
        B[no][1] = B[no][1].replace(aranan, konan)

    yeni = {}
    for tutulan, eklenen, bt, be, _tur, _obek in BIRLESME:
        a, b = paragraflar(B[tutulan][1]), paragraflar(B[eklenen][1])
        if tutulan == 2:
            # Uşak'ın bugünü en sona: 1925'e geri sıçramasın.
            son = [p for p in a if p.startswith(TASIN_SONA[dil])]
            if len(son) != 1:
                sys.exit("✗ %s §2: taşınacak paragraf bulunamadı" % dil)
            a = [p for p in a if p not in son]
            govde = a + b + son
        else:
            govde = a + b
        yeni[tutulan] = [bt if dil == "tr" else be, "\n\n".join(govde)]

    emilen = {e for _t, e, *_ in BIRLESME}
    sirali = [n for n in sorted(B) if n not in emilen]
    g = [bas.rstrip() + "\n\n"]
    esleme = {}
    for i, eski in enumerate(sirali, 1):
        baslik, govde = yeni.get(eski, B[eski])
        esleme[eski] = i
        g.append("## %d. %s\n\n%s\n\n" % (i, baslik, govde))
    return "".join(g).rstrip() + "\n", esleme


def main():
    esleme = None
    for ad, dil in (("metin_tr.md", "tr"), ("metin_en.md", "en")):
        p = KOK / ad
        yeni, e = birlestir(dil, p.read_text(encoding="utf-8"))
        if esleme is None:
            esleme = e
        elif esleme != e:
            sys.exit("✗ iki dil farklı eşleme üretti")
        p.write_text(yeni, encoding="utf-8")

    emilen = {e: t for t, e, *_ in BIRLESME}
    tur_yeni = {esleme[t]: tur for t, _e, _bt, _be, tur, _o in BIRLESME}

    # ── yayin.json ───────────────────────────────────────────────────────
    y_yol = KOK / "yayin.json"
    Y = json.loads(y_yol.read_text(encoding="utf-8"))

    def tasi(blok, birlestirici=None):
        out = {k: v for k, v in blok.items() if k.startswith("_")}
        for k, v in blok.items():
            if k.startswith("_"):
                continue
            n = int(k)
            if n in emilen:                 # emilen bölüm: değeri tutulana kat
                if birlestirici is None:
                    continue
                hedef = str(esleme[emilen[n]])
                out[hedef] = birlestirici(out.get(hedef), v)
            else:
                out[str(esleme[n])] = v
        return {k: out[k] for k in sorted(
            out, key=lambda x: (0, 0) if x.startswith("_") else (1, int(x)))}

    def grafik_kat(eski, yeni_deger):
        a = [] if eski is None else (eski if isinstance(eski, list) else [eski])
        b = yeni_deger if isinstance(yeni_deger, list) else [yeni_deger]
        return a + b

    Y["bolum_grafikleri"] = tasi(Y["bolum_grafikleri"], grafik_kat)
    Y["bolum_turleri"] = tasi(Y["bolum_turleri"])
    Y["bolum_turleri"].update({str(k): v for k, v in tur_yeni.items()})
    Y["bolum_turleri"] = {k: Y["bolum_turleri"][k] for k in sorted(
        Y["bolum_turleri"],
        key=lambda x: (0, 0) if x.startswith("_") else (1, int(x)))}

    # Boşta kalan görselleri AYIR, sonra bölüm eşlemesini kaydır.
    bosta = {e: Y["bolum_gorselleri"][str(e)] for e in emilen}
    Y["bolum_gorselleri"] = {k: v for k, v in Y["bolum_gorselleri"].items()
                             if k.startswith("_") or int(k) not in emilen}
    Y["bolum_gorselleri"] = tasi(Y["bolum_gorselleri"])

    TR = (KOK / "metin_tr.md").read_text(encoding="utf-8")
    B = {m.group(1): m.group(2).strip()
         for m in re.finditer(r"^## (\d+)\. (.+)$", TR, flags=re.M)}
    Y["_bolum_basliklari"] = {
        "_notu": Y["_bolum_basliklari"].get("_notu", "Metinden okunuyor."),
        **{k: B[k] for k in sorted(B, key=int)}}
    Y["_birlestirme_notu"] = (
        "24 Kasım 2026, kullanıcı: 'önerdiğin bölümleri birleştir.' Yedi çift "
        "birleşti, 29 → 22 bölüm. Eşleme _raw/birlestir.py/BIRLESME içinde; "
        "dikiş düzeltmeleri DUZELTME içinde. Boşta kalan yedi bölüm görseli "
        "galeriye taşındı.")
    y_yol.write_text(json.dumps(Y, ensure_ascii=False, indent=2),
                     encoding="utf-8")

    # ── kunye.json: bölüm numaraları ─────────────────────────────────────
    ku_yol = RAW / "gorseller" / "kunye.json"
    KU = json.loads(ku_yol.read_text(encoding="utf-8"))
    tasinan_kimlik = {}
    for kimlik, g in list(KU["gorseller"].items()):
        n = int(g["bolum"])
        if n in emilen:
            tasinan_kimlik[n] = kimlik
            KU["gorseller"].pop(kimlik)
        else:
            g["bolum"] = str(esleme[n])
    ku_yol.write_text(json.dumps(KU, ensure_ascii=False, indent=2),
                      encoding="utf-8")

    # ── boşta kalan kareler galeriye (parti 3) ───────────────────────────
    alt_bolum = json.loads((RAW / "altyazilar.json").read_text(encoding="utf-8"))
    sec_yol = RAW / "galeri_secim.json"
    gk_yol = RAW / "gorseller" / "galeri_kunye.json"
    ga_yol = RAW / "galeri_altyazilar.json"
    SEC = json.loads(sec_yol.read_text(encoding="utf-8"))
    GK = json.loads(gk_yol.read_text(encoding="utf-8"))
    GA = json.loads(ga_yol.read_text(encoding="utf-8"))
    obek = {e: o for _t, e, _bt, _be, _tur, o in BIRLESME}
    var = {k["kimlik"] for k in SEC["kareler"]}
    eklenen = 0
    for eski_no, kimlik in sorted(tasinan_kimlik.items()):
        gk = "galeri_%s" % kimlik
        if gk in var:
            continue
        kunye = KU.get("_cikarilan", {}).get(kimlik)
        if kunye is None:
            kunye = bosta_kunye[kimlik]
        a = alt_bolum.get(kimlik)
        if a is None:
            sys.exit("✗ %s altyazısız" % kimlik)
        GK["kareler"][gk] = {
            "adres": None, "asil": None, "sayfa": kunye["sayfa"],
            "mime": "image/jpeg", "nesne_adi": kunye["nesne_adi"],
            "aciklama": kunye["aciklama"], "tarih": kunye.get("tarih"),
            "atif": kunye["atif"], "kredi": kunye["kredi"],
            "lisans": kunye["lisans"], "lisans_adresi": kunye["lisans_adresi"],
            "ad": kunye["ad"], "dosya": kunye["dosya"], "bayt": kunye["bayt"],
            "kaynak_turu": kunye.get("_tur") or "salt",
            "obek": obek[eski_no],
        }
        GA[gk] = {"tr": a["tr"], "en": a["en"],
                  "_dayanak": a["_dayanak"] + " §%d bölüm görseliyken "
                              "bölümler birleşince galeriye taşındı." % eski_no}
        SEC["kareler"].append({"kimlik": gk, "kaynak": GK["kareler"][gk]["kaynak_turu"],
                               "dosya": kunye["ad"], "obek": obek[eski_no],
                               "parti": 3})
        eklenen += 1
    SEC["_parti3"] = (
        "24 Kasım 2026: yedi bölüm çifti birleşti; boşta kalan bölüm "
        "görselleri galerinin sonuna eklendi.")
    sec_yol.write_text(json.dumps(SEC, ensure_ascii=False, indent=2), encoding="utf-8")
    gk_yol.write_text(json.dumps(GK, ensure_ascii=False, indent=2), encoding="utf-8")
    ga_yol.write_text(json.dumps(GA, ensure_ascii=False, indent=2), encoding="utf-8")

    for t, e, bt, _be, tur, _o in BIRLESME:
        print("  §%-2d + §%-2d → §%-2d  %-34s [%s]"
              % (t, e, esleme[t], bt, tur))
    print("\n  ✓ 29 → %d bölüm · %d kare galeriye · galeri %d"
          % (len(B), eklenen, len(SEC["kareler"])))


# Boşta kalan karelerin künyesi kunye.json'dan ÖNCE okunuyor: main()
# içinde satır silindikten sonra erişilemez.
_KU = json.loads((RAW / "gorseller" / "kunye.json").read_text(encoding="utf-8"))
_Y = json.loads((KOK / "yayin.json").read_text(encoding="utf-8"))
bosta_kunye = {}
for _kimlik, _g in _KU["gorseller"].items():
    if int(_g["bolum"]) in {e for _t, e, *_ in BIRLESME}:
        bosta_kunye[_kimlik] = {**_g,
                                "_tur": "kurum" if "turkseker.gov.tr" in (_g.get("sayfa") or "")
                                else ("commons" if "commons.wikimedia.org" in (_g.get("sayfa") or "")
                                      else "salt")}

main()
