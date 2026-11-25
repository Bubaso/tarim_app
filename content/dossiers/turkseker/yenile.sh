#!/bin/bash
# Dosyayı sıfırdan üretir. SIRA ÖNEMLİ: çıkarıcılar → veri → üreteçler → denetim.
#
# NEDEN VAR: ciftci_dususu_kimin alanı bir kez tek seferlik yamayla
# ciftci.json'a eklenmişti; çıkarıcı yeniden koşunca silindi ve build_data
# düştü. Tek tek koşturmak bunu göstermiyordu, bütün zincir gösterdi.
#
# AĞ GEREKTİRENLER BU ZİNCİRDE YOK. gorsel_indir.py, galeri_indir.py ve
# olc_anahtar.py ayrı koşuyor: ikisi kareleri indiriyor, biri yayımlanmış
# haberi okuyor. Üçünün de çıktısı (gorseller/, galeri_kunye.json,
# anahtar_olcum.json) diskte duruyor.
set -euo pipefail
cd "$(dirname "$0")"
echo "═══ çıkarıcılar ═══"
for f in pancar_ayikla seker_ayikla ciftci_ayikla kota_ayikla kurum_ayikla tarih_kur ticaret_ayikla haber_ayikla; do
  printf "  %-16s " "$f"; (cd _raw && python3 "$f.py" >/dev/null) && echo "✓"
done
echo "═══ katmanlar ═══"
# kur_galeri BUILD_DATA'DAN ÖNCE: build_data galeri.json'u okuyup data.json'a
# koyuyor. Sonra koşsaydı ilk turda data.json galerisiz çıkar, ikinci turda
# dolardı — "iki kez koşunca değişen çıktı" tam olarak bu zincirin
# yakalamak için yazıldığı hata.
printf "  %-16s " "kur_galeri";     (cd _raw && python3 kur_galeri.py >/dev/null) && echo "✓"
printf "  %-16s " "build_data";     python3 build_data.py >/dev/null && echo "✓"
for f in kur_grafikler kur_tasarim kur_gorseller kur_hikaye kur_yayin_gorselleri; do
  printf "  %-16s " "$f"; (cd _raw && python3 "$f.py" >/dev/null) && echo "✓"
done
echo "═══ denetimler ═══"
# DÜŞEN DENETÇİ ZİNCİRİ DÜŞÜRÜR. Önceki hâlde komut `&& echo "✓"` içinde
# koşuyordu; `set -e` bir `&&` zincirinin SOL tarafında devreye girmiyor,
# bu yüzden dogrula_yayin.py çöktüğü hâlde döngü sürdü ve altta
# "✓ zincir temiz" yazdı. Çıkış kodu artık ayrıca sınanıyor.
dusen=0
for d in dogrula_grafik dogrula_tasarim dogrula_metin dogrula_yayin dogrula_galeri dogrula_goc; do
  printf "  %-16s " "$d"
  if python3 "$d.py" >/dev/null 2>&1; then echo "✓"; else echo "✗ DÜŞTÜ"; dusen=1; fi
done
if [ "$dusen" -ne 0 ]; then
  echo "  ✗ zincir TEMİZ DEĞİL — düşen denetçiyi tek başına koştur"
  exit 1
fi
echo "  ✓ zincir temiz"
