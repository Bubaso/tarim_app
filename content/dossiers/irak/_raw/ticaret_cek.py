#!/usr/bin/env python3
"""Comtrade ve Dünya Bankası'ndan Irak verisi → ticaret.json + banka.json

AYNA İSTATİSTİK — BU DOSYANIN TEMEL KISITI.
Irak Comtrade'e muhabir olarak neredeyse hiç rapor vermiyor: 2018, 2020 ve
2022 için SIFIR satır, 2024 için bir satır. Dolayısıyla bütün ticaret
rakamları TÜRKİYE'NİN beyanından okunuyor (reporterCode=792). Metin bunu
açıkça yazacak; Rusya dosyasındaki "ticaret istatistiği yayımlanmıyor"
notunun karşılığı.

ÇİFT SAYIM SÜZGECİ (§2.2.1): Comtrade aynı hücreyi üç boyutta hem toplu hem
kırılımlı veriyor. customsCode='C00' VE motCode=0 VE partner2Code=0 olmayan
satır alınmıyor. Süzgeç hem sorguya hem GELEN SATIRA uygulanıyor — sunucu
süzgeci sessizce yok sayabiliyor.

BOŞ SONUÇ SIFIR DEĞİLDİR (§2.2.1, dokuzuncu tuzak). API veri bulamadığında
hata değil BOŞ DİZİ döndürüyor. Toplamı alan bir kod bunu 0 sanır ve "o yıl
hiç ticaret olmamış" diye okur. Bu dosyada ölçüldü: partnerCode=840 (ABD)
ısrarla boş dizi dönüyor — Türkiye'nin ABD'ye tarım ihracatı elbette var.
Bu yüzden her çağrı (ham_satir, suzulmus_satir, toplam) üçlüsü döndürüyor ve
ham_satir sıfırsa değer None yazılıyor, 0 değil.

Çalıştırma: ~/tarim_ai_pipeline/venv/bin/python ticaret_cek.py
"""
from __future__ import annotations

import json
import pathlib
import time
import urllib.error
import urllib.request

KOK = pathlib.Path(__file__).parent
UA = {'User-Agent': 'tarimportali.net dosya arastirmasi (burhanbasoglu4@gmail.com)'}
COMTRADE = 'https://comtradeapi.un.org/public/v1/preview/C/A/HS'

TR, IRAK, DUNYA = 792, 368, 0
FASILLAR = [f'{i:02d}' for i in range(1, 25)]      # HS 01-24 = tarım
TARIM = ','.join(FASILLAR)


def comtrade(partner: int, cmd: str, yil: int, akis: str = 'X', dene: int = 5):
    """(ham satır, süzülmüş satır, toplam değer) — ham 0 ise toplam None."""
    u = (f'{COMTRADE}?reporterCode={TR}&period={yil}&partnerCode={partner}'
         f'&flowCode={akis}&cmdCode={cmd}'
         f'&customsCode=C00&motCode=0&partner2Code=0')
    for i in range(dene):
        try:
            with urllib.request.urlopen(urllib.request.Request(u, headers=UA),
                                        timeout=120) as r:
                ham = json.load(r).get('data') or []
            suz = [x for x in ham
                   if str(x.get('customsCode', 'C00')) in ('C00', '')
                   and str(x.get('motCode', 0)) in ('0', '')
                   and str(x.get('partner2Code', 0)) in ('0', '')]
            if not ham:
                return 0, 0, None          # BOŞ SONUÇ — sıfır değil
            return len(ham), len(suz), sum(x['primaryValue'] for x in suz)
        except Exception:
            time.sleep(6 * (i + 1))
    return None, None, None                # hata — boş sonuçtan ayrı


def fasil_dokumu(yil: int):
    ham, suz, _ = comtrade(IRAK, TARIM, yil)
    if not ham:
        return None
    u = (f'{COMTRADE}?reporterCode={TR}&period={yil}&partnerCode={IRAK}'
         f'&flowCode=X&cmdCode={TARIM}&customsCode=C00&motCode=0&partner2Code=0')
    with urllib.request.urlopen(urllib.request.Request(u, headers=UA), timeout=120) as r:
        d = json.load(r).get('data') or []
    return sorted(
        ({'fasil': str(x['cmdCode']).zfill(2), 'deger': x['primaryValue']}
         for x in d
         if str(x.get('customsCode', 'C00')) in ('C00', '')
         and str(x.get('motCode', 0)) in ('0', '')
         and str(x.get('partner2Code', 0)) in ('0', '')),
        key=lambda z: -z['deger'])


def wb(gosterge: str, ulke: str = 'IRQ'):
    """En yeni dolu değer ve yılı. Veri yoksa None — sıfır değil."""
    u = (f'https://api.worldbank.org/v2/country/{ulke}/indicator/{gosterge}'
         f'?format=json&per_page=80')
    for i in range(4):
        try:
            with urllib.request.urlopen(urllib.request.Request(u, headers=UA),
                                        timeout=60) as r:
                d = json.load(r)
            v = [x for x in (d[1] or []) if x['value'] is not None]
            if not v:
                return None
            return {'yil': int(v[0]['date']), 'deger': v[0]['value']}
        except Exception:
            time.sleep(5 * (i + 1))
    return None


def main() -> None:
    YIL = 2024
    print('▸ Comtrade — ayna istatistik (muhabir: Türkiye)')

    irak_ham, _, irak_tarim = comtrade(IRAK, TARIM, YIL)
    dunya_ham, _, dunya_tarim = comtrade(DUNYA, TARIM, YIL)
    _, _, irak_toplam = comtrade(IRAK, 'TOTAL', YIL)
    ithal_ham, _, irak_ithalat = comtrade(IRAK, TARIM, YIL, 'M')

    # Irak'ın MUHABİR olarak sessizliği — iddianın kendi kanıtı
    irak_muhabir = {}
    for y in (2018, 2020, 2022, 2024):
        u = (f'{COMTRADE}?reporterCode={IRAK}&period={y}&partnerCode={TR}'
             f'&flowCode=M&cmdCode=TOTAL')
        try:
            with urllib.request.urlopen(urllib.request.Request(u, headers=UA),
                                        timeout=90) as r:
                irak_muhabir[y] = len(json.load(r).get('data') or [])
        except Exception:
            irak_muhabir[y] = None
        time.sleep(2)

    cikti = {
        '_uretim': 'ticaret_cek.py — elle düzenlenmez',
        '_muhabir': 'Türkiye (792). Irak kendi beyanını vermiyor; bkz. irak_muhabir_satir.',
        '_suzgec': "customsCode=C00 · motCode=0 · partner2Code=0 — sorguda ve satırda",
        'yil': YIL,
        'tarim_ihracat_irak': irak_tarim,
        'tarim_ihracat_dunya': dunya_tarim,
        'toplam_ihracat_irak': irak_toplam,
        'tarim_ithalat_irak': irak_ithalat,
        'ihracat_fasil_sayisi': irak_ham,
        'ithalat_fasil_sayisi': ithal_ham,
        'fasillar': fasil_dokumu(YIL),
        'irak_muhabir_satir': irak_muhabir,
    }

    print('▸ Dünya Bankası')
    gostergeler = {
        'nufus': 'SP.POP.TOTL',
        'tarim_gsyh_payi': 'NV.AGR.TOTL.ZS',
        'tarim_arazi_payi': 'AG.LND.AGRI.ZS',
        'tarim_istihdam_payi': 'SL.AGR.EMPL.ZS',
        'tahil_verimi_kg_ha': 'AG.YLD.CREL.KG',
        'gida_ithalat_payi': 'TM.VAL.FOOD.ZS.UN',
        'sulanan_arazi_payi': 'AG.LND.IRIG.AG.ZS',
        'kirsal_nufus_payi': 'SP.RUR.TOTL.ZS',
    }
    banka = {'_uretim': 'ticaret_cek.py', '_kaynak': 'Dünya Bankası göstergeleri'}
    for ad, g in gostergeler.items():
        banka[ad] = wb(g)
        time.sleep(1)
    # Türkiye karşılaştırması — ORTAK YIL kuralı için (§2.7)
    banka['turkiye'] = {ad: wb(g, 'TUR') for ad, g in
                        (('tarim_gsyh_payi', 'NV.AGR.TOTL.ZS'),
                         ('tahil_verimi_kg_ha', 'AG.YLD.CREL.KG'),
                         ('nufus', 'SP.POP.TOTL'))}

    (KOK / 'ticaret.json').write_text(
        json.dumps(cikti, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    (KOK / 'banka.json').write_text(
        json.dumps(banka, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')

    print(f"✓ ticaret.json · Irak'a tarım {irak_tarim/1e9:,.2f} milyar $ · "
          f"dünya {dunya_tarim/1e9:,.2f} · ters yön {irak_ithalat/1e6:,.1f} M$")
    print(f"✓ banka.json · {len([k for k,v in banka.items() if isinstance(v,dict) and v])} gösterge")


if __name__ == '__main__':
    main()
