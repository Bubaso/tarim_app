#!/bin/bash
# TİGEM erişim haritası — DURUM KODUNA DEĞİL İÇERİK TÜRÜNE bakar.
# Irak dosyasının dersi: Firebase ve çok sayıda kurum sitesi olmayan yol için
# 200 + text/html döndürüyor (yumuşak 404). Gövde uzunluğu da ölçülüyor:
# JavaScript kabuğu 200 döner ama içinde veri yoktur.
UA='Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 Chrome/131.0 Safari/537.36'
yokla() {
  local ad="$1" url="$2"
  local r
  r=$(curl -sS -L --max-time 25 -A "$UA" -o /tmp/y.$$ -w '%{http_code}|%{content_type}|%{size_download}' "$url" 2>/dev/null) || r="000|-|0"
  local kod="${r%%|*}" rest="${r#*|}" tip="${rest%%|*}" boy="${r##*|}"
  local govde=""
  if [[ "$tip" == text/html* ]]; then
    govde=$(python3 -c "
import re,sys,html
t=open('/tmp/y.$$','r',errors='replace').read()
t=re.sub(r'(?is)<(script|style|nav|footer|head).*?</\1>',' ',t)
t=html.unescape(re.sub(r'(?s)<[^>]+>',' ',t)); t=re.sub(r'\s+',' ',t).strip()
print(len(t))" 2>/dev/null)
    govde=" · metin ${govde:-?} krk"
  fi
  printf "  %-36s %s  %-28s %7s B%s\n" "$ad" "$kod" "${tip:0:28}" "$boy" "$govde"
  rm -f /tmp/y.$$
}
echo "══ TİGEM'in kendi siteleri"
yokla "tigem.gov.tr" "https://www.tigem.gov.tr/"
yokla "tigem faaliyet raporu sayfası" "https://www.tigem.gov.tr/Sayfa/Detay/faaliyet-raporlari"
yokla "tigem işletmeler" "https://www.tigem.gov.tr/Sayfa/Detay/isletmelerimiz"
yokla "tigem mevzuat" "https://www.tigem.gov.tr/Sayfa/Detay/mevzuat"
echo
echo "══ Birincil mevzuat"
yokla "Resmî Gazete arşiv (233 KHK)" "https://www.resmigazete.gov.tr/arsiv/18435_1.pdf"
yokla "mevzuat.gov.tr 233 KHK" "https://www.mevzuat.gov.tr/MevzuatMetin/4.5.233.pdf"
yokla "mevzuat.gov.tr 5433 (DÜÇ 1950)" "https://www.mevzuat.gov.tr/MevzuatMetin/1.3.5433.pdf"
echo
echo "══ Denetim ve KİT raporları"
yokla "Sayıştay ana sayfa" "https://www.sayistay.gov.tr/"
yokla "Sayıştay KİT raporları" "https://www.sayistay.gov.tr/reports/category/8-kit-denetim-raporlari"
yokla "SBB Kamu İşletmeleri Raporu" "https://www.sbb.gov.tr/kamu-isletmeleri-raporlari/"
echo
echo "══ Bağımsız istatistik"
yokla "TÜİK ana" "https://www.tuik.gov.tr/"
yokla "TBMM tutanak arama" "https://www.tbmm.gov.tr/"
