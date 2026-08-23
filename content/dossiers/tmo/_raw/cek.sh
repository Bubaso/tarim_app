#!/usr/bin/env bash
# TMO — Kurum Dosyası · ham kaynak çekimi
#
# Neden betik: her rakamın kaynağına geri yürünebilmesi gerekiyor. Bu betik
# yeniden çalıştırıldığında aynı dosyaları aynı adlarla getirir; bir rakam
# tartışmaya açılırsa PDF'in kendisine bakılır, hatırlanana değil.
#
# NOT: mevzuat.gov.tr bu ağdan zaman aşımına uğruyor (WebFetch sertifika
# hatası, curl timeout). Kanun metinleri bu yüzden TMO'nun kendi mevzuat
# bölümünden ve TBMM arşivinden alınıyor. Kuruluş kanununun Resmî Gazete
# tarih/sayısı HENÜZ BİRİNCİL KAYNAKTAN DOĞRULANMADI.
set -euo pipefail
KOK="https://www.tmo.gov.tr"

cek() { # <yol> <hedef>
  echo "→ $2"
  curl -sS -L --max-time 90 "$KOK/$1" -o "$2"
}

# ── Kurumsal kimlik ────────────────────────────────────────────────────────
cek "Upload/Document/mevzuat/tmoanastatusu.pdf"        ana_statu.pdf
cek "Upload/Document/genmud/kurumhakkinda.pdf"         kurum_hakkinda.pdf
cek "Upload/Document/genmud/tasrateskilati.pdf"        tasra_teskilati.pdf
cek "Upload/Document/genmud/TmoOrgSemaTR.pdf"          org_sema.pdf

# ── Faaliyet raporları · seri ──────────────────────────────────────────────
cek "Upload/Document/maliisler/2025faliyetroporu.pdf"  faaliyet_2025.pdf
cek "Upload/Document/maliisler/2024faaliyetraporu.pdf" faaliyet_2024.pdf
cek "Upload/Document/maliisler/2022faaliyetraporu.pdf" faaliyet_2022.pdf

# ── Mevzuat dizini (kanun listesi bu sayfadan çıkarıldı) ───────────────────
cek "mevzuat/3/kanunlar"                               site_kanunlar.html
cek "bilgi-merkezi/istatistikler"                      site_istatistik.html

# ── PDF → metin ────────────────────────────────────────────────────────────
python3 - <<'PY'
from pypdf import PdfReader
import glob, os
for ad in sorted(glob.glob('*.pdf')):
    hedef = ad[:-4] + '.txt'
    try:
        r = PdfReader(ad)
        txt = '\n'.join((p.extract_text() or '') for p in r.pages)
        open(hedef, 'w').write(txt)
        print(f'{ad}: {len(r.pages)} sayfa → {hedef}')
    except Exception as e:
        print(f'{ad}: ÇIKARILAMADI — {e}')
PY
