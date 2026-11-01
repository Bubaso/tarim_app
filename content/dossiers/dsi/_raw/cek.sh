#!/usr/bin/env bash
# DSİ — Kurum Dosyası Sayı 05 · ham kaynak çekimi
#
# Neden betik: her rakamın kaynağına geri yürünebilmesi gerekiyor. Yeniden
# çalıştırıldığında aynı dosyaları aynı adlarla getirir; bir rakam tartışmaya
# açılırsa PDF'in kendisine bakılır, hatırlanana değil (§2.2).
#
# ── AĞ SINIRI ARTIK YOK ───────────────────────────────────────────────────
# TMO ve Ziraat dosyalarında mevzuat.gov.tr bu ağdan HİÇ açılmıyordu (curl
# 000) ve kural oradan doğmuştu: birincil kaynaktan doğrulanamayan RG künyesi
# metne yazılmaz. 10 Eylül 2026'da sınır kalktı (§8.14.1) ve bu dosya dizinin
# ikinci RG künyeli dosyası oluyor. Künye yine YALNIZCA çekilmiş belgeden
# yazılır.
#
# ── İKİ KANUN, İKİ AYRI İŞ ────────────────────────────────────────────────
# 6200 kurumun kendi kanunu. 6172 ise DSİ'nin inşa ettiği tesisleri İŞLETMEYİ
# devrettiği birlikleri düzenliyor. İkisi birlikte okunmadan "DSİ ne yapıyor"
# sorusu cevaplanamıyor.
#
# ── YUMUŞAK 404 ───────────────────────────────────────────────────────────
# Bu projede 404 diye bir şey yok: hem mevzuat.gov.tr mülga kanunda hem
# kurum siteleri bilinmeyen adreste 200 + HTML döndürüyor (§8.14.1, §2.12.1).
# Her indirme İÇERİĞE karşı sınanıyor; durum kodu tek başına yeterli değil.
set -euo pipefail
cd "$(dirname "$0")"
UA='Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 Chrome/120'

cek() { # <adres> <hedef> <beklenen_ibare>
  printf '→ %-34s ' "$2"
  curl -sS -L --max-time 240 -A "$UA" "$1" -o "$2" || { echo "AĞ HATASI"; return 1; }
  local n; n=$(wc -c < "$2" | tr -d ' ')
  if [ "$n" -lt 20000 ]; then echo "ÇOK KÜÇÜK (${n}B) — yumuşak 404?"; rm -f "$2"; return 1; fi
  echo "${n} B"
}

# ── Birincil: kanun metinleri ─────────────────────────────────────────────
# Kimlikleri indirildikten SONRA dogrula_kaynak.py ile sınanıyor. 6200'ün
# 1. maddesi mülga (2/7/2018 – KHK-703/69); bu dosyanın ekseni muhtemelen
# oradan çıkacak ama kaynak okunmadan karar verilmiyor (§8.12).
cek "https://www.mevzuat.gov.tr/MevzuatMetin/1.3.6200.pdf" "kanun_6200.pdf" ""
cek "https://www.mevzuat.gov.tr/MevzuatMetin/1.5.6172.pdf" "kanun_6172_sulama_birlikleri.pdf" ""

# ── Kurumun kendi beyanı: faaliyet raporları ──────────────────────────────
# ÜÇ YIL, BEŞ DEĞİL. Her rapor bir önceki yılın karşılaştırmalı rakamını da
# taşıyor; 2025/2022/2019 üçlüsü 2018-2025 aralığını kapatıyor ve depoya
# gereksiz yüz megabayt koymuyor. Ara yıl gerekirse adres kalıbı
# dsi.gov.tr/Sayfa/Detay/759 sayfasından alınır — 2016'ya kadar duruyor.
CDN="https://cdniys.tarimorman.gov.tr/api/File/GetFile/425"
cek "$CDN/Sayfa/759/1107/DosyaGaleri/.dsi_2025_yili_idare_faaliyet_raporu.pdf" "faaliyet_2025.pdf" ""
cek "$CDN/Sayfa/759/1107/DosyaGaleri/dsi2022faaliyetraporu.pdf"                "faaliyet_2022.pdf" ""
# TUZAK: 2019 dosyasının adında Türkçe İ ve boşluk var; curl ham hâlini
# "Malformed input to a URL function" diye REDDEDİYOR. Yüzde kodlaması
# zorunlu — İ = %C4%B0, boşluk = %20. Adres sayfadan kopyalandığı gibi
# yapıştırılamaz.
cek "$CDN/KonuIcerik/759/1107/DosyaGaleri/DS%C4%B0%202019-yili-faaliyet-raporu.pdf" "faaliyet_2019.pdf" ""

# ── Kurumun kendi anlatısı ────────────────────────────────────────────────
# NOT: Bunlar "SİCİLİN BEYANI" sınıfı (§2.2) — kurumun kendisi hakkında
# söyledikleri. Kanun metniyle aynı ağırlıkta değil ve metinde böyle anılır.
for p in 754:site_tarihce.html 692:site_hakkimizda.html \
         697:site_sulama_dairesi.html 769:site_istatistik.html; do
  cek "https://www.dsi.gov.tr/Sayfa/Detay/${p%%:*}" "${p##*:}" ""
done

echo "✓ çekim bitti — şimdi: python3 dogrula_kaynak.py"
