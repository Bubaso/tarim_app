#!/usr/bin/env python3
"""TİGEM — tasarım künyesinin BÜTÜN sayıları burada ölçülür.

§8.4: "Kontrast bir kez hesaplanır." Bu betik `_ortak/kontrast.py`yi genişletiyor:
Irak dosyasının eklediği Viénot-Mollon renk körlüğü benzetimi burada KÜME
AYRIMINA uygulanıyor, çünkü dizinin dokuzuncu kümesi ilk kez bu dosyada
kuruluyor ve yeni bir rengin eskilerden ayrılıp ayrılmadığı tahminle
bilinemez.

Üç ölçü birden alınır:
  1. WCAG kontrast oranı — okunabilirlik
  2. CIE76 ΔE (Lab) — algısal mesafe; KONTRAST ORANI HUE AYRIMINI ÖLÇMEZ.
     İki renk aynı parlaklıkta ama bambaşka tonda olabilir; kontrast oranı
     1,0 çıkar, göz ise ikisini rahat ayırır. Mevcut sekiz küme zaten böyle:
     Üretici örgütü ile Hayalet arasındaki kontrast oranı 1,01.
  3. Deuteranopi ve protanopi altında ΔE — kırmızı-yeşil ekseni çöktüğünde
     ayrım ne oluyor.

Çalıştırma: python3 kontrast.py
"""
from __future__ import annotations

import math

# ── WCAG ──────────────────────────────────────────────────────────────────
def _lin(c: float) -> float:
    c /= 255
    return c / 12.92 if c <= 0.03928 else ((c + 0.055) / 1.055) ** 2.4


def L(hx: str) -> float:
    hx = hx.lstrip("#")
    r, g, b = (int(hx[i:i + 2], 16) for i in (0, 2, 4))
    return 0.2126 * _lin(r) + 0.7152 * _lin(g) + 0.0722 * _lin(b)


def cr(a: str, b: str) -> float:
    la, lb = L(a), L(b)
    return (max(la, lb) + 0.05) / (min(la, lb) + 0.05)


# ── Lab ve ΔE ─────────────────────────────────────────────────────────────
def _srgb(c: float) -> float:
    c /= 255
    return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4


def lab(hx: str) -> tuple[float, float, float]:
    hx = hx.lstrip("#")
    r, g, b = (_srgb(int(hx[i:i + 2], 16)) for i in (0, 2, 4))
    X = 0.4124 * r + 0.3576 * g + 0.1805 * b
    Y = 0.2126 * r + 0.7152 * g + 0.0722 * b
    Z = 0.0193 * r + 0.1192 * g + 0.9505 * b

    def f(t: float) -> float:
        return t ** (1 / 3) if t > 0.008856 else 7.787 * t + 16 / 116

    fx, fy, fz = f(X / 0.95047), f(Y), f(Z / 1.08883)
    return 116 * fy - 16, 500 * (fx - fy), 200 * (fy - fz)


def dE(a: str, b: str) -> float:
    return math.dist(lab(a), lab(b))


# ── Viénot-Mollon renk körlüğü benzetimi (Irak dosyasından) ───────────────
_LMS = [[17.8824, 43.5161, 4.11935],
        [3.45565, 27.1554, 3.86714],
        [0.0299566, 0.184309, 1.46709]]
_LMS_TERS = [[0.0809444479, -0.130504409, 0.116721066],
             [-0.0102485335, 0.0540193266, -0.113614708],
             [-0.000365296938, -0.00412161469, 0.693511405]]
_KOR = {
    "protanopi": [[0, 1.05118, -0.05116], [0, 1, 0], [0, 0, 1]],
    "deuteranopi": [[1, 0, 0], [0.9513, 0, 0.04315], [0, 0, 1]],
}


def _carp(M, v):
    return [sum(M[i][j] * v[j] for j in range(3)) for i in range(3)]


def benzet(hx: str, tip: str) -> str:
    hx = hx.lstrip("#")
    v = [int(hx[i:i + 2], 16) for i in (0, 2, 4)]
    lms = _carp(_LMS, v)
    lms = _carp(_KOR[tip], lms)
    rgb = _carp(_LMS_TERS, lms)
    return "#" + "".join(f"{max(0, min(255, round(c))):02X}" for c in rgb)


# ── Dizi sabitleri ────────────────────────────────────────────────────────
KAGIT, YUZEY = "#E3E7E5", "#F0F2F0"
MUREKKEP, SESSIZ = "#15191A", "#575F61"
RAY, KURAL = "#C0C6C3", "#767E7C"
KZEMIN, KYUZEY = "#131718", "#1D2325"
KMUREKKEP, KSESSIZ = "#F0F2F0", "#98A1A2"
APP_KREM = "#F6F1E7"

KUMELER = [
    ("Kamu gucu", "#8E2B24", "#E88079"),
    ("Finans", "#1D5B4A", "#6FC3A4"),
    ("Uretici orgutu", "#8A5410", "#E0A54F"),
    ("Piyasa altyapisi", "#2A4E84", "#86ABE8"),
    ("Bilgi", "#58397F", "#B294E6"),
    ("Su-toprak", "#11616B", "#4FC0CB"),
    ("Meslek", "#5F5417", "#C6B457"),
    ("Hayalet", "#5C6264", "#A4ABAD"),
]
YENI = ("Uretim", "#1F5626", "#4CC756")

if __name__ == "__main__":
    print("═══ Kağıt gövde ═══")
    for ad, hx in [("murekkep", MUREKKEP), ("sessiz", SESSIZ), ("ray", RAY),
                   ("cizgiVurgu", KURAL), ("yuzey", YUZEY), ("vurgu", YENI[1])]:
        print(f"  {ad:12} {hx}  kağıt {cr(hx, KAGIT):5.2f}  yüzey {cr(hx, YUZEY):5.2f}")
    print(f"  kağıt ↔ uygulama kremi {APP_KREM}: {cr(KAGIT, APP_KREM):.3f}")

    print("\n═══ Koyu kapak ═══")
    for ad, hx in [("murekkep", KMUREKKEP), ("sessiz", KSESSIZ),
                   ("yuzey", KYUZEY), ("vurgu", YENI[2])]:
        print(f"  {ad:12} {hx}  zemin {cr(hx, KZEMIN):5.2f}")

    print("\n═══ Şerit — ana sayfanın krem zemini ═══")
    for ad, hx in [("murekkep", MUREKKEP), ("vurguKoyu", YENI[1]), ("ikincilKoyu", SESSIZ)]:
        print(f"  {ad:12} {hx}  krem {cr(hx, APP_KREM):5.2f}")
    print(f"  vurgu ↔ uygulamanın yapısal yeşili #2F4B2E: {cr(YENI[1], '#2F4B2E'):.2f}"
          f"   (Hollanda'da çöken desen 1,05; Avustralya'nın ilk hâli 1,03)")

    print("\n═══ DOKUZUNCU KÜME — eskilerden ayrışıyor mu ═══")
    print(f"  {'küme':18} {'ΔE normal':>10} {'ΔE deut.':>9} {'ΔE prot.':>9} {'kontrast':>9}")
    en = []
    for ad, kagit_hx, _ in KUMELER:
        n = dE(YENI[1], kagit_hx)
        d = dE(benzet(YENI[1], "deuteranopi"), benzet(kagit_hx, "deuteranopi"))
        p = dE(benzet(YENI[1], "protanopi"), benzet(kagit_hx, "protanopi"))
        en.append((n, d, p, ad))
        print(f"  {ad:18} {n:10.1f} {d:9.1f} {p:9.1f} {cr(YENI[1], kagit_hx):9.2f}")
    print(f"  → en yakın: normal ΔE {min(e[0] for e in en):.1f} · "
          f"deuteranopi {min(e[1] for e in en):.1f} · protanopi {min(e[2] for e in en):.1f}")

    print("\n═══ TABAN: mevcut sekiz küme zaten ne kadar ayrışıyor ═══")
    cift = []
    for i, (a, ah, _) in enumerate(KUMELER):
        for b, bh, _ in KUMELER[i + 1:]:
            cift.append((dE(ah, bh),
                         dE(benzet(ah, "deuteranopi"), benzet(bh, "deuteranopi")),
                         f"{a} ↔ {b}"))
    cift.sort()
    for n, d, ad in cift[:3]:
        print(f"  {ad:40} ΔE normal {n:5.1f} · deuteranopi {d:5.1f}")
    print(f"  → mevcut TABAN: en küçük normal ΔE {min(c[0] for c in cift):.1f}, "
          f"en küçük deuteranopi ΔE {min(c[1] for c in cift):.1f}")
    print("  SONUÇ: dokuzuncu küme tabanın ÜSTÜNDE. Ama renk tek başına hiçbir "
          "yerde anlam taşımıyor — arşivde küme adı YAZIYLA da duruyor.")

    print("\n═══ Kapak vurgusu, öteki kapak vurgularına karşı ═══")
    kn = min(dE(YENI[2], k) for _, _, k in KUMELER)
    kd = min(dE(benzet(YENI[2], "deuteranopi"), benzet(k, "deuteranopi")) for _, _, k in KUMELER)
    print(f"  {YENI[2]}  koyu zemin kontrastı {cr(YENI[2], KZEMIN):.2f}  "
          f"(mevcut aralık {min(cr(k, KZEMIN) for _, _, k in KUMELER):.2f}–"
          f"{max(cr(k, KZEMIN) for _, _, k in KUMELER):.2f})")
    print(f"  en yakın kapak vurgusundan ΔE: normal {kn:.1f} · deuteranopi {kd:.1f}")
