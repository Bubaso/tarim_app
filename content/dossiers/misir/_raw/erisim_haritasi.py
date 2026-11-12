#!/usr/bin/env python3
"""Mısır dosyası · tur 1 — hangi kaynak bu ağdan iş görüyor?

NEDEN BETİK. Irak ve Avustralya dosyalarında kapalı kapılar turun en pahalı
sürprizi oldu. Önce ölçülüyor, sonra plan yapılıyor.

DURUM KODU TEK BAŞINA YALAN SÖYLÜYOR (§2.12.1, İspanya vakası). Üç şey
birlikte okunuyor: kod + content-type + gövde uzunluğu.
  · 200 + text/html, gövde 150 karakter   → kabuk, veri yok
  · 200 + text/html, PDF beklenirken      → yumuşak 404
  · 200 + gövde 2 KB, JS uygulaması       → tarayıcısız okunamaz
User-Agent'ta kişisel bilgi yok.
"""
from __future__ import annotations
import json, pathlib, socket, ssl, time, urllib.error, urllib.request

KOK = pathlib.Path(__file__).parent
UA = {'User-Agent': 'tarimportali.net dosya arastirmasi'}

HEDEFLER = [
    # (ad, adres, sınıf, ne beklendiği)
    ("CAPMAS — Mısır İstatistik Kurumu", "https://www.capmas.gov.eg/", "BİRİNCİL", "html"),
    ("CAPMAS ingilizce", "https://www.capmas.gov.eg/Pages/StaticPages.aspx?page_id=5034", "BİRİNCİL", "html"),
    ("Mısır Tarım Bakanlığı", "https://www.moa.gov.eg/", "BİRİNCİL", "html"),
    ("Mısır Su Kaynakları Bakanlığı", "http://www.mwri.gov.eg/", "BİRİNCİL", "html"),
    ("Mısır Merkez Bankası", "https://www.cbe.org.eg/en/economic-research/statistics", "BİRİNCİL", "html"),
    ("Nile Basin Initiative", "https://nilebasin.org/", "BAĞIMSIZ", "html"),
    ("FAOSTAT toplu indirme dizini", "https://bulks-faostat.fao.org/production/", "BAĞIMSIZ", "html"),
    ("FAOSTAT REST API", "https://fenixservices.fao.org/faostat/api/v1/en/data/QCL", "BAĞIMSIZ", "json"),
    ("Dünya Bankası API", "https://api.worldbank.org/v2/country/EGY/indicator/AG.LND.AGRI.K2?format=json", "BAĞIMSIZ", "json"),
    ("UN Comtrade preview", "https://comtradeapi.un.org/public/v1/preview/C/A/HS?reporterCode=818&period=2023&partnerCode=792&flowCode=X&cmdCode=TOTAL", "BAĞIMSIZ", "json"),
    ("USDA FAS PSD toplu", "https://apps.fas.usda.gov/psdonline/downloads/psd_alldata_csv.zip", "BAĞIMSIZ", "zip"),
    ("FAO AQUASTAT ülke profili", "https://www.fao.org/aquastat/en/countries-and-basins/country-profiles/country/EGY", "BAĞIMSIZ", "html"),
    ("FAO belge (fao.org/4)", "https://www.fao.org/4/y5082e/y5082e00.pdf", "BAĞIMSIZ", "pdf"),
    ("Resmî Gazete arşivi", "https://www.resmigazete.gov.tr/arsiv/10127.pdf", "BİRİNCİL", "pdf"),
    ("TBMM tutanak arşivi", "https://www5.tbmm.gov.tr/tutanaklar/TUTANAK/TBMM/", "BİRİNCİL", "html"),
    ("TÜİK dış ticaret", "https://data.tuik.gov.tr/Kategori/GetKategori?p=dis-ticaret-104", "BİRİNCİL", "html"),
    ("TİM ihracat rakamları", "https://tim.org.tr/tr/ihracat-rakamlari", "BİRİNCİL", "html"),
    ("Suez Canal Authority", "https://www.suezcanal.gov.eg/English/Pages/default.aspx", "BİRİNCİL", "html"),
]


def dene(adres: str, beklenen: str):
    istek = urllib.request.Request(adres, headers=UA)
    try:
        with urllib.request.urlopen(istek, timeout=25) as r:
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
    if beklenen == 'pdf' and ct != 'application/pdf':
        teshis = f'YUMUŞAK 404 — pdf beklenirken {ct}'
    elif beklenen == 'zip' and 'zip' not in ct and 'octet' not in ct:
        teshis = f'beklenmeyen tür: {ct}'
    elif beklenen == 'json' and 'json' not in ct:
        teshis = f'beklenmeyen tür: {ct}'
    elif beklenen == 'html' and n < 2000:
        teshis = f'KABUK — gövde {n} bayt'
    return {'kod': kod, 'tur': ct, 'bayt': int(tam) if tam and tam.isdigit() else n,
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
