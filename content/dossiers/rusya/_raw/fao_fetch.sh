#!/usr/bin/env bash
# FAOSTAT toplu CSV'lerini indirir ve açar. ~237 MB iner, açılınca ~1 GB.
# Çıkarım betikleri çalıştıktan sonra `rm -rf x *.zip` ile silinmeli.
#
# BÖLGE TUZAĞI (Hollanda dosyasından devralındı, burada daha da can yakıcı):
# FAOSTAT Türkiye'yi ASYA, Rusya'yı AVRUPA grubuna koyuyor. Tek bölge indirilirse
# karşılaştırmanın yarısı sessizce boş gelir — hata vermez, satır bulunmaz.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE="https://bulks-faostat.fao.org/production"
cd "$DIR"
mkdir -p x

FILES=(
  "Production_Crops_Livestock_E_Europe.zip"
  "Production_Crops_Livestock_E_Asia.zip"
  "Value_of_Production_E_Europe.zip"
  "Value_of_Production_E_Asia.zip"
  "Trade_CropsLivestock_E_Europe.zip"
  "Trade_CropsLivestock_E_Asia.zip"
  "Trade_CropsLivestock_E_Africa.zip"
  "Trade_CropsLivestock_E_Americas.zip"
  "Trade_CropsLivestock_E_Oceania.zip"
  # Rusya'nın müşterileri — Türkiye kaçıncı sırada? 189 MB.
  "Trade_DetailedTradeMatrix_E_Europe.zip"
)

for f in "${FILES[@]}"; do
  printf 'indiriliyor: %-52s' "$f"
  curl -fsSL --max-time 1800 -o "$f" "$BASE/$f"
  unzip -oq "$f" -d x/
  printf 'ok\n'
done

printf 'bitti. açılan dosyalar: x/\n'
