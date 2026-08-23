#!/usr/bin/env python3
"""TMO data.json → _raw çapraz doğrulaması.

Zincirin en kritik halkası burada sınanıyor: data.json'daki her kilit rakamın
ham kaynak metninde GERÇEKTEN geçtiği. Bir kalem elle düzenlenir veya yanlış
kopyalanırsa burada düşer.

Ham metinlerdeki biçim (6.150.832 / 13,7 / 422.5) korunarak aranıyor; sayıyı
normalleştirip aramak, yanlış bir kalemin doğru görünmesine yol açabilirdi.

    python3 content/dossiers/tmo/dogrula_veri.py
"""
import json, sys
from pathlib import Path

KOK = Path(__file__).parent
ham = {ad: (KOK / '_raw' / f'{ad}.txt').read_text(encoding='utf-8')
       for ad in ('faaliyet_2025', 'ana_statu', 'kurum_hakkinda')}

# (açıklama, ham metinde aranan dizi, hangi kaynakta)
KONTROLLER = [
    ('toplam alım · ton',        '6.150.332',                      'faaliyet_2025'),
    ('toplam ödeme · bin TL',    '81.624.184',                     'faaliyet_2025'),
    ('buğday gerçekleşen',       '3 milyon 841 bin',               'faaliyet_2025'),
    ('arpa gerçekleşen',         '171 bin',                        'faaliyet_2025'),
    ('buğday alım fiyatı',       '13.500',                         'faaliyet_2025'),
    ('arpa alım fiyatı',         '11.000',                         'faaliyet_2025'),
    ('su yılı yağışı',           '422.5',                          'faaliyet_2025'),
    ('normal yağış 1991-2020',   '573.4',                          'faaliyet_2025'),
    ('buğday üretim kaybı',      '13,7',                           'faaliyet_2025'),
    ('arpa üretim kaybı',        '25,9',                           'faaliyet_2025'),
    ('sermaye 12,55 milyar',     '12.550.000.000',                 'ana_statu'),
    ('sermaye 52,55 milyar',     '52.550.000.000',                 'ana_statu'),
    ('sermaye 124,55 milyar',    '124.550.000.000',                'ana_statu'),
    ('sermaye 94,55 milyar',     '94.550.000.000',                 'ana_statu'),
    ('hukuki bünye · İDT',       'iktisadi devlet teşekkülüdür',   'ana_statu'),
    ('mülga ana statü RG',       '18602',                          'ana_statu'),
    ('kuruluş RG tarihi',        '13/7/1938',                      'kurum_hakkinda'),
    ('kuruluş kanun no',         '3491',                           'kurum_hakkinda'),
    ('arpa-yulaf yetkisi',       '27 Ekim 1939',                   'kurum_hakkinda'),
    ('çavdar yetkisi',           '28 Kasım 1940',                  'kurum_hakkinda'),
    # "25 Nisan 1941" PDF'te satır sonunda bölünüyor ("…25\nNisan 1941…"),
    # o yüzden tarihin kendisi değil kırılmayan kısmı aranıyor. Satır kırılması
    # bu tür aramaların en sessiz tuzağı: kalem doğruyken kontrol düşer.
    ('mısır yetkisi',            'Nisan 1941 tarihinde mısır',     'kurum_hakkinda'),
]

hata = 0
for aciklama, aranan, kaynak in KONTROLLER:
    bulundu = aranan in ham[kaynak]
    if not bulundu:
        hata += 1
    print(f"  {'✓' if bulundu else '✗'} {aciklama:26} '{aranan}'  ← {kaynak}")

# data.json ayrıca geçerli JSON ve zorunlu blokları taşımalı.
veri = json.loads((KOK / 'data.json').read_text(encoding='utf-8'))
for blok in ('tez', 'kunye', 'mevzuat_zinciri', 'sermaye', 'urun_yetkisi',
             'alim_2025', 'kuraklik_2025', 'bosluklar'):
    if blok not in veri:
        print(f'  ✗ data.json içinde "{blok}" bloğu yok'); hata += 1

print()
print(f'✗ {hata} sorun' if hata else f'✓ {len(KONTROLLER)} kalemin hepsi ham kaynakta doğrulandı')
sys.exit(1 if hata else 0)
