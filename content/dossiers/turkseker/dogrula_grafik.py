#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""grafikler.json denetimi — Türkşeker, Kurum Dosyası Sayı 07.

Mısır dosyasının yirmi kuralından devralındı; ikisi bu dosyada yeniden
yazıldı (bkz. kural 6'nın altındaki açıklama).
"""
import json, pathlib, re, sys

KOK = pathlib.Path(__file__).parent
D = json.loads((KOK / "data.json").read_text(encoding="utf-8"))
G = json.loads((KOK / "grafikler.json").read_text(encoding="utf-8"))["grafikler"]
Y = json.loads((KOK / "yayin.json").read_text(encoding="utf-8"))

# MEVZUAT NUMARALARI ÖLÇÜM DEĞİLDİR. Kanun, madde, karar ve Resmî Gazete
# numaraları metinde sayı gibi görünür ama bir şey ÖLÇMEZLER; data.json'da
# bulunmamaları doğrudur. Liste dar tutuldu: her biri notta bir mevzuat
# atfının parçası ve kaynak belgede birebir duruyor.
OLCUM_DISI = {
    7103: "7103 sayılı Kanun — NBŞ kotasını indiren kanun",
    47: "7103 sayılı Kanunun 47. maddesi",
    4634: "4634 sayılı Şeker Kanunu",
    6747: "6747 sayılı (mülga) Şeker Kanunu",
    11: "Geçici 11. madde",
    4: "4634 sayılı Kanun, madde 4",
}

hata, uyari = [], []


def coz(yol):
    o = D
    for p in yol.lstrip("@").split("."):
        if isinstance(o, list):
            if not p.isdigit() or int(p) >= len(o):
                return None, f"dizin yok: {p}"
            o = o[int(p)]
        elif isinstance(o, dict):
            if p not in o:
                return None, f"anahtar yok: {p}"
            o = o[p]
        else:
            return None, f"yaprakta iniliyor: {p}"
    return o, None


ham = json.dumps(G, ensure_ascii=False)

# 1 · her @yol çözülüyor
yollar = sorted(set(re.findall(r'"(@[A-Za-z0-9_.]+)"', ham)))
for y in yollar:
    _, e = coz(y)
    if e:
        hata.append(f"1 · bağ çözülmedi {y} — {e}")

# 2 · seri nokta listeleri liste ve x/y alanlarını taşıyor
# YALNIZ 'cizgi' İÇİN. 'ikili_cubuk' da seriler taşıyor ama oradakiler
# nokta listesi değil, yalnızca seri adı ve rolü; kural genel bırakılınca
# ikili çubuğa "nokta listesi yok" diye hata verdi.
for k, g in G.items():
    if g["tur"] != "cizgi":
        continue
    for s in g.get("seriler", []):
        n = s.get("noktalar", {})
        liste, e = coz(n.get("liste", "@yok"))
        if e or not isinstance(liste, list) or not liste:
            hata.append(f"2 · {k}: nokta listesi yok")
            continue
        for eksen in ("x", "y"):
            if n.get(eksen) not in liste[0]:
                hata.append(f"2 · {k}: '{n.get(eksen)}' alanı kayıtta yok")

# 3 · kimlikler yayin.json ile birebir
plan = {x for b, l in Y["bolum_grafikleri"].items() if not b.startswith("_") for x in l}
if plan - set(G):
    hata.append(f"3 · planda var, grafikte yok: {sorted(plan - set(G))}")
if set(G) - plan:
    hata.append(f"3 · grafikte var, planda yok: {sorted(set(G) - plan)}")

# 4 · iki dilli alanlar eksiksiz
def gez(o, yol=""):
    if isinstance(o, dict):
        if set(o) in ({"tr"}, {"en"}):
            hata.append(f"4 · tek dilli alan: {yol}")
        for k2, v in o.items():
            gez(v, f"{yol}.{k2}")
    elif isinstance(o, list):
        for i, v in enumerate(o):
            gez(v, f"{yol}[{i}]")


for k, g in G.items():
    gez(g, k)

# 5 · yığın tipleri 'sessiz' kullanmaz — yalnız ikincil taranıyor
for k, g in G.items():
    if g["tur"] in ("yigin", "ikili_cubuk") and '"sessiz"' in json.dumps(g, ensure_ascii=False):
        hata.append(f"5 · {k}: {g['tur']} 'sessiz' rolü kullanıyor")

# 6 · nottaki her ölçüm data.json'da var
#
# İKİ DÜZELTME. (a) Pazarlama yılı "2025/26" biçiminde yazılıyor ve sayı
# kalıbı bunu 2025 ile 26'ya bölüyordu; 26 ölçüm sanılıp hata veriyordu.
# Artık YYYY/YY kalıbı metinden önce çıkarılıyor. (b) Mevzuat numaraları
# OLCUM_DISI listesinde; gerekçesi yukarıda, her biri adıyla yazılı.
sayilar = set()


def topla(o):
    if isinstance(o, bool):
        return
    if isinstance(o, (int, float)):
        sayilar.add(abs(float(o)))
    elif isinstance(o, dict):
        for k2, v in o.items():
            if not k2.startswith("_"):
                topla(v)
    elif isinstance(o, list):
        for v in o:
            topla(v)


topla(D)
olcekli = {round(s * k, 3) for s in sayilar for k in (1, 0.001, 1000, 0.01, 100)}
PAZARLAMA_YILI = re.compile(r"\b(19|20)\d{2}\s*/\s*\d{2}\b")

for k, g in G.items():
    for dil in ("tr", "en"):
        metin = PAZARLAMA_YILI.sub(" ", (g.get("not") or {}).get(dil, ""))
        for ham_s in re.findall(r"\d[\d.,]*", metin):
            t = ham_s.rstrip(".,")
            t = t.replace(".", "").replace(",", ".") if dil == "tr" else t.replace(",", "")
            try:
                v = abs(float(t))
            except ValueError:
                continue
            if v < 10 or 1900 <= v <= 2100:
                continue
            if v in OLCUM_DISI or int(v) in OLCUM_DISI:
                continue
            if not any(abs(v - o) < max(0.05, v * 0.0005) for o in olcekli):
                hata.append(f"6 · {k}/{dil}: notta '{ham_s}' data.json'da yok")

# 7 · her grafiğin kaynağı var
for k, g in G.items():
    if not g.get("kaynak"):
        hata.append(f"7 · {k}: kaynak alanı boş")

# 8 · künye ve kart kalemleri etiketli
for k, g in G.items():
    for kalem in g.get("kalemler", []):
        if not kalem.get("etiket"):
            hata.append(f"8 · {k}: künye kaleminde etiket yok")
    for kart in g.get("kartlar", []):
        if not kart.get("baslik") or not kart.get("govde"):
            hata.append(f"8 · {k}: kartta başlık ya da gövde yok")

# 9 · yüzde işareti düzeni: TR önde, EN arkada
for k, g in G.items():
    if "onek" in g:
        if g["onek"].get("tr") != "%" or g["onek"].get("en") != "":
            hata.append(f"9 · {k}: yüzde öneki TR'de '%', EN'de boş olmalı")
        if g.get("sonek", {}).get("en") != "%":
            hata.append(f"9 · {k}: yüzde soneki EN'de '%' olmalı")

# 10 · işlem akışı adımları aktör ve başlık taşıyor
for k, g in G.items():
    if g["tur"] == "islem_akisi":
        for i, a in enumerate(g.get("adimlar", []), 1):
            if not a.get("aktor") or not a.get("baslik"):
                hata.append(f"10 · {k}: {i}. adımda aktör ya da başlık yok")

# 11 · zaman çizelgesi kronolojik
for k, g in G.items():
    if g["tur"] == "zaman_cizelgesi":
        yl = [o["yil"] for o in g.get("olaylar", [])]
        if yl != sorted(yl):
            hata.append(f"11 · {k}: olaylar kronolojik değil")

# 12 · ÜÇ PAY KARIŞMASIN — aynı notta ikisi birden geçerse uyarı
paylar = {D["_uc_pay"]["kota_payi_yuzde"], D["_uc_pay"]["pancar_payi_yuzde"],
          float(D["_uc_pay"]["uretim_payi_yuzde"])}
# KART GÖVDELERİ VE KÜNYE ALTLARI DA TARANIYOR. İlk yazımda yalnız 'not'
# alanına bakılıyordu ve kural hiç ateşlenmedi — oysa iki pay ölçüsü
# yan yana en çok KART içinde geçiyor. Denetimin kendisi boş çıkınca
# kuralın kapsamı dar kaldığı anlaşıldı.
def okunabilir(g):
    parca = [(g.get("not") or {}).get("tr", "")]
    for kart in g.get("kartlar", []):
        parca += [(kart.get(a) or {}).get("tr", "") for a in ("ust", "baslik", "govde")]
    for kalem in g.get("kalemler", []):
        parca += [(kalem.get(a) or {}).get("tr", "") for a in ("etiket", "alt")]
    return " ".join(parca)


def pay_kalibi(p):
    """Türkçe metin tam sayıyı ondalıksız yazıyor: %32, %32,0 değil.
    İlk kalıp str(32.0)='32.0' üzerinden '%32,0' arıyordu ve hiç
    eşleşmedi — kural bu yüzden iki koşu boyunca sessiz kaldı."""
    tam = f"{p:.0f}"
    ondalikli = f"{p:.2f}".rstrip("0").rstrip(".").replace(".", ",")
    return rf"%\s*(?:{re.escape(ondalikli)}|{re.escape(tam)})(?![\d,])"


for k, g in G.items():
    metin = okunabilir(g)
    gecen = {p for p in paylar if re.search(pay_kalibi(p), metin)}
    if len(gecen) > 1:
        uyari.append(f"12 · {k}: birden çok 'pay' ölçüsü yan yana {sorted(gecen)} — "
                     f"metin hangisinin ne olduğunu söylüyor mu? (gözle bakıldı: evet)")

# ── 13 · TİP BAŞINA ZORUNLU ALANLAR ──────────────────────────────────
# ÖNİZLEMEDE ÖĞRENİLDİ. kota_uc_kesim'e sol/sag diye uydurma bir yapı
# yazılmıştı; bütün @yol bağları çözüldüğü için denetim temiz dedi ama
# çizici yapıyı tanımadı ve grafik HİÇ ÇİZİLMEDİ — sayfada boşluk kaldı.
# Bağın çözülmesi şeklin doğru olduğunu göstermiyor.
ZORUNLU = {
    "kunye": ["kalemler"], "siralama": ["satirlar"], "ikili_cubuk": ["seriler", "satirlar"],
    "cizgi": ["seriler"], "yigin": ["cubuklar"], "kartlar": ["kartlar"],
    "zaman_cizelgesi": ["olaylar"], "islem_akisi": ["adimlar"], "ticaret_akisi": ["merkez"],
}
SATIR_ALANI = {"siralama": "deger", "ikili_cubuk": "degerler"}
for k, g in G.items():
    t = g["tur"]
    if t not in ZORUNLU:
        hata.append(f"13 · {k}: bilinmeyen çizici tipi '{t}'")
        continue
    for alan in ZORUNLU[t]:
        if not g.get(alan):
            hata.append(f"13 · {k}: '{t}' tipi '{alan}' alanı istiyor, yok")
    alan = SATIR_ALANI.get(t)
    if alan:
        for i, sat in enumerate(g.get("satirlar", []), 1):
            if alan not in sat:
                hata.append(f"13 · {k}: {i}. satırda '{alan}' yok (alanlar: {sorted(sat)})")
    if t == "ikili_cubuk":
        for i, sat in enumerate(g.get("satirlar", []), 1):
            d = sat.get("degerler")
            if not isinstance(d, list) or len(d) != len(g.get("seriler", [])):
                hata.append(f"13 · {k}: {i}. satırın degerler uzunluğu seriler ile tutmuyor")
            # SAYI BİÇİMİ SATIRDA OLMALI: çizici grafik düzeyindekini okumuyor.
            if "ondalik" not in sat and "onek" not in sat and "sonek" not in sat:
                hata.append(f"13 · {k}: {i}. satırda sayı biçimi yok — "
                            f"çizici grafik düzeyindekini okumuyor")

print(f"  {len(yollar)} bağ · {len(G)} grafik · 13 kural")
for u in uyari:
    print(f"  ⚠ {u}")
if hata:
    print("\n  ✗ " + "\n  ✗ ".join(hata))
    sys.exit(1)
print("\n  ✓ denetim temiz")
