#!/usr/bin/env python3
"""
Yapay Zeka ve Dijital Tarım — yazdırılabilir sürüm (karar 60, ○ 26).

    python3 -I yazdir_uret.py <çıktı klasörü>

Her başlık ve teknoloji sayfası için iki dilde duru bir HTML sayfası üretir:
`<çıktı>/<adres>.<dil>.html` (teknoloji sayfası: `teknoloji-<kod>.<dil>.html`).
Sayfa tarayıcının "Yazdır"ıyla kâğıda ya da "PDF olarak kaydet"le PDF'e
döner (A4, kenar boşlukları, sayfa sonunda bölünmeyen görsel ve grafik).
Flutter uygulaması tuvale çizdiği için kendisi düzgün yazdırılamıyor;
çevrimdışı okumak ya da basmak isteyen okur bu sayfayı açıyor.

İçerik uygulamayla aynı kaynaktan: metinler (.md), grafikler (grafikler.json,
tablo karşılığıyla), görseller (gorseller.json; Türkçe sayfada Türkçeye
uyarlanmış kopya ve lejant çevirisi), kaynaklar (bNN_kaynaklar.json ya da
tek_<kod>_kaynaklar.json). Yeni bilgi eklenmez.

OKURA KAPALIYKEN `web/` altına yazılmaz: sayfalar dağıtımla yayına çıkar.
Önizleme için derleme klasörüne (`build/yz_onizleme/yz/yazdir`), açılışta
`web/yz/yazdir`'a üretilir (README "Açılış adımları").
"""
from __future__ import annotations

import html
import json
import re
import sys
from pathlib import Path

BURASI = Path(__file__).resolve().parent
BOLUM = BURASI.parent
BOLUMLER = BOLUM / "bolumler"
TEKNOLOJILER = BOLUM / "teknolojiler"
DEPO = BOLUM.parents[1]
SITE = "https://tarimportali.net"
YOL = "/yapay-zeka-dijital-tarim"

AYLAR = {
    "tr": ["Ocak", "Şubat", "Mart", "Nisan", "Mayıs", "Haziran", "Temmuz", "Ağustos", "Eylül",
           "Ekim", "Kasım", "Aralık"],
    "en": ["January", "February", "March", "April", "May", "June", "July", "August", "September",
           "October", "November", "December"],
}


def tr_buyuk(s: str, dil: str) -> str:
    """Türkçe büyük harf: i → İ, ı → I (ham upper() "İ"yi bozar)."""
    if dil == "tr":
        s = s.replace("i", "İ").replace("ı", "I")
    return s.upper()


def tarih(iso: str, dil: str) -> str:
    m = re.match(r"(\d{4})-(\d{2})-(\d{2})", iso or "")
    if not m:
        return iso or ""
    return f"{int(m.group(3))} {AYLAR[dil][int(m.group(2)) - 1]} {m.group(1)}"


def sayi(deger: float, dil: str) -> str:
    """Grafik değeri: Türkçede ondalık virgül, binlik nokta."""
    v = float(deger)
    metin = f"{v:,.0f}" if v == int(v) else f"{v:,.2f}".rstrip("0").rstrip(".")
    if dil == "tr":
        metin = metin.replace(",", "§").replace(".", ",").replace("§", ".")
    return metin


def satir_ici(metin: str) -> str:
    """**kalın** (rakamlı olan rakam sınıfıyla), *italik*, adresler bağlantı."""
    e = html.escape(metin, quote=False)

    def kalin(m: re.Match) -> str:
        ic = m.group(1)
        return f'<strong class="rakam">{ic}</strong>' if re.search(r"\d", ic) else f"<strong>{ic}</strong>"

    e = re.sub(r"\*\*(.+?)\*\*", kalin, e)
    e = re.sub(r"(?<!\*)\*(?!\*)([^*]+?)\*(?!\*)", r"<em>\1</em>", e)
    e = re.sub(r"(https?://[^\s<>\"]+?)([.,;:)]*)(?=\s|$|<)",
               lambda m: f'<a href="{m.group(1)}">{m.group(1)}</a>{m.group(2)}', e)
    return e


def bloklar(md: str) -> list[tuple[str, object]]:
    """yzAyristir'in Python karşılığı (yazdırma için)."""
    cikti: list[tuple[str, object]] = []
    satirlar = md.replace("\r\n", "\n").split("\n")
    par: list[str] = []

    def kapat():
        if par:
            cikti.append(("p", " ".join(par)))
            par.clear()

    i = 0
    while i < len(satirlar):
        t = satirlar[i].strip()
        if not t:
            kapat(); i += 1
        elif t.startswith("# "):
            kapat(); i += 1
        elif m := re.fullmatch(r"\[\[(grafik|gorsel):([a-z0-9-]+)\]\]", t):
            kapat(); cikti.append((m.group(1), m.group(2))); i += 1
        elif t.startswith("## "):
            kapat(); cikti.append(("h", t[3:].strip())); i += 1
        elif t.startswith("- "):
            kapat()
            ogeler = []
            while i < len(satirlar) and satirlar[i].strip().startswith("- "):
                ogeler.append(satirlar[i].strip()[2:].strip()); i += 1
            cikti.append(("liste", ogeler))
        elif t.startswith("|"):
            kapat()
            tablo = []
            while i < len(satirlar) and satirlar[i].strip().startswith("|"):
                s = satirlar[i].strip()
                if not re.fullmatch(r"\|?\s*:?-{3,}:?\s*(\|\s*:?-{3,}:?\s*)*\|?\s*", s):
                    tablo.append([h.strip() for h in s.strip("|").split("|")])
                i += 1
            cikti.append(("tablo", tablo))
        else:
            par.append(t); i += 1
    kapat()
    return cikti


def grafik_html(g: dict, dil: str) -> str:
    """Grafiğin tablo karşılığı: başlık, satır satır değerler, açıklama, kaynak."""
    diziler = {d["kod"]: d.get(dil, "") for d in g.get("diziler", [])}
    birim = (g.get("birim") or {}).get(dil, "")
    cok_dizi = len(diziler) > 1
    panel = any((n.get("panel") or {}).get(dil) for n in g.get("noktalar", []))
    zaman = g.get("tur") == "zaman"
    bas = []
    if panel:
        bas.append("Panel" if dil == "en" else "Panel")
    bas.append(("Year" if dil == "en" else "Yıl") if zaman else ("Item" if dil == "en" else "Kalem"))
    if cok_dizi:
        bas.append("Series" if dil == "en" else "Dizi")
    bas.append(("Event" if dil == "en" else "Olay") if zaman else
               (("Value" if dil == "en" else "Değer") + (f" ({birim})" if birim else "")))
    satirlar = []
    for n in g.get("noktalar", []):
        h = []
        if panel:
            h.append((n.get("panel") or {}).get(dil, ""))
        kat = (n.get("kategori") or {}).get(dil, "")
        if zaman:
            h.append(str(int(float(n["deger"]))))
            if cok_dizi:
                h.append(diziler.get(n.get("dizi", ""), ""))
            h.append(kat)
        else:
            h.append(kat)
            if cok_dizi:
                h.append(diziler.get(n.get("dizi", ""), ""))
            d = sayi(float(n["deger"]) * float(n.get("carpan", 1)), dil)
            nb = (n.get("birim") or {}).get(dil, "")
            ek = (n.get("ek") or {}).get(dil, "")
            h.append(" ".join(x for x in (n.get("uc", ""), d, nb, ek and f"({ek})") if x))
        satirlar.append(h)
    tablo = "<table><thead><tr>" + "".join(f"<th>{html.escape(x)}</th>" for x in bas) + "</tr></thead><tbody>"
    tablo += "".join("<tr>" + "".join(f"<td>{html.escape(str(x))}</td>" for x in r) + "</tr>" for r in satirlar)
    tablo += "</tbody></table>"
    aciklama = (g.get("aciklama") or {}).get(dil, "")
    kaynak = (g.get("kaynak") or {}).get(dil, "")
    return (f'<figure class="grafik"><figcaption class="grafik-baslik">{html.escape(g["baslik"][dil])}</figcaption>'
            f'{tablo}<p class="kunye">{satir_ici(aciklama)}</p><p class="kaynak">{html.escape(kaynak)}</p></figure>')


def gorsel_html(g: dict, dil: str) -> str:
    dosya = g.get("dosya_tr") if dil == "tr" and g.get("dosya_tr") else g["dosya"]
    adres = "/" + dosya.removeprefix("web/")
    kunye = g["kunye"][dil]
    kaynak = g["kaynak"][dil]
    lejant = (g.get("lejant") or {}).get("tr") if dil == "tr" else None
    return (f'<figure class="gorsel"><img src="{adres}" alt="{html.escape(kunye)}" loading="eager">'
            f'<figcaption><span class="kunye">{html.escape(kunye)}</span>'
            + (f'<span class="lejant">{html.escape(lejant)}</span>' if lejant else "")
            + f'<span class="kaynak">{html.escape(kaynak)}</span></figcaption></figure>')


def kaynaklar_html(kayit_yolu: Path, dil: str) -> str:
    if not kayit_yolu.exists():
        return ""
    k = json.loads(kayit_yolu.read_text(encoding="utf-8"))
    ogeler = []
    for v in (k.get("kaynaklar") or {}).values():
        if not isinstance(v, dict) or not v.get("kunye"):
            continue
        adres = (v.get("adres") or "").split(" ")[0]
        ogeler.append((v["kunye"], adres if adres.startswith("http") else ""))
    if not ogeler:
        return ""
    ogeler.sort(key=lambda x: x[0].lower())
    basl = "Sources" if dil == "en" else "Kaynaklar"
    li = "".join(f"<li>{html.escape(kn)}" + (f' <a href="{html.escape(a)}">{html.escape(a)}</a>' if a else "") + "</li>"
                 for kn, a in ogeler)
    return f'<section class="kaynaklar"><h2>{basl}</h2><ol>{li}</ol></section>'


CSS = """
@font-face{font-family:"YzGovde";src:url("/assets/assets/google_fonts/Newsreader-Regular.ttf") format("truetype")}
@font-face{font-family:"YzBaslik";font-weight:700;src:url("/assets/assets/google_fonts/Outfit-Bold.ttf") format("truetype")}
@font-face{font-family:"YzVeri";font-weight:600;src:url("/assets/assets/google_fonts/IBMPlexMono-SemiBold.ttf") format("truetype")}
@page{size:A4;margin:18mm 17mm 20mm}
:root{--murekkep:#1D2321;--soluk:#5C6662;--makine:#34507A;--cizgi:#D5DBD4;--zemin:#F3F5F1}
*{box-sizing:border-box}
body{margin:0;background:var(--zemin);color:var(--murekkep);font:17.5px/1.6 "YzGovde",Georgia,"Times New Roman",serif}
.arac{position:sticky;top:0;z-index:2;display:flex;gap:12px;align-items:center;justify-content:space-between;
  padding:10px 16px;background:var(--zemin);border-bottom:1px solid var(--cizgi);font:600 13px/1.3 "YzVeri",monospace}
.arac a{color:var(--makine);text-decoration:none}
.arac button{font:600 13px/1 "YzVeri",monospace;color:#fff;background:var(--makine);border:0;border-radius:6px;
  padding:10px 14px;cursor:pointer}
.arac button:focus-visible{outline:3px solid #9DB4D6;outline-offset:2px}
main{max-width:680px;margin:0 auto;padding:28px 24px 48px;background:#fff}
.ust{font:600 11px/1.4 "YzVeri",monospace;letter-spacing:1.1px;color:var(--makine);margin:0 0 6px}
h1{font:700 30px/1.15 "YzBaslik",system-ui,sans-serif;margin:0 0 8px;text-wrap:balance}
.kunye-ust{font:500 12px/1.5 "YzVeri",monospace;color:var(--soluk);margin:0 0 22px}
h2{font:700 19px/1.25 "YzBaslik",system-ui,sans-serif;margin:28px 0 8px;break-after:avoid;text-wrap:balance}
p{margin:0 0 14px}
p.giris{font-size:19px;line-height:1.55}
ul{margin:0 0 16px;padding-left:22px}
li{margin:0 0 6px}
.rakam{font-weight:400;color:var(--makine);font-variant-numeric:lining-nums}
a{color:var(--makine);word-break:break-word}
table{border-collapse:collapse;width:100%;margin:6px 0 18px;font-size:14px;line-height:1.4}
th,td{border-bottom:1px solid var(--cizgi);padding:6px 8px;text-align:left;vertical-align:top}
th{font:600 11px/1.3 "YzVeri",monospace;letter-spacing:.6px;color:var(--makine);background:#EEF2F7}
figure{margin:18px 0 22px;break-inside:avoid}
figure img{display:block;max-width:100%;max-height:118mm;margin:0 auto;object-fit:contain}
figcaption,.kunye,.kaynak,.lejant{display:block;font-size:13.5px;line-height:1.45}
figcaption{margin-top:8px}
.kaynak{font:500 11px/1.4 "YzVeri",monospace;color:var(--soluk);margin-top:4px}
.lejant{color:var(--soluk);margin-top:4px}
.grafik-baslik{font:700 15px/1.3 "YzBaslik",system-ui,sans-serif;margin:0 0 6px}
.grafik table{font-size:13px}
.kaynaklar{margin-top:34px;border-top:1px solid var(--cizgi);padding-top:6px}
.kaynaklar ol{font-size:12.5px;line-height:1.45;padding-left:20px}
.son{margin-top:26px;font:500 11px/1.5 "YzVeri",monospace;color:var(--soluk)}
@media print{
  body{background:#fff;font-size:11pt}
  .arac{display:none}
  main{max-width:none;padding:0}
  h1{font-size:22pt}
  h2{font-size:14pt}
  p.giris{font-size:12.5pt}
  a{color:var(--murekkep)}
}
"""


def sayfa(baslik: str, ust: str, md: str, dil: str, guncellendi: str, adres: str,
          kayit_yolu: Path, grafikler: dict, gorseller: dict) -> str:
    govde = []
    ilk = True
    for tur, x in bloklar(md):
        if tur == "p":
            sinif = ' class="giris"' if ilk else ""
            govde.append(f"<p{sinif}>{satir_ici(x)}</p>")
            ilk = False
        elif tur == "h":
            govde.append(f"<h2>{html.escape(x)}</h2>")
            ilk = False
        elif tur == "liste":
            govde.append("<ul>" + "".join(f"<li>{satir_ici(o)}</li>" for o in x) + "</ul>")
        elif tur == "tablo" and x:
            bas, *gv = x
            t = "<table><thead><tr>" + "".join(f"<th>{html.escape(tr_buyuk(h, dil))}</th>" for h in bas) + "</tr></thead><tbody>"
            t += "".join("<tr>" + "".join(f"<td>{satir_ici(c)}</td>" for c in r) + "</tr>" for r in gv)
            govde.append(t + "</tbody></table>")
        elif tur == "grafik" and x in grafikler:
            govde.append(grafik_html(grafikler[x], dil))
        elif tur == "gorsel" and x in gorseller:
            govde.append(gorsel_html(gorseller[x], dil))
    tam = SITE + adres
    en = dil == "en"
    son = (f"This printable version follows the page at {tam}; last checked against its sources on "
           f"{tarih(guncellendi, 'en')}." if en else
           f"Bu yazdırılabilir sürüm {tam} adresindeki sayfanın metnidir; kaynaklarından son okunduğu gün "
           f"{tarih(guncellendi, 'tr')}.")
    return f"""<!doctype html>
<html lang="{dil}">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="robots" content="noindex">
<link rel="canonical" href="{tam}">
<title>{html.escape(baslik)} · {"AI and Digital Agriculture" if en else "Yapay Zeka ve Dijital Tarım"} · Tarım Portalı</title>
<style>{CSS}</style>
</head>
<body>
<nav class="arac"><a href="{adres}">← {"Back to the page" if en else "Sayfaya dön"}</a>
<button type="button" onclick="window.print()">{"Print or save as PDF" if en else "Yazdır ya da PDF olarak kaydet"}</button></nav>
<main>
<p class="ust">TARIM PORTALI · {html.escape(tr_buyuk(ust, dil))}</p>
<h1>{html.escape(baslik)}</h1>
<p class="kunye-ust">{tam}</p>
{chr(10).join(govde)}
{kaynaklar_html(kayit_yolu, dil)}
<p class="son">{html.escape(son)}</p>
</main>
</body>
</html>
"""


def main() -> int:
    if len(sys.argv) < 2:
        print(__doc__)
        return 2
    cikti = Path(sys.argv[1]).expanduser()
    yayin = json.loads((BOLUM / "yayin.json").read_text(encoding="utf-8"))
    if not yayin.get("okura_acik") and cikti.resolve().is_relative_to((DEPO / "web").resolve()):
        print("✗ okura KAPALI: web/ altına yazılmaz (sayfalar dağıtımla yayına çıkar)")
        return 1
    cikti.mkdir(parents=True, exist_ok=True)
    iskelet = json.loads((BOLUM / "iskelet.json").read_text(encoding="utf-8"))
    katmanlar = iskelet.get("katmanlar", {})
    grafikler = json.loads((BURASI / "grafikler.json").read_text(encoding="utf-8"))["grafikler"]
    gorseller = json.loads((BURASI / "gorseller.json").read_text(encoding="utf-8"))["gorseller"]
    teknolojiler = iskelet.get("teknoloji", {})
    n = 0
    for b in iskelet["basliklar"]:
        no, slug = b["no"], b["slug"]
        for dil in ("tr", "en"):
            yol = next(BOLUMLER.glob(f"{no:02d}-*.{dil}.md"), None)
            if yol is None:
                continue
            md = yol.read_text(encoding="utf-8")
            kayit = BURASI / f"b{no:02d}_kaynaklar.json"
            guncel = json.loads(kayit.read_text(encoding="utf-8")).get("guncellendi", "") if kayit.exists() else ""
            ust = (katmanlar.get(b.get("katman"), {}) or {}).get(dil, b.get("katman", ""))
            ad = (b.get("baslik") or {}).get(dil) or (b.get("baslik") or {}).get("tr", slug)
            (cikti / f"{slug}.{dil}.html").write_text(
                sayfa(ad, ust, md, dil, guncel, f"{YOL}/{slug}", kayit if no not in (29, 30) else Path("-"),
                      grafikler, gorseller), encoding="utf-8")
            n += 1
    for kod in sorted(p.name.split(".")[0] for p in TEKNOLOJILER.glob("*.tr.md")):
        for dil in ("tr", "en"):
            yol = TEKNOLOJILER / f"{kod}.{dil}.md"
            if not yol.exists():
                continue
            kayit = BURASI / f"tek_{kod}_kaynaklar.json"
            guncel = json.loads(kayit.read_text(encoding="utf-8")).get("guncellendi", "") if kayit.exists() else ""
            ad = (teknolojiler.get(kod) or {}).get(dil, kod)
            (cikti / f"teknoloji-{kod}.{dil}.html").write_text(
                sayfa(ad, "Technology" if dil == "en" else "Teknoloji", yol.read_text(encoding="utf-8"), dil,
                      guncel, f"{YOL}/teknoloji/{kod}", kayit, grafikler, gorseller), encoding="utf-8")
            n += 1
    print(f"✓ {n} yazdırılabilir sayfa → {cikti}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
