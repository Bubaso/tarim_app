#!/usr/bin/env bash
# Avustralya — TARIM katmanı kaynak çekimi (su katmanı cek.sh'te)
#
# ERİŞİM HARİTASI — tarım için ölçüldü:
#   ✓ data.api.abs.gov.au      ABS (AG_BROADACRE, LSTOCK_SLAUGHT 1965→)
#   ✓ sdmx.oecd.org            OECD tarım politikası göstergeleri (PSE)
#   ✓ comtradeapi.un.org       ikili ticaret
#   ✓ api.worldbank.org        makro göstergeler
#   ✗ csiro.au · publications.csiro.au · research.csiro.au   → 000
#   ✗ dpi.nsw.gov.au · agriculture.vic.gov.au · daf.qld.gov.au → 403
#   ✗ api.trove.nla.gov.au     → 410 (v2 API kapatılmış)
#   ✗ adb.anu.edu.au arama     → 400 (biyografi aramaya kapalı)
#
# ADB TUZAĞI: tahmin edilen biyografi kimliği 200 dönüyor ama BAŞKA BİRİNİ
# veriyor — /biography/farrer-william-james-6144 "Mary Martha Farrelly"
# sayfasını açtı. Kimlik doğrulanmadan hiçbir biyografi kaynak gösterilmez.
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p kaynak_dosyalari
ua='Mozilla/5.0'

# ── ABS: tarla bitkileri (yalnız 2022-2024 kapsıyor) ─────────────────────
# ANA BİLGİSAYAR TUZAĞI: data.api.abs.gov.au çalışıyor, api.data.abs.gov.au 000.
curl -s -A "$ua" -H 'Accept: text/csv' -L --max-time 180 \
  "https://data.api.abs.gov.au/rest/data/ABS,AG_BROADACRE,1.0.0/all?startPeriod=2015&dimensionAtObservation=AllDimensions" \
  -o kaynak_dosyalari/abs_tarla_bitkileri.csv

# ── ABS: hayvan kesimi — 1965'ten beri çeyreklik ─────────────────────────
# Dosyanın en uzun serisi. UNIT_MULT=3 → değerler BİNDİR.
curl -s -A "$ua" -H 'Accept: text/csv' -L --max-time 180 \
  "https://data.api.abs.gov.au/rest/data/ABS,LSTOCK_SLAUGHT,1.0.0/all?dimensionAtObservation=AllDimensions" \
  -o kaynak_dosyalari/abs_hayvan_kesim.csv

# ── OECD: Üretici Destek Tahmini (PSE) ───────────────────────────────────
# oecd.org 403 veriyor ama sdmx.oecd.org açık. Akış kimliği uzun ve
# tahmin edilemez: DSD_AGR_POLIND@DF_PSE, sürüm 1.2, kurum OECD.TAD.ARP.
curl -s -A "$ua" -H 'Accept: application/vnd.sdmx.data+csv;version=1.0.0' -L --max-time 180 \
  "https://sdmx.oecd.org/public/rest/data/OECD.TAD.ARP,DSD_AGR_POLIND@DF_PSE,1.2/all?startPeriod=2015&endPeriod=2023" \
  -o kaynak_dosyalari/oecd_destek_pse.csv

echo "── sağlama ──"
python3 - <<'PY'
import csv, pathlib, sys
hata = 0
for ad, en_az in (('abs_tarla_bitkileri.csv', 5000), ('abs_hayvan_kesim.csv', 20000),
                  ('oecd_destek_pse.csv', 500)):
    p = pathlib.Path('kaynak_dosyalari') / ad
    n = len(list(csv.reader(p.open(encoding='utf-8')))) if p.exists() else 0
    ok = n >= en_az
    print(f"  {'✓' if ok else '✗'} {ad:<28s} {n:>7,} satır")
    hata |= (not ok)
sys.exit(hata)
PY
