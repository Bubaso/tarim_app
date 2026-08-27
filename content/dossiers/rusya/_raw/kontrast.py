#!/usr/bin/env python3
"""Rusya paleti "Kara Toprak ve Kırağı" — WCAG 2.1 kontrast denetimi.

tasarim.json'daki her kontrast iddiası buradan geliyor. Palet değişirse önce bu
betik çalıştırılır, sonra tasarim.json güncellenir.

    python3 content/dossiers/rusya/_raw/kontrast.py
"""
import sys


def lin(c):
    c = c / 255
    return c / 12.92 if c <= 0.03928 else ((c + 0.055) / 1.055) ** 2.4


def L(hx):
    hx = hx.lstrip("#")
    r, g, b = (int(hx[i:i + 2], 16) for i in (0, 2, 4))
    return 0.2126 * lin(r) + 0.7152 * lin(g) + 0.0722 * lin(b)


def cr(a, b):
    la, lb = L(a), L(b)
    return (max(la, lb) + 0.05) / (min(la, lb) + 0.05)


# ── koyu dosya sayfası — kanonik palet ───────────────────────────────────────
P = {
    "zemin":      "#14110D",  # çernozyom — sıcak, mavi değil
    "yuzey":      "#221C15",
    "murekkep":   "#EFE9DF",
    "sessiz":     "#ADA492",
    "vurgu":      "#E8B94E",  # bozkır otu — toprağı yapan şey
    "ikincil":    "#6BA5BA",  # kırağı — Türkiye serisi
    "cizgi":      "#302921",
    "cizgiVurgu": "#6E6353",
}

# ── ana sayfa şeridi açık modda yaşıyor ──────────────────────────────────────
A = {
    "murekkep":    "#1B1710",
    "vurguKoyu":   "#7A5306",
    "ikincilKoyu": "#1C5566",
}
KREM = "#F6F1E7"
BEYAZ = "#FFFFFF"

HEDEF = {
    "murekkep": (12.0, None), "sessiz": (4.5, None),
    "vurgu": (4.5, None), "ikincil": (4.5, None),
    "cizgi": (None, 2.0), "cizgiVurgu": (3.0, None),
}

dusen = []
print("=== Koyu sayfa (zemin %s) ===" % P["zemin"])
for ad, hx in P.items():
    if ad in ("zemin",):
        continue
    z, y = cr(hx, P["zemin"]), cr(hx, P["yuzey"])
    alt, ust = HEDEF.get(ad, (None, None))
    bayrak = ""
    if alt and z < alt:
        bayrak, _ = "❌ ALT SINIR %.1f" % alt, dusen.append((ad, z))
    if ust and z > ust:
        bayrak, _ = "❌ ÜST SINIR %.1f" % ust, dusen.append((ad, z))
    print(f"  {ad:12} {hx}  zemin {z:6.2f}  yuzey {y:6.2f}  {bayrak}")

print("\n=== Renk körlüğü: vurgu ve ikincil ayırt edilebilir mi? ===")
lv, li = L(P["vurgu"]), L(P["ikincil"])
oran = max(lv, li) / min(lv, li)
print(f"  vurgu L={lv:.4f}  ikincil L={li:.4f}  parlaklık oranı {oran:.2f}")
if oran < 1.35:
    print("  ❌ Parlaklıklar çok yakın — gri tonda ayrışmazlar.")
    dusen.append(("renk_korlugu", oran))
else:
    print("  ✅ Gri tonda da ayrışıyorlar. Yine de grafiklerde biçim farkı ZORUNLU.")
print("  Not: sarı–mavi çifti, kırmızı–yeşil körlüğünde korunan eksendir;")
print("       Hollanda'nın turuncu–yeşil çiftinden bu açıdan daha güvenli.")

print("\n=== Açık mod şeridi (krem %s) ===" % KREM)
for ad, hx in A.items():
    k, b = cr(hx, KREM), cr(hx, BEYAZ)
    bayrak = "" if k >= 4.5 else "❌ ALT SINIR 4.5"
    if k < 4.5:
        dusen.append((ad, k))
    print(f"  {ad:12} {hx}  krem {k:6.2f}  beyaz {b:6.2f}  {bayrak}")

print("\n=== Koyu paletin vurgusu açık zeminde neden kullanılamaz ===")
print(f"  vurgu {P['vurgu']} krem üstünde {cr(P['vurgu'], KREM):.2f} — AA sınırının altında")
print(f"  ikincil {P['ikincil']} krem üstünde {cr(P['ikincil'], KREM):.2f}")

print()
if dusen:
    print("DÜŞEN:", ", ".join(f"{a} ({b:.2f})" for a, b in dusen))
    sys.exit(1)
print("Palet temiz.")
