#!/usr/bin/env python3
"""Irak — ham kaynaklardan `cikarim.json` üretir.

EKSEN: Türkiye'nin tarım ihracatının yedide biri tek bir komşuya gidiyor ve
ters yön neredeyse boş. Ama dosyanın GÖVDESİ Irak tarımının kendisi —
kullanıcı şartı.

HER ALINTI METNE BAĞLANIYOR. Bir ibare kaynakta harfi harfine bulunamazsa
çıkarım DURUR — §2.2'nin "getir, hatırlama" kuralının koddaki karşılığı.
Boşluk toleransı var çünkü PDF çıkarıcısı kelime ortasına işaretsiz boşluk
sokuyor (§8.14.2'nin altıncı tuzağı).

BU DOSYADA DOĞRULAYICI AYRI YAZILIR (§8.14.2): `dogrula_metin.py` buradan
hiçbir şey içe aktarmaz, normalleştirmeyi baştan kurar. Ortak yardımcı
paylaşılsaydı üretici ile doğrulayıcı aynı yönde yanılırdı.

Çalıştırma: ~/tarim_ai_pipeline/venv/bin/python cikar.py
"""
from __future__ import annotations

import json
import pathlib
import re
import sys

from pypdf import PdfReader

KOK = pathlib.Path(__file__).parent
BELGE = KOK / 'kaynak_dosyalari'
hata: list[str] = []


def duz(s: str) -> str:
    return re.sub(r'[ \t]+', ' ', s.replace('\xad', ''))


def harf(s: str) -> str:
    """Boşluksuz harf dizisi — PDF'in kelime ortasına soktuğu boşluk için."""
    return re.sub(r'\s+', '', s).lower()


def pdf(ad: str, bas: int = 0, son: int | None = None) -> str:
    r = PdfReader(BELGE / ad)
    say = r.pages[bas:son] if son else r.pages[bas:]
    return duz('\n'.join(p.extract_text() or '' for p in say))


def bagla(kaynak: str, ibare: str, iz: str) -> str:
    if harf(ibare) not in harf(kaynak):
        hata.append(f"ALINTI BAĞLANMADI · {iz} · '{ibare[:70]}'")
    return ibare


# ══ 1. Ticaret — AYNA İSTATİSTİK ═══════════════════════════════════════════
tic = json.loads((KOK / 'ticaret.json').read_text(encoding='utf-8'))
banka = json.loads((KOK / 'banka.json').read_text(encoding='utf-8'))
uretim = json.loads((KOK / 'uretim.json').read_text(encoding='utf-8'))

ticaret = {
    '_kaynak_niteligi': 'BAĞIMSIZ — UN Comtrade, muhabir Türkiye',
    '_kapsam': f"HS 01-24 · {tic['yil']} · Türkiye'nin beyanı",
    '_ayna_uyarisi': (
        "IRAK KENDİ BEYANINI VERMİYOR. Comtrade'de Irak muhabir olarak "
        f"2018'de {tic['irak_muhabir_satir'].get('2018')}, 2020'de "
        f"{tic['irak_muhabir_satir'].get('2020')}, 2022'de "
        f"{tic['irak_muhabir_satir'].get('2022')} satır döndürüyor. Bütün "
        "ticaret rakamları Türkiye'nin beyanından okundu ve metinde bu "
        "açıkça yazılacak."),
    'yil': tic['yil'],
    'tarim_ihracat_irak': tic['tarim_ihracat_irak'],
    'tarim_ihracat_dunya': tic['tarim_ihracat_dunya'],
    'toplam_ihracat_irak': tic['toplam_ihracat_irak'],
    'tarim_ithalat_irak': tic['tarim_ithalat_irak'],
    'fasillar': tic['fasillar'],
    'irak_muhabir_satir': tic['irak_muhabir_satir'],
}

# ══ 2. Makro — BAĞIMSIZ ════════════════════════════════════════════════════
makro = {
    '_kaynak_niteligi': 'BAĞIMSIZ — Dünya Bankası göstergeleri',
    '_kapsam': 'Irak · en yeni dolu yıl; her kalem kendi yılını taşıyor',
    '_sulanan_notu': ("Sulanan arazi payı göstergesi Irak için BOŞ dönüyor. "
                      "Suyun belirleyici olduğu bir ülkede bu kalem "
                      "yayımlanmıyor; metinde boşluk olarak anılacak."),
    **{k: v for k, v in banka.items() if not k.startswith('_')},
}

# ══ 3. Üretim — BAĞIMSIZ ═══════════════════════════════════════════════════
uretim_blok = {
    '_kaynak_niteligi': 'BAĞIMSIZ — FAOSTAT',
    '_kapsam': uretim['_kapsam'],
    '_agrega_notu': uretim['_agrega_notu'],
    'urunler': uretim['urunler'],
    'hayvan': uretim['hayvan'],
    'hurma_dunya': uretim['hurma_dunya'],
}

# ══ 4. 1946 su protokolü — BİRİNCİL ════════════════════════════════════════
t46 = pdf('tbmm_ss241_1947_antlasma.pdf')
protokol = {
    '_kaynak_niteligi': ('BİRİNCİL — TBMM S. Sayısı 241, 1947 onay tasarısı; '
                         'antlaşma ve protokol metinleri ek olarak basılı'),
    '_kapsam': 'Türkiye–Irak · 29 Mart 1946 · yürürlüğe giriş 1947',
    'imza_tarihi': '29 Mart 1946',
    'baslik': bagla(t46, 'DÎCLE, FIRAT VE KOLLARI SULARININ DÜZENE KONMASI PROTOKOLÜ',
                    'protokol.baslik'),
    'protokol_sayisi': 6,
    'harcamalar_irakta': bagla(
        t46, 'bütün harcamaları Irak tarafından yüklenilecek', 'protokol.harcama'),
    'gozetleme_istasyonu': bagla(
        t46, 'Türkiye daimî gözetleme istasyonları kuracak', 'protokol.istasyon'),
    'gider_yarisi': bagla(
        t46, 'Türkiye ve Irak tarafından yarı', 'protokol.gider'),
    'telgraf_istasyonlari': bagla(
        t46, 'Dicle üzerindeki Diyarbakır, Cizre', 'protokol.telgraf'),
    'keban': bagla(t46, 'Fırat üzerindeki Keban', 'protokol.keban'),
    # Madde 4 — yapıların her biri ayrı anlaşmaya konu olacak ve TÜRKİYE'NİN
    # KENDİ sulama ve enerji kullanımı o anlaşmanın konusu. 1946'da, DSİ
    # kurulmadan yedi yıl önce yazılmış.
    #
    # ÇIKARICI TUZAĞI: PDF 'etme maksadiyle' ifadesini 'etmemaksadiyle' diye
    # birleştiriyor. harf() boşlukları atıyor, dolayısıyla ibare BOŞLUKLU
    # yazılabiliyor — ama kelime ortasına giren boşluk olsaydı da aynı yol
    # çalışırdı (§8.14.2, altıncı tuzak).
    'turkiyenin_kendi_kullanimi': bagla(
        t46,
        "Türkiye'nin sulama ve enerji elde etme maksadiyle onlardan "
        "faydalanması bakımından ayrı bir Anlaşmaya konu teşkil eyliyecektir",
        'protokol.kullanim'),
    # Madde 5 — Türkiye tasarılarını haber vermeyi kabul ediyor; onay almayı
    # değil. Fark metinde korunacak.
    'haber_verme': bagla(
        t46,
        "Irak'a haber vermeyi kabul eyler", 'protokol.haber'),
    '_keban_notu': ("Keban 1946'da bir TELGRAF GÖZLEM İSTASYONU olarak geçiyor. "
                    "Kurum Dosyası Sayı 05 (DSİ) aynı Keban'ı GAP'ın Fırat "
                    "üzerindeki beş barajından biri sayıyor."),
}

# ══ 5. Savaşın tarlaya hasarı — BAĞIMSIZ (FAO saha ölçümü) ═════════════════
fao16 = pdf('fao_savas_hasari_2016.pdf')
savas = {
    '_kaynak_niteligi': ('BAĞIMSIZ — FAO, Iraq Agriculture and Livelihoods '
                         'Needs Assessment, Şubat 2016'),
    '_kapsam': 'Kerkük, Ninova ve Selahaddin · yeni kurtarılmış alanlar · saha ölçümü',
    'ninova_bugday': bagla(
        fao16,
        'In Ninewa on average 32% of acres dedicated to wheat cultivations were '
        'badly damaged resulting in a lower yields, and 68% was completely lost',
        'savas.ninova'),
    'ninova_arpa': bagla(
        fao16,
        '43% of the acres used for barley were damaged while 57% was completely '
        'destroyed', 'savas.arpa'),
    'selahaddin': bagla(
        fao16,
        'About 70 to 80% of cultivated area with corn, wheat, and barley was '
        'damaged', 'savas.selahaddin'),
    'sebepler': bagla(
        fao16,
        'massive displacement of the local population, looting and destruction of '
        'silos and seed and fertilizer storage facilities as well as the collapse '
        'of government support in providing inputs', 'savas.sebep'),
    'ninova_bugday_agir_hasar_yuzde': 32,
    'ninova_bugday_tam_kayip_yuzde': 68,
    'ninova_arpa_hasar_yuzde': 43,
    'ninova_arpa_tam_kayip_yuzde': 57,
}

# ══ 6. Su ve toprak — BAĞIMSIZ (Dünya Bankası) ═════════════════════════════
db14 = pdf('db_sulama_drenaj_2014.pdf')
su = {
    '_kaynak_niteligi': 'BAĞIMSIZ — Dünya Bankası, PID P149803 (2014)',
    '_kapsam': 'Irak · 2014 tarihli proje belgesi',
    'dis_bagimlilik': bagla(
        db14,
        'Iraq is heavily dependent on the external water resources that are not '
        'subject to well-established cross-border agreements', 'su.bagimlilik'),
    'devre_disi_alan': bagla(
        db14,
        'almost 40 percent of historically-irrigated areas out of production',
        'su.devre_disi'),
    'tuzluluk': bagla(
        db14,
        '70 percent of crop land is affected by high soil salinity',
        'su.tuzluluk'),
    'petrol_disi_gsyh': bagla(
        db14,
        'The agricultural sector contributes to 35 percent of', 'su.gsyh'),
    'devre_disi_yuzde': 40,
    'tuzluluk_yuzde': 70,
    'petrol_disi_gsyh_payi_yuzde': 35,
    '_iki_payda_uyarisi': (
        "Dünya Bankası API'si tarımın TOPLAM GSYH payını veriyor; bu belge "
        "PETROL DIŞI GSYH payını veriyor. İkisi çelişmiyor, paydaları farklı. "
        "Yalnızca birini yazmak Irak'ta tarımın yerini yanlış gösterir."),
}

# ══ 7. Dünya su tablosu — BAĞIMSIZ (FAO) ═══════════════════════════════════
faosu = pdf('fao_dunya_su_kaynaklari.pdf')
dunya_su = {
    '_kaynak_niteligi': ('BAĞIMSIZ — FAO, Review of World Water Resources by '
                         'Country (AQUASTAT Water Reports 23)'),
    '_kapsam': 'Dünya · ülke listesi',
    '_tarih_uyarisi': ('Belge ESKİ. Metinde yılı belirtilmeden kullanılmayacak; '
                       'güncel bir rakam yerine NİTEL bir tespit için var.'),
    'yarisindan_fazlasi_disaridan': bagla(
        faosu,
        'other countries for over 50 percent of their renewable water resources',
        'dunyasu.liste'),
    'irak_listede': bagla(faosu, 'Iraq', 'dunyasu.irak'),
}

cikti = {
    '_dosya': 'Irak — Ülke Dosyası Sayı 05 · ham çıkarım',
    '_uretim': 'cikar.py — elle düzenlenmez',
    'ticaret': ticaret,
    'makro': makro,
    'uretim': uretim_blok,
    'protokol': protokol,
    'savas': savas,
    'su': su,
    'dunya_su': dunya_su,
}

if hata:
    print('ÇIKARIM DURDU:\n', file=sys.stderr)
    for h in hata:
        print('  ✗ ' + h, file=sys.stderr)
    sys.exit(1)

(KOK / 'cikarim.json').write_text(
    json.dumps(cikti, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
print(f"✓ cikarim.json · {len([k for k in cikti if not k.startswith('_')])} blok")
print(f"  Irak'a tarım {ticaret['tarim_ihracat_irak']/1e9:,.2f} milyar $ · "
      f"ters yön {ticaret['tarim_ithalat_irak']/1e6:,.1f} M$")
