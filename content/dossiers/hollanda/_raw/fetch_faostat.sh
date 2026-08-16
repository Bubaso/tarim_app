#!/usr/bin/env bash
# FAOSTAT toplu CSV'lerini indirir ve açar. ~2,2 GB yer kaplar.
# Çıkarım betikleri çalıştıktan sonra `rm -rf x *.zip` ile silinmeli.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE="https://bulks-faostat.fao.org/production"
cd "$DIR"
mkdir -p x

# Türkiye Asya, Hollanda Avrupa grubunda — ikisi de gerekli.
FILES=(
  "Production_Crops_Livestock_E_Europe.zip"
  "Production_Crops_Livestock_E_Asia.zip"
  "Value_of_Production_E_Europe.zip"
  "Value_of_Production_E_Asia.zip"
  "Employment_Indicators_Agriculture_E_Europe.zip"
  "Employment_Indicators_Agriculture_E_Asia.zip"
  # Dünya sıralaması için beş bölgenin tamamı
  "Trade_CropsLivestock_E_Europe.zip"
  "Trade_CropsLivestock_E_Asia.zip"
  "Trade_CropsLivestock_E_Africa.zip"
  "Trade_CropsLivestock_E_Americas.zip"
  "Trade_CropsLivestock_E_Oceania.zip"
  # İkili ticaret — tek başına 180 MB (açılınca 737 MB)
  "Trade_DetailedTradeMatrix_E_Europe.zip"
)

for f in "${FILES[@]}"; do
  printf 'indiriliyor: %s\n' "$f"
  curl -fsSL --max-time 900 -o "$f" "$BASE/$f"
  unzip -oq "$f" -d x/
done

printf 'bitti. açılan dosyalar: x/\n'
