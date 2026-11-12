#!/usr/bin/env python3
"""Comtrade + Dünya Bankası'ndan Mısır verisi → ticaret.json, banka.json

IRAK'TAN DEVRALINAN ÜÇ KORUMA — gerekçeleri orada ölçüldü:

  1. ÇİFT SAYIM SÜZGECİ (§2.2.1). Comtrade aynı hücreyi hem toplu hem
     kırılımlı veriyor. customsCode='C00' VE motCode=0 VE partner2Code=0
     olmayan satır alınmıyor. Süzgeç hem SORGUYA hem GELEN SATIRA
     uygulanıyor: sunucu süzgeci sessizce yok sayabiliyor.
  2. BOŞ SONUÇ SIFIR DEĞİLDİR. API veri bulamayınca hata değil BOŞ DİZİ
     dönüyor; toplamı alan kod bunu 0 sanıp "o yıl hiç ticaret olmamış" diye
     okur. Her çağrı (ham, süzülmüş, toplam) döndürüyor; ham 0 ise değer
     None yazılıyor.
  3. HATA İLE BOŞLUK AYRI. Ağ hatası None,None,None; gerçek boşluk 0,0,None.

MISIR'DA IRAK'TAN FARKLI OLAN ŞEY: Mısır Comtrade'e muhabir olarak rapor
veriyor. Yani Irak dosyasındaki "ayna istatistik" zorunluluğu burada YOK —
iki beyan karşılaştırılabilir. Betik ikisini de çekiyor; fark varsa o
farkın kendisi dosyada anlatılacak bir şey (§2.2.1 ikinci biçim).

User-Agent'ta kişisel bilgi YOK: dış servise sitenin genel adresi gider.

Çalıştırma: python3 ticaret_cek.py
"""
from __future__ import annotations

import json
import pathlib
import time
import urllib.error
import urllib.request

KOK = pathlib.Path(__file__).parent
UA = {'User-Agent': 'tarimportali.net dosya arastirmasi'}
COMTRADE = 'https://comtradeapi.un.org/public/v1/preview/C/A/HS'

TR, MISIR, DUNYA = 792, 818, 0
FASILLAR = [f'{i:02d}' for i in range(1, 25)]      # HS 01-24 = tarım
TARIM = ','.join(FASILLAR)


def _cek(u: str, dene: int = 5):
    for i in range(dene):
        try:
            with urllib.request.urlopen(urllib.request.Request(u, headers=UA),
                                        timeout=120) as r:
                return json.load(r).get('data') or []
        except Exception as e:
            if i == dene - 1:
                print(f'    ! {type(e).__name__}: {str(e)[:70]}')
            time.sleep(6 * (i + 1))
    return None


def _suz(ham):
    return [x for x in ham
            if str(x.get('customsCode', 'C00')) in ('C00', '')
            and str(x.get('motCode', 0)) in ('0', '')
            and str(x.get('partner2Code', 0)) in ('0', '')]


def comtrade(reporter: int, partner: int, cmd: str, yil: int, akis: str = 'X'):
    """(ham satır, süzülmüş satır, toplam) — ham 0 ise toplam None."""
    u = (f'{COMTRADE}?reporterCode={reporter}&period={yil}&partnerCode={partner}'
         f'&flowCode={akis}&cmdCode={cmd}'
         f'&customsCode=C00&motCode=0&partner2Code=0')
    ham = _cek(u)
    if ham is None:
        return None, None, None
    if not ham:
        return 0, 0, None
    suz = _suz(ham)
    return len(ham), len(suz), sum(x['primaryValue'] for x in suz)


def fasil_dokumu(yil: int, akis: str = 'X'):
    u = (f'{COMTRADE}?reporterCode={TR}&period={yil}&partnerCode={MISIR}'
         f'&flowCode={akis}&cmdCode={TARIM}&customsCode=C00&motCode=0&partner2Code=0')
    d = _cek(u)
    if not d:
        return None
    return sorted(({'fasil': str(x['cmdCode']).zfill(2), 'deger': x['primaryValue']}
                   for x in _suz(d)), key=lambda z: -z['deger'])


def wb(gosterge: str, ulke: str = 'EGY', seri: bool = False):
    u = (f'https://api.worldbank.org/v2/country/{ulke}/indicator/{gosterge}'
         f'?format=json&per_page=90')
    for i in range(4):
        try:
            with urllib.request.urlopen(urllib.request.Request(u, headers=UA),
                                        timeout=60) as r:
                d = json.load(r)
            v = [x for x in (d[1] or []) if x['value'] is not None]
            if not v:
                return None
            if seri:
                return [{'yil': int(x['date']), 'deger': x['value']} for x in v]
            return {'yil': int(v[0]['date']), 'deger': v[0]['value']}
        except Exception:
            time.sleep(5 * (i + 1))
    return None


def main() -> None:
    YIL = 2024
    cikti = {'_kaynak': 'UN Comtrade · HS 01-24 · yıllık',
             '_yil': YIL,
             '_suzgec': "customsCode=C00, motCode=0, partner2Code=0 (çift sayım)",
             '_bos_notu': 'ham satır 0 ise değer null — SIFIR DEĞİL'}

    print(f'▸ Comtrade {YIL} — Türkiye beyanı')
    for ad, (p, cmd, akis) in {
        'tr_misira_tarim_ihracat':  (MISIR, TARIM, 'X'),
        'tr_misirdan_tarim_ithalat':(MISIR, TARIM, 'M'),
        'tr_misira_toplam_ihracat': (MISIR, 'TOTAL', 'X'),
        'tr_dunyaya_tarim_ihracat': (DUNYA, TARIM, 'X'),
    }.items():
        ham, suz, top = comtrade(TR, p, cmd, YIL, akis)
        cikti[ad] = {'ham_satir': ham, 'suzulmus_satir': suz, 'deger_usd': top}
        print(f'  {ad:30} ham {str(ham):>5} · süz {str(suz):>5} · '
              f'{"—" if top is None else f"{top:,.0f} $"}')

    print(f'▸ Comtrade {YIL} — MISIR beyanı (ayna kontrolü)')
    for ad, (p, cmd, akis) in {
        'misir_trden_tarim_ithalat': (TR, TARIM, 'M'),
        'misir_tre_tarim_ihracat':   (TR, TARIM, 'X'),
        'misir_dunyaya_tarim_ihracat': (DUNYA, TARIM, 'X'),
    }.items():
        ham, suz, top = comtrade(MISIR, p, cmd, YIL, akis)
        cikti[ad] = {'ham_satir': ham, 'suzulmus_satir': suz, 'deger_usd': top}
        print(f'  {ad:30} ham {str(ham):>5} · süz {str(suz):>5} · '
              f'{"—" if top is None else f"{top:,.0f} $"}')

    print('▸ Fasıl dökümü')
    cikti['fasil_ihracat'] = fasil_dokumu(YIL, 'X')
    cikti['fasil_ithalat'] = fasil_dokumu(YIL, 'M')
    for ad in ('fasil_ihracat', 'fasil_ithalat'):
        v = cikti[ad]
        print(f'  {ad}: {"—" if not v else f"{len(v)} fasıl, en büyük {v[0]}"}')

    (KOK / 'ticaret.json').write_text(
        json.dumps(cikti, ensure_ascii=False, indent=1), encoding='utf-8')
    print('✓ ticaret.json')

    print('▸ Dünya Bankası — Mısır')
    GOSTERGE = {
        'tarim_gsyh_pay':      'NV.AGR.TOTL.ZS',
        'tarim_istihdam_pay':  'SL.AGR.EMPL.ZS',
        'tarim_arazi_km2':     'AG.LND.AGRI.K2',
        'ekili_arazi_km2':     'AG.LND.CROP.K2',
        'sulanan_pay':         'AG.LND.IRIG.AG.ZS',
        'tahil_verim_kg_ha':   'AG.YLD.CREL.KG',
        'nufus':               'SP.POP.TOTL',
        'kirsal_nufus_pay':    'SP.RUR.TOTL.ZS',
        'gida_ithalat_pay':    'TM.VAL.FOOD.ZS.UN',
        'yenilenebilir_su_kisi':'ER.H2O.INTR.PC',
    }
    banka = {'_kaynak': 'World Bank Open Data API v2', '_ulke': 'EGY'}
    for ad, kod in GOSTERGE.items():
        banka[ad] = {'kod': kod, 'misir': wb(kod, 'EGY'), 'turkiye': wb(kod, 'TUR')}
        m, t = banka[ad]['misir'], banka[ad]['turkiye']
        f = lambda x: '—' if not x else f"{x['deger']:,.1f} ({x['yil']})"
        print(f'  {ad:24} MISIR {f(m):>22}   TÜRKİYE {f(t):>22}')
    (KOK / 'banka.json').write_text(
        json.dumps(banka, ensure_ascii=False, indent=1), encoding='utf-8')
    print('✓ banka.json')


if __name__ == '__main__':
    main()
