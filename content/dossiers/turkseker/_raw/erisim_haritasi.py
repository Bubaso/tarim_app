#!/usr/bin/env python3
"""Türkşeker dosyası · tur 1 — hangi kaynak bu ağdan iş görüyor?

NEDEN BETİK. Irak ve Avustralya dosyalarında kapalı kapılar turun en pahalı
sürprizi oldu. Önce ölçülüyor, sonra plan yapılıyor.

DURUM KODU TEK BAŞINA YALAN SÖYLÜYOR (§2.12.1, İspanya vakası). Üç şey
birlikte okunuyor: kod + content-type + gövde uzunluğu.
  · 200 + text/html, gövde 150 karakter   → kabuk, veri yok
  · 200 + text/html, PDF beklenirken      → yumuşak 404
  · 200 + gövde 2 KB, JS uygulaması       → tarayıcısız okunamaz
  · 302 → Hata.aspx, 200 + 45 KB          → ŞİŞMAN HATA SAYFASI

ŞİŞMAN HATA SAYFASI — TÜRKŞEKER DOSYASINDA ÖLÇÜLDÜ. Bu betiğin ilk hâli
gövde uzunluğuna bakıyordu (html için 2000 bayt eşiği) ve ince kabuğu
yakalıyordu. Türkşeker'in sitesi bilinmeyen yolu 302 ile `Hata.aspx`'e
yönlendiriyor; o sayfa 200 ve 45 KB. Eşik onu asla yakalamaz, çünkü sorun
boyut değil KİMLİK. Ayırt edici işaret SON ADRES: istenen yol ile varılan
yol başka. Artık son adres kaydediliyor ve hata sayfasına varan istek
açık sayılmıyor.
User-Agent'ta kişisel bilgi yok.
"""
from __future__ import annotations
import json, pathlib, socket, ssl, time, urllib.error, urllib.request

KOK = pathlib.Path(__file__).parent
UA = {'User-Agent': 'tarimportali.net dosya arastirmasi'}

HEDEFLER = [
    # (ad, adres, sınıf, ne beklendiği)
    # ── KURUMUN KENDİSİ ───────────────────────────────────────────────────
    ("Türkşeker", "https://www.turkseker.gov.tr/", "BİRİNCİL", "html"),
    ("Türkşeker — şeker fabrikaları", "https://www.turkseker.gov.tr/?ModulID=3&MenuID=22", "BİRİNCİL", "html"),
    ("Türkşeker — tarihçe", "https://www.turkseker.gov.tr/?ModulID=3&MenuID=3", "BİRİNCİL", "html"),
    ("Türkşeker — faaliyet raporları", "https://www.turkseker.gov.tr/?ModulID=8&MenuID=36", "BİRİNCİL", "html"),
    ("Türkşeker — 2025 sektör raporu", "https://www.turkseker.gov.tr/data/dokumanlar/2025_sektor_raporu.pdf", "BİRİNCİL", "pdf"),
    ("Türkşeker — ana statü", "https://www.turkseker.gov.tr/data/dokumanlar/Ana_Statu.pdf", "BİRİNCİL", "pdf"),
    ("Türkşeker — stratejik plan", "https://www.turkseker.gov.tr/Belgeler/stratejik_plan_12_09_2024_v4.pdf", "BİRİNCİL", "pdf"),
    ("Türkşeker — kuruluş mevzuatı", "https://www.turkseker.gov.tr/?ModulID=3&MenuID=30", "BİRİNCİL", "html"),
    ("Türkşeker — makine fabrikaları", "https://www.turkseker.gov.tr/?ModulID=3&MenuID=25", "BİRİNCİL", "html"),
    ("Türkşeker kütüphanesi (Bakanlık kataloğu)", "https://kutuphane.tarimorman.gov.tr/vufind/", "BİRİNCİL", "html"),
    # ── DÜZENLEYİCİ VE SAHİPLİK ──────────────────────────────────────────
    ("Şeker Kurumu (kapatıldı, arşiv)", "https://www.sekerkurumu.gov.tr/", "BİRİNCİL", "html"),
    ("Özelleştirme İdaresi", "https://www.oib.gov.tr/", "BİRİNCİL", "html"),
    ("Tarım ve Orman Bakanlığı", "https://www.tarimorman.gov.tr/", "BİRİNCİL", "html"),
    ("Resmî Gazete arşivi", "https://www.resmigazete.gov.tr/", "BİRİNCİL", "html"),
    ("Mevzuat Bilgi Sistemi — 4634 Şeker Kanunu", "https://www.mevzuat.gov.tr/MevzuatMetin/1.5.4634.pdf", "BİRİNCİL", "pdf"),
    ("Mevzuat — 6747 (mülga) Şeker Kanunu", "https://www.mevzuat.gov.tr/MevzuatMetin/1.3.6747.pdf", "BİRİNCİL", "pdf"),
    # ── ÜRETİCİ ÖRGÜTÜ ───────────────────────────────────────────────────
    ("Pankobirlik", "https://www.pankobirlik.com.tr/", "BİRİNCİL", "html"),
    # ── İSTATİSTİK ───────────────────────────────────────────────────────
    ("TÜİK bitkisel üretim", "https://data.tuik.gov.tr/Kategori/GetKategori?p=tarim-111", "BAĞIMSIZ", "html"),
    ("TÜİK API", "https://biruni.tuik.gov.tr/medas/?kn=92&locale=tr", "BAĞIMSIZ", "html"),
    ("FAOSTAT toplu indirme dizini", "https://bulks-faostat.fao.org/production/", "BAĞIMSIZ", "html"),
    ("USDA PSD — şeker toplu CSV", "https://apps.fas.usda.gov/psdonline/downloads/psd_sugar_csv.zip", "BAĞIMSIZ", "zip"),
    ("USDA FAS GAIN arama", "https://gain.fas.usda.gov/", "BAĞIMSIZ", "html"),
    ("ISO — Uluslararası Şeker Örgütü", "https://www.isosugar.org/", "BAĞIMSIZ", "html"),
    ("Eurostat şeker", "https://ec.europa.eu/eurostat/databrowser/view/apro_cpsh1/default/table", "BAĞIMSIZ", "html"),
    ("UN Comtrade API", "https://comtradeapi.un.org/public/v1/preview/C/A/HS?reporterCode=792&period=2024&cmdCode=1701", "BAĞIMSIZ", "json"),
    # ── ARŞİV VE TARİH ───────────────────────────────────────────────────
    ("TBMM tutanak arşivi", "https://www.tbmm.gov.tr/tutanaklar/TUTANAK_SD.php", "BİRİNCİL", "html"),
    ("Cumhuriyet Arşivi (Devlet Arşivleri)", "https://www.devletarsivleri.gov.tr/", "BİRİNCİL", "html"),
    ("Wikimedia Commons API", "https://commons.wikimedia.org/w/api.php?action=query&format=json&list=search&srsearch=Alpullu", "BAĞIMSIZ", "json"),
]


def dene(adres: str, beklenen: str):
    istek = urllib.request.Request(adres, headers=UA)
    try:
        with urllib.request.urlopen(istek, timeout=25) as r:
            son_adres = r.geturl()
            govde = r.read(60000)
            ct = (r.headers.get('content-type') or '').split(';')[0]
            n = len(govde)
            tam = r.headers.get('content-length')
            kod = r.status
    except urllib.error.HTTPError as e:
        return {'kod': e.code, 'tur': None, 'bayt': None, 'teshis': f'HTTP {e.code}'}
    except (urllib.error.URLError, socket.timeout, ssl.SSLError, ConnectionError) as e:
        s = str(getattr(e, 'reason', e))[:50]
        return {'kod': 0, 'tur': None, 'bayt': None, 'teshis': f'bağlantı yok — {s}'}
    except Exception as e:
        return {'kod': None, 'tur': None, 'bayt': None, 'teshis': type(e).__name__}

    teshis = 'açık'
    # SON ADRES İLK SINANIYOR: şişman hata sayfası boyuttan anlaşılmıyor.
    if son_adres and son_adres != adres:
        dusuk = son_adres.lower()
        if any(k in dusuk for k in ('hata', 'error', '404', 'notfound', 'not-found')):
            return {'kod': kod, 'tur': ct, 'bayt': n,
                    'son_adres': son_adres,
                    'teshis': f'HATA SAYFASINA YÖNLENDİ — {son_adres[:70]}'}
    if beklenen == 'pdf' and ct != 'application/pdf':
        teshis = f'YUMUŞAK 404 — pdf beklenirken {ct}'
    elif beklenen == 'zip' and 'zip' not in ct and 'octet' not in ct:
        teshis = f'beklenmeyen tür: {ct}'
    elif beklenen == 'json' and 'json' not in ct:
        teshis = f'beklenmeyen tür: {ct}'
    elif beklenen == 'html' and n < 2000:
        teshis = f'KABUK — gövde {n} bayt'
    return {'kod': kod, 'tur': ct, 'bayt': int(tam) if tam and tam.isdigit() else n,
            'son_adres': son_adres if son_adres != adres else None,
            'teshis': teshis}


def main():
    sonuc = {'_ne': 'Mısır dosyası tur 1 erişim haritası',
             '_yontem': 'kod + content-type + gövde birlikte okunuyor (§2.12.1)',
             '_tarih': time.strftime('%Y-%m-%d'), 'kaynaklar': []}
    print(f"{'kaynak':42} {'sınıf':10} {'kod':>4}  teşhis")
    print('─' * 108)
    for ad, adres, sinif, bek in HEDEFLER:
        r = dene(adres, bek)
        r.update({'ad': ad, 'adres': adres, 'sinif': sinif, 'beklenen': bek})
        sonuc['kaynaklar'].append(r)
        isaret = '✓' if r['teshis'] == 'açık' else '✗'
        print(f"{isaret} {ad:40} {sinif:10} {str(r['kod']):>4}  {r['teshis']}")
        time.sleep(1.2)
    (KOK / 'erisim.json').write_text(json.dumps(sonuc, ensure_ascii=False, indent=1),
                                     encoding='utf-8')
    acik = sum(1 for k in sonuc['kaynaklar'] if k['teshis'] == 'açık')
    print(f"\n{acik}/{len(HEDEFLER)} açık → erisim.json")


if __name__ == '__main__':
    main()
