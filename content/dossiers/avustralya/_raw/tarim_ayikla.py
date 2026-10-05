#!/usr/bin/env python3
"""ABS ve OECD ham dosyalarından tarım verisini çıkarır.

KAYNAKLAR
  abs_tarla_bitkileri.csv  ABS, AG_BROADACRE — ürün bazında alan/üretim/değer/işletme
  abs_hayvan_kesim.csv     ABS, LSTOCK_SLAUGHT — 1965'ten beri ÇEYREKLİK
  oecd_destek_pse.csv      OECD, Üretici Destek Tahmini

ÜÇ TUZAK, üçü de koda yazılı:
1. ABS'in bölge kodu 'AUS' ulusal toplamdır; eyalet kodlarıyla toplanırsa
   çift sayım olur. Yalnız 'AUS' alınıyor ve bunun gerçekten en büyük
   olduğu sınanıyor.
2. LSTOCK_SLAUGHT'ta UNIT_MULT=3, yani değerler BİNDİR. Çarpan okunmazsa
   on sekiz milyonluk sürü on sekiz bin görünür.
3. Çeyreklik seri yıla toplanırken TAMAMLANMAMIŞ yıl dışarıda bırakılıyor;
   yoksa son yıl yapay olarak düşük çıkar ve 'düşüş' sanılır.
"""
import collections, csv, json, pathlib, re, sys

KD = pathlib.Path('kaynak_dosyalari')
hata = []
oku = lambda ad: list(csv.DictReader((KD / ad).open(encoding='utf-8')))

# ══ 1. Tarla bitkileri ═══════════════════════════════════════════════════
r = oku('abs_tarla_bitkileri.csv')
alan = collections.defaultdict(lambda: collections.defaultdict(dict))
for x in r:
    m = re.match(r'Broad([A-Za-z]+)_(Area_Total|Prod_Levy|Val_Local|Count)$', x['DATAITEM'])
    if not m: continue
    try: v = float(x['OBS_VALUE'])
    except (TypeError, ValueError): continue
    alan[m.group(1)][x['REGION']][(m.group(2), x['TIME_PERIOD'][:4])] = v

# TUZAK 1: 'AUS' gerçekten ulusal toplam mı?
ornek = 'Wheat'
if ornek in alan:
    aus = alan[ornek].get('AUS', {}).get(('Area_Total', '2023'), 0)
    en_buyuk_eyalet = max((d.get(('Area_Total', '2023'), 0)
                           for k, d in alan[ornek].items() if k != 'AUS'), default=0)
    if aus <= en_buyuk_eyalet:
        hata.append("ABS 'AUS' kodu ulusal toplam değil — bölge kodu değişmiş olabilir")

urunler = []
for ad, b in alan.items():
    d = b.get('AUS', {})
    a = d.get(('Area_Total', '2023')); p = d.get(('Prod_Levy', '2023'))
    v = d.get(('Val_Local', '2023')); c = d.get(('Count', '2023'))
    if not a: continue
    k = {'urun': ad, 'alan_ha': a, 'uretim_t': p, 'deger_aud': v, 'isletme': c}
    if c: k['ha_isletme'] = round(a / c)
    if c and v: k['aud_isletme'] = round(v / c)
    if a and p: k['verim_t_ha'] = round(p / a, 2)
    urunler.append(k)
urunler.sort(key=lambda z: -z['alan_ha'])

# ══ 2. Hayvan kesimi — 1965'ten beri ═════════════════════════════════════
h = oku('abs_hayvan_kesim.csv')
carpan = {x['UNIT_MULT'] for x in h if x['UNIT_MEASURE'] == 'NUM'}
if carpan != {'3'}:
    hata.append(f"LSTOCK_SLAUGHT çarpanı beklenen 3 değil: {carpan} — birim değişmiş")

ADI = {'70': 'koyun', '80': 'kuzu', '30': 'sigir', '60': 'dana', '110': 'domuz'}
ceyrek = collections.defaultdict(lambda: collections.defaultdict(list))
for x in h:
    if x['STATE'] != 'AUS' or x['TSEST'] != '10' or x['UNIT_MEASURE'] != 'NUM': continue
    ad = ADI.get(x['LSTOCK_SLAUGHT'])
    if not ad: continue
    try: ceyrek[ad][x['TIME_PERIOD'][:4]].append(float(x['OBS_VALUE']))
    except (TypeError, ValueError): pass

hayvan = {}
for ad, yillar in ceyrek.items():
    # TUZAK 3: dört çeyreği tam olmayan yılı at
    tam = {y: sum(v) for y, v in yillar.items() if len(v) == 4}
    if not tam: continue
    ys = sorted(tam)
    zirve = max(tam.items(), key=lambda kv: kv[1])
    hayvan[ad] = {
        '_birim': 'bin baş (UNIT_MULT=3)',
        'ilk_yil': ys[0], 'son_yil': ys[-1],
        'zirve_yil': zirve[0], 'zirve_bin_bas': round(zirve[1]),
        'son_bin_bas': round(tam[ys[-1]]),
        'zirveye_oran_yuzde': round(100 * tam[ys[-1]] / zirve[1], 1),
        'seri': {y: round(v) for y, v in sorted(tam.items())},
    }

# ══ 3. OECD Üretici Destek Tahmini ═══════════════════════════════════════
o = oku('oecd_destek_pse.csv')
pse = collections.defaultdict(dict)
for x in o:
    if x.get('MEASURE') != 'PSEP': continue
    try: pse[x['REF_AREA']][x['TIME_PERIOD']] = round(float(x['OBS_VALUE']), 2)
    except (TypeError, ValueError): pass
son = max((y for d in pse.values() for y in d), default=None)
destek = {
    '_olcu': 'PSEP — Üretici Destek Tahmini, brüt çiftlik hasılatının yüzdesi',
    '_birim': 'PT_REC_FRM',
    'son_yil': son,
    'ulkeler': {u: d for u, d in sorted(pse.items()) if son in d},
}
if son:
    sir = sorted(((u, d[son]) for u, d in pse.items() if son in d), key=lambda z: z[1])
    destek['en_dusuk_bes'] = sir[:5]
    destek['avustralya'] = pse.get('AUS', {}).get(son)
    destek['turkiye'] = pse.get('TUR', {}).get(son)
    destek['oecd'] = pse.get('OECD', {}).get(son)
    if destek['avustralya'] is None or destek['oecd'] is None:
        hata.append('OECD PSE: AUS veya OECD satırı yok')

if hata:
    print('ÇIKARIM DURDU:', file=sys.stderr)
    for x in hata: print('  ✗ ' + x, file=sys.stderr)
    sys.exit(1)

veri = {
    '_kaynak_niteligi': 'BAĞIMSIZ — ABS (ulusal istatistik kurumu) ve OECD',
    '_kapsam': 'Avustralya geneli',
    'tarla_bitkileri_2023': urunler,
    'hayvan_kesimi': hayvan,
    'destek': destek,
}
pathlib.Path('tarim.json').write_text(
    json.dumps(veri, ensure_ascii=False, indent=2), encoding='utf-8')

print(f"✓ tarim.json")
print(f"  tarla bitkisi: {len(urunler)} ürün · en büyük {urunler[0]['urun']} "
      f"{urunler[0]['alan_ha']:,.0f} ha / {urunler[0]['isletme']:,.0f} işletme "
      f"= {urunler[0]['ha_isletme']:,} ha")
for ad, d in hayvan.items():
    print(f"  {ad:<7s} {d['ilk_yil']}–{d['son_yil']} · zirve {d['zirve_yil']} "
          f"{d['zirve_bin_bas']:,} bin · son {d['son_bin_bas']:,} bin "
          f"(%{d['zirveye_oran_yuzde']})")
print(f"  destek {destek['son_yil']}: AUS %{destek['avustralya']} · "
      f"TUR %{destek['turkiye']} · OECD %{destek['oecd']}")
print(f"  en az destekleyen beş: {destek['en_dusuk_bes']}")
