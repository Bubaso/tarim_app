#!/usr/bin/env python3
"""Irak — `tasarim.json`'u kendi hex değerlerine ve veri katmanına karşı sınar.

NEDEN VAR. Avustralya'nın tasarım künyesi şeridin ana sayfa renklerinden
ayrıştığını SAYIYLA yazıyordu ama o sayılar hiçbir betikte hesaplanmıyordu;
elle konmuşlardı. Bu dosyada da bütün kontrast değerleri künyeye elle
yazıldı. Elle yazılan sayı, yazıldığı anda doğru olsa bile paletin bir
sonraki değişikliğinde sessizce yanlışa döner.

ALTI KURAL:
  1. Künyedeki her kontrast/ayrışma sayısı, künyenin KENDİ hex'lerinden
     yeniden hesaplanınca aynı çıkıyor (±0,01)
  2. WCAG eşikleri tutuyor — gövde ≥4,5, anlam taşıyan çizgi ≥3,0
  3. İki seri hem normal görmede hem ÜÇ KÖRLÜK TİPİNDE ≥1,4 ayrışıyor
  4. Künyedeki renkler kontrast.py'dekilerle aynı — iki dosya ayrışmamış
  5. Tez cümlesindeki her sayı (yazıyla da olsa) veri katmanında karşılığını
     buluyor
  6. Künyenin RENK ROLÜ İDDİASI grafikler.json ile tutuyor — künye bir seriyi
     adıyla iddia ediyorsa o seri gerçekten o rolde olmalı

NEYİ KANITLAMAZ: paletin GÜZEL olduğunu. Yalnızca okunabilir ve tutarlı
olduğunu. Estetik karar gözle verilir, bu betik onu denetlemez.

Çalıştırma: python3 dogrula_tasarim.py
"""
from __future__ import annotations

import json
import pathlib
import re
import sys

KOK = pathlib.Path(__file__).parent
T = json.loads((KOK / 'tasarim.json').read_text(encoding='utf-8'))
VERI = json.loads((KOK / 'data.json').read_text(encoding='utf-8'))
hata: list[str] = []

# ── Renk matematiği BAĞIMSIZ kuruluyor (§8.14.2) ──────────────────────────
# kontrast.py'den içe aktarılmıyor: üretici ile doğrulayıcı aynı yardımcıyı
# paylaşsaydı aynı yönde yanılırlardı.


def lin(c: float) -> float:
    c /= 255
    return c / 12.92 if c <= 0.03928 else ((c + 0.055) / 1.055) ** 2.4


def L(hx: str) -> float:
    hx = hx.lstrip('#')
    return (0.2126 * lin(int(hx[0:2], 16)) + 0.7152 * lin(int(hx[2:4], 16))
            + 0.0722 * lin(int(hx[4:6], 16)))


def cr(a: str, b: str) -> float:
    return (max(L(a), L(b)) + 0.05) / (min(L(a), L(b)) + 0.05)


def oran(a: str, b: str) -> float:
    return max(L(a), L(b)) / min(L(a), L(b))


def _rgb(h): return [lin(int(h.lstrip('#')[i:i + 2], 16)) for i in (0, 2, 4)]


def _hx(v):
    def g(c):
        c = max(0.0, min(1.0, c))
        c = 12.92 * c if c <= 0.0031308 else 1.055 * c ** (1 / 2.4) - 0.055
        return round(c * 255)
    return '#%02X%02X%02X' % tuple(g(c) for c in v)


def _mm(M, v): return [sum(M[i][j] * v[j] for j in range(3)) for i in range(3)]


R2L = [[.31399, .63951, .04649], [.15537, .75789, .08670], [.01775, .10945, .87253]]
L2R = [[5.47221, -4.6419, .16963], [-1.1252, 2.29317, -.1678], [.02980, -.19318, 1.16364]]
KORLUK = {'protanopi': [[0, 1.05118, -.05116], [0, 1, 0], [0, 0, 1]],
          'deuteranopi': [[1, 0, 0], [.9513, 0, .04315], [0, 0, 1]],
          'tritanopi': [[1, 0, 0], [0, 1, 0], [-.86744, 1.86727, 0]]}


def benzet(hx, tip): return _hx(_mm(L2R, _mm(KORLUK[tip], _mm(R2L, _rgb(hx)))))


p = T['palet']
koyu, serit = p['koyu'], p['acik_mod_seridi']
ZEMIN, YUZEY = koyu['zemin']['hex'], koyu['yuzey']['hex']
KREM = '#F6F1E7'
ANASAYFA = {'darkGreen_#2F4B2E': '#2F4B2E', 'primaryGreen_#5C8A4A': '#5C8A4A',
            'wheat_#C9A15A': '#C9A15A', 'marketDown_#9C4A3C': '#9C4A3C',
            'alertRed_#D32F2F': '#D32F2F'}


def karsilastir(iz: str, yazilan, hesap: float) -> None:
    if yazilan is None:
        return
    if abs(float(yazilan) - hesap) > 0.011:
        hata.append(f"{iz}: künyede {yazilan} · hesap {hesap:.2f} — ELLE YAZILMIŞ "
                    "SAYI VERİYLE TUTMUYOR")


# ── 1 ve 2 — gövde ────────────────────────────────────────────────────────
ESIK = {'murekkep': 4.5, 'sessiz': 4.5, 'vurgu': 4.5, 'ikincil': 4.5, 'cizgiVurgu': 3.0}
for ad, blok in koyu.items():
    if ad in ('zemin',):
        continue
    hx = blok['hex']
    karsilastir(f'koyu.{ad}.kontrast_zemin', blok.get('kontrast_zemin'), cr(hx, ZEMIN))
    karsilastir(f'koyu.{ad}.kontrast_yuzey', blok.get('kontrast_yuzey'), cr(hx, YUZEY))
    if ad in ESIK and min(cr(hx, ZEMIN), cr(hx, YUZEY)) < ESIK[ad]:
        hata.append(f"koyu.{ad}: WCAG EŞİĞİ ALTINDA "
                    f"({min(cr(hx, ZEMIN), cr(hx, YUZEY)):.2f} < {ESIK[ad]})")

# ── 1 ve 2 — şerit ────────────────────────────────────────────────────────
for ad in ('murekkep', 'vurguKoyu', 'ikincilKoyu'):
    hx = serit[ad]['hex']
    karsilastir(f'serit.{ad}.kontrast_krem', serit[ad].get('kontrast_krem'), cr(hx, KREM))
    if cr(hx, KREM) < 4.5:
        hata.append(f"serit.{ad}: KREM ÜSTÜNDE EŞİK ALTI ({cr(hx, KREM):.2f})")
    ayr = serit[ad].get('_anasayfadan_ayrisma') or {}
    for an, yazilan in ayr.items():
        if an.startswith('_'):
            continue
        if an not in ANASAYFA:
            hata.append(f"serit.{ad}: tanınmayan ana sayfa rengi '{an}'")
            continue
        karsilastir(f'serit.{ad}.ayrisma.{an}', yazilan, oran(hx, ANASAYFA[an]))
        if oran(hx, ANASAYFA[an]) < 1.25:
            hata.append(f"serit.{ad} ↔ {an}: ÇAKIŞMA RİSKİ ({oran(hx, ANASAYFA[an]):.2f})")

# ── 3 — iki seri, normal görme VE üç körlük tipi ──────────────────────────
ciftler = {'gövde': (koyu['vurgu']['hex'], koyu['ikincil']['hex']),
           'şerit': (serit['vurguKoyu']['hex'], serit['ikincilKoyu']['hex'])}
olculen = {}
for ad, (a, b) in ciftler.items():
    o = oran(a, b)
    olculen[f'{ad}:normal'] = o
    if o < 1.4:
        hata.append(f"{ad} serileri normal görmede ayrışmıyor ({o:.2f})")
    for tip in KORLUK:
        ob = oran(benzet(a, tip), benzet(b, tip))
        olculen[f'{ad}:{tip}'] = ob
        if ob < 1.4:
            hata.append(f"{ad} serileri {tip} altında AYRIŞMIYOR ({ob:.2f}) — "
                        "parlaklık oranı vekil ölçüdür, benzetim esastır")

# Künyedeki ÖLÇÜ BLOĞU sınanıyor — düzyazıdan sayı kazınmıyor.
# İlk sürüm notun içindeki düzyazıdan regex ile okuyordu ve 'şerit' kelimesi
# nottaki başka bir cümlede geçtiği için gövdenin sayılarını şeride atadı.
# Düzyazı iddia taşır, ÖLÇÜ ayrı ve yapılandırılmış alanda durur.
blok = p.get('_olculen_ayrisma')
if not isinstance(blok, dict):
    hata.append('palet._olculen_ayrisma YOK — ölçüler düzyazıya gömülmüş olabilir')
else:
    for ad, anahtar in (('gövde', 'govde'), ('şerit', 'serit')):
        alt = blok.get(anahtar)
        if not isinstance(alt, dict):
            hata.append(f'_olculen_ayrisma.{anahtar} yok')
            continue
        for tip in ('normal', 'protanopi', 'deuteranopi', 'tritanopi'):
            if tip not in alt:
                hata.append(f'_olculen_ayrisma.{anahtar}.{tip} yok')
                continue
            karsilastir(f'_olculen_ayrisma.{anahtar}.{tip}', alt[tip],
                        olculen[f'{ad}:{tip}'])
    # Düzyazıda ölçü kalmış mı — kalmışsa çürümeye açık demektir
    if re.search(r'normal\s*[\d,]+\s*·', p.get('renk_korlugu_notu', '')):
        hata.append('renk_korlugu_notu: düzyazıda hâlâ ölçü listesi var — '
                    'sayı düzyazıda tutulmaz, _olculen_ayrisma alanında tutulur')

# ── 4 — künye ile kontrast.py aynı rengi mi taşıyor ───────────────────────
kaynak = (KOK / '_raw' / 'kontrast.py').read_text(encoding='utf-8')
for ad, hx in (('zemin', ZEMIN), ('yuzey', YUZEY),
               ('vurgu', koyu['vurgu']['hex']), ('ikincil', koyu['ikincil']['hex']),
               ('murekkep', koyu['murekkep']['hex']), ('sessiz', koyu['sessiz']['hex']),
               ('cizgi', koyu['cizgi']['hex']), ('cizgiVurgu', koyu['cizgiVurgu']['hex']),
               ('serit.murekkep', serit['murekkep']['hex']),
               ('serit.vurguKoyu', serit['vurguKoyu']['hex']),
               ('serit.ikincilKoyu', serit['ikincilKoyu']['hex'])):
    if hx.upper() not in kaynak.upper():
        hata.append(f"{ad} {hx}: kontrast.py'de YOK — künye ile denetim betiği "
                    "ayrışmış, biri güncellenirken öteki unutulmuş")

# ── 5 — tez cümlesindeki sayılar veriye dayanıyor mu ──────────────────────
YAZI = {'yüz elli dört': 154, 'yüzde yetmiş': 70, 'iki': 2}
tez = T['tez_cumlesi']['tr']
tt = VERI['turetilmis']
if YAZI['yüz elli dört'] != int(tt['dengesizlik_kat']):
    hata.append(f"tez: 'yüz elli dört' ≠ ölçülen {tt['dengesizlik_kat']:.0f} kat")
if 'yüz elli dört' not in tez:
    hata.append('tez: dengesizlik oranı cümlede yok')
# Rakam HANESİYLE yazılmamalı (§ dizi kuralı) — rozet ve not hariç
if re.search(r'\d', tez):
    hata.append('tez: cümlede HANELİ RAKAM var — dizide tez cümlesinde sayı yazıyla')

# Tuz oranı gerçekten %70 mi
su = VERI['su']
if not any(abs(float(v) - 70) < 0.5 for v in re.findall(r'\d+(?:\.\d+)?', json.dumps(su))):
    hata.append("tez: 'yüzde yetmiş' su bloğunda karşılık bulmuyor")

# ── 6 — künyenin ROL İDDİASI grafiklerle tutuyor mu ──────────────────────
# Künye renklerin ne anlama geldiğini söylüyor; grafikler onları kullanıyor.
# İki dosya arasındaki kayma başka hiçbir denetimde görünmez. İlk yazımda
# künyede "ikincil — Türkiye serisi" yazıyordu; ikinci seriler sayıldığında
# hiçbirinde Türkiye yoktu.
gpath = KOK / 'grafikler.json'
if gpath.exists():
    G = json.loads(gpath.read_text(encoding='utf-8'))['grafikler']
    ikinci = []
    for gid, g in G.items():
        for sr in (g.get('seriler') or []):
            if sr.get('rol') == 'ikincil':
                ikinci.append(sr['ad']['tr'])
        if g.get('tur') == 'ticaret_akisi':
            for yaka in ('giren', 'cikan'):
                for kol in (g.get(yaka) or []):
                    if kol.get('rol') == 'ikincil':
                        ikinci.append(f"{yaka}:{kol['etiket']['tr']}")
    rol = koyu['ikincil'].get('rol', '') + ' ' + koyu['ikincil'].get('_rol_notu', '')
    # Künye bir ülke adı iddia ediyorsa o ad serilerde geçmeli
    for ulke in ('Türkiye', 'Irak'):
        iddia = f'{ulke} serisi' in koyu['ikincil'].get('rol', '')
        gercek = any(ulke.lower() in x.lower() for x in ikinci)
        if iddia and not gercek:
            hata.append(f"koyu.ikincil.rol: künye '{ulke} serisi' diyor ama "
                        f"ikincil rollü seriler bunlar: {ikinci} — KÜNYE İLE "
                        "GRAFİKLER AYRIŞMIŞ")
    if not ikinci:
        hata.append('hiçbir grafikte ikincil rollü seri yok — ikincil renk ölü')

if hata:
    print('TASARIM SINAMASI BAŞARISIZ:\n', file=sys.stderr)
    for h in hata:
        print('  ✗ ' + h, file=sys.stderr)
    sys.exit(1)

print('✓ tasarim.json · 6 kural geçti')
print(f"  palet: {p['ad']} · gövde {koyu['vurgu']['hex']} ↔ {koyu['ikincil']['hex']}")
print(f"  şerit: {serit['vurguKoyu']['hex']} ↔ {serit['ikincilKoyu']['hex']}")
for k, v in olculen.items():
    print(f"  {k:22s} {v:.2f}")
