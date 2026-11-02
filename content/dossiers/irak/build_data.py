#!/usr/bin/env python3
"""Irak — `_raw/cikarim.json` → `data.json`. Veri sayfası burada KİLİTLENİR.

EKSEN: Türkiye'nin tarım ihracatının yedide biri tek bir komşuya gidiyor,
ters yön neredeyse boş. GÖVDE ise Irak tarımının kendisi — kullanıcı şartı
(2 Kasım 2026): "yalnızca Türkiye ile ilişkileri üzerinden bir dosya
oluşmasın".

YEDİ DOĞRULAMA — biri bile tutmazsa üretim DURUR:
  1. Her blok `_kapsam` ve `_kaynak_niteligi` taşıyor (§2.2)
  2. AYNA İSTATİSTİK gerçekten zorunlu mu — Irak'ın muhabir satırları sayılıyor
  3. Fasıl dökümünün toplamı manşet rakamla tutuyor
  4. Tarım ihracatı toplam ihracatı aşamaz
  5. BOŞ SONUÇ SIFIR DEĞİL — hiçbir ticaret kalemi 0 olarak yazılmamış
  6. Tarımın payı İKİ PAYDAYLA birden duruyor (GSYH ve petrol dışı GSYH)
  7. Seriler kendi içinde tutarlı; çöküş iddiaları veriden HESAPLANIYOR

Çalıştırma: ~/tarim_ai_pipeline/venv/bin/python build_data.py
"""
from __future__ import annotations

import json
import pathlib
import sys

KOK = pathlib.Path(__file__).parent
ham = json.loads((KOK / '_raw' / 'cikarim.json').read_text(encoding='utf-8'))
hata: list[str] = []
govde = {k: v for k, v in ham.items() if not k.startswith('_')}


# ── 1. Kapsam ve kaynak niteliği zorunlu ──────────────────────────────────
for ad, blok in govde.items():
    if not isinstance(blok, dict):
        hata.append(f"BLOK SÖZLÜK DEĞİL · '{ad}'"); continue
    if not blok.get('_kapsam'):
        hata.append(f"KAPSAM YOK · '{ad}'")
    if not blok.get('_kaynak_niteligi'):
        hata.append(f"KAYNAK NİTELİĞİ YOK · '{ad}'")

t = govde['ticaret']

# ── 2. Ayna istatistik gerçekten zorunlu mu ───────────────────────────────
# Bu dosyanın en büyük kısıtı. İddia "Irak rapor vermiyor" — ve iddia
# ölçülmeden yazılmıyor. Irak muhabir olarak üç yılda kaç satır döndürüyor?
sessiz = [y for y, n in t['irak_muhabir_satir'].items()
          if n is not None and n <= 1]
if len(sessiz) < 3:
    hata.append("AYNA İSTATİSTİK GEREKÇESİ ZAYIF · Irak beklenenden çok "
                f"satır veriyor: {t['irak_muhabir_satir']}")

# ── 3. Fasıl dökümü manşetle tutuyor mu ───────────────────────────────────
if t.get('fasillar'):
    fasil_toplam = sum(f['deger'] for f in t['fasillar'])
    fark = abs(fasil_toplam - t['tarim_ihracat_irak'])
    if fark > 1:
        hata.append(f"FASIL TOPLAMI TUTMUYOR · {fasil_toplam:,.0f} ≠ "
                    f"{t['tarim_ihracat_irak']:,.0f}")
    if len(t['fasillar']) != 24:
        hata.append(f"FASIL SAYISI {len(t['fasillar'])} · HS 01-24 = 24 olmalı")
else:
    hata.append('FASIL DÖKÜMÜ YOK')

# ── 4. Tarım, toplamı aşamaz ──────────────────────────────────────────────
if t['toplam_ihracat_irak'] and t['tarim_ihracat_irak'] > t['toplam_ihracat_irak']:
    hata.append('TARIM İHRACATI TOPLAM İHRACATI AŞIYOR — çift sayım şüphesi')

# ── 5. Boş sonuç sıfır değildir (§2.2.1, dokuzuncu tuzak) ─────────────────
# Comtrade veri bulamayınca boş dizi döndürüyor; toplamı alan kod bunu 0
# sanar ve "hiç ticaret olmamış" diye okur. Bu dosyada ölçüldü: ABD için
# ısrarla boş dizi geliyor. Sıfır yazılmış bir kalem varsa üretim durur.
for ad in ('tarim_ihracat_irak', 'tarim_ihracat_dunya',
           'toplam_ihracat_irak', 'tarim_ithalat_irak'):
    if t[ad] == 0:
        hata.append(f"TİCARET KALEMİ SIFIR · '{ad}' — boş sonuç sıfır olarak "
                    "yazılmış olabilir, None olmalıydı")
    if t[ad] is None:
        hata.append(f"TİCARET KALEMİ ÇEKİLEMEDİ · '{ad}'")

# ── 6. Tarımın payı iki paydayla birden ───────────────────────────────────
# Dünya Bankası API'si TOPLAM GSYH payını, aynı kurumun 2014 belgesi PETROL
# DIŞI GSYH payını veriyor. Yalnızca birini taşımak Irak'ta tarımın yerini
# yanlış gösterir — petrol ekonomisinde toplam GSYH payı yanıltıcıdır.
m, s = govde['makro'], govde['su']
if not (m.get('tarim_gsyh_payi') and s.get('petrol_disi_gsyh_payi_yuzde')):
    hata.append('TARIM PAYI TEK PAYDAYLA · iki payda da bulunmalı')

# ── 7. Seriler ve çöküş hesapları ─────────────────────────────────────────
u = govde['uretim']['urunler']
u_hayvan = govde['uretim']['hayvan']


def seri(ad: str) -> dict[int, float]:
    return {int(y): v for y, v in u.get(ad, {}).items()}


pirinc = seri('Rice|Production')
arpa = seri('Barley|Production')
bugday = seri('Wheat|Production')
for ad, d in (('pirinç', pirinc), ('arpa', arpa), ('buğday', bugday)):
    if len(d) < 50:
        hata.append(f"{ad} serisi kısa · {len(d)} yıl")

# Çöküş İDDİA EDİLMİYOR, HESAPLANIYOR.
if pirinc.get(2020) and pirinc.get(2022):
    pirinc_dusus = round((1 - pirinc[2022] / pirinc[2020]) * 100, 1)
    if pirinc_dusus < 50:
        hata.append(f"PİRİNÇ İDDİASI TUTMUYOR · düşüş %{pirinc_dusus}")
else:
    hata.append('PİRİNÇ SERİSİNDE 2020 ya da 2022 YOK')


# ── 8. KAPSAM ÇARPIŞMASI — bataklık ölçeği ile ülke ölçeği ────────────────
# BM raporu mandayı BATAKLIKTA sayıyor, FAOSTAT ÜLKEDE. İki rakam yan yana
# yazılırsa okur manda sayısının altmış kat yanlış olduğunu sanır. Burada
# ölçülüyor: aynı yıl için iki kapsam arasında en az bir büyüklük mertebesi
# fark YOKSA, ayrım gereksizdir ve uyarı yanlış yere konmuştur; varsa uyarı
# ZORUNLUDUR ve blokta durmak zorundadır.
b = govde['bataklik']
manda_ulke_2011 = {int(y): v for y, v in u_hayvan.get('Buffalo', {}).items()}.get(2011)
if manda_ulke_2011 is None:
    hata.append('MANDA 2011 YOK · kapsam karşılaştırması yapılamıyor')
else:
    kat = manda_ulke_2011 / 5000
    if kat < 10:
        hata.append(f"KAPSAM AYRIMI GEREKSİZ · bataklık ve ülke ölçeği yalnızca "
                    f"{kat:.1f} kat ayrı — uyarı yanlış yere konmuş")
    elif not b.get('_olcek_uyarisi'):
        hata.append(f"ÖLÇEK UYARISI YOK · bataklık {kat:.0f} kat farklı bir şey "
                    "sayıyor, blok bunu söylemeli")

# ── Türetilmiş ────────────────────────────────────────────────────────────
manda = {int(y): v for y, v in u_hayvan['Buffalo'].items()}
koyun = {int(y): v for y, v in u_hayvan['Sheep'].items()}
keci = {int(y): v for y, v in u_hayvan['Goats'].items()}
sigir = {int(y): v for y, v in u_hayvan['Cattle'].items()}
# Dip 1990 SONRASINDA aranıyor: 1970'lerin yüksek tabanı dibi gizlerdi
manda_dip_yil = min((y for y in manda if y >= 1990), key=lambda y: manda[y])

tavuk = {int(y): v for y, v in u_hayvan['Chickens'].items()}
misir = seri('Maize (corn)|Production')
m_alan = seri('Maize (corn)|Area harvested')
domates = seri('Tomatoes|Production')


def verim_cifti(urun: str) -> dict:
    """İlk ortak yıl ve 2024 için verim, alan ve ikisinin katı.

    ÜRETİM = ALAN × VERİM. Ayrıştırılmadan bakılan bir üretim serisi
    yanıltır: hurmada üretim artmış görünüyor ama artış ALANDAN geliyor,
    verim düşmüş. Bu ayrım dosyanın iki bölümünü birden taşıyor."""
    p_ = seri(f'{urun}|Production')
    a_ = seri(f'{urun}|Area harvested')
    ortak = sorted(set(p_) & set(a_))
    ilk, son = ortak[0], ortak[-1]
    return {'ilk_yil': ilk, 'son_yil': son,
            'verim_ilk': round(p_[ilk] / a_[ilk], 2),
            'verim_son': round(p_[son] / a_[son], 2),
            'verim_kat': round((p_[son] / a_[son]) / (p_[ilk] / a_[ilk]), 2),
            'alan_ilk': a_[ilk], 'alan_son': a_[son],
            'alan_kat': round(a_[son] / a_[ilk], 2)}


verim_tablosu = {ad: verim_cifti(urun) for ad, urun in (
    ('bugday', 'Wheat'), ('arpa', 'Barley'), ('pirinc', 'Rice'),
    ('hurma', 'Dates'), ('misir', 'Maize (corn)'), ('domates', 'Tomatoes'))}

hurma = seri('Dates|Production')
hurma_d = {int(y): v for y, v in govde['uretim']['hurma_dunya'].items()}
ortak_hurma = sorted(set(hurma) & set(hurma_d))

govde['turetilmis'] = {
    '_kaynak_niteligi': 'TÜRETİLMİŞ — yukarıdaki blokların hesabı',
    '_kapsam': 'Türetilmiş; her satırın kapsamı kendi kaynağınınkidir',

    # Eksenin kendisi
    'irak_payi_yuzde': round(t['tarim_ihracat_irak'] / t['tarim_ihracat_dunya'] * 100, 1),
    'dengesizlik_kat': round(t['tarim_ihracat_irak'] / t['tarim_ithalat_irak'], 0),
    'tarimin_toplam_ihracattaki_payi_yuzde': round(
        t['tarim_ihracat_irak'] / t['toplam_ihracat_irak'] * 100, 1),

    # Ekmek zinciri — un, hamur işleri ve hububat bir arada
    'ekmek_zinciri_usd': sum(f['deger'] for f in t['fasillar']
                             if f['fasil'] in ('10', '11', '19')),
    'ekmek_zinciri_payi_yuzde': round(
        sum(f['deger'] for f in t['fasillar'] if f['fasil'] in ('10', '11', '19'))
        / t['tarim_ihracat_irak'] * 100, 1),
    'arpa_alan_2020': {int(y): v for y, v in u['Barley|Area harvested'].items()}[2020],
    'arpa_alan_2022': {int(y): v for y, v in u['Barley|Area harvested'].items()}[2022],
    'hurma_1961': hurma[1961], 'hurma_2024': hurma[2024],
    'hurma_zirve_yil': max(hurma, key=hurma.get), 'hurma_zirve': max(hurma.values()),
    'ithalat_toplam_kontrol': sum(f['deger'] for f in t['ithalat_fasillar']),

    # ── VERİM Mİ, ALAN MI ────────────────────────────────────────────────
    # Üretim = alan × verim. Bir ülkenin neyi başardığı ancak bu ikisi
    # AYRIŞTIRILINCA görünür. Hurmada üretim 1,7 kat arttı diye "iyi gidiyor"
    # denemez: alan 2,4 kat artmış, verim DÜŞMÜŞ. Dünya payının inişinin
    # sebebi bu bölümde duruyor.
    **{f'verim_{ad}': deger for ad, deger in verim_tablosu.items()},

    # Tavuk — ülkenin en hızlı büyüyen sürüsü, hiçbir bölümde geçmiyordu
    'tavuk_1961': tavuk[1961], 'tavuk_2024': tavuk[2024],
    'tavuk_zirve_yil': max(tavuk, key=tavuk.get), 'tavuk_zirve': max(tavuk.values()),
    'tavuk_kat': round(tavuk[2024] / tavuk[1961], 1),

    # Sonradan gelen iki ürün
    'misir_alan_1961': m_alan[1961], 'misir_alan_2024': m_alan[2024],
    'misir_2024': misir[2024], 'misir_zirve_yil': max(misir, key=misir.get),
    'misir_zirve': max(misir.values()),
    'domates_zirve_yil': max(domates, key=domates.get),
    'domates_zirve': max(domates.values()), 'domates_2024': domates[2024],
    'domates_1961': domates[1961],

    # Çöküşler — hesaplanmış, iddia edilmemiş
    'pirinc_dusus_yuzde': round((1 - pirinc[2022] / pirinc[2020]) * 100, 1),
    'pirinc_2020': pirinc[2020], 'pirinc_2022': pirinc[2022],
    'arpa_dusus_yuzde': round((1 - arpa[2022] / arpa[2020]) * 100, 1),
    # ARPA GERİ GELMEDİ, PİRİNÇ GELDİ. Bu ayrım dosyanın iki bölümünü birden
    # belirliyor: §2.8'in "terk edilen ürün" kategorisi arpadır, pirinç değil.
    'arpa_en_dusuk_yil': min(arpa, key=arpa.get),
    'arpa_en_dusuk': min(arpa.values()),
    'arpa_2020': arpa[2020], 'arpa_2024': arpa[2024],
    'arpa_bugun_2020_yuzdesi': round(arpa[2024] / arpa[2020] * 100, 1),
    'pirinc_2024': pirinc[2024],
    'pirinc_bugun_2020_yuzdesi': round(pirinc[2024] / pirinc[2020] * 100, 1),
    'pirinc_alan_2020': {int(y): v for y, v in u['Rice|Area harvested'].items()}[2020],
    'pirinc_alan_2022': {int(y): v for y, v in u['Rice|Area harvested'].items()}[2022],
    'bugday_en_dusuk_yil': min(bugday, key=bugday.get),
    'bugday_en_dusuk': min(bugday.values()),
    'bugday_2014': bugday.get(2014), 'bugday_2015': bugday.get(2015),
    'bugday_isid_dusus_yuzde': round((1 - bugday[2015] / bugday[2014]) * 100, 1),


    # Manda ve koyun — İDDİA EDİLMİYOR, HESAPLANIYOR. Ülke ölçeği (FAOSTAT).
    # Mandanın dibi ile BM raporunun kurutma takvimi örtüşüyor; dosya bunu
    # ZAMANLAMA olarak yazar, sebep olarak değil — rapor manda sayımını
    # bataklık ölçeğinde veriyor, ülke eğrisinin sebebini söylemiyor.
    'manda_dip_yil': manda_dip_yil,
    'manda_dip': manda[manda_dip_yil],
    'manda_bugun': manda[max(manda)],
    'manda_dipten_kat': round(manda[max(manda)] / manda[manda_dip_yil], 1),
    'manda_1990_degisim_yuzde': round((manda[2024] / manda[1990] - 1) * 100, 1),
    'koyun_1990_degisim_yuzde': round((koyun[2024] / koyun[1990] - 1) * 100, 1),
    'koyun_zirve_yil': max(koyun, key=koyun.get),
    'koyun_zirve': max(koyun.values()),
    'koyun_bugun': koyun[max(koyun)],
    'keci_1990_degisim_yuzde': round((keci[2024] / keci[1990] - 1) * 100, 1),
    'sigir_1990_degisim_yuzde': round((sigir[2024] / sigir[1990] - 1) * 100, 1),
    # Bataklık ölçeği — BM raporundan, ÜLKE eğrisiyle aynı cümleye girmez
    'bataklik_manda_payi_2011_yuzde': round(5000 / manda[2011] * 100, 1),
    'manda_ulke_2011': manda[2011],

    # Hurmada kaybedilen yer
    'hurma_ilk_yil': ortak_hurma[0], 'hurma_son_yil': ortak_hurma[-1],
    'hurma_pay_ilk_yuzde': round(hurma[ortak_hurma[0]] / hurma_d[ortak_hurma[0]] * 100, 1),
    'hurma_pay_son_yuzde': round(hurma[ortak_hurma[-1]] / hurma_d[ortak_hurma[-1]] * 100, 1),
    'hurma_irak_kat': round(hurma[ortak_hurma[-1]] / hurma[ortak_hurma[0]], 1),
    'hurma_dunya_kat': round(hurma_d[ortak_hurma[-1]] / hurma_d[ortak_hurma[0]], 1),

    # Hurma payı SERİSİ — grafiğe gidiyor. Ortak yılı olmayan yıl atlanıyor;
    # eksik yılı sıfır saymak payı yapay olarak düşürürdü.
    'hurma_pay_serisi': {str(y): round(hurma[y] / hurma_d[y] * 100, 2)
                         for y in ortak_hurma},

    # ORTAK YIL (§2.7) — üç kaynağın üç ayrı son yılı var
    '_ortak_yil_notu': (
        f"Comtrade {t['yil']} · FAOSTAT {max(bugday)} · Dünya Bankası kalem "
        "kalem değişiyor. Karşılaştırma ortak yıldan kurulur, ileri not "
        "atlanmaz."),
    'comtrade_yil': t['yil'],
    'faostat_son_yil': max(bugday),
}

if hata:
    print('ÜRETİM DURDU:\n', file=sys.stderr)
    for h in hata:
        print('  ✗ ' + h, file=sys.stderr)
    sys.exit(1)

tt = govde['turetilmis']
out = {
    '_dosya': 'Irak — Ülke Dosyası Sayı 05 · veri katmanı',
    '_uretim': 'build_data.py — elle düzenlenmez',
    # Türkçe sayı biçimi: ondalık VİRGÜL. Bu dize data.json'da duruyor ve
    # okunuyor; İngilizce biçim bırakılırsa metne de öyle geçer (§8.10/4).
    '_eksen': (f"Türkiye'nin tarım ihracatının "
               f"%{str(tt['irak_payi_yuzde']).replace('.', ',')}'ü tek bir "
               f"komşuya gidiyor; ters yön {tt['dengesizlik_kat']:,.0f} kat daha "
               "küçük."),
    '_gövde_notu': ("Eksen ticaret ama dosyanın gövdesi Irak tarımının kendisi: "
                    "savaş, su, tuzluluk, pirincin kayboluşu, hurmada kaybedilen "
                    "yer ve hayvancılık kendi bölümlerini alıyor."),
    '_ayna_siniri': ("Bütün ticaret rakamları TÜRKİYE'NİN beyanından. Irak "
                     "Comtrade'e muhabir olarak rapor vermiyor; metin bunu "
                     "açıkça yazar."),
    **govde,
}
(KOK / 'data.json').write_text(
    json.dumps(out, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')

print(f"✓ data.json · {len(govde)} blok")
print(f"  eksen: %{tt['irak_payi_yuzde']} · dengesizlik {tt['dengesizlik_kat']:,.0f} kat")
print(f"  pirinç düşüşü %{tt['pirinc_dusus_yuzde']} · buğday IŞİD düşüşü "
      f"%{tt['bugday_isid_dusus_yuzde']}")
print(f"  manda dibi {tt['manda_dip_yil']} · {tt['manda_dip']:,.0f} → "
      f"bugün {tt['manda_bugun']:,.0f} (dipten {tt['manda_dipten_kat']} kat)")
print(f"  tavuk {tt['tavuk_1961']:,.0f} → {tt['tavuk_2024']:,.0f} bin baş ({tt['tavuk_kat']} kat)")
print(f"  hurma verim {tt['verim_hurma']['verim_ilk']} → {tt['verim_hurma']['verim_son']} t/ha "
      f"({tt['verim_hurma']['verim_kat']} kat) · alan {tt['verim_hurma']['alan_kat']} kat")
print(f"  hurma payı %{tt['hurma_pay_ilk_yuzde']} → %{tt['hurma_pay_son_yuzde']}")
