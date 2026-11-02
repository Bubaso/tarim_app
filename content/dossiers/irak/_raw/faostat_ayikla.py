#!/usr/bin/env python3
"""FAOSTAT toplu indirmesinden Irak serileri → uretim.json

NEDEN TOPLU İNDİRME, API DEĞİL. FAOSTAT'ın REST API'si (fenixservices) bu
ağdan 521 dönüyor; toplu zip (`bulks-faostat.fao.org`) çalışıyor. Erişim
haritası README'de.

TOPLULAŞTIRICI TUZAĞI (§2.2.1). Bu dosyada alan agregaları KULLANILMIYOR —
yalnızca Area == 'Iraq' ve hurmada dünya payı için Area == 'World'
okunuyor. 'Cereals, primary' gibi toplu kalemler tek tek ürünlerin YANINDA
duruyor ve onları içeriyor; hiçbiri toplanmıyor.

SIFIR İLE YOKLUK AYRI. FAOSTAT boş hücreyi boş dize veriyor; bu satır
atlanıyor, sıfır yazılmıyor. Bir ürünün o yıl üretilmemesiyle o yılın hiç
ölçülmemesi aynı şey değil.

Çalıştırma: ~/tarim_ai_pipeline/venv/bin/python faostat_ayikla.py
"""
from __future__ import annotations

import collections
import csv
import io
import json
import pathlib
import zipfile

KOK = pathlib.Path(__file__).parent
ZIP = KOK / 'kaynak_dosyalari' / 'faostat_uretim.zip'
CSV_AD = 'Production_Crops_Livestock_E_All_Data_(Normalized).csv'

URUNLER = ['Wheat', 'Barley', 'Rice', 'Dates', 'Maize (corn)', 'Tomatoes']
HAYVANLAR = ['Sheep', 'Goats', 'Cattle', 'Buffalo', 'Chickens']


def main() -> None:
    uretim = collections.defaultdict(dict)     # (urun, element) -> yil -> deger
    hayvan = collections.defaultdict(dict)
    hurma_dunya = {}
    satir = 0

    with zipfile.ZipFile(ZIP) as z:
        f = io.TextIOWrapper(z.open(CSV_AD), encoding='utf-8-sig', errors='replace')
        for row in csv.DictReader(f):
            alan, urun = row.get('Area'), row.get('Item')
            el, yil, ham = row.get('Element'), row.get('Year'), row.get('Value')
            if ham in (None, ''):
                continue                       # YOKLUK — sıfır yazılmıyor
            try:
                deger, yil = float(ham), int(yil)
            except (TypeError, ValueError):
                continue

            if alan == 'World' and urun == 'Dates' and el == 'Production':
                hurma_dunya[yil] = deger
                continue
            if alan != 'Iraq':
                continue
            satir += 1
            if urun in URUNLER and el in ('Production', 'Area harvested'):
                uretim[f'{urun}|{el}'][yil] = deger
            elif urun in HAYVANLAR and el == 'Stocks':
                hayvan[urun][yil] = deger

    cikti = {
        '_uretim': 'faostat_ayikla.py — elle düzenlenmez',
        '_kaynak': 'FAOSTAT · Production_Crops_Livestock (toplu indirme)',
        '_kapsam': 'Irak · yıllık · ton ve hektar; hayvan varlığı baş',
        '_agrega_notu': ("Alan ve ürün agregaları KULLANILMADI; yalnızca tek tek "
                         "ürünler okundu. Hurmada dünya payı için Area='World' "
                         "ayrıca alındı — tek kalem, toplama değil."),
        '_irak_satir': satir,
        'urunler': {k: {str(y): v for y, v in sorted(d.items())}
                    for k, d in sorted(uretim.items())},
        'hayvan': {k: {str(y): v for y, v in sorted(d.items())}
                   for k, d in sorted(hayvan.items())},
        'hurma_dunya': {str(y): v for y, v in sorted(hurma_dunya.items())},
    }
    (KOK / 'uretim.json').write_text(
        json.dumps(cikti, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')

    b = uretim['Wheat|Production']
    print(f"✓ uretim.json · Irak {satir} satır · {len(cikti['urunler'])} seri")
    print(f"  buğday {min(b)}–{max(b)} · {len(b)} yıl · "
          f"en düşük {min(b.values())/1000:,.0f} bin ton ({min(b, key=b.get)})")


if __name__ == '__main__':
    main()
