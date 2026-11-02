#!/usr/bin/env python3
"""Irak — `grafikler.json`'u `data.json`'a karşı sınar.

DAYANAK ÇİZİCİNİN KENDİSİ. Kurallar `dossier_chart.dart`'tan okunarak
yazıldı, tahminle değil. DSİ dosyasında bunun tersi yapılmıştı: doğrulayıcı
üreticiyle aynı yanlış şekli varsayıyordu, 26 @yol çözülüyordu, yedi kural
geçiyordu — ve çizgi grafiği canlıda HİÇ ÇİZİLMİYORDU.

DOKUZ KURAL:
  1. Her @yol data.json'da karşılığını buluyor
  2. @yol'un ucu SAYI (küme alanları hariç)
  3. cizgi serilerinde noktalar `noktalar.harita` ya da `noktalar.liste`
     ALTINDA; üst düzeyde liste/harita/x/y bulunursa HATA
  4. cizgi x ekseni sayısal — yıl anahtarları parse edilebiliyor
  5. ikili_cubuk'ta satır değer sayısı seri sayısına eşit
  6. ticaret_akisi'nın İKİ YAKASI DA dolu — biri boşsa model null döndürür
  7. siralama ve kunye boş değil
  8. Ayna istatistik taşıyan her grafiğin notu muhabirini söylüyor
  9. Notlardaki her rakam veri katmanındaki bir değerin kendi
     basamağında doğru yuvarlanmışı (tolerans değil, yuvarlama)

9. KURALIN GÜCÜ ÖLÇÜLDÜ — OLMADIĞI GÜÇ ONA ATFEDİLMESİN.
Havuz 10.531 değer taşıyor; yıl türevleri küçük tam sayıları neredeyse
tamamen dolduruyor. Rastgele uydurma bir sayının kurala TAKILMADAN geçme
oranı ölçüldü:
    1–1000 arası tam sayı        %54,7'si geçiyor
    1–100 arası bir ondalıklı    %33,8'i geçiyor
    1–1000 arası bir ondalıklı    %9,5'i geçiyor
    1–100 arası iki ondalıklı     %6,8'i geçiyor
Havuz daraltılarak denendi (×100 çıkarma, ölçekleri 1e3'e indirme); tam
sayıda en iyi sonuç %42,9 oldu — kusur ölçek türevlerinde değil, altmış
yıllık serilerin kendisinde. Dolayısıyla bu kural KABA UYDURMAYI yakalar:
veriyle hiç ilgisi olmayan büyük ya da çok basamaklı bir rakam geçemez.
Makul görünen küçük bir tam sayıyı yakalayacağına GÜVENİLMEZ. Notlardaki
kritik rakamlar ayrıca gözle data.json'a bakılarak kuruldu.

Çalıştırma: python3 dogrula_grafik.py
"""
from __future__ import annotations

import json
import pathlib
import re
import sys

KOK = pathlib.Path(__file__).parent
VERI = json.loads((KOK / 'data.json').read_text(encoding='utf-8'))
TANIM = json.loads((KOK / 'grafikler.json').read_text(encoding='utf-8'))
hata: list[str] = []
yol_sayisi = 0

#: Bu alanların ucu sayı olmak ZORUNDA DEĞİL — küme taşıyorlar.
KUME_ALANLARI = {'harita', 'liste'}


def coz(yol: str):
    """'a.b.0.c' → değer. Bulunamazsa KeyError."""
    cur = VERI
    for parca in yol.split('.'):
        if isinstance(cur, list):
            cur = cur[int(parca)]
        elif isinstance(cur, dict):
            cur = cur[parca]
        else:
            raise KeyError(yol)
    return cur


def gez(dugum, iz: str, alan: str | None = None):
    """@yol'ları çözer ve yerine koyar."""
    global yol_sayisi
    if isinstance(dugum, str) and dugum.startswith('@'):
        yol = dugum[1:]
        yol_sayisi += 1
        try:
            v = coz(yol)
        except (KeyError, IndexError, ValueError):
            hata.append(f"{iz}: @yol ÇÖZÜLMEDİ · {yol}")
            return None
        if alan not in KUME_ALANLARI and not isinstance(v, (int, float)):
            hata.append(f"{iz}: @yol SAYI DEĞİL · {yol} → {type(v).__name__}")
        return v
    if isinstance(dugum, dict):
        return {k: gez(x, f'{iz}.{k}', k) for k, x in dugum.items()}
    if isinstance(dugum, list):
        return [gez(x, f'{iz}[{i}]') for i, x in enumerate(dugum)]
    return dugum


cozulmus = {}
for gid, g in TANIM['grafikler'].items():
    cozulmus[gid] = gez(g, gid)

for gid, g in TANIM['grafikler'].items():
    c, tur = cozulmus[gid], g.get('tur')

    # ── Kural 3 ve 4 — cizgi şekli ────────────────────────────────────────
    if tur == 'cizgi':
        for i, s in enumerate(g.get('seriler', [])):
            for kacak in ('liste', 'harita', 'x', 'y'):
                if kacak in s:
                    hata.append(f"{gid}.seriler[{i}]: '{kacak}' serinin ÜST "
                                "DÜZEYİNDE — model onu 'noktalar' altında arar, "
                                "burada kalırsa grafik sessizce çizilmez")
            n = s.get('noktalar')
            if not isinstance(n, dict):
                hata.append(f"{gid}.seriler[{i}]: 'noktalar' sözlüğü yok")
                continue
            if 'harita' not in n and 'liste' not in n:
                hata.append(f"{gid}.seriler[{i}].noktalar: ne 'harita' ne 'liste'")
                continue
            if 'harita' in n:
                h = cozulmus[gid]['seriler'][i]['noktalar']['harita']
                if not isinstance(h, dict) or not h:
                    hata.append(f"{gid}.seriler[{i}]: harita boş ya da sözlük değil")
                    continue
                for k, v in h.items():
                    if re.fullmatch(r'-?\d+(\.\d+)?', str(k)) is None:
                        hata.append(f"{gid}.seriler[{i}]: x ekseni SAYISAL DEĞİL "
                                    f"({k!r}) — seri sessizce boş kalır")
                        break
                    if not isinstance(v, (int, float)):
                        hata.append(f"{gid}.seriler[{i}]: y değeri sayı değil ({v!r})")
                        break

    # ── Kural 5 — ikili_cubuk ─────────────────────────────────────────────
    if tur == 'ikili_cubuk':
        n = len(g.get('seriler', []))
        if n < 2:
            hata.append(f"{gid}: ikili_cubuk en az iki seri ister, {n} var")
        for i, s in enumerate(g.get('satirlar', [])):
            if len(s.get('degerler', [])) != n:
                hata.append(f"{gid}.satirlar[{i}]: {len(s.get('degerler', []))} "
                            f"değer, {n} seri — eşleşmiyor")

    # ── Kural 6 — ticaret_akisi'nın iki yakası ────────────────────────────
    if tur == 'ticaret_akisi':
        if not g.get('merkez', {}).get('etiket'):
            hata.append(f"{gid}: merkez etiketi yok — model null döndürür")
        for yaka in ('giren', 'cikan'):
            kollar = c.get(yaka) or []
            if not kollar:
                hata.append(f"{gid}: '{yaka}' BOŞ — tek yakası boş akış model "
                            "tarafından null döndürülür, grafik hiç çizilmez")
            for j, k in enumerate(kollar):
                if not isinstance(k.get('deger'), (int, float)):
                    hata.append(f"{gid}.{yaka}[{j}]: değer sayı değil — kol düşer")
        if not (g.get('giren_basligi') and g.get('cikan_basligi')):
            hata.append(f"{gid}: yaka başlıkları eksik — Dart'ta varsayılan metin "
                        "YOK, başlık yazılmazsa hiç çizilmez")

    # ── Kural 7 — boş grafik ──────────────────────────────────────────────
    if tur in ('siralama', 'kunye', 'kartlar'):
        alan = {'siralama': 'satirlar', 'kunye': 'kalemler', 'kartlar': 'kartlar'}[tur]
        if not g.get(alan):
            hata.append(f"{gid}: '{alan}' boş")

# ── Kural 8 — ayna istatistik notta söylenmiş mi ──────────────────────────
# Ticaret rakamlarının tamamı Türkiye'nin beyanından. Bunu söylemeyen bir
# grafik okura Irak'ın kendi rakamını gösteriyormuş gibi görünür.
for gid in ('fasillar', 'akis'):
    notu = json.dumps(TANIM['grafikler'][gid].get('not', {}), ensure_ascii=False)
    if 'muhabir' not in notu.lower() and 'reporting' not in notu.lower() \
            and 'beyan' not in notu.lower():
        hata.append(f"{gid}: notu AYNA İSTATİSTİĞİ söylemiyor — rakamlar "
                    "Türkiye'nin beyanından")

# ══ Kural 9 — NOT İÇİNDEKİ SAYI İZİ ═══════════════════════════════════════
# Grafik notları serbest metin; @yol çözülmüyor, dolayısıyla sekiz kural da
# oradaki rakamlara hiç bakmıyordu. DSİ'nin grafik doğrulayıcısında da yoktu.
# Metin tarafındaki sayı avcısının karşılığı burada kuruluyor.
#
# ÖLÇÜT YUVARLAMA: yazılan sayı, veri katmanındaki bir değerin KENDİ
# BASAMAĞINDA doğru yuvarlanmışı olmalı. "270 bin" kabul edilir çünkü
# 269.940/1000 = 269,94 → 270. "271 bin" edilmez. Tolerans değil, yuvarlama.
havuz: set[float] = set()


def _topla(o) -> None:
    if isinstance(o, dict):
        # ANAHTARLAR DA VERİDİR. Seriler {"1990": 9600000} biçiminde duruyor;
        # yıl ANAHTARIN kendisi. Yalnızca values() gezilirse notta geçen her
        # yıl "veride yok" diye işaretlenir ve kural gürültüye dönüşür —
        # yazar da onu kapatır. İlk çalıştırmada tam bu oldu.
        for k, v in o.items():
            _topla(k); _topla(v)
    elif isinstance(o, list):
        for v in o: _topla(v)
    elif isinstance(o, bool):
        pass
    elif isinstance(o, (int, float)):
        havuz.add(float(o))
    elif isinstance(o, str):
        # Dize içindeki sayılar da havuza: BM alıntılarındaki '90%', '80,000'
        for parca in re.findall(r'\d+(?:[.,]\d{1,3})*(?:[.,]\d+)?', o):
            for aday in (parca.replace(',', ''), parca.replace('.', ''),
                         parca.replace(',', '.')):
                try: havuz.add(float(aday))
                except ValueError: pass
        for y in re.findall(r'(?:18|19|20)\d{2}', o):
            havuz.add(float(y))


_topla(VERI)
# Ölçek ve işaret türevleri — havuz bilerek geniş (§2.2.2): dar havuz meşru
# cümleyi işaretler, yazar da denetimi gevşetir.
for v in list(havuz):
    for k in (1e3, 1e6, 1e9):
        havuz.add(v / k); havuz.add(v * k)
    havuz.add(abs(v)); havuz.add(v * 100); havuz.add(v / 100)
havuz |= {float(n) for n in range(0, 32)}     # sıra ve küçük tam sayılar
havuz_s = sorted(havuz)


def _yuvarlanir(y: float, basamak: int) -> bool:
    return any(round(v, basamak) == y for v in havuz_s)


SAYI_TR = re.compile(r'(?<![\w.,])(\d{1,3}(?:\.\d{3})+|\d+)(?:,(\d+))?(?![\w])')
SAYI_EN = re.compile(r'(?<![\w.,])(\d{1,3}(?:,\d{3})+|\d+)(?:\.(\d+))?(?![\w])')

for gid, g in TANIM['grafikler'].items():
    for alan in ('not', 'baslik', 'birim', 'kaynak'):
        deger = g.get(alan)
        if not deger:
            continue
        ciftler = deger.items() if isinstance(deger, dict) else [('tr', deger)]
        for dil, metin in ciftler:
            if not isinstance(metin, str):
                continue
            desen = SAYI_EN if dil == 'en' else SAYI_TR
            for m in desen.finditer(metin):
                tam = m.group(1).replace('.', '').replace(',', '')
                kesir = m.group(2) or ''
                try: y = float(f'{tam}.{kesir}' if kesir else tam)
                except ValueError: continue
                if not _yuvarlanir(y, len(kesir)):
                    hata.append(f"{gid}.{alan}[{dil}]: '{m.group(0)}' VERİDE YOK "
                                "— not rakamı veri katmanına dayanmalı")

if hata:
    print('GRAFİK SINAMASI BAŞARISIZ:\n', file=sys.stderr)
    for h in hata:
        print('  ✗ ' + h, file=sys.stderr)
    sys.exit(1)

print(f"✓ {len(TANIM['grafikler'])} grafik · {yol_sayisi} @yol çözüldü · 9 kural geçti")
for gid, g in TANIM['grafikler'].items():
    n = (len(g.get('satirlar', [])) or len(g.get('kalemler', []))
         or len(g.get('kartlar', [])) or len(g.get('seriler', []))
         or len(g.get('giren', [])))
    print(f"  {gid:16s} {g['tur']:16s} {n} öğe")
