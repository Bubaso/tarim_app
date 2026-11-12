#!/usr/bin/env python3
"""Mısır — `tasarim.json`'u kendi hex değerlerine ve veri katmanına karşı sınar.

NEDEN VAR. Avustralya'nın tasarım künyesi şeridin ana sayfa renklerinden
ayrıştığını SAYIYLA yazıyordu ama o sayılar hiçbir betikte hesaplanmıyordu.
Bu künye _raw/kontrast.py'nin çıktısından ÜRETİLDİ, ama üretildiği an doğru
olan sayı paletin bir sonraki değişikliğinde sessizce yanlışa döner.

DOKUZ KURAL — ilk altısı Irak dosyasından devralındı:
  1. Künyedeki her kontrast/ayrışma sayısı, künyenin KENDİ hex'lerinden
     yeniden hesaplanınca aynı çıkıyor (±0,011)
  2. WCAG eşikleri tutuyor — gövde ≥4,5, anlam taşıyan çizgi ≥3,0
  3. İki seri hem normal görmede hem ÜÇ KÖRLÜK TİPİNDE ≥1,4 ayrışıyor
  4. Künyedeki renkler kontrast.py'dekilerle aynı — iki dosya ayrışmamış
  5. Tez cümlesindeki her sayı veri katmanında karşılığını buluyor
  6. Künyenin RENK ROLÜ İDDİASI grafikler.json ile tutuyor
  7. VURGU GÖVDE METNİNDEN AYRIŞIYOR (≥1,4). Bu dosyada eklendi: vurgu
     cümlenin içinde rakam rengi, mürekkebe yakınsa vurgu olmaktan çıkar
  8. DURDURMAYAN ÖLÇÜMÜN GEREKÇESİ HÂLÂ GEÇERLİ. Künye vurgu↔sessiz ve
     ikincil↔sessiz çiftlerini "ölçüldü ama durdurmuyor" diye ayırıyor ve
     gerekçesi şu: o çiftler eşiğin altında. Palet değişip çift eşiği
     GEÇERSE gerekçe çürür ve istisna kaldırılmalı — künyede ölü bir
     muafiyet kalmasın
  9. SESSİZ YIĞILMIŞ TÜRDE SERİ DEĞİL. Künye bunu iddia ediyor; iddia
     grafikler.json'a karşı sınanıyor. İki dosyadan biri değişirse öteki
     yanlış bir cümle taşır

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
MUREKKEP = koyu['murekkep']['hex']
KREM = '#F6F1E7'
ANASAYFA = {'darkGreen_#2F4B2E': '#2F4B2E', 'primaryGreen_#5C8A4A': '#5C8A4A',
            'wheat_#C9A15A': '#C9A15A', 'marketDown_#9C4A3C': '#9C4A3C',
            'alertRed_#D32F2F': '#D32F2F'}


def karsilastir(iz: str, yazilan, hesap: float) -> None:
    if yazilan is None:
        return
    if abs(float(yazilan) - hesap) > 0.011:
        hata.append(f"{iz}: künyede {yazilan} · hesap {hesap:.2f} — YAZILMIŞ "
                    "SAYI PALETLE TUTMUYOR")


# ── 1, 2 ve 7 — gövde ─────────────────────────────────────────────────────
ESIK = {'murekkep': 4.5, 'sessiz': 4.5, 'vurgu': 4.5, 'ikincil': 4.5, 'cizgiVurgu': 3.0}
for ad, blok in koyu.items():
    if ad == 'zemin':
        continue
    hx = blok['hex']
    karsilastir(f'koyu.{ad}.kontrast_zemin', blok.get('kontrast_zemin'), cr(hx, ZEMIN))
    karsilastir(f'koyu.{ad}.kontrast_yuzey', blok.get('kontrast_yuzey'), cr(hx, YUZEY))
    karsilastir(f'koyu.{ad}.kontrast_murekkep', blok.get('kontrast_murekkep'),
                oran(hx, MUREKKEP))
    if ad in ESIK and min(cr(hx, ZEMIN), cr(hx, YUZEY)) < ESIK[ad]:
        hata.append(f"koyu.{ad}: WCAG EŞİĞİ ALTINDA "
                    f"({min(cr(hx, ZEMIN), cr(hx, YUZEY)):.2f} < {ESIK[ad]})")

# 7 — vurgu gövde metninden ayrışıyor
vm = oran(koyu['vurgu']['hex'], MUREKKEP)
if vm < 1.4:
    hata.append(f"vurgu ↔ mürekkep {vm:.2f} — vurgu cümlenin içinde vurgu "
                "olmaktan çıkar (eşik 1,4)")

# ── 1 ve 2 — şerit ────────────────────────────────────────────────────────
S_MUREKKEP = serit['murekkep']['hex']
for ad in ('murekkep', 'vurguKoyu', 'ikincilKoyu'):
    hx = serit[ad]['hex']
    karsilastir(f'serit.{ad}.kontrast_krem', serit[ad].get('kontrast_krem'), cr(hx, KREM))
    karsilastir(f'serit.{ad}.kontrast_serit_murekkebi',
                serit[ad].get('kontrast_serit_murekkebi'), oran(hx, S_MUREKKEP))
    if cr(hx, KREM) < 4.5:
        hata.append(f"serit.{ad}: KREM ÜSTÜNDE EŞİK ALTI ({cr(hx, KREM):.2f})")
    if ad != 'murekkep' and oran(hx, S_MUREKKEP) < 1.4:
        hata.append(f"serit.{ad}: kendi mürekkebinden ayrışmıyor "
                    f"({oran(hx, S_MUREKKEP):.2f})")
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

# ── 3 ve 8 — çiftler ──────────────────────────────────────────────────────
CIFT = {
    'govde': (koyu['vurgu']['hex'], koyu['ikincil']['hex']),
    'serit': (serit['vurguKoyu']['hex'], serit['ikincilKoyu']['hex']),
    'vurgu_sessiz': (koyu['vurgu']['hex'], koyu['sessiz']['hex']),
    'ikincil_sessiz': (koyu['ikincil']['hex'], koyu['sessiz']['hex']),
}
blok = p.get('_olculen_ayrisma')
if not isinstance(blok, dict):
    hata.append('palet._olculen_ayrisma YOK — ölçüler düzyazıya gömülmüş olabilir')
    blok = {}
DURDURAN = set(blok.get('_durduran') or [])
MUAF = set(blok.get('_olculen_ama_durdurmayan') or [])

olculen: dict[str, dict[str, float]] = {}
for ad, (a, b) in CIFT.items():
    olculen[ad] = {'normal': oran(a, b)}
    for tip in KORLUK:
        olculen[ad][tip] = oran(benzet(a, tip), benzet(b, tip))
olculen['vurgu_murekkep'] = {'normal': vm}

for ad, deger in olculen.items():
    yazilan = blok.get(ad)
    if not isinstance(yazilan, dict):
        hata.append(f'_olculen_ayrisma.{ad} yok — ölçüm künyede durmak zorunda')
        continue
    for tip, v in deger.items():
        if tip not in yazilan:
            if ad == 'vurgu_murekkep' and tip != 'normal':
                continue
            hata.append(f'_olculen_ayrisma.{ad}.{tip} yok')
            continue
        karsilastir(f'_olculen_ayrisma.{ad}.{tip}', yazilan[tip], v)
    if ad in DURDURAN and min(deger.values()) < 1.4:
        kotu = min(deger, key=deger.get)
        hata.append(f"{ad}: {kotu} altında AYRIŞMIYOR ({deger[kotu]:.2f}) — "
                    "parlaklık oranı vekil ölçüdür, benzetim esastır")

# 8 — muafiyetin gerekçesi hâlâ geçerli mi
for ad in MUAF:
    if ad not in olculen:
        hata.append(f'_olculen_ama_durdurmayan: tanınmayan çift {ad!r}')
        continue
    if min(olculen[ad].values()) >= 1.4:
        hata.append(f"{ad}: künye bu çifti 'ölçüldü ama durdurmuyor' diye "
                    f"ayırıyor, gerekçesi eşiğin ALTINDA olması. Artık dört "
                    f"koşulda da eşiği geçiyor ({min(olculen[ad].values()):.2f}) "
                    f"— muafiyet ÖLÜ, künyeden kaldırılacak ve durduran "
                    f"listeye alınacak")
if DURDURAN & MUAF:
    hata.append(f'bir çift hem durduran hem muaf listede: {DURDURAN & MUAF}')
if not DURDURAN:
    hata.append('_durduran listesi boş — hiçbir ölçüm durdurmuyor demektir')

# Düzyazıda ölçü listesi kalmış mı
if re.search(r'normal\s*[\d,]+\s*·', p.get('renk_korlugu_notu', '')):
    hata.append('renk_korlugu_notu: düzyazıda hâlâ ölçü listesi var — '
                'sayı düzyazıda tutulmaz, _olculen_ayrisma alanında tutulur')

# ── 4 — künye ile kontrast.py aynı rengi mi taşıyor ───────────────────────
kaynak = (KOK / '_raw' / 'kontrast.py').read_text(encoding='utf-8')
for ad, hx in (('zemin', ZEMIN), ('yuzey', YUZEY), ('murekkep', MUREKKEP),
               ('sessiz', koyu['sessiz']['hex']), ('vurgu', koyu['vurgu']['hex']),
               ('ikincil', koyu['ikincil']['hex']), ('cizgi', koyu['cizgi']['hex']),
               ('cizgiVurgu', koyu['cizgiVurgu']['hex']),
               ('serit.murekkep', S_MUREKKEP),
               ('serit.vurguKoyu', serit['vurguKoyu']['hex']),
               ('serit.ikincilKoyu', serit['ikincilKoyu']['hex'])):
    if hx.upper() not in kaynak.upper():
        hata.append(f"{ad} {hx}: kontrast.py'de YOK — künye ile denetim betiği "
                    "ayrışmış, biri güncellenirken öteki unutulmuş")

# ── 5 — tez cümlesindeki sayılar veriye dayanıyor mu ──────────────────────
tez = T['tez_cumlesi']['tr']
tu, ar, su = VERI['turetilmis'], VERI['arazi'], VERI['su']
BEKLENEN = {
    'arazi payı': f"%{tu['tarim_arazisi_payi_misir']:.2f}".replace('.', ','),
    'su bağımlılığı': f"%{su['disa_bagimlilik_yuzde']:.1f}".replace('.', ','),
    'kişi başına hektar': f"{tu['ha_kisi_misir']:.2f}".replace('.', ','),
    'kişi başına feddan': f"{tu['feddan_kisi_misir']:.2f}".replace('.', ','),
    'Türkiye hektar': f"{tu['ha_kisi_turkiye']:.2f}".replace('.', ','),
    'portakal oranı': f"{tu['oran_portakal']:.2f}".replace('.', ','),
}
for ad, s in BEKLENEN.items():
    if s not in tez:
        hata.append(f"tez: {ad} ({s}) cümlede yok — tez cümlesi veri "
                    "sayfasıyla ayrışmış")
if not re.search(r'\d', tez):
    hata.append('tez: cümlede hiç RAKAM yok — sayılar rakamla yazılıyor '
                '(kullanıcı kararı, 3 Kasım 2026)')
for yaziyla in ('yüzde dört', 'yüzde doksan', 'bir virgül', 'yedi virgül'):
    if yaziyla in tez:
        hata.append(f"tez: '{yaziyla}' YAZIYLA yazılmış — rakamla yazılacak")

# ── 6 ve 9 — künyenin iddiası grafiklerle tutuyor mu ──────────────────────
gpath = KOK / 'grafikler.json'
if gpath.exists():
    G = json.loads(gpath.read_text(encoding='utf-8'))['grafikler']
    ikinci: list[str] = []
    yigilmis_sessiz: list[str] = []
    for gid, g in G.items():
        if gid.startswith('_'):
            continue
        for sr in (g.get('seriler') or []):
            if sr.get('rol') == 'ikincil':
                ikinci.append(sr['ad']['tr'])
            if sr.get('rol') == 'sessiz' and g.get('tur') in ('ikili_cubuk', 'yigin'):
                yigilmis_sessiz.append(f"{gid}:{sr['ad']['tr']}")
        for c in (g.get('cubuklar') or []):
            for dl in (c.get('dilimler') or []):
                if dl.get('rol') == 'ikincil':
                    ikinci.append(dl['ad']['tr'])
                if dl.get('rol') == 'sessiz':
                    yigilmis_sessiz.append(f"{gid}:{dl['ad']['tr']}")
    # 6 — künye bir ülke adı iddia ediyorsa o ad serilerde geçmeli
    for ulke in ('Türkiye', 'Mısır'):
        if f'{ulke} serisi' in koyu['ikincil'].get('rol', ''):
            if not any(ulke.lower() in x.lower() for x in ikinci):
                hata.append(f"koyu.ikincil.rol: künye '{ulke} serisi' diyor ama "
                            f"ikincil rollü seriler bunlar: {ikinci} — KÜNYE "
                            "İLE GRAFİKLER AYRIŞMIŞ")
    if not ikinci:
        hata.append('hiçbir grafikte ikincil rollü seri yok — ikincil renk ölü')
    # 9 — künye sessizin yığılmış türde seri olmadığını iddia ediyor
    iddia = '_rol_siniri' in koyu['sessiz']
    if iddia and yigilmis_sessiz:
        hata.append(f"koyu.sessiz._rol_siniri: künye sessizin yığılmış türde "
                    f"seri OLMADIĞINI yazıyor ama şunlar var: "
                    f"{yigilmis_sessiz} — iddia yanlış")
    if not iddia and not yigilmis_sessiz:
        hata.append('koyu.sessiz._rol_siniri yok ama grafiklerde de kullanım '
                    'yok — sınır yazılmazsa sonraki tur bilmez')

if hata:
    print('TASARIM SINAMASI BAŞARISIZ:\n', file=sys.stderr)
    for h in hata:
        print('  ✗ ' + h, file=sys.stderr)
    sys.exit(1)

print(f"✓ tasarim.json · 9 kural geçti · palet: {p['ad']}")
print(f"  gövde {koyu['vurgu']['hex']} ↔ {koyu['ikincil']['hex']}  ·  "
      f"şerit {serit['vurguKoyu']['hex']} ↔ {serit['ikincilKoyu']['hex']}")
for ad in ('govde', 'serit', 'vurgu_murekkep', 'vurgu_sessiz', 'ikincil_sessiz'):
    d = olculen[ad]
    im = 'DURDURAN' if ad in DURDURAN else 'ölçülü, durdurmuyor'
    print(f"  {ad:16s} " + ' '.join(f'{t[:4]} {v:.2f}' for t, v in d.items())
          + f"   [{im}]")
