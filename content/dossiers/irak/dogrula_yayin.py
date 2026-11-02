#!/usr/bin/env python3
"""Irak — `yayin.json`'u grafiklere, veri katmanına ve DİSKTEKİ dosyalara sınar.

NEDEN VAR. Yayın künyesi üç ayrı şeye söz veriyor: grafikler.json'daki
kimliklere, web/dosya/irak altındaki dosyalara ve data.json'daki sayılara.
Üçü de ayrı dosyada; aralarındaki kayma hiçbir denetimde görünmez. Dosya
yayına alındıktan sonra görünür ve o zaman geç olur.

YEDİ KURAL:
  1. bolum_grafikleri'ndeki her kimlik grafikler.json'da VAR
  2. Her grafik en az bir bölüme yerleştirilmiş — yetim grafik yok
  3. Bölüm numaraları iskeletle tutuyor; hiçbir blok olmayan bölüme atıfta
     bulunmuyor
  4. Her görselin dosyası DİSKTE var, content-type'ı görüntü ve en_boy
     DOSYADAN ölçülenle aynı (künyeden kopyalanmış olamaz)
  5. Her görselde atıf, lisans, alt_tr ve alt_en dolu; lisans kabul listesinde
  6. Hikâye slaytlarındaki her rakam data.json'da karşılığını buluyor
  7. Hikâye görselleri bölüm görselleriyle aynı havuzdan

NEYİ KANITLAMAZ: görselin KONUYA uygun olduğunu. Başlık yalan söyleyebilir ve
söyledi — on dokuz adayın üçü gözle açıldığında reddedildi. Bu betik gözün
yerine geçmez; göz bakmadan önce dosyanın tutarlı olduğunu söyler.

Çalıştırma: python3 dogrula_yayin.py
"""
from __future__ import annotations

import json
import pathlib
import re
import sys

KOK = pathlib.Path(__file__).parent
DEPO = KOK.parent.parent.parent                      # tarim_app/
Y = json.loads((KOK / 'yayin.json').read_text(encoding='utf-8'))
G = json.loads((KOK / 'grafikler.json').read_text(encoding='utf-8'))['grafikler']
VERI = json.loads((KOK / 'data.json').read_text(encoding='utf-8'))
hata: list[str] = []

LISANS = {'CC0', 'Public domain', 'CC BY 2.0', 'CC BY 3.0', 'CC BY 4.0',
          'CC BY-SA 2.0', 'CC BY-SA 2.5', 'CC BY-SA 3.0', 'CC BY-SA 4.0'}
BOLUM = {int(k) for k in Y['_bolum_basliklari'] if not k.startswith('_')}

# ── 1, 2, 3 — grafikler ve bölüm numaraları ───────────────────────────────
yerlesen = set()
for no, liste in Y['bolum_grafikleri'].items():
    if no.startswith('_'):
        continue
    if int(no) not in BOLUM:
        hata.append(f"bolum_grafikleri: §{no} iskelette yok")
    for gid in liste:
        if gid not in G:
            hata.append(f"bolum_grafikleri §{no}: '{gid}' grafikler.json'da YOK")
        yerlesen.add(gid)
for gid in G:
    if gid not in yerlesen:
        hata.append(f"YETİM GRAFİK: '{gid}' hiçbir bölüme yerleştirilmemiş — "
                    "üretildi ama sayfada hiç görünmeyecek")
for alan in ('bolum_turleri', 'bolum_gorselleri'):
    for no in Y[alan]:
        if not no.startswith('_') and int(no) not in BOLUM:
            hata.append(f"{alan}: §{no} iskelette yok")
eksik_tur = BOLUM - {int(k) for k in Y['bolum_turleri'] if not k.startswith('_')}
if eksik_tur:
    hata.append(f"bolum_turleri eksik: §{sorted(eksik_tur)}")

# ── 4 ve 5 — görseller ────────────────────────────────────────────────────
try:
    from PIL import Image
except ImportError:
    Image = None
    hata.append('Pillow yok — en_boy ölçülemedi, 4. kural ÇALIŞMADI')

gorseller = {'kapak': Y['kapak']}
gorseller.update({f'§{k}': v for k, v in Y['bolum_gorselleri'].items()
                  if not k.startswith('_')})
dosyalar = set()
for iz, g in gorseller.items():
    for alan in ('url', 'atif', 'lisans', 'alt_tr', 'alt_en', 'en_boy'):
        if not g.get(alan):
            hata.append(f"{iz}: '{alan}' boş — atıfsız ya da altyazısız görsel yayımlanmaz")
    if g.get('lisans') not in LISANS:
        hata.append(f"{iz}: lisans '{g.get('lisans')}' kabul listesinde değil")
    ad = (g.get('url') or '').rsplit('/', 1)[-1]
    dosyalar.add(ad)
    yol = DEPO / 'web' / 'dosya' / 'irak' / ad
    if not yol.exists():
        hata.append(f"{iz}: DOSYA DİSKTE YOK · web/dosya/irak/{ad}")
        continue
    if Image:
        with Image.open(yol) as im:
            olculen = round(im.width / im.height, 4)
        if abs(olculen - float(g['en_boy'])) > 0.003:
            hata.append(f"{iz}: en_boy {g['en_boy']} · DOSYADAN ölçülen {olculen} — "
                        "künyeden kopyalanmış olabilir (kırpılan görselde oran değişir)")
    # Altyazı GÖRÜLENİ söylemeli: iddia kipi kullanılamaz
    for dil in ('alt_tr', 'alt_en'):
        if re.search(r'\b(en büyük|largest|ilk kez|first time|tarihin|history)\b',
                     g[dil], re.I):
            hata.append(f"{iz}.{dil}: altyazı GÖRÜLEMEYEN bir iddia taşıyor — "
                        "altyazı yalnız karede görüneni söyler")

# ── 6 — hikâye rakamları veriye dayanıyor mu ──────────────────────────────
havuz: set[float] = set()


def topla(o) -> None:
    if isinstance(o, dict):
        for k, v in o.items():
            topla(k); topla(v)
    elif isinstance(o, list):
        for v in o:
            topla(v)
    elif isinstance(o, bool):
        pass
    elif isinstance(o, (int, float)):
        havuz.add(float(o))
    elif isinstance(o, str):
        for parca in re.findall(r'\d+(?:[.,]\d{1,3})*(?:[.,]\d+)?', o):
            for aday in (parca.replace(',', ''), parca.replace('.', ''),
                         parca.replace(',', '.')):
                try:
                    havuz.add(float(aday))
                except ValueError:
                    pass


topla(VERI)
for v in list(havuz):
    for k in (1e3, 1e6, 1e9):
        havuz.add(v / k); havuz.add(v * k)
    havuz.add(abs(v)); havuz.add(v * 100); havuz.add(v / 100)
havuz |= {float(n) for n in range(0, 32)}
havuz_s = sorted(havuz)

SAYI_TR = re.compile(r'(?<![\w.,])(\d{1,3}(?:\.\d{3})+|\d+)(?:,(\d+))?(?![\w])')
SAYI_EN = re.compile(r'(?<![\w.,])(\d{1,3}(?:,\d{3})+|\d+)(?:\.(\d+))?(?![\w])')

hikaye = Y.get('hikaye') or {}
for i, s in enumerate(hikaye.get('slaytlar', [])):
    for alan in ('baslik', 'rakam', 'etiket', 'baslik_en', 'rakam_en', 'etiket_en'):
        metin = s.get(alan) or ''
        desen = SAYI_EN if alan.endswith('_en') else SAYI_TR
        for m in desen.finditer(metin):
            tam = m.group(1).replace('.', '').replace(',', '')
            kesir = m.group(2) or ''
            try:
                deger = float(f'{tam}.{kesir}' if kesir else tam)
            except ValueError:
                continue
            if not any(round(v, len(kesir)) == deger for v in havuz_s):
                hata.append(f"slayt[{i}].{alan}: '{m.group(0)}' VERİDE YOK")
    # ── 7 — slayt görseli havuzdan mı
    ad = (s.get('gorsel') or '').rsplit('/', 1)[-1]
    if ad not in dosyalar:
        hata.append(f"slayt[{i}]: görsel '{ad}' bölüm görselleri havuzunda yok — "
                    "künyesiz görsel hikâyeye giremez")

if hata:
    print('YAYIN KÜNYESİ SINAMASI BAŞARISIZ:\n', file=sys.stderr)
    for h in hata:
        print('  ✗ ' + h, file=sys.stderr)
    sys.exit(1)

print(f"✓ yayin.json · 7 kural geçti")
print(f"  {len(BOLUM)} bölüm · {len(yerlesen)} grafik yerleşti · "
      f"{len(gorseller)} görsel (kapak dahil) · {len(hikaye.get('slaytlar', []))} slayt")
bos = sorted(BOLUM - {int(k) for k in Y['bolum_gorselleri'] if not k.startswith('_')})
print(f"  görselsiz bölüm: §{bos}")
