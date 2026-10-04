#!/usr/bin/env python3
"""BoM Kuraklık Bildirisi arşivinden kronoloji çıkarır.

KAYNAK: kaynak_dosyalari/bom_kuraklik_arsiv.html
        (https://www.bom.gov.au/climate/drought/archive.shtml)
SINIF : BAĞIMSIZ — Meteoroloji Bürosu, su piyasasıyla ilgisi olmayan kurum.

Büronun KENDİ ifadesiyle: Büro kuraklık İLAN ETMEZ, bildiri yayımlar.
Bu ayrım metinde korunacak — "kuraklık ilan edildi" yazılmayacak.

ÇÖZÜLEN TUZAK: bildiri yayımlanMAYAN aylar için de SAYFA var ve başlığı
"No Drought Statement issued for <Ay>" oluyor. İlk çıkarımda bunlar da
bildiri sayıldı ve 2011 için "12 bildiri + 3 bildirisiz ay" gibi imkânsız
bir tablo çıktı. Ayrım başlıkta.
"""
import collections, html as H, json, pathlib, re, sys

KAYNAK = pathlib.Path('kaynak_dosyalari/bom_kuraklik_arsiv.html')
if not KAYNAK.exists():
    sys.exit('HATA: arşiv HTML yok — önce cek.sh')
h = KAYNAK.read_text(errors='replace')

AY = ('January February March April May June July August September '
      'October November December').split()

bildiri = []
for m in re.finditer(
        r'href="(/climate/drought/archive/(\d{4})(\d{2})(\d{2})\.shtml)"[^>]*>(.*?)</a>',
        h, re.S):
    baslik = ' '.join(H.unescape(re.sub(r'<[^>]+>', ' ', m.group(5))).split())
    bildiri.append({'tarih': f'{m.group(2)}-{m.group(3)}-{m.group(4)}',
                    'yil': int(m.group(2)), 'ay': int(m.group(3)),
                    'baslik': baslik, 'adres': 'https://www.bom.gov.au' + m.group(1)})
if not bildiri:
    sys.exit('HATA: hiç bildiri bağlantısı yok — sayfa yapısı değişmiş olabilir')
bildiri.sort(key=lambda b: b['tarih'])

YOK = re.compile(r'^No Drought Statement issued', re.I)
yoklar = [{'yil': b['yil'], 'ay': b['ay'], 'tarih': b['tarih']}
          for b in bildiri if YOK.match(b['baslik'])]
bildiri = [b for b in bildiri if not YOK.match(b['baslik'])]

yil_say = collections.Counter(b['yil'] for b in bildiri)
yil_yok = collections.Counter(y['yil'] for y in yoklar)

en, bas = 0, None
if yoklar:
    ay_no = sorted(y['yil'] * 12 + y['ay'] for y in yoklar)
    n, b0 = 1, ay_no[0]
    en, bas = 1, ay_no[0]
    for a, b in zip(ay_no, ay_no[1:]):
        if b == a + 1:
            n += 1
        else:
            n, b0 = 1, b
        if n > en:
            en, bas = n, b0
AD = lambda t: f'{AY[(t - 1) % 12]} {(t - 1) // 12}'

veri = {
 '_kaynak': 'Bureau of Meteorology — Drought Statement archive',
 '_kaynak_adresi': 'https://www.bom.gov.au/climate/drought/archive.shtml',
 '_kaynak_niteligi': 'BAĞIMSIZ',
 '_uyari': 'Büro kuraklık ilan etmez, bildiri yayımlar. "İlan" denmeyecek.',
 'bildiri_sayisi': len(bildiri),
 'ilk': bildiri[0]['tarih'], 'son': bildiri[-1]['tarih'],
 'bildirisiz_ay_sayisi': len(yoklar),
 'en_uzun_bildirisiz_dizi_ay': en,
 'en_uzun_bildirisiz_dizi': f'{AD(bas)} → {AD(bas + en - 1)}' if bas else None,
 'yila_gore_bildiri': dict(sorted(yil_say.items())),
 'yila_gore_bildirisiz_ay': dict(sorted(yil_yok.items())),
 'bildiriler': bildiri}
pathlib.Path('kuraklik.json').write_text(
    json.dumps(veri, ensure_ascii=False, indent=2), encoding='utf-8')

print(f'✓ {len(bildiri)} bildiri · {veri["ilk"]} → {veri["son"]}')
print(f'✓ bildirisiz ay: {len(yoklar)} · en uzun dizi: {en} ay '
      f'({veri["en_uzun_bildirisiz_dizi"]})')
print('\nyıl  bildiri  bildirisiz')
for y in range(min(yil_say), max(yil_say) + 1):
    print(f'{y}   {yil_say.get(y,0):4d}   {yil_yok.get(y,0):7d}')
