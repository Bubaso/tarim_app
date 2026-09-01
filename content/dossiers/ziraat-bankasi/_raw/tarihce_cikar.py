#!/usr/bin/env python3
"""site_tarihce.html → tarihce.json

NEDEN AYRI BETİK. Sayfa yılları ve açıklamaları İKİ AYRI HTML bloğunda
tutuyor: `.history-slider` içinde 51 yıl, `.history-content` içinde 51
açıklama kümesi, aynı sırada. Düz metne çevirip okumak sırayı kaydırıyor —
ilk okumada Menafi Hissesi 1883 yerine 1867'ye, 10 milyonluk sermaye 1888
yerine 1916'ya atfedildi. Eşleştirme etiket yapısından yapılır, göz kararıyla
değil.
"""
import re, html, json, sys

s = open('site_tarihce.html', encoding='utf-8', errors='replace').read()
sik = re.sub(r'>\s+<', '><', s)

yillar = re.findall(r'<div class="item"><a>(\d{4})</a></div>', sik)
kuyruk = sik[sik.find('class="history-content"'):]
bloklar = re.findall(r'<div class="item"><ul>(.*?)</ul></div>', kuyruk, re.S)

if len(yillar) != len(bloklar):
    sys.exit(f'HİZALAMA BOZUK: {len(yillar)} yıl, {len(bloklar)} blok. '
             'Sayfa yapısı değişmiş — elle bakılmalı.')

def temiz(x):
    return re.sub(r'\s+', ' ', html.unescape(re.sub(r'<[^>]+>', ' ', x))).strip()

kayit = [{'yil': int(y),
          'maddeler': [m for m in (temiz(x) for x in
                       re.findall(r'<li>(.*?)</li>', b, re.S)) if m]}
         for y, b in zip(yillar, bloklar)]

json.dump(kayit, open('tarihce.json', 'w'), ensure_ascii=False, indent=1)
print(f'→ tarihce.json · {len(kayit)} yıl · '
      f'{sum(len(k["maddeler"]) for k in kayit)} madde '
      f'({kayit[0]["yil"]}–{kayit[-1]["yil"]})')
