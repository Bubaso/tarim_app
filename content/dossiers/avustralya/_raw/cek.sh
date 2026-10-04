#!/usr/bin/env bash
# Avustralya — Ülke Dosyası Sayı 04 · kaynak çekimi
#
# ERİŞİM HARİTASI — ÖNCE BUNU OKU. Avustralya'nın merkezî tarım veri kurumları
# bu ağdan AÇILMIYOR ve bu, dosyanın kaynak seçimini belirledi:
#   ✗ agriculture.gov.au (ABARES) → 000   ✗ data.daff.gov.au → 000
#   ✗ mdba.gov.au → 403                   ✗ oecd.org → 403
#   ✓ abs.gov.au · data.gov.au · bom.gov.au · waterregister.vic.gov.au
#   ✓ legislation.vic.gov.au  ← kanun metni
#
# Ulusal kurum kapalıyken EYALET SİCİLİ birincil kaynak olarak kullanılıyor;
# metinde kapsam (kuzey Victoria) her bölümde belirtilecek.
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p kaynak_dosyalari
ua='Mozilla/5.0'
B='https://www.waterregister.vic.gov.au/images/documents'

curl -sL -A "$ua" --max-time 180 "$B/Victorian-Water-Trading-Annual-Report-2024-25.pdf" -o kaynak_dosyalari/yillik_2024_25.pdf
curl -sL -A "$ua" --max-time 180 "$B/Victorian-Water-Trading-Annual-Report-2023-24.pdf" -o kaynak_dosyalari/yillik_2023_24.pdf
curl -sL -A "$ua" --max-time 180 "$B/Water-Market-Trends-Updated-Trends-in-Northern-Victorian-Water-Trade-2025.pdf" -o kaynak_dosyalari/egilim_2001_2024.pdf
# KURA: Barmah darlığından ticaret hakkı KURAYLA dağıtılıyor, çekilişi rekabet
# kurumu izliyor. Dosyanın en şaşırtıcı mekanizması; birincil belge bu.
curl -sL -A "$ua" --max-time 120 "$B/ACCC_statement_randomisation_July_2026_Barmah.pdf" -o kaynak_dosyalari/accc_kura_2026.pdf
curl -sL -A "$ua" --max-time 120 "$B/Goulburn-to-Murray-and-Barmah-Narrows-Post-Trade-Opening-Report-July-2026.pdf" -o kaynak_dosyalari/kura_raporu_2026.pdf
curl -sL -A "$ua" --max-time 180 "$B/water-supply-and-demand-in-the-southern-basin-2025-update.pdf" -o kaynak_dosyalari/arz_talep_2025.pdf

# BİRİNCİL: Water Act 1989 (Victoria) tasdikli konsolide metin, 923 sayfa.
# Kısım 3A su payını, Kısım 4B arazide kullanım iznini düzenler; ayrışma bir
# cümle değil, kanunun YAPISI. Sürüm değişirse adres de değişir:
#   https://www.legislation.vic.gov.au/in-force/acts/water-act-1989
curl -sL -A "$ua" --max-time 400 \
  "https://content.legislation.vic.gov.au/sites/default/files/2026-06/89-80aa147-authorised.pdf" \
  -o kaynak_dosyalari/vic_su_kanunu_1989.pdf

# BAĞIMSIZ: BoM Kuraklık Bildirisi arşivi.
# DİKKAT: BoM'un YENİ sayfaları JavaScript ile geliyor (192 KB HTML'den 319
# karakter metin). ESKİ statik arşiv tam içerik veriyor — bu yüzden bu adres.
curl -s -A "$ua" -L --max-time 120 "https://www.bom.gov.au/climate/drought/archive.shtml" -o kaynak_dosyalari/bom_kuraklik_arsiv.html

# BAĞIMSIZ: ulusal katman. Ulusal su piyasası raporunu artık ABARES değil BoM
# yayımlıyor. DİKKAT: 2020-21 ve sonrası 404 — ulusal rakam 2019-20'de kalıyor,
# piyasa verisi 2023-24'e geliyor; dört yıllık fark metinde belirtilecek.
curl -sL -A "$ua" --max-time 300 "http://www.bom.gov.au/water/waterinaustralia/files/Water-in-Australia-2019-20.pdf" -o kaynak_dosyalari/ulusal_su_2019_20.pdf

# BAĞIMSIZ: ABS tarla bitkileri.
# ANA BİLGİSAYAR ADI TUZAĞI: data.api.abs.gov.au çalışıyor,
# api.data.abs.gov.au bu ağdan 000 veriyor. İkisi kolay karıştırılıyor.
curl -s -A "$ua" -H 'Accept: text/csv' -L --max-time 180 \
  "https://data.api.abs.gov.au/rest/data/ABS,AG_BROADACRE,1.0.0/all?startPeriod=2015&dimensionAtObservation=AllDimensions" \
  -o kaynak_dosyalari/abs_tarla_bitkileri.csv

echo "── içerik sınaması ──"
python3 - <<'PY'
import pathlib, sys
hata = 0
for p in sorted(pathlib.Path('kaynak_dosyalari').glob('*.pdf')):
    ok = p.read_bytes()[:4] == b'%PDF'
    print(f"  {'✓' if ok else '✗'} {p.name} {p.stat().st_size // 1024} KB"
          + ('' if ok else '  ← PDF DEĞİL, yumuşak 404 olabilir'))
    hata |= (not ok)
sys.exit(hata)
PY
