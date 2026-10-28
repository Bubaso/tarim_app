#!/usr/bin/env python3
"""Avustralya — palet kontrast hesabı.

tasarim.json'daki HİÇBİR kontrast sayısı elle yazılmaz; hepsi buradan gelir.
Palet değişirse bu betik yeniden koşar ve tasarim.json güncellenir.
WCAG 2.1: gövde metni ≥ 4,5 · anlam taşıyan çizgi ≥ 3,0.

İKİ EŞİK HATASI BU BETİKLE YAKALANDI, gözle yakalanmazdı:
  1. cizgiVurgu ilk seçimi #6A6354 zeminde 3,19 ile geçiyor ama YÜZEYDE
     2,86 ile geçmiyordu. Yalnız zemine bakan bir denetim kaçırırdı.
  2. Şeritteki iki serinin parlaklık oranı ilk hesapta 1,06 çıktı — Hollanda'da
     deuteranopi altında ayırt edilemeyen çiftin oranı 1,05'ti. Teal
     koyulaştırıldı.
"""
def lin(c):
    c = c / 255
    return c / 12.92 if c <= 0.03928 else ((c + 0.055) / 1.055) ** 2.4

def L(hx):
    hx = hx.lstrip("#")
    r, g, b = (int(hx[i:i+2], 16) for i in (0, 2, 4))
    return 0.2126*lin(r) + 0.7152*lin(g) + 0.0722*lin(b)

def cr(a, b):
    la, lb = L(a), L(b)
    hi, lo = max(la, lb), min(la, lb)
    return (hi + 0.05) / (lo + 0.05)

# ── Koyu gövde: gece, sulama bölgesi ────────────────────────────────────
ZEMIN, YUZEY = "#11100D", "#1E1C17"
MUREKKEP, SESSIZ = "#EFEBE1", "#A69D8D"
VURGU, IKINCIL = "#5BC8C0", "#C9763C"      # kanal suyu · kuru toprak
CIZGI, CIZGIVURGU = "#2B2922", "#7A7363"   # ikincisi 3,0'ı YÜZEYDE de geçsin diye açıldı
# ── Ana sayfa şeridi: krem zemin ────────────────────────────────────────
KREM, S_MUREKKEP = "#F6F1E7", "#1A1813"
S_VURGU, S_IKINCIL = "#0B4F4A", "#8A4414"  # teal, parlaklık ayrımı için koyulaştırıldı

print("=== Koyu gövde ===")
for ad, hx, esik in (("murekkep",MUREKKEP,4.5), ("sessiz",SESSIZ,4.5),
                     ("vurgu",VURGU,4.5), ("ikincil",IKINCIL,4.5),
                     ("cizgiVurgu",CIZGIVURGU,3.0), ("cizgi",CIZGI,0), ("yuzey",YUZEY,0)):
    z, y = cr(hx, ZEMIN), cr(hx, YUZEY)
    im = "" if esik == 0 else ("  ✓" if min(z, y) >= esik else "  ✗ EŞİK ALTI")
    print(f"  {ad:11} {hx}  zemin {z:5.2f}  yuzey {y:5.2f}{im}")

print("\n=== İki serinin ayrımı (Hollanda dersi) ===")
lv, li = L(VURGU), L(IKINCIL)
o = max(lv, li) / min(lv, li)
print(f"  vurgu (kanal)   bağıl parlaklık {lv:.4f}")
print(f"  ikincil (toprak) bağıl parlaklık {li:.4f}")
print(f"  parlaklık oranı {o:.2f}" + ("  ✓" if o >= 1.4 else "  ✗ ZAYIF"))

print("\n=== Şerit (krem zemin) ===")
for ad, hx in (("murekkep",S_MUREKKEP), ("vurguKoyu",S_VURGU), ("ikincilKoyu",S_IKINCIL)):
    k = cr(hx, KREM)
    print(f"  {ad:12} {hx}  krem {k:5.2f}" + ("  ✓" if k >= 4.5 else "  ✗ EŞİK ALTI"))
os_ = max(L(S_VURGU), L(S_IKINCIL)) / min(L(S_VURGU), L(S_IKINCIL))
print(f"  şerit parlaklık oranı {os_:.2f}" + ("  ✓" if os_ >= 1.4 else "  ✗ ZAYIF"))
