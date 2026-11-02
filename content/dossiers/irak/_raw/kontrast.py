#!/usr/bin/env python3
"""Irak — palet kontrast ve renk körlüğü hesabı.

tasarim.json'daki HİÇBİR kontrast sayısı elle yazılmaz; hepsi buradan gelir.
Palet değişirse bu betik yeniden koşar ve tasarim.json güncellenir.
WCAG 2.1: gövde metni ≥ 4,5 · anlam taşıyan çizgi ≥ 3,0.

DEVRALINAN İKİ DERS:
  1. Eşik HEM zeminde HEM yüzeyde sınanır (Avustralya: #6A6354 zeminde 3,19
     ile geçiyor, yüzeyde 2,86 ile geçmiyordu).
  2. İki serinin BAĞIL PARLAKLIK oranı ayrıca sınanır (Hollanda: sodyum
     turuncusu ile cam yeşilinin oranı 1,05'ti, deuteranopi altında ayırt
     edilemiyorlardı). Eşik 1,4.

BU DOSYADA EKLENEN İKİ SINAMA:
  3. ANA SAYFADAN AYRIŞMA. Avustralya'nın künyesi şeridin ana sayfa
     renklerinden ayrıştığını sayıyla yazıyordu ama o sayılar betikte
     HESAPLANMIYORDU, elle konmuştu. Burada hesaplanıyor. İlk palet
     denemesinde nehir koyusu #15526B ile ana sayfanın yapısal yeşili
     #2F4B2E arasında oran 1,24 çıktı — kart sayfanın kendi rengiyle aynı
     ağırlıkta olurdu. Gözle görülmezdi.
  4. RENK KÖRLÜĞÜ BENZETİMİ. Parlaklık oranı bir VEKİL ölçüdür ve
     yanılabiliyor: ikinci şerit denemesi (#1D5587 / #3B1F0C) normal görmede
     1,67 veriyordu — eşiği rahat geçiyor — ama deuteranopi altında 1,34'e
     düşüyordu. Vekile güvenmek yerine üç körlük tipi doğrudan benzetiliyor
     (Viénot-Mollon, LMS düzleminde izdüşüm) ve oran benzetim SONRASINDA
     ölçülüyor.

Çalıştırma: python3 content/dossiers/irak/_raw/kontrast.py
"""


def lin(c):
    c = c / 255
    return c / 12.92 if c <= 0.03928 else ((c + 0.055) / 1.055) ** 2.4


def L(hx):
    hx = hx.lstrip('#')
    r, g, b = (int(hx[i:i + 2], 16) for i in (0, 2, 4))
    return 0.2126 * lin(r) + 0.7152 * lin(g) + 0.0722 * lin(b)


def cr(a, b):
    la, lb = L(a), L(b)
    return (max(la, lb) + 0.05) / (min(la, lb) + 0.05)


def oran(a, b):
    return max(L(a), L(b)) / min(L(a), L(b))


# ── Renk körlüğü benzetimi (Viénot-Mollon) ────────────────────────────────
def _rgb(h):
    h = h.lstrip('#')
    return [lin(int(h[i:i + 2], 16)) for i in (0, 2, 4)]


def _hex(v):
    def g(c):
        c = max(0.0, min(1.0, c))
        c = 12.92 * c if c <= 0.0031308 else 1.055 * c ** (1 / 2.4) - 0.055
        return round(c * 255)
    return '#%02X%02X%02X' % tuple(g(c) for c in v)


def _mm(M, v):
    return [sum(M[i][j] * v[j] for j in range(3)) for i in range(3)]


_R2L = [[.31399, .63951, .04649], [.15537, .75789, .08670], [.01775, .10945, .87253]]
_L2R = [[5.47221, -4.6419, .16963], [-1.1252, 2.29317, -.1678], [.02980, -.19318, 1.16364]]
KORLUK = {
    'protanopi': [[0, 1.05118, -.05116], [0, 1, 0], [0, 0, 1]],
    'deuteranopi': [[1, 0, 0], [.9513, 0, .04315], [0, 0, 1]],
    'tritanopi': [[1, 0, 0], [0, 1, 0], [-.86744, 1.86727, 0]],
}


def benzet(hx, tip):
    return _hex(_mm(_L2R, _mm(KORLUK[tip], _mm(_R2L, _rgb(hx)))))


# ── Koyu gövde: gece, alüvyon ovası ───────────────────────────────────────
ZEMIN, YUZEY = '#12100C', '#1F1A12'
MUREKKEP, SESSIZ = '#EFE8DA', '#A89B84'
VURGU, IKINCIL = '#E3A94A', '#5F93AD'      # hurma amberi · nehir mavisi
CIZGI, CIZGIVURGU = '#2B2418', '#7C7158'

# ── Ana sayfa şeridi: krem zemin ──────────────────────────────────────────
# ŞERİTTE NEHİR ÖNDE, SAYFADA HURMA. Gerekçe ölçülmüş: krem zeminde hurma
# amberinin koyu sürümü ana sayfanın buğday ve marketDown renklerinin
# mahallesine düşüyor ve ancak siyaha yaklaşarak ayrışıyor — o noktada da
# şeridin kendi mürekkebine karışıyor. Nehir mavisi tekerleğin soğuk yarısını
# tek başına kullanıyor. Hangi rengin önde durduğu ZEMİNE bağlı.
KREM, S_MUREKKEP = '#F6F1E7', '#19150F'
S_VURGU, S_IKINCIL = '#1D5587', '#3B1F0C'  # nehir koyusu · hurma koyusu

# ── Ana sayfanın kendi renkleri (lib/core/theme/app_colors.dart) ──────────
ANASAYFA = {
    'darkGreen #2F4B2E': '#2F4B2E',
    'primaryGreen #5C8A4A': '#5C8A4A',
    'wheat #C9A15A': '#C9A15A',
    'marketDown #9C4A3C': '#9C4A3C',
    'alertRed #D32F2F': '#D32F2F',
}

kusur = []

print('=== Koyu gövde ===')
for ad, hx, esik in (('murekkep', MUREKKEP, 4.5), ('sessiz', SESSIZ, 4.5),
                     ('vurgu', VURGU, 4.5), ('ikincil', IKINCIL, 4.5),
                     ('cizgiVurgu', CIZGIVURGU, 3.0),
                     ('cizgi', CIZGI, 0), ('yuzey', YUZEY, 0)):
    z, y = cr(hx, ZEMIN), cr(hx, YUZEY)
    if esik and min(z, y) < esik:
        kusur.append(f'{ad} eşik altı ({min(z, y):.2f} < {esik})')
    im = '' if esik == 0 else ('  ✓' if min(z, y) >= esik else '  ✗ EŞİK ALTI')
    print(f'  {ad:11} {hx}  zemin {z:5.2f}  yuzey {y:5.2f}{im}')


def seri_ayrimi(baslik, a, b, ad_a, ad_b):
    print(f'\n=== {baslik} ===')
    o = oran(a, b)
    print(f'  {ad_a:9} {a}  bağıl parlaklık {L(a):.4f}')
    print(f'  {ad_b:9} {b}  bağıl parlaklık {L(b):.4f}')
    print(f'  normal görme    parlaklık oranı {o:.2f}' + ('  ✓' if o >= 1.4 else '  ✗ ZAYIF'))
    if o < 1.4:
        kusur.append(f'{baslik}: normal görmede zayıf ({o:.2f})')
    # VEKİLE GÜVENİLMEZ — benzetim sonrası yeniden ölçülüyor
    for tip in KORLUK:
        sa, sb = benzet(a, tip), benzet(b, tip)
        ob = oran(sa, sb)
        if ob < 1.4:
            kusur.append(f'{baslik}: {tip} altında ayrışmıyor ({ob:.2f})')
        print(f'  {tip:13}  {sa} {sb}  oran {ob:.2f}'
              + ('  ✓' if ob >= 1.4 else '  ✗ AYRIŞMIYOR'))


seri_ayrimi('Gövde serileri (hurma ↔ nehir)', VURGU, IKINCIL, 'vurgu', 'ikincil')

print('\n=== Şerit (krem zemin) ===')
for ad, hx in (('murekkep', S_MUREKKEP), ('vurguKoyu', S_VURGU),
               ('ikincilKoyu', S_IKINCIL)):
    k = cr(hx, KREM)
    if k < 4.5:
        kusur.append(f'şerit {ad} eşik altı ({k:.2f})')
    print(f'  {ad:12} {hx}  krem {k:5.2f}' + ('  ✓' if k >= 4.5 else '  ✗ EŞİK ALTI'))
for ad, hx in (('vurguKoyu', S_VURGU), ('ikincilKoyu', S_IKINCIL)):
    om = oran(hx, S_MUREKKEP)
    if om < 1.4:
        kusur.append(f'şerit {ad} kendi mürekkebinden ayrışmıyor ({om:.2f})')
    print(f'  {ad:12} ↔ şerit mürekkebi {om:5.2f}' + ('  ✓' if om >= 1.4 else '  ✗ ZAYIF'))

seri_ayrimi('Şerit serileri (nehir ↔ hurma)', S_VURGU, S_IKINCIL, 'vurguKoyu', 'ikincilKoyu')

print('\n=== Ana sayfadan ayrışma ===')
print("  Eşik 1,25 — Hollanda'da çöken çiftin oranı 1,05'ti.")
for ad, hx in (('vurguKoyu', S_VURGU), ('ikincilKoyu', S_IKINCIL)):
    print(f'  {ad}:')
    for an, ahx in ANASAYFA.items():
        r = oran(hx, ahx)
        if r < 1.25:
            kusur.append(f'şerit {ad} ↔ {an} ayrışmıyor ({r:.2f})')
        print(f'     ↔ {an:22} {r:5.2f}' + ('  ✓' if r >= 1.25 else '  ✗ ÇAKIŞMA RİSKİ'))

print()
if kusur:
    print('KUSURLU — palet düzeltilmeden tasarim.json yazılmaz:')
    for k in kusur:
        print('  ✗ ' + k)
    raise SystemExit(1)
print('✓ palet temiz — WCAG eşikleri, ana sayfa ayrımı ve üç körlük tipi geçti')
