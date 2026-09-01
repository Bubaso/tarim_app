#!/usr/bin/env bash
# Ziraat Bankası — Kurum Dosyası · ham kaynak çekimi
#
# Neden betik: her rakamın kaynağına geri yürünebilmesi gerekiyor. Bu betik
# yeniden çalıştırıldığında aynı dosyaları aynı adlarla getirir; bir rakam
# tartışmaya açılırsa PDF'in kendisine bakılır, hatırlanana değil.
#
# ── AĞ SINIRI (TMO dosyasında da yaşandı) ─────────────────────────────────
# mevzuat.gov.tr ve resmigazete.gov.tr bu ağdan AÇILMIYOR (bağlantı hiç
# kurulmuyor, curl 000 dönüyor). Kanun ve nizamname künyeleri bu yüzden
# bankanın kendi belgelerinden alınıyor. Birincil kaynaktan doğrulanamayan
# Resmî Gazete tarih/sayısı METNE YAZILMAZ — uydurmak yerine hiç yazmamak.
#
# ── NEDEN ÜÇ FAALİYET RAPORU ──────────────────────────────────────────────
# Raporların her biri ~16 MB; beş yılın beşini indirmek depoya 80 MB koyardı.
# Her rapor bir önceki yılın karşılaştırmalı rakamını da taşıdığı için üç
# rapor (2025, 2023, 2021) 2020-2025 aralığını kapatıyor. Ara yıl gerekirse
# aşağıdaki satır çoğaltılır; adres kalıbı yıl dışında aynı.
set -euo pipefail
KOK="https://www.ziraatbank.com.tr"

cek() { # <yol> <hedef>
  echo "→ $2"
  curl -sS -L --max-time 180 "$KOK/$1" -o "$2"
}

# ── Kurumun kendi anlatısı ────────────────────────────────────────────────
# Tarihçe sayfası statik HTML ve 1863→2025 kilometre taşlarını tam veriyor.
# Bu KURUMUN ANLATISI, bağımsız veri değil; öyle işaretlenip öyle kullanılır.
cek "tr/bankamiz/hakkimizda/bankamiz-tarihcesi"     site_tarihce.html
cek "tr/bankamiz/hakkimizda/gunumuzde-ziraat-bankasi" site_bugun.html
cek "tr/bankamiz/hakkimizda/organizasyon-yapimiz"   site_organizasyon.html
cek "tr/ticari/tarim"                               site_tarim_bankaciligi.html
cek "tr/yatirimci-iliskileri/finansal-bilgiler"     site_finansal.html

# ── Entegre faaliyet raporları ────────────────────────────────────────────
BELGE="tr/yatirimci-iliskileri-ZB/finansal-bilgiler/Documents"
cek "$BELGE/2025_entegre_faaliyet_raporu.pdf"       faaliyet_2025.pdf
cek "$BELGE/2023_entegre_faaliyet_raporu.pdf"       faaliyet_2023.pdf
cek "$BELGE/2021_entegre_faaliyet_raporu.pdf"       faaliyet_2021.pdf

# ── Karşılaştırma kaynağı (12. bölüm) ─────────────────────────────────────
# Rabobank bu ağdan 403 dönüyor (tarayıcı kimliğiyle de), raiffeisen.ch tarih
# sayfaları 404. Üç bankayı yüzeysel anlatmaktansa biri derin: Crédit Agricole.
UA="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120 Safari/537.36"
for ikili in \
  "https://www.credit-agricole.com/en/group/history-of-the-credit-agricole-group|site_creditagricole_tarih.html" \
  "https://www.credit-agricole.com/en/group/discover-the-credit-agricole-group|site_creditagricole_profil.html"; do
  adres="${ikili%%|*}"; hedef="${ikili##*|}"
  echo "→ $hedef"
  curl -sS -A "$UA" -L --max-time 90 "$adres" -o "$hedef"
done

# ── Tarihçe → yapısal JSON ────────────────────────────────────────────────
python3 tarihce_cikar.py

# ── PDF doğrulaması ───────────────────────────────────────────────────────
# HTML hata sayfası .pdf adıyla kaydedilip "indirildi" sanılmıştı (görsel
# indiricide yaşandı). Sihirli bayt bakılmadan hiçbir dosya kabul edilmiyor.
for f in *.pdf; do
  if [ "$(head -c 4 "$f")" != "%PDF" ]; then
    echo "HATA: $f PDF değil — $(head -c 60 "$f" | tr -d '\0')" >&2
    exit 1
  fi
  echo "  ✓ $f $(wc -c < "$f") bayt"
done

# ── PDF → metin ───────────────────────────────────────────────────────────
python3 - <<'PY'
from pypdf import PdfReader
import glob
for ad in sorted(glob.glob('*.pdf')):
    hedef = ad[:-4] + '.txt'
    try:
        r = PdfReader(ad)
        # Sayfalar \f ile ayrılıyor: bir rakamın KAÇINCI SAYFADA olduğu
        # doğrulama betiğinin sorusu, metni tek parça yazmak onu siliyor.
        txt = '\n\f\n'.join((p.extract_text() or '') for p in r.pages)
        open(hedef, 'w').write(txt)
        print(f'{ad}: {len(r.pages)} sayfa → {hedef}')
    except Exception as e:
        print(f'{ad}: ÇIKARILAMADI — {e}')
PY
