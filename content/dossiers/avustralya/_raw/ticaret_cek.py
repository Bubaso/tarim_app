#!/usr/bin/env python3
"""Comtrade ve Dünya Bankası'ndan Avustralya tarım ticareti.

ÇİFT SAYIM SÜZGECİ (§2.2.1): Comtrade aynı hücreyi üç boyutta toplu ve
kırılımlı veriyor. customsCode='C00' VE motCode=0 VE partner2Code=0
olmayan satır alınmıyor. Süzgeç hem sorguya hem gelen satıra uygulanıyor.

AVUSTRALYA TUZAĞI: bu muhabir için netWgt ve qty alanları SIFIR geliyor —
değer dolu, ağırlık boş. HS 10 / 2024 / ihracat 8,25 milyar dolar dönerken
netWgt 0. TONAJ BU KAYNAKTAN ALINMAZ; yalnızca değer kullanılıyor.
"""
import json, pathlib, sys, time, urllib.request

UA = {'User-Agent': 'tarimportali.net dosya arastirmasi (burhanbasoglu4@gmail.com)'}
B = 'https://comtradeapi.un.org/public/v1/preview/C/A/HS'

def comtrade(rep, par, cmd, yil, akis='X'):
    u = f'{B}?reporterCode={rep}&period={yil}&partnerCode={par}&flowCode={akis}&cmdCode={cmd}'
    for d in range(4):
        try:
            with urllib.request.urlopen(urllib.request.Request(u, headers=UA), timeout=90) as r:
                v = json.load(r).get('data') or []
            return [x for x in v
                    if str(x.get('customsCode', 'C00')) in ('C00', '')
                    and str(x.get('motCode', 0)) in ('0', '')
                    and str(x.get('partner2Code', 0)) in ('0', '')]
        except Exception:
            time.sleep(5 * (d + 1))
    return None

def wb(gosterge):
    u = (f'https://api.worldbank.org/v2/country/AUS/indicator/{gosterge}'
         f'?format=json&date=2010:2024&per_page=40')
    for d in range(3):
        try:
            with urllib.request.urlopen(urllib.request.Request(u, headers=UA), timeout=60) as r:
                j = json.load(r)
            if isinstance(j, list) and len(j) > 1:
                return {x['date']: x['value'] for x in j[1] if x['value'] is not None}
        except Exception:
            time.sleep(4 * (d + 1))
    return {}

TARIM = [f'{i:02d}' for i in range(1, 25)]          # HS 01-24
hata = []
cikti = {
    '_kaynak': 'UN Comtrade (preview) ve Dünya Bankası',
    '_kaynak_niteligi': 'BAĞIMSIZ',
    '_kapsam': 'Avustralya geneli',
    '_cift_sayim': "customsCode='C00' ve motCode=0 ve partner2Code=0 süzgeci "
                   "uygulandı (§2.2.1).",
    '_agirlik_uyarisi': 'Bu muhabir için netWgt/qty SIFIR geliyor; tonaj '
                        'kullanılmıyor, yalnızca değer.',
}

# ── Avustralya → dünya, tarım fasılları ──────────────────────────────────
d = comtrade('036', '0', ','.join(TARIM), 2024)
if d is None: hata.append('AUS→dünya tarım fasılları çekilemedi')
else:
    cikti['dunyaya_tarim_2024'] = {
        'toplam_usd': sum(x.get('primaryValue') or 0 for x in d),
        'fasillar': sorted(
            [{'hs': x['cmdCode'], 'deger_usd': x.get('primaryValue') or 0} for x in d],
            key=lambda z: -z['deger_usd']),
    }

# ── yün ve pamuk ayrı fasıl (01-24 dışında) ──────────────────────────────
for hs, ad in (('51', 'yun'), ('52', 'pamuk')):
    d = comtrade('036', '0', hs, 2024)
    if d: cikti.setdefault('dunyaya_lif_2024', {})[ad] = {
        'hs': hs, 'deger_usd': d[0].get('primaryValue') or 0}

# ── zaman serisi: yün / et / hububat ─────────────────────────────────────
seri = {}
for y in (2005, 2010, 2015, 2020, 2024):
    seri[str(y)] = {}
    for hs, ad in (('51', 'yun'), ('02', 'et'), ('10', 'hububat')):
        d = comtrade('036', '0', hs, y)
        seri[str(y)][ad] = (d[0].get('primaryValue') if d else None)
        time.sleep(1)
cikti['seri_2005_2024'] = seri

# ── Türkiye ile iki yönlü ────────────────────────────────────────────────
ikili = {}
for ad, rep, par in (('aus_tur', '036', '792'), ('tur_aus', '792', '036')):
    d = comtrade(rep, par, ','.join(TARIM), 2024)
    if d is None: hata.append(f'{ad} çekilemedi'); continue
    ikili[ad] = {'toplam_usd': sum(x.get('primaryValue') or 0 for x in d),
                 'fasillar': sorted([{'hs': x['cmdCode'], 'deger_usd': x.get('primaryValue') or 0}
                                     for x in d], key=lambda z: -z['deger_usd'])}
# HS 08 kırılımı — iki ülke de birbirine aynı fasılı satıyor
h8 = ','.join(f'08{i:02d}' for i in range(1, 15))
for ad, rep, par in (('aus_tur', '036', '792'), ('tur_aus', '792', '036')):
    d = comtrade(rep, par, h8, 2024)
    if d: ikili[ad]['hs08_kirilim'] = sorted(
        [{'hs': x['cmdCode'], 'deger_usd': x.get('primaryValue') or 0} for x in d],
        key=lambda z: -z['deger_usd'])
cikti['turkiye_2024'] = ikili

# ── Dünya Bankası makro ──────────────────────────────────────────────────
cikti['makro'] = {
    'tarim_katma_deger_gsyh_yuzde': wb('NV.AGR.TOTL.ZS'),
    'tarim_arazisi_yuzde': wb('AG.LND.AGRI.ZS'),
    'tarim_istihdam_yuzde': wb('SL.AGR.EMPL.ZS'),
    'islenebilir_arazi_ha': wb('AG.LND.ARBL.HA'),
}

if hata:
    print('ÇEKİM BAŞARISIZ:', file=sys.stderr)
    for h in hata: print('  ✗ ' + h, file=sys.stderr)
    sys.exit(1)

pathlib.Path('ticaret.json').write_text(
    json.dumps(cikti, ensure_ascii=False, indent=2), encoding='utf-8')
d24 = cikti['dunyaya_tarim_2024']
print(f"✓ ticaret.json")
print(f"  AUS→dünya tarım 2024: {d24['toplam_usd']/1e9:,.2f} milyar $")
for f in d24['fasillar'][:6]:
    print(f"    HS {f['hs']}  {f['deger_usd']/1e9:>6,.2f} Mr$")
print(f"  yün {cikti['dunyaya_lif_2024']['yun']['deger_usd']/1e9:.2f} Mr$ · "
      f"pamuk {cikti['dunyaya_lif_2024']['pamuk']['deger_usd']/1e9:.2f} Mr$")
t = cikti['turkiye_2024']
print(f"  AUS→TUR {t['aus_tur']['toplam_usd']/1e6:,.1f} M$ · "
      f"TUR→AUS {t['tur_aus']['toplam_usd']/1e6:,.1f} M$")
m = cikti['makro']
print(f"  tarım GSYH %{list(m['tarim_katma_deger_gsyh_yuzde'].values())[0]:.2f} · "
      f"arazi %{list(m['tarim_arazisi_yuzde'].values())[0]:.2f} · "
      f"istihdam %{list(m['tarim_istihdam_yuzde'].values())[0]:.2f}")
